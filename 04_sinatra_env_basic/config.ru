require_relative "../shared/init.rb"
require_relative "./lib/some_poro_helper.rb"

require "sinatra/base"

HTTP_STATUS_OK = 200

class Application < Sinatra::Base
  def initialize
    super
    @poro_helper = SomePoroHelper.new
  end

  get '/logged_in_method' do
    # Where did `env` come from?
    # This is implicit state that resembles a global:
    # It's global to Sinatra's endpoints,
    # but not available outside of sinatra
    secret = env['HTTP_SESSION_SECRET']
    should_print_in_poro = env['HTTP_DEMO_ENV']
    puts("/logged_in_method: requesting external resource")
    @poro_helper.this_method_needs_session_info(should_print_in_poro)

    respond({
      secret_from_headers: secret
    })
  end


  error do
    content_type :json
    status 418 # I _am_ a teapot.

    e = env['sinatra.error']
    {:result => 'error', :message => e.message}.to_json
  end


  def respond(serializable)
    return [
      HTTP_STATUS_OK,
      { "Content-Type" => "application/json" },
      serializable.to_json
    ]
  end


end

run Application.new
