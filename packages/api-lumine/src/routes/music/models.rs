use serde::{Deserialize, Serialize};

#[derive(Serialize, Clone, PartialEq)]
pub struct Image {
    pub small: String,
    pub medium: String,
    pub large: String,
}

#[derive(Serialize, Clone, PartialEq)]
pub struct Artist {
    pub name: String,
    pub url: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub images: Option<Image>,
}

#[derive(Serialize, Clone)]
pub struct Track {
    pub title: String,
    pub album: String,
    pub track_number: u64,
    pub url: String,
    pub images: Image,
    pub artists: Vec<Artist>,
}

#[derive(Serialize, Clone)]
#[serde(tag = "status", content = "track", rename_all = "snake_case")]
pub enum NowPlayingResponse {
    NotPlaying,     // 204
    Paused(Track),  // 200, is_playing: false
    Playing(Track), // 200, is_playing: true
}

pub type TopArtistsResponse = Vec<Artist>;
pub type TopTracksResponse = Vec<Track>;

#[derive(Deserialize, Clone, Default, Debug, PartialEq, Eq, Hash)]
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

#[derive(Deserialize)]
pub struct TopParams {
    #[serde(default)]
    pub range: TimeRange,
}
