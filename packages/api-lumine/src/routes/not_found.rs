use crate::ApiError;

use axum::{extract::OriginalUri, http::Method};

pub async fn handler(method: Method, uri: OriginalUri) -> ApiError {
    println!("{} {} -> 404", method, uri.path());
    ApiError::NotFound
}
