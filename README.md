# Rack experiments
These experiments explore certain behavior of [Rack](https://github.com/rack/rack), [Puma](https://puma.io/), [Sinatra](http://sinatrarb.com/):
- Single-threadedness
- Multi-threadedness
- Multi-process/clustered mode
- Global - in particular across threads
- Access to the data of a Rack/Sinatra request (`env`) from Plain Ol' Ruby Classes

# Motivation
This was prompted by frustrations in dealing with [Faraday](https://github.com/lostisland/faraday) middleware within - which was inspired by Rack itself - that needed to access data received in Sinatra requests.

In this stack, sessions were parsed from HTTP headers via Rack middleware, and made available to Sinatra as part of the `env` variable that Rack relies on its middleware stack to propagate results of previously run middleware - for each request.

As part of handling that response, I needed Faraday to send third-party HTTP requests, and write the request, response - and, crucially, session ID - to a persistent log.

The session was readily available inside of Sinatra controllers/endpoints that had run the middleware. But annoyingly, when Faraday ran its logging middleware - it was impossible to get ahold of Sinatra/Rack's `env` - it works like a global within the framework, but is inaccessible outside.

# Staring at the abyss of options
1. ...Perhaps Faraday can live inside of the `env` of each Sinatra request? I'd recreate all my Faraday connections each time whether I need them or not. Ugh. I refuse to be forced into inefficiency out of lack of options. I sometimes *choose* it because it's simpler and efficient enough, thank you very much.

2. Perhaps... I can still re-create my Faraday objects on each request, but individually in each endpoint? I hate it. I have a massive application, self-contained, unit-tested utility classes, and Faraday is created deeply-nested inside of them, cached. Why can't I even in principle avoid unnecessary garbage collection?

3. Maybe I can avoid Faraday middleware, and log each API call individually? How [WET](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) can it be, really?... hmmmm ummmmm, no, thank you.

4. Ok, I want to try to play by the rules of Sinatra. Deep in its tiny bowels lives the Delegator https://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb#L1919 - a clever-ish class that breaks the standard Ruby function call/messaging paradigm (and programmer expectations), and redirects requests sent to an object to Sinatra's Application class. I guess maybe I can have a singleton application, so the class can send a message to its instance, and that will have the env. Muahaha. No.

5. How about. On each request. Sinatra sets. A class-level variable in Faraday... with the Rack environment... oh god, no.

6. Ok, Sinatra utilizes what is basically a global, except it cleverly conceals it from Plain Ol' Ruby Object world. Can I use a global? If I can use a global, there are millions of viable-feeling solutions to consider.

Maybe I'm just not creative enough.

# Can I use a global?
## No
Programmers hate globals.

E.g. I've heard an argument that it diminishes reusability, breaks modularity. I hope it's comically obvious that options (1) and (2) try so hard to avoid a global - only to completely decimate any hope of decoupling otherwise standalone Faraday request logic from Rack's middleware framework.

I hope (3) is not tempting for anyone. Perhaps in a better world we can have some artisinal hand-crafted logging for each individual third-party API request, but my application sends hundreds of different API requests - it's just not worth it. Would you rather copy+paste 20 lines of the same code all over the place like a 4-year-old, or be a man, go against the grain, and declare a $global?

Sorry about (4). That was not my best moment. I won't take it back. Sinatra offers desperately little guidance for dealing with its internals - and lacks foresight to support these requirements; maybe it's just not the right tool for this type of application. It's like a hammer, when I need a computer - or, actually - a flexible unintrusive web framework that doesn't mutilate underlying language features.

So the thing about (5) is - it's a global. A singleton (4 too), a class-level variable, a static variable - they are all globals. I'll prove it. Right here in this repository.

## Maybe?
Maybe I just get frustrated too easily. Maybe I have a life to live. Girls. Maybe I just haven't figured out the elegant way to do this. In that case, I'm sorry. Let's be friends - enlighten me.

## Yes
Ok let's get down and dirty.

Globals are a problem for multi-threadedness.

But... Rack isn't multi-threaded; neither is [Sinatra](https://stackoverflow.com/questions/6278817/is-sinatra-multi-threaded/6282999#6282999)!. Whew.

Jokes aside, our stack is run with Puma.

Soo - if I declare a global in Puma - will the child threads see it and share it? What if the global is defined on a child thread - will it also be shared with the parent process, siblings, and all children?

Uhh Puma also has got not just a thread pool, but cluster mode too. A whole cluster of processes. Each with its own threads. Cool. Gonna make it work with elegance and grace.

Ok... rough. I'm down to try a global. Sinatra does it, but lies about it, and twists the language to manipulate your heart into believing it is a light, unopinionated framework, as it coddles its non-local environment semantics in Ruby's hyper-reflexive self-modifying shadows of metaprogramming... I'm just going to be up front about it; be a man, like my grandpa taught me - grow a beard, embrace my actual programming language without spaghettifying its call stack: declare a global - and get to the bottom of exactly how they interact with multi-threaded multi-cluster Puma running a Rack stack with Sinatric sugar.

LET'S DO THIS.

I should really just change frameworks.

# Experiments and results
I'm going to go in order of increasing complexity and variety.

## Rack is single-threaded
The most basic rack app is single-threaded. To prove that I in fact am sane - and to establish a baseline of expectations - I ran a [simple rack application](01_rack_threaded_requests/config.ru) with `rackup`, and ran a plain Ruby multi-threaded process against it.

Each GET request to Rack increments a global variable - which I print, prefixed with its thread ID. Both the thread ID and immediate value of the global are returned from the HTTP request.

In the multi-threaded client, each thread just calls the GET endpoint on a loop, and accumulates results (ThreadID+Value when called). After the loop is done, each client thread prints _its_ thread ID, and the values it accumulated.

E.g. if the server-side global starts at 0, and we have 3 threads with 3 requests, we should end up at 9. Fingers crossed!

Server side output
```bash
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
vim /Users/alexey/.asdf/shims/rackup

### Which just does this...
exec /opt/homebrew/opt/asdf/libexec/bin/asdf exec "rackup" "$@"
```

Whatever. I'm sure it's fine. I'm sure Puma is righteously spinning up its extra allowed threads to deal with my multi-threaded client. Here's the result if I run 1 thread with 5 requests:

```bash
780: 1
780: 2
780: 3
780: 4
780: 5
```

Yup. Same thing with 1 thread + 25 requests. Maakes seense. Puma. Already. I was gonna go slow.

In fact, I'ma slow down:

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

And yeah, no matter how many threads/requests the client throws at it, the `Thread.current.object_id` is table:
```bash
# Trust me, I tried more.
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

Alright. And the baseline for the client shall be:

```bash
============ 60 ==========
800 => 1, 800 => 4, 800 => 7
============ 80 ==========
800 => 2, 800 => 5, 800 => 8
============ 100 ==========
800 => 3, 800 => 6, 800 => 9
````

Makes sense... a bit too orderly. It does faithfully randomize with a few more values:
```bash
============ 100 ==========
760 => 2, 760 => 5, 760 => 8, 760 => 10, 760 => 13, 760 => 16, 760 => 19, 760 => 22
============ 80 ==========
760 => 3, 760 => 6, 760 => 9, 760 => 12, 760 => 14, 760 => 18, 760 => 21, 760 => 23
============ 60 ==========
760 => 1, 760 => 4, 760 => 7, 760 => 11, 760 => 15, 760 => 17, 760 => 20, 760 => 24
```

Now I'm ready for the good stuff.

## Rack + Puma
Suppose we launch
