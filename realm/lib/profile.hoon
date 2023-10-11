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
          [%register reg]
          [%update-available de-avail]
          [%update-crux de-init]
          [%save-opengraph-image save-opengraph-image]
      ==
    ::
    ++  reg
      ^-  [req-id =ship]
    [[~zod ~2000.1.1] (su ;~(pfix sig fed:ag))]
    ::
    ++  de-avail
      |=  jon=json
      ^-  [req-id (unit ship)]
      [[~zod ~2000.1.1] ?~(jon ~ (some (su ;~(pfix sig fed:ag))))]
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