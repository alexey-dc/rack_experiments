## Introducing Puma
In the [last section](../01_rack_threaded_requests/README.md), it turned out that vanilla `rackup` already runs Puma.

To make these tests more deterministic, I've added a `./run` aka `bash run` command in each folder that captures what the meaningful way to run the experiment is.

```bash
puma
√ ~/work/alexey/rack_experiments/02_puma_basic % bash run
Puma starting in single mode...
* Puma version: 5.6.4 (ruby 3.0.2-p107) ("Birdie's Version")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 88888
* Listening on http://0.0.0.0:9292
````

Configuring the number of threads:
```bash
√ ~/work/alexey/rack_experiments/02_puma_basic % puma -t0:5
Puma starting in single mode...
* Puma version: 5.6.4 (ruby 3.0.2-p107) ("Birdie's Version")
*  Min threads: 0
*  Max threads: 5
...
````

This will reproduce the output of the test we got when we ran `puma` accidentally/implicitly through `rackup`:
```bash
# Server
1020: 1
1060: 3
1040: 2
1060: 4
1020: 5
1040: 6
1020: 7
1040: 9
1060: 8
```

EXCELLENT! That means that the *sibling threads do indeed share global state*.

Note the output made it up to 9, which is correct - in my case, I lucked out to have a Ruby interpreter that guarantees thread-safe increments.

Client output:
```bash
# Client
+-------------------------------------------+
|   03 threads     -       03 requests      |
+-------------------------------------------+
============ 100 ==========
1020 => 1, 1020 => 5, 1040 => 7
============ 80 ==========
1040 => 2, 1040 => 4, 1020 => 8
============ 60 ==========
1060 => 3, 1060 => 6, 1060 => 9
```

## Mutexes
[The standard](https://stackoverflow.com/a/44521011). doesn't lock that down in Ruby - so implementations may vary. To ensure correctness, it's possible to use [mutexes](https://lucaguidi.com/2014/03/27/thread-safety-with-ruby/). M

From ["this thread"](https://stackoverflow.com/a/47462446) on Ruby VM implementations:
```ruby
irb(main):002:0> RbConfig::CONFIG["RUBY_INSTALL_NAME"]
=> "ruby"
```
That means I have one of the most popular VMs, YARV, which evolved out of MRI (which also would have given `ruby`), so on my machine, integers are safe from race-condition without mutexes.

## Testing the limit

```bash
/Users/alexey/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/net/http.rb:987:in `initialize': Can't assign requested address - connect(2) for "localhost" port 9292 (Errno::EADDRNOTAVAIL)
```

This happens if I scale up the basic client tests to about `~300x300` - both for Rack and Sinatra.

[Next experiment](../03_puma_sinatra/README.md)
