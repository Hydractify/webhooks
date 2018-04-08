FROM leifg/elixir:latest as build

LABEL name "webhooks-build"
LABEL maintainer "SpaceEEC"

COPY lib ./lib
COPY config ./config
COPY rel ./rel
COPY mix.exs .
COPY mix.lock .

RUN export MIX_ENV=prod && \
  rm -rf _build && \
  mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get && \
  mix release

RUN APP_NAME="webhooks" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

FROM alpine:3.7

LABEL name "webhooks"
LABEL maintainer "SpaceEEC"

RUN apk add --no-cache openssl bash

COPY --from=build /export/ .

ENTRYPOINT ["/bin/webhooks"]
CMD ["foreground"]