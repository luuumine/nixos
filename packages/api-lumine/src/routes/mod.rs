use crate::AppState;
use axum::{Router, routing::get};

pub mod health;
pub mod music;
pub mod not_found;
pub mod notes;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/health", get(health::handler))
        .nest("/music", music::router())
        .nest("/notes", notes::router())
        .fallback(not_found::handler)
}
