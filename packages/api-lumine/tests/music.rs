mod common;
use common::*;

use api_lumine::*;

use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use http_body_util::BodyExt;
use serde_json::Value;
use tower::ServiceExt;

#[tokio::test]
async fn currently_playing() -> Result<(), String> {
    let mock_server = spotify_mock_server().await?;

    // start app
    let state = create_dummy_state(&mock_server.uri(), &mock_server.uri()).await;
    let app = create_app(state);

    let request = Request::builder()
        .uri("/music/currently_playing")
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
        .map_err(|e| format!("Failed to parse JSON response: {}", e))?;

    assert_eq!(json["status"], "playing");

    // track data
    assert_eq!(json["track"]["title"], "belavenir");
    assert_eq!(json["track"]["album"], "RAPPEL");
    assert_eq!(json["track"]["track_number"], 7);
    assert_eq!(
        json["track"]["url"],
        "https://open.spotify.com/track/7KdLgNe9VGs7v9F39M8wl9"
    );
    assert_eq!(
        json["track"]["images"]["large"],
        "https://i.scdn.co/image/ab67616d0000b273840cee3deff8dd039e25aaa5"
    );
    assert_eq!(
        json["track"]["images"]["small"],
        "https://i.scdn.co/image/ab67616d00004851840cee3deff8dd039e25aaa5"
    );

    // nested artists array
    let artists = json["track"]["artists"]
        .as_array()
        .expect("Expected artists array");
    assert_eq!(artists.len(), 2);
    assert_eq!(artists[0]["name"], "Jima");
    assert_eq!(
        artists[0]["url"],
        "https://open.spotify.com/artist/5kGE5WhDLFZwLude1avCuw"
    );
    assert_eq!(
        artists[0].get("images"),
        None,
        "Nested artist should not have images"
    );
    assert_eq!(artists[1]["name"], "ysma");

    Ok(())
}

#[tokio::test]
async fn top_artists() -> Result<(), String> {
    let mock_server = spotify_mock_server().await?;

    // start app
    let state = create_dummy_state(&mock_server.uri(), &mock_server.uri()).await;
    let app = create_app(state);

    let request = Request::builder()
        .uri("/music/top/artists")
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
        .map_err(|e| format!("Failed to parse JSON response: {}", e))?;
    let artists = json.as_array().expect("Expected a JSON array");

    assert_eq!(artists.len(), 5);

    // artist data
    assert_eq!(artists[0]["name"], "Laïoss");
    assert_eq!(
        artists[0]["url"],
        "https://open.spotify.com/artist/7vtQ2ObucvhANXj1s6cGkc"
    );

    // images data
    assert_eq!(
        artists[0]["images"]["large"],
        "https://i.scdn.co/image/ab6761610000e5ebf78971192ab702f9d3e87ea3"
    );
    assert_eq!(
        artists[0]["images"]["medium"],
        "https://i.scdn.co/image/ab67616100005174f78971192ab702f9d3e87ea3"
    );
    assert_eq!(
        artists[0]["images"]["small"],
        "https://i.scdn.co/image/ab6761610000f178f78971192ab702f9d3e87ea3"
    );

    Ok(())
}

#[tokio::test]
async fn top_tracks() -> Result<(), String> {
    let mock_server = spotify_mock_server().await?;

    // start app
    let state = create_dummy_state(&mock_server.uri(), &mock_server.uri()).await;
    let app = create_app(state);

    let request = Request::builder()
        .uri("/music/top/tracks")
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
        .map_err(|e| format!("Failed to parse JSON response: {}", e))?;
    let tracks = json.as_array().expect("Expected a JSON array");

    assert_eq!(tracks.len(), 5);

    // track data
    assert_eq!(tracks[0]["title"], "ma star");
    assert_eq!(tracks[0]["album"], ".MOV");
    assert_eq!(tracks[0]["track_number"], 1);
    assert_eq!(
        tracks[0]["url"],
        "https://open.spotify.com/track/1eLUBPMQXSmufjQjy9LMGe"
    );

    // images data
    assert_eq!(
        tracks[0]["images"]["large"],
        "https://i.scdn.co/image/ab67616d0000b273a01bd68fe0a65e75b06c903f"
    );
    assert_eq!(
        tracks[0]["images"]["medium"],
        "https://i.scdn.co/image/ab67616d00001e02a01bd68fe0a65e75b06c903f"
    );
    assert_eq!(
        tracks[0]["images"]["small"],
        "https://i.scdn.co/image/ab67616d00004851a01bd68fe0a65e75b06c903f"
    );

    // artists data
    let artists = tracks[0]["artists"]
        .as_array()
        .expect("Expected artists array");
    assert_eq!(artists.len(), 1);
    assert_eq!(artists[0]["name"], "Laïoss");
    assert_eq!(
        artists[0]["url"],
        "https://open.spotify.com/artist/7vtQ2ObucvhANXj1s6cGkc"
    );
    assert_eq!(
        artists[0].get("images"),
        None,
        "Images should be omitted for nested artists"
    );

    Ok(())
}
