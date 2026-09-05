use axum::{
    Json, Router,
    http::{Method, StatusCode},
    response::IntoResponse,
};
use reqwest::Client;
use serde_json::json;
use sqlx::SqlitePool;
use std::sync::Arc;
use tokio::sync::RwLock;
use tower_http::cors::{Any, CorsLayer};

pub mod routes;

pub struct TokenCache {
    pub access_token: String,
    pub expires_at: u64,
}
pub struct SongCache {
    pub data: routes::music::NowPlayingResponse,
    pub expires_at: u64,
}

#[derive(Clone)]
pub struct SpotifyConfig {
    pub api_url: String,
    pub account_url: String,
    pub client_id: String,
    pub client_secret: String,
    pub refresh_token: String,
    pub token_cache: Arc<RwLock<Option<TokenCache>>>,
    pub song_cache: Arc<RwLock<Option<SongCache>>>,
}

#[derive(Clone)]
pub struct NotesConfig {
    pub db_pool: SqlitePool,
    pub api_key: String,
}

#[derive(Clone)]
pub struct AppState {
    pub http_client: Client,
    pub spotify: SpotifyConfig,
    pub notes: NotesConfig,
}

pub fn create_app(state: AppState) -> Router {
    let cors = CorsLayer::new()
        .allow_methods([Method::GET])
        .allow_origin(Any);

    routes::router().with_state(state).layer(cors)
}

#[derive(Debug)]
pub enum ApiError {
    BadRequest,          // 400
    NotFound,            // 404
    ServiceUnavailable,  // 503
    InternalServerError, // 500
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        if !matches!(self, ApiError::NotFound) {
            eprintln!("API ERROR: {:?}", self);
        }

        let (status, error_code, error_message) = match self {
            ApiError::BadRequest => (
                StatusCode::BAD_REQUEST,
                "BAD_REQUEST",
                "The request was invalid or malformed.",
            ),
            ApiError::NotFound => (
                StatusCode::NOT_FOUND,
                "NOT_FOUND",
                "The requested endpoint does not exist.",
            ),
            ApiError::ServiceUnavailable => (
                StatusCode::SERVICE_UNAVAILABLE,
                "SERVICE_UNAVAILABLE",
                "The requested service is not available. Try again later.",
            ),
            ApiError::InternalServerError => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR",
                "An internal server error occured. Try again later.",
            ),
        };

        let body = Json(json!({
            "error": {
                "code": error_code,
                "message": error_message
            }
        }));

        (status, body).into_response()
    }
}
