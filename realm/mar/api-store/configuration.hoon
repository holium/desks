/-  api-store
:: /+  lib=api-store
::
|_  =store-conf:api-store
++  grad  %noun
++  grow
  |%
  ++  noun  store-conf
  ++  json
    %-
    |=  creds=store-conf:api-store
    ^-  ^json
    %-  pairs:enjs:format
    :~  ['buckets' a+(turn ~(tap in buckets.creds) |=(t=@t s+t))]
        ['currentBucket' s+current-bucket.creds]
        ['region' s+region.creds]
    ==
    store-conf
  --
::
++  grab
  |%
  ++  noun  store-conf:api-store
  --
--

