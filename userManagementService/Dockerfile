FROM elixir:1.12.0-rc.1-alpine as builder

RUN mix local.rebar --force && \
    mix local.hex --force
WORKDIR /app
ENV MIX_ENV=prod

FROM builder as deps
COPY mix.* /app/
RUN mix do deps.get --only prod, deps.compile

FROM deps as releaser
COPY . /app/
RUN mix do release
RUN pwd
RUN ls

# ---- Application Stage ----
FROM alpine:3
RUN apk add --no-cache --update busybox-extras bash openssl curl

WORKDIR app

RUN pwd
RUN ls
COPY --from=releaser /app/_build .

CMD ["/app/prod/rel/user_management/bin/user_management", "start"]
