# Webhooks

Small application listening for webhook notifications.

Currently supporting:
- [Discord Bots](https://discordbots.org) ([docs](https://discordbots.org/api/docs#webhooks))


## Discord Bots

Required setup:  
- Adding `dbl_secret` to config.exs (or setting an environment variable called `DBL_SECRET`)
- Appending `/webhooks/dbl?secret=secret_from_above` to the webservers' url
- Adding `bot_id` to config.exs (or setting an environment variable called `bot_id`)
- Redis listening on `127.0.0.1:6397` (default)

Upon receiving an upvote this will add a key `DBL:#{USER_ID}` with the value `1` into redis.
> The key will expire after 24 hours; The user can vote again

In case a user unvotes the key will be removed.