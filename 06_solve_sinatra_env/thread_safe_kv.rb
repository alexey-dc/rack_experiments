module State
  class ThreadSafeKv
    def initialize()
      @stores = {}
    end

    def set(k ,v)
      store[k] = v
    end

    def get(k)
      store[k]
    end


    def store
      # basically each thread gets its own storage
      @stores[Thread.current.object_id] ||= {}
    end
  end
end
