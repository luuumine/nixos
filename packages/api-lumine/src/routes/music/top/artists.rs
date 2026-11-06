use axum::{
    Json,
    extract::{Query, State},
    response::IntoResponse,
};

use crate::{
    ApiError, AppState,
    routes::music::{
        TopParams,
        spotify::{token::get_token, top::fetch_top_artists},
    },
};

pub async fn handler(
    State(state): State<AppState>,
    Query(params): Query<TopParams>,
) -> Result<impl IntoResponse, ApiError> {
    let access_token = get_token(&state).await.map_err(|e| {
        println!("INTERNAL ERROR [get_token]: {}", e);
        ApiError::InternalServerError
    })?;

    let range = params.range;

    let top_artists = fetch_top_artists(&state, &access_token, &range)
        .await
        .map_err(|e| {
            println!("INTERNAL ERROR [fetch_top_artists]: {}", e);
            ApiError::InternalServerError
        })?;

    Ok(Json(top_artists))
}
