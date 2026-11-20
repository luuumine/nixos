use crate::{
    ApiError, AppState,
    routes::music::{
        TopParams,
        models::Track,
        spotify::{token::get_token, top::fetch_top_tracks},
    },
};

use axum::{
    Json,
    extract::{Query, State},
};

#[utoipa::path(
    get,
    path = "/tracks",
    tag = "music",
    params(TopParams),
    responses(
        (status = StatusCode::OK, description = "List of top tracks", body = Vec<Track>),
        ApiError,
    ),
)]
pub async fn get_top_tracks(
    State(state): State<AppState>,
    Query(params): Query<TopParams>,
) -> Result<Json<Vec<Track>>, ApiError> {
    let access_token = get_token(&state).await?;
    let top_artists = fetch_top_tracks(&state, &access_token, &params.range).await?;

    Ok(Json(top_artists))
}
