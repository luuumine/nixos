use axum::{
    Router,
    extract::{
        State, WebSocketUpgrade,
        ws::{Message, WebSocket},
    },
    http::header,
    response::{Html, IntoResponse, Response},
    routing::{any, get},
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};
use uuid::Uuid;

#[derive(Deserialize)]
#[serde(tag = "type")]
enum ClientMessage {
    #[serde(rename = "join")]
    Join { username: Option<String> },
    #[serde(rename = "chat")]
    Chat { text: String },
    #[serde(rename = "change_username")]
    ChangeUsername { new_username: String },
}

#[derive(Serialize)]
#[serde(tag = "type")]
enum ServerMessage {
    #[serde(rename = "welcome")]
    Welcome { id: Uuid, username: String },
    #[serde(rename = "chat")]
    Chat {
        sender_id: Uuid,
        username: String,
        text: String,
    },
    #[serde(rename = "system")]
    System { text: String },
    #[serde(rename = "user_list")]
    UserList { users: Vec<String> },
}

struct AppState {
    tx: broadcast::Sender<String>,
    users: RwLock<HashMap<Uuid, String>>,
}

#[tokio::main]
async fn main() {
    let (tx, _rx) = broadcast::channel::<String>(100);

    let state = Arc::new(AppState {
        tx,
        users: RwLock::new(HashMap::new()),
    });

    let app = Router::new()
        .route("/", get(index))
        .route("/app.js", get(app_js))
        .route("/style.css", get(style_css))
        .route("/ws", any(websocket))
        .with_state(state);

    let addr = "0.0.0.0:3000";
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();

    println!("Server running at {}", addr);
    axum::serve(listener, app).await.unwrap();
}

async fn index() -> Html<&'static str> {
    Html(include_str!("index.html"))
}

async fn app_js() -> impl IntoResponse {
    (
        [(header::CONTENT_TYPE, "application/javascript")],
        include_str!("app.js"),
    )
}

async fn style_css() -> impl IntoResponse {
    (
        [(header::CONTENT_TYPE, "text/css")],
        include_str!("style.css"),
    )
}

async fn websocket(ws: WebSocketUpgrade, State(state): State<Arc<AppState>>) -> Response {
    ws.on_upgrade(move |socket| handle_socket(socket, state))
}

async fn broadcast_user_list(state: &Arc<AppState>) {
    let users_map = state.users.read().await;
    let mut users: Vec<String> = users_map.values().cloned().collect();
    users.sort();

    let msg = ServerMessage::UserList { users };
    let _ = state.tx.send(serde_json::to_string(&msg).unwrap());
}

async fn handle_socket(mut socket: WebSocket, state: Arc<AppState>) {
    let mut rx = state.tx.subscribe();
    let my_id = Uuid::new_v4();
    let mut my_username = String::new();

    while let Some(Ok(Message::Text(text))) = socket.recv().await {
        if let Ok(ClientMessage::Join { username }) = serde_json::from_str(&text) {
            my_username = username.unwrap_or_else(|| format!("User-{}", &my_id.to_string()[..4]));
            break;
        }
    }

    if my_username.is_empty() {
        return;
    }

    {
        let mut users = state.users.write().await;
        users.insert(my_id, my_username.clone());
    } // drop write lock

    let welcome = ServerMessage::Welcome {
        id: my_id,
        username: my_username.clone(),
    };

    if socket
        .send(Message::Text(
            serde_json::to_string(&welcome).unwrap().into(),
        ))
        .await
        .is_err()
    {
        let mut users = state.users.write().await;
        users.remove(&my_id);
        return;
    }

    broadcast_user_list(&state).await;

    let join_msg = ServerMessage::System {
        text: format!("{} joined the chat", my_username),
    };
    let _ = state.tx.send(serde_json::to_string(&join_msg).unwrap());

    loop {
        tokio::select! {
            msg = socket.recv() => {
                let text = match msg {
                    Some(Ok(Message::Text(t))) => t,
                    Some(Ok(_)) => continue,
                    _ => break,
                };

                let Ok(client_msg) = serde_json::from_str::<ClientMessage>(&text) else {
                    continue;
                };

                let sys_msg = match client_msg {
                    ClientMessage::Chat { text: chat_text } => {
                        ServerMessage::Chat {
                            sender_id: my_id,
                            username: my_username.clone(),
                            text: chat_text,
                        }
                    }
                    ClientMessage::ChangeUsername { new_username } => {
                        let old_username = my_username.clone();
                        my_username = new_username;

                        {
                            let mut users = state.users.write().await;
                            users.insert(my_id, my_username.clone());
                        }

                        broadcast_user_list(&state).await;

                        ServerMessage::System {
                            text: format!("{} is now known as {}", old_username, my_username),
                        }
                    }
                    _ => continue,
                };

                let _ = state.tx.send(serde_json::to_string(&sys_msg).unwrap());
            },
            msg = rx.recv() => if let Ok(json_string) = msg {
                if socket.send(Message::Text(json_string.into())).await.is_err() {
                    break;
                }
            }
        }
    }

    {
        let mut users = state.users.write().await;
        users.remove(&my_id);
    }
    broadcast_user_list(&state).await;

    let leave_msg = ServerMessage::System {
        text: format!("{} left the chat", my_username),
    };
    let _ = state.tx.send(serde_json::to_string(&leave_msg).unwrap());
}
