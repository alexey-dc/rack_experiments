## Verifying Rack's single-threadedness
The most basic rack app is single-threaded. To prove that with certainty - and to establish a baseline of expectations - I ran a [simple rack application](config.ru) with `rackup`, and ran a plain Ruby multi-threaded process against it.

Each GET request to Rack increments a global variable - which I print, prefixed with its thread ID. Both the thread ID and immediate value of the global are returned from the HTTP request.

In the multi-threaded client, each thread just calls the GET endpoint on a loop, and accumulates results (ThreadID+Value when called). After the loop is done, each client thread prints _its_ thread ID, and the values it accumulated.

E.g. if the server-side global starts at 0, and we have 3 threads with 3 requests, we should end up at 9. Fingers crossed!

```bash
# START!
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
Oh. Wait, what. I expected those `Thread.current.object_id`s to be the same on the left...

I guess `rack` isn't single-threaded out of the box after all.

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

Fine. Weird. Why is it Puma? Is `rackup` even a real thing? I had mine from `asdf`:
```
√ ~/work/alexey/rack_experiments/01_thread_globals_naive % which rackup
/Users/alexey/.asdf/shims/rackup

### So what is that shim?
vim /Users/alexey/.asdf/shims/rackup
### It just does this...
exec /opt/homebrew/opt/asdf/libexec/bin/asdf exec "rackup" "$@"
```

I'm sure it's fine: Puma is probably righteously spinning up its extra allowed threads to deal with my multi-threaded client. Here's the result if I run the _client_ on 1 thread with 5 requests, against this same server:

```bash
# Server
780: 1
780: 2
780: 3
780: 4
780: 5
```

Yup. Same thing with 1 thread + 25 requests. Maakes seense. So my rack just runs Puma.

This is getting ahead of where I wanted to be in these experiments, so I want to slow down a bit:

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

And yeah, no matter how many threads/requests the client throws at it, the `Thread.current.object_id` is stable:
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

Alright. And the baseline for the client shall be (for each client thread ID, ouputs `server_thread_id => value_returned`, ...):

```bash
# Client
+-------------------------------------------+
|   03 threads     -       03 requests      |
+-------------------------------------------+
============ 60 ==========
800 => 1, 800 => 4, 800 => 7
============ 80 ==========
800 => 2, 800 => 5, 800 => 8
============ 100 ==========
800 => 3, 800 => 6, 800 => 9
````

A bit too orderly... It randomizes if we add a few more values:
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


