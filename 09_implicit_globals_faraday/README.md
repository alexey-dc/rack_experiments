## Fiber locals for storing Sinatra env data
So it looks like thread/fiber storage is a viable way to share data within the scope of an entire thread.

## Conclusion
It seems like Fiber Local Storage is able to pass data to Faraday's middleware from Sinatra successfully.

## Client logs
```
+-------------------------------------------+
|   05 threads     -       05 requests      |
+-------------------------------------------+
============ 140 ==========
{"http_response"=>"From middleware (thread 1620): very_secret_data_33", "secret"=>"very_secret_data_33", "thread_id"=>1620}
{"http_response"=>"From middleware (thread 1740): very_secret_data_195", "secret"=>"very_secret_data_195", "thread_id"=>1740}
{"http_response"=>"From middleware (thread 1580): very_secret_data_775", "secret"=>"very_secret_data_775", "thread_id"=>1580}
{"http_response"=>"From middleware (thread 1740): very_secret_data_105", "secret"=>"very_secret_data_105", "thread_id"=>1740}
{"http_response"=>"From middleware (thread 1560): very_secret_data_464", "secret"=>"very_secret_data_464", "thread_id"=>1560}
============ 80 ==========
{"http_response"=>"From middleware (thread 1700): very_secret_data_209", "secret"=>"very_secret_data_209", "thread_id"=>1700}
{"http_response"=>"From middleware (thread 1820): very_secret_data_155", "secret"=>"very_secret_data_155", "thread_id"=>1820}
{"http_response"=>"From middleware (thread 1880): very_secret_data_794", "secret"=>"very_secret_data_794", "thread_id"=>1880}
{"http_response"=>"From middleware (thread 1820): very_secret_data_525", "secret"=>"very_secret_data_525", "thread_id"=>1820}
{"http_response"=>"From middleware (thread 2020): very_secret_data_225", "secret"=>"very_secret_data_225", "thread_id"=>2020}
============ 120 ==========
{"http_response"=>"From middleware (thread 1740): very_secret_data_623", "secret"=>"very_secret_data_623", "thread_id"=>1740}
{"http_response"=>"From middleware (thread 1880): very_secret_data_509", "secret"=>"very_secret_data_509", "thread_id"=>1880}
{"http_response"=>"From middleware (thread 1700): very_secret_data_257", "secret"=>"very_secret_data_257", "thread_id"=>1700}
{"http_response"=>"From middleware (thread 1700): very_secret_data_282", "secret"=>"very_secret_data_282", "thread_id"=>1700}
{"http_response"=>"From middleware (thread 1580): very_secret_data_500", "secret"=>"very_secret_data_500", "thread_id"=>1580}
============ 60 ==========
{"http_response"=>"From middleware (thread 1560): very_secret_data_160", "secret"=>"very_secret_data_160", "thread_id"=>1560}
{"http_response"=>"From middleware (thread 1620): very_secret_data_559", "secret"=>"very_secret_data_559", "thread_id"=>1620}
{"http_response"=>"From middleware (thread 1700): very_secret_data_761", "secret"=>"very_secret_data_761", "thread_id"=>1700}
{"http_response"=>"From middleware (thread 1880): very_secret_data_833", "secret"=>"very_secret_data_833", "thread_id"=>1880}
{"http_response"=>"From middleware (thread 1820): very_secret_data_449", "secret"=>"very_secret_data_449", "thread_id"=>1820}
============ 100 ==========
{"http_response"=>"From middleware (thread 1580): very_secret_data_106", "secret"=>"very_secret_data_106", "thread_id"=>1580}
{"http_response"=>"From middleware (thread 2020): very_secret_data_260", "secret"=>"very_secret_data_260", "thread_id"=>2020}
{"http_response"=>"From middleware (thread 1880): very_secret_data_93", "secret"=>"very_secret_data_93", "thread_id"=>1880}
{"http_response"=>"From middleware (thread 1820): very_secret_data_232", "secret"=>"very_secret_data_232", "thread_id"=>1820}
{"http_response"=>"From middleware (thread 1620): very_secret_data_699", "secret"=>"very_secret_data_699", "thread_id"=>1620}
```
