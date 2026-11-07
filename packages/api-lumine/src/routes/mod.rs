use crate::AppState;
use axum::Router;
use utoipa::{
    Modify, OpenApi,
    openapi::security::{HttpAuthScheme, HttpBuilder, SecurityScheme},
};
use utoipa_axum::{router::OpenApiRouter, routes};
use utoipa_swagger_ui::SwaggerUi;

pub mod health;
pub mod music;
pub mod not_found;
pub mod notes;

#[derive(OpenApi)]
#[openapi(
    info(title = "api-lumine"),
    modifiers(&SecurityAddon)
)]
struct ApiDoc;

struct SecurityAddon;
impl Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        if let Some(components) = openapi.components.as_mut() {
            components.add_security_scheme(
                "NOTES_API_KEY",
                SecurityScheme::Http(HttpBuilder::new().scheme(HttpAuthScheme::Bearer).build()),
            );
        }
    }
}

pub fn router() -> Router<AppState> {
    let mut openapi = ApiDoc::openapi();
    openapi.info.version = env!("API_VERSION").to_string();

    let (router, api) = OpenApiRouter::with_openapi(openapi)
        .routes(routes!(health::handler))
        .nest("/notes", notes::openapi_router())
        // .nest("/music", music::openapi_router())
        .split_for_parts();

    router
        .merge(SwaggerUi::new("/").url("/openapi.json", api))
        .fallback(not_found::handler)
}
