use axum::{Json, response::IntoResponse};
use serde::Serialize;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema)]
pub struct HealthResponse {
    #[schema(example = "ok")]
    pub status: String,
}
impl Default for HealthResponse {
    fn default() -> Self {
        HealthResponse {
            status: "ok".to_string(),
        }
    }
}

#[utoipa::path(
    get,
    path = "/health",
    responses(
        (status = 200, description = "api is healthy", body = HealthResponse)
    )
)]
pub async fn handler() -> impl IntoResponse {
    Json(HealthResponse::default())
}
