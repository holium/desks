/-  sur=rooms-v2
=<  [sur .]
=,  sur
|%
++  max-occupancy      6
++  max-rooms          256
::
::
++  enjs
  =,  enjs:format
  |%
  ++  signal-action
    |=  act=^signal-action
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.act
    ?-  -.act
        %signal
      %-  pairs
      :~
        ['from' s+(scot %p from.act)]
        ['to' s+(scot %p to.act)]
        ['rid' s+rid.act]
        ['data' s+data.act]
      ==
    ==
  ::
  ++  reaction
    |=  rct=reaction:sur
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.rct
    ?-  -.rct
        %room-entered 
      %-  pairs
      :~
        ['rid' %s rid.rct]
        ['ship' %s (scot %p ship.rct)]
      ==
        %room-left 
      %-  pairs
      :~
        ['rid' %s rid.rct]
        ['ship' %s (scot %p ship.rct)]
      ==
      ::
        %room-created
      %-  pairs
      ['room' (room:encode room.rct)]~
      ::
        %room-updated
      %-  pairs
      ['rooms' (room:encode room.rct)]~
      ::
        %room-deleted
      %-  pairs
      ['rid' %s rid.rct]~
      ::
        %provider-changed
      %-  pairs
      :~
        ['provider' %s (scot %p provider.rct)]
        ['rooms' (rooms:encode rooms.rct)]
      ==
      ::
        %invited
      %-  pairs
      :~
        ['provider' %s (scot %p provider.rct)]
        ['rid' %s rid.rct]
        ['title' %s title.rct]
        ['invitedBy' %s (scot %p ship.rct)]
      ==
      ::
        %kicked
      %-  pairs
      :~
        ['rid' %s rid.rct]
        ['ship' %s (scot %p ship.rct)]
      ==
      ::
        %chat-received 
      %-  pairs
      :~
        ['from' %s (scot %p from.rct)]
        ['content' %s content.rct]
      ==
    ==
  ++  view
    |=  vi=view:sur
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.vi
    ?-  -.vi
        %session
      (session:encode session-state.vi)
      ::
        %room
      (room:encode room.vi)
      ::
        %provider
      s+(scot %p ship.vi)
    ==
  --
::
++  encode
  =,  enjs:format
  |%
  ++  session
    |=  ses=session-state:sur
    ^-  json
    %-  pairs
    :~
      ['provider' s+(scot %p provider.ses)]
      ['current' (current current.ses)]
      ['rooms' (rooms rooms.ses)]
    ==
  ::
  ++  rooms
    |=  =rooms:sur
    ^-  json
    %-  pairs
    %+  turn  ~(tap by rooms)
      |=  [=rid:sur =room:sur]
      ^-  [cord json]
      [rid (room:encode room)]
  ::
  ++  room
    |=  =room:sur
    ^-  json
    %-  pairs
    :~
      ['rid' s+rid.room]
      ['provider' s+(scot %p provider.room)]
      ['creator' s+(scot %p creator.room)]
      ['access' s+access.room]
      ['title' s+title.room]
      ['present' (set-ship present.room)]
      ['whitelist' (set-ship whitelist.room)]
      ['capacity' (numb capacity.room)]
      ['path' ?~(path.room ~ s+u.path.room)]
    ==
  ++  set-ship
    |=  ships=(set @p)
    ^-  json
    :-  %a
    %+  turn
      ~(tap in ships)
      |=  her=@p
      s+(scot %p her)
  ::
  ++  current
    |=  current=(unit @t)
    ^-  json
    ?~  current
      ~
    s+u.current
    
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  signal-action
    |=  jon=json
    ^-  ^signal-action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~
        [%signal signal]
      ==
    ::
    ++  signal
      %-  ot
      :~  [%from patp]
          [%to patp]
          [%rid so]
          [%data so]
      ==
    ++  patp
      (su ;~(pfix sig fed:ag))
  ::
    ::
  --
  ++  session-action
    |=  jon=json
    ^-  ^session-action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%set-provider patp]
          [%reset-provider ul]
          [%create-room add]
          [%edit-room edit]
          [%delete-room so]
          [%enter-room so]
          [%leave-room so]
          [%invite invite]
          [%kick kick]
          [%send-chat so]
      ==
    ++  patp
      (su ;~(pfix sig fed:ag))
    :: ::
    ++  add
      %-  ot
      :~  [%rid so]
          [%access access]
          [%title so]
          [%path (mu so)]
      ==
    ::
    ++  edit
      %-  ot
      :~  [%rid so]
          [%title so]
          [%access access]
      ==
    ::
    ++  invite
      %-  ot
      :~  [%rid so]
          [%ship patp]
      ==
    ++  kick
      %-  ot
      :~  [%rid so]
          [%ship patp]
      ==
    ++  access
      |=  =json
      ^-  ^access
      ?>  ?=(%s -.json)
      ?:  =('private' p.json)
        %private
      ?:  =('public' p.json)
        %public
      !!
    ::
    ++  spc-pth
      %-  ot
      :~  [%ship patp]
          [%space so]
      ==
     
    ::
    --
  ::
  ++  provider-action
    |=  jon=json
    ^-  provider-action:sur
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%set-online bo]
          [%ban patp]
          [%unban patp]
      ==
    ::
    ++  patp
      (su ;~(pfix sig fed:ag))
    ::
    --
  --
--
