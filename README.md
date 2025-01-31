# Rack experiments
These experiments explore certain behavior of [Rack](https://github.com/rack/rack), [Puma](https://puma.io/), [Sinatra](http://sinatrarb.com/):
- Single-threadedness
- Multi-threadedness
- Multi-process/clustered mode
- Various forms of lobals and their interaction across threads (Top Level Namespace, $-variables, Thread/Fiber storage)
- Access to the data of a Rack/Sinatra request (`env`) from Plain Ol' Ruby Classes
- Storing data in fiber-local/thread-local storage for cross-application access

# Tl;dr: Experiments and results
These are links to README.md of the individual experiments that describe the premise/observation/conclusion - but it definitely helps to read the code in each to understand the setup. Fortunately, the code is very similar between them, and usually minimal - to test 1-2 specific things.

They build up from foundations (e.g. exploring Rack's initial single-threaded model) to exploring various forms of globals in Ruby and the extent to which they are available across threads: `$` globals, Top Level Namespace, fiber-local. Sinatra's env and its interaction with plain ruby objects is explored, and put into a multi-threded context with globals.

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
This was prompted by frustrations in dealing with [Faraday](https://github.com/lostisland/faraday) middleware (itself inspired by Rack) in a context where the middleware needed access to data from individual Sinatra requests.

In this stack, sessions were parsed from HTTP headers via Rack middleware, and made available to Sinatra as part of the `env` variable that Rack relies on in its middleware stack to propagate results of previously run middleware - for each request.

As part of handling that response, Faraday needed to send third-party HTTP requests, and write the request, response - and, crucially, session ID - to a persistent log.

The session was readily available inside of Sinatra controllers/endpoints that had run the middleware. But annoyingly, when Faraday ran its logging middleware - it was impossible to get ahold of Sinatra/Rack's `env` - it works like a global within the framework, but is inaccessible outside.

# Basic options of integrating Sinatra data into Faraday
1. Recreating all Faraday connections on each new request? This may imply inefficiency in code architecture, or in CPU cycles. This would also introduce awkward coupling of Sinatra logic with utility classes it relies on.

2. Avoid Faraday middleware, and log each API call individually? Would require significant code repetition.

3. Set a class-level variable on Faraday on each request? (still requires understanding how the class level variables interplay with Puma/threading)

4. Lean on Sinatra's semi-global, i.e. the internal `env` that's concealed from the outside world

# What to do?
The options that don't rely on some sort of thread-aware application-wide state are not very comforting to pass Sinatra's request information to parts of the app outside of endpoints like general purpose API request senders.

So - declaring a global in Puma - will the child threads see it and share it? What if the global is defined on a child thread - will it also be shared with the parent process, siblings, and all children?

This project is an attempt to explore all options with using every type of Ruby global for this purpose, and to resolve all uncertainties and open questions.

# Learnings
- Sibling threads share global state
- Child threads share global state with parent
- Top Level Namespace values (e.g. classes/modules) behave the same way as globals and can also be used to store data
- Threads provide a [storage mechanism](https://ruby-doc.org/core-2.5.0/Thread.html#class-Thread-label-Fiber-local+vs.+Thread-local) that can be accessed by any file/module/class/method - but is isolated from other threads
- Any global model (`$`, Top Level Namespace, fiber/thread-locals) can work to share state between Sinatra and Faraday middleware
- Thread-locals and Fiber-locals will encapsulate the global data to the thread, while globals are shared across the entire multi-threaded application.

# Conclusions
There are several viable approaches to sharing data across the application.

Fiber/Thread local variables enable a concise solution.

For more control, a global storage can be initialized when Puma starts. That type of variable can isolate threads by namespace, enable data sharing, and manual memory management - which may be a benefit or a drawback.

