## Sinatra's env
This test exhibits the basic behavior of Sinatra's `env` variable in an artificial setting.

The conclusion here is that within Sinatra's controllers, `env` [acts like a global](https://github.com/alexey-dc/rack_experiments/blob/main/04_sinatra_env_basic/config.ru#L19), but it's [not accessible outside of Sinatra](https://github.com/alexey-dc/rack_experiments/blob/main/04_sinatra_env_basic/lib/some_poro_helper.rb#L17).

In this simplistic example, it's tempting to come up with solutions like simply passing in the env or its constituents down to the PORO object - but that is not always possible; to illustrate that, the [next example](../05_sinatra_faraday/README.md) augments this simplistic setup with Faraday middleware.

