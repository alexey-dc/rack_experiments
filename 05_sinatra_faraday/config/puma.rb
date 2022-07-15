require_relative("../../shared/thread_safe_kv.rb")



$thread_safe_kv ||= State::ThreadSafeKv.new
