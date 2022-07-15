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

    def delete(k)
      store.delete(k)
    end

    def clear_for_thread
      @stores.delete Thread.current.object_id
    end

    def store_count
      @stores.length
    end

    private
    def store
      # basically each thread gets its own storage
      @stores[Thread.current.object_id] ||= {}
    end
  end
end
