use crate::AppState;
use axum::{Router, routing::get};

pub mod health;
pub mod music;
pub mod not_found;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/health", get(health::handler))
        .nest("/music", music::router())
        .fallback(not_found::handler)
}
