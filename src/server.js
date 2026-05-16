require("dotenv").config();

const app = require("./app");
const config = require("./config/environment");
const { testConnection } = require("./config/database");
const logger = require("./utils/logger");
const initializeDatabase = require("./scripts/initDatabase");
const { seedData } = require("./scripts/seedDatabase");

const PORT = config.port || process.env.PORT || 3000;

// Start Express server
const server = app.listen(PORT, () => {
  logger.info(`🚀 Server running on port ${PORT}`);
  logger.info(`📚 API Documentation: /api-docs`);
  logger.info(`🏥 Health Check: /api/health`);
  logger.info(`🌍 Environment: ${config.nodeEnv || process.env.NODE_ENV}`);

  initializeApp();
});

// Initialize application
async function initializeApp() {
  try {
    logger.info("🔄 Connecting to database...");

    const dbConnected = await testConnection();

    if (!dbConnected) {
      logger.error("❌ Failed to connect to database");
      return;
    }

    logger.info("✅ Database connected");

    // Initialize database tables
    logger.info("🔄 Initializing database...");

    await initializeDatabase();
    // Conditionally run seeders when explicitly enabled via env
    if (process.env.RUN_SEEDERS === "true") {
      try {
        logger.info("🔁 RUN_SEEDERS=true — running seeders...");
        await seedData();
        logger.info("✅ Seeders finished");
      } catch (err) {
        logger.error("Seeder error:", err);
      }
    }

    logger.info("✅ Database initialized");
  } catch (error) {
    logger.error("❌ Initialization error:", error);
  }
}

// Handle server errors
server.on("error", (err) => {
  logger.error("Server Error:", err);
});

// Handle unhandled promise rejections
process.on("unhandledRejection", (err) => {
  logger.error("Unhandled Promise Rejection:", err);
});

// Handle uncaught exceptions
process.on("uncaughtException", (err) => {
  logger.error("Uncaught Exception:", err);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM signal received");

  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  logger.info("SIGINT signal received");

  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});
