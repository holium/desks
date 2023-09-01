::  db [realm]:
::  TODO:
::  - constraints via paths-table settings
/-  *passport, common
/+  scries=bedrock-scries
|%
::
:: helpers
::
++  req
  |=  [=ship dap=@tas]
  ^-  card
  [%pass /contacts %agent [ship dap] %poke %passport-action !>([%request-contacts ~])]
::
++  maybe-log
  |=  [hide-debug=? msg=tape]
  ?:  =(%.y hide-debug)  ~
  ~&  msg
  ~
::
++  url-encode
  |=  url=@t
  ^-  @t
  =/  trl=tape  (trip url)
  =/  result=tape  ""
  |-
    ?:  =(0 (lent trl))
      (crip result)
    =/  curr=@t  (snag 0 trl)
    =/  char=tape
      ?:  =(curr ':')  "%3A"
      ?:  =(curr '/')  "%2F"
      ?:  =(curr '?')  "%3F"
      ?:  =(curr '#')  "%23"
      ?:  =(curr '[')  "%5B"
      ?:  =(curr ']')  "%5D"
      ?:  =(curr '@')  "%40"
      ?:  =(curr '!')  "%21"
      ?:  =(curr '$')  "%24"
      ?:  =(curr '&')  "%26"
      ?:  =(curr '\'')  "%27"
      ?:  =(curr '(')  "%29"
      ?:  =(curr ')')  "%2A"
      ?:  =(curr '*')  "%2B"
      ?:  =(curr '+')  "%2C"
      ?:  =(curr ',')  "%2D"
      ?:  =(curr ';')  "%3B"
      ?:  =(curr '=')  "%3D"
      ?:  =(curr '%')  "%25"
      ?:  =(curr ' ')  "%20"
      (trip curr)
    %=  $
      trl       +.trl
      result    (weld result char)
    ==
::
++  remove-newlines
  |=  str=@t
  ^-  @t
  =/  tp=tape  (trip str)
  =/  result=tape  ""
  |-
    ?:  =(0 (lent tp))
      (crip result)
    =/  curr=@t  (snag 0 tp)
    %=  $
      tp        +.tp
      result    ?:(=(curr '\0a') result (snoc result curr))
    ==
::
:: pokes
++  receive-contacts
:: our ship gets this from another ship when they are giving us some contacts
::passport &passport-action [%receive-contacts (malt [~zod [~zod [%image ''] ~ [~ 'ZOOOD']]]~)]
  |=  [m=peers state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%receive-contacts: {<m>}")

  :: loop through the ships they sent us
  =/  ships=(list ship)  ~(tap in ~(key by m))
  |-
    ?:  =(0 (lent ships))
      [~ state]
    =/  shp=ship  (snag 0 ships)
    =/  con=contact:common  (~(got by m) shp)
    =.  avatar.con
      ?-  -.avatar.con
          %image
        [%image (url-encode img.avatar.con)]
          %nft
        [%nft (url-encode nft.avatar.con)]
      ==
    %=  $
      :: add to the peers map
      peers.state   (~(put by peers.state) ship.con con)
      ships         +.ships
    ==
::
++  request-contacts
:: our ship gets this from another ship who wants to learn our contacts
::passport &passport-action [%request-contacts ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%request-contacts from {<src.bowl>}")

  =/  ourcontact=contact:common  contact:(our-passport:scries bowl)
  =/  response  !>([%receive-contacts (~(put by peers.state) our.bowl ourcontact)])
  =/  cards=(list card)
    [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action response]~
  [cards state]
::
++  add-friend
::passport &passport-action [%add-friend [our now] ~zod ~]
  |=  [[=req-id =ship mtd=(map @t @t)] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-friend: {<req-id>} {<ship>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  new-fren=fren  [ship %requested %.n mtd]
  =.  friends.state  (~(put by friends.state) ship new-fren)

  =/  cards=(list card)
    :~  [%give %fact ~[vent-path] passport-vent+!>([%ack ~])]
        kickcard
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%get-friend mtd])]
        (req ship dap.bowl)
    ==
  [cards state]
::
++  get-friend
::passport &passport-action [%get-friend ~]
  |=  [mtd=(map @t @t) state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get-friend: {<mtd>} from {<src.bowl>}")

  =/  new-fren=fren  [src.bowl %pending %.n mtd]
  =.  friends.state  (~(put by friends.state) src.bowl new-fren)

  =/  cards=(list card)
    :~  (req src.bowl dap.bowl)
    ==
  [cards state]
::
++  handle-friend-request
::passport &passport-action [%handle-friend-request [our now] %.y ~zod]
  |=  [[=req-id accept=? =ship] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%handle-friend-request: {<req-id>} {<accept>} {<ship>}")
  ?>  =(src.bowl our.bowl) ::only we can accept/reject requests

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  new-fren=fren     (~(got by friends.state) ship)
  =.  status.new-fren   ?:(accept %friend %rejected)
  =.  friends.state     (~(put by friends.state) ship new-fren)

  =/  cards=(list card)
    :~  [%give %fact ~[vent-path] passport-vent+!>([%ack ~])]
        kickcard
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%respond-to-friend-request accept])]
        (req ship dap.bowl)
    ==
  [cards state]
::
++  respond-to-friend-request
::passport &passport-action [%respond-to-friend-request %.y]
  |=  [accept=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%respond-to-friend-request: {<accept>} from {<src.bowl>}")

  =/  new-fren=fren     (~(got by friends.state) src.bowl)
  =.  status.new-fren   ?:(accept %friend %rejected)
  =.  friends.state     (~(put by friends.state) src.bowl new-fren)

  =/  cards=(list card)
    :~  (req src.bowl dap.bowl)
    ==
  [cards state]
::
++  add-link
::passport &passport-action [%add-link passport-link]
  |=  [[=req-id ln=passport-link:common] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-link: {<req-id>} {<ln>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  :: TODO verify the link is valid, then save it to bedrock

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] passport-vent+!>([%link ln])]
    :-  kickcard
    ~
  [cards state]
::
++  get
:: for getting our passport
::passport &passport-action [%get [our now]]
  |=  [=req-id state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get: {<req-id>} from {<src.bowl>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  pass=passport:common   (our-passport:scries bowl)
  =/  ufr=(unit fren)   (~(get by friends.state) src.bowl)
  =/  src-fren=?  ?~(ufr %.n =(%friend status.u.ufr))
  :: only actually give out the passport if we are discoverable
  :: OR we are friends with the requester
  ?>  |(discoverable.pass src-fren)

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] passport-vent+!>([%passport pass])]
    :-  kickcard
    ~
  [cards state]
::
++  toggle-hide-logs
::passport &passport-action [%toggle-hide-logs %.n]
  |=  [toggle=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =.  hide-logs.state  toggle
  `state
::
::
::  JSON
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
      :~  [%add-link add-link]
          ::[%receive-contacts ]
      ==
    ::
    ++  add-link
      |=  jon=json
      ^-  [req-id passport-link:common]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] (de-add-link jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-add-link jon)]
    ::
    ++  de-add-link
      |=  jon=json
      ^-  passport-link:common
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  link-type=@tas   ((se %tas) (gt 'link-type'))
      ?+  link-type  !!
          %edge-remove
        [%edge-remove (so (gt 'link-hash'))]
          %key-remove
        [%key-remove (so (gt 'name'))]
          %name-record-set
        [%name-record-set (so (gt 'name')) (so (gt 'record'))]
      ==
    ::
    ++  de-type
      %+  cu
        path-to-type
      pa
    ::
    ++  path-to-type
      |=  p=path
      ^-  type:common
      [`@tas`(slav %tas +2:p) `@uvH`(slav %uv +6:p)]
    ::
    ::
    ++  de-id
      %+  cu
        path-to-id
      pa
    ::
    ++  path-to-id
      |=  p=path
      ^-  id:common
      [`@p`(slav %p +2:p) `@da`(slav %da +6:p)]
    ::
    ++  de-space-path
      %+  cu
        path-to-space-path
      pa
    ::
    ++  path-to-space-path
      |=  p=path
      ^-  [=ship space=cord]
      [`@p`(slav %p +2:p) `@t`(slav %tas +6:p)]
    ::
    ++  de-ship  (su ;~(pfix sig fed:ag))
    ::
    ++  dri   :: specify in integer milliseconds, returns a @dr
      (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) ni)
    --
  --
::
++  enjs
  =,  enjs:format
  |%
    ++  en-vent
      |=  =vent
      ^-  json
      ?-  -.vent
        %ack    s/%ack
        %passport  ~  :: TODO (en-passport passport.vent)
        %link   ~
      ==
    ::
    ++  state
      |=  st=versioned-state
      ^-  json
      ?-  -.st
          %0
        %-  pairs
        :~  ['state-version' (numb `@`-.st)]
        ==
      ==
    ::
    ++  row-id-to-json
      |=  =id:common
      ^-  json
      s+(row-id-to-cord id)
    ::
    ++  row-id-to-cord
      |=  =id:common
      ^-  cord
      (spat ~[(scot %p ship.id) (scot %da t.id)])
    ::
    ++  en-db-type
      |=  =type:common
      ^-  json
      s+(db-type-to-cord type)
    ::
    ++  db-type-to-cord
      |=  =type:common
      ^-  cord
      (spat ~[(scot %tas name.type) (scot %uv hash.type)])
    ::
    ++  numbrd
      |=  a=@rd
      ^-  json
      :-  %n
      (crip (flop (snip (snip (flop (trip (scot %rd a)))))))
    ::
    ++  time-dr
      |=  a=@dr
      ^-  json
      (numb (mul (div a ~s1) 1.000))
    ::
  --
::
:: state format upgrade helpers
::

:: none yet
--
