::  app/passport.hoon
/-  *passport, db, common
/+  dbug, passport, scries=bedrock-scries
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
    =/  default-cards=(list card)
      :-  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %passport-action !>([%init-our-passport ~])]
      :-  [%pass /db %agent [our.bowl %bedrock] %watch /db] :: watch bedrock for new peers
      ~
    [default-cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    =/  cards=(list card)
      :-  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %passport-action !>([%init-our-passport ~])]
      ?.  =(wex.bowl ~)  ~
      :~  [%pass /db %agent [our.bowl %bedrock] %watch /db]
      ==
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
      %cancel-friend-request  :: for us to cancel a pending request we sent out
        (cancel-friend-request:passport +.act state bowl)
      %revoke-friend-request  :: for another ship to tell us they canceled their request
        (revoke-friend-request:passport state bowl)
      %handle-friend-request
        (handle-friend-request:passport +.act state bowl)
      %respond-to-friend-request
        (respond-to-friend-request:passport +.act state bowl)

      %receive-contacts
        (receive-contacts:passport +.act state bowl)
      %request-contacts
        (request-contacts:passport state bowl)

      %get     :: for getting someone else's passport via a threadpoke
        (get:passport +.act state bowl)
      %get-contact  :: for getting someone else's contact via a threadpoke
        (get-contact:passport +.act state bowl)
      %add-link
        (add-link:passport +.act state bowl)
      %change-contact
        (change-contact:passport +.act state bowl)
      %change-passport
        (change-passport:passport +.act state bowl)

      %toggle-hide-logs
        (toggle-hide-logs:passport +.act state bowl)

      %init-our-passport
        (init-our-passport:passport state bowl)
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
      [%x %contacts ~]
        ``passport-contacts+!>((turn (our-contacts:scries bowl) |=(c=[=id:common @da =contact:common] contact.c)))
    ::
      [%x %friends ~]
        ?.  (test-bedrock-table-existence:scries friend-type:common bowl)
          ``passport-friends+!>(~)
        ``passport-friends+!>((get-friends:scries bowl))
    ::
    :: for getting the list of friend requests you need to respond to
      [%x %pending-friends ~]
        ?.  (test-bedrock-table-existence:scries friend-type:common bowl)
          ``passport-friends+!>(~)
        =/  friends=(list friend:common)
          %+  skim
            (get-friends:scries bowl)
          |=  =friend:common
          ^-  ?
          =(%pending-incoming status.friend)
        ``passport-friends+!>(friends)
    ::
    :: .^([[@p * (unit @t) *] (unit @t) @t *] %gx /=/passport/=/our-passport/noun)
      [%x %our-passport ~]
        ``passport+!>((our-passport:scries bowl))
    ::
      [%x %passport-state ~]
        ``passport-state+!>(state)
    ::
      [%x %template %next-block %metadata-or-root ~]
        =/  op=passport:common  (our-passport:scries bowl)
        ?:  =(0 (lent chain.op))
          =/  p=passport-crypto:common
          [
            'PASSPORT_ROOT'
            0
            0
            now.bowl
            '0x00000000000000000000000000000000'
            [
              [(scot %p our.bowl) ~]
              (malt [(scot %p our.bowl) ['FILL_IN' ~]]~)
              (malt ['FILL_IN' 0]~)
              (malt [(scot %p our.bowl) 1.728]~)
              (malt ['FILL_IN' (scot %p our.bowl)]~)
            ]
            [
              (limo ~['ENTITY_ADD' 'ENTITY_REMOVE' 'KEY_ADD' 'KEY_REMOVE' 'NAME_RECORD_SET'])
              ''
            ]
            [(limo ['NAME_RECORD' ~]) '']
            [144 1.000 'FILL_IN' o+(malt ['NAME_RECORD' o+~]~)]
          ]
          ``passport-template-root+!>(p)
        =/  m=passport-data-link-metadata:common
        [
          ?.  =((lent chain-owner-entities.pki-state.crypto.op) 1)
            'FILL_IN'
          (snag 0 chain-owner-entities.pki-state.crypto.op)
          'FILL_IN'
          1
          'FILL_IN'
          0
          0
          '0x00000000000000000000000000000000'
          ?~(chain.op 0 (dec (lent chain.op)))
          ?:((lth (lent chain.op) 2) '0x00000000000000000000000000000000' hash:(rear chain.op))
          ?~(chain.op 0 (dec (lent chain.op)))
          now.bowl
        ]
        ``passport-template+!>(m)
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
      [%contacts ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%db: {<(spat wire)>} contacts failed"
            ::~&  >>>  p.sign
            `this
        ==
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
      :: bedrock state changes, we only care about %add-peer
      [%db ~]
        ?+    -.sign  `this
          %fact
            ?+    p.cage.sign  `this
              %db-changes
            =/  changes=db-changes:db  !<(db-changes:db q.cage.sign)
            =/  cards=(list card)
            %-  zing
            %+  turn
              %+  skim
                changes
              |=  ch=db-change:db
              ^-  ?
              =(-.ch %add-peer)
            |=  ch=db-change:db
            ^-  (list card)
            ?+  -.ch  ~
              %add-peer
            ?:  =(our.bowl ship.peer.ch)  ~ :: skip ourself, duh
            ~&  >  "sharing our contact with {<ship.peer.ch>}"
            =/  pass=passport:common   (our-passport:scries bowl)
            :: send the new peer a request for his contact
            :~  [%pass /contacts %agent [ship.peer.ch dap.bowl] %poke %passport-action !>([%get-contact [our.bowl now.bowl]])]
            :: and give him our contact
                [%pass /contacts %agent [ship.peer.ch dap.bowl] %poke %passport-action !>([%receive-contacts [[now.bowl contact.pass] ~]])]
            ==
            ==
            [cards this]
            ==
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
