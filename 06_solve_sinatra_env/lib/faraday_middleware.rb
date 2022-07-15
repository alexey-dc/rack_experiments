class FaradayMiddleware < Faraday::Middleware
  def initialize(app)
    super(app)
    @app = app
  end

  def call(env)
    @app.call(env)
    env.body = "From middleware (thread #{Thread.current.object_id}): " + $thread_safe_kv.get('env')['HTTP_SESSION_SECRET']
  end

end
