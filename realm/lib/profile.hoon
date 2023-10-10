/-  store=profile-store
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
      ==
    ::
    ++  save-opengraph-image
      |=  jon=json
      :: ^-  [req-id (unit @t)]
      ?>  ?=([%o *] jon)
      :: =/  wallet=(unit json)  (~(get by p.jon) '')
      [[~zod ~2000.1.1] (deog jon)]
    ::
    ++  deog
      %-  ot
      :~  [%img so]
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