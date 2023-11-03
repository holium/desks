::  app/bedrock.hoon
::  - all data is scoped by /path, with a corresponding peers list
::  - ship-to-frontend syncing of data uses chat-db model of /db
::    subscribe wire and /x/db/start-ms/[unix ms].json
::  - %db provides a data layer only. business logic and permissioning
::    must be checked by the %app that uses it (unless it can be fit
::    within the database permissions and constraints system)
::  - custom data types work by %apps specifying the schema for the type
::
::  TO USE:
::  - create a path with a list of peers with %create-path
::    ex: :db &db-action [%create-path /example %host ~ ~ ~ ~[[~zod %host] [~bus %member]]]
::  - create a data-row of a custom or pre-defined type
::    you are required to provide a schema when you first create a row of a new custom-type
::    but if the schema is already there for that type,
::    you can just pass ~ in that spot

/-  *db, sstore=spaces-store, vstore=visas
/+  dbug, db
=|  state-2
=*  state  -
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      core   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  default-state=state-2   *state-2
    :: make sure the relay table exists on-init
    =.  tables.default-state
    (~(gas by *^tables) ~[[relay-type:common *pathed-table] [vote-type:common *pathed-table] [react-type:common *pathed-table]])
    =/  default-cards
      :~  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
          [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%create-initial-spaces-paths ~])]
          [%pass /timer %arvo %b %wait next-refresh-time:core]
          [%pass /keep-alive-timer %arvo %b %wait next-keep-alive-time:core]
      ==
    [default-cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  uold=(unit versioned-state)
      (mole |.(!<(versioned-state old-state)))
    =/  old=versioned-state
    ?~  uold
      ::  types failed to nest, so fallback to empty tables,
      ::  same paths and peers
      =/  old-paths-and-peers     !<(minimal-state old-state)
      ?-  -.old-paths-and-peers
        %0
      =/  default-state=state-0   *state-0
      =.  paths.default-state     paths.old-paths-and-peers
      =.  peers.default-state     peers.old-paths-and-peers
      =.  tables.default-state
      (~(gas by *tables-0) ~[[%relay *pathed-table-0] [%vote *pathed-table-0] [%react *pathed-table-0]])
      default-state
        %1
      =/  default-state=state-1   *state-1
      =.  paths.default-state     paths.old-paths-and-peers
      =.  peers.default-state     peers.old-paths-and-peers
      =.  tables-1.default-state
      (~(gas by *tables-1) ~[[relay-type:common *pathed-table-1] [vote-type:common *pathed-table-1] [react-type:common *pathed-table-1]])
      default-state
        %2
      =/  default-state=state-2   *state-2
      =.  paths.default-state     paths.old-paths-and-peers
      =.  peers.default-state     peers.old-paths-and-peers
      =.  tables.default-state
      (~(gas by *^tables) ~[[relay-type:common *pathed-table] [vote-type:common *pathed-table] [react-type:common *pathed-table]])
      default-state
      ==
    :: types DO nest, so just read it out
    !<(versioned-state old-state)
    :: do a quick check to make sure we are subbed to /updates in %spaces
    =/  cards
      :-  [%pass /timer %arvo %b %rest next-refresh-time:core]
      :-  [%pass /timer %arvo %b %wait next-refresh-time:core]
      :-  [%pass /keep-alive-timer %arvo %b %rest next-keep-alive-time:core]
      :: keep-alive every time we on-load. it'll go back to normal
      :: cadence on its own
      :-  [%pass /keep-alive-timer %arvo %b %wait s1-from-now:core]
      :-  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%create-initial-spaces-paths ~])]
      ?:  (~(has by wex.bowl) [/spaces our.bowl %spaces])
        ~
      [%pass /spaces %agent [our.bowl %spaces] %watch /updates]~
    ?-  -.old
        %0
      =/  new-state=state-1  [
        %1
        (transform-tables-0-to-tables:db tables.old schemas.old)
        (transform-schemas-0-to-schemas:db schemas.old)
        (transform-paths-0-to-paths:db paths.old)
        peers.old
        (transform-del-log-0-to-del-log:db del-log.old schemas.old)
        hide-logs.old
      ]
      (on-load !>(new-state))
        %1
      =/  new-state=state-2  [
        %2
        (transform-tables-1-to-tables:db tables-1.old)
        schemas.old
        paths.old
        peers.old
        del-log.old
        hide-logs.old
      ]
      [cards this(state new-state)]
        %2
      [cards this(state old)]
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%db-action mark)
    =/  act  !<(action vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      %create-path
        (create-path:db +.act state bowl)
      %create-from-space
        (create-from-space:db +.act state bowl)
      %edit-path
        (edit-path:db +.act state bowl)
      %remove-path
        (remove-path:db +.act state bowl)
      %add-peer
        (add-peer:db +.act state bowl)
      %kick-peer
        (kick-peer:db +.act state bowl)
      %keep-alive
        (keep-alive:db +.act state bowl)

      %get-path
        (get-path:db +.act state bowl)
      %delete-path
        (delete-path:db +.act state bowl)
      %put-path
        (put-path:db +.act state bowl)
      %refresh-path
        (refresh-path:db +.act state bowl)

      %create
        (create:db +.act state bowl)
      %create-many
        =|  cards=(list card)
        |-
        ?~  args.act
          [cards state]
        =^  cadz  state
          (create:db i.args.act state bowl)
        $(args.act t.args.act, cards (weld cadz cards))
      %edit
        (edit:db +.act state bowl)
      %remove
        (remove:db +.act state bowl)
      %remove-many
        (remove-many:db +.act state bowl)
      %remove-before
        (remove-before:db +.act state bowl)

      %relay
        (relay:db +.act state bowl)

      %handle-changes
        (handle-changes:db +.act state bowl)

      %create-initial-spaces-paths
        (create-initial-spaces-paths:db state bowl)
      %refresh-chat-paths
        (refresh-chat-paths:db state bowl)
      %toggle-hide-logs
        (toggle-hide-logs:db +.act state bowl)
    ==
    [cards this]
  ::
  :: endpoints for clients to keep in sync with our ship
  :: /db
  :: /path/[path]
  :: endpoints for other ships to keep in sync with us
  :: /next/@da/[path]
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
    ::  each path should map to a list of cards
    ?+  path      !!
      ::
        [%db ~]  :: the "everything" path
          ?>  =(our.bowl src.bowl)
          ~  :: we are not "priming" this subscription with anything, since the client can just scry if they need. the sub is for receiving new updates
      ::
        [%db %common ~]  :: the "common-types only" path
          ?>  =(our.bowl src.bowl)
          ~  :: we are not "priming" this subscription with anything, since the client can just scry if they need. the sub is for receiving new updates
      :: /path/the/actual/path/
        [%path *]  :: the "path" path, subscribe by path explicitly
          ?>  =(our.bowl src.bowl)
          =/  thepathrow    (~(got by paths.state) t.path)
          =/  peerslist     (~(got by peers.state) t.path)
          =/  thechange
           :: TODO also dump all the rows here
            db-changes+!>([[%add-path thepathrow] (turn peerslist |=(p=peer [%add-peer p]))])
          :~  [%give %fact ~ thechange]
          ==
      :: /next/@da/the/actual/path/
        [%next @ *]  :: the "next" path, for other ships to get the next update on a particular path
          ?<  =(our.bowl src.bowl)  :: this path should only be used by NOT us
          =/  t=@da  (slav %da i.t.path)
          =/  thepathrow    (~(got by paths.state) t.t.path)
          :: if the @da they passed was behind, %give them the current version, and %kick them
          ?:  (gth updated-at.thepathrow t)
            :: ~&  >>>  "{<src.bowl>} tried to sub on old @da {<t>}, %kicking them from {<t.t.path>}"
            =/  thepeers    (~(got by peers.state) t.t.path)
            =/  tbls        (tables-by-path:db tables.state t.t.path)
            =/  dels=(list [@da db-del-change])
              (dels-by-path:db t.t.path state)
            :~  [%give %fact ~ db-path+!>([thepathrow thepeers tbls schemas.state dels])]
                [%give %kick [path ~] `src.bowl]
            ==
          :: else, don't give them anything. we will give+kick when a new version happens
          ::=/  thepathrow   (~(get by paths-table.state) t.t.path)
          :::~  [%give %fact ~ chat-path-row+!>(thepathrow)]
          ::==
          ::~&  >  "{(scow %p src.bowl)} subbed to {(spud path)}"
          ~
      :: /vent/~zod/~2000.1.1
        [%vent @ @ ~] :: poke response comes on this path
          =/  src=ship  (slav %p i.t.path)
          ?>  =(src src.bowl)
          ~
    ==
    [cards this]
  ::
  :: endpoints for clients syncing with their own ship
  :: /x/db.json
  :: /x/db/path/[path].json
  :: /x/db/start-ms/[unix ms].json
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    ::
      [%x %db ~]
        ``db-state+!>(state)
    ::
    :: full information about a given path
      [%x %db %path *]
        =/  thepath  t.t.t.path
        =/  thepathrow  (~(got by paths.state) thepath)
        =/  thepeers    (~(got by peers.state) thepath)
        =/  tbls        (tables-by-path:db tables.state thepath)
        =/  dels=(list [@da db-del-change])
          (dels-by-path:db thepath state)
        ``db-path+!>([thepathrow thepeers tbls schemas.state dels])
    ::
    :: all rows from a given table
    ::  /db/table/realm-note/0v6.539qr.dv1ns.thh70.fnqol.fb2us.json
      [%x %db %table *]
        =/  tblname=^path  t.t.t.path
        =/  typ=type:common  (path-to-type:core tblname)
        ``db-table+!>([typ (~(got by tables.state) typ) schemas.state])
    ::
    :: all rows from a given table and path (as a pathed-table in noun form)
    ::  /db/table-by-path/chat/<hash>/<path>.json
      [%x %db %table-by-path @ @ *]
        =/  tblname=@tas  i.t.t.t.path
        =/  typ=type:common   [tblname (slav %uv i.t.t.t.t.path)]
        =/  dbpath        t.t.t.t.t.path
        =/  tbl     (get-tbl:db typ dbpath state)
        ?~  tbl
          ``db-table+!>([typ *pathed-table schemas.state])
        ``db-table+!>([typ (~(put by *pathed-table) dbpath u.tbl) schemas.state])
    ::
    :: a specific row from a given table, by id
    ::  /row/message/0v12jdlk.asdf.12e.s/~zod/~2000.1.1.json
      [%x %row @ @ @ @ ~]
        =/  tblname=@tas  i.t.t.path
        =/  typ=type:common   [tblname (slav %uv i.t.t.t.path)]
        =/  ship=@p       `@p`(slav %p i.t.t.t.t.path)
        =/  t=@da         `@da`(slav %da i.t.t.t.t.t.path)
        =/  therow=row    (~(got by (ptbl-to-tbl:db (~(got by tables.state) typ))) [ship t])
        ``db-row+!>([therow schemas.state])
    ::
    :: test existence of specific row from a given table, by id
    ::  /loobean/row/message/~zod/~2000.1.1/<path>.json
      [%x %loobean %row @ @ @ @ *]
        =/  tblname=@tas      i.t.t.t.path
        =/  typ=type:common   [tblname (slav %uv i.t.t.t.t.path)]
        =/  ship=@p     `@p`(slav %p i.t.t.t.t.t.path)
        =/  t=@da       `@da`(slav %da i.t.t.t.t.t.t.path)
        =/  dbpath                       t.t.t.t.t.t.t.path
        =/  therow=(unit row)    (get-db:db typ dbpath [ship t] state)
        ?~  therow
          ``ud+!>(1)  :: false
        ``ud+!>(0)    :: true, because the pathrow exsits
    ::
    :: host of a given path
      [%x %host %path *]
        =/  thepath  t.t.t.path
        =/  thepathrow  (~(got by paths.state) thepath)
        ``ship+!>(host.thepathrow)
    ::
    :: test existence of given path
      [%x %loobean %path *]
        =/  thepath  t.t.t.path
        =/  thepathrow  (~(get by paths.state) thepath)
        ?~  thepathrow
          ``ud+!>(1)  :: false
        ``ud+!>(0)    :: true, because the pathrow exsits
         :: test existence of given type
    ::
      [%x %loobean %table @ @ ~]
        =/  tblname=@tas      i.t.t.t.path
        =/  typ=type:common   [tblname (slav %uv i.t.t.t.t.path)]
        =/  thetbl  (~(get by tables.state) typ)
        ?~  thetbl
          ``ud+!>(1)  :: false
        ``ud+!>(0)    :: true, because the pathrow exsits
    ::
    :: test existence of given type
      [%x %loobean %table @ @ ~]
        =/  tblname=@tas      i.t.t.t.path
        =/  typ=type:common   [tblname (slav %uv i.t.t.t.t.path)]
        =/  thetbl  (~(get by tables.state) typ)
        ?~  thetbl
          ``ud+!>(1)  :: false
        ``ud+!>(0)    :: true, because the pathrow exsits
    ::
    :: /x/db/start-ms/[unix ms].json
    :: all tables, but only with received-at after <time>
      [%x %db %start-ms @ ~]
        =/  timestamp=@da   (di:dejs:format n+i.t.t.t.path)
        ``db-state+!>((after-time:db state timestamp))
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
      [%kept-alive *]
        ?+    -.sign  `this
          %poke-ack
            :: update received-at on the path row so we don't hammer
            :: dead hosts
            =/  dbpath=path     t.wire
            =/  pr=path-row     (~(got by paths.state) dbpath)
            =.  received-at.pr  now.bowl
            =.  paths.state     (~(put by paths.state) dbpath pr)
            ?~  p.sign
              `this(state state)
            ~&  >>>  "%db: {<(spat wire)>} kept-alive failed"
            ~&  >>>  p.sign
            `this
        ==
      [%selfpoke ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%db: {<(spat wire)>} selfpoke failed"
            `this
        ==
      [%spaces ~]
        ?+    -.sign  !!
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to spaces" ~)  `this
            ::~&  >>>  "{<dap.bowl>}: spaces subscription failed"
            `this
          %kick
            ::~&  >  "{<dap.bowl>}: spaces kicked us, resubscribing..."
            :_  this
            :~  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
            ==
          %fact
            ?+    p.cage.sign   !!
              %spaces-reaction
                =^  cards  state
                  (spaces-reaction:db !<(=reaction:sstore q.cage.sign) state bowl)
                [cards this]
              ::
              %visa-reaction
                =^  cards  state
                  (visas-reaction:db !<(=reaction:vstore q.cage.sign) state bowl)
                [cards this]
            ==
        ==
      [%next @ *]
        ?-    -.sign
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%db: {<(spat wire)>} /next/[path] failed"
            ::~&  >>>  p.sign
            `this
          %watch-ack
            ?~  p.sign  `this
            ::~&  >>>  "{<dap.bowl>}: /next/[path] subscription failed"
            `this
          %kick
            `this
            ::=/  pathrow    (~(get by paths.state) +.+.wire)
            ::?:  =(~ pathrow)
              ::~&  >>>  "got a %kick on {(spud +.+.wire)} that we are ignoring because that path is not in our state"
            ::  `this
            ::=/  newpath  (weld /next/(scot %da updated-at:(need pathrow)) path:(need pathrow))
            ::~&  >>>  "{<dap.bowl>}: /next/[path] kicked us, resubbing {(spud newpath)}"
            :::_  this
            :::~
            ::  [%pass newpath %agent [src.bowl dap.bowl] %watch newpath]
            ::==
          %fact
            :: handle the update by updating our local state and
            :: pushing db-changes out to our subscribers
            =^  cards  state
            ^-  (quip card state-2)
            =/  dbpath=path         +.+.wire
            =/  factmark  -.+.sign
            ~&  >>>  "%fact on {(spud wire)}: {<factmark>}"
            ?+  factmark
              :: default case:
                ~&  >>>  "UNHANDLED FACT type"
                ~&  >>>  +.sign
                `state
              %db-changes
                =/  changes=db-changes  !<(db-changes +.+.sign)
                =/  result-cards   *(list card)
                =/  index=@ud           0
                |-
                  ?:  =(index (lent changes))
                    :_  state
                    :: echo the changes out to our client subs
                    ^-  (list card)
                    %+  weld
                      result-cards
                    ^-  (list card)
                    [%give %fact [/db (weld /path dbpath) ~] db-changes+!>(changes)]~
                  =/  change   (snag index changes)
                  =/  new-scry=(list card)
                    ?+  -.change  ~
                      %add-row
                        ?.  ?=(%relay name.type.row.change)  ~
                        ?>  ?=(%relay -.data.row.change)
                        =/  uobj=(unit row)  (get-db:db type.data.row.change path.data.row.change id.data.row.change state)
                        ?~  uobj :: if we DONT have the obj already, remote-scry it
                          ::~&  >>>  "asking for remote-scry"
                          :~  [
                            %pass
                            /remote-scry/callback
                            %arvo
                            %a
                            %keen
                            ship.id.row.change
                            /g/x/(scot %ud revision.data.row.change)/(scot %tas dap.bowl)//(scot %p ship.id.data.row.change)/(scot %da t.id.data.row.change)
                          ]
                          ==
                        ~ :: otherwise, don't emit any cards
                      %upd-row
                        ?.  ?=(%relay name.type.row.change)  ~
                        ?>  ?=(%relay -.data.row.change)
                        ?:  deleted.data.row.change  ~  :: if the root-obj is deleted, don't remote-scry it
                        ::~&  >>>  "asking for remote-scry"
                        :~  [
                          %pass
                          /remote-scry/callback
                          %arvo
                          %a
                          %keen
                          ship.id.row.change
                          /g/x/(scot %ud revision.data.row.change)/(scot %tas dap.bowl)//(scot %p ship.id.data.row.change)/(scot %da t.id.data.row.change)
                        ]
                        ==
                    ==
                  =/  pokes=(list card)
                    ?+  -.change  ~
                      %upd-row
                        ?:  ?=(%relay name.type.row.change)  ~
                        :: if it's NOT a relay, we might have to poke ourselves to update the relay
                        =/  our-relays=(list row)  (our-matching-relays:db row.change state bowl)
                        ?~  our-relays  ~
                        :-
                          :: remote-scry-publish the new row version
                          [%pass /remote-scry/callback %grow /(scot %p ship.id.row.change)/(scot %da t.id.row.change) row-and-schema+[row.change schema.change]]
                        ^-  (list card)
                        %-  zing
                        %+  turn
                          our-relays
                        |=  rela=row
                        ^-  (list card)
                        ?+  -.data.rela  ~
                          %relay
                            :: increment the revision of all the relays
                            :: that we host for this changed row
                            =/  dat  data.rela
                            =.  revision.dat  +(revision.dat)
                            [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%edit id.rela path.rela type.rela dat ~])]~
                        ==
                      %del-row
                        ?:  ?=(%relay name.type.change)  ~
                        :: if it's NOT a relay, we might have to poke ourselves to update the relay
                        =/  fakerow=row  *row
                        =.  id.fakerow   id.change
                        =/  our-relays=(list row)  (our-matching-relays:db fakerow state bowl)
                        ?~  our-relays  ~
                        =/  snagged-first=row  (snag 0 `(list row)`our-relays)
                        ?>  ?=(%relay -.data.snagged-first)
                        :-
                          :: remote-scry-cull all the revisions of this
                          :: deleted object
                          [%pass /remote-scry/cullback %cull [%ud revision.data.snagged-first] /(scot %p ship.id.change)/(scot %da t.id.change)]
                        ^-  (list card)
                        %-  zing
                        %+  turn
                          our-relays
                        |=  rela=row
                        ^-  (list card)
                        ?+  -.data.rela  ~
                          %relay
                            :: signal that the relayed object was deleted
                            =/  dat  data.rela
                            =.  deleted.dat  %.y
                            [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%edit id.rela path.rela type.rela dat ~])]~
                        ==
                    ==
                  =.  state
                    ?:  ?&  ?=(%upd-row -.change)
                            ?=(%relay name.type.row.change)
                            ?=(%relay -.data.row.change)
                            =(%.y deleted.data.row.change)
                        ==
                      ::~&  >>>  "{<our.bowl>} is del-db ing {<type.data.row.change>} {<ship.id.data.row.change>} {<t.id.data.row.change>}"
                      (del-db:db type.data.row.change path.data.row.change id.data.row.change state (add now.bowl index))
                    state
                  $(index +(index), state (process-db-change:db dbpath change state bowl), result-cards (weld (weld result-cards new-scry) pokes))
              %db-path
                :: TODO logging ~& to indicate that we are recieving a
                :: fullpath instead of just a single change
                :: |ames-cong 5 100.000
                =/  full=fullpath   !<(fullpath +.+.sign)
                ~&  >>>  "getting fullpath for {<path.path-row.full>}"
                :: insert pathrow
                =.  received-at.path-row.full  now.bowl
                =.  paths.state     (~(put by paths.state) dbpath path-row.full)
                :: insert peers
                =.  peers.full
                  %+  turn
                    peers.full
                  |=  p=peer
                  =.  received-at.p  now.bowl
                  p
                =.  peers.state     (~(put by peers.state) dbpath peers.full)
                :: update schemas
                =.  schemas.state   (~(gas by schemas.state) ~(tap by schemas.full))
                :: update del-log
                =.  del-log.state   (~(gas by del-log.state) dels.full)
                :: update tables
                =/  keys=(list type:common)   ~(tap in ~(key by tables.full))
                =/  index=@ud       0
                |-
                  ?:  =(index (lent keys))
                    :_  state
                    :: echo the changes out to our client subs
                    [%give %fact [/db (weld /path dbpath) ~] db-path+!>(full)]~
                  =/  key         (snag index keys)
                  =/  maybe-pt    (~(get by tables.state) key)
                  =.  tables.state
                    ?~  maybe-pt
                      (~(put by tables.state) key (malt [dbpath (~(got by tables.full) key)]~))
                    =/  pt  (~(put by (need maybe-pt)) dbpath (~(got by tables.full) key))
                    (~(put by tables.state) key pt)
                  $(index +(index))
            ==
            [cards this]
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
        ?+  -.sign-arvo  `this
          %ames
            ?+  -.+.sign-arvo  `this
              %tune
                =/  r=(unit roar:ames)   roar.+.sign-arvo
                ?~  r  `this
                =/  ro=roar:ames    (need r)
                ?~  data=q.dat.ro  `this
                =/  rs=row-and-schema  ;;(row-and-schema q.u.data)
                =/  uobj=(unit row)    (get-db:db type.row.rs path.row.rs id.row.rs state)
                =/  cards=(list card)
                  ?~  uobj :: if we DONT have the obj already, we're `add-row`ing it
                    [%give %fact [/db (weld /path path.row.rs) ~] db-changes+!>([%add-row row.rs schema.rs]~)]~
                  :: otherwise we are just `upd-row`ing it
                  [%give %fact [/db (weld /path path.row.rs) ~] db-changes+!>([%upd-row row.rs schema.rs]~)]~
                :-  cards
                this(state (add-row-to-db:db row.rs schema.rs state))
            ==
        ==
      [%remote-scry %cullback ~]
        ::~&  >  "remote-scry cullback we culled something"
        ::~&  >  -.sign-arvo
        `this
      [%timer ~]
        =/  paths-we-host  (skim ~(val by paths.state) |=(p=path-row =(our.bowl host.p)))
        =/  refresh-pokes=(list card)
          %-  zing
          %+  turn
            paths-we-host
          |=  p=path-row
          ^-  (list card)
          =/  peers=(list peer)  (~(got by peers.state) path.p)
          %+  turn
            (skip peers |=(per=peer =(ship.per our.bowl))) :: don't bother poking ourselves
          |=  =peer
          ^-  card
          [%pass /dbpoke %agent [ship.peer dap.bowl] %poke %db-action !>([%refresh-path updated-at.p path.p])]
        [
          :: we remove the old timer (if any) and add the new one, so that
          :: we don't get an increasing number of timers associated with
          :: this agent every time the agent gets updated
          :-  [%pass /timer %arvo %b %rest next-refresh-time:core]
          :-  [%pass /timer %arvo %b %wait next-refresh-time:core]
          refresh-pokes
          this
        ]
      [%keep-alive-timer ~]
        :: gets all the paths we don't host AND whose host is 'alive'
        =/  paths-we-dont-host
          %+  skim
            ~(val by paths.state)
          |=  p=path-row
          ?&  ?!(=(our.bowl host.p))
            :: host acked a keep-alive poke, or sent an update within
            :: 1.5 timer windows, proving it's still alive and we should
            :: send %keep-alive to them
              (gth received-at.p (sub now.bowl ~h3))
          ==

        =/  pokes=(list card)
          %+  turn
            paths-we-dont-host
          |=  p=path-row
          ^-  card
          [%pass (weld /kept-alive path.p) %agent [host.p dap.bowl] %poke %db-action !>([%keep-alive path.p])]

        [
          :: we remove the old timer (if any) and add the new one, so that
          :: we don't get an increasing number of timers associated with
          :: this agent every time the agent gets updated
          :-  [%pass /keep-alive-timer %arvo %b %rest next-keep-alive-time:core]
          :-  [%pass /keep-alive-timer %arvo %b %wait next-keep-alive-time:core]
          pokes
          this
        ]
      [%nft-verify @ @ *]
    =/  =path    `path`t.t.t.wire
    =/  =ship    `@p`(slav %p i.t.wire)
    =/  =role    `@tas`(slav %tas i.t.t.wire)
    ?>  ?=(%iris -.sign-arvo)
    =/  i  +.sign-arvo
    ?>  ?=(%http-response -.i)
    ?>  ?=(%finished -.+.i)
    =/  payload  full-file.client-response.i
    ?~  payload  `this
    =/  contracts=(list @t)
      (parse-alchemy-json (need (de:json:html q.data.u.payload)))
    =/  path-row=path-row    (~(got by paths.state) path)
    =/  chatrow=row  (snag 0 ~(val by (need (get-tbl:db chat-type:common path state))))
    ?>  ?=(%chat -.data.chatrow)
    ?>  |-
      ?:  =((lent contracts) 0)
        %.n
      ?:  =(contract:(need nft.data.chatrow) (snag 0 contracts))
        ~&  >  "found matching contract {<nft.data.chatrow>} {<(snag 0 contracts)>}"
        %.y
      $(contracts +.contracts)
    =/  newpeer=peer  [path ship role now.bowl now.bowl now.bowl]

    :: local state updates
    :: update paths table
    =.  updated-at.path-row     now.bowl
    =.  received-at.path-row    now.bowl
    =.  paths.state             (~(put by paths.state) path path-row)
    :: update peers table
    =/  original-peers=(list peer)    (~(got by peers.state) path)
    =/  newlist=(list peer)     [newpeer (skip original-peers |=(p=peer =(ship.p ship)))]
    =.  peers.state             (~(put by peers.state) path newlist)

    =/  thechange=db-changes    [%add-peer newpeer]~
    :: emit the change to subscribers
    =/  cards=(list card)
      :: poke `ship` with %get path
      :-  (get-path-card:db ship path-row (peers-to-ship-roles:db (~(got by peers.state) path)))
      :: tell clients about the new peer
      :-  [%give %fact [/db (weld /path path) ~] db-changes+!>(thechange)]
      :: tell subs about the new peer
      %+  turn
        (living-peers:db original-peers now.bowl our.bowl)
      |=  p=peer
      ^-  card
      (handle-changes-card:db ship.p thechange path)
    [cards this]
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
++  next-keep-alive-time  `@da`(add (mul (div now.bowl ~h2) ~h2) ~h2)  :: TODO decide on actual timer interval
++  s1-from-now  `@da`(add (mul (div now.bowl ~s1) ~s1) ~s1)
++  path-to-type
  |=  p=path
  ^-  type:common
  [`@tas`(slav %tas +2:p) `@uvH`(slav %uv +6:p)]
++  parse-alchemy-json
  |=  jon=json
  ^-  (list @t)
  ?>  ?=([%o *] jon)
  =/  contracts=json  (~(got by p.jon) 'contracts')
  ?>  ?=([%a *] contracts)
  %+  turn  p.contracts
  |=  jn=json
  ^-  @t
  ?>  ?=([%o *] jn)
  =/  address=json  (~(got by p.jn) 'address')
  (so:dejs:format address)
--
