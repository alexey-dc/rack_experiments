## Implicit globals
Ruby's classes automatically occupy the [Top Level Namespace](https://www.rubydoc.info/stdlib/core/toplevel), which is a special kind of global namespaces, distinct from [explicit global variables](https://www.geeksforgeeks.org/global-variable-in-ruby/) that start with `$`.

The Top Level Namespace is accessed via the `::` operator. Any module or class defined as just
```ruby
module NewModule
end

class NewClass
end
```

gets added to the Top Level Namespace - i.e. it is global, and explicitly addresable as `::NewModule` and `::NewClass`, e.g.
```ruby
module SomeModule
  class NewClass
    def initialze

    end

    def compare
      puts ::NewClass == NewClass # would not be equal...
    end
  end
end

nc = SomeModule::NewClass.new
nc.compare # Prints "false"
```

Are top level namespaces shared across threads? E.g. if not, we could store data on a global class, like `Faraday`.

## Setup
This test creates a Plain Old Ruby Object (PORO) with class-level variable hashes.

On each thread request, those class-level hashes get values stored into them: one store is keyed off the thread ID, the other off the same key every time.

There's a random delay in the response to increase the probability that threads interleave during a reponse.

## Conclusion
It does seem like data on Class-level data is shared across threads the same way global data is shared - but storing data on the thread's ID is sufficient to avoid collisions across threads.

=> Storing data on class-level variables/relying on the Top Level Namespace - is the same as storing data in a global.

## Client output
```
+-------------------------------------------+
|   10 threads     -       05 requests      |
+-------------------------------------------+
============ 80 ==========
{"kv_store"=>"very_secret_data_937", "shared_key_store"=>"very_secret_data_59", "secret"=>"very_secret_data_937", "thread_id"=>1540}
{"kv_store"=>"very_secret_data_645", "shared_key_store"=>"very_secret_data_645", "secret"=>"very_secret_data_645", "thread_id"=>1540}
{"kv_store"=>"very_secret_data_945", "shared_key_store"=>"very_secret_data_528", "secret"=>"very_secret_data_945", "thread_id"=>1540}
{"kv_store"=>"very_secret_data_442", "shared_key_store"=>nil, "secret"=>"very_secret_data_442", "thread_id"=>1540}
{"kv_store"=>"very_secret_data_598", "shared_key_store"=>"very_secret_data_674", "secret"=>"very_secret_data_598", "thread_id"=>1540}
============ 140 ==========
{"kv_store"=>"very_secret_data_254", "shared_key_store"=>"very_secret_data_506", "secret"=>"very_secret_data_254", "thread_id"=>1600}
{"kv_store"=>"very_secret_data_733", "shared_key_store"=>nil, "secret"=>"very_secret_data_733", "thread_id"=>1600}
{"kv_store"=>"very_secret_data_792", "shared_key_store"=>"very_secret_data_788", "secret"=>"very_secret_data_792", "thread_id"=>1600}
{"kv_store"=>"very_secret_data_662", "shared_key_store"=>"very_secret_data_854", "secret"=>"very_secret_data_662", "thread_id"=>1600}
{"kv_store"=>"very_secret_data_422", "shared_key_store"=>"very_secret_data_769", "secret"=>"very_secret_data_422", "thread_id"=>1600}
============ 160 ==========
{"kv_store"=>"very_secret_data_24", "shared_key_store"=>"very_secret_data_442", "secret"=>"very_secret_data_24", "thread_id"=>1560}
{"kv_store"=>"very_secret_data_19", "shared_key_store"=>"very_secret_data_436", "secret"=>"very_secret_data_19", "thread_id"=>1560}
{"kv_store"=>"very_secret_data_793", "shared_key_store"=>"very_secret_data_499", "secret"=>"very_secret_data_793", "thread_id"=>1560}
{"kv_store"=>"very_secret_data_267", "shared_key_store"=>nil, "secret"=>"very_secret_data_267", "thread_id"=>1560}
{"kv_store"=>"very_secret_data_289", "shared_key_store"=>"very_secret_data_289", "secret"=>"very_secret_data_289", "thread_id"=>1600}
============ 200 ==========
{"kv_store"=>"very_secret_data_33", "shared_key_store"=>"very_secret_data_838", "secret"=>"very_secret_data_33", "thread_id"=>1640}
{"kv_store"=>"very_secret_data_506", "shared_key_store"=>"very_secret_data_149", "secret"=>"very_secret_data_506", "thread_id"=>1640}
{"kv_store"=>"very_secret_data_310", "shared_key_store"=>"very_secret_data_310", "secret"=>"very_secret_data_310", "thread_id"=>1640}
{"kv_store"=>"very_secret_data_506", "shared_key_store"=>"very_secret_data_793", "secret"=>"very_secret_data_506", "thread_id"=>1640}
{"kv_store"=>"very_secret_data_676", "shared_key_store"=>"very_secret_data_126", "secret"=>"very_secret_data_676", "thread_id"=>1640}
============ 120 ==========
{"kv_store"=>"very_secret_data_505", "shared_key_store"=>"very_secret_data_183", "secret"=>"very_secret_data_505", "thread_id"=>1700}
{"kv_store"=>"very_secret_data_55", "shared_key_store"=>"very_secret_data_676", "secret"=>"very_secret_data_55", "thread_id"=>1700}
{"kv_store"=>"very_secret_data_788", "shared_key_store"=>"very_secret_data_79", "secret"=>"very_secret_data_788", "thread_id"=>1700}
{"kv_store"=>"very_secret_data_800", "shared_key_store"=>"very_secret_data_800", "secret"=>"very_secret_data_800", "thread_id"=>1700}
{"kv_store"=>"very_secret_data_499", "shared_key_store"=>"very_secret_data_420", "secret"=>"very_secret_data_499", "thread_id"=>1700}
============ 100 ==========
{"kv_store"=>"very_secret_data_700", "shared_key_store"=>"very_secret_data_945", "secret"=>"very_secret_data_700", "thread_id"=>1580}
{"kv_store"=>"very_secret_data_838", "shared_key_store"=>"very_secret_data_733", "secret"=>"very_secret_data_838", "thread_id"=>1580}
{"kv_store"=>"very_secret_data_243", "shared_key_store"=>"very_secret_data_201", "secret"=>"very_secret_data_243", "thread_id"=>1580}
{"kv_store"=>"very_secret_data_736", "shared_key_store"=>"very_secret_data_422", "secret"=>"very_secret_data_736", "thread_id"=>1580}
{"kv_store"=>"very_secret_data_953", "shared_key_store"=>"very_secret_data_259", "secret"=>"very_secret_data_953", "thread_id"=>1540}
============ 60 ==========
{"kv_store"=>"very_secret_data_623", "shared_key_store"=>"very_secret_data_243", "secret"=>"very_secret_data_623", "thread_id"=>1620}
{"kv_store"=>"very_secret_data_528", "shared_key_store"=>"very_secret_data_792", "secret"=>"very_secret_data_528", "thread_id"=>1620}
{"kv_store"=>"very_secret_data_44", "shared_key_store"=>"very_secret_data_598", "secret"=>"very_secret_data_44", "thread_id"=>1620}
{"kv_store"=>"very_secret_data_436", "shared_key_store"=>nil, "secret"=>"very_secret_data_436", "thread_id"=>1620}
{"kv_store"=>"very_secret_data_769", "shared_key_store"=>nil, "secret"=>"very_secret_data_769", "thread_id"=>1620}
============ 220 ==========
{"kv_store"=>"very_secret_data_162", "shared_key_store"=>"very_secret_data_55", "secret"=>"very_secret_data_162", "thread_id"=>1660}
{"kv_store"=>"very_secret_data_149", "shared_key_store"=>"very_secret_data_506", "secret"=>"very_secret_data_149", "thread_id"=>1660}
{"kv_store"=>"very_secret_data_201", "shared_key_store"=>nil, "secret"=>"very_secret_data_201", "thread_id"=>1660}
{"kv_store"=>"very_secret_data_120", "shared_key_store"=>nil, "secret"=>"very_secret_data_120", "thread_id"=>1660}
{"kv_store"=>"very_secret_data_126", "shared_key_store"=>nil, "secret"=>"very_secret_data_126", "thread_id"=>1580}
============ 240 ==========
{"kv_store"=>"very_secret_data_185", "shared_key_store"=>nil, "secret"=>"very_secret_data_185", "thread_id"=>1680}
{"kv_store"=>"very_secret_data_725", "shared_key_store"=>nil, "secret"=>"very_secret_data_725", "thread_id"=>1680}
{"kv_store"=>"very_secret_data_854", "shared_key_store"=>"very_secret_data_120", "secret"=>"very_secret_data_854", "thread_id"=>1680}
{"kv_store"=>"very_secret_data_79", "shared_key_store"=>nil, "secret"=>"very_secret_data_79", "thread_id"=>1680}
{"kv_store"=>"very_secret_data_259", "shared_key_store"=>"very_secret_data_534", "secret"=>"very_secret_data_259", "thread_id"=>1640}
============ 180 ==========
{"kv_store"=>"very_secret_data_59", "shared_key_store"=>"very_secret_data_725", "secret"=>"very_secret_data_59", "thread_id"=>1720}
{"kv_store"=>"very_secret_data_183", "shared_key_store"=>"very_secret_data_662", "secret"=>"very_secret_data_183", "thread_id"=>1720}
{"kv_store"=>"very_secret_data_674", "shared_key_store"=>nil, "secret"=>"very_secret_data_674", "thread_id"=>1720}
{"kv_store"=>"very_secret_data_420", "shared_key_store"=>nil, "secret"=>"very_secret_data_420", "thread_id"=>1660}
{"kv_store"=>"very_secret_data_534", "shared_key_store"=>nil, "secret"=>"very_secret_data_534", "thread_id"=>1600}```
```


## Server output
```
1540 wrote value to shared key very_secret_data_937
1560 wrote value to shared key very_secret_data_24
1580 wrote value to shared key very_secret_data_700
1600 wrote value to shared key very_secret_data_254
1620 wrote value to shared key very_secret_data_623
1640 wrote value to shared key very_secret_data_33
1660 wrote value to shared key very_secret_data_162
1680 wrote value to shared key very_secret_data_185
1700 wrote value to shared key very_secret_data_505
1720 wrote value to shared key very_secret_data_59
1540 deleting value from shared key very_secret_data_59
1540 wrote value to shared key very_secret_data_645
1540 deleting value from shared key very_secret_data_645
1540 wrote value to shared key very_secret_data_945
1580 deleting value from shared key very_secret_data_945
1580 wrote value to shared key very_secret_data_838
1640 deleting value from shared key very_secret_data_838
1640 wrote value to shared key very_secret_data_506
1600 deleting value from shared key very_secret_data_506
1600 wrote value to shared key very_secret_data_733
1580 deleting value from shared key very_secret_data_733
1580 wrote value to shared key very_secret_data_243
1620 deleting value from shared key very_secret_data_243
1620 wrote value to shared key very_secret_data_528
1540 deleting value from shared key very_secret_data_528
1540 wrote value to shared key very_secret_data_442
1560 deleting value from shared key very_secret_data_442
1680 deleting value from shared key
1560 wrote value to shared key very_secret_data_19
1680 wrote value to shared key very_secret_data_725
1720 deleting value from shared key very_secret_data_725
1720 wrote value to shared key very_secret_data_183
1700 deleting value from shared key very_secret_data_183
1700 wrote value to shared key very_secret_data_55
1660 deleting value from shared key very_secret_data_55
1660 wrote value to shared key very_secret_data_149
1640 deleting value from shared key very_secret_data_149
1640 wrote value to shared key very_secret_data_310
1640 deleting value from shared key very_secret_data_310
1640 wrote value to shared key very_secret_data_506
1660 deleting value from shared key very_secret_data_506
1660 wrote value to shared key very_secret_data_201
1580 deleting value from shared key very_secret_data_201
1600 deleting value from shared key
1580 wrote value to shared key very_secret_data_736
1600 wrote value to shared key very_secret_data_792
1620 deleting value from shared key very_secret_data_792
1540 deleting value from shared key
1620 wrote value to shared key very_secret_data_44
1540 wrote value to shared key very_secret_data_598
1620 deleting value from shared key very_secret_data_598
1620 wrote value to shared key very_secret_data_436
1560 deleting value from shared key very_secret_data_436
1560 wrote value to shared key very_secret_data_793
1640 deleting value from shared key very_secret_data_793
1640 wrote value to shared key very_secret_data_676
1700 deleting value from shared key very_secret_data_676
1700 wrote value to shared key very_secret_data_788
1600 deleting value from shared key very_secret_data_788
1600 wrote value to shared key very_secret_data_662
1720 deleting value from shared key very_secret_data_662
1720 wrote value to shared key very_secret_data_674
1540 deleting value from shared key very_secret_data_674
1680 deleting value from shared key
1680 wrote value to shared key very_secret_data_854
1600 deleting value from shared key very_secret_data_854
1600 wrote value to shared key very_secret_data_422
1580 deleting value from shared key very_secret_data_422
1660 deleting value from shared key
1540 wrote value to shared key very_secret_data_953
1660 wrote value to shared key very_secret_data_120
1680 deleting value from shared key very_secret_data_120
1680 wrote value to shared key very_secret_data_79
1700 deleting value from shared key very_secret_data_79
1700 wrote value to shared key very_secret_data_800
1700 deleting value from shared key very_secret_data_800
1700 wrote value to shared key very_secret_data_499
1560 deleting value from shared key very_secret_data_499
1620 deleting value from shared key
1560 wrote value to shared key very_secret_data_267
1620 wrote value to shared key very_secret_data_769
1600 deleting value from shared key very_secret_data_769
1560 deleting value from shared key
1600 wrote value to shared key very_secret_data_289
1600 deleting value from shared key very_secret_data_289
1660 deleting value from shared key
1580 wrote value to shared key very_secret_data_126
1640 deleting value from shared key very_secret_data_126
1720 deleting value from shared key
1660 wrote value to shared key very_secret_data_420
1700 deleting value from shared key very_secret_data_420
1680 deleting value from shared key
1640 wrote value to shared key very_secret_data_259
1540 deleting value from shared key very_secret_data_259
1620 deleting value from shared key
1580 deleting value from shared key
1660 deleting value from shared key
1600 wrote value to shared key very_secret_data_534
1640 deleting value from shared key very_secret_data_534
1600 deleting value from shared key
```

[Next experiment](../08_implicit_globals_thread/README.md)
