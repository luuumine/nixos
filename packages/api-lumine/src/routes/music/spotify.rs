use std::time::{SystemTime, UNIX_EPOCH};

use crate::{
    AppState, SongCache,
    routes::music::currently_playing::{NowPlayingResponse, SongData},
};
use reqwest::StatusCode;

pub async fn fetch_currently_playing(
    state: &AppState,
    access_token: &str,
) -> Result<NowPlayingResponse, String> {
    const SONG_LIFETIME: u64 = 5;

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| format!("time shouldnt be negative: {}", e))?
        .as_secs();

    let buffer = 1;

    {
        // get read lock
        let cache = state.spotify.song_cache.read().await;
        if let Some(song_data) = &*cache {
            if now + buffer < song_data.expires_at {
                return Ok(song_data.data.clone());
            }
        }
    } // `cache` goes out of scope there

    // get write lock. pauses other threads
    let mut cache = state.spotify.song_cache.write().await;

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

    let response_data = match response.status() {
        StatusCode::NO_CONTENT => return Ok(NowPlayingResponse::NotPlaying),
        StatusCode::OK => {
            let json = response
                .json::<serde_json::Value>()
                .await
                .map_err(|e| format!("failed to parse response body: {}", e))?;
            let (song_data, b) = parse_spotify_response(json)?;
            match b {
                true => NowPlayingResponse::Playing(song_data),
                false => NowPlayingResponse::Paused(song_data),
            }
        }
        _ => {
            return Err(format!(
                "spotify api returned unexpected status: {}",
                response.status()
            ));
        }
    };

    *cache = Some(SongCache {
        data: response_data.clone(),
        expires_at: now + SONG_LIFETIME,
    });

    Ok(response_data)
}

fn parse_spotify_response(json: serde_json::Value) -> Result<(SongData, bool), String> {
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
    let song_url = item["external_urls"]["spotify"]
        .as_str()
        .ok_or("missing song url")?
        .to_string();

    let artists_array = item["artists"].as_array().ok_or("missing artists array")?;
    let mut artists = Vec::new();
    for artist in artists_array {
        if let Some(name) = artist["name"].as_str() {
            artists.push(name.to_string());
        }
    }

    let song_data = SongData {
        title,
        artists,
        album,
        song_url,
    };

    Ok((song_data, is_playing))
}
