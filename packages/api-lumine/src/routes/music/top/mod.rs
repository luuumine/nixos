use crate::AppState;
use utoipa_axum::{router::OpenApiRouter, routes};

mod artists;
mod tracks;

pub fn openapi_router() -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(artists::get_top_artists))
        .routes(routes!(tracks::get_top_tracks))
}
