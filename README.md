# Webhooks
[![Build Status](https://travis-ci.org/TheDragonProject/webhooks.svg?branch=master)](https://travis-ci.org/TheDragonProject/webhooks)  

Small application listening for webhook notifications.
> Docker container built by travis are available [here](https://hub.docker.com/r/spaceeec/tdp_webhooks/).

Currently supporting:
- [Discord Bots](https://discordbots.org) ([docs](https://discordbots.org/api/docs#webhooks))

## General

Required Setup:  
- Running Redis
  - Connection defaults to `redis://127.0.0.1:6397`, can be overriden with an environment variable called `REDIS_URL`

Optional Setup:  
- You can override the port Cowboy / Plug will listen to by setting an environment variable `PORT`

## Discord Bots

Required Setup:  
- Setting an environment variable called `DBL_SECRET`
- Setting that secret in the optional available `Authorization` header, which dbl provides
- Setting an environment variable called `BOT_ID` with the id of the bot to receive upvotes for

Upon receiving an upvote this will add a key `dbl:#{USER_ID}` with the value `1` into redis.
> The key will expire after 24 hours; The user can vote again
