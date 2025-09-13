# Rack experiments
These experiments explore certain behavior of [Rack](https://github.com/rack/rack), [Puma](https://puma.io/), [Sinatra](http://sinatrarb.com/):
- Single-threadedness (does each request get processed on just 1 thread which blocks for I/O?)
- Multi-threadedness (to what degree is what data exposed to sibling threads in each framework?)
- Multi-process/clustered mode (when running Puma, what is shared across processes, what can be exposed?)
- Various forms of lobals and their interaction across threads/processes (Top Level Namespace, $-variables, Thread/Fiber storage)
- Access to the data of a Rack/Sinatra request (`env`) from Ruby classes
- Storing data in fiber-local/thread-local storage for cross-application access

# Tl;dr: Experiments and results
Each experiment has a README.md with a premise/observation/conclusion - it helps to read the code in each to understand the setup. The code is similar/incremental across tests, usually just testing 1-2 aspects of behavior.

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
I needed to learn these details when dealing with [Faraday](https://github.com/lostisland/faraday) middleware (itself inspired by Rack) in a context where the middleware needed access to data from individual Sinatra requests.

In this stack, sessions were parsed from HTTP headers via Rack middleware, and made available to Sinatra as part of the `env` variable that Rack relies on in its middleware stack to propagate results of previously run middleware - for each request.

As part of handling that response, Faraday needed to send third-party HTTP requests, and write the request, response - and, importantly, session ID - to a persistent log.

The session was available inside of Sinatra controllers/endpoints that ran the middleware. But when Faraday ran its logging middleware - it was impossible to get ahold of Sinatra/Rack's `env`.

# Basic options of integrating Sinatra data into Faraday
1. Recreate all Faraday connections on each new requests - which can be awkward and inefficient

2. Avoid Faraday middleware, and log each API call individually - would require significant code repetition

3. Set a class-level variable on Faraday on each request - also a bit awkward, maybe a bit too implicit (and still global)

4. Lean on Sinatra's `env` - ensure it is accessible to the application when processing each request

# What to do?
I favored option 4 - which required a thorough understanding of the threading model of Sinatra, Rack, and Puma - to ensure correctness in all execution environments.

# Results/Findings
- Sibling threads share global state
- Child threads share global state with parent
- Top Level Namespace values (e.g. classes/modules) behave the same way as globals and can also be used to store data
- Threads provide a [storage mechanism](https://ruby-doc.org/core-2.5.0/Thread.html#class-Thread-label-Fiber-local+vs.+Thread-local) that can be accessed by any file/module/class/method - but is isolated from other threads
- Any global model (`$`, Top Level Namespace, fiber/thread-locals) can work to share state between Sinatra and Faraday middleware
- Thread-locals and Fiber-locals allow isolating data from across threads, while enabling global access within a thread

# Conclusions
There are several viable approaches to sharing data across the application.

I opted for the solution from experiment 9 - leveraging Fiber/Thread local variables to expose the state of each Sinatra request within the thread it is being processed on.

For more control, a global storage can be initialized when Puma starts. That type of variable can isolate threads by namespace, enable data sharing, and manual memory management - which may be a benefit or a drawback.

