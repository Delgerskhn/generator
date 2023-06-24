---
to: "<%= path ? `${path}/redis/client.go` : `${cwd}/src/services/redis/client.go` %>"
---
package redis


var CTX = context.Background()

// CreateClient initialize redis client
func InitRedis() *redis.Client {
	rdb := redis.NewClient(&redis.Options{
		Addr: fmt.Sprintf("%s:%d",
			viper.GetString("REDIS_HOST"),
			viper.GetInt("REDIS_PORT"),
		),
		DB:       viper.GetInt("REDIS_DB"),
		Username: viper.GetString("REDIS_USER"),
		Password: viper.GetString("REDIS_PASSWORD"),
	})
	return rdb
}
