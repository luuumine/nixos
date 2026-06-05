use crate::{
    AppState,
    routes::music::currently_playing::{NowPlayingResponse, SongData},
};
use reqwest::StatusCode;

pub async fn fetch_currently_playing(
    state: &AppState,
    access_token: &str,
) -> Result<NowPlayingResponse, String> {
    let url = format!("{}/v1/me/player/currently-playing", state.spotify.api_url);

    let response = state
        .http_client
        .get(url)
        .bearer_auth(access_token)
        .send()
        .await
        .map_err(|e| format!("failed to fetch response: {}", e))?;

    match response.status() {
        StatusCode::NO_CONTENT => return Ok(NowPlayingResponse::NotPlaying),
        StatusCode::OK => {
            let json = response
                .json::<serde_json::Value>()
                .await
                .map_err(|e| format!("failed to parse response body: {}", e))?;
            let (song_data, b) = parse_spotify_response(json)?;
            return Ok(match b {
                true => NowPlayingResponse::Playing(song_data),
                false => NowPlayingResponse::Paused(song_data),
            });
        }
        _ => {
            return Err(format!(
                "spotify api returned unexpected status: {}",
                response.status()
            ));
        }
    }
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
