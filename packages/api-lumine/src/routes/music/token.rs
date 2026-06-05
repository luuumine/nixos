use crate::{AppState, TokenCache};

use reqwest::StatusCode;
use serde::Deserialize;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Deserialize)]
pub struct SpotifyTokenResponse {
    pub access_token: String,
    pub expires_in: u64,
}

pub async fn get_token(state: &AppState) -> Result<String, String> {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| format!("time shouldnt be negative: {}", e))?
        .as_secs();

    let buffer = 10;

    {
        // get read lock
        let cache = state.spotify.token_cache.read().await;

        if let Some(token_data) = &*cache {
            if now + buffer < token_data.expires_at {
                return Ok(token_data.access_token.clone());
            }
        }
    } // `cache` goes out of scope there

    // get write lock. pauses other threads
    let mut cache = state.spotify.token_cache.write().await;

    // check if another thread wrote a new valid token before updating it
    if let Some(token_data) = &*cache {
        if now + buffer < token_data.expires_at {
            return Ok(token_data.access_token.clone());
        }
    }

    let token_response = update_token(state).await?;

    let new_expiration = now + token_response.expires_in;

    let access_token = token_response.access_token.clone();

    *cache = Some(TokenCache {
        access_token: token_response.access_token,
        expires_at: new_expiration,
    });

    Ok(access_token)
}

async fn update_token(state: &AppState) -> Result<SpotifyTokenResponse, String> {
    let url = format!("{}/api/token", state.spotify.account_url);

    let params = [
        ("grant_type", "refresh_token"),
        ("refresh_token", &state.spotify.refresh_token),
    ];

    let response = state
        .http_client
        .post(url)
        .basic_auth(&state.spotify.client_id, Some(&state.spotify.client_secret))
        .form(&params)
        .send()
        .await
        .map_err(|e| format!("failed to send token request: {}", e))?;

    match response.status() {
        StatusCode::OK => {
            let token_data = response
                .json::<SpotifyTokenResponse>()
                .await
                .map_err(|e| format!("failed to aprse token response json: {}", e))?;
            Ok(token_data)
        }
        status => Err(format!(
            "spotify auth api returned unexpected status: {}",
            status
        )),
    }
}

#[cfg(test)]
mod tests {

    use crate::{AppState, SpotifyConfig, routes::music::token::update_token};

    use serde_json::json;
    use std::sync::Arc;
    use tokio::sync::RwLock;
    use wiremock::{
        Mock, MockServer, ResponseTemplate,
        matchers::{body_string_contains, header, method, path},
    };

    #[tokio::test]
    async fn fetch_token() -> Result<(), String> {
        let mock_server = MockServer::start().await;

        let auth_response_body = json!({
            "access_token": "new_mocked_token",
            "token_type": "Bearer",
            "expires_in": 3600,
            "scope": "user-read-currently-playing"
        });

        Mock::given(method("POST"))
            .and(path("/api/token"))
            .and(header("Content-Type", "application/x-www-form-urlencoded"))
            .and(header("Authorization", "Basic bXlfaWQ6bXlfc2VjcmV0")) // basic auth for "my_id:my_secret
            .and(body_string_contains("grant_type=refresh_token"))
            .and(body_string_contains("refresh_token=my_refresh_token"))
            .respond_with(ResponseTemplate::new(200).set_body_json(auth_response_body))
            .mount(&mock_server)
            .await;

        let state = AppState {
            http_client: reqwest::Client::new(),
            spotify: SpotifyConfig {
                api_url: "https://api.spotify.com".to_string(),
                account_url: mock_server.uri(),
                client_id: "my_id".to_string(),
                client_secret: "my_secret".to_string(),
                refresh_token: "my_refresh_token".to_string(),
                token_cache: Arc::new(RwLock::new(None)),
            },
        };

        let token_response = update_token(&state).await?;

        assert_eq!(token_response.access_token, "new_mocked_token");
        assert_eq!(token_response.expires_in, 3600);

        Ok(())
    }
}
