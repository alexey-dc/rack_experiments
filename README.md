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

6. Ok, Sinatra utilizes what is basically a global, except it's concealed from Plain Ol' Ruby Object world. Can I use a global? If I can use a global, there are millions of viable-feeling solutions to consider.

Maybe I'm just not creative enough.

# Can I use a global?
## No
Programmers hate globals.

E.g. I've heard an argument that it diminishes reusability, breaks modularity. I hope it's comically obvious that options (1) and (2) try so hard to avoid a global - only to completely decimate any hope of decoupling otherwise standalone Faraday request logic from Rack's middleware framework.

I hope (3) is not tempting for anyone. Perhaps in a better world we can have some artisinal hand-crafted logging for each individual third-party API request, but my application sends hundreds of different API requests - it's just not worth it. Would you rather copy+paste 20 lines of the same code all over the place like a 4-year-old, or be a man, go against the grain, and declare a $global?

Sorry about (4). That was not my best moment. I won't take it back. Sinatra offers desperately little guidance for dealing with its internals - and lacks foresight to support these requirements; maybe it's just not the right tool for this type of application. It's like a hammer, when I need a computer - or, actually - a flexible unintrusive web framework that doesn't mutilate underlying language features.

So the thing about (5) is - it's a global. A singleton (4 too), a class-level variable, a static variable - they are all globals. I'll prove it. Right here in this repository.

## Maybe?
Maybe I just give up too easily. Maybe I have a life to live. Maybe I just haven't figured out the elegant way to do this. In that case, I'm sorry. Let's be friends - enlighten me.

## Yes
Ok let's get down and dirty.

Globals are a problem for multi-threadedness.

But... Rack isn't multi-threaded; neither is [Sinatra](https://stackoverflow.com/questions/6278817/is-sinatra-multi-threaded/6282999#6282999)!. Whew.

Jokes aside, our stack is run with Puma.

Soo - if I declare a global in Puma - will the child threads see it and share it? What if the global is defined on a child thread - will it also be shared with the parent process, siblings, and all children?

Uhh Puma also has got not just a thread pool, but cluster mode too. A whole cluster of processes, each with its own threads. Cool. Gonna make it work with elegance and grace.

Ok... rough. I'm down to try a global. Sinatra does it, but lies about it, and twists the language to manipulate your heart into believing it is a light, unopinionated framework, as it coddles its non-local environment semantics in Ruby's hyper-reflexive language-altering shadow of metaprogramming... I'm just going to be up front about it; be a man, like my grandpa taught me - grow a beard, embrace my actual programming language without spaghettifying its call stack: declare a global - and get to the bottom of exactly how they interact with multi-threaded multi-cluster Puma running a Rack stack with Sinatra sugar.

LET'S DO THIS.

I should really just change frameworks.

# Experiments and results
I'm going to go in order of increasing complexity and variety.

1. [Rack is single-threaded](01_rack_threaded_request/README.md)
2. [Puma + Rack](02_puma_basic/README.md)
3. [Puma + Sinatra](03_puma_sinatra/README.md)
4. [Sinatra's env](04_sinatra_env_basic/README.md)
5. [Sinatra's env with Faraday](05_sinatra_faraday/README.md)
6. [Ruby global to pass in Sinatra's env values to Faraday](06_solve_sinatra_env/README.me)


# Disappointments
I thought after Rack left me and I got ambushed by Puma in step (1), I was prepared for the world.

```bash
/Users/alexey/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/net/http.rb:987:in `initialize': Can't assign requested address - connect(2) for "localhost" port 9292 (Errno::EADDRNOTAVAIL)
````

This happens if I scale up the client tests to about `~300x300` - both for Rack and Sinatra.

It's large volume, but maybe Sinatra could have slowed down vs crashing.


# Conclusions
- Ruby does not have thread-safe integers out of the box (e.g. it does have mutexes out of the box)
  - Many Ruby VMs will have them, e.g. the common and popular YARV
  - Seems foolish to rely on VM implementation details for engineering thread-safe code
- Sibling threads share global state
- Child threads share global state with parent
