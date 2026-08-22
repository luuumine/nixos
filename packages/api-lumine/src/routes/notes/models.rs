use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Serialize, Deserialize, FromRow, PartialEq)]
pub struct Note {
    pub id: i64,
    pub content: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Deserialize)]
pub struct CreateNoteRequest {
    pub content: String,
}

#[derive(Deserialize)]
pub struct GetNotesParams {
    pub limit: Option<i64>,
}
