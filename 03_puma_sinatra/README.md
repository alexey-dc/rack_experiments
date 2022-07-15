## Sinatra
This experiment adds Sinatra to our previous setup, and a few other enhancements described below.

Here we just set the stage for demonstrating the issues with [Sinatra's `env`](../04_sinatra_env_basic/README.md), its interaction with [Faraday's middleware](../05_sinatra_faraday/README.md), and some [potential solutions](../06_solve_sinatra_env/README.md).

### Puma startup config
Puma's runs `config/puma.rb` before it boots the server it's running (Sinatra/Rack...).

That's the right place to initialize application-wide globals - my previous naive app was re-initializing the same variable each time a new thread was spun up - i.e. in theory the data could have been erased, if I actually had a thread die and be reborn.

### Mutexes
I didn't care that the previous app has the theoretical capacity to miscalculate addition, but here I added a more mature implementation.

I also ["read up"](https://stackoverflow.com/a/47462446) on Ruby VM implementations:
```ruby
irb(main):002:0> RbConfig::CONFIG["RUBY_INSTALL_NAME"]
=> "ruby"
```

Turns out I have ruby! Thank God! Mr. Mittag suggests that probably means I have one of the most popular VMs, YARV, which evolved out of MRI (which also would have given `ruby`). Groooby.

Actually, this means that my integers are race-condition proof without mutexes (on my machine)... What a rollercoaster we've just been on, phew.

### Tests/results
I intentionally let the flawed, corrupted, evil, two-faced `/thread_dangerous_increment` live alongside its valiant mutex companion `/thread_safe_increment` - and pit them to fight against each other in the pit OF DEATH to THE DEATH.

They came back EQUAL. Unscathed. I never have nice things, so I didn't expect to get the crèm-de-la-crém Ruby Virtual Machine YARV that _does_ provide thread-safe addition. I would personally choose to rely on the Ruby standard, and not my particular VM, so in production it may be wise to use mutexes for this type of situation regardless.

A smaller test result is provided below, but it holds up with thousands of requests.

```bash
# Server
1520: 1
1540: 2
1580: 3
1600: 4
1540: 5
1580: 6
1520: 7
1620: 8
1840: 9
1600: 10
1620: 11
1920: 12
1840: 13
1920: 14
1580: 15
1520: 16
1520: 17
1540: 18
1580: 19
1600: 20
1540: 21
1620: 22
1580: 23
1920: 24
1840: 25
1600: 26
1520: 27
1520: 28
1920: 29
1600: 30
```

```bash
# Client
+-------------------------------------------+
|   06 threads     -       05 requests      |
+-------------------------------------------+
============ 160 ==========
1540 => 2, 1580 => 6, 1620 => 11, 1520 => 16, 1580 => 19
============ 60 ==========
1520 => 1, 1540 => 5, 1840 => 13, 1600 => 20, 1840 => 25
============ 140 ==========
1520 => 7, 1600 => 10, 1520 => 17, 1540 => 21, 1600 => 26
============ 120 ==========
1580 => 3, 1840 => 9, 1580 => 15, 1620 => 22, 1520 => 27
============ 80 ==========
1600 => 4, 1920 => 12, 1540 => 18, 1920 => 24, 1920 => 29
============ 100 ==========
1620 => 8, 1920 => 14, 1580 => 23, 1520 => 28, 1600 => 30
```
