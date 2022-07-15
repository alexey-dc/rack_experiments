## Faraday + Sinatra
This example steps up the [previous one](../04_sinatra_env_basic/README.md) by showcasing the interaction of Faraday (and its middleware) with Sinatra's env.

It's the same basic setup - needing to access something in Sinatra's ENV from a PORO (Faraday's middleware) - and not having access. However in this case, it's hopefully more clear why we may want to preserve the object between endpoint runs. We may be accessing many different endpoints, with different Faraday instances - at some point, re-creating all our dependencies would cause unacceptable slowdown.
