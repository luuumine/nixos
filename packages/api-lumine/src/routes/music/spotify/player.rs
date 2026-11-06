use crate::{AppState, Cache, routes::music::models::*};
use reqwest::StatusCode;
use std::time::{SystemTime, UNIX_EPOCH};

pub async fn fetch_currently_playing(
    state: &AppState,
    access_token: &str,
) -> Result<NowPlayingResponse, String> {
    const SONG_LIFETIME: u64 = 5;
    const ERROR_TIMEOUT: u64 = 1800;

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| format!("time shouldnt be negative: {}", e))?
        .as_secs();

    let buffer = 1;

    {
        // get read lock
        let cache = state.spotify.cache.playing.read().await;
        if let Some(song_data) = &*cache {
            if now + buffer < song_data.expires_at {
                return Ok(song_data.data.clone());
            }
        }
    } // `cache` goes out of scope there

    // get write lock. pauses other threads
    let mut cache = state.spotify.cache.playing.write().await;

    // check if another thread wrote new valid data before updating it
    if let Some(song_data) = &*cache {
        if now < song_data.expires_at {
            return Ok(song_data.data.clone());
        }
    }

    let url = format!("{}/v1/me/player/currently-playing", state.spotify.api_url);

    let response = state
        .http_client
        .get(url)
        .bearer_auth(access_token)
        .send()
        .await
        .map_err(|e| format!("failed to fetch response: {}", e))?;

    let status = response.status();

    let (response_data, ttl, api_err) = match status {
        StatusCode::NO_CONTENT => (NowPlayingResponse::NotPlaying, SONG_LIFETIME, None),

        StatusCode::OK => {
            let json = response
                .json::<serde_json::Value>()
                .await
                .map_err(|e| format!("failed to parse response body: {}", e))?;
            let (song_data, b) = parse_spotify_response(json)?;

            let state = match b {
                true => NowPlayingResponse::Playing(song_data),
                false => NowPlayingResponse::Paused(song_data),
            };

            (state, SONG_LIFETIME, None)
        }

        StatusCode::TOO_MANY_REQUESTS => {
            let mut timeout = ERROR_TIMEOUT; // default 30 mins

            if let Some(retry_val) = response.headers().get("retry-after") {
                if let Ok(retry_str) = retry_val.to_str() {
                    if let Ok(parsed_timeout) = retry_str.parse::<u64>() {
                        timeout = parsed_timeout;
                    }
                }
            }

            eprintln!(
                "spotify api returned unexpected status: {} (cooling down for {}s)",
                status, timeout
            );

            (
                NowPlayingResponse::NotPlaying,
                timeout + SONG_LIFETIME,
                None,
            )
        }

        _ => {
            eprintln!("spotify api returned unexpected status: {}", status);
            (
                NowPlayingResponse::NotPlaying,
                ERROR_TIMEOUT,
                Some(format!(
                    "spotify api returned unexpected status: {}",
                    status
                )),
            )
        }
    };

    *cache = Some(Cache {
        data: response_data.clone(),
        expires_at: now + ttl,
    });

    if let Some(err) = api_err {
        return Err(err);
    }

    Ok(response_data)
}

fn parse_spotify_response(json: serde_json::Value) -> Result<(Track, bool), String> {
    let is_playing = json["is_playing"]
        .as_bool()
        .ok_or("missing \"is_playing\" boolean in spotify response")?;

    let item = &json["item"];
    if item.is_null() {
        return Err("spotify \"item\" is null (no track data available)".to_string());
    }

    let title = item["name"]
        .as_str()
        .ok_or("missing track name")?
        .to_string();
    let album = item["album"]["name"]
        .as_str()
        .ok_or("missing album name")?
        .to_string();
    let track_number = item["track_number"]
        .as_u64()
        .ok_or("missing track number")?;
    let url = item["external_urls"]["spotify"]
        .as_str()
        .ok_or("missing song url")?
        .to_string();

    let images_array = item["album"]["images"]
        .as_array()
        .ok_or("missing album images")?;
    if images_array.len() != 3 {
        return Err("expected 3 image sizes from Spotify".to_string());
    }
    let images = Image {
        small: images_array[2]["url"].as_str().unwrap().to_string(),
        medium: images_array[1]["url"].as_str().unwrap().to_string(),
        large: images_array[0]["url"].as_str().unwrap().to_string(),
    };

    let artists_array = item["artists"].as_array().ok_or("missing artists array")?;
    let mut artists = Vec::new();
    for artist in artists_array {
        if let (Some(name), Some(artist_url)) = (
            artist["name"].as_str(),
            artist["external_urls"]["spotify"].as_str(),
        ) {
            artists.push(Artist {
                name: name.to_string(),
                url: artist_url.to_string(),
                images: None,
            })
        }
    }

    let track = Track {
        title,
        album,
        track_number,
        url,
        images,
        artists,
    };

    Ok((track, is_playing))
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::test_utils::create_dummy_state;
    use serde_json::{Value, json};
    use wiremock::{
        Mock, MockServer, ResponseTemplate,
        matchers::{header, method, path},
    };

    #[tokio::test]
    async fn fetch_song_while_playing() -> Result<(), String> {
        let mock_server = MockServer::start().await;

        let raw_json = include_str!("../fixtures/spotify_playing.json");
        let spotify_mock_body: Value = serde_json::from_str(raw_json)
            .map_err(|e| format!("failed to parse the spotify fixture json: {}", e))?;

        Mock::given(method("GET"))
            .and(path("/v1/me/player/currently-playing"))
            .and(header("Authorization", "Bearer fake_token"))
            .respond_with(ResponseTemplate::new(200).set_body_json(spotify_mock_body))
            .mount(&mock_server)
            .await;

        let state = create_dummy_state(&mock_server.uri(), "http://dummy-account.internal").await;

        let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

        if let NowPlayingResponse::Playing(track) = now_playing_response {
            assert_eq!(track.title, "belavenir");
            assert_eq!(track.album, "RAPPEL");
            assert_eq!(
                track.url,
                "https://open.spotify.com/track/7KdLgNe9VGs7v9F39M8wl9"
            );

            // images
            assert_eq!(
                track.images.large,
                "https://i.scdn.co/image/ab67616d0000b273840cee3deff8dd039e25aaa5"
            );
            assert_eq!(
                track.images.small,
                "https://i.scdn.co/image/ab67616d00004851840cee3deff8dd039e25aaa5"
            );

            // artists
            assert_eq!(track.artists.len(), 2);
            assert_eq!(track.artists[0].name, "Jima");
            assert_eq!(
                track.artists[0].url,
                "https://open.spotify.com/artist/5kGE5WhDLFZwLude1avCuw"
            );
            assert_eq!(track.artists[1].name, "ysma");
        } else {
            return Err("expected Playing".to_string());
        };

        Ok(())
    }

    #[tokio::test]
    async fn fetch_song_while_paused() -> Result<(), String> {
        let mock_server = MockServer::start().await;

        let raw_json = include_str!("../fixtures/spotify_playing.json");
        let mut spotify_mock_body: Value = serde_json::from_str(raw_json)
            .map_err(|e| format!("failed to parse the spotify fixture json: {}", e))?;

        if let Some(is_playing) = spotify_mock_body.get_mut("is_playing") {
            *is_playing = json!(false);
        }

        Mock::given(method("GET"))
            .and(path("/v1/me/player/currently-playing"))
            .and(header("Authorization", "Bearer fake_token"))
            .respond_with(ResponseTemplate::new(200).set_body_json(spotify_mock_body))
            .mount(&mock_server)
            .await;

        let state = create_dummy_state(&mock_server.uri(), "http://dummy-account.internal").await;

        let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

        if let NowPlayingResponse::Paused(track) = now_playing_response {
            assert_eq!(track.title, "belavenir");
            assert_eq!(track.album, "RAPPEL");
            assert_eq!(
                track.url,
                "https://open.spotify.com/track/7KdLgNe9VGs7v9F39M8wl9"
            );

            // images
            assert_eq!(
                track.images.large,
                "https://i.scdn.co/image/ab67616d0000b273840cee3deff8dd039e25aaa5"
            );
            assert_eq!(
                track.images.small,
                "https://i.scdn.co/image/ab67616d00004851840cee3deff8dd039e25aaa5"
            );

            // artists
            assert_eq!(track.artists.len(), 2);
            assert_eq!(track.artists[0].name, "Jima");
            assert_eq!(
                track.artists[0].url,
                "https://open.spotify.com/artist/5kGE5WhDLFZwLude1avCuw"
            );
            assert_eq!(track.artists[1].name, "ysma");
        } else {
            return Err("expected NotPlaying".to_string());
        };

        Ok(())
    }

    #[tokio::test]
    async fn fetch_song_while_not_playing() -> Result<(), String> {
        let mock_server = MockServer::start().await;

        Mock::given(method("GET"))
            .and(path("/v1/me/player/currently-playing"))
            .and(header("Authorization", "Bearer fake_token"))
            .respond_with(ResponseTemplate::new(204))
            .mount(&mock_server)
            .await;

        let state = create_dummy_state(&mock_server.uri(), "http://dummy-account.internal").await;

        let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

        assert!(
            matches!(now_playing_response, NowPlayingResponse::NotPlaying),
            "expected NotPlaying, but got something else"
        );

        Ok(())
    }
}
