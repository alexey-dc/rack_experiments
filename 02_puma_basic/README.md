## Introducing Puma
Puma self-introduced itself in the [last section](../01_rack_threaded_requests/README.md) where I was trying to simply run vanilla rackup. Typical cat.

To accommodate for these letdowns and make these tests more deterministic, I've added a `./run` aka `bash run` command in each folder that captures what the meaningful way to run the experiment is.

So basically, running `puma` on my system achieves the same thing as rackup
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

But then I want to _lock it down_ to something like that default...
```bash
√ ~/work/alexey/rack_experiments/02_puma_basic % puma -t0:5
Puma starting in single mode...
* Puma version: 5.6.4 (ruby 3.0.2-p107) ("Birdie's Version")
*  Min threads: 0
*  Max threads: 5
...
````

Got you kitty. Can't escape now - you get the threads you're given.

The results of running the same test that was basically already accidentally run previously were straightforward and pleasantly as-expected for once.

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

Excellent. EXCELLENT! This tells me that... the *sibling threads do indeed share state*. I wish I didn't find that out by accident earlier already, because this is the paragraph where I am blown away by my discovery.

I got real nice outputs - we made it as high as 9, so the counting was done correctly. Perhaps it's no accident? Perhaps I get thread-safe increments??

[No :(](https://stackoverflow.com/a/44521011). Ugh. Ruby doesn't lock that down in any standard - so implementations may vary. I guess if I needed to count correctly, I'd have to use [mutexes](https://lucaguidi.com/2014/03/27/thread-safety-with-ruby/) or something. Oh well, I didn't really want that 9 anyway. I am *laser* focused on the target: I'll need a HashMap eventually.

Client looks good too:

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
````

Moving on. I got a 9 without using mutexes. Deal with it. In fact I'd have been _happy_ if I got like a negative 75. _That_ would have been exciting.



## Disappointments
I thought after Rack left me and I got ambushed by Puma in [step (1)](../01_rack_threaded_requests/README.md), I was prepared for the harsh realities of the real world. However...

```bash
/Users/alexey/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/net/http.rb:987:in `initialize': Can't assign requested address - connect(2) for "localhost" port 9292 (Errno::EADDRNOTAVAIL)
````

This happens if I scale up the basic client tests to about `~300x300` - both for Rack and Sinatra.

It's large volume, but maybe Sinatra could have slowed down vs crashing.
