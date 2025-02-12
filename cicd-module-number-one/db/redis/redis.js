const redis = require('redis');
const bluebird = require('bluebird');
const config = require('config');
const reqlib = require('app-root-path').require;
const logger = reqlib('/helpers/logger');

// Promisify all redis methods
bluebird.promisifyAll(redis.RedisClient.prototype);
bluebird.promisifyAll(redis.Multi.prototype);

class RedisDB {
  async connectDB() {
    try {
      // Create connection only once
      if (!RedisDB.redisClient) {
        // Get redis config
        const host = config.get('redis.host');
        const port = config.get('redis.port');

        // Check if redis config is present
        if (!host || !port) {
          logger.error('Redis:connectDB() function => Error = redis config not found');
          return false;
        }

        // Connect to redis client
        const client = redis.createClient({
          host: host,
          port: port
        });

        // Check if any error while connecting to db
        const connectionStatus = await this.checkConnection(client);

        // DB not connected
        if (!connectionStatus) {
          return false;
        }

        // Instance of redis client
        RedisDB.redisClient = client;

        return true;
      }
    } catch (e) {
      logger.error('Redis:connectDB() function => Error = ', e);
      throw e;
    }
  }

  // Check whether db has connected properly or not
  checkConnection(client) {
    return new Promise((resolve, reject) => {
      client.on('error', (e) => {
        // Not connected
        if (e) {
          logger.error('Redis:checkConnection() function => Error = ', e);
          return resolve(false);
        }
      });

      client.on('connect', () => {
        return resolve(true);
      });
    });
  }

  // Get redis client
  getRedisClient() {
    return RedisDB.redisClient || null;
  }

  // This will set a value
  async set(name, value, expiry) {
    try {
      if (parseInt(expiry, 10) > 0) {
        await RedisDB.redisClient.setAsync(name, value, 'EX', expiry);
      } else {
        await RedisDB.redisClient.setAsync(name, value);
      }
      return true;
    } catch (e) {
      logger.error('Redis:set() function => Error = ', e);
      throw e;
    }
  }

  // This will get a value
  async get(name) {
    try {
      const returnValue = await RedisDB.redisClient.getAsync(name);
      return returnValue;
    } catch (e) {
      logger.error('Redis:get() function => Error = ', e);
      throw e;
    }
  }

  // This will set a value in a set
  async sadd(key, members) {
    try {
      await RedisDB.redisClient.saddAsync(key, members);
      return true;
    } catch (e) {
      logger.error('Redis:sadd() function => Error = ', e);
      throw e;
    }
  }

  // This will get a value from a set
  async smembers(key) {
    try {
      const returnValue = await RedisDB.redisClient.smembersAsync(key);
      return returnValue;
    } catch (e) {
      logger.error('Redis:smembers() function => Error = ', e);
      throw e;
    }
  }

  // This will delete key
  async delete(key) {
    try {
      const result = await RedisDB.redisClient.delAsync(key);
      return result;
    } catch (e) {
      logger.error('Redis:delete() function => Error = ', e);
      throw e;
    }
  }
}

module.exports = RedisDB;

