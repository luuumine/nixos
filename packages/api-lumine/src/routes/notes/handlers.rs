use crate::{
    ApiError, AppState,
    routes::notes::{
        auth::RequireAuth,
        models::{CreateNoteRequest, GetNotesParams, Note},
    },
};

use axum::{
    extract::{Json, Path, Query, State},
    http::StatusCode,
};

#[utoipa::path(
    get,
    path = "/",
    tag = "notes",
    responses(
        (status = StatusCode::OK, description = "List of notes", body = Vec<Note>),
        ApiError,
    ),
    params(GetNotesParams),
)]
pub async fn get_notes(
    State(state): State<AppState>,
    Query(params): Query<GetNotesParams>,
) -> Result<Json<Vec<Note>>, ApiError> {
    let limit = params.limit.unwrap_or(-1);

    let notes: Vec<Note> = sqlx::query_as("SELECT * FROM notes ORDER BY id DESC LIMIT (?)")
        .bind(limit)
        .fetch_all(&state.notes.db_pool)
        .await?;

    Ok(Json(notes))
}

#[utoipa::path(
    get,
    path = "/{id}",
    tag = "notes",
    params(("id" = i64, Path, description = "Note ID")),
    responses(
        (status = StatusCode::OK, description = "Get a single note by ID", body = Note),
        ApiError,
    ),
)]
pub async fn get_note(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Note>, ApiError> {
    let note = sqlx::query_as::<_, Note>("SELECT * FROM notes WHERE id = (?)")
        .bind(id)
        .fetch_optional(&state.notes.db_pool)
        .await?;

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
        (status = StatusCode::CREATED, description = "Note created", body = Note),
        ApiError,
    ),
    security(("NOTES_API_KEY" = [])),
)]
pub async fn post_note(
    _auth: RequireAuth,
    State(state): State<AppState>,
    Json(payload): Json<CreateNoteRequest>,
) -> Result<(StatusCode, Json<Note>), ApiError> {
    // insert the note
    let note: Note = sqlx::query_as::<_, Note>(
        "INSERT INTO notes (content) VALUES (?) RETURNING id, content, created_at",
    )
    .bind(&payload.content)
    .fetch_one(&state.notes.db_pool)
    .await?;

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
    params(("id" = i64, Path, description = "Note ID")),
    responses(
        (status = StatusCode::NO_CONTENT, description = "The note was deleted"),
        ApiError,
    ),
    security(("NOTES_API_KEY" = [])),
)]
pub async fn delete_note(
    _auth: RequireAuth,
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, ApiError> {
    let result = sqlx::query("DELETE FROM notes WHERE id = (?)")
        .bind(id)
        .execute(&state.notes.db_pool)
        .await?;

    if result.rows_affected() == 0 {
        return Err(ApiError::BadRequest);
    }

    println!("DELETE /notes/{} -> 204", id);

    Ok(StatusCode::NO_CONTENT)
}
