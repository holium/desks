/-  api-store
:: /+  lib=api-store
::
|_  creds=store-results:api-store
++  grad  %noun
++  grow
  |%
  ++  noun  creds
  ++  json
    ^-  ^json
    %-  pairs:enjs:format
    :~  ['endpoint' s+endpoint.creds]
        ['accessKeyId' s+access-key-id.creds]
        ['secretAccessKey' s+secret-access-key.creds]
    ==
  --
::
++  grab
  |%
  ++  noun  store-results:api-store
  --
--

