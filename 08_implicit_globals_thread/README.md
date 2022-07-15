## Thread storage
Ruby `Thread`  exposes custom storage via [Fiber locals](https://ruby-doc.org/core-2.5.0/Thread.html#class-Thread-label-Fiber-local+vs.+Thread-local):

```ruby
Thread.current[:key1] = value
Thread.current[:key1]

Thread.current.thread_variable_set(:key2, value)
Thread.current.thread_variable_get(:key2)
```

Instead of defining a custom storage class, we could use Fiber locals.

## Conclusion
Thread storage is reliable for storing data global to a thread, and would automatically get cleaned if the thread dies.

## Client logs
```
+-------------------------------------------+
|   10 threads     -       05 requests      |
+-------------------------------------------+
============ 220 ==========
{"thread_current_key"=>"1800-very_secret_data_552+174", "secret"=>"very_secret_data_552", "thread_id"=>1800}
{"thread_current_key"=>"1800-very_secret_data_268+704", "secret"=>"very_secret_data_268", "thread_id"=>1800}
{"thread_current_key"=>"1800-very_secret_data_523+791", "secret"=>"very_secret_data_523", "thread_id"=>1800}
{"thread_current_key"=>"1800-very_secret_data_403+726", "secret"=>"very_secret_data_403", "thread_id"=>1800}
{"thread_current_key"=>"1800-very_secret_data_631+723", "secret"=>"very_secret_data_631", "thread_id"=>1800}
============ 180 ==========
{"thread_current_key"=>"1640-very_secret_data_842+907", "secret"=>"very_secret_data_842", "thread_id"=>1640}
{"thread_current_key"=>"1640-very_secret_data_154+492", "secret"=>"very_secret_data_154", "thread_id"=>1640}
{"thread_current_key"=>"1640-very_secret_data_643+898", "secret"=>"very_secret_data_643", "thread_id"=>1640}
{"thread_current_key"=>"1640-very_secret_data_45+833", "secret"=>"very_secret_data_45", "thread_id"=>1640}
{"thread_current_key"=>"1640-very_secret_data_206+318", "secret"=>"very_secret_data_206", "thread_id"=>1640}
============ 120 ==========
{"thread_current_key"=>"1760-very_secret_data_459+608", "secret"=>"very_secret_data_459", "thread_id"=>1760}
{"thread_current_key"=>"1760-very_secret_data_520+298", "secret"=>"very_secret_data_520", "thread_id"=>1760}
{"thread_current_key"=>"1760-very_secret_data_353+601", "secret"=>"very_secret_data_353", "thread_id"=>1760}
{"thread_current_key"=>"1640-very_secret_data_94+233", "secret"=>"very_secret_data_94", "thread_id"=>1640}
{"thread_current_key"=>"1760-very_secret_data_518+369", "secret"=>"very_secret_data_518", "thread_id"=>1760}
============ 240 ==========
{"thread_current_key"=>"1700-very_secret_data_632+139", "secret"=>"very_secret_data_632", "thread_id"=>1700}
{"thread_current_key"=>"1700-very_secret_data_699+724", "secret"=>"very_secret_data_699", "thread_id"=>1700}
{"thread_current_key"=>"1700-very_secret_data_74+191", "secret"=>"very_secret_data_74", "thread_id"=>1700}
{"thread_current_key"=>"1700-very_secret_data_390+909", "secret"=>"very_secret_data_390", "thread_id"=>1700}
{"thread_current_key"=>"1800-very_secret_data_505+402", "secret"=>"very_secret_data_505", "thread_id"=>1800}
============ 140 ==========
{"thread_current_key"=>"1660-very_secret_data_240+864", "secret"=>"very_secret_data_240", "thread_id"=>1660}
{"thread_current_key"=>"1660-very_secret_data_944+112", "secret"=>"very_secret_data_944", "thread_id"=>1660}
{"thread_current_key"=>"1660-very_secret_data_842+480", "secret"=>"very_secret_data_842", "thread_id"=>1660}
{"thread_current_key"=>"1800-very_secret_data_438+316", "secret"=>"very_secret_data_438", "thread_id"=>1800}
{"thread_current_key"=>"1640-very_secret_data_321+758", "secret"=>"very_secret_data_321", "thread_id"=>1640}
============ 100 ==========
{"thread_current_key"=>"1720-very_secret_data_388+211", "secret"=>"very_secret_data_388", "thread_id"=>1720}
{"thread_current_key"=>"1720-very_secret_data_29+367", "secret"=>"very_secret_data_29", "thread_id"=>1720}
{"thread_current_key"=>"1720-very_secret_data_512+984", "secret"=>"very_secret_data_512", "thread_id"=>1720}
{"thread_current_key"=>"1800-very_secret_data_334+713", "secret"=>"very_secret_data_334", "thread_id"=>1800}
{"thread_current_key"=>"1560-very_secret_data_830+393", "secret"=>"very_secret_data_830", "thread_id"=>1560}
============ 60 ==========
{"thread_current_key"=>"1560-very_secret_data_493+138", "secret"=>"very_secret_data_493", "thread_id"=>1560}
{"thread_current_key"=>"1560-very_secret_data_681+991", "secret"=>"very_secret_data_681", "thread_id"=>1560}
{"thread_current_key"=>"1560-very_secret_data_479+924", "secret"=>"very_secret_data_479", "thread_id"=>1560}
{"thread_current_key"=>"1560-very_secret_data_606+494", "secret"=>"very_secret_data_606", "thread_id"=>1560}
{"thread_current_key"=>"1660-very_secret_data_489+553", "secret"=>"very_secret_data_489", "thread_id"=>1660}
============ 160 ==========
{"thread_current_key"=>"1780-very_secret_data_845+136", "secret"=>"very_secret_data_845", "thread_id"=>1780}
{"thread_current_key"=>"1780-very_secret_data_967+754", "secret"=>"very_secret_data_967", "thread_id"=>1780}
{"thread_current_key"=>"1780-very_secret_data_817+670", "secret"=>"very_secret_data_817", "thread_id"=>1780}
{"thread_current_key"=>"1560-very_secret_data_158+324", "secret"=>"very_secret_data_158", "thread_id"=>1560}
{"thread_current_key"=>"1780-very_secret_data_149+190", "secret"=>"very_secret_data_149", "thread_id"=>1780}
============ 200 ==========
{"thread_current_key"=>"1740-very_secret_data_320+755", "secret"=>"very_secret_data_320", "thread_id"=>1740}
{"thread_current_key"=>"1740-very_secret_data_749+121", "secret"=>"very_secret_data_749", "thread_id"=>1740}
{"thread_current_key"=>"1740-very_secret_data_823+838", "secret"=>"very_secret_data_823", "thread_id"=>1740}
{"thread_current_key"=>"1760-very_secret_data_914+803", "secret"=>"very_secret_data_914", "thread_id"=>1760}
{"thread_current_key"=>"1740-very_secret_data_252+196", "secret"=>"very_secret_data_252", "thread_id"=>1740}
============ 80 ==========
{"thread_current_key"=>"1540-very_secret_data_588+124", "secret"=>"very_secret_data_588", "thread_id"=>1540}
{"thread_current_key"=>"1540-very_secret_data_582+750", "secret"=>"very_secret_data_582", "thread_id"=>1540}
{"thread_current_key"=>"1540-very_secret_data_485+727", "secret"=>"very_secret_data_485", "thread_id"=>1540}
{"thread_current_key"=>"1700-very_secret_data_586+164", "secret"=>"very_secret_data_586", "thread_id"=>1700}
{"thread_current_key"=>"1720-very_secret_data_941+292", "secret"=>"very_secret_data_941", "thread_id"=>1720}
```


## Server logs

```
Before [1540] key: 1540-very_secret_data_588+124
Before [1560] key: 1560-very_secret_data_493+138
Before [1640] key: 1640-very_secret_data_842+907
Before [1660] key: 1660-very_secret_data_240+864
Before [1700] key: 1700-very_secret_data_632+139
Before [1720] key: 1720-very_secret_data_388+211
Before [1740] key: 1740-very_secret_data_320+755
Before [1760] key: 1760-very_secret_data_459+608
Before [1780] key: 1780-very_secret_data_845+136
Before [1800] key: 1800-very_secret_data_552+174
After [1800] key: 1800-very_secret_data_552+174
Before [1800] key: 1800-very_secret_data_268+704
After [1660] key: 1660-very_secret_data_240+864
Before [1660] key: 1660-very_secret_data_944+112
After [1560] key: 1560-very_secret_data_493+138
Before [1560] key: 1560-very_secret_data_681+991
After [1640] key: 1640-very_secret_data_842+907
Before [1640] key: 1640-very_secret_data_154+492
After [1800] key: 1800-very_secret_data_268+704
After [1760] key: 1760-very_secret_data_459+608
Before [1760] key: 1760-very_secret_data_520+298
Before [1800] key: 1800-very_secret_data_523+791
After [1720] key: 1720-very_secret_data_388+211
Before [1720] key: 1720-very_secret_data_29+367
After [1640] key: 1640-very_secret_data_154+492
Before [1640] key: 1640-very_secret_data_643+898
After [1560] key: 1560-very_secret_data_681+991
Before [1560] key: 1560-very_secret_data_479+924
After [1800] key: 1800-very_secret_data_523+791
Before [1800] key: 1800-very_secret_data_403+726
After [1740] key: 1740-very_secret_data_320+755
Before [1740] key: 1740-very_secret_data_749+121
After [1780] key: 1780-very_secret_data_845+136
After [1660] key: 1660-very_secret_data_944+112
Before [1780] key: 1780-very_secret_data_967+754
Before [1660] key: 1660-very_secret_data_842+480
After [1640] key: 1640-very_secret_data_643+898
Before [1640] key: 1640-very_secret_data_45+833
After [1760] key: 1760-very_secret_data_520+298
Before [1760] key: 1760-very_secret_data_353+601
After [1700] key: 1700-very_secret_data_632+139
Before [1700] key: 1700-very_secret_data_699+724
After [1540] key: 1540-very_secret_data_588+124
Before [1540] key: 1540-very_secret_data_582+750
After [1800] key: 1800-very_secret_data_403+726
Before [1800] key: 1800-very_secret_data_631+723
After [1560] key: 1560-very_secret_data_479+924
Before [1560] key: 1560-very_secret_data_606+494
After [1700] key: 1700-very_secret_data_699+724
Before [1700] key: 1700-very_secret_data_74+191
After [1720] key: 1720-very_secret_data_29+367
Before [1720] key: 1720-very_secret_data_512+984
After [1660] key: 1660-very_secret_data_842+480
After [1800] key: 1800-very_secret_data_631+723
Before [1800] key: 1800-very_secret_data_438+316
After [1700] key: 1700-very_secret_data_74+191
After [1740] key: 1740-very_secret_data_749+121
Before [1740] key: 1740-very_secret_data_823+838
Before [1700] key: 1700-very_secret_data_390+909
After [1640] key: 1640-very_secret_data_45+833
Before [1640] key: 1640-very_secret_data_206+318
After [1780] key: 1780-very_secret_data_967+754
Before [1780] key: 1780-very_secret_data_817+670
After [1540] key: 1540-very_secret_data_582+750
Before [1540] key: 1540-very_secret_data_485+727
After [1640] key: 1640-very_secret_data_206+318
After [1760] key: 1760-very_secret_data_353+601
Before [1640] key: 1640-very_secret_data_94+233
After [1640] key: 1640-very_secret_data_94+233
Before [1760] key: 1760-very_secret_data_518+369
After [1800] key: 1800-very_secret_data_438+316
Before [1640] key: 1640-very_secret_data_321+758
After [1560] key: 1560-very_secret_data_606+494
Before [1660] key: 1660-very_secret_data_489+553
After [1700] key: 1700-very_secret_data_390+909
Before [1800] key: 1800-very_secret_data_505+402
After [1760] key: 1760-very_secret_data_518+369
After [1780] key: 1780-very_secret_data_817+670
Before [1560] key: 1560-very_secret_data_158+324
After [1800] key: 1800-very_secret_data_505+402
After [1560] key: 1560-very_secret_data_158+324
Before [1780] key: 1780-very_secret_data_149+190
After [1720] key: 1720-very_secret_data_512+984
Before [1800] key: 1800-very_secret_data_334+713
After [1740] key: 1740-very_secret_data_823+838
Before [1760] key: 1760-very_secret_data_914+803
After [1540] key: 1540-very_secret_data_485+727
Before [1700] key: 1700-very_secret_data_586+164
After [1800] key: 1800-very_secret_data_334+713
Before [1560] key: 1560-very_secret_data_830+393
After [1640] key: 1640-very_secret_data_321+758
After [1560] key: 1560-very_secret_data_830+393
After [1660] key: 1660-very_secret_data_489+553
After [1700] key: 1700-very_secret_data_586+164
Before [1720] key: 1720-very_secret_data_941+292
After [1760] key: 1760-very_secret_data_914+803
Before [1740] key: 1740-very_secret_data_252+196
After [1780] key: 1780-very_secret_data_149+190
After [1740] key: 1740-very_secret_data_252+196
After [1720] key: 1720-very_secret_data_941+292
```

[Next experiment](../09_implicit_globals_faraday/README.md)


