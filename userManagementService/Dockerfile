FROM elixir:1.11.4-alpine

WORKDIR src

ADD .. .

RUN mix local.hex --force

RUN mix do deps.get deps.compile compile

ENTRYPOINT mix run --no-halt
