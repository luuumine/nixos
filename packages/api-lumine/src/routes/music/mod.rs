use crate::AppState;
use axum::{Router, routing::get};

mod currently_playing;
mod top;

pub mod models;
pub mod spotify;

pub use models::{NowPlayingResponse, TopParams};

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(currently_playing::handler))
        .route("/currently_playing", get(currently_playing::handler))
        .nest("/top", top::router())
}
