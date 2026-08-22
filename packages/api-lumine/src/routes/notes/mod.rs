use crate::AppState;
use axum::{
    Router,
    routing::{delete, get, post},
};

mod auth;
pub mod handlers;
pub mod models;

pub use models::Note;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(handlers::get_notes))
        .route("/", post(handlers::post_note))
        .route("/{id}", get(handlers::get_note))
        .route("/{id}", delete(handlers::delete_note))
}
