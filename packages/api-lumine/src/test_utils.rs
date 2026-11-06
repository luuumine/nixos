use crate::{AppState, NotesConfig, SpotifyCache, SpotifyConfig};
use sqlx::{migrate, sqlite::SqlitePoolOptions};

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
