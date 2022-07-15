class FaradayMiddleware < Faraday::Middleware
  def initialize(app)
    super(app)
    @app = app
  end

  def call(env)
    puts("----- Faraday's middleware's env --------------------")
    puts (env)
    puts("------------ @app available to faraday---------------")
    puts(@app)
    puts("-----------------------------------------------------")
    # The idea is that we may need to send API requests that require
    # values from the app's env. That env is not available in Faraday:
    # the env passed to call(env) here is a different unrelated value.
    @app.call(env)
  end
end
