use api_lumine::*;

use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use serde_json::Value;
use sqlx::{migrate, sqlite::SqlitePoolOptions};
use std::sync::Arc;
use tokio::sync::RwLock;
use tower::ServiceExt;

#[tokio::test]
async fn unknown_route() -> Result<(), String> {
    let db_pool = SqlitePoolOptions::new()
        .connect("sqlite::memory:")
        .await
        .expect("Failed to create in-memory db for tests");
    migrate!()
        .run(&db_pool)
        .await
        .expect("Failed to migrate test db");

    let state = AppState {
        http_client: reqwest::Client::new(),
        spotify: SpotifyConfig {
            api_url: "http://dummy-api.internal".to_string(),
            account_url: "http://dummy-account.internal".to_string(),
            client_id: "dummy_id".to_string(),
            client_secret: "dummy_secret".to_string(),
            refresh_token: "dummy_refresh".to_string(),
            token_cache: Arc::new(RwLock::new(None)),
            song_cache: Arc::new(RwLock::new(None)),
        },
        notes: NotesConfig {
            db_pool,
            api_key: "dummy_api_key".to_string(),
        },
    };

    let app = create_app(state);

    let request = Request::builder()
        .uri("/does-not-exist")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::NOT_FOUND);

    let body = response
        .collect()
        .await
        .map_err(|e| format!("The response body couldn't be collected: {}", e))?;

    let json: Value = serde_json::from_slice(&body.to_bytes())
        .map_err(|e| format!("Failed to parse response body: {}", e))?;

    assert_eq!(json["error"]["code"], "NOT_FOUND");
    assert_eq!(
        json["error"]["message"],
        "The requested endpoint does not exist."
    );

    Ok(())
}
