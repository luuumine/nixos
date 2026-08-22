use crate::AppState;
use axum::{
    extract::FromRequestParts,
    http::{StatusCode, header, request::Parts},
};

pub struct RequireAuth;

impl FromRequestParts<AppState> for RequireAuth {
    type Rejection = StatusCode;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        // get Authorization header
        let auth_header = parts
            .headers
            .get(header::AUTHORIZATION)
            .and_then(|val| val.to_str().ok());

        // extract token
        let token = match auth_header {
            Some(header) => match header.strip_prefix("Bearer ") {
                Some(tok) => tok,
                None => {
                    println!(
                        "AUTH FAILED: Missing 'Bearer ' prefix on {} {}",
                        parts.method, parts.uri
                    );
                    return Err(StatusCode::UNAUTHORIZED);
                }
            },
            None => {
                println!(
                    "AUTH FAILED: Missing Authorization header on {} {}",
                    parts.method, parts.uri
                );
                return Err(StatusCode::UNAUTHORIZED);
            }
        };

        if token == state.notes.api_key {
            Ok(RequireAuth)
        } else {
            Err(StatusCode::UNAUTHORIZED)
        }
    }
}
