use crate::{
    ApiError, AppState,
    routes::music::{
        NowPlayingResponse,
        spotify::{player::fetch_currently_playing, token::get_token},
    },
};

use axum::{Json, extract::State};

#[utoipa::path(
    get,
    path = "/currently_playing",
    tag = "music",
    responses(
        (status = StatusCode::OK, description = "Current playback state", body = NowPlayingResponse),
        ApiError,
    ),
)]
pub async fn get_currently_playing(
    State(state): State<AppState>,
) -> Result<Json<NowPlayingResponse>, ApiError> {
    let access_token = get_token(&state).await?;
    let currently_playing = fetch_currently_playing(&state, &access_token).await?;

    Ok(Json(currently_playing))
}
