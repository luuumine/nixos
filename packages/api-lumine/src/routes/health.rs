use axum::Json;
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
        (status = StatusCode::OK, description = "api is healthy", body = HealthResponse),
    ),
)]
pub async fn health() -> Json<HealthResponse> {
    Json(HealthResponse::default())
}
