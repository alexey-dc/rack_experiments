require_relative("../lib/thread_safe_kv.rb")

$thread_safe_kv ||= State::ThreadSafeKv.new

