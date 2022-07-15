class Poro
    @@kv_store = {}
    @@shared_key_store = {}

    def self.kv_store
      @@kv_store
    end

    def self.shared_key_store
      @@shared_key_store
    end
end
