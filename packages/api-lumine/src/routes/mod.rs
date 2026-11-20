use crate::AppState;

use axum::{Router, response::Redirect, routing::get};
use utoipa::{
    Modify, OpenApi,
    openapi::security::{HttpAuthScheme, HttpBuilder, SecurityScheme},
};
use utoipa_axum::{router::OpenApiRouter, routes};
use utoipa_swagger_ui::{Config, SwaggerUi};

pub mod health;
pub mod music;
pub mod not_found;
pub mod notes;

#[derive(OpenApi)]
#[openapi(
    info(
        title = "api-lumine",
        version = env!("API_VERSION").to_string(),
        contact(
            name = "lumine",
            email = "hello@luuumine.com",
            url = "https://luuumine.com",
        ),
    ),
    modifiers(&SecurityAddon),
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
    let openapi = ApiDoc::openapi();

    let (router, api) = OpenApiRouter::with_openapi(openapi)
        .routes(routes!(health::health))
        .nest("/notes", notes::openapi_router())
        .nest("/music", music::openapi_router())
        .split_for_parts();

    router
        .route("/", get(|| async { Redirect::permanent("/docs") }))
        .merge(
            SwaggerUi::new("/docs")
                .url("/docs/openapi.json", api)
                .config(
                    Config::default()
                        .display_operation_id(true)
                        .display_request_duration(true)
                        .try_it_out_enabled(true)
                        .validator_url("none"),
                ),
        )
        .fallback(not_found::handler)
}
