import "dotenv/config";
import express from "express";
import { createServer } from "http";
import net from "net";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { registerOAuthRoutes } from "./oauth";
import { registerStorageProxy } from "./storageProxy";
import { appRouter } from "../routers";
import { createContext } from "./context";
import { ENV } from "./env";

const MAX_JSON_BODY_BYTES = "1mb";
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 120;
const rateBuckets = new Map<string, { count: number; resetAt: number }>();

function allowedCorsOrigins() {
  return new Set(
    (process.env.CORS_ORIGINS ?? "")
      .split(",")
      .map((origin) => origin.trim())
      .filter(Boolean),
  );
}

function isDevelopmentOrigin(origin: string) {
  try {
    const hostname = new URL(origin).hostname;
    return hostname === "localhost" || hostname === "127.0.0.1" || hostname.endsWith(".manus.computer");
  } catch {
    return false;
  }
}

function isAllowedCorsOrigin(origin: string) {
  const configuredOrigins = allowedCorsOrigins();
  if (configuredOrigins.has(origin)) return true;
  return !ENV.isProduction && isDevelopmentOrigin(origin);
}

function requestKey(req: express.Request) {
  const forwarded = req.headers["x-forwarded-for"];
  const candidate = Array.isArray(forwarded) ? forwarded[0] : forwarded?.split(",")[0];
  return candidate?.trim() || req.ip || "unknown";
}

function isPortAvailable(port: number): Promise<boolean> {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.listen(port, () => {
      server.close(() => resolve(true));
    });
    server.on("error", () => resolve(false));
  });
}

async function findAvailablePort(startPort: number = 3000): Promise<number> {
  for (let port = startPort; port < startPort + 20; port++) {
    if (await isPortAvailable(port)) {
      return port;
    }
  }
  throw new Error(`No available port found starting from ${startPort}`);
}

async function startServer() {
  const app = express();
  const server = createServer(app);

  app.disable("x-powered-by");

  app.use((req, res, next) => {
    res.header("X-Content-Type-Options", "nosniff");
    res.header("X-Frame-Options", "DENY");
    res.header("Referrer-Policy", "no-referrer");
    res.header("Permissions-Policy", "camera=(), geolocation=(), microphone=()");
    res.header("Cross-Origin-Resource-Policy", "same-site");

    const origin = req.headers.origin;
    if (origin) {
      if (!isAllowedCorsOrigin(origin)) {
        res.status(403).json({ error: "Origin is not allowed" });
        return;
      }
      res.header("Access-Control-Allow-Origin", origin);
      res.vary("Origin");
    }
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    res.header(
      "Access-Control-Allow-Headers",
      "Origin, X-Requested-With, Content-Type, Accept, Authorization",
    );
    res.header("Access-Control-Allow-Credentials", "true");

    if (req.method === "OPTIONS") {
      res.sendStatus(204);
      return;
    }
    next();
  });

  app.use("/api", (req, res, next) => {
    const now = Date.now();
    if (rateBuckets.size > 10_000) {
      for (const [candidate, bucket] of rateBuckets) {
        if (bucket.resetAt <= now) rateBuckets.delete(candidate);
      }
    }
    const key = requestKey(req);
    const current = rateBuckets.get(key);
    const bucket = !current || current.resetAt <= now ? { count: 0, resetAt: now + RATE_LIMIT_WINDOW_MS } : current;
    bucket.count += 1;
    rateBuckets.set(key, bucket);
    if (bucket.count > RATE_LIMIT_MAX_REQUESTS) {
      res.setHeader("Retry-After", Math.ceil((bucket.resetAt - now) / 1000));
      res.status(429).json({ error: "Too many requests" });
      return;
    }
    next();
  });

  app.use(express.json({ limit: MAX_JSON_BODY_BYTES }));
  app.use(express.urlencoded({ limit: MAX_JSON_BODY_BYTES, extended: true }));

  registerStorageProxy(app);
  registerOAuthRoutes(app);

  app.get("/api/health", (_req, res) => {
    res.json({ ok: true, timestamp: Date.now() });
  });

  app.use(
    "/api/trpc",
    createExpressMiddleware({
      router: appRouter,
      createContext,
    }),
  );

  const preferredPort = parseInt(process.env.PORT || "3000");
  const port = await findAvailablePort(preferredPort);

  if (port !== preferredPort) {
    console.log(`Port ${preferredPort} is busy, using port ${port} instead`);
  }

  server.listen(port, () => {
    console.log(`[api] server listening on port ${port}`);
  });
}

startServer().catch(console.error);
