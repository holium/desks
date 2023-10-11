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
          [%initialize de-init]
          [%save-opengraph-image save-opengraph-image]
      ==
    ::
    ++  de-init
      |=  jon=json
      ^-  [req-id (unit @t)]
      [[~zod ~2000.1.1] ?~(jon ~ (some (so jon)))]
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