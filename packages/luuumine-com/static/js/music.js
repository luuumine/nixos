const MUSIC_CACHE_TTL = 1000 * 3;
const MUSIC_API_URL = "https://api.luuumine.com/music";
const music_formatter = new Intl.ListFormat("en", {
  style: "short",
  type: "conjunction",
});

function music_updateWidget(data) {
  const widget = document.getElementById("np-widget");
  const title = document.getElementById("np-title");
  const artist = document.getElementById("np-artist");

  if (!widget || !title || !artist) return;

  if (!data) {
    widget.removeAttribute("href");
    widget.className = "now-playing-card empty";
    title.innerText = "api error";
    artist.innerText = "";
    return;
  }

  if (data.status === "not_playing") {
    widget.removeAttribute("href");
    widget.className = "now-playing-card empty";
    title.innerText = "not playing anything";
    artist.innerText = "";
  } else {
    // "playing" and "paused"
    widget.href = data.song_url;
    widget.className = `now-playing-card ${data.status}`;
    title.innerText = data.title;
    artist.innerText = music_formatter.format(data.artists);
  }
}

async function music_fetchAPI() {
  try {
    const res = await fetch(`${MUSIC_API_URL}/currently_playing`);
    if (!res.ok) throw new Error("Bad API response");
    return await res.json();
  } catch (error) {
    return null;
  }
}

async function music_sync() {
  const data = await music_fetchAPI();
  if (data) {
    sessionStorage.setItem("music_data", JSON.stringify(data));
    sessionStorage.setItem(
      "music_expires",
      (Date.now() + MUSIC_CACHE_TTL).toString(),
    );
  }
  music_updateWidget(data);
}

function music_init() {
  const cachedData = sessionStorage.getItem("music_data");
  const cachedExp = sessionStorage.getItem("music_expires");

  if (cachedData && cachedExp && Date.now() < parseInt(cachedExp, 10)) {
    music_updateWidget(JSON.parse(cachedData));
  } else {
    music_sync();
  }

  if (!window.music_interval) {
    window.music_interval = window.setInterval(music_sync, MUSIC_CACHE_TTL);
  }
}

music_init();
