use crate::{AppState, NotesConfig, SpotifyCache, SpotifyConfig};

use serde_json::{Value, json};
use sqlx::{migrate, sqlite::SqlitePoolOptions};
use wiremock::{
    Mock, MockServer, ResponseTemplate,
    matchers::{header, method, path},
};

pub async fn create_dummy_state(api_url: &str, account_url: &str) -> AppState {
    let db_pool = SqlitePoolOptions::new()
        .connect("sqlite::memory:")
        .await
        .expect("Failed to create in-memory db for tests");
    migrate!()
        .run(&db_pool)
        .await
        .expect("Failed to migrate test db");

    AppState {
        http_client: reqwest::Client::new(),
        spotify: SpotifyConfig {
            api_url: api_url.to_string(),
            account_url: account_url.to_string(),
            client_id: "valid_client_id".to_string(),
            client_secret: "valid_client_secret".to_string(),
            refresh_token: "valid_refresh_token".to_string(),
            cache: SpotifyCache::default(),
        },
        notes: NotesConfig {
            db_pool,
            api_key: "valid_api_key".to_string(),
        },
    }
}

#[allow(dead_code)]
pub async fn spotify_mock_server() -> Result<MockServer, String> {
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

    // currently_playing
    let playing_json = include_str!("../../src/routes/music/fixtures/spotify_playing.json");
    let playing_body: Value = serde_json::from_str(playing_json)
        .map_err(|e| format!("failed to parse playing fixture: {}", e))?;

    Mock::given(method("GET"))
        .and(path("/v1/me/player/currently-playing"))
        .and(header("Authorization", "Bearer integration_mock_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(playing_body))
        .mount(&mock_server)
        .await;

    // top_artists
    let artists_json = include_str!("../../src/routes/music/fixtures/spotify_top_artists.json");
    let artists_body: Value = serde_json::from_str(artists_json)
        .map_err(|e| format!("failed to parse artists fixture: {}", e))?;

    Mock::given(method("GET"))
        .and(path("/v1/me/top/artists"))
        .and(header("Authorization", "Bearer integration_mock_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(artists_body))
        .mount(&mock_server)
        .await;

    // top_artists
    let tracks_json = include_str!("../../src/routes/music/fixtures/spotify_top_tracks.json");
    let tracks_body: Value = serde_json::from_str(tracks_json)
        .map_err(|e| format!("failed to parse track fixture: {}", e))?;

    Mock::given(method("GET"))
        .and(path("/v1/me/top/tracks"))
        .and(header("Authorization", "Bearer integration_mock_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(tracks_body))
        .mount(&mock_server)
        .await;

    Ok(mock_server)
}
