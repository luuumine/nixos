import { serve } from "@hono/node-server";
import { Hono } from "hono";

import { handle as statusHandler } from "./status";
import { handle as musicHandler } from "./music";

const app = new Hono();

app.all("/api/status", async (c) => await statusHandler(c.req.raw));
app.all("/api/music", async (c) => await musicHandler(c.req.raw));

app.notFound((c) => {
  console.warn(
    `[${new Date().toISOString()}] ${c.req.method} ${c.req.url} -> 404`,
  );
  return c.text("Not Found", 404);
});

app.onError((err, c) => {
  console.error(
    `[${new Date().toISOString()}] Error handling ${c.req.url}`,
    err,
  );
  return c.text("Internal Server Error", 500);
});

const port = Number(process.env.PORT) || 3000;
console.log(`Server is running on port ${port}`);

serve({
  fetch: app.fetch,
  port,
});
