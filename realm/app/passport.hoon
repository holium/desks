::  app/passport.hoon
/-  *passport, db, common
/+  dbug, passport
=|  state-0
=*  state  -
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      core   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  default-state=state-0   *state-0
    =/  default-cards=(list card)  ~
    [default-cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    =/  cards=(list card)  ~
    [cards this(state old)]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%passport-action mark)
    =/  act  !<(action vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      %add-friend
        (add-friend:passport +.act state bowl)
      %get-friend
        (get-friend:passport +.act state bowl)
      %handle-friend-request
        (handle-friend-request:passport +.act state bowl)
      %respond-to-friend-request
        (respond-to-friend-request:passport +.act state bowl)

      %add-link
        (add-link:passport +.act state bowl)
      %receive-contacts
        (receive-contacts:passport +.act state bowl)
      %request-contacts
        (request-contacts:passport state bowl)
      %get     :: for getting someone else's passport via a threadpoke
        (get:passport +.act state bowl)
      %toggle-hide-logs
        (toggle-hide-logs:passport +.act state bowl)
    ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
    ::  each path should map to a list of cards
    ?+  path      !!
      ::
      :: /vent/~zod/~2000.1.1
        [%vent @ @ ~] :: poke response comes on this path
          =/  src=ship  (slav %p i.t.path)
          ?>  =(src src.bowl)
          ~
    ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    ::
      [%x %pending-friends ~]
        =/  contacts=(list contact:common)
        %+  turn
          %+  skim
            ~(val by friends.state)
          |=  =fren
          ^-  ?
          =(%pending status.fren)
        |=  =fren
        ^-  contact:common
        (~(got by peers.state) ship.fren)

        ``contacts+!>(contacts)
    ::
      [%x %passport ~]
        ``passport+!>(state)
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  ~&(wire ~&(sign !!))
      [%remote-scry %callback ~]
        ::~&  >  "remote-scry/callback on-agent {<-.sign>}"
        ::~&  +.sign
        `this
      [%dbpoke ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%db: {<(spat wire)>} dbpoke failed"
            ::~&  >>>  p.sign
            `this
        ==
      [%selfpoke ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%db: {<(spat wire)>} selfpoke failed"
            `this
        ==
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ::~&  "Unsubscribe by: {<src.bowl>} on: {<path>}"
    `this
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  wire  !!
      [%remote-scry %callback ~]
        ::~&  >  "remote-scry/callback on-arvo"
        `this
      [%remote-scry %cullback ~]
        ::~&  >  "remote-scry cullback we culled something"
        ::~&  >  -.sign-arvo
        `this
      [%timer ~]
        [
          :: we remove the old timer (if any) and add the new one, so that
          :: we don't get an increasing number of timers associated with
          :: this agent every time the agent gets updated
          :-  [%pass /timer %arvo %b %rest next-refresh-time:core]
          [%pass /timer %arvo %b %wait next-refresh-time:core]~

          this
        ]
    ==
  ::
  ++  on-fail
    |=  [=term =tang]
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
  --
|_  [=bowl:gall cards=(list card)]
::
++  this  .
++  core  .
++  next-refresh-time  `@da`(add (mul (div now.bowl ~h24) ~h24) ~h24)  :: TODO decide on actual timer interval
++  s1-from-now  `@da`(add (mul (div now.bowl ~s1) ~s1) ~s1)
++  path-to-type
  |=  p=path
  ^-  type:common
  [`@tas`(slav %tas +2:p) `@uvH`(slav %uv +6:p)]
--
