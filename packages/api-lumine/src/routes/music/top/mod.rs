use crate::AppState;
use axum::{Router, routing::get};

mod artists;
mod tracks;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/artists", get(artists::handler))
        .route("/tracks", get(tracks::handler))
}
