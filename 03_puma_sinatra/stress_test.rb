require_relative "../shared/init.rb"

require 'net/http'

def http_get(uri)
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    response = http.request request # Net::HTTPResponse object
  end
end


def run_requests(request_count, url)
  tid = Thread.current.object_id
  uri = URI(url)

  results = []
  request_count.times do
    response = JSON.parse(http_get(uri).body)
    results.push "#{response["thread"]} => #{response["counter"]}"
  end

  puts("============ #{tid} ==========")
  puts results.join(", ")
end

def stress_out(num_threads, requests_per_thread, url)
  threads = []
  n = num_threads
  r = requests_per_thread
  puts("+-------------------------------------------+")
  puts("|   "+ "%02d"% n +" threads     -       "+ "%02d" % r  +" requests      |")
  puts("+-------------------------------------------+")
  num_threads.times do
    threads.push(
      Thread.new { run_requests(requests_per_thread, url) }
    )
  end
  threads.each { |t| t.join }
end


stress_out(60, 300, "http://localhost:9292/thread_safe_increment")
