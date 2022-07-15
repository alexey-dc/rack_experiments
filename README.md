# Rack experiments
These experiments explore certain behavior of [Rack](https://github.com/rack/rack), [Puma](https://puma.io/), [Sinatra](http://sinatrarb.com/):
- Single-threadedness
- Multi-threadedness
- Multi-process/clustered mode
- Global - in particular across threads
- Access to the data of a Rack/Sinatra request (`env`) from Plain Ol' Ruby Classes
- Storing data in fiber-local/thread-local storage for cross-application access

# Tl;dr: Experiments and results
I'm going to go in order of increasing complexity and variety.

1. [Rack is single-threaded](01_rack_threaded_requests/README.md)
2. [Puma + Rack](02_puma_basic/README.md)
3. [Puma + Sinatra](03_puma_sinatra/README.md)
4. [Sinatra's env](04_sinatra_env_basic/README.md)
5. [Sinatra's env with Faraday](05_sinatra_faraday/README.md)
6. [Ruby global to pass in Sinatra's env values to Faraday](06_solve_sinatra_env/README.md)
7. [Ruby's Top Level Namespace allows using class variables as globals](07_implicit_globals_poro/README.md)
8. [Threads enable fiber-local and thread-local storage which can be seen application-wide](08_implicit_globals_thread/README.md)
9. [Using fiber storage to expose Sinatra's env to Faraday](09_implicit_globals_faraday/README.md)

# Motivation
This was prompted by frustrations in dealing with [Faraday](https://github.com/lostisland/faraday) middleware within - which was inspired by Rack itself - that needed to access data received in Sinatra requests.

In this stack, sessions were parsed from HTTP headers via Rack middleware, and made available to Sinatra as part of the `env` variable that Rack relies on its middleware stack to propagate results of previously run middleware - for each request.

As part of handling that response, Faraday needed to send third-party HTTP requests, and write the request, response - and, crucially, session ID - to a persistent log.

The session was readily available inside of Sinatra controllers/endpoints that had run the middleware. But annoyingly, when Faraday ran its logging middleware - it was impossible to get ahold of Sinatra/Rack's `env` - it works like a global within the framework, but is inaccessible outside.

# Staring at the abyss of options
1. ...Perhaps I'd recreate all my Faraday connections on each new request? I hate to have my freedom so limited, though: this may imply inefficiency in code architecture, or in CPU cycles. This also risks introducing awkward coupling of Sinatra logic with utility classes it relies on.

2. Maybe I can avoid Faraday middleware, and log each API call individually? A bit too un-DRY for my taste...

3. Perhaps we can set a class-level variable on Faraday on each request? Would this even work?

4. Ok, Sinatra utilizes what is basically a global, except it's concealed from Plain Ol' Ruby Object world. Can I just use a global?

# Can I use a global?
## No
Programmers hate globals.

However, the options I could come up with don't seem any better. Perhaps you have a better idea? If so, would love to hear about it.

E.g. I've heard an argument that globals diminish reusability, break modularity. I hope it's comically obvious that option (1) tries so hard to avoid a global - only to obliviate any hope of decoupling otherwise standalone Faraday request logic from Rack's middleware framework.

(3) is also very global-like - but it's a reasonable option to explore... for that reason.

## Maybe?
Maybe I just give up too easily.  Maybe I just haven't figured out the elegant way to do this. In that case, I'm sorry. Let's be friends - enlighten me.

## Yes
Globals are a problem for multi-threadedness.

But... Rack isn't multi-threaded; neither is [Sinatra](https://stackoverflow.com/questions/6278817/is-sinatra-multi-threaded/6282999#6282999)! Whew.

Jokes aside, our stack is run with Puma.

Soo - if I declare a global in Puma - will the child threads see it and share it? What if the global is defined on a child thread - will it also be shared with the parent process, siblings, and all children?

This project is an attempt to explore all options with using every type of Ruby global for this purpose, and to resolve all uncertainties and open questions.


# Learnings
- Ruby does not have thread-safe integers out of the box (e.g. it does have mutexes out of the box)
  - Many Ruby VMs will have them, e.g. the common and popular YARV
  - Seems foolish to rely on VM implementation details for engineering thread-safe code
- Sibling threads share global state
- Child threads share global state with parent
- Top Level Namespace values (e.g. classes/modules) behave the same way as globals and can also be used to store data
- Threads provide a [storage mechanism](https://ruby-doc.org/core-2.5.0/Thread.html#class-Thread-label-Fiber-local+vs.+Thread-local) that can be accessed by any file/module/class/method - but is isolated from other threads

# Conclusions
There are several viable approaches to sharing data across the application.

Perhaps a good default is Fiber/Thread local variables.

For more control, a global storage can be initialized when Puma starts. That type of variable can isolate threads by namespace, enable data sharing, and manual memory management - which may be a benefit or a drawback.

