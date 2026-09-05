use api_lumine::*;
use sqlx::migrate;
use sqlx::sqlite::SqlitePoolOptions;

use std::env;
use std::sync::Arc;
use tokio::sync::RwLock;

#[tokio::main]
async fn main() {
    let port = env::var("PORT").expect("CRITICAL: PORT environment variable is missing");
    let addr = format!("0.0.0.0:{}", port);

    let client_id = env::var("SPOTIFY_CLIENT_ID")
        .expect("CRITICAL: SPOTIFY_CLIENT_ID environment variable is missing");
    let client_secret = env::var("SPOTIFY_CLIENT_SECRET")
        .expect("CRITICAL: SPOTIFY_CLIENT_SECRET environment variable is missing");
    let refresh_token = env::var("SPOTIFY_REFRESH_TOKEN")
        .expect("CRITICAL: SPOTIFY_REFRESH_TOKEN environment variable is missing");

    let db_url =
        env::var("NOTES_DB_URL").expect("CRITICAL: NOTES_DB_URL environment variable is missing");
    let api_key =
        env::var("NOTES_API_KEY").expect("CRITICAL: NOTES_API_KEY environment variable is missing");

    let db_pool = SqlitePoolOptions::new()
        .connect(&db_url)
        .await
        .expect("CRITICAL: Failed to connect to SQLite database");
    migrate!()
        .run(&db_pool)
        .await
        .expect("CRITICAL: Failed to run database migrations");

    let state = AppState {
        http_client: reqwest::Client::new(),
        spotify: SpotifyConfig {
            api_url: "https://api.spotify.com".to_string(),
            account_url: "https://accounts.spotify.com".to_string(),
            client_id,
            client_secret,
            refresh_token,
            token_cache: Arc::new(RwLock::new(None)),
            song_cache: Arc::new(RwLock::new(None)),
        },
        notes: NotesConfig { db_pool, api_key },
    };

    let app = create_app(state);

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .unwrap_or_else(|_| panic!("CRITICAL: failed to bind to port {}", port));

    axum::serve(listener, app).await.unwrap();
}
