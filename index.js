const Lynx = require('lynx');

const STATSD_HOST = process.env.STATSD_HOST || 'localhost';
const STATSD_PORT = parseInt(process.env.STATSD_PORT || '8125', 10);

// Create metrics client
const metrics = new Lynx(STATSD_HOST, STATSD_PORT, {
    on_error: (err) => console.error('StatsD Error:', err),
});

// Sleep utility
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

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

async function mainLoop() {
    console.log("🚀 App started. Sending metrics to StatsD...");
    console.log(`📡 STATSD: ${STATSD_HOST}:${STATSD_PORT}`);

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

// Start
mainLoop().catch((err) => {
    console.error('❌ Unexpected error:', err);
    process.exit(1);
});
