use crate::AppState;
use axum::{Router, routing::get};

mod currently_playing;
mod spotify;
mod token;

#[cfg(test)]
mod tests;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(currently_playing::handler))
        .route("/currently_playing", get(currently_playing::handler))
}
