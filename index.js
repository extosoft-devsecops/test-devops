// =============================
// 📌 Imports & Config
// =============================
const http = require("http");
const StatsD = require("hot-shots");

// ======== ENVIRONMENT ========
const PORT = parseInt(process.env.PORT || "3000", 10);
const NODE_ENV = process.env.NODE_ENV || "localhost";
const ENABLE_METRICS = process.env.ENABLE_METRICS === "true";

const SERVICE_NAME = process.env.SERVICE_NAME || "test-devops-app";
const STATSD_HOST = process.env.DD_AGENT_HOST || process.env.STATSD_HOST || "localhost";
const STATSD_PORT = parseInt(process.env.DD_DOGSTATSD_PORT || "8125", 10);

// Utility: Sleep
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// =============================
// 🐶 DogStatsD Client Toggle
// =============================
let dogstatsd = null;

if (ENABLE_METRICS) {
    console.log("📡 Metrics ENABLED");
    console.log(`🐶 DogStatsD → ${STATSD_HOST}:${STATSD_PORT}`);

    dogstatsd = new StatsD({
        host: STATSD_HOST,
        port: STATSD_PORT,
        prefix: `${SERVICE_NAME}.`,
        globalTags: {
            env: NODE_ENV,
            service: SERVICE_NAME,
        },
        errorHandler: (err) => console.error("🐶 StatsD Error:", err),
    });
} else {
    console.log("📉 Metrics DISABLED");
    // 👇 Dummy client (ไม่ error เวลาเรียกใช้)
    dogstatsd = {
        increment: () => {
        }, timing: () => {
        }, gauge: () => {
        }
    };
}

// =============================
// 🌐 HTTP Server (API Routes)
// =============================
const requestHandler = (req, res) => {
    if (req.url === "/healthz") {
        return sendJSON(res, 200, {status: "ok", uptime: process.uptime()});
    }

    if (req.url === "/") {
        return sendHTML(
            res,
            200,
            `
      <h1>Test DevOps App</h1>
      <p>Sending metrics via Datadog DogStatsD</p>
      <p>Environment: <strong>${NODE_ENV}</strong></p>
      <p>Service: <strong>${SERVICE_NAME}</strong></p>
      <p>Metrics: <strong>${ENABLE_METRICS ? "ENABLED" : "DISABLED"}</strong></p>
      <p>Timestamp: <strong>${new Date().toISOString()}</strong></p>
    `
        );
    }

    return sendJSON(res, 404, {error: "not found"});
};

function sendJSON(res, status, obj) {
    res.writeHead(status, {"Content-Type": "application/json"});
    res.end(JSON.stringify(obj));
}

function sendHTML(res, status, html) {
    res.writeHead(status, {"Content-Type": "text/html"});
    res.end(`<html><body>${html}</body></html>`);
}

const server = http.createServer(requestHandler);

// =============================
// 📊 Metrics Loop
// =============================
let running = true;

async function sendMetric() {
    try {
        const delay = Math.floor(Math.random() * 1000);
        dogstatsd.timing("core.random_delay", delay);
        console.log(`📊 core.random_delay = ${delay}ms`);
        await sleep(3000);
    } catch (err) {
        console.error("❌ Failed to send metric:", err);
    }
}

async function mainLoop() {
    while (running) {
        await sendMetric();
    }
}

// =============================
// 🧹 Graceful Shutdown
// =============================
function shutdown(signal) {
    console.log(`\n⚠️ Received ${signal}, shutting down...`);
    running = false;

    setTimeout(() => {
        dogstatsd.close?.();
        server.close(() => {
            console.log("✨ Clean exit.");
            process.exit(0);
        });
    }, 500);
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));

// =============================
// ▶️ Start App
// =============================
if (require.main === module) {
    server.listen(PORT, () => {
        console.log(`🚀 App running at port ${PORT}`);
        mainLoop().catch((err) => {
            console.error("❌ Unexpected error:", err);
            process.exit(1);
        });
    });
}

// เพิ่มฟังก์ชัน start/stop สำหรับ unit test
module.exports = {
    server,
    start: (cb) => server.listen(PORT, cb),
    stop: (cb) => server.close(cb),
};
