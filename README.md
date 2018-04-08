# Webhooks

Small application listening for webhook notifications.

Currently supporting:
- [Discord Bots](https://discordbots.org) ([docs](https://discordbots.org/api/docs#webhooks))


## Discord Bots

Required setup:  
- Adding `dbl_secret` to config.exs (or setting an environment variable called `DBL_SECRET`)
- Specifying `dbl_secret` secret in the optional available `Authorization` header, dbl provides
- Adding `bot_id` to config.exs (or setting an environment variable called `BOT_ID`)
- Running Redis
  - Connection defaults to `127.0.0.1:6397`, can be configured by specifying `redis` in the config.exs file.

Upon receiving an upvote this will add a key `DBL:#{USER_ID}` with the value `1` into redis.
> The key will expire after 24 hours; The user can vote again
