const NOTES_CACHE_TTL = 1000 * 60;
const NOTES_API_URL = "https://api.luuumine.com/notes";
const NOTES_LIMIT = 10;

function notes_formatDate(isoString) {
  const date = new Date(isoString);

  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");
  const hh = String(date.getHours()).padStart(2, "0");
  const min = String(date.getMinutes()).padStart(2, "0");

  return `${yyyy}-${mm}-${dd} ${hh}:${min}`;
}

function notes_renderWidget(data) {
  const container = document.getElementById("notes-container");
  if (!container) return;

  if (!data) {
    container.innerHTML = '<li class="loading-text">api error.</li>';
    return;
  }

  if (data.length === 0) {
    container.innerHTML = '<li class="loading-text">no notes found.</li>';
    return;
  }

  container.innerHTML = data
    .map(
      (note) =>
        `<li><time datetime="${note.created_at}">${notes_formatDate(note.created_at)}</time> <span>${note.content}</span></li>`,
    )
    .join("");
}

async function notes_fetchAPI() {
  try {
    const res = await fetch(`${NOTES_API_URL}?limit=${NOTES_LIMIT}`);
    if (!res.ok) throw new Error("Bad API response");
    return await res.json();
  } catch (error) {
    return null;
  }
}

async function notes_sync() {
  const data = await notes_fetchAPI();
  if (data) {
    sessionStorage.setItem("notes_data", JSON.stringify(data));
    sessionStorage.setItem(
      "notes_expires",
      (Date.now() + NOTES_CACHE_TTL).toString(),
    );
  }
  notes_renderWidget(data);
}

function notes_init() {
  const cachedData = sessionStorage.getItem("notes_data");
  const cachedExp = sessionStorage.getItem("notes_expires");

  if (cachedData && cachedExp && Date.now() < parseInt(cachedExp, 10)) {
    notes_renderWidget(JSON.parse(cachedData));
  } else {
    notes_sync();
  }

  if (!window.notes_interval) {
    window.notes_interval = window.setInterval(notes_sync, NOTES_CACHE_TTL);
  }
}

notes_init();
