// =============================
// 📌 Imports & Config
// =============================
const http = require('http');
const Lynx = require('lynx');

const STATSD_HOST = process.env.STATSD_HOST || 'localhost';
const STATSD_PORT = parseInt(process.env.STATSD_PORT || '8125', 10);
const PORT = parseInt(process.env.PORT || '3000', 10);
const NODE_ENV = process.env.NODE_ENV || 'development';

// =============================
// 📊 StatsD Client
// =============================
const metrics = new Lynx(STATSD_HOST, STATSD_PORT, {
    on_error: (err) => console.error('StatsD Error:', err),
});

// Utility: Sleep
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// =============================
// 🌐 HTTP Server (API Routes)
// =============================
const requestHandler = (req, res) => {
    if (req.url === '/healthz') {
        return sendJSON(res, 200, {status: 'ok', uptime: process.uptime()});
    }

    if (req.url === '/') {
        return sendHTML(res, 200, `
            <h1>Test DevOps Application</h1>
            <p>Application is running and sending metrics to StatsD</p>
            <p>StatsD Host: <strong>${STATSD_HOST}:${STATSD_PORT}</strong></p>
            <p>Environment: <strong>${NODE_ENV}</strong></p>
            <p>Timestamp: <strong>${new Date().toISOString()}</strong></p>
        `);
    }

    return sendJSON(res, 404, {error: 'not found'});
};

function sendJSON(res, status, obj) {
    res.writeHead(status, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(obj));
}

function sendHTML(res, status, html) {
    res.writeHead(status, {'Content-Type': 'text/html'});
    res.end(`
        <html>
            <head><title>Test DevOps App</title></head>
            <body>${html}</body>
        </html>
    `);
}

const server = http.createServer(requestHandler);

// =============================
// 📡 Metrics Loop
// =============================
let running = true;

async function sendMetric() {
    try {
        const delay = Math.floor(Math.random() * 1000);
        metrics.timing('test.core.delay', delay);
        console.log(`📊 Sent metric: test.core.delay = ${delay}ms`);
        await sleep(3000);
    } catch (err) {
        console.error('❌ Failed to send metric:', err);
    }
}

async function mainLoop() {
    console.log("🚀 App started. Sending metrics to StatsD...");
    console.log(`📡 STATSD: ${STATSD_HOST}:${STATSD_PORT}`);
    console.log(`🌐 HTTP Server running on port ${PORT}`);

    while (running) {
        await sendMetric();
    }

    console.log("🛑 Metrics loop stopped.");
}

// =============================
// 🧹 Graceful Shutdown
// =============================
function shutdown(signal) {
    console.log(`\n⚠️ Received ${signal}, shutting down...`);
    running = false;

    setTimeout(() => {
        metrics.close();
        server.close(() => {
            console.log("✨ Clean exit.");
            process.exit(0);
        });
    }, 500);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

// =============================
// ▶️ Start App
// =============================
server.listen(PORT, () => {
    console.log(`🌐 HTTP Server listening on port ${PORT}`);
    mainLoop().catch((err) => {
        console.error('❌ Unexpected error:', err);
        process.exit(1);
    });
});
