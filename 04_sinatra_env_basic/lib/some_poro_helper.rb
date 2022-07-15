# This class exists outside of Sinatra -
# and thus has no access to Sinatra's environment.
#
# It may not be a problem if a Sinatra endpoint
# instantiates it on each run of an endpoint.
#
# If that can not be done for whatever reason,
# it becomes a bigger problem.
class SomePoroHelper
  def initialize
  end

  def this_method_needs_session_info(print_poro_test)
    # https://www.rubyguides.com/2018/10/defined-keyword/
    if print_poro_test
      puts("----- Accessing Sinatra's env from PORO ----")
      puts defined?(env)
      puts("-------------- Did it work? ^ --------------")
    end
  end
end
