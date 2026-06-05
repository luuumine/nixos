use api_lumine::*;

use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use serde_json::{Value, json};
use std::sync::Arc;
use tokio::sync::RwLock;
use tower::ServiceExt;
use wiremock::{
    Mock, MockServer, ResponseTemplate,
    matchers::{header, method, path},
};

#[tokio::test]
async fn currently_playing() -> Result<(), String> {
    let mock_server = MockServer::start().await;

    // the token request
    let auth_response = json!({
        "access_token":"integration_mock_token",
        "token_type":"Bearer",
        "expires_in": 3600
    });

    Mock::given(method("POST"))
        .and(path("/api/token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(auth_response))
        .mount(&mock_server)
        .await;

    // the player request
    let raw_json = include_str!("../src/routes/music/fixtures/spotify_playing.json");
    let spotify_mock_body: Value = serde_json::from_str(raw_json)
        .map_err(|e| format!("failed to parse the spotify fixture json: {}", e))?;

    Mock::given(method("GET"))
        .and(path("/v1/me/player/currently-playing"))
        .and(header("Authorization", "Bearer integration_mock_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(spotify_mock_body))
        .mount(&mock_server)
        .await;

    // start app
    let state = AppState {
        http_client: reqwest::Client::new(),
        spotify: SpotifyConfig {
            api_url: mock_server.uri(),
            account_url: mock_server.uri(),
            client_id: "dummy_id".to_string(),
            client_secret: "dummy_secret".to_string(),
            refresh_token: "dummy_refresh".to_string(),
            token_cache: Arc::new(RwLock::new(None)),
        },
    };

    let app = create_app(state);

    let request = Request::builder()
        .uri("/music/currently_playing")
        .body(Body::empty())
        .map_err(|e| format!("failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::OK);

    let body = response
        .collect()
        .await
        .map_err(|e| format!("Failed to collect body: {}", e))?
        .to_bytes();

    let json: Value = serde_json::from_slice(&body)
        .map_err(|e| format!("Failed to parse JSON response: {}", e))?;

    assert_eq!(json["status"], "playing");
    assert_eq!(json["title"], "belavenir");
    assert_eq!(json["album"], "RAPPEL");
    assert_eq!(json["artists"], json!(["Jima", "ysma"]));

    Ok(())
}
