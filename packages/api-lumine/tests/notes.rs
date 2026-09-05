use api_lumine::{routes::notes::Note, *};

use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use serde_json::{Value, json};
use sqlx::{SqlitePool, migrate, query_as, sqlite::SqlitePoolOptions};
use std::sync::Arc;
use tokio::sync::RwLock;
use tower::ServiceExt;

async fn get_pool_state() -> (SqlitePool, AppState) {
    let db_pool = SqlitePoolOptions::new()
        .connect("sqlite::memory:")
        .await
        .expect("Failed to create in-memory db for tests");
    migrate!()
        .run(&db_pool)
        .await
        .expect("Failed to migrate test db");

    let pool = db_pool.clone();

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
            api_key: "valid_api_key".to_string(),
        },
    };

    (pool, state)
}

#[tokio::test]
async fn get_single_note_exists() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?), (?)")
        .bind("my specific note")
        .bind("another note")
        .execute(&pool)
        .await
        .map_err(|e| format!("Failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes/1")
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
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    assert_eq!(json["id"], 1);
    assert_eq!(json["content"], "my specific note");

    Ok(())
}

#[tokio::test]
async fn get_single_note_not_found() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?)")
        .bind("my specific note")
        .execute(&pool)
        .await
        .map_err(|e| format!("Failed to seed db: {}", e))?;

    let app = create_app(state);

    // request non existing id
    let request = Request::builder()
        .uri("/notes/999")
        .body(Body::empty())
        .map_err(|e| format!("failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::NOT_FOUND);

    let body = response
        .collect()
        .await
        .map_err(|e| format!("Failed to collect body: {}", e))?
        .to_bytes();

    let json: Value = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    assert_eq!(json["error"]["code"], "NOT_FOUND");

    Ok(())
}

#[tokio::test]
async fn get_notes_empty_db() -> Result<(), String> {
    let (_, state) = get_pool_state().await;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes")
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

    let notes: Vec<Note> = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    assert!(notes.is_empty());

    Ok(())
}

#[tokio::test]
async fn get_notes_all() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?), (?)")
        .bind("first note")
        .bind("second note")
        .execute(&pool)
        .await
        .map_err(|e| format!("failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes")
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

    let notes: Vec<Note> = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    // how many notes it should return
    assert_eq!(notes.len(), 2);

    // check ordering
    assert_eq!(notes[0].id, 2);
    assert_eq!(notes[0].content, "second note");

    assert_eq!(notes[1].id, 1);
    assert_eq!(notes[1].content, "first note");

    Ok(())
}

#[tokio::test]
async fn get_n_notes_fewer_exists() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?)")
        .bind("first note")
        .execute(&pool)
        .await
        .map_err(|e| format!("failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes?limit=2")
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

    let notes: Vec<Note> = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    // how many notes it should return
    // only one because there's only one in db
    assert_eq!(notes.len(), 1);

    // content
    assert_eq!(notes[0].id, 1);
    assert_eq!(notes[0].content, "first note");

    Ok(())
}

#[tokio::test]
async fn get_n_notes_exact() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?), (?)")
        .bind("first note")
        .bind("second note")
        .execute(&pool)
        .await
        .map_err(|e| format!("failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes?limit=2")
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

    let notes: Vec<Note> = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    // how many notes it should return
    assert_eq!(notes.len(), 2);

    // content and ordering
    assert_eq!(notes[0].id, 2);
    assert_eq!(notes[0].content, "second note");

    assert_eq!(notes[1].id, 1);
    assert_eq!(notes[1].content, "first note");

    Ok(())
}

#[tokio::test]
async fn get_n_notes_more_exists() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?), (?), (?)")
        .bind("first note")
        .bind("second note")
        .bind("third note")
        .execute(&pool)
        .await
        .map_err(|e| format!("failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .uri("/notes?limit=2")
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

    let notes: Vec<Note> = serde_json::from_slice(&body)
        .map_err(|e| format!("failed to parse JSON response: {}", e))?;

    // how many notes it should return
    assert_eq!(notes.len(), 2);

    // content and ordering
    assert_eq!(notes[0].id, 3);
    assert_eq!(notes[0].content, "third note");

    assert_eq!(notes[1].id, 2);
    assert_eq!(notes[1].content, "second note");

    Ok(())
}

#[tokio::test]
async fn post_note_valid_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    let app = create_app(state);

    let note_body = json!({
        "content":"this is a test note!"
    });

    let request = Request::builder()
        .method("POST")
        .uri("/notes")
        .header("Content-Type", "application/json")
        .header("Authorization", "Bearer valid_api_key")
        .body(Body::from(note_body.to_string()))
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    // Reponse status should be 201 CREATED
    assert_eq!(response.status(), StatusCode::CREATED);

    let body = response
        .collect()
        .await
        .map_err(|e| format!("Failed to collect body: {}", e))?
        .to_bytes();

    let json: Value = serde_json::from_slice(&body)
        .map_err(|e| format!("Failed to parse JSON response: {}", e))?;

    assert_eq!(json["content"], "this is a test note!");
    assert_eq!(json["id"], 1);

    let note: Note = query_as::<_, Note>("SELECT * FROM notes WHERE id = 1")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Note was not found in database: {}", e))?;

    assert_eq!(note.id, 1);
    assert_eq!(note.content, "this is a test note!");

    Ok(())
}

#[tokio::test]
async fn post_note_invalid_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    let app = create_app(state);

    let note_body = json!({
        "content":"im an intruder!"
    });

    // invalid api key in request
    let request = Request::builder()
        .method("POST")
        .uri("/notes")
        .header("Content-Type", "application/json")
        .header("Authorization", "Bearer invalid_api_key")
        .body(Body::from(note_body.to_string()))
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    // Reponse status should be 401 UNAUTHORIZED
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;

    assert_eq!(count.0, 0);

    Ok(())
}

#[tokio::test]
async fn post_note_no_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    let app = create_app(state);

    let note_body = json!({
        "content":"im not authentified!"
    });

    // no api key in request
    let request = Request::builder()
        .method("POST")
        .uri("/notes")
        .header("Content-Type", "application/json")
        .body(Body::from(note_body.to_string()))
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    // Reponse status should be 401 UNAUTHORIZED
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;

    assert_eq!(count.0, 0);

    Ok(())
}

#[tokio::test]
async fn post_note_invalid_body() -> Result<(), String> {
    let (_, state) = get_pool_state().await;
    let app = create_app(state);

    let request = Request::builder()
        .method("POST")
        .uri("/notes")
        .header("Content-Type", "application/json")
        .header("Authorization", "Bearer valid_api_key")
        .body(Body::from(r#"{"invalid_json": true"#)) // malformed JSON
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Dispatch failed: {}", e))?;

    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    Ok(())
}

#[tokio::test]
async fn delete_note_valid_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?), (?)")
        .bind("note to delete")
        .bind("note to keep")
        .execute(&pool)
        .await
        .map_err(|e| format!("Failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .method("DELETE")
        .uri("/notes/1")
        .header("Authorization", "Bearer valid_api_key")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::NO_CONTENT);

    // check only 1 note remains
    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;
    assert_eq!(count.0, 1);

    // check id 1 was deleted
    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes WHERE id = 1")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;
    assert_eq!(count.0, 0);

    // check id 2 still exists
    let remaining_count: (i64,) = query_as("SELECT COUNT(*) FROM notes WHERE id = 2")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;
    assert_eq!(remaining_count.0, 1);

    Ok(())
}

#[tokio::test]
async fn delete_note_not_found() -> Result<(), String> {
    let (_, state) = get_pool_state().await;

    let app = create_app(state);

    // note 999 does not exist
    let request = Request::builder()
        .method("DELETE")
        .uri("/notes/999")
        .header("Authorization", "Bearer valid_api_key")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    Ok(())
}

#[tokio::test]
async fn delete_note_invalid_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?)")
        .bind("protected note")
        .execute(&pool)
        .await
        .map_err(|e| format!("Failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .method("DELETE")
        .uri("/notes/1")
        .header("Authorization", "Bearer invalid_api_key")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    // ensure note was NOT deleted
    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes WHERE id = 1")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;
    assert_eq!(count.0, 1);

    Ok(())
}

#[tokio::test]
async fn delete_note_no_auth() -> Result<(), String> {
    let (pool, state) = get_pool_state().await;

    sqlx::query("INSERT INTO notes (content) VALUES (?)")
        .bind("protected note")
        .execute(&pool)
        .await
        .map_err(|e| format!("Failed to seed db: {}", e))?;

    let app = create_app(state);

    let request = Request::builder()
        .method("DELETE")
        .uri("/notes/1")
        .body(Body::empty())
        .map_err(|e| format!("Failed to build request: {}", e))?;

    let response = app
        .oneshot(request)
        .await
        .map_err(|e| format!("Failed to dispatch request: {}", e))?;

    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    // ensure note was NOT deleted
    let count: (i64,) = query_as("SELECT COUNT(*) FROM notes WHERE id = 1")
        .fetch_one(&pool)
        .await
        .map_err(|e| format!("Failed to query db: {}", e))?;
    assert_eq!(count.0, 1);

    Ok(())
}
