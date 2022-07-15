require 'pry'
require 'pry-nav'
require 'json'

module Rack
  class CommonLogger
    def log(env, status, header, began_at)
      # silence rack's logging that can be over-verbose for the purposes of these experiments
    end
  end
end

