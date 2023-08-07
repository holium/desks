::  app/notif-db.hoon
/-  *notif-versioned-state, sur=notif-db, db-sur=chat-db
/+  dbug, db-lib=notif-db, cdb-lib=chat-db
=|  state-0
=*  state  -
:: ^-  agent:gall
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      core   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  default-state=state-0
      [%0 0 *notifs-table:sur *del-log:sur]
    =/  cards=(list card)
    :~  [%pass /db %agent [our.bowl %chat-db] %watch /db]
    ==
    [cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  cards=(list card)
      %+  weld
        ^-  (list card)
        [%pass /selfpoke %agent [our.bowl %notif-db] %poke %notif-db-poke !>([%delete-old-realm-chat-notifs ~])]~
      ^-  (list card)
      ?:  =(wex.bowl ~)
        [%pass /db %agent [our.bowl %chat-db] %watch /db]~
      ~
    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  [cards this(state old)]
    ==
  ::
  ++  on-poke
    :: for access-control, we allow pokes to create notifications from
    :: anywhere, but updating/deleting them can only come from ourselves
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%notif-db-poke mark)
    =/  act  !<(action:sur vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      :: permission-wise, basically others can %create notifs for us,
      :: but only we can manipulate them once created
      :: maybe we will need to allow them to update them...
      %create
        (create:db-lib +.act state bowl)
      %read-id
        ?>  =(src.bowl our.bowl)
        (read-id:db-lib +.act state bowl)
      %read-app
        ?>  =(src.bowl our.bowl)
        (read-app:db-lib +.act state bowl)
      %read-path
        ?>  =(src.bowl our.bowl)
        (read-path:db-lib +.act state bowl)
      %read-all
        ?>  =(src.bowl our.bowl)
        (read-all:db-lib +.act state bowl)
      %dismiss-id
        ?>  =(src.bowl our.bowl)
        (dismiss-id:db-lib +.act state bowl)
      %dismiss-app
        ?>  =(src.bowl our.bowl)
        (dismiss-app:db-lib +.act state bowl)
      %dismiss-path
        ?>  =(src.bowl our.bowl)
        (dismiss-path:db-lib +.act state bowl)
      %update
        ?>  =(src.bowl our.bowl)
        (update:db-lib +.act state bowl)
      %delete
        ?>  =(src.bowl our.bowl)
        (delete:db-lib +.act state bowl)
      %delete-old-realm-chat-notifs
        (delete-old-realm-chat-notifs:db-lib state bowl)
    ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    =/  cards=(list card)
    ::  each path should map to a list of cards
    ?+  path      !!
      ::
        [%db ~]  :: the "everything" path
          ~  :: don't "prime" this path with anything, only give-facts on db changes (pokes)
      ::
        [%new ~]  :: the "new notificaitons only" path
          ~  :: we don't "prime" this path with anything, only give-facts on %create action
    ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    :: TODO notifs since timestamp
    ::
      [%x %db ~]
        ``notif-rows+!>(all-rows:core)
    ::
      [%x %db %unreads ~]
        ``notif-rows+!>(all-unread-rows:core)
    ::
      [%x %db %reads ~]
        ``notif-rows+!>(all-read-rows:core)
    ::
      [%x %db %dismissed ~]
        ``notif-rows+!>(all-dismissed-rows:core)
    ::
      [%x %db %not-dismissed ~]
        ``notif-rows+!>(all-not-dismissed-rows:core)
    ::
      [%x %db %notif @ ~]
        =/  theid    (slav %ud i.t.t.t.path)
        ``notif-rows+!>([(got:notifon notifs-table.state theid) ~])
    ::
      [%x %db %unread-count @ ~]
        =/  theapp    `@tas`i.t.t.t.path
        ``atom+!>((lent (unreads-by-app:core theapp)))
    ::
      [%x %db %path @ *]
        =/  theapp    `@tas`i.t.t.t.path
        =/  thepath   t.t.t.t.path
        ``notif-rows+!>((rows-by-path:core theapp thepath))
    :: /db/type/message/talk/dms/~zod.json
    :: .^(* %gx /(scot %p our)/notif-db/(scot %da now)/db/type/message/talk/dms/~zod/noun)
      [%x %db %type @ @ *]
        =/  thetype   `@tas`i.t.t.t.path
        =/  theapp    `@tas`i.t.t.t.t.path
        =/  thepath   t.t.t.t.t.path
        ``notif-rows+!>((rows-by-type:core theapp thepath thetype))
    ::
    :: notifs since index
      [%x %db %since-index @ ~]
        =/  index=@ud  (ni:dejs:format n+i.t.t.t.path)
        =/  new-rows  
            (turn (tap:notifon:sur (lot:notifon:sur notifs-table.state ~ `index)) val-r:core)
        ``notif-rows+!>(new-rows)
    ::
    :: notifs since index
      [%x %db %since-ms @ ~]
        =/  ms=@da  (di:dejs:format n+i.t.t.t.path)
        =/  new-rows  
          %+  turn
            (skim (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] |((gth created-at.v ms) (gth updated-at.v ms))))
          val-r:core
        ``notif-rows+!>(new-rows)
    ::
      [%x %delete-log %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.path)
        ``notif-del-log+!>((lot:delon:sur del-log.state ~ `timestamp))
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  !!
      [%selfpoke ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            ~&  >>>  "%realm-chat: {<(spat wire)>} selfpoke failed"
            `this
        ==
      [%db ~]
        ?+  -.sign  `this
          %fact
            ?+  p.cage.sign  `this
              %chat-db-change
                =/  thechange=db-change:db-sur  !<(db-change:db-sur q.cage.sign)
                =/  del-paths=(list path)
                  %+  turn
                    %+  skim
                      thechange
                    |=(ch=db-change-type:db-sur =(-.ch %del-paths-row))
                  |=  ch=db-change-type:db-sur
                  ?+  -.ch    !!
                    %del-paths-row    path.ch
                  ==
                =/  del-msgs=(list cord)
                  %+  turn
                    %+  skim
                      thechange
                    |=(ch=db-change-type:db-sur =(-.ch %del-messages-row))
                  |=  ch=db-change-type:db-sur
                  ?+  -.ch    !!
                    %del-messages-row    (msg-id-to-cord:encode:cdb-lib msg-id.uniq-id.ch)
                  ==
                ?:  &(=(0 (lent del-msgs)) =(0 (lent del-paths)))  `this  :: return nothing if no del changes
                =/  notif-ids=(list id:sur)
                (generate-uniq-notif-ids-to-del:db-lib state del-msgs del-paths)
                =/  index=@ud  0
                =/  changes=db-change:sur  ~
                =/  cs=[db-change:sur state-0]
                  |-
                    ?:  =(index (lent notif-ids))
                      [changes state]
                    =/  id=id:sur  (snag index notif-ids)
                    =/  ch=db-change-type:sur  [%del-row id]
                    =.  notifs-table.state  +:(del:notifon:sur notifs-table.state id)
                    =.  del-log.state       (put:delon:sur del-log.state (add now.bowl index) ch)
                    $(index +(index), changes (snoc changes ch))

                =/  ourchange  notif-db-change+!>(-.cs)
                =/  gives  :~
                  [%give %fact [/db ~] ourchange]
                ==
                [gives this(state +.cs)]
            ==
        ==
    ==
  ::
  ++  on-leave
    |=  path
      `this
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    !!
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
++  keyval-to-change
  |=  [key=id:sur val=notif-row:sur]
  [%add-row val]
++  val-r
  |=([k=@ud v=notif-row:sur] v)
++  all-rows
  (turn (tap:notifon:sur notifs-table.state) val-r)
++  all-dismissed-rows
  %+  turn
    (skim (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] dismissed.v))
  val-r
++  all-not-dismissed-rows
  %+  turn
    (skip (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] dismissed.v))
  val-r
++  all-unread-rows
  %+  turn
    (skip (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] read.v))
  val-r
++  all-read-rows
  %+  turn
    (skim (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] read.v))
  val-r
++  unreads-by-app
  |=  app=@tas
  %+  skim
    all-unread-rows
  |=(v=notif-row:sur =(app.v app))
++  rows-by-path
  |=  [app=@tas =path]
  %+  turn
    (notifs-by-path app path)
  val-r
++  rows-by-type
  |=  [app=@tas =path type=@tas]
  %+  turn
    (skim (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(path path.v) =(type type.v))))
  val-r
++  notifs-by-path
  |=  [app=@tas =path]
  (skim (tap:notifon:sur notifs-table.state) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(path path.v))))
--
