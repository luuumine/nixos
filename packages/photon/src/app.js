let socket = null;
let myId = null;

const inputBox = document.querySelector("#message");
const usernameBox = document.querySelector("#username");
const outputBox = document.getElementById("output");
const userCount = document.getElementById("user-count");
const userList = document.getElementById("user-list");
const connectBtn = document.getElementById("connect-btn");
const changeBtn = document.getElementById("change-btn");
const sendBtn = document.getElementById("send-btn");

inputBox.addEventListener("keypress", function(event) {
    if (event.key === "Enter") sendMessage();
});

usernameBox.addEventListener("keypress", function(event) {
    if (event.key === "Enter") changeUsername();
});

function setConnectedUI(connected) {
    inputBox.disabled = !connected;
    usernameBox.disabled = !connected;
    changeBtn.disabled = !connected;
    sendBtn.disabled = !connected;

    if (connected) {
        connectBtn.textContent = "Disconnect";
        connectBtn.className = "btn-disconnect";
        userList.classList.remove("disconnected-list");
    } else {
        connectBtn.textContent = "Connect";
        connectBtn.className = "btn-connect";
        userList.classList.add("disconnected-list");
    }
}

function toggleConnection() {
    if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
        socket.close();
    } else {
        connect();
    }
}

function connect() {
    if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
        return;
    }

    socket = new WebSocket("ws://" + location.host + "/ws");

    socket.onopen = () => {
        const savedName = localStorage.getItem("username");
        socket.send(JSON.stringify({ type: "join", username: savedName }));
        setConnectedUI(true);
    };

    socket.onmessage = (event) => {
        const payload = JSON.parse(event.data);

        if (payload.type === "welcome") {
            myId = payload.id;
            localStorage.setItem("username", payload.username);
            appendSystemMessage(`Connected as ${payload.username}`);
        }
        else if (payload.type === "chat") {
            const isMe = (payload.sender_id === myId);
            appendChatMessage(isMe, isMe ? "You" : payload.username, payload.text);
        }
        else if (payload.type === "system") {
            appendSystemMessage(payload.text);
        }
        else if (payload.type === "user_list") {
            userCount.textContent = payload.users.length;
            userList.innerHTML = "";
            payload.users.forEach(u => {
                const div = document.createElement("div");
                div.classList.add("user-item");
                div.textContent = u;
                userList.appendChild(div);
            });
        }
    };

    socket.onclose = () => {
        appendSystemMessage("Disconnected from server.");
        userCount.textContent = "0";
        setConnectedUI(false);
    };
}

function sendMessage() {
    const msg = inputBox.value.trim();
    if (!msg || !socket || socket.readyState !== WebSocket.OPEN) return;

    socket.send(JSON.stringify({ type: "chat", text: msg }));
    inputBox.value = "";
}

function changeUsername() {
    const newName = usernameBox.value.trim();
    if (!newName || !socket || socket.readyState !== WebSocket.OPEN) return;

    localStorage.setItem("username", newName);
    socket.send(JSON.stringify({ type: "change_username", new_username: newName }));
    usernameBox.value = "";
}

function appendChatMessage(isMe, senderName, text) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("msg-wrapper", isMe ? "mine" : "theirs");

    const nameDiv = document.createElement("div");
    nameDiv.classList.add("sender-name");
    nameDiv.textContent = senderName;

    const bubbleDiv = document.createElement("div");
    bubbleDiv.classList.add("bubble");
    bubbleDiv.textContent = text;

    wrapper.appendChild(nameDiv);
    wrapper.appendChild(bubbleDiv);

    outputBox.appendChild(wrapper);
    outputBox.scrollTop = outputBox.scrollHeight;
}

function appendSystemMessage(text) {
    const div = document.createElement("div");
    div.classList.add("system-msg");
    div.textContent = text;

    outputBox.appendChild(div);
    outputBox.scrollTop = outputBox.scrollHeight;
}

setConnectedUI(false);
connect();
