mod common;
use common::create_dummy_state;

use api_lumine::*;

use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use serde_json::Value;
use tower::ServiceExt;

#[tokio::test]
async fn status_check() -> Result<(), String> {
    let state =
        create_dummy_state("http://dummy-api.internal", "http://dummy-account.internal").await;
    let app = create_app(state);

    let request = Request::builder()
        .uri("/health")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::OK);

    let body = response
        .collect()
        .await
        .map_err(|e| format!("The response body couldn't be collected: {}", e))?;

    let json: Value = serde_json::from_slice(&body.to_bytes())
        .map_err(|e| format!("Failed to parse response body: {}", e))?;

    assert_eq!(json["status"], "ok");

    Ok(())
}
