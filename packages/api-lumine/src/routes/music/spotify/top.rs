use std::time::{SystemTime, UNIX_EPOCH};

use reqwest::StatusCode;

use crate::{AppState, Cache, routes::music::models::*};

const LIMIT: usize = 5;
const TOP_LIFETIME: u64 = 86400;
const ERROR_TIMEOUT: u64 = 1800;

pub async fn fetch_top_artists(
    state: &AppState,
    access_token: &str,
    range: &TimeRange,
) -> Result<TopArtistsResponse, String> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| format!("time shouldnt be negative: {}", e))?
        .as_secs();

    let buffer = 1;

    {
        // get read lock
        let cache = state.spotify.cache.top.artists.read().await;
        if let Some(artists_data) = cache.get(range) {
            if now + buffer < artists_data.expires_at {
                return Ok(artists_data.data.clone());
            }
        }
    } // `cache` goes out of scope there

    // get write lock. pauses other threads
    let mut cache = state.spotify.cache.top.artists.write().await;

    // check if another thread wrote new valid data before updating it
    if let Some(artists_data) = cache.get(range) {
        if now < artists_data.expires_at {
            return Ok(artists_data.data.clone());
        }
    }

    let url = format!("{}/v1/me/top/artists", state.spotify.api_url);

    let params = [
        ("time_range", range.as_spotify_param()),
        ("limit", &LIMIT.to_string()),
    ];

    let response = state
        .http_client
        .get(url)
        .bearer_auth(access_token)
        .query(&params)
        .send()
        .await
        .map_err(|e| format!("failed to send top request: {}", e))?;

    let status = response.status();

    match status {
        StatusCode::OK => {
            let json = response
                .json()
                .await
                .map_err(|e| format!("failed to parse response body: {}", e))?;

            let response_data = parse_artists_response(json)?;

            cache.insert(
                range.clone(),
                Cache {
                    data: response_data.clone(),
                    expires_at: now + TOP_LIFETIME,
                },
            );

            Ok(response_data)
        }
        _ => {
            eprint!("spotify api returned unexpected status: {}", status);

            // else, we just update the TTL and keep stale data
            if let Some(stale_entry) = cache.get_mut(range) {
                stale_entry.expires_at = now + ERROR_TIMEOUT;
                return Ok(stale_entry.data.clone());
            }

            // if no stale information exists, we return the error
            Err(format!(
                "spotify api returned unexpected status: {}",
                status
            ))
        }
    }
}

pub async fn fetch_top_tracks(
    state: &AppState,
    access_token: &str,
    range: &TimeRange,
) -> Result<TopTracksResponse, String> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| format!("time shouldnt be negative: {}", e))?
        .as_secs();

    let buffer = 1;

    {
        // get read lock
        let cache = state.spotify.cache.top.tracks.read().await;
        if let Some(tracks_data) = cache.get(range) {
            if now + buffer < tracks_data.expires_at {
                return Ok(tracks_data.data.clone());
            }
        }
    } // `cache` goes out of scope there

    // get write lock. pauses other threads
    let mut cache = state.spotify.cache.top.tracks.write().await;

    // check if another thread wrote new valid data before updating it
    if let Some(tracks_data) = cache.get(range) {
        if now < tracks_data.expires_at {
            return Ok(tracks_data.data.clone());
        }
    }

    let url = format!("{}/v1/me/top/tracks", state.spotify.api_url);

    let params = [
        ("time_range", range.as_spotify_param()),
        ("limit", &LIMIT.to_string()),
    ];

    let response = state
        .http_client
        .get(url)
        .bearer_auth(access_token)
        .query(&params)
        .send()
        .await
        .map_err(|e| format!("failed to send top request: {}", e))?;

    let status = response.status();

    match status {
        StatusCode::OK => {
            let json = response
                .json()
                .await
                .map_err(|e| format!("failed to parse response body: {}", e))?;

            let response_data = parse_tracks_response(json)?;

            cache.insert(
                range.clone(),
                Cache {
                    data: response_data.clone(),
                    expires_at: now + TOP_LIFETIME,
                },
            );

            Ok(response_data)
        }
        _ => {
            eprint!("spotify api returned unexpected status: {}", status);

            // else, we just update the TTL and keep stale data
            if let Some(stale_entry) = cache.get_mut(range) {
                stale_entry.expires_at = now + ERROR_TIMEOUT;
                return Ok(stale_entry.data.clone());
            }

            // if no stale information exists, we return the error
            Err(format!(
                "spotify api returned unexpected status: {}",
                status
            ))
        }
    }
}

fn parse_artists_response(json: serde_json::Value) -> Result<TopArtistsResponse, String> {
    let artists_array = json["items"].as_array().ok_or("missing artists array")?;

    let l = artists_array.len();
    if l != LIMIT {
        return Err(format!("expected {LIMIT} artists, but found {l}"));
    }

    let mut artists = Vec::new();
    for artist in artists_array {
        if let (Some(name), Some(artist_url), Some(images_array)) = (
            artist["name"].as_str(),
            artist["external_urls"]["spotify"].as_str(),
            artist["images"].as_array(),
        ) && images_array.len() == 3
        {
            artists.push(Artist {
                name: name.to_string(),
                url: artist_url.to_string(),
                images: Some(Image {
                    large: images_array[0]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                    medium: images_array[1]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                    small: images_array[2]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                }),
            });
        }
    }

    Ok(artists)
}

fn parse_tracks_response(json: serde_json::Value) -> Result<TopTracksResponse, String> {
    let tracks_array = json["items"].as_array().ok_or("missing tracks array")?;

    let l = tracks_array.len();
    if l != LIMIT {
        return Err(format!("expected {LIMIT} tracks but found {l}"));
    }

    let mut tracks = Vec::new();
    for track in tracks_array {
        if let (
            Some(name),
            Some(album),
            Some(track_number),
            Some(url),
            Some(images_array),
            Some(artists_array),
        ) = (
            track["name"].as_str(),
            track["album"]["name"].as_str(),
            track["track_number"].as_u64(),
            track["external_urls"]["spotify"].as_str(),
            track["album"]["images"].as_array(),
            track["artists"].as_array(),
        ) && images_array.len() == 3
        {
            tracks.push(Track {
                title: name.to_string(),
                album: album.to_string(),
                track_number: track_number,
                url: url.to_string(),
                images: Image {
                    large: images_array[0]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                    medium: images_array[1]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                    small: images_array[2]["url"]
                        .as_str()
                        .unwrap_or_default()
                        .to_string(),
                },
                artists: artists_array
                    .iter()
                    .filter_map(|artist| {
                        if let (Some(name), Some(url)) = (
                            artist["name"].as_str(),
                            artist["external_urls"]["spotify"].as_str(),
                        ) {
                            Some(Artist {
                                name: name.to_string(),
                                url: url.to_string(),
                                images: None,
                            })
                        } else {
                            None
                        }
                    })
                    .collect(),
            })
        }
    }

    Ok(tracks)
}
