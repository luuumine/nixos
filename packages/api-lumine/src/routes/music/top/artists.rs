use crate::{
    ApiError, AppState,
    routes::music::{
        TopParams,
        models::Artist,
        spotify::{token::get_token, top::fetch_top_artists},
    },
};

use axum::{
    Json,
    extract::{Query, State},
};

#[utoipa::path(
    get,
    path = "/artists",
    tag = "music",
    params(TopParams),
    responses(
        (status = StatusCode::OK, description = "List of top artists", body = Vec<Artist>),
        ApiError,
    ),
)]
pub async fn get_top_artists(
    State(state): State<AppState>,
    Query(params): Query<TopParams>,
) -> Result<Json<Vec<Artist>>, ApiError> {
    let access_token = get_token(&state).await?;
    let top_artists = fetch_top_artists(&state, &access_token, &params.range).await?;

    Ok(Json(top_artists))
}
