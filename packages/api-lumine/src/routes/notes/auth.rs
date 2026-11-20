use crate::{ApiError, AppState};

use axum::{
    extract::FromRequestParts,
    http::{header, request::Parts},
};

pub struct RequireAuth;

impl FromRequestParts<AppState> for RequireAuth {
    type Rejection = ApiError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        // get Authorization header
        let reason = match parts
            .headers
            .get(header::AUTHORIZATION)
            .and_then(|val| val.to_str().ok())
        {
            None => "missing header",
            Some(h) => match h.strip_prefix("Bearer ") {
                None => "missing 'Bearer ' prefix",
                Some(tok) if tok == state.notes.api_key => return Ok(RequireAuth),
                Some(_) => "invalid token",
            },
        };

        println!("{} {} -> 401 ({})", parts.method, parts.uri, reason);
        Err(ApiError::Unauthorized)
    }
}
