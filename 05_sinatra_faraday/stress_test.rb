require_relative "../shared/init.rb"

require 'net/http'

def http_get(uri)
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri
    request['session_secret'] = "very_secret_data"

    response = http.request request # Net::HTTPResponse object
  end
end


def run_requests(request_count, url)
  tid = Thread.current.object_id
  uri = URI(url)

  results = []
  request_count.times do
    response = JSON.parse(http_get(uri).body)
    results.push response
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


stress_out(1, 1, "http://localhost:9292/logged_in_method")
