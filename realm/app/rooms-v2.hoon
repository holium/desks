/-  store=rooms-v2
/+  verb, dbug, default-agent, lib=rooms-v2
::
|%
::
+$  versioned-state  $%(state-0)
::
+$  state-0
  $:  %0
      provider=provider-state:store
      session=session-state:store
      active-timer=_|
      signal-tally=(map signal-action:store @)
  ==
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
=|  state-0
=*  state  -
::
^-  agent:gall
::
=<
  |_  =bowl:gall
  +*  this  .
      def  ~(. (default-agent this %|) bowl)
      hol   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =^  cards  state
      abet:init:hol
    [cards this]
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    |=  =vase
    ^-  (quip card:agent:gall agent:gall)
    =/  old=(unit state-0)
      (mole |.(!<(state-0 vase)))
    ?^  old
      `this(state u.old)
    ~&  >>  'nuking old %rooms-v2 state' ::  temporarily doing this for making development easier
    =^  cards  this  on-init
    :_  this
    =-  (welp - cards)
    %+  turn  ~(tap in ~(key by wex.bowl))
    |=  [=wire =ship =term]
    ^-  card
    [%pass wire %agent [ship term] %leave ~]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    |^
    =^  cards  state
    ?+  mark                  (on-poke:def mark vase)
        %rooms-v2-signal
      (action:signal:hol !<(signal-action:store vase))
        %rooms-v2-provider-action
      (provider:action:rooms:hol !<(provider-action:store vase))
        %rooms-v2-session-action
      (session:action:rooms:hol !<(session-action:store vase))
    ==
    [cards this]
    --
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
        [%x %session ~]  ::  ~/scry/rooms/session.json
      ?>  =(our.bowl src.bowl)
      ``rooms-v2-view+!>([%session session.state])
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
    ?+  path                  (on-watch:def path)
      ::
      [%lib ~]
        ?>  (is-our:hol src.bowl)
        [%give %fact [/lib ~] rooms-v2-view+!>([%session session.state])]~
      ::
      [%provider-updates @ ~]  ::  subscribe to updates for a specific provider
        ~&  >>  "{<dap.bowl>}: [on-watch]. {<src.bowl>} subscribing to updates for {<our.bowl>}"
        =/  host      `@p`(slav %p i.t.path)
        ?<  (is-banned:hol src.bowl)
        =/  rooms         rooms.provider.state
        [%give %fact ~ rooms-v2-reaction+!>([%provider-changed host rooms])]~
      ::
    ==
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =/  wirepath  `path`wire
    ?+    wire  (on-agent:def wire sign)
      [%provider-updates @ ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to rooms" ~)  `this
            ~&  >>>  "{<dap.bowl>}: rooms subscription failed"
            `this
          ::
          %kick
            ~&  >  "{<dap.bowl>}: rooms kicked us, resubscribing..."
            =/  host         `@p`(slav %p i.t.wire)
            =/  watch-path    [/provider-updates/(scot %p host)]
            :_  this
            [%pass watch-path %agent [host %rooms-v2] %watch watch-path]~
          ::
          %fact
            ?+    p.cage.sign   (on-agent:def wire sign)
                %rooms-v2-reaction
              =^  cards  state
                (reaction:rooms:hol !<(=reaction:store q.cage.sign))
              [cards this]
            ==
        ==
    ==
  ::
  ++  on-arvo   on-arvo:def
  ::
  ++  on-fail   on-fail:def
  ::
  ++  on-leave  on-leave:def
  --
::
|_  [bol=bowl:gall dek=(list card)]
::
+*  hol  .
++  abet
  ^-  (quip card _state)
  [(flop dek) state]
::
++  init
  ^+  hol
  =/  wire       [/provider-updates/(scot %p our.bol)]
  =/  watch-our  [%pass wire %agent [our.bol %rooms-v2] %watch wire]~
  hol(state [%0 host=provider-init session=session-init | ~], dek (weld watch-our dek))
  ::
  ++  provider-init
    ^-  provider-state:store
    [rooms=[~] online=%.y banned=~]
  ::
  ++  session-init
    ^-  session-state:store
    [provider=our.bol current=~ rooms=[~]]
::
++  signal
  |%
  ++  action
    |=  act=signal-action:store
    ^-  (quip card _state)
    |^
    ?-  -.act
      %signal         (handle-signal +.act)
    ==
    ::
    ++  handle-signal
      |=  [from=ship to=ship rid=cord data=cord]
      ^-  (quip card _state)
      ~&  >  "{<dap.bol>}: signal from {<from>} to {<to>}"
      ?:  =(from our.bol)
        ::  Sending a signal to another ship
        :_  state
        [%pass / %agent [to %rooms-v2] %poke rooms-v2-signal+!>([%signal from to rid data])]~
      ::  Receiving a signal from another ship
      :_  state
      [%give %fact [/lib ~] rooms-v2-signal+!>([%signal from to rid data])]~
    ::
    --
  --
++  rooms
  |%
  ++  action
    |%
    ++  provider
      |=  act=provider-action:store
      ^-  (quip card _state)
      ?-  -.act
        %set-online   (set-online +.act)
        %ban          (ban +.act)
        %unban        (unban +.act)
      ==
      ::
      ++  set-online
        |=  [online=?]
        =.  online.provider.state   online
        `state
      ::
      ++  ban
        |=  [=ship]
        =.  banned.provider.state  (~(put in banned.provider.state) ship)
        `state
      ::
      ++  unban
        |=  [=ship]
        =.  banned.provider.state  (~(del in banned.provider.state) ship)
        `state
      --

    ++  session
      |=  act=session-action:store
      ^-  (quip card _state)
      ?-  -.act
        %set-provider       (set-provider +.act)
        %reset-provider     reset-provider
        %create-room        (create-room +.act)
        %edit-room          (edit-room +.act)
        %delete-room        (delete-room +.act)
        %enter-room         (enter-room +.act)
        %leave-room         (leave-room +.act)
        %invite             `state
        %kick               (handle-kick +.act)
        %send-chat          (handle-send-chat +.act)
      ==
      ::
      ++  set-provider
        |=  new-provider=ship
        =/  old-provider   provider.session.state
        :: if its the same provider, don't change
        ?:  =(new-provider old-provider)  `state
        =/  leave-cards
          ?~  current.session.state  [~]
          [%pass / %agent [old-provider dap.bol] %poke rooms-v2-session-action+!>([%leave-room u.current.session.state])]~
        ::
        =/  old-wire       [/provider-updates/(scot %p old-provider)]
        =/  wire           [/provider-updates/(scot %p new-provider)]
        ::  TODO this log is triggered 4 times when joining a space, why?
        %-  (slog leaf+"{<dap.bol>}: [set-provider]. {<src.bol>} setting provider from {<old-provider>} to {<new-provider>}" ~)
        =/  outgoing-sub-wire-leave-cards
          ^-  (list card)
          %+  murn
            ^-  (list path)
            %~  tap  in
            ^-  (set path)
            %-  %~  run  in
                  ~(key by wex.bol)
            |=  [sub=path =ship =term]
            sub
          |=  =path
          ?+  path  ~
              [%provider-updates @ ~]
            `[%pass path %agent [(slav %p i.t.path) %rooms-v2] %leave ~]
          ==
        :_  state
        %+  weld  outgoing-sub-wire-leave-cards
          %+  weld  leave-cards
            ^-  (list card)
            :~
              [%pass old-wire %agent [old-provider %rooms-v2] %leave ~]
              [%pass wire %agent [new-provider %rooms-v2] %watch wire]
            ==
      ::
      ++  reset-provider
        =/  old-provider            provider.session.state
        =.  provider.session.state  our.bol
        =.  current.session.state   ~
        =.  rooms.session.state     ~
        =/  old-wire       [/provider-updates/(scot %p old-provider)]
        =/  wire           [/provider-updates/(scot %p our.bol)]
        :_  state
        :~
          [%pass old-wire %agent [old-provider %rooms-v2] %leave ~]
          [%pass wire %agent [our.bol %rooms-v2] %watch wire]
        ==
      ::
      ++  create-room
        |=  [=rid:store =access:store =title:store path=(unit cord)]
        ~&  >>  "{<dap.bol>}: [create-room]. {<src.bol>} creating room {<rid>} on provider {<provider.session.state>}"
        ?:  (is-provider:hol provider.session.state src.bol)
          (provider-create-room rid access title path)
        ::  the action is from us and we are not the provider, so send the action to the provider
        (session-create-room rid access title path)
        ::
        ++  session-create-room
          |=  [=rid:store =access:store =title:store path=(unit cord)]
          =/  provider      provider.session.state
          :_  state
          [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%create-room rid access title path])]~
        ::
        ++  provider-create-room
          |=  [=rid:store =access:store =title:store path=(unit cord)]
          ~&  >>  "{<dap.bol>}: [create-room] host. {<src.bol>} creating room {<rid>}"
          ?<  (~(has by rooms.provider.state) rid) :: assert unique room id
          ?>  (lte ~(wyt by rooms.provider.state) max-rooms:lib)
          ::  TODO check if src.bol is allowed to create a room
          =|  =room:store
            =:  rid.room       rid
                provider.room  our.bol
                creator.room   src.bol
                access.room    access
                title.room     title
                capacity.room  max-occupancy:lib
                path.room      path
            ==
          =/  old-room                (get-present-room:helpers:rooms:hol src.bol)
          =.  rooms.provider.state              :: remove old room if it exists
            ?~  old-room  rooms.provider.state
            ?:  =(src.bol creator.u.old-room)   :: creator is leaving the room, so delete it
              (~(del by rooms.provider.state) rid.u.old-room)
            :: if participant is leaving, remove participant
            =.  present.u.old-room    (~(del in present.u.old-room) src.bol)
            (~(put by rooms.provider.state) [rid.u.old-room u.old-room])
          ::
          =/  fact-path               [/provider-updates/(scot %p our.bol) ~]
          =/  delete-cards            ::  prep cards to update delete old rooms by the creator
            ?~  old-room  ~
            ?:  =(src.bol creator.u.old-room)  ::  creator is leaving the room, so delete it
              [%give %fact fact-path rooms-v2-reaction+!>([%room-deleted rid.u.old-room])]~
            [%give %fact fact-path rooms-v2-reaction+!>([%room-left rid.u.old-room src.bol])]~
          =.  present.room            (~(put in present.room) src.bol)        :: enter new room
          =.  whitelist.room          (~(put in whitelist.room) src.bol)      :: creator is always on the whitelist
          =.  rooms.provider.state    (~(put by rooms.provider.state) [rid room])
          :_  state
          %+  weld  delete-cards
            ^-  (list card)
            [%give %fact fact-path rooms-v2-reaction+!>([%room-created room])]~
      ::
      ++  edit-room
        |=  [=rid:store =title:store =access:store]
        =/  provider      provider.session.state
        ::
        ?.  (is-provider:hol provider src.bol)
          :_  state
          [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%edit-room rid title access])]~
        ::
        =/  room                      (~(got by rooms.provider.state) rid)
        ?.  =(src.bol creator.room)   `state  :: only the creator can edit the room
        =.  access.room               access
        =.  title.room                title
        =.  rooms.provider.state      (~(put by rooms.provider.state) [rid room])
        =/  fact-path                 [/provider-updates/(scot %p our.bol) ~]
        :_  state
        [%give %fact fact-path rooms-v2-reaction+!>([%room-updated room])]~
      ::
      ++  delete-room
        |=  =rid:store
        =/  provider      provider.session.state
        ?.  (is-provider:hol provider src.bol)
          :_  state
          [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%delete-room rid])]~
        ::
        ?>  (~(has by rooms.provider.state) rid) ::  room exists
        =/  room   (~(got by rooms.provider.state) rid)
        =/  can-delete
          ?|  (is-creator:hol src.bol rid)
              (is-our:hol src.bol)
          ==
        ?.  can-delete
          ~&  >>>  'cannot delete room - not creator or host'
          `state
        ::
        =.  rooms.provider.state      (~(del by rooms.provider.state) rid)
        =/  fact-path                 [/provider-updates/(scot %p our.bol) ~]
        :_  state
        :~
          [%give %fact fact-path rooms-v2-reaction+!>([%room-deleted rid])]
        ==
      ::
      ++  enter-room
        |=  =rid:store
        =/  provider      provider.session.state
        ?.  (is-provider:hol provider src.bol)
          :_  state
            [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%enter-room rid])]~
        ::
        ?>  (~(has by rooms.provider.state) rid)  ::  room exists
        ?>  (can-enter:hol rid src.bol)       ::  src.bol can enter
        =/  fact-path               [/provider-updates/(scot %p our.bol) ~]
        =/  old-room                (get-present-room:helpers:rooms:hol src.bol)
          =.  rooms.provider.state              :: remove old room if it exists
            ?~  old-room  rooms.provider.state
            ?:  =(src.bol creator.u.old-room)   :: creator is leaving the room, so delete it
              (~(del by rooms.provider.state) rid.u.old-room)
            :: if participant is leaving, remove participant
            =.  present.u.old-room    (~(del in present.u.old-room) src.bol)
            (~(put by rooms.provider.state) [rid.u.old-room u.old-room])
        =/  leave-cards            ::  prep card to leave old room
          ?~  old-room  ~
          ?:  =(src.bol creator.u.old-room)  ::  creator is leaving the room, so delete it
            [%give %fact fact-path rooms-v2-reaction+!>([%room-deleted rid.u.old-room])]~
          [%give %fact fact-path rooms-v2-reaction+!>([%room-left rid.u.old-room src.bol])]~

        =/  room                      (~(got by rooms.provider.state) rid)
        ?>  (lth ~(wyt in present.room) capacity.room)
        =.  present.room              (~(put in present.room) src.bol)
        =.  rooms.provider.state      (~(put by rooms.provider.state) [rid room])
        :_  state
        %+  weld  leave-cards
            ^-  (list card)
        [%give %fact fact-path rooms-v2-reaction+!>([%room-entered rid src.bol])]~
        :: ?.  =(~(wyt by rooms.remove-result) 0)
        ::     =.  rooms.provider.state    rooms.remove-result ::  remove from present rooms
        :: :_  state
        :: %+  weld  cards.remove-result
        ::     ^-  (list card)
        ::     [%give %fact [/provider-updates ~] rooms-v2-reaction+!>([%room-entered rid src.bol])]~

      ::
      ++  leave-room
        |=  =rid:store
        =/  provider      provider.session.state
        ?.  (is-provider:hol provider src.bol)
          :_  state
          [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%leave-room rid])]~
        ::
        ?.  (~(has by rooms.provider.state) rid)  `state  ::  room exists
        :: ?:  (is-present:hol src.bol rid)      `state  ::  src.bol is present
        =/  fact-path                 [/provider-updates/(scot %p our.bol) ~]
        ?:  (is-creator:hol src.bol rid)
          =.  rooms.provider.state    (~(del by rooms.provider.state) rid)
          :_  state
          [%give %fact fact-path rooms-v2-reaction+!>([%room-deleted rid])]~
        ::
        =/  room                  (~(got by rooms.provider.state) rid)
        =.  present.room          (~(del in present.room) src.bol)
        =.  rooms.provider.state      (~(put by rooms.provider.state) [rid room])
        :_  state
        [%give %fact fact-path rooms-v2-reaction+!>([%room-left rid src.bol])]~
      ::
      ++  handle-send-chat
        |=  [content=cord]
        ^-  (quip card _state)
        ?~  current.session.state
            ~&  >>>  'must be in a room to send or receive chat'
            `state
        ?:  =(src.bol our.bol)
          ::  send all present users the chat message
          =/  room    (~(got by rooms.session.state) u.current.session.state)
          =/  peers   (skim ~(tap in present.room) skim-self:helpers:rooms:hol)
          :_  state
          %+  turn  (skim ~(tap in present.room) skim-self:helpers:rooms:hol)
            |=  =ship
            ^-  card
            [%pass / %agent [ship dap.bol] %poke rooms-v2-session-action+!>([%send-chat content])]
        ::  Receiving a signal from another ship
        :_  state
        [%give %fact [/lib ~] rooms-v2-reaction+!>([%chat-received src.bol content])]~
      ::
      ++  handle-kick
        |=  [rid=cord =ship]
        ^-  (quip card _state)
        =/  room                  (~(got by rooms.session.state) rid)
        ?.  (is-our:hol provider.room)
          :_  state
          [%pass / %agent [provider.room dap.bol] %poke rooms-v2-session-action+!>([%kick rid ship])]~
        ::
        ?.  =(creator.room src.bol)  `state
        =.  present.room            (~(del in present.room) ship)
        =.  rooms.provider.state    (~(put by rooms.provider.state) [rid room])
        =/  fact-path               [/provider-updates/(scot %p our.bol) ~]
        :_  state
        :~
          [%give %fact fact-path rooms-v2-reaction+!>([%kicked rid ship])]
        ==
      ::
      --
  ::
  ++  reaction
    |=  [rct=reaction:store]
    ^-  (quip card _state)
    |^
    ::
    ?+  -.rct             `state
      %room-created       (on-created +.rct)
      %room-updated       (on-updated +.rct)
      %room-deleted       (on-deleted +.rct)
      %room-entered       (on-entered +.rct)
      %room-left          (on-left +.rct)
      %provider-changed   (on-provider +.rct)
      :: %present          (on-suite-add +.rct)
      :: %invited          (on-joined +.rct)
      %kicked             (on-kicked +.rct)
    ==
    ::
    ++  on-created
      |=  [=room:store]
      =.  current.session.state
        ::  if we created the room, update our current
        ?:  =(our.bol creator.room)  (some rid.room)  current.session.state
      ~&  >>  "on-created: current={<current.session.state>}"
      =.  rooms.session.state    (~(put by rooms.session.state) [rid.room room])
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%room-created room])]~
    ::
    ++  on-updated
      |=  [=room:store]
      =.  rooms.session.state    (~(put by rooms.session.state) [rid.room room])
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%room-updated room])]~
    ::
    ++  on-deleted
      |=  [=rid:store]
      =.  current.session.state
        ?:  =(current.session.state (some rid))  ~  current.session.state
      =.  rooms.session.state   (~(del by rooms.session.state) rid)
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%room-deleted rid])]~
    ::
    ++  on-entered
      |=  [=rid:store =ship]
      ^-  (quip card _state)
      =.  current.session.state
        ::  if the entered ship is us, update our current
        ?:  =(our.bol ship)  (some rid)  current.session.state
      ::
      ~&  >>  ['on-entered' ship rid]
      =/  room                  (~(got by rooms.session.state) rid)
      =.  present.room          (~(put in present.room) ship)
      =.  rooms.session.state   (~(put by rooms.session.state) [rid room])
      ~&  >>  ['on-entered updated room:' room]
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%room-entered rid ship])]~
    ::
    ++  on-left
      |=  [=rid:store =ship]
      =.  current.session.state
        ::  if the left ship is us, update our current
        ?:
          ?&
            =(our.bol ship)
            =((some rid) current.session.state)
          ==
          ~  current.session.state
      ~&  >>  "on-left: rid={<rid>} ship={<ship>}"
      =/  room                  (~(got by rooms.session.state) rid)
      =.  present.room          (~(del in present.room) ship)
      =.  rooms.session.state   (~(put by rooms.session.state) [rid room])
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%room-left rid ship])]~
    ::
    ++  on-provider
      |=  [provider=ship =rooms:store]
      =.  provider.session.state    provider
      =.  rooms.session.state       rooms
      =.  current.session.state
        ::  if the provider has actually changed, clear our current
        ?:  ?!(=(provider provider.session.state))  ~  current.session.state
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%provider-changed provider rooms])]~
    ::
    ++  on-kicked
      |=  [=rid:store =ship]
      ~&  >>  "on-kicked: rid={<rid>} ship={<ship>}"
      =?  current.session.state  ::  if the left ship is us, update our current
          ?&
            =(our.bol ship)
            =((some rid) current.session.state)
          ==
        ~
      =/  room                  (~(got by rooms.session.state) rid)
      =.  present.room          (~(del in present.room) ship)
      =.  rooms.session.state   (~(put by rooms.session.state) [rid room])
      :_  state
      [%give %fact [/lib ~] rooms-v2-reaction+!>([%kicked rid ship])]~
    ::
    --
  ::
  ++  helpers
    |%
    ++  gen-leave-cards
      |=  [=rid:store provider=ship]
      ^-  (list card)
      ?:  =(current.session.state rid)
        [%pass / %agent [provider dap.bol] %poke rooms-v2-session-action+!>([%leave-room rid])]~
      [~]
    ::
    ++  get-present-room
      |=  =ship
      ^-  (unit room:store)
      =/  rooms=(list room=room:store)
        %+  skim  ~(val by rooms.provider.state)
          |=  =room:store
          (skim-present-rooms ship room)
      ?:  =((lent rooms) 0)  ~
      (some (rear rooms))
    ::
    ++  skim-created-rooms
      |=  [=ship =room:store]
      ^-  ?
      =/  creator  creator.room
      =(ship creator)
    ::
    ++  skim-present-rooms
      |=  [=ship =room:store]
      ^-  ?
      (~(has in present.room) ship)
    ::
    ++  skim-self
      |=  =ship
      ^-  ?
      ?!  =(ship our.bol)
    ::
    --
::
++  can-enter
  |=  [=rid:store =ship]
  ^-  ?
  =/  room      (~(got by rooms.provider.state) rid)
  ?:  =(%private access.room)
    (is-whitelisted:hol room ship)
  %.y
::
++  is-whitelisted
  |=  [=room:store =ship]
  ^-  ?
  (~(has in whitelist.room) ship)
::
++  is-creator
  |=  [=ship =rid:store]
  ^-  ?
  =/  room  (~(get by rooms.provider.state) rid)
  ?~  room  %.n
  =(creator.u.room ship)
::
++  is-banned
  |=  [=ship]
  ^-  ?
  (~(has in banned.provider.state) ship)
::
++  is-present
  |=  [=ship =rid:store]
  ^-  ?
  =/  room    (~(get by rooms.provider.state) rid)
  ?~  room    %.n
  (~(has in present.u.room) ship)
::
++  is-our
  |=  [=ship]
  ^-  ?
  =(our.bol ship)

++  is-provider
  |=  [provider=ship src=ship]
  ^-  ?
  ?|
    ?!(=(src our.bol))  ::  if the action is not from the provider
    =(provider our.bol) ::  if the action is from the provider, and we are the provider
  ==
--
