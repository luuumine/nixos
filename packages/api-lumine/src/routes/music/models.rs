use serde::{Deserialize, Serialize};
use utoipa::{IntoParams, ToSchema};

#[derive(Clone, Serialize, ToSchema)]
pub struct Image {
    pub small: String,
    pub medium: String,
    pub large: String,
}

#[derive(Clone, Serialize, ToSchema)]
pub struct Artist {
    pub name: String,
    pub url: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub images: Option<Image>,
}

#[derive(Clone, Serialize, ToSchema)]
pub struct Track {
    pub title: String,
    pub album: String,
    pub track_number: u64,
    pub url: String,
    pub images: Image,
    pub artists: Vec<Artist>,
}

#[derive(Clone, Debug, PartialEq, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum PlaybackStatus {
    NotPlaying,
    Paused,
    Playing,
}

#[derive(Clone, Serialize, ToSchema)]
pub struct NowPlayingResponse {
    pub status: PlaybackStatus,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub track: Option<Track>,
}

#[derive(Deserialize, Clone, Default, Debug, PartialEq, Eq, Hash, ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum TimeRange {
    ShortTerm,
    #[default]
    MediumTerm,
    LongTerm,
}

impl TimeRange {
    pub fn as_spotify_param(&self) -> &'static str {
        match self {
            TimeRange::ShortTerm => "short_term",
            TimeRange::MediumTerm => "medium_term",
            TimeRange::LongTerm => "long_term",
        }
    }
}

#[derive(Deserialize, IntoParams)]
pub struct TopParams {
    #[serde(default)]
    #[param(inline)]
    pub range: TimeRange,
}
