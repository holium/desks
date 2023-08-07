::  app/chat-db.hoon
/-  *versioned-state, sur=chat-db
/+  dbug, db-lib=chat-db
=|  state-2
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
    =/  default-state=state-2
      [%2 *paths-table:sur *messages-table:sur *peers-table:sur *del-log:sur]
    :_  this(state default-state)
    [%pass /timer %arvo %b %wait next-expire-time:core]~
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    :: we remove the old timer (if any) and add the new one, so that
    :: we don't get an increasing number of timers associated with
    :: this agent every time the agent gets updated
    =/  default-cards
      [[%pass /timer %arvo %b %rest next-expire-time:core] [%pass /timer %arvo %b %wait next-expire-time:core] ~]
    ?-  -.old
      %0  
        =/  new  [%1 paths-table-1.old messages-table-1.old peers-table-1.old *del-log-1:sur]
        (on-load !>(new))

      %1
        =/  paths
          %-  ~(gas by *paths-table:sur)
          %+  turn
            ~(tap by paths-table-1.old)
          |=  kv=[k=path v=path-row-1:sur]
          ^-  [k=path:sur v=path-row:sur]
          [
            k.kv
            [
              path.v.kv
              metadata.v.kv
              type.v.kv
              created-at.v.kv
              updated-at.v.kv
              pins.v.kv
              invites.v.kv
              peers-get-backlog.v.kv
              max-expires-at-duration.v.kv
              created-at.v.kv :: set received-at to be the created-at, since we don't actually know when it was recieved
            ]
          ]

        =/  peers
          %-  ~(gas by *peers-table:sur)
          %+  turn
            ~(tap by peers-table-1.old)
          |=  kv=[k=path v=(list peer-row-1:sur)]
          ^-  [k=path:sur v=(list peer-row:sur)]
          =/  peers=(list peer-row:sur)
            %+  turn
              v.kv
            |=  p=peer-row-1:sur
            ^-  peer-row:sur
            [
              path.p
              patp.p
              role.p
              created-at.p
              updated-at.p
              created-at.p :: set received-at to be the created-at, since we don't actually know when it was recieved
            ]
          [
            k.kv
            peers
          ]

        =/  msgs
          %+  gas:msgon
            *messages-table:sur
          %+  turn
            (tap:msgon-1 messages-table-1.old)
          |=  kv=[k=uniq-id:sur v=msg-part-1:sur]
          ^-  [k=uniq-id:sur v=msg-part:sur]
          [
            k.kv
            [
              path.v.kv
              msg-id.v.kv
              msg-part-id.v.kv
              content.v.kv
              reply-to.v.kv
              metadata.v.kv
              created-at.v.kv
              updated-at.v.kv
              expires-at.v.kv
              created-at.v.kv :: set received-at to be the created-at, since we don't actually know when it was recieved
            ]
          ]
        =/  new-state  [
          %2
          paths
          msgs
          peers
          *del-log:sur :: technically we don't NEED to wipe this in order to upgrade... but who cares about the delete log.
        ]
        [default-cards this(state new-state)]
      %2  [default-cards this(state old)]
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%chat-db-action mark)
    =/  act  !<(action:sur vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      :: paths-table pokes
      %create-path 
        (create-path:db-lib +.act state bowl)
      %edit-path
        (edit-path:db-lib +.act state bowl)
      %edit-path-pins
        (edit-path-pins:db-lib +.act state bowl)
      %leave-path 
        (leave-path:db-lib +.act state bowl)
      :: messages-table pokes
      %insert
        (insert:db-lib +.act state bowl)
      %insert-backlog
        (insert-backlog:db-lib +.act state bowl)
      %edit
        (edit:db-lib +.act state bowl)
      %delete
        (delete:db-lib +.act state bowl)
      %delete-backlog
        (delete-backlog:db-lib +.act state bowl)
      :: peers-table pokes
      %add-peer
        (add-peer:db-lib +.act state bowl)
      %kick-peer
        (kick-peer:db-lib +.act state bowl)
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
          :::~  [%give %fact ~ chat-db-dump+!>(tables+all-tables:core)]
          ::==
          ~  :: we are not "priming" these subscriptions with anything, since the client can just scry if they need. the sub is for receiving new updates
      :: /db/messages/start/~zod/~2023.1.17..19.50.46..be0e
        [%db %messages %start @ @ ~]  :: the "recent messages" path
          ::=/  sender=@p       `@p`(slav %p i.t.t.t.path)
          ::=/  timestamp=@da   `@da`(slav %da i.t.t.t.t.path)
          ::[%give %fact ~ chat-db-dump+!>([%tables [[%messages (start:from:db-lib `msg-id:sur`[timestamp sender] messages-table.state)] ~]])]~
          ~  :: we are not "priming" these subscriptions with anything, since the client can just scry if they need. the sub is for receiving new updates
      :: /db/path/the/actual/path/here
        [%db %path *]  :: the "path" path, subscribe by path explicitly
          =/  thepathrow   (~(get by paths-table.state) t.t.path)
          :~  [%give %fact ~ chat-path-row+!>(thepathrow)]
          ==
      :: /chat-vent/~2000.1.1
        [%chat-vent @ ~] :: poke response comes on this path
          ~
    ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    ::
      [%x %db ~]
        ``chat-db-dump+!>(tables+all-tables:core)
    ::
      [%x %db %paths ~]
        ``chat-db-dump+!>(tables+[[%paths paths-table.state] ~])
    ::
      [%x %db %path *]
        =/  thepath  t.t.t.path
        =/  thepathrow  (~(got by paths-table.state) thepath)
        ``chat-db-dump+!>([%tables [[%paths (malt (limo ~[[thepath thepathrow]]))] ~]])
    ::
      [%x %db %peers ~]
        ``chat-db-dump+!>([%tables [[%peers peers-table.state] ~]])
    ::
    :: .^(* %gx /(scot %p our)/chat-db/(scot %da now)/db/peers-for-path/a/path/to/a/chat/noun)
      [%x %db %peers-for-path *]
        =/  thepath  t.t.t.path
        =/  thepeers  (~(got by peers-table.state) thepath)
        ``chat-db-dump+!>([%tables [[%peers (malt (limo ~[[thepath thepeers]]))] ~]])
    ::
      [%x %db %messages-for-path *]
        =/  thepath  t.t.t.path
        =/  msgs=messages-table:sur  (path-msgs:from:db-lib messages-table.state thepath)
        ``chat-db-dump+!>(tables+[messages+msgs ~])
    ::
      [%x %db %message-count-for-path *]
        =/  thepath  t.t.t.path
        =/  count=@ud  (path-msgs-count:from:db-lib messages-table.state thepath)
        ``ud+!>(count)
    ::
      [%x %db %messages ~]
        ``chat-db-dump+!>(tables+[messages+messages-table.state ~])
    ::
    :: /db/start-ms/<time>.json
    :: all tables, but only with received-at after <time> (updated on
    :: both create and update)
      [%x %db %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.path)
        =/  msgs            messages+(start:from:db-lib timestamp messages-table.state)
        =/  paths           paths+(path-start:from:db-lib timestamp paths-table.state)
        =/  peers           peers+(peer-start:from:db-lib timestamp peers-table.state)
        ``chat-db-dump+!>(tables+[msgs paths peers ~])
    ::
    :: /db/start-ms/<messages-time>/<paths-time>/<peers-time>.json
    :: all tables, but only with received-at after <time>,
    :: allowing you to specify a different timestamp for each table
      [%x %db %start-ms @ @ @ ~]
        =/  msgs-t=@da      (di:dejs:format n+i.t.t.t.path)
        =/  paths-t=@da     (di:dejs:format n+i.t.t.t.t.path)
        =/  peers-t=@da     (di:dejs:format n+i.t.t.t.t.t.path)
        ?:  &(=(0 msgs-t) =(0 paths-t) =(0 peers-t))
          ``chat-db-dump+!>(tables+all-tables:core)  :: if all 3 timestamps are 0, just return the whole tables, don't bother actually filtering them
        =/  msgs            messages+(start:from:db-lib msgs-t messages-table.state)
        =/  paths           paths+(path-start:from:db-lib paths-t paths-table.state)
        =/  peers           peers+(peer-start:from:db-lib peers-t peers-table.state)
        ``chat-db-dump+!>(tables+[msgs paths peers ~])
    ::
    :: /db/paths/start-ms/<time>.json
      [%x %db %paths %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.t.path)
        =/  paths           paths+(path-start:from:db-lib timestamp paths-table.state)
        ``chat-db-dump+!>(tables+[paths ~])
    ::
    :: /db/peers/start-ms/<time>.json
      [%x %db %peers %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.t.path)
        =/  peers           peers+(peer-start:from:db-lib timestamp peers-table.state)
        ``chat-db-dump+!>(tables+[peers ~])
    ::
      [%x %db %messages %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.t.path)
        ``chat-db-dump+!>(tables+[messages+(start:from:db-lib timestamp messages-table.state) ~])
    ::
      [%x %db %messages %start-ms @ %path *]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.t.path)
        =/  thepath  t.t.t.t.t.t.path
        =/  timeboxed=messages-table:sur    (start:from:db-lib timestamp messages-table.state)
        =/  msgs=messages-table:sur         (path-msgs:from:db-lib timeboxed thepath)
        ``chat-db-dump+!>(tables+[messages+msgs ~])
    ::
    :: /db/start/<time>.json
    :: all tables, but only with received-at after <time>
      [%x %db %start @ ~]
        =/  timestamp=@da   `@da`(slav %da i.t.t.t.path)
        =/  msgs            messages+(start:from:db-lib timestamp messages-table.state)
        =/  paths           paths+(path-start:from:db-lib timestamp paths-table.state)
        =/  peers           peers+(peer-start:from:db-lib timestamp peers-table.state)
        ``chat-db-dump+!>(tables+[msgs paths peers ~])
    ::
    :: /db/paths/start/<time>.json
      [%x %db %paths %start @ ~]
        =/  timestamp=@da   `@da`(slav %da i.t.t.t.t.path)
        =/  paths           paths+(path-start:from:db-lib timestamp paths-table.state)
        ``chat-db-dump+!>(tables+[paths ~])
    ::
    :: /db/peers/start/<time>.json
      [%x %db %peers %start @ ~]
        =/  timestamp=@da   `@da`(slav %da i.t.t.t.t.path)
        =/  peers           peers+(peer-start:from:db-lib timestamp peers-table.state)
        ``chat-db-dump+!>(tables+[peers ~])
    ::
    ::  USE THIS ONE FOR PRECISE msg-id PINPOINTING
      [%x %db %messages %start @ @ ~]
        =/  timestamp=@da   `@da`(slav %da i.t.t.t.t.path)
        =/  sender=@p       `@p`(slav %p i.t.t.t.t.t.path)
        ``chat-db-dump+!>(tables+[messages+(start-lot:from:db-lib `msg-id:sur`[timestamp sender] messages-table.state) ~])
    ::
      [%x %db %message @ @ ~]
        =/  timestamp=@da   `@da`(slav %da i.t.t.t.path)
        =/  sender=@p       `@p`(slav %p i.t.t.t.t.path)
        ``chat-db-message+!>((get-full-message:db-lib messages-table.state [timestamp sender]))
    ::
      [%x %delete-log %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.path)
        ``chat-del-log+!>((lot:delon:sur del-log.state ~ `timestamp))
    ==
  :: chat-db does not subscribe to anything.
  :: chat-db does not care
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    `this
  ::
  ++  on-leave
    |=  path
      `this
  ::
  ::  only used for behn timers
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  wire  !!
      [%timer ~]
        =/  st-ch  (expire-old-msgs:db-lib state now.bowl)
        =.  state  s.st-ch
        [
          :: we remove the old timer (if any) and add the new one, so that
          :: we don't get an increasing number of timers associated with
          :: this agent every time the agent gets updated
          :-
          [%give %fact (limo [/db ~]) chat-db-change+!>(ch.st-ch)]
          [[%pass /timer %arvo %b %rest next-expire-time:core] [%pass /timer %arvo %b %wait next-expire-time:core] ~]
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
++  next-expire-time  `@da`(add (mul (div now.bowl ~m1) ~m1) ~m1)  :: TODO decide on actual timer interval
++  all-tables
  [[%paths paths-table.state] [%messages messages-table.state] [%peers peers-table.state] ~]
--
