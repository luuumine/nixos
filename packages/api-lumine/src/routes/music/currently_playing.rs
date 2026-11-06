use axum::{Json, extract::State, response::IntoResponse};

use crate::{
    ApiError, AppState,
    routes::music::spotify::{player::fetch_currently_playing, token::get_token},
};

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

    Ok(Json(currently_playing))
}
