use axum::{
    Json, Router,
    http::{Method, StatusCode},
    response::IntoResponse,
};
use reqwest::Client;
use serde::Serialize;
use sqlx::SqlitePool;
use std::{collections::HashMap, sync::Arc};
use tokio::sync::RwLock;
use tower_http::cors::{Any, CorsLayer};
use utoipa::{IntoResponses, ToSchema};

use crate::routes::music::models::*;

pub mod routes;

#[cfg(test)]
pub mod test_utils;

pub struct Cache<T> {
    pub data: T,
    pub expires_at: u64,
}

pub type TokenCache = Arc<RwLock<Option<Cache<String>>>>;
pub type PlayingCache = Arc<RwLock<Option<Cache<routes::music::NowPlayingResponse>>>>;

// top
pub type ArtistsCache = Arc<RwLock<HashMap<TimeRange, Cache<Vec<Artist>>>>>;
pub type TracksCache = Arc<RwLock<HashMap<TimeRange, Cache<Vec<Track>>>>>;

#[derive(Clone, Default)]
pub struct TopCache {
    pub artists: ArtistsCache,
    pub tracks: TracksCache,
}

#[derive(Clone, Default)]
pub struct SpotifyCache {
    pub token: TokenCache,
    pub playing: PlayingCache,
    pub top: TopCache,
}

#[derive(Clone)]
pub struct SpotifyConfig {
    pub api_url: String,
    pub account_url: String,
    pub client_id: String,
    pub client_secret: String,
    pub refresh_token: String,
    pub cache: SpotifyCache,
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

#[derive(Debug, Serialize, ToSchema)]
pub struct ErrorResponse {
    pub error: ErrorDetail,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct ErrorDetail {
    #[schema(example = "INTERNAL_SERVER_ERROR")]
    pub code: String,
    #[schema(example = "An unexpected error occurred.")]
    pub message: String,
}

#[derive(Debug, IntoResponses)]
pub enum ApiError {
    #[response(status = StatusCode::BAD_REQUEST, description = "The request was invalid or malformed.")]
    BadRequest,

    #[response(status = StatusCode::UNAUTHORIZED, description = "Missing or invalid authorization token.")]
    Unauthorized,

    #[response(
        status = StatusCode::NOT_FOUND,
        description = "The requested endpoint or resource does not exist."
    )]
    NotFound,

    #[response(status = StatusCode::INTERNAL_SERVER_ERROR, description = "An internal server error occurred.")]
    InternalServerError,

    #[response(
        status = StatusCode::SERVICE_UNAVAILABLE,
        description = "The requested service is temporarily unavailable."
    )]
    ServiceUnavailable,
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        let (status, error_code, error_message) = match self {
            ApiError::BadRequest => (
                StatusCode::BAD_REQUEST,
                "BAD_REQUEST".to_string(),
                "The request is invalid or contains malformed data.".to_string(),
            ),
            ApiError::Unauthorized => (
                StatusCode::UNAUTHORIZED,
                "UNAUTHORIZED".to_string(),
                "Missing or invalid Bearer token.".to_string(),
            ),
            ApiError::NotFound => (
                StatusCode::NOT_FOUND,
                "NOT_FOUND".to_string(),
                "The requested endpoint does not exist.".to_string(),
            ),
            ApiError::InternalServerError => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR".to_string(),
                "An unexpected internal server error occurred.".to_string(),
            ),
            ApiError::ServiceUnavailable => (
                StatusCode::SERVICE_UNAVAILABLE,
                "SERVICE_UNAVAILABLE".to_string(),
                "The requested service is not available. Try again later.".to_string(),
            ),
        };

        let body = Json(ErrorResponse {
            error: ErrorDetail {
                code: error_code,
                message: error_message,
            },
        });

        (status, body).into_response()
    }
}

impl From<String> for ApiError {
    fn from(err: String) -> Self {
        eprintln!("INTERNAL ERROR: {}", err);
        ApiError::InternalServerError
    }
}

impl From<sqlx::Error> for ApiError {
    fn from(err: sqlx::Error) -> Self {
        eprintln!("DB ERROR: {}", err);
        ApiError::InternalServerError
    }
}
