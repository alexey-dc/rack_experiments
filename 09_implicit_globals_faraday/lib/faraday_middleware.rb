class FaradayMiddleware < Faraday::Middleware
  def initialize(app)
    super(app)
    @app = app
  end

  def call(env)
    @app.call(env)
    sinatra_env = Thread.current[:env]
    env.body = "From middleware (thread #{Thread.current.object_id}): " + sinatra_env['HTTP_SESSION_SECRET']
  end

end
