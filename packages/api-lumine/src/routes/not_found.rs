use crate::ApiError;

use axum::{extract::OriginalUri, http::Method, response::IntoResponse};

pub async fn handler(method: Method, uri: OriginalUri) -> impl IntoResponse {
    println!("{} {} -> 404", method, uri.path());
    ApiError::NotFound
}
