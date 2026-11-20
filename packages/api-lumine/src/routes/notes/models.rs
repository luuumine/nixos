use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use utoipa::{IntoParams, ToSchema};

#[derive(Debug, PartialEq, Serialize, Deserialize, FromRow, ToSchema)]
pub struct Note {
    pub id: i64,
    pub content: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Deserialize, ToSchema)]
pub struct CreateNoteRequest {
    pub content: String,
}

#[derive(Deserialize, IntoParams)]
pub struct GetNotesParams {
    pub limit: Option<i64>,
}
