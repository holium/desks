/-  store=profile
=<  [store .]
=,  store
|%
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~
          [%save-opengraph-image save-opengraph-image]
          [%set-key set-key]
      ==
    ::
    ++  save-opengraph-image
      |=  jon=json
      ?>  ?=([%o *] jon)
      [[~zod ~2000.1.1] (deog jon)]
    ::
    ++  set-key
      |=  jon=json
      ?>  ?=([%o *] jon)
      [[~zod ~2000.1.1] (dek jon)]
    ::
    ++  deog
      %-  ot
      :~  [%img so]
      ==
    ::
    ++  dek
      %-  ot
      :~  [%device-id so]
          [%key so]
      ==
    --
  --
::
++  enjs
  =,  enjs:format
  |%
    ::
    ++  en-vent
      |=  =vent
      ^-  json
      ?-  -.vent
        %ack        s/%ack
      ==
  --
--