## A solution to Sinatra's env vs Faraday middleware
This test introduces a thread-safe key-value storage, which is initialized when Puma first starts up - so the global is shared among all threads and never re-initialised.

Sinatra is set up with a `before` and `after` hook. The `before` hook populates a global key-value store for that thread with Sinatra's env; the `after` hook performs cleanup for all data for that thread - so there are no memory leaks on the occasion that threads get destroyed completely.

Faraday is set up with middleware to read from the global, and it replaces the response body with some value that uses the global.

On each request to `/logged_in_method`, Sinatra makes a Faraday request (to itself). The value the test passes in to Sinatra via `env` headers. The secret is generated randomly as `"very_secret_data_#{rand(1000)}"`.

The client prints the responses from Sinatra it got on each of its threads - it expects to get the source secret sent to Sinatra, as well as the response fetched from Faraday augmented with that secret value.

The server prints how many threads it has in its thread-safe storage before and after each request (on each thread).


### Test output
```
+-------------------------------------------+
|   08 threads     -       03 requests      |
+-------------------------------------------+
============ 80 ==========

{"http_response"=>"From middleware (thread 1620): very_secret_data_601", "secret"=>"very_secret_data_601", "thread_storage_count"=>4}

{"http_response"=>"From middleware (thread 1700): very_secret_data_671", "secret"=>"very_secret_data_671", "thread_storage_count"=>5}

{"http_response"=>"From middleware (thread 1700): very_secret_data_808", "secret"=>"very_secret_data_808", "thread_storage_count"=>6}
============ 120 ==========

{"http_response"=>"From middleware (thread 1560): very_secret_data_963", "secret"=>"very_secret_data_963", "thread_storage_count"=>8}

{"http_response"=>"From middleware (thread 1740): very_secret_data_585", "secret"=>"very_secret_data_585", "thread_storage_count"=>4}

{"http_response"=>"From middleware (thread 1840): very_secret_data_739", "secret"=>"very_secret_data_739", "thread_storage_count"=>6}
============ 160 ==========

{"http_response"=>"From middleware (thread 1600): very_secret_data_93", "secret"=>"very_secret_data_93", "thread_storage_count"=>7}

{"http_response"=>"From middleware (thread 1560): very_secret_data_753", "secret"=>"very_secret_data_753", "thread_storage_count"=>6}

{"http_response"=>"From middleware (thread 1580): very_secret_data_827", "secret"=>"very_secret_data_827", "thread_storage_count"=>7}
============ 200 ==========

{"http_response"=>"From middleware (thread 1640): very_secret_data_980", "secret"=>"very_secret_data_980", "thread_storage_count"=>4}

{"http_response"=>"From middleware (thread 1860): very_secret_data_77", "secret"=>"very_secret_data_77", "thread_storage_count"=>4}

{"http_response"=>"From middleware (thread 1720): very_secret_data_465", "secret"=>"very_secret_data_465", "thread_storage_count"=>5}
============ 180 ==========

{"http_response"=>"From middleware (thread 1540): very_secret_data_641", "secret"=>"very_secret_data_641", "thread_storage_count"=>8}

{"http_response"=>"From middleware (thread 1540): very_secret_data_294", "secret"=>"very_secret_data_294", "thread_storage_count"=>4}

{"http_response"=>"From middleware (thread 1540): very_secret_data_888", "secret"=>"very_secret_data_888", "thread_storage_count"=>4}
============ 100 ==========

{"http_response"=>"From middleware (thread 1580): very_secret_data_219", "secret"=>"very_secret_data_219", "thread_storage_count"=>5}

{"http_response"=>"From middleware (thread 1620): very_secret_data_755", "secret"=>"very_secret_data_755", "thread_storage_count"=>5}

{"http_response"=>"From middleware (thread 1640): very_secret_data_368", "secret"=>"very_secret_data_368", "thread_storage_count"=>3}
============ 140 ==========

{"http_response"=>"From middleware (thread 1680): very_secret_data_770", "secret"=>"very_secret_data_770", "thread_storage_count"=>3}

{"http_response"=>"From middleware (thread 1660): very_secret_data_309", "secret"=>"very_secret_data_309", "thread_storage_count"=>7}

{"http_response"=>"From middleware (thread 1760): very_secret_data_352", "secret"=>"very_secret_data_352", "thread_storage_count"=>2}
============ 60 ==========

{"http_response"=>"From middleware (thread 1660): very_secret_data_742", "secret"=>"very_secret_data_742", "thread_storage_count"=>3}

{"http_response"=>"From middleware (thread 1760): very_secret_data_320", "secret"=>"very_secret_data_320", "thread_storage_count"=>7}

{"http_response"=>"From middleware (thread 1680): very_secret_data_707", "secret"=>"very_secret_data_707", "thread_storage_count"=>1}
```


### Server output
```
[1540] thread count before: 0
[1560] thread count before: 1
[1580] thread count before: 2
[1600] thread count before: 3
[1620] thread count before: 4
[1640] thread count before: 5
[1660] thread count before: 6
[1680] thread count before: 7
[1700] thread count before: 8
[1700] thread count after: 8
[1720] thread count before: 8
[1720] thread count after: 8
[1740] thread count before: 8
[1740] thread count after: 7
[1840] thread count before: 7
[1840] thread count after: 7
[1860] thread count before: 7
[1760] thread count before: 8
[1760] thread count after: 8
[1540] thread count after: 7
[1560] thread count after: 7
[1600] thread count after: 6
[1620] thread count after: 3
[1760] thread count before: 3
[1760] thread count after: 3
[1900] thread count before: 6
[1860] thread count after: 5
[1660] thread count after: 2
[1740] thread count before: 2
[1580] thread count after: 4
[1680] thread count after: 2
[1900] thread count after: 3
[1540] thread count before: 3
[1700] thread count before: 3
[1640] thread count after: 3
[1560] thread count before: 3
[1580] thread count before: 3
[1580] thread count after: 4
[1740] thread count after: 3
[1600] thread count before: 3
[1680] thread count before: 4
[1680] thread count after: 4
[1600] thread count after: 3
[1620] thread count before: 3
[1860] thread count before: 4
[1700] thread count after: 4
[1760] thread count before: 4
[1540] thread count after: 4
[1840] thread count before: 4
[1640] thread count before: 5
[1640] thread count after: 5
[1660] thread count before: 4
[1560] thread count after: 5
[1740] thread count before: 5
[1740] thread count after: 5
[1620] thread count after: 4
[1600] thread count before: 4
[1600] thread count after: 4
[1860] thread count after: 3
[1700] thread count before: 3
[1680] thread count before: 4
[1680] thread count after: 4
[1540] thread count before: 4
[1580] thread count before: 5
[1720] thread count before: 6
[1760] thread count after: 6
[1640] thread count before: 6
[1620] thread count before: 7
[1620] thread count after: 7
[1660] thread count after: 6
[1860] thread count before: 6
[1860] thread count after: 6
[1700] thread count after: 5
[1760] thread count before: 5
[1680] thread count before: 5
[1620] thread count before: 7
[1620] thread count after: 7
[1600] thread count before: 5
[1600] thread count after: 7
[1580] thread count after: 6
[1560] thread count before: 6
[1560] thread count after: 6
[1900] thread count before: 6
[1900] thread count after: 6
[1660] thread count before: 6
[1660] thread count after: 6
[1840] thread count after: 5
[1720] thread count after: 4
[1540] thread count after: 3
[1640] thread count after: 2
[1640] thread count before: 2
[1640] thread count after: 2
[1760] thread count after: 1
[1860] thread count before: 1
[1860] thread count after: 1
[1680] thread count after: 0
```
