use crate::AppState;
use axum::Router;
use utoipa_axum::{router::OpenApiRouter, routes};
use utoipa_swagger_ui::SwaggerUi;

pub mod health;
pub mod music;
pub mod not_found;
pub mod notes;

pub fn router() -> Router<AppState> {
    let (router, api) = OpenApiRouter::new()
        .routes(routes!(health::handler))
        .nest("/notes", notes::openapi_router())
        // .nest("/music", music::openapi_router())
        .split_for_parts();

    router
        .merge(SwaggerUi::new("/").url("/openapi.json", api))
        .fallback(not_found::handler)
}
