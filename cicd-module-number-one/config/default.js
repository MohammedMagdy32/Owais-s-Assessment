module.exports = {
  env: process.env.NODE_ENV || "development",
  host: "http://localhost:3000",
  port: 3000,
  debug: 1,
  mysql: {
    host: process.env.MYSQL_HOST || "localhost",
    port: process.env.MYSQL_PORT || 3306,
    user: process.env.MYSQL_USER || "root",
    password: process.env.MYSQL_PASSWORD || "Root@123",
    connectionLimit: 10,
    database: process.env.MYSQL_DATABASE || "nodejs_api",
    timezone: "+05:30"
  },
  redis: {
    host: process.env.REDIS_HOST || "localhost",
    port: process.env.REDIS_PORT || 6379
  },
  mongo: {
    uri: "mongodb://localhost:27017/nodejs_api",
    user: "node",
    password: "Node@123",
    poolSize: 10
  },
  auth: {
    algorithm: "RS256",
    tokenExpiryInMin: {
      web: 10,
      android: 120
    },
    issuer: "Node API Ltd",
    audience: "http://localhost"
  },
  email: {
    noReply: "noreply@gmail.com",
    gmail: {
      user: "user@gmail.com",
      password: "password"
    },
    smtp: {
      user: "user@gmail.com",
      password: "password",
      host: "localhost",
      port: 25,
      secure: false
    }
  }
};

