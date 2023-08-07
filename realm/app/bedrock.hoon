::  app/bedrock.hoon
::  - all data is scoped by /path, with a corresponding peers list
::  - ship-to-ship replication of data uses one-at-a-time subscriptions
::    described here: https://developers.urbit.org/reference/arvo/concepts/subscriptions#one-at-a-time
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
::    but if the schema is already there for that type/version combo,
::    you can just pass ~ in that spot
::    schemas are versionable
::    ex: :db &db-action [%create /example %foo 0 [%general ~[1 'a']] ~[['num' 'ud'] ['str' 't']]]
::        :db &db-action [%create /example %vote 0 [%vote [%.y our %foo [~zod now] /example]] ~]
::        :db &db-action [%create /example %foo 1 [%general ~[1 'd' (jam /hello/goodbye)]] ~[['num' 'ud'] ['str' 't'] ['mypath' 'path']]]
::        :~zod/db &db-action [%create /example %vote 0 [%vote %.y our %foo [~zod now] /example] ~]

/-  *db, sstore=spaces-store, vstore=visas
/+  dbug, db
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
    :: make sure the relay table exists on-init
    =.  tables.default-state
    (~(gas by *^tables) ~[[%relay *pathed-table] [%vote *pathed-table] [%react *pathed-table]])
    =/  default-cards
      :~  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
          [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%create-initial-spaces-paths ~])]
          [%pass /timer %arvo %b %wait next-refresh-time:core]
      ==
    [default-cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    :: REMOVE WHEN YOU WANT DATA TO ACTUALLY STICK AROUND
    ::=/  default-state=state-0   *state-0
    :: make sure the relay table exists on-init
    ::=.  tables.default-state
    ::(~(gas by *^tables) ~[[%relay *pathed-table] [%vote *pathed-table] [%react *pathed-table]])
    :: do a quick check to make sure we are subbed to /updates in %spaces
    =/  cards
      :-  [%pass /timer %arvo %b %rest next-refresh-time:core]
      :-  [%pass /timer %arvo %b %wait next-refresh-time:core]
      :: :-  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%create-initial-spaces-paths ~])]
      :: :-  [%pass /selfpoke %agent [our.bowl %api-store] %poke %api-store-action !>([%sync-to-bedrock ~])] :: ALSO REMOVE WHEN YOU STOP WIPING THE DATA EVERY TIME
      ?:  (~(has by wex.bowl) [/spaces our.bowl %spaces])
        ~
      [%pass /spaces %agent [our.bowl %spaces] %watch /updates]~
    [cards this(state old)]
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

      %get-path
        (get-path:db +.act state bowl)
      %delete-path
        (delete-path:db +.act state bowl)
      %refresh-path
        (refresh-path:db +.act state bowl)

      %create
        (create:db +.act state bowl)
      %edit
        (edit:db +.act state bowl)
      %remove
        (remove:db +.act state bowl)
      %remove-many
        (remove-many:db +.act state bowl)

      %relay
        (relay:db +.act state bowl)

      %create-initial-spaces-paths
        (create-initial-spaces-paths:db state bowl)
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
            ::~&  >>>  "{<src.bowl>} tried to sub on old @da {<t>}, %kicking them"
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
    ::  /db/table/realm-note.json
      [%x %db %table @ ~]
        =/  tblname=@tas  i.t.t.t.path
        ``db-table+!>([tblname (~(got by tables.state) tblname) schemas.state])
    ::
    :: host of a given path
      [%x %host %path *]
        =/  thepath  t.t.t.path
        =/  thepathrow  (~(got by paths.state) thepath)
        ``ship+!>(host.thepathrow)
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
      [%next *]
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
            =/  pathrow    (~(get by paths.state) +.wire)
            ?:  =(~ pathrow)
              ::~&  >>>  "got a %kick on {(spud +.wire)} that we are ignoring because that path is not in our state"
              `this
            =/  newpath  (weld /next/(scot %da updated-at:(need pathrow)) path:(need pathrow))
            ::~&  >  "{<dap.bowl>}: /next/[path] kicked us, resubbing {(spud newpath)}"
            :_  this
            :~
              [%pass wire %agent [src.bowl dap.bowl] %watch newpath]
            ==
          %fact
            :: handle the update by updating our local state and
            :: pushing db-changes out to our subscribers
            =^  cards  state
            ^-  (quip card state-0)
            =/  dbpath=path         +.wire
            =/  factmark  -.+.sign
            ::~&  >>  "%fact on {(spud wire)}: {<factmark>}"
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
                        ?.  ?=(%relay type.row.change)  ~
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
                        ?.  ?=(%relay type.row.change)  ~
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
                        ?:  ?=(%relay type.row.change)  ~
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
                            [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%edit id.rela path.rela type.rela v.rela dat ~])]~
                        ==
                      %del-row
                        ?:  ?=(%relay type.change)  ~
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
                            [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %db-action !>([%edit id.rela path.rela type.rela v.rela dat ~])]~
                        ==
                    ==
                  =.  state
                    ?:  ?&  ?=(%upd-row -.change)
                            ?=(%relay type.row.change)
                            ?=(%relay -.data.row.change)
                            =(%.y deleted.data.row.change)
                        ==
                      ::~&  >>>  "{<our.bowl>} is del-db ing {<type.data.row.change>} {<ship.id.data.row.change>} {<t.id.data.row.change>}"
                      (del-db:db type.data.row.change path.data.row.change id.data.row.change state (add now.bowl index))
                    state
                  $(index +(index), state (process-db-change:db dbpath change state bowl), result-cards (weld (weld result-cards new-scry) pokes))
              %db-path
                =/  full=fullpath   !<(fullpath +.+.sign)
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
      [%path @ *]
        ?-    -.sign
          %poke-ack
            ?~  p.sign  `this
            ::~&  >>>  "%realm-chat: {<(spat wire)>} dbpoke failed"
            ::~&  >>>  p.sign
            `this
          %watch-ack
            ?~  p.sign  `this
            ::~&  >>>  "{<dap.bowl>}: /db subscription failed"
            `this
          %kick
            ::~&  >  "{<dap.bowl>}: /db kicked us, resubscribing..."
            :_  this
            :~
              [%pass /db %agent [our.bowl %chat-db] %watch /db]
            ==
          %fact
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
++  next-refresh-time  `@da`(add (mul (div now.bowl ~h8) ~h8) ~h8)  :: TODO decide on actual timer interval
--
