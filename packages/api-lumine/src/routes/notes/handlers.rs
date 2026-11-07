use axum::{
    extract::{Json, Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};

use super::{auth::RequireAuth, models::*};
use crate::{ApiError, AppState};

#[utoipa::path(
    get,
    path = "/",
    tag = "notes",
    responses(
        (status = 200, description = "list of notes", body = Vec<Note>)
    ),
    params(GetNotesParams)
)]
pub async fn get_notes(
    State(state): State<AppState>,
    Query(params): Query<GetNotesParams>,
) -> Result<impl IntoResponse, ApiError> {
    let limit = params.limit.unwrap_or(-1);

    let notes: Vec<Note> = sqlx::query_as("SELECT * FROM notes ORDER BY id DESC LIMIT (?)")
        .bind(limit)
        .fetch_all(&state.notes.db_pool)
        .await
        .map_err(|e| {
            eprintln!("DB ERROR [get_notes]: {}", e);
            ApiError::InternalServerError
        })?;

    Ok(Json(notes))
}

#[utoipa::path(
    get,
    path = "/{id}",
    tag = "notes",
    responses(
        (status = 200, description = "list of notes", body = Vec<Note>)
    )
)]
pub async fn get_note(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<impl IntoResponse, ApiError> {
    let note = sqlx::query_as::<_, Note>("SELECT * FROM notes WHERE id = (?)")
        .bind(id)
        .fetch_optional(&state.notes.db_pool)
        .await
        .map_err(|e| {
            eprintln!("DB ERROR [get_note]: {}", e);
            ApiError::InternalServerError
        })?;

    match note {
        Some(n) => {
            println!("GET /notes/{} -> 200", id);
            Ok(Json(n))
        }
        None => {
            println!("GET /notes/{} -> 404", id);
            Err(ApiError::NotFound)
        }
    }
}

#[utoipa::path(
    post,
    path = "/",
    tag = "notes",
    responses(
        (status = StatusCode::CREATED, body = Note)
    ),
    security(("NOTES_API_KEY" = []))
)]
pub async fn post_note(
    _auth: RequireAuth,
    State(state): State<AppState>,
    Json(payload): Json<CreateNoteRequest>,
) -> Result<impl IntoResponse, ApiError> {
    // insert the note
    let note: Note = sqlx::query_as::<_, Note>(
        "INSERT INTO notes (content) VALUES (?) RETURNING id, content, created_at",
    )
    .bind(&payload.content)
    .fetch_one(&state.notes.db_pool)
    .await
    .map_err(|e| {
        eprintln!("DB ERROR [post_note]: {}", e);
        ApiError::InternalServerError
    })?;

    println!(
        "POST /notes -> 201 (id: {}, content: \"{}\")",
        note.id, note.content
    );

    Ok((StatusCode::CREATED, Json(note)))
}

#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "notes",
    responses(
        (status = StatusCode::NO_CONTENT, description = "the note was deleted"),
        (status = StatusCode::BAD_REQUEST, description = "the note doesn't exist")
    )
)]
pub async fn delete_note(
    _auth: RequireAuth,
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<impl IntoResponse, ApiError> {
    let result = sqlx::query("DELETE FROM notes WHERE id = (?)")
        .bind(id)
        .execute(&state.notes.db_pool)
        .await
        .map_err(|e| {
            eprintln!("DB ERROR [delete_note]: {}", e);
            ApiError::InternalServerError
        })?;

    if result.rows_affected() == 0 {
        println!("DELETE /notes/{} -> 400", id);
        return Err(ApiError::BadRequest);
    }

    println!("DELETE /notes/{} -> 204", id);

    Ok(StatusCode::NO_CONTENT)
}
