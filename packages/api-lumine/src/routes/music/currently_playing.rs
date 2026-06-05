use axum::{Json, extract::State, response::IntoResponse};
use serde::Serialize;
use serde_json::json;

use crate::{
    ApiError, AppState,
    routes::music::{spotify::fetch_currently_playing, token::get_token},
};

#[derive(Serialize, Debug, PartialEq)]
pub struct SongData {
    pub title: String,
    pub artists: Vec<String>,
    pub album: String,
    pub song_url: String,
}
pub enum NowPlayingResponse {
    NotPlaying,        // 204
    Paused(SongData),  // 200, is_playing: false
    Playing(SongData), // 200, is_playing: true
}

pub async fn handler(State(state): State<AppState>) -> Result<impl IntoResponse, ApiError> {
    let access_token = get_token(&state).await.map_err(|e| {
        println!("INTERNAL ERROR [get_token]: {}", e);
        ApiError::InternalServerError
    })?;

    let currently_playing = fetch_currently_playing(&state, &access_token)
        .await
        .map_err(|e| {
            println!("INTERNAL ERROR [fetch_currently_playing]: {}", e);
            ApiError::InternalServerError
        })?;

    let body = match currently_playing {
        NowPlayingResponse::NotPlaying => json!({
            "status":"not_playing"
        }),
        NowPlayingResponse::Paused(song) => json!({
            "status":"paused",
            "title": song.title,
            "artists": song.artists,
            "album": song.album,
            "song_url": song.song_url,
        }),
        NowPlayingResponse::Playing(song) => json!({
            "status":"playing",
            "title": song.title,
            "artists": song.artists,
            "album": song.album,
            "song_url": song.song_url,
        }),
    };

    Ok(Json(body))
}
