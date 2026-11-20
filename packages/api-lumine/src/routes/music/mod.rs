use crate::AppState;
use utoipa_axum::{router::OpenApiRouter, routes};

mod currently_playing;
mod top;

pub mod models;
pub mod spotify;

pub use models::{NowPlayingResponse, TopParams};

pub fn openapi_router() -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(currently_playing::get_currently_playing))
        .nest("/top", top::openapi_router())
}
