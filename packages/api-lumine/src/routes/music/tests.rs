use crate::{
    AppState, NotesConfig, SpotifyConfig,
    routes::music::{currently_playing::NowPlayingResponse, spotify::fetch_currently_playing},
};
use serde_json::{Value, json};
use sqlx::{migrate, sqlite::SqlitePoolOptions};
use std::sync::Arc;
use tokio::sync::RwLock;
use wiremock::{
    Mock, MockServer, ResponseTemplate,
    matchers::{header, method, path},
};

async fn create_dummy_state(api_url: String) -> AppState {
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
            api_url,
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
    }
}

#[tokio::test]
async fn fetch_song_while_playing() -> Result<(), String> {
    let mock_server = MockServer::start().await;

    let raw_json = include_str!("./fixtures/spotify_playing.json");
    let spotify_mock_body: Value = serde_json::from_str(raw_json)
        .map_err(|e| format!("failed to parse the spotify fixture json: {}", e))?;

    Mock::given(method("GET"))
        .and(path("/v1/me/player/currently-playing"))
        .and(header("Authorization", "Bearer fake_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(spotify_mock_body))
        .mount(&mock_server)
        .await;

    let state = create_dummy_state(mock_server.uri()).await;

    let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

    if let NowPlayingResponse::Playing(song) = now_playing_response {
        assert_eq!(song.title, "belavenir");
        assert_eq!(song.artists, vec!["Jima", "ysma"]);
        assert_eq!(song.album, "RAPPEL");
        assert_eq!(
            song.song_url,
            "https://open.spotify.com/track/7KdLgNe9VGs7v9F39M8wl9"
        )
    } else {
        return Err("expected Playing".to_string());
    };

    Ok(())
}

#[tokio::test]
async fn fetch_song_while_paused() -> Result<(), String> {
    let mock_server = MockServer::start().await;

    let raw_json = include_str!("./fixtures/spotify_playing.json");
    let mut spotify_mock_body: Value = serde_json::from_str(raw_json)
        .map_err(|e| format!("failed to parse the spotify fixture json: {}", e))?;

    if let Some(is_playing) = spotify_mock_body.get_mut("is_playing") {
        *is_playing = json!(false);
    }

    Mock::given(method("GET"))
        .and(path("/v1/me/player/currently-playing"))
        .and(header("Authorization", "Bearer fake_token"))
        .respond_with(ResponseTemplate::new(200).set_body_json(spotify_mock_body))
        .mount(&mock_server)
        .await;

    let state = create_dummy_state(mock_server.uri()).await;

    let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

    if let NowPlayingResponse::Paused(song) = now_playing_response {
        assert_eq!(song.title, "belavenir");
        assert_eq!(song.artists, vec!["Jima", "ysma"]);
        assert_eq!(song.album, "RAPPEL");
        assert_eq!(
            song.song_url,
            "https://open.spotify.com/track/7KdLgNe9VGs7v9F39M8wl9"
        )
    } else {
        return Err("expected NotPlaying".to_string());
    };

    Ok(())
}

#[tokio::test]
async fn fetch_song_while_not_playing() -> Result<(), String> {
    let mock_server = MockServer::start().await;

    Mock::given(method("GET"))
        .and(path("/v1/me/player/currently-playing"))
        .and(header("Authorization", "Bearer fake_token"))
        .respond_with(ResponseTemplate::new(204))
        .mount(&mock_server)
        .await;

    let state = create_dummy_state(mock_server.uri()).await;

    let now_playing_response = fetch_currently_playing(&state, "fake_token").await?;

    assert!(
        matches!(now_playing_response, NowPlayingResponse::NotPlaying),
        "expected NotPlaying, but got Playing"
    );

    Ok(())
}
