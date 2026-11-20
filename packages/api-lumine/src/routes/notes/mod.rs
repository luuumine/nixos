use crate::AppState;

mod auth;
pub mod handlers;
pub mod models;

pub use models::Note;
use utoipa_axum::{router::OpenApiRouter, routes};

pub fn openapi_router() -> OpenApiRouter<AppState> {
    OpenApiRouter::new()
        .routes(routes!(handlers::get_notes, handlers::post_note))
        .routes(routes!(handlers::get_note, handlers::delete_note))
}
