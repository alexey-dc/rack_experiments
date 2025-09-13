## Tl;dr
Modern `rackup` is not guaranteed to run on one thread - for example, my asdf-installed `rackup` command just runs puma with 0-5 threads.

However, within a thread, there are no interruptions: it runs top to bottom, and future requests are blocked until the previous request is fully processed.

## Reminder
For the experiment log below to make sense, check out the code that is sibling to this README.md file:
- [config.ru](config.ru)
- [stress_test.rb](stress_test.rb) (numbers cranked down to not be quite so stressing :D)

## Verifying Rack's single-threadedness
I used to think Rack was single-threded out of the box.

To test that, I ran a [simple rack application](config.ru) with `rackup`, and ran a plain Ruby multi-threaded process against it.

Each GET request to Rack increments a global variable - which I print, prefixed with its thread ID. Both the thread ID and immediate value of the global are returned from the HTTP request.

In the multi-threaded client, each thread just calls the GET endpoint on a loop, and accumulates results (ThreadID+Value when called). After the loop is done, each client thread prints _its_ thread ID, and the values it accumulated.

E.g. if the server-side global starts at 0, and we have 3 threads with 3 requests, we should end up at 9. Fingers crossed!

```bash
# start!
rackup
```
Server side output
```bash
# Server
760: 1
800: 2
840: 3
760: 4
800: 5
760: 6
840: 7
800: 8
760: 9
```

That result is unexpected - I would expect rackup to launch a single-threaded process without Puma, and the entire left column to be just one number, using the same thread ID.

So it seems `rackup` is in fact not single-threaded out of the box, otherwise I'd expect those `Thread.current.object_id`s to be the same (left column). The cuprit is seen in this output:
```bash
√ ~/work/alexey/rack_experiments/01_thread_globals_naive % rackup
Puma starting in single mode...
* Puma version: 5.6.4 (ruby 3.0.2-p107) ("Birdie's Version")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 83916
* Listening on http://127.0.0.1:9292
* Listening on http://[::1]:9292
Use Ctrl-C to stop
```

It seems that's the behavior of rackup out of the box - to launch itself with Puma and default process/thread settings when Puma is available.

Is my `rackup` even real? I installed it through `asdf`:
```
√ ~/work/alexey/rack_experiments/01_thread_globals_naive % which rackup
/Users/alexey/.asdf/shims/rackup

### So what is that shim?
vim /Users/alexey/.asdf/shims/rackup
### It just does this...
exec /opt/homebrew/opt/asdf/libexec/bin/asdf exec "rackup" "$@"
```

One interesting aspect I checked - which just tests the behavior of a server behind Puma in this setup - is whether a single-threaded client utilizes a single server thread in this case:
```bash
# Server
780: 1
780: 2
780: 3
780: 4
780: 5
```

This is getting ahead of where I wanted to be in this first experiment though, so I forced a single-threaded backend:
```bash
?1 ~/work/alexey/rack_experiments/01_thread_globals_naive % rackup -O Threads=0:1
Puma starting in single mode...
* Puma version: 5.6.4 (ruby 3.0.2-p107) ("Birdie's Version")
*  Min threads: 0
*  Max threads: 1
*  Environment: development
*          PID: 85306
* Listening on http://127.0.0.1:9292
* Listening on http://[::1]:9292
````

In this case, no matter how many threads/requests the client throws at it, the `Thread.current.object_id` is stable:
```bash
# More massive loads have been tried.
760: 1
760: 2
760: 3
760: 4
760: 5
760: 6
760: 7
760: 8
760: 9
```

This establishes a baseline against which I'll compare outputs from the next series of tests (for each client thread ID, ouputs `server_thread_id => value_returned`, ...):

```bash
# Client
+-------------------------------------------+
|   03 threads     -       08 requests      |
+-------------------------------------------+
============ 80 ==========
760 => 1, 760 => 4, 760 => 7, 760 => 10, 760 => 13, 760 => 16, 760 => 19, 760 => 22
============ 60 ==========
760 => 2, 760 => 5, 760 => 8, 760 => 11, 760 => 14, 760 => 17, 760 => 20, 760 => 23
============ 100 ==========
760 => 3, 760 => 6, 760 => 9, 760 => 12, 760 => 15, 760 => 18, 760 => 21, 760 => 24
````

A bit too orderly... I've seen it more random without the random sleep I have in each API call.

Perhaps the thread scheduler in Ruby is more likely to run threads in the order they are created in if each thread has to be context switched (during the server-side sleep as they are blocked on I/O).

```bash
# Client
+-------------------------------------------+
|   03 threads     -       08 requests      |
+-------------------------------------------+
============ 100 ==========
760 => 2, 760 => 5, 760 => 8, 760 => 10, 760 => 13, 760 => 16, 760 => 19, 760 => 22
============ 80 ==========
760 => 3, 760 => 6, 760 => 9, 760 => 12, 760 => 14, 760 => 18, 760 => 21, 760 => 23
============ 60 ==========
760 => 1, 760 => 4, 760 => 7, 760 => 11, 760 => 15, 760 => 17, 760 => 20, 760 => 24
```


[Next experiment](../02_puma_basic/README.md)
