const http = require('http');
const Lynx = require('lynx');

const PORT = process.env.PORT || 3000;
const STATSD_HOST = process.env.STATSD_HOST || 'localhost';
const STATSD_PORT = parseInt(process.env.STATSD_PORT || '8125', 10);
const PORT = parseInt(process.env.PORT || '3000', 10);

// Create metrics client
const metrics = new Lynx(STATSD_HOST, STATSD_PORT, {
    on_error: (err) => console.error('StatsD Error:', err),
});

// Sleep utility
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// HTTP Server
const server = http.createServer((req, res) => {
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }));
        return;
    }
    
    if (req.url === '/') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
            <html>
                <head><title>Test DevOps App</title></head>
                <body>
                    <h1>🚀 Test DevOps Application</h1>
                    <p>Application is running and sending metrics to StatsD</p>
                    <p>StatsD Host: ${STATSD_HOST}:${STATSD_PORT}</p>
                    <p>Environment: ${process.env.NODE_ENV || 'development'}</p>
                    <p>Timestamp: ${new Date().toISOString()}</p>
                </body>
            </html>
        `);
        return;
    }
    
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
});

async function sendMetric() {
    try {
        const delay = Math.floor(Math.random() * 1000);
        metrics.timing('test.core.delay', delay);
        console.log(`📊 Sent metric: test.core.delay = ${delay}ms`);
    } catch (err) {
        console.error('❌ Failed to send metric:', err);
    }

    await sleep(3000);
}

// =============================
// 🚑 Health Check API
// =============================
const server = http.createServer((req, res) => {
    if (req.url === '/healthz') {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify({status: 'ok', uptime: process.uptime()}));
        return;
    }

    res.writeHead(404, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({error: 'not found'}));
});

server.listen(PORT, () => {
    console.log(`🧪 Health API running on port ${PORT} (GET /healthz)`);
});

// =============================
// ♾️ Main Loop
// =============================
async function mainLoop() {
    console.log("🚀 App started. Sending metrics to StatsD...");
    console.log(`📡 STATSD: ${STATSD_HOST}:${STATSD_PORT}`);
    console.log(`🌐 HTTP Server running on port ${PORT}`);

    while (running) {
        await sendMetric();
    }

    console.log("🛑 Main loop stopped.");
}

// Graceful shutdown handler
let running = true;

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

function shutdown(signal) {
    console.log(`\n⚠️ Received ${signal}, shutting down...`);
    running = false;

    // Give metric client time to flush
    setTimeout(() => {
        metrics.close();
        console.log("✨ Clean exit.");
        process.exit(0);
    }, 500);
}

// Start HTTP Server
server.listen(PORT, () => {
    console.log(`🌐 HTTP Server listening on port ${PORT}`);
});

// Start metrics loop
mainLoop().catch((err) => {
    console.error('❌ Unexpected error:', err);
    process.exit(1);
});
