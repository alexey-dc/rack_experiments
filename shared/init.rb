require 'pry'
require 'pry-nav'
require 'json'

module Rack
  class CommonLogger
    def log(env, status, header, began_at)
      # make rack STFU; our logging middleware takes care of this      
    end
  end
end

