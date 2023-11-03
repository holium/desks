::  db [realm]:
::  TODO:
::  - constraints via paths-table settings
/-  *db, common, mstore=membership, sstore=spaces-store
/-  vstore=visas
/+  spaces-chat, passport-lib=passport, crypto-helper
|%
::
:: helpers
::
++  is-common
  |=  =type:common
  ^-  ?
  ?|  =(type vote-type:common)
      =(type rating-type:common)
      =(type comment-type:common)
      =(type react-type:common)
      =(type tag-type:common)
      =(type link-type:common)
      =(type relay-type:common)
      =(type creds-type:common)
      =(type friend-type:common)
      =(type passport-type:common)
      =(type contact-type:common)
      =(type chat-type:common)
      =(type message-type:common)
  ==
++  living-peers
:: filter for peers who ARE NOT `our` AND have an updated-at within the
:: %keep-alive window (on a 2hr cadence)
:: WARNING keep logic in sync with `keep-alive` method
  |=  [peers=(list peer) now=@da our=ship]
  ^-  (list peer)
  :: ~h5 because it means they missed 2 %keep-alives (on a 2hr cadence)
  %+  skim
    peers
  |=  p=peer
  ?&  (gth updated-at.p (sub now ~h5))
      ?!(=(ship.p our))
  ==
::
++  dels-by-path
  |=  [=path state=state-2]
  ^-  (list [@da db-del-change])
  %+  skim
    ~(tap by del-log.state)
  |=  [k=@da v=db-del-change]
  ^-  ?
  ?-  -.v
    %del-row   =(path.v path)
    %del-peer  =(path.v path)
    %del-path  =(path.v path)
  ==
::
++  maybe-log
  |=  [hide-debug=? msg=tape]
  ?:  =(%.y hide-debug)  ~
  ~&  msg
  ~
::
++  got-db
  |=  [=type:common =path =id:common state=state-2]
  ^-  row
  (~(got by (~(got by (~(got by tables.state) type)) path)) id)
::
++  get-db
  |=  [=type:common =path =id:common state=state-2]
  ^-  (unit row)
  =/  tbl   (get-tbl type path state)
  ?~  tbl   ~
  (~(get by u.tbl) id)
::
++  get-tbl
  |=  [=type:common =path state=state-2]
  ^-  (unit table)
  =/  ptbl  (~(get by tables.state) type)
  ?~  ptbl  ~
  (~(get by u.ptbl) path)
::
++  del-db
  |=  [=type:common =path =id:common state=state-2 t=@da]
  ^-  state-2
  =/  pt                  (~(got by tables.state) type)
  =/  tbl                 (~(got by pt) path)
  =/  old-row             (~(got by tbl) id) :: old row must first exist
  :: do the delete
  =.  tbl             (~(del by tbl) id)                :: delete by id
  =.  pt              (~(put by pt) path tbl)           :: update the pathed-table
  =.  tables.state    (~(put by tables.state) type pt)  :: update the tables.state
  =/  log=db-row-del-change    [%del-row path type id t]
  =.  del-log.state   (~(put by del-log.state) t log)  :: record the fact that we deleted
  state
::
++  our-matching-relays
  |=  [r=row state=state-2 =bowl:gall]
  ^-  (list row)
  =/  uptbl=(unit pathed-table)  (~(get by tables.state) relay-type:common)
  ?~  uptbl  `(list row)`~
  =/  relays=(list row)  ~(val by (ptbl-to-tbl u.uptbl))
  %+  skim
    relays
  |=  rel=row
  ^-  ?
  ?+  -.data.rel  %.n
    %relay
      &(=(id.data.rel id.r) =(ship.id.rel our.bowl))
  ==
::
++  meets-constraints-edit
  |=  [=path-row =row state=state-2 =bowl:gall]
  ^-  ?
  =/  tbl=(unit table)    (get-tbl type.row path.path-row state)
  ?~  tbl  %.y  :: there's nothing in this table, so any row we add is unique along all possible columns
  =/  uconst=(unit constraint)  (~(get by constraints.path-row) type.row)
  =/  const=(unit constraint)
    ?~  uconst  (~(get by default-constraints) type.row)
    uconst
  ?~  const  %.y  :: there is neither a defined-constraint nor a default-constraint, thus this "meets constraints"
  %-  ~(all in uniques.u.const)
  |=  cols=unique-columns
  ^-  ?
  =/  where=(list [column-accessor *])
    %+  turn
      ~(tap in cols)
    |=  ca=column-accessor
    :-  ca
    (snag-val-from-row ca row)
  =/  matches=(list ^row)  (find-from-where u.tbl where)
  ?&  =(1 (lent matches))
      =((lent `(list ^row)`(skim matches |=(r=^row =(id.r id.row)))) 1)
  ==
::
++  meets-constraints
  |=  [=path-row =row state=state-2 =bowl:gall]
  ^-  ?
  =/  tbl=(unit table)    (get-tbl type.row path.path-row state)
  ?~  tbl  %.y  :: there's nothing in this table, so any row we add is unique along all possible columns
  =/  uconst=(unit constraint)  (~(get by constraints.path-row) type.row)
  =/  const=(unit constraint)
    ?~  uconst  (~(get by default-constraints) type.row)
    uconst
  ?~  const  %.y  :: there is neither a defined-constraint nor a default-constraint, thus this "meets constraints"
  %-  ~(all in uniques.u.const)
  |=  cols=unique-columns
  ^-  ?
  =/  where=(list [column-accessor *])
    %+  turn
      ~(tap in cols)
    |=  ca=column-accessor
    :-  ca
    (snag-val-from-row ca row)
  =/  matches=(list ^row)  (find-from-where u.tbl where)
  ?~  matches  %.y
  %.n
::
++  find-from-where
  |=  [tbl=table conds=(list [i=column-accessor v=*])]
  ^-  (list row)
  %+  skim
    ~(val by tbl)
  |=  r=row
  %+  levy
    conds
  |=  cond=[i=column-accessor v=*]
  =(v.cond (snag-val-from-row i.cond r))
::
++  snag-val-from-row
  |=  [i=column-accessor r=row]
  ?@  i   (snag-by-index i +.data.r)
  ?:  =(i "ship.id")      ship.id.r
  ?:  =(i "t.id")         t.id.r
  ?:  =(i "created-at")   created-at.r
  ?:  =(i "updated-at")   updated-at.r
  ?:  =(i "received-at")  received-at.r
  !! :: unsupported name
::
++  snag-by-index
  |=  [i=@ r=*]
  |-
    ?@  r  !!
    ?:  =(0 i)  -:r
    $(r +:r, i (dec i))
::
++  has-create-permissions
  |=  [=path-row =row state=state-2 =bowl:gall]
  ^-  ?
  (has-ced-permissions %create path-row row state bowl)
::
++  has-edit-permissions
  |=  [=path-row =row state=state-2 =bowl:gall]
  ^-  ?
  (has-ced-permissions %edit path-row row state bowl)
::
++  has-delete-permissions
  |=  [=path-row =row state=state-2 =bowl:gall]
  ^-  ?
  (has-ced-permissions %delete path-row row state bowl)
::
++  has-ced-permissions
  |=  [ced=?(%create %edit %delete) =path-row =row state=state-2 =bowl:gall]
  ^-  ?
  ::  src.bowl must be in the peers list
  =/  possiblepeers=(list peer)   (skim (~(got by peers.state) path.path-row) |=(=peer =(ship.peer src.bowl)))
  ?:  =((lent possiblepeers) 0)   %.n
  =/  srcpeer=peer                (snag 0 possiblepeers)

  :: find relevant access-rules for this type.row
  =/  tbl-acs  (~(get by table-access.path-row) type.row)
  ::  if type.row is in table-access.path-row, check that
  ::  else check the default-access rule
  =/  rules=access-rules
    ?~  tbl-acs
      default-access.path-row
    (need tbl-acs)
  
  =/  u-role-rule   (~(get by rules) role.srcpeer)
  =/  role-rule=access-rule
    ?~  u-role-rule
      (~(got by rules) %$)  :: fall back to wildcard role
    (need u-role-rule)

  ?-  ced
    %create
      create.role-rule
    %edit
      (check-permission-scope edit.role-rule row src.bowl)
    %delete
      (check-permission-scope delete.role-rule row src.bowl)
  ==
::
++  check-permission-scope
  |=  [s=permission-scope =row =ship]
  ^-  ?
  ?-  s
    %table  %.y
    %none   %.n
    %own    =(ship.id.row ship)
  ==
::
++  peers-to-ship-roles
  |=  peers=(list peer)
  ^-  ship-roles
  %+  turn
    peers
  |=(p=peer [ship.p role.p])
::
++  get-path-card
  |=  [=ship =path-row peers=ship-roles]
  ^-  card
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%get-path path-row peers])]
::
++  delete-path-card
  |=  [=ship =path]
  ^-  card
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%delete-path path])]
::
++  handle-changes-card
  |=  [=ship =db-changes =path]
  ^-  card
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%handle-changes db-changes path])]
::
++  del-path-in-tables
  |=  [state=state-2 =path]
  ^-  tables
  =/  keys    ~(tap in ~(key by tables.state))
  =/  index  0
  |-
    ?:  =(index (lent keys))
      tables.state
    =/  typekey    (snag index keys)
    =/  pt         (~(del by (~(got by tables.state) typekey)) path)
    $(index +(index), tables.state (~(put by tables.state) typekey pt))
::
++  process-db-change
:: takes a db-change object (that we presumably got as a %fact on a
:: subscription) and mutates state appropriately
  |=  [=path ch=db-change state=state-2 =bowl:gall]
  ^-  state-2
  :: ensure the path exists
  =/  tmp         (~(get by paths.state) path)
  ?:  =(~ tmp)    state
  =/  path-row    (need tmp)
  :: ensure this came from the host
  ?.  =(src.bowl host.path-row)   state

  =.  received-at.path-row        now.bowl

  ?-  -.ch
    %add-row
      =.  updated-at.path-row   updated-at.row.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      =.  received-at.row.ch    now.bowl
      (add-row-to-db row.ch schema.ch state)
    %upd-row
      =.  updated-at.path-row   updated-at.row.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      =.  received-at.row.ch    now.bowl
      =/  sch=schema            (~(got by schemas.state) type.row.ch) :: currently just ensuring that we have the schema already
      ?:  =(sch schema.ch)
        :: the schema has not changed, so this is fine
        (add-row-to-db row.ch schema.ch state)
      ::TODO handle the schema has changed situation
      !!
    %del-row
      =.  updated-at.path-row   t.ch
      =.  paths.state           (~(put by paths.state) path.ch path-row)
      =/  pt              (~(got by tables.state) type.ch)
      =/  tbl             (~(got by pt) path.ch)
      =.  tbl             (~(del by tbl) id.ch)                :: delete by id
      =.  pt              (~(put by pt) path.ch tbl)           :: update the pathed-table
      =.  tables.state    (~(put by tables.state) type.ch pt)  :: update the tables.state
      =.  del-log.state   (~(put by del-log.state) now.bowl ch)  :: record the fact that we deleted
      state
    %add-path   !!  :: don't bother handling this because it should never come on the sub-wire... it goes through %get-path
    %upd-path
      =.  updated-at.path-row   updated-at.path-row.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      state
    %del-path   !!  :: don't bother handling, because it goes over %delete-path poke
    %add-peer
      =.  updated-at.path-row   updated-at.peer.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      =.  received-at.peer.ch   now.bowl
      =/  newlist               [peer.ch (~(got by peers.state) path)]
      =.  peers.state           (~(put by peers.state) path newlist)
      state
    %upd-peer
      =.  updated-at.path-row   updated-at.peer.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      =.  received-at.peer.ch   now.bowl
      =/  oldlist               (~(got by peers.state) path)
      =/  newlist               [peer.ch (skip oldlist |=(=peer =(ship.peer ship.peer.ch)))]
      =.  peers.state           (~(put by peers.state) path newlist)
      state
    %del-peer     :: WARNING does not handle the "self" case. when we are being removed from a list, the host will send a %delete-path poke
      =.  updated-at.path-row   t.ch
      =.  paths.state           (~(put by paths.state) path path-row)
      =/  oldlist               (~(got by peers.state) path)
      =/  newlist               (skip oldlist |=(=peer =(ship.peer ship.ch)))
      =.  peers.state           (~(put by peers.state) path newlist)
      state
  ==
::
++  add-row-to-db
::  handles the nested tables accessing logic and schema validation
  |=  [=row =schema state=state-2]
  ^-  state-2
  :: schema stuff
  =/  schv  type.row
  ?> :: ensure there is not a conflict between table and the schema we are gonna validate
    ?:  (~(has by schemas.state) schv)
      =((~(got by schemas.state) schv) schema)
    %.y
  :: validate the row against schema
  ?>  
    ?:  ?=(%general -.data.row)
      =((lent schema) (lent +.data.row))  :: TODO make a stronger schema-check by comparing path/map/set/list etc for each item in the data-list
    %.y :: other types are auto-validated
  =.  schemas.state   (~(put by schemas.state) schv schema)

  =.  tables.state
    ?:  (~(has by tables.state) type.row)
      =/  ptbl    (~(got by tables.state) type.row)
      ?:  (~(has by ptbl) path.row)
        :: type + path already exist so just update them
        =/  tbl     (~(got by ptbl) path.row)
        =.  tbl     (~(put by tbl) id.row row)
        =.  ptbl    (~(put by ptbl) path.row tbl)
        (~(put by tables.state) type.row ptbl)
      :: new path in existing type-tbl
      =/  tbl     (~(put by *table) id.row row)
      =.  ptbl    (~(put by ptbl) path.row tbl)
      (~(put by tables.state) type.row ptbl)
    :: new type, initialize both type and path
    =/  tbl     (~(put by *table) id.row row)
    =/  ptbl    (~(put by *pathed-table) path.row tbl)
    (~(put by tables.state) type.row ptbl)

  state
::
++  tables-by-path
  |=  [=tables =path]
  ^-  (map type:common table)
  =/  result      *(map type:common table)
  =/  index=@ud   0
  =/  types=(list type:common)   ~(tap in ~(key by tables))
  |-
    ?:  =(index (lent types))
      result
    =/  current-type    (snag index types)
    =/  pt   (~(got by tables) current-type)
    =/  tbl  (~(get by pt) path)
    ?~  tbl
      $(index +(index))
    $(index +(index), result (~(put by result) current-type (need tbl)))
::
++  flatten-tables
  |=  =tables
  ^-  (map type:common table)
  =/  types=(list type:common)  ~(tap in ~(key by tables))
  =/  result                    *(map type:common table)
  =/  index=@ud                 0
  |-
    ?:  =(index (lent types))
      result
    =/  t       (snag index types)
    =/  tbl=table  (ptbl-to-tbl (~(got by tables) t))
    $(index +(index), result (~(put by result) t tbl))
::
++  ptbl-to-tbl
  |=  ptbl=pathed-table
  ^-  table
  =/  paths   ~(tap in ~(key by ptbl))
  =/  result=table  *table
  =/  index=@ud     0
  |-
    ?:  =(index (lent paths))
      result
    =/  tbl=table  (~(got by ptbl) (snag index paths))
    $(index +(index), result (~(uni by result) tbl))
::
++  tbl-after
  |=  [tbl=table t=@da]
  ^-  table
  %-  ~(gas by *table)
  %+  skim
    ~(tap by tbl) 
  |=  [k=id:common v=row]
  ^-  ?
  (gth received-at.v t)
::
++  after-time
  |=  [st=state-2 t=@da]
  ^-  state-2
  ?:  =(0 t)  st

  =.  paths.st
    (~(gas by *paths) (skim ~(tap by paths.st) |=(kv=[=path =path-row] (gth received-at.path-row.kv t))))

  =.  del-log.st
    %-  ~(gas by *del-log)
    %+  skim
      ~(tap by del-log.st)
    |=  [dt=@da ch=db-del-change]
    (gth dt t)

  =.  peers.st
    %+  ~(put by *peers)
      /output
    %+  skim
      ^-  (list peer)
      %-  zing
      ~(val by peers.st)
    |=(=peer (gth received-at.peer t))

  =/  types=(list type:common)  ~(tap in ~(key by tables.st))
  =/  newtbls=tables            *tables
  =/  index=@ud                 0
  =.  tables.st
    |-
      ?:  =(index (lent types))
        newtbls
      =/  typ     (snag index types)
      =/  tbl     (tbl-after (ptbl-to-tbl (~(got by tables.st) typ)) t)
      $(index +(index), newtbls (~(put by newtbls) typ (~(put by *pathed-table) /output tbl)))
  st
::
++  spaces-reaction
  |=  [rct=reaction:sstore state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  |^
  ?+  -.rct         `state
    %add            (on-add +.rct)
    %remove         (on-remove +.rct)
  ==
  ::
  ++  on-add
    |=  [new-space=space:sstore =members:mstore]
    ::  only host can create space path-rows
    ?.  =(our.bowl ship.path.new-space)
      `state
    %-  (slog leaf+"{<dap.bowl>}: creating paths for {<path.new-space>}" ~)
    :: create the default 4 paths
    =/  pathed    (pathify-space-path:spaces-chat path.new-space)
    =/  ini       (create-from-space [(weld pathed /initiate) path.new-space %initiate] state bowl)
    =/  mem       (create-from-space [pathed path.new-space %member] +.ini bowl)
    =/  cs        [(weld -.ini -.mem) +.mem]
    =/  adm       (create-from-space [(weld pathed /admin) path.new-space %admin] +.cs bowl)
    =.  cs        [(weld -.cs -.adm) +.adm]
    =/  owr       (create-from-space [(weld pathed /owner) path.new-space %owner] +.cs bowl)
    [(weld -.cs -.owr) +.owr]
  ::
  ++  on-remove
    |=  [path=space-path:sstore]
    ::  only host can delete space path-rows
    ?.  =(our.bowl ship.path)
      `state
    %-  (slog leaf+"{<dap.bowl>}: deleting paths for {<path>}" ~)
    =/  pathed    (pathify-space-path:spaces-chat path)
    =/  prs=(list path-row)  
      %+  skim
        ~(val by paths.state)
      |=(pr=path-row ?~(space.pr %.n =(path:(need space.pr) pathed)))

    =/  index=@ud  0
    =/  cs      [*(list card) state]
    |-
      ?:  =(index (lent prs))
        cs
      =/  pr   (snag index prs)
      =/  fakebowl  bowl
      =.  now.fakebowl   `@da`(add index now.bowl)
      =/  new  (remove-path path.pr +.cs fakebowl)
      $(index +(index), cs [(weld -.cs -.new) +.new])
    ::
  --
::
++  visas-reaction
  |=  [rct=reaction:vstore state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  |^
  ?+  -.rct             `state
    %invite-accepted    (on-accepted +.rct)
    %kicked             (on-kicked +.rct)
  ==
  ::
  ++  on-accepted
    |=  [path=space-path:sstore =ship =member:mstore]
    ^-  (quip card state-2)
    ::  only host can modify peers lists
    ?.  =(our.bowl ship.path)    `state
    =/  log1  (maybe-log hide-logs.state "on-accepted, trying to add {<ship>} to relevant paths")
    ::  if we are here, we are the host
    =/  max-role
      ?:  (~(has in roles.member) %owner)   %host
      ?:  (~(has in roles.member) %admin)   %admin
      ?:  (~(has in roles.member) %member)  %member
      %initiate
    ?:  =(max-role %initiate)  `state :: initiates don't get access to anything new from accepting
    =/  pathed    (pathify-space-path:spaces-chat path)
    =/  prs=(list path-row)
      %+  skim
        ~(val by paths.state)
      |=  pr=path-row
      ^-  ?
      ?&  ?~(space.pr %.n =(path:(need space.pr) pathed))
          =(host.pr our.bowl)
      ==
    =/  index=@ud  0
    =/  cs   [*(list card) state]
    |-
      ?:  =(index (lent prs))
        cs
      =/  pr   (snag index prs)
      =/  prole  role:(need space.pr)
      ?:  ?|  =(prole %member)
              =(prole %initiate)
              ?&  =(prole %admin)
                  |(=(max-role %host) =(max-role %admin))
              ==
              ?&  =(prole %host)
                  =(max-role %host)
              ==
          ==
        :: if they SHOULD be added, add them
        =/  log2  (maybe-log hide-logs.state "on-accepted: adding {<ship>} to {<path.pr>}")
        =/  new  (add-peer [path.pr ship max-role ~] +.cs bowl)
        $(index +(index), cs [(weld -.cs -.new) +.new])
      :: else, move on
      $(index +(index), cs cs)
  ::
  ++  on-kicked
    |=  [path=space-path:sstore =ship]
    ^-  (quip card state-2)
    ::  only host can modify peers lists
    ?.  =(our.bowl ship.path)    `state
    =/  pathed    (pathify-space-path:spaces-chat path)
    :: attempt to kick from all since it doesn't hurt anything if they
    :: aren't actually in the path
    =/  pathed    (pathify-space-path:spaces-chat path)
    =/  prs=(list path-row)  
      %+  skim
        ~(val by paths.state)
      |=(pr=path-row ?~(space.pr %.n =(path:(need space.pr) pathed)))

    =/  index=@ud  0
    =/  cs      [*(list card) state]
    |-
      ?:  =(index (lent prs))
        cs
      =/  pr   (snag index prs)
      =/  new  (kick-peer [path.pr ship] +.cs bowl)
      $(index +(index), cs [(weld -.cs -.new) +.new])
  --
::
:: pokes
::   tests:
::bedrock &db-action [%create-path /example %host ~ ~ ~ ~[[~zod %host] [~bus %member]]]
::bedrock &db-action [%add-peer /example ~fed %member]
::bedrock &db-action [%create [~zod now] /example %foo 0 [%general ~[1 'a']] ~[['num' 'ud'] ['str' 't']]]
::bedrock &db-action [%create [~zod now] /example %vote 0 [%vote [%.y %foo [~zod ~2023.6.21..22.25.01..e411] /example]] ~]
:: from ~bus:
::~zod/bedrock &db-action [%create [our now] /example %foo 0 [%general ~[1 'a']] ~[['num' 'ud'] ['str' 't']]]
::
::  in zod
::bedrock &db-action [%create-path /example %host ~ ~ ~ ~[[~zod %host] [~bus %member]]]
::bedrock &db-action [%create [~zod now] /example %foo 0 [%general ~[1 'a']] ~[['num' 'ud'] ['str' 't']]]
::  in bus
::bedrock &db-action [%create-path /target %host ~ ~ ~ ~[[~bus %host] [~fed %member]]]
::bedrock &db-action [%relay [~bus now] /target %relay 0 [%relay [~zod ~2023.6.13..15.57.34..aa97] %foo /example 0 %all %.n] ~]
::  then, in zod again
::bedrock &db-action [%edit [our ~2023.5.22..17.21.47..9d73] /example %foo 0 [%general ~[2 'b']] ~]
::bedrock &db-action [%remove %foo /example [our ~2023.8.9..16.43.15..96af]]
++  create-path
::bedrock &db-action [%create-path /example %host ~ ~ ~ ~[[~zod %host] [~bus %member]]]
::bedrock &db-action [%create-path /target %host ~ ~ ~ ~[[~bus %host] [~fed %member]]]
  |=  [=input-path-row state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%create-path {<path.input-path-row>} {<peers.input-path-row>}")
  :: ensure the path doesn't already exist
  =/  pre-existing    (~(get by paths.state) path.input-path-row)
  ?>  =(~ pre-existing)
  :: ensure this came from our ship
  ?>  =(our.bowl src.bowl)

  =/  sorted-peers=ship-roles
    (sort peers.input-path-row |=([a=[s=@p =role] b=[s=@p =role]] (gth s.a s.b)))
  =/  requested-hosts=ship-roles
    (skim sorted-peers |=(p=[s=@p =role] =(role.p %host)))
  ?>  (gth (lent requested-hosts) 0)  :: ensure there is at least one requested host
  :: ensure our ship is in the peers list
  =/  our-role  (snag 0 (skim sorted-peers |=(a=[s=@p =role] =(s.a our.bowl))))
  =/  true-host=ship   s:(snag 0 requested-hosts)

  :: local state updates
  :: create the path-row
  =/  path-row=path-row  [
    path.input-path-row
    true-host
    replication.input-path-row
    default-access.input-path-row
    table-access.input-path-row
    constraints.input-path-row
    ~
    now.bowl
    now.bowl
    now.bowl
  ]
  :: overwrite with global default if path-default is not specified
  =.  default-access.path-row
    ?~  default-access.path-row
      default-access-rules
    default-access.path-row
  =.  paths.state     (~(put by paths.state) path.path-row path-row)
  :: create the peers list
  =/  peerslist
    %+  turn
      sorted-peers
    |=  [s=@p =role]
    ^-  peer
    [
      path.path-row
      s
      role
      now.bowl
      now.bowl
      now.bowl
    ]
  =.  peers.state     (~(put by peers.state) path.path-row peerslist)

  ::  alert the peers that they have been added
  =/  peer-pokes=(list card)
    %+  turn
      (skip peerslist |=(p=peer =(ship.p our.bowl))) :: skip ourselves though, since that poke will just fail
    |=  =peer
    ^-  card
    (get-path-card ship.peer path-row sorted-peers)
  :: emit the change to self-subscriptions (our clients)
  =/  thechange  db-changes+!>([[%add-path path-row] (turn peerslist |=(p=peer [%add-peer p]))])
  =/  subscription-facts=(list card)  :~
    [%give %fact [/db /db/common (weld /path path.path-row) ~] thechange]
  ==

  =/  cards  (weld peer-pokes subscription-facts)
  [cards state]
::
++  create-from-space
:: note sr is the space-role that the path is being generated for, not
:: the %db role (%host vs %owner)
:: if you pass _____ as sr:
::   %owner,    only members with %owner in their roles will be part of the path, %joined or %host must be status
::   %admin,    %owner or %admin must be in roles, %joined must be status
::   %member,   %owner %admin or %member must be in roles, %joined must be status
::   %initiate, every ship in the members list, regardless of role or joined status
  |=  [[=path sp=[=ship space=cord] sr=role:mstore] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%create-from-space")
  =/  members     .^(view:mstore %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/(scot %p ship.sp)/(scot %tas space.sp)/members/noun)
  ?>  ?=(%members -.members)
  =/  filtered-members
    %+  skim
      ~(tap by members.members)
    |=  [=ship =member:mstore]
    ^-  ?
    ?:  =(sr %initiate)  %.y
    ?&  |(=(status.member %joined) =(status.member %host))
      ?|
        (~(has in roles.member) sr)
        ?-  sr
          %initiate   %.y
          %member 
            ?|  (~(has in roles.member) %admin)
                (~(has in roles.member) %owner)
            ==
          %admin
                (~(has in roles.member) %owner)
          %owner      %.n
        ==
      ==
    ==

  =/  peers=(list peer)
    %+  turn
      filtered-members
    |=  [=ship =member:mstore]
    ^-  peer
    =/  max-role
      ?:  (~(has in roles.member) %owner)   %host
      ?:  (~(has in roles.member) %admin)   %admin
      ?:  (~(has in roles.member) %member)  %member
      %initiate
    [
      path
      ship
      ?:(=(ship our.bowl) %host max-role)  :: our is always the %host
      now.bowl
      now.bowl
      now.bowl
    ]
  =.  peers.state     (~(put by peers.state) path peers)

  :: create the path-row
  =/  path-row=path-row  [
    path
    our.bowl
    %host
    default-access-rules
    ~
    ~
    [~ [(pathify-space-path:spaces-chat sp) sr]]
    now.bowl
    now.bowl
    now.bowl
  ]
  =.  paths.state     (~(put by paths.state) path path-row)

  ::  alert the peers that they have been added
  =/  peer-pokes=(list card)
    %+  turn
      (skip peers |=(p=peer =(ship.p our.bowl))) :: skip ourselves though, since that poke will just fail
    |=  =peer
    ^-  card
    (get-path-card ship.peer path-row (turn peers |=(p=^peer [ship.p role.p])))
  :: emit the change to self-subscriptions (our clients)
  =/  thechange  db-changes+!>([[%add-path path-row] (turn peers |=(p=peer [%add-peer p]))])
  =/  client-facts=(list card)  :~
    [%give %fact [/db /db/common (weld /path path.path-row) ~] thechange]
  ==

  =/  cards  (weld peer-pokes client-facts)
  [cards state]
::
++  edit-path
::bedrock &db-action [%edit-path /example %host ~ ~ ~ ~[[~zod %host] [~bus %member]]]
::bedrock &db-action [%edit-path /target %host ~ ~ ~ ~[[~bus %host] [~fed %member]]]
  |=  [=input-path-row state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  :: ensure the path exists
  =/  path-row    (~(got by paths.state) path.input-path-row)
  :: ensure this came from our ship
  ?>  =(our.bowl src.bowl)
  :: ensure we are the host (ONLY HOST CAN EDIT)
  ?>  =(our.bowl host.path-row)

  :: only editable fields are:
  ::  replication
  ::  default-access
  ::  table-access
  ::  constraints
  =.  replication.path-row              replication.input-path-row
  =.  default-access.path-row
    ?~  default-access.input-path-row   default-access.path-row
    default-access.input-path-row
  =.  table-access.path-row
    ?~  table-access.input-path-row     table-access.path-row
    table-access.input-path-row
  =.  constraints.path-row
    ?~  constraints.input-path-row      constraints.path-row
    constraints.input-path-row
  =.  updated-at.path-row               now.bowl
  =.  received-at.path-row              now.bowl

  =.  paths.state     (~(put by paths.state) path.path-row path-row)

  :: emit the change to /next and self-subscriptions (our clients)
  =/  prs=(list peer)   (~(got by peers.state) path.path-row)
  =/  pokes=(list card)
    %+  turn
      (living-peers prs now.bowl our.bowl)
    |=  p=peer
    ^-  card
    [%pass /dbpoke %agent [ship.p %bedrock] %poke %db-action !>([%put-path path-row])]

  =/  tbls              (tables-by-path tables.state path.path-row)
  =/  dels              (dels-by-path path.path-row state)
  =/  full=fullpath     [path-row prs tbls schemas.state dels]
  =/  thechange         db-path+!>(full)

  =/  cards=(list card)
    :-  [%give %fact [/db /db/common (weld /path path.path-row) ~] thechange]
    pokes

  [cards state]
::
++  put-path
::  called by host to tell subs that the path metadata has changed
  |=  [new=path-row state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  :: ensure the path actually exists
  =/  original=path-row    (~(got by paths.state) path.new)
  :: ensure this came from host ship
  ?>  =(host.original src.bowl)
  :: ensure new path is same as old path
  ?>  =(path.original path.new)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%put-path: updating {<path.new>} metadata")

  :: update paths table
  =.  received-at.new  now.bowl
  =.  paths.state  (~(put by paths.state) path.new new)

  :: emit the change to clients
  =/  cards=(list card)
    [%give %fact [/db /db/common (weld /path path.new) ~] db-changes+!>([%upd-path new]~)]~
  [cards state]
::
++  remove-path
::bedrock &db-action [%remove-path /example]
  |=  [=path state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  :: ensure the path actually exists
  =/  path-row=path-row    (~(got by paths.state) path)
  :: and that we are the %host of it
  ?>  =(host.path-row our.bowl)
  :: ensure this came from our ship
  ?>  =(our.bowl src.bowl)

  :: alert peers of the removal
  =/  del-pokes=(list card)
    %+  turn
      (skip (~(got by peers.state) path) |=(p=peer =(ship.p our.bowl))) :: skip ourselves though, since that poke will just fail
    |=  =peer
    ^-  card
    (delete-path-card ship.peer path)

  :: emit the change to subscribers
  =/  sub-facts=(list card)
    [%give %fact [/db /db/common (weld /path path) ~] db-changes+!>([%del-path path now.bowl]~)]~
  =/  cards=(list card)  (weld del-pokes sub-facts)

  :: remove from paths table, and peers table
  =.  paths.state  (~(del by paths.state) path)
  =.  peers.state  (~(del by peers.state) path)
  :: remove from data tables
  =.  tables.state  (del-path-in-tables state path)

  :: add to del-log
  =.  del-log.state   (~(put by del-log.state) now.bowl [%del-path path now.bowl])

  [cards state]
::
++  add-peer
::bedrock &db-action [%add-peer /realm-chat/0vpjm9o.8a6mq.4j0et.nehkn.nj8km ~fed %member (some ['' '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'])]
  |=  [[=path =ship =role sig=(unit [sig=@t addr=@t])] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%add-peer: {<ship>} to {(spud path)} as {<role>}")
  :: ensure the path actually exists
  =/  path-row=path-row    (~(got by paths.state) path)
  =/  is-allowed=?(%y %n %nft)
    ?+  path
      :: and that we are the %host of it
      ?:  ?&  =(host.path-row our.bowl)
          :: ensure this came from our ship
              =(our.bowl src.bowl)
          ==
        %y
      %n
      [%spaces @ @ %chats @ ~]  %y
      [%realm-chat @ ~]
    =/  chatrow=row  (snag 0 ~(val by (need (get-tbl chat-type:common path state))))
    ?>  ?=(%chat -.data.chatrow)
    ?.  =(%nft-gated type.data.chatrow)  %y
    ?~  sig  %n
    ?~  nft.data.chatrow  %n
    =/  msg=@t  (crip ['I own the nft, let me in to ' (spat path) ~])
    ?:  (verify-message:crypto-helper msg sig.u.sig addr.u.sig)  %nft
    %n
    ==
  ?:  =(is-allowed %nft)
    =/  chatrow=row  (snag 0 ~(val by (need (get-tbl chat-type:common path state))))
    ?>  ?=(%chat -.data.chatrow)
    =/  url=@t
    %-  crip
    :~  'https://realm-server-test.plymouth.network/alchemy/nfts/'
      chain:(need nft.data.chatrow)
      '/'
      addr:(need sig)
    ==
    =/  =request:http  [%'GET' url ~ ~]
    =/  return-wire  (weld /nft-verify/(scot %p ship)/(scot %tas role) path)
    ~&  "sending {<url>}"
    :_  state
    :_  ~
    ^-  card
    [%pass return-wire %arvo %i %request request *outbound-config:iris]

  ?>  =(is-allowed %y)
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
    :-  (get-path-card ship path-row (peers-to-ship-roles (~(got by peers.state) path)))
    :: tell clients about the new peer
    :-  [%give %fact [/db /db/common (weld /path path) ~] db-changes+!>(thechange)]
    :: tell subs about the new peer
    %+  turn
      (living-peers original-peers now.bowl our.bowl)
    |=  p=peer
    ^-  card
    (handle-changes-card ship.p thechange path)

  [cards state]
::
++  kick-peer
::bedrock &db-action [%kick-peer /example ~fed]
  |=  [[=path =ship] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  :: ensure the path actually exists
  =/  path-row=path-row    (~(got by paths.state) path)
  :: and that we are the %host of it
  ?>  =(host.path-row our.bowl)
  :: ensure this came from our ship
  ?>  =(our.bowl src.bowl)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%kick-peer: {(scow %p ship)} from {<path>}")

  :: local state updates
  :: update paths table
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path path-row)
  :: update peers table
  =/  newlist=(list peer)     (skip (~(got by peers.state) path) |=(=peer =(ship.peer ship)))
  =.  peers.state             (~(put by peers.state) path newlist)

  :: emit the changes
  =/  thechange=db-changes    [%del-peer path ship now.bowl]~
  =/  cards=(list card)
    :: poke %delete-path to the ship we are kicking
    :-  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%delete-path path])]
    :: tell clients about the new peer
    :-  [%give %fact [/db /db/common (weld /path path) ~] db-changes+!>(thechange)]
    :: tell subs about the new peer
    %+  turn
      (living-peers newlist now.bowl our.bowl)
    |=  p=peer
    ^-  card
    (handle-changes-card ship.p thechange path)

  [cards state]
::
++  get-path
  |=  [[=path-row peers=ship-roles] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%get-path {<path.path-row>}")
  :: ensure the path doesn't already exist
  =/  pre-existing    (~(get by paths.state) path.path-row)
  ?>  =(~ pre-existing)
  :: ensure this came from a foreign ship
  ?<  =(src.bowl our.bowl)

  :: local state updates
  :: create the path-row
  =.  host.path-row         src.bowl
  =.  received-at.path-row  now.bowl
  =.  paths.state     (~(put by paths.state) path.path-row path-row)
  :: create the peers list
  =.  peers :: ensure [src.bowl %host] is in the peers list
    ?~  (find [[src.bowl %host]]~ peers)
      [[src.bowl %host] peers]
    peers
  =/  peerslist
    %+  turn
      peers
    |=  [s=@p =role]
    ^-  peer
    [
      path.path-row
      s
      ?:(=(s src.bowl) %host role)  :: src is always the %host
      created-at.path-row
      updated-at.path-row
      now.bowl
    ]
  =.  peers.state     (~(put by peers.state) path.path-row peerslist)

  :: emit the change to subscribers
  =/  sub-facts=(list card)
    [%give %fact [/db /db/common (weld /path path.path-row) ~] db-changes+!>([%add-path path-row]~)]~
  :: subscribe to src.bowl on /next/updated-at.path-row/[path] for data-changes in this path
  =/  subs  :~
    [
      %pass
      (weld /next/(scot %da *@da) path.path-row) :: intentionally subscribe to an old timestamp to force-refresh on first init
      %agent
      [src.bowl dap.bowl]
      %watch
      (weld /next/(scot %da *@da) path.path-row)
    ]
  ==
  =/  log2  (maybe-log hide-logs.state "subbing to {<subs>}")
  =/  cards=(list card)  (weld subs sub-facts)
  [cards state]
::
++  delete-path
::  incoming from host, just need to forward to clients
  |=  [=path state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  :: ensure the path actually exists
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%delete-path: {<path>}")
  =/  path-row=path-row    (~(got by paths.state) path)
  :: ensure this came from host ship
  ?>  =(host.path-row src.bowl)

  =/  log2  (maybe-log hide-logs.state "we either got kicked or the host deleted the whole path: {(spud path)}")

  =/  old-peers=(list peer)  (~(got by peers.state) path)

  :: remove from paths table, and peers table
  =.  paths.state  (~(del by paths.state) path)
  =.  peers.state  (~(del by peers.state) path)
  :: remove from data tables
  =.  tables.state  (del-path-in-tables state path)

  :: add to del-log (implies that the other stuff is also deleted)
  =.  del-log.state   (~(put by del-log.state) now.bowl [%del-path path now.bowl])
  =.  del-log.state
    %-  ~(gas by del-log.state)
    %+  turn  old-peers
    |=(peer [now.bowl %del-peer path ship now.bowl])

  :: emit the change to subscribers
  =/  cards=(list card)
    =/  changes=db-changes
      :-  [%del-path path now.bowl]
      %+  turn  old-peers
      |=(peer [%del-peer path ship now.bowl])
    [%give %fact [/db /db/common (weld /path path) ~] db-changes+!>(changes)]~
  [cards state]
::
++  refresh-path
::~bus/bedrock &db-action [%refresh-path now /path]
  |=  [[t=@da =path] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%refresh-path {(spud path)}")
  :: sanity checking
  =/  path-row=path-row   (~(got by paths.state) path)
  ?>  =(src.bowl host.path-row)
  ?<  =(src.bowl our.bowl) :: ignore requests to refresh from ourself
  :: logic
  ?:  =(t updated-at.path-row)
    `state :: if we are in sync, do nothing
  :: otherwise sub to an intentionally way too old time, so that we get
  :: the full path state updated
  =/  log2  (maybe-log hide-logs.state "we are OUT OF sync, resubbing")
  =/  newpath  (weld /next/~2000.1.1 path)
  =/  cards=(list card)  [%pass newpath %agent [host.path-row dap.bowl] %watch newpath]~
  [cards state]
::
++  keep-alive
::  subs send this to host on a heartbeat to prevent from being skipped
  |=  [=path state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%keep-alive {<src.bowl>} {(spud path)}")
  :: sanity checking
  =/  path-row=path-row   (~(got by paths.state) path)
  =/  old-peers=(list peer)  (~(got by peers.state) path)

  :: send %refresh-path to the peer if he was NOT alive
  =/  behind-peers=(list peer)
    %+  skim
      old-peers
    |=  p=peer
    ^-  ?
    :: WARNING keep logic in sync with `living-peers` method
    ?&  =(ship.p src.bowl)
        (gth (sub now.bowl ~h4) updated-at.p) :: he was >4hrs out of date
    ==
  =/  cards=(list card)
    ?:  =(0 (lent behind-peers))  ~
    ~&  >>>  "{<src.bowl>} was behind, sending %refresh-path"
    [%pass /dbpoke %agent [src.bowl dap.bowl] %poke %db-action !>([%refresh-path updated-at.path-row path])]~

  :: update the updated-at on the peer
  =/  peers=(list peer)
    %+  turn
      old-peers
    |=  p=peer
    ^-  peer
    ?.  =(ship.p src.bowl)
      p
    =.  updated-at.p  now.bowl
    p
  =.  peers.state  (~(put by peers.state) path peers)
  [cards state]
::
++  handle-changes
::  subs receive this from host when database changes
  |=  [[changes=db-changes =path] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  path-row=path-row   (~(got by paths.state) path)
  ?>  =(host.path-row src.bowl)  :: only accept changes from host for now

  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%handle-changes: on {<path>} => {<changes>}")
  =/  touches-common-type=?
    %+  lien
      changes
    |=  c=db-change
    ^-  ?
    ?+  -.c  %.n
      %add-row  (is-common type.row.c)
      %upd-row  (is-common type.row.c)
      %del-row  (is-common type.c)
    ==

  =/  index=@ud           0
  =/  result-cards   *(list card)
  |-
    ?:  =(index (lent changes))
      :: RETURN FINAL RESULT HERE
      :_  state
      :: echo the changes out to our client subs
      ^-  (list card)
      %+  weld
        result-cards
      ^-  (list card)
      =/  sub-paths=(list ^path)
      %+  weld
        `(list ^path)`[/db (weld /path path) ~]
      ^-  (list ^path)
      ?:  touches-common-type  [/db/common ~]
      ~
      [%give %fact sub-paths db-changes+!>(changes)]~
    :: main iterator
    =/  change   (snag index changes)
    :: dependent cards to emit for when %relay stuff happens
    =/  new-scry=(list card)
      ?+  -.change  ~
        %add-row
          ?.  ?=(%relay name.type.row.change)  ~
          ?>  ?=(%relay -.data.row.change)
          =/  uobj=(unit row)  (get-db type.data.row.change path.data.row.change id.data.row.change state)
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
          =/  our-relays=(list row)  (our-matching-relays row.change state bowl)
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
          =/  our-relays=(list row)  (our-matching-relays fakerow state bowl)
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
    :: update state if the change was a relay marking its child deleted
    =.  state
      ?:  ?&  ?=(%upd-row -.change)
              ?=(%relay name.type.row.change)
              ?=(%relay -.data.row.change)
              =(%.y deleted.data.row.change)
          ==
        (del-db type.data.row.change path.data.row.change id.data.row.change state (add now.bowl index))
      state
    :: recur
    %=  $
      index         +(index)
      state         (process-db-change path change state bowl)
      result-cards  (weld (weld result-cards new-scry) pokes)
    ==
::
++  create
::bedrock &db-action [%create [~zod now] /example [%foo 0v3.vumvj.9vf1a.f3lje.d8i4e.vrmeu] 0 [%general ~[1 'a']] ~[['num' 'ud'] ['str' 't']]]
::bedrock &db-action [%create /example %vote 0 [%vote [%.y our %foo [~zod now] /example]] ~]
::bedrock &db-action [%create /example %foo 1 [%general ~[1 'd' (jam /hello/goodbye)]] ~[['num' 'ud'] ['str' 't'] ['mypath' 'path']]]
::~zod/bedrock &db-action [%create /example %vote 0 [%vote %.y our %foo [~zod now] /example] ~]
  |=  [[=req-id =input-row] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log4  (maybe-log hide-logs.state "{<dap.bowl>}%create: {<req-id>} {<input-row>}")
  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]
  :: form row from input
  =/  created-time=@da  
    ?:(=(now.req-id *@da) now.bowl now.req-id)
  =/  creator=ship
    ?:  &(=(our.bowl src.bowl) ?!(=(src.req-id our.bowl)))
      src.req-id
    src.bowl
  :: create with unique id
  ::
  =?  created-time  |((gth created-time now.bowl) (lth (sub now.bowl created-time) ~s30))
    |-
    =/  =id:common  [creator created-time]
    ?~  get=(get-db type.input-row path.input-row id state)
      created-time
    $(created-time +(created-time))
  ::
  =/  row=row  [
    path.input-row
    [creator created-time]
    type.input-row
    data.input-row
    created-time
    created-time
    now.bowl
  ]
  :: ensure the path actually exists
  =/  path-row=path-row    (~(got by paths.state) path.row)
  ?.  (has-create-permissions path-row row state bowl)
    =/  log1  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to create a %{(scow %tas name.type.row)} row where they didn't have permissions")
    [~[kickcard] state]
  :: forward the request if we aren't the host
  ?.  =(host.path-row our.bowl)
    =/  log2  (maybe-log hide-logs.state "{<src.bowl>} tried to have us ({<our.bowl>}) create a row in {<path.path-row>} where we are not the host. forwarding the poke to the host: {<host.path-row>}")
    :_  state
    [%pass /dbpoke %agent [host.path-row dap.bowl] %poke %db-action !>([%create req-id input-row])]~
  :: ensure that the row meets constraints
  ?.  (meets-constraints path-row row state bowl)
    =/  log3  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to create a %{(scow %tas name.type.row)} row where they violated constraints")
    [~[kickcard] state]
  ::

  :: update path
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path.row path-row)

  =.  state             (add-row-to-db row schema.input-row state)

  :: emit the change to subscribers
  =/  thechange=db-changes    [%add-row row schema.input-row]~
  =/  peers=(list peer)       (~(got by peers.state) path.row)
  =/  sub-paths=(list path)
  %+  weld
    `(list path)`[/db (weld /path path.row) ~]
  ^-  (list path)
  ?:  (is-common type.row)  [/db/common ~]
  ~
  =/  cards=(list card)
    :: give vent response
    :-  [%give %fact ~[vent-path] db-vent+!>([%row row schema.input-row])]
    :-  kickcard
    :: tell clients about the new peer
    :-  [%give %fact sub-paths db-changes+!>(thechange)]
    :: tell subs about the new peer
    %+  turn
      (living-peers peers now.bowl our.bowl)
    |=  p=peer
    ^-  card
    (handle-changes-card ship.p thechange path.row)

  [cards state]
::
++  edit  :: falls back to existing db schema if schema from poke input is null
:: generally, you'd only bother passing the schema if you are changing the version of the row
::db &db-action [%edit [our ~2023.5.22..17.21.47..9d73] /example %foo 0 [%general ~[2 'b']] ~]
  |=  [[=req-id =id:common =input-row] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%edit: {<req-id>} {<id>} {<input-row>}")
  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  :: permissions
  =/  old-row              (~(got by (~(got by (~(got by tables.state) type.input-row)) path.input-row)) id) :: old row must first exist
  =/  path-row=path-row    (~(got by paths.state) path.input-row)
  ?.  (has-edit-permissions path-row old-row state bowl)
    =/  log2  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to edit a %{(scow %tas name.type.input-row)} row where they didn't have permissions")
    `state
  :: forward the request if we aren't the host
  ?.  =(host.path-row our.bowl)
    =/  log3  (maybe-log hide-logs.state "{<src.bowl>} tried to have us ({<our.bowl>}) edit a row in {<path.path-row>} where we are not the host. forwarding the poke to the host: {<host.path-row>}")
    :_  state
    [%pass /dbpoke %agent [host.path-row dap.bowl] %poke %db-action !>([%edit req-id id input-row])]~

  :: schema checking
  =/  sch=schema
    ?~  schema.input-row
      (~(got by schemas.state) type.input-row) :: crash if they didn't pass a schema AND we don't already have one
    schema.input-row

  :: cleanup input
  =/  row=row  [
    path.input-row
    id
    type.input-row
    data.input-row
    created-at.old-row
    now.bowl
    now.bowl
  ]

  :: ensure that the row meets constraints
  ?.  (meets-constraints-edit path-row row state bowl)
    =/  log4  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to edit a %{(scow %tas name.type.row)} row where they violated constraints")
    [~[kickcard] state]

  :: update path
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path.path-row path-row)

  =.  state             (add-row-to-db row sch state)

  :: emit the change to subscribers
  =/  thechange=db-changes    [%upd-row row sch]~
  =/  peers=(list peer)       (~(got by peers.state) path.row)
  =/  sub-paths=(list path)
  %+  weld
    `(list path)`[/db (weld /path path.row) ~]
  ^-  (list path)
  ?:  (is-common type.row)  [/db/common ~]
  ~
  =/  cards=(list card)
    :: give vent response
    :-  [%give %fact ~[vent-path] db-vent+!>([%row row sch])]
    :-  kickcard
    :: tell clients about the new peer
    :-  [%give %fact sub-paths db-changes+!>(thechange)]
    :: tell subs about the new peer
    %+  turn
      (living-peers peers now.bowl our.bowl)
    |=  p=peer
    ^-  card
    (handle-changes-card ship.p thechange path.row)

  [cards state]
::
++  remove
::bedrock &db-action [%remove [our now] [%friend 0v0] /private [our ~2023.9.15..19.23.10..46c2]]
  |=  [[=req-id =type:common =path =id:common] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  vent-path=^path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]
  =/  log3  (maybe-log hide-logs.state "{<dap.bowl>}%remove: {<req-id>} {<type>} {<path>} {<id>}")
  :: permissions
  =/  pt                  (~(got by tables.state) type)
  =/  tbl                 (~(got by pt) path)
  =/  old-row             (~(got by tbl) id) :: old row must first exist
  =/  path-row=path-row   (~(got by paths.state) path)
  ?.  (has-delete-permissions path-row old-row state bowl)
    =/  log1  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to delete a %{(scow %tas name.type)} row where they didn't have permissions")
    `state
  :: forward the request if we aren't the host
  ?.  =(host.path-row our.bowl)
    =/  log2  (maybe-log hide-logs.state "{<src.bowl>} tried to have us ({<our.bowl>}) remove a row in {<path.path-row>} where we are not the host. forwarding the poke to the host: {<host.path-row>}")
    :_  state
    [%pass /dbpoke %agent [host.path-row dap.bowl] %poke %db-action !>([%remove req-id type path id])]~

  :: update path
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path path-row)

  :: do the delete
  =.  tbl             (~(del by tbl) id)                :: delete by id
  =.  pt              (~(put by pt) path tbl)           :: update the pathed-table
  =.  tables.state    (~(put by tables.state) type pt)  :: update the tables.state
  =/  log=db-row-del-change    [%del-row path type id now.bowl]
  =.  del-log.state   (~(put by del-log.state) now.bowl log)  :: record the fact that we deleted
  :: TODO remove remote-scry paths for the row

  :: emit the change
  =/  thechange=db-changes    ~[log]
  =/  peers=(list peer)       (~(got by peers.state) path)
  =/  sub-paths=(list ^path)
  %+  weld
    `(list ^path)`[/db (weld /path path) ~]
  ^-  (list ^path)
  ?:  (is-common type)  [/db/common ~]
  ~
  =/  cards=(list card)
    :: give vent response
    :-  [%give %fact ~[vent-path] db-vent+!>([%del-row id type path])]
    :-  kickcard
    :: tell clients about the new peer
    :-  [%give %fact sub-paths db-changes+!>(thechange)]
    :: tell subs about the new peer
    %+  turn
      (living-peers peers now.bowl our.bowl)
    |=  p=peer
    ^-  card
    (handle-changes-card ship.p thechange path)

  [cards state]
::
++  remove-many :: only works on ids from same path
::bedrock &db-action [%remove-many %foo /example [[our ~2023.5.22..19.22.29..d0f7] [our ~2023.5.22..19.22.29..d0f7] ~]]
  |=  [[=req-id =path ids=(list [=id:common =type:common])] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log3  (maybe-log hide-logs.state "{<dap.bowl>}%remove-many {<path>} {<ids>}")
  =/  vent-path=^path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  :: forward the request if we aren't the host
  =/  path-row=path-row   (~(got by paths.state) path)
  ?.  =(host.path-row our.bowl)
    =/  log2  (maybe-log hide-logs.state "{<src.bowl>} tried to remove rows: {<ids>} in {<path.path-row>} where we are not the host. forwarding the poke to the host: {<host.path-row>}")
    :_  state
    [%pass /dbpoke %agent [host.path-row dap.bowl] %poke %db-action !>([%remove-many req-id path ids])]~
  :: permissions
  =/  index=@ud   0
  =/  allowed-ids=(list [=id:common =type:common])   ~
  =.  allowed-ids
    |-
      ?:  =(index (lent ids))
        allowed-ids
      =/  id        (snag index ids)
      =/  pt        (~(got by tables.state) type.id)
      =/  tbl       (~(got by pt) path)
      =/  old-row   (~(got by tbl) id.id) :: old row must first exist
      ?:  (has-delete-permissions path-row old-row state bowl)
        $(index +(index), allowed-ids [id allowed-ids])
      =/  log1  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to delete a row {<id.id>} on {<path>} where they didn't have permissions, skipping it")
      $(index +(index))

  :: update path
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path path-row)

  :: do the delete
  =.  index    0
  =/  logs=(list db-row-del-change)  ~
  |-
    ?:  =(index (lent allowed-ids))
      :: TODO remove remote-scry paths for the row
      =/  last  (snag (dec index) logs)
      :: emit the change
      =/  peers=(list peer)       (~(got by peers.state) path)
      =/  sub-paths=(list ^path)
      %+  weld
        `(list ^path)`[/db (weld /path path) ~]
      ^-  (list ^path)
      ?:  (is-common type.last)  [/db/common ~]
      ~
      =/  cards=(list card)
        :: give vent response
        :-  [%give %fact ~[vent-path] db-vent+!>([%del-row id.last type.last path.last])]
        :-  kickcard
        :: tell clients about the new peer
        :-  [%give %fact sub-paths db-changes+!>(logs)]
        :: tell subs about the new peer
        %+  turn
          (living-peers peers now.bowl our.bowl)
        |=  p=peer
        ^-  card
        (handle-changes-card ship.p logs path)

      [cards state]
    =/  id        (snag index allowed-ids)
    =/  pt        (~(got by tables.state) type.id)
    =/  tbl       (~(del by (~(got by pt) path)) id.id)
    =.  pt        (~(put by pt) path tbl)           :: update the pathed-table
    =/  log=db-row-del-change    [%del-row path type.id id.id (add now.bowl index)]
    %=  $
      index           +(index)
      tables.state    (~(put by tables.state) type.id pt)
      del-log.state   (~(put by del-log.state) (add now.bowl index) log)
      logs            [log logs]
    ==
::
++  remove-before :: similar to TRUNCATE, removes all rows of a given type and path up to and including a certain timestamp
::bedrock &db-action [%remove-before [%foo *@uvH] /example ~2023.5.22..19.22.29..d0f7]
  |=  [[=type:common =path t=@da] state=state-2 =bowl:gall]
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%remove-before {<t>}")
  ^-  (quip card state-2)

  :: forward the request if we aren't the host
  =/  path-row=path-row   (~(got by paths.state) path)
  ?.  =(host.path-row our.bowl)
    =/  log2  (maybe-log hide-logs.state "{<src.bowl>} tried to have us ({<our.bowl>}) %remove-before in {<path.path-row>} where we are not the host. forwarding the poke to the host: {<host.path-row>}")
    :_  state
    [%pass /dbpoke %agent [host.path-row dap.bowl] %poke %db-action !>([%remove-before type path t])]~
  :: permissions
  =/  pt          (~(got by tables.state) type)
  =/  tbl         (~(got by pt) path)
  =/  ids         (skim ~(tap in ~(key by tbl)) |=(k=id:common (lte t.k t)))
  =/  index=@ud   0
  =/  all-have-permission=?
    |-
      ?:  =(index (lent ids))
        %.y
      =/  id        (snag index ids)
      =/  old-row   (~(got by tbl) id) :: old row must first exist
      ?:  (has-delete-permissions path-row old-row state bowl)
        $(index +(index))
      %.n
  ?.  all-have-permission
    =/  log1  (maybe-log hide-logs.state "{(scow %p src.bowl)} tried to delete a %{(scow %tas name.type)} row where they didn't have permissions")
    `state

  :: update path
  =/  foreign-ship-sub-wire   (weld /next/(scot %da updated-at.path-row) path)
  =.  updated-at.path-row     now.bowl
  =.  received-at.path-row    now.bowl
  =.  paths.state             (~(put by paths.state) path path-row)

  :: do the delete
  =.  index    0
  =/  logs=(list db-row-del-change)  ~
  |-
    ?:  =(index (lent ids))
      =.  pt              (~(put by pt) path tbl)           :: update the pathed-table
      =.  tables.state    (~(put by tables.state) type pt)  :: update the tables.state
      :: TODO remove remote-scry paths for the row
      =/  sub-paths=(list ^path)
      %+  weld
        `(list ^path)`[/db (weld /path path) foreign-ship-sub-wire ~]
      ^-  (list ^path)
      ?:  (is-common type)  [/db/common ~]
      ~
      :: emit the change to subscribers
      =/  cards=(list card)  :~
        :: tell subs about the new row
        [%give %fact sub-paths db-changes+!>(logs)]
        :: kick foreign ship subs to force them to re-sub for next update
        [%give %kick [foreign-ship-sub-wire ~] ~]
      ==

      [cards state]
    =/  log=db-row-del-change    [%del-row path type (snag index ids) (add now.bowl index)]
    $(index +(index), tbl (~(del by tbl) (snag index ids)), del-log.state (~(put by del-log.state) (add now.bowl index) log), logs [log logs])
::
++  relay
  :: supposed to be used by the sharer, poking their own ship,
  :: regardless of if they are the host of either original or target path
::bedrock &db-action [%relay [~bus now] /target %relay 0 [%relay [~zod ~2023.6.13..15.57.34..aa97] %foo /example 0 %all %.n] ~]
  |=  [[=req-id =input-row] state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%relay: {<req-id>} {<input-row>}")
  :: first check that the input is actually a %relay
  ?+  -.data.input-row   !!
    %relay 
  :: then force to %all for protocol for now
  =.  protocol.data.input-row    %all
  :: then check that we actually have the thing being relayed
  =/  obj-id=id:common  id.data.input-row
  =/  obj=row  (got-db type.data.input-row path.data.input-row obj-id state)
  :: and its schema
  =/  sch=schema  (~(got by schemas.state) type.obj)
  :: then check if we have already relayed this thing before
  =/  prev=(list row)  (our-matching-relays obj state bowl)

  ?~  prev
    :: if we have not previously relayed this thing, publish to remote-scry
    =/  cards  [%pass /remote-scry/callback %grow /(scot %p ship.obj-id)/(scot %da t.obj-id) row-and-schema+[obj sch]]~
    =.  revision.data.input-row  0 :: force to 0 because we are publishing for first time
    =/  qcs=(quip card state-2)  (create [req-id input-row] state bowl)
    [(weld cards -.qcs) +.qcs]
  :: else, the thing is already published, so use the pre-existing revision number
  =/  first-prev=row             (snag 0 `(list row)`prev)
  ?+  -.data.first-prev  !!
      %relay
    =.  revision.data.input-row  revision.data.first-prev
    (create [req-id input-row] state bowl)
  ==
  ==
::
++  toggle-hide-logs
::bedrock &db-action [%toggle-hide-logs %.n]
  |=  [toggle=? state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =.  hide-logs.state  toggle
  `state
::
++  create-initial-spaces-paths
::  on-init selfpoke
  |=  [state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  spaces-scry   .^(view:sstore %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/all/noun)
  ?>  ?=(%spaces -.spaces-scry)

  =/  index=@ud     0
  =/  keys=(list space-path:sstore)  :: list of space-path we own
    %+  skim
      ~(tap in ~(key by spaces.spaces-scry))
    |=(=space-path:sstore =(ship.space-path our.bowl))

  =/  cs=(quip card state-2)  [~ state]
  |-
    ?:  =(index (lent keys))
      [-.cs +.cs]
    =/  key       (snag index keys)
    =/  pathed    (pathify-space-path:spaces-chat key)
    =/  preexisting=(unit path-row)    (~(get by paths.state) pathed)
    :: if the "main" space path-row already is there, then skip them all
    ?~  preexisting
      ?:  =(space.key 'our')
        =/  mem       (create-from-space [pathed key %member] +.cs bowl)
        $(index +(index), cs [(weld -.cs -.mem) +.mem])
      =/  ini       (create-from-space [(weld pathed /initiate) key %initiate] +.cs bowl)
      =.  cs        [(weld -.cs -.ini) +.ini]
      =/  mem       (create-from-space [pathed key %member] +.cs bowl)
      =.  cs        [(weld -.cs -.mem) +.mem]
      =/  adm       (create-from-space [(weld pathed /admin) key %admin] +.cs bowl)
      =.  cs        [(weld -.cs -.adm) +.adm]
      =/  owr       (create-from-space [(weld pathed /owner) key %owner] +.cs bowl)
      $(index +(index), cs [(weld -.cs -.owr) +.owr])
    $(index +(index))
::
++  refresh-chat-paths
::  macro for chat-db to force bedrock to refresh all the chat-paths
  |=  [state=state-2 =bowl:gall]
  ^-  (quip card state-2)
  =/  log1  (maybe-log hide-logs.state "{<dap.bowl>}%refresh-chat-paths")
  =/  paths=(list path-row)
    %+  skim
      ~(val by paths.state)
    |=  p=path-row
    ?+  path.p  %.n
      [%spaces @ @ %chats @ ~]  %.y
      [%realm-chat @ ~]         %.y
    ==
  =/  cards=(list card)
    %+  turn
      paths
    |=  p=path-row
    ^-  card
    [%pass (weld /next/~2000.1.1 path.p) %agent [host.p dap.bowl] %watch (weld /next/~2000.1.1 path.p)]
  [cards state]
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
      :~  [%add-peer add-peer]
          [%kick-peer kick-peer]
          [%create-path create-path]
          [%create-from-space de-create-from-space]
          [%edit-path create-path]
          [%remove-path pa]
          [%create de-create-input-row]
          [%create-many (ar de-create-input-row)]
          [%edit de-edit-poke]
          [%remove remove]
          [%remove-many remove-many]
          [%remove-before remove-before]
          [%relay de-create-input-row]
      ==
    ::
    ++  de-create-input-row
      |=  jon=json
      ^-  [req-id input-row]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] (de-input-row jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-input-row jon)]
    ::
    ++  de-edit-poke
      |=  jon=json
      ^-  [req-id id:common input-row]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] ((ot ~[[%id de-id] [%input-row de-input-row]]) jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) ((ot ~[[%id de-id] [%input-row de-input-row]]) jon)]
    ::
    ++  add-peer
      |=  jon=json
      ^-  [path ship role (unit [sig=@t addr=@t])]
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  sig   (~(get by p.jon) 'signature')
      =/  psig
      ?~  sig  ~
      (some ((ot ~[sig+so addr+so]) u.sig))
      [
        (pa (gt 'path'))
        (de-ship (gt 'ship'))
        ((se %tas) (gt 'role'))
        psig
      ]
    ::
    ++  kick-peer
      %-  ot
      :~  [%path pa]
          [%ship de-ship]
      ==
    ::
    ++  remove
      |=  jon=json
      ^-  [req-id type:common path id:common]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] (de-remove jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-remove jon)]
    ::
    ++  de-remove
      %-  ot
      :~  [%type de-type]
          [%path pa]
          [%id de-id]
      ==
    ::
    ++  remove-many
      |=  jon=json
      ^-  [req-id path (list [id:common type:common])]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] (de-remove-many jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-remove-many jon)]
    ::
    ++  de-remove-many
      %-  ot
      :~  [%path pa]
          [%ids (ar (ot [[%id de-id] [%type de-type] ~]))]
      ==
    ::
    ++  remove-before
      %-  ot
      :~  [%type de-type]
          [%path pa]
          [%t di]
      ==
    ::
    ++  de-create-from-space
      %-  ot
      :~  [%path pa]
          [%space-path de-space-path]
          [%space-role de-space-role]
      ==
    ::
    ++  create-path
      |=  jon=json
      ^-  input-path-row
      ?>  ?=([%o *] jon)
      =/  urep    (~(get by p.jon) 'replication')
      =/  replication=replication
        ?~  urep
          %host
        (de-replication (need urep))
      =/  udef    (~(get by p.jon) 'default-access')
      =/  default-access 
        ?~  udef
          ~
        (de-access-rules (need udef))
      =/  utbl    (~(get by p.jon) 'table-access')
      =/  table-access 
        ?~  utbl
          ~
        (de-table-access (need utbl))
      =/  uprs    (~(get by p.jon) 'peers')
      =/  prs
        ?~  uprs
          ~
        ((ar (ot ~[[%ship de-ship] [%role (se %tas)]])) (need uprs))
      [
        (pa (~(got by p.jon) 'path'))
        replication
        default-access
        table-access
        ~ :: TODO parse json constraints
        prs
      ]
    ::
    ++  de-table-access
      |=  jon=json
      ^-  table-access
      ?>  ?=([%o *] jon)
      =/  type-keys  ~(tap in ~(key by p.jon))
      =/  kvs
        %+  turn
          type-keys
        |=  k=@t
        ^-  [k=type:common v=access-rules]
        [(de-type s+k) (de-access-rules (~(got by p.jon) k))]
      (~(gas by *table-access) kvs)
    ::
    ++  de-access-rules
      |=  jon=json
      ^-  access-rules
      ?>  ?=([%o *] jon)
      =/  role-keys  ~(tap in ~(key by p.jon))
      =/  kvs
        %+  turn
          role-keys
        |=  k=@t
        ^-  [k=role v=access-rule]
        [`@tas`k (de-access-rule (~(got by p.jon) k))]
      (~(gas by *access-rules) kvs)
    ::
    ++  de-access-rule
      %-  ot
      :~  [%create bo]
          [%edit de-permission-scope]
          [%delete de-permission-scope]
      ==
    ::
    ++  de-replication
      %+  cu
        tas-to-replication
      (se %tas)
    ::
    ++  tas-to-replication
      |=  t=@tas
      ^-  replication
      ?+  t  !!
        %shared-host  %shared-host
        %host         %host
        %gossip       %gossip
      ==
    ::
    ++  de-permission-scope
      %+  cu
        tas-to-permission-scope
      (se %tas)
    ::
    ++  tas-to-permission-scope
      |=  t=@tas
      ^-  permission-scope
      ?+  t  !!
        %table  %table
        %own    %own
        %none   %none
      ==
    ::
    ++  de-input-row
      |=  jon=json
      ^-  input-row
      ?>  ?=([%o *] jon)
      =/  data-type=type:common   (de-type (~(got by p.jon) 'type'))
      =/  schema=schema     ((ar (at ~[so so])) (~(got by p.jon) 'schema'))
      =/  actual-data
        ?+  name.data-type
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %vote
            ?:  =(hash.data-type hash:vote-type:common)
              [%vote (de-vote (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %comment
            ?:  =(hash.data-type hash:comment-type:common)
              [%comment (de-comment (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %relay
            ?:  =(hash.data-type hash:relay-type:common)
              [%relay (de-relay (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %creds
            ?:  =(hash.data-type hash:creds-type:common)
              [%creds (de-creds (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %chat
            ?:  =(hash.data-type hash:chat-type:common)
              [%chat (de-chat (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
          %message
            ?:  =(hash.data-type hash:message-type:common)
              [%message (de-message (~(got by p.jon) 'data'))]
            [%general ((de-cols schema) (~(got by p.jon) 'data'))]
        ==
      [
        (pa (~(got by p.jon) 'path'))
        data-type
        actual-data
        schema
      ]
    ::
    ++  de-cols
      |=  sch=schema
      |=  jon=json
      ^-  (list @)
      ?>  ?=([%a *] jon)
      =/  index=@ud   0
      =/  result      *(list @)
      |-
        ?:  =(index (lent p.jon))
          result
        =/  type-key            t:(snag index sch)
        =/  datatom             (snag index `(list json)`p.jon)
        =/  next=@
          ?:  =(type-key 'rd')    (ne datatom)
          ?:  =(type-key 'ud')    (ni datatom)
          ?:  =(type-key 'da')    (di datatom)
          ?:  =(type-key 'dr')    (dri datatom)
          ?:  =(type-key 't')     (so datatom)
          ?:  =(type-key 'f')     (bo datatom)
          ?:  =(type-key 'p')     ((se %p) datatom)
          ?:  =(type-key 'id')    (jam (de-id datatom))
          ?:  =(type-key 'type')  (jam (de-type datatom))
          ?:  =(type-key 'unit')  (jam (so:dejs-soft:format datatom))
          ?:  =(type-key 'path')  (jam (pa datatom))
          ?:  =(type-key 'list')  (jam ((ar so) datatom))
          ?:  =(type-key 'set')   (jam ((as so) datatom))
          ?:  =(type-key 'map')   (jam ((om so) datatom))
          !!
        $(index +(index), result (snoc result next))
    ::
    ++  de-vote
      %-  ot
      :~  [%up bo]
          [%parent-type de-type]
          [%parent-id de-id]
          [%parent-path pa]
      ==
    ::
    ++  de-creds
      %-  ot
      :~  [%endpoint so]
          [%access-key-id so]
          [%secret-access-key so]
          [%buckets (as so)]
          [%current-bucket so]
          [%region so]
      ==
    ::
    ++  de-comment
      %-  ot
      :~  [%txt so]
          [%parent-type de-type]
          [%parent-id de-id]
          [%parent-path pa]
      ==
    ::
    ++  de-relay
      %-  ot
      :~  [%id de-id]
          [%type de-type]
          [%path pa]
          [%revision ni]
          [%protocol de-relay-protocol]
          [%deleted bo]
      ==
    ::
    ++  de-chat
      %-  ot
      :~  [%metadata (om so)]
          [%type (se %tas)]
          [%pins (as de-id)]
          [%invites (se %tas)]
          [%peers-get-backlog bo]
          [%max-expires-at-duration null-or-dri]
          [%nft (ot ~[contract+so chain+so standard+so]):dejs-soft:format]
      ==
    ::
    ++  de-message
      %-  ot
      :~  [%chat-id de-id]
          [%reply-to (mu path-and-id)]
          [%expires-at da-or-bunt-null]
          [%content (ar de-msg-part)]
      ==
    ::
    ++  de-msg-part
      %-  ot
      :~  [%formatted-text de-formatted-text]
          [%metadata (om so)]
      ==
    ::
    ++  de-formatted-text
      %-  of
      :~  
          [%plain so]
          [%markdown so]
          [%bold so]
          [%italics so]
          [%strike so]
          [%bold-italics so]
          [%bold-strike so]
          [%italics-strike so]
          [%bold-italics-strike so]
          [%blockquote so]
          [%inline-code so]
          [%code so]
          [%image so]
          [%ur-link so]
          [%react so]
          [%break ul]
          [%ship de-ship]
          [%link so]
          [%custom (ot ~[[%name so] [%value so]])]
          [%status so]
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
    ++  path-and-id
      %-  ot
      :~  
          [%path pa]
          [%id de-id]
      ==
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
    ++  de-relay-protocol
      %+  cu
        tas-to-relay-protocol
      (se %tas)
    ::
    ++  tas-to-relay-protocol
      |=  t=@tas
      ^-  relay-protocol:common
      ?+  t  !!
        %static   %static
        %edit     %edit
        %all      %all
      ==
    ::
    ++  de-space-role
      %+  cu
        tas-to-space-role
      (se %tas)
    ::
    ++  tas-to-space-role
      |=  t=@tas
      ^-  role:mstore
      ?+  t  !!
        %initiate   %initiate
        %member     %member
        %admin      %admin
        %owner      %owner
      ==
    ::
    ++  de-ship  (su ;~(pfix sig fed:ag))
    ::
    ++  da-or-bunt-null   :: specify in integer milliseconds, returns a @dr
      |=  jon=json
      ^-  @da
      ?+  jon   !!
        [%n *]  (di jon)
        ~       *@da
      ==
    ::
    ++  dri   :: specify in integer milliseconds, returns a @dr
      (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) ni)
    ::
    ++  null-or-dri   :: specify in integer milliseconds, returns a @dr
      (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) null-or-ni)
    ::
    ++  null-or-ni  :: accepts either a null or a n+'123', and converts nulls to 0, non-null to the appropriate number
      |=  jon=json
      ^-  @ud
      ?+  jon  !!
        [%n *]  (rash p.jon dem)
        ~       0
      ==
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
        %ack   s/%ack
        %row   (en-row row.vent (~(put by *schemas) type.row.vent schema.vent))
        %del-row
          %-  pairs
          :~  ['id' (row-id-to-json id.vent)]
              ['type' (en-db-type type.vent)]
              ['path' s+(spat path.vent)]
          ==
      ==
    ::
    ++  en-db-changes
      |=  chs=db-changes
      ^-  json
      :-  %a
      %+  turn
        chs
      |=  ch=db-change
      ^-  json
      %-  pairs
      ^-  (list [@t json])
      %+  weld
        ^-  (list [@t json])
        ~[['change' [%s -.ch]]]
      ^-  (list [@t json])
      ?-  -.ch
        %add-row
          ~[['row' (en-row row.ch (~(put by *schemas) type.row.ch schema.ch))]]
        %upd-row
          ~[['row' (en-row row.ch (~(put by *schemas) type.row.ch schema.ch))]]
        %del-row
          :~  ['path' s+(spat path.ch)]
              ['type' (en-db-type type.ch)]
              ['id' (row-id-to-json id.ch)]
              ['timestamp' (time t.ch)]
           ==
        %add-peer
          ~[['peer' (en-peer peer.ch)]]
        %upd-peer
          ~[['peer' (en-peer peer.ch)]]
        %del-peer
          :~  ['path' s+(spat path.ch)]
              ['ship' s+(scot %p ship.ch)]
              ['timestamp' (time t.ch)]
           ==
        %add-path
          ~[['path' (en-path-row path-row.ch)]]
        %upd-path
          ~[['path' (en-path-row path-row.ch)]]
        %del-path
          :~  ['path' s+(spat path.ch)]
              ['timestamp' (time t.ch)]
           ==
      ==
    ::
    ++  state
      |=  st=versioned-state
      ^-  json
      ?+  -.st  !!
          %2
        %-  pairs
        :~  ['state-version' (numb `@`-.st)]
            ['data-tables' (en-tables tables.st schemas.st)]
            ['schemas' (en-schemas schemas.st)]
            ['paths' (en-paths paths.st)]
            ['peers' (en-peers peers.st)]
            ['del-log' (en-del-log del-log.st)]
        ==
      ==
    ::
    ++  en-del-log
      |=  =del-log
      ^-  json
      :-  %a
      (turn ~(tap by del-log) en-del-change)
    ::
    ++  en-del-change
      |=  [t=@da ch=db-del-change]
      ^-  json
      =/  default=(list [@t json])
        :~  ['timestamp' (time t)]
            ['change' [%s -.ch]]
        ==
      %-  pairs
      %+  weld
        default
      ^-  (list [@t json])
      ?-  -.ch
        %del-path
          ~[['path' s+(spat path.ch)]]
        %del-peer
          ~[['path' s+(spat path.ch)] ['ship' s+(scot %p ship.ch)]]
        %del-row
          :~  ['path' s+(spat path.ch)]
              ['type' (en-db-type type.ch)]
              ['id' (row-id-to-json id.ch)]
          == 
      ==
    ::
    ++  en-tables
      |=  [=tables =schemas]
      ^-  json
      :-  %a
      %+  turn
        ~(tap by tables)
      |=  [=type:common pt=pathed-table]
      (en-table type pt schemas)
    ::
    ++  en-fullpath-tables
      |=  [tables=(map type:common table) =schemas]
      ^-  json
      :-  %a
      %+  turn
        ~(tap by tables)
      |=  [=type:common =table]
      =/  rows=(list row)  ~(val by table)
      %-  pairs
      :~  ['type' (en-db-type type)]
          ['rows' a+(turn rows |=(=row (en-row row schemas)))]
      ==
    ::
    ++  en-fullpath
      |=  fp=fullpath
      ^-  json
      %-  pairs
      :~  ['path-row' (en-path-row path-row.fp)]
          ['peers' a+(turn peers.fp en-peer)]
          ['tables' (en-fullpath-tables [tables schemas]:fp)]
          ['schemas' (en-schemas schemas.fp)]
          ['dels' a+(turn dels.fp en-del-change)]
      ==
    ::
    ++  en-table
      |=  [=type:common pt=pathed-table =schemas]
      ^-  json
      =/  all-rows=(list row)
        %-  zing
        %+  turn
          ~(val by pt)
        |=  =table
        ^-  (list row)
        ~(val by table)
      %-  pairs
      :~  ['type' (en-db-type type)]
          :-  'rows'
          :-  %a
          %+  turn
            all-rows
          |=  =row
          (en-row row schemas)
      ==
    ::
    ++  en-row
      |=  [=row =schemas]
      ^-  json
      =/  schema  (~(got by schemas) type.row)
      =/  basekvs=(list [@t json])
        :~  path+s+(spat path.row)
            id+(row-id-to-json id.row)
            ['type' (en-db-type type.row)]
            creator+s+(scot %p ship.id.row)
            created-at+(time created-at.row)
            updated-at+(time updated-at.row)
            received-at+(time received-at.row)
        ==
      =/  dynamickvs=(list [@t json])
        ?+  -.data.row  !!
          %general
            =/  index=@ud  0
            =/  result=(list [@t json])  ~
            |-
              ?:  =((lent cols.data.row) index)
                result
              =/  sch  (snag index schema)
              =/  d    (snag index cols.data.row)
              =/  t
:: apply the t.sch as aura to atom
                ?:  =(t.sch 'ud')  (numb `@ud`d)
                ?:  =(t.sch 'rd')  (numbrd `@rd`d)
                ?:  =(t.sch 't')   [%s `@t`d]
                ?:  =(t.sch 'p')   s+(scot %p `@p`d)
                ?:  =(t.sch 'f')   [%b ?:(=(d 0) %.y %.n)] :: @f is ? is flag is loobean is %.y/%.n 0 is true
                ?:  =(t.sch 'da')  (time `@da`d)
                ?:  =(t.sch 'dr')  (time-dr `@dr`d)
                ?:  =(t.sch 'id')    (row-id-to-json ;;(id:common (cue d)))
                ?:  =(t.sch 'type')  (en-db-type ;;(type:common (cue d)))
                ?:  =(t.sch 'unit')  ?~(;;((unit @t) (cue d)) ~ s+(need ;;((unit @t) (cue d))))
                ?:  =(t.sch 'path')  (path ;;(^path (cue d)))
                ?:  =(t.sch 'list')  [%a (turn ;;((list @t) (cue d)) |=(i=@t s+i))]
                ?:  =(t.sch 'set')   [%a (turn ~(tap in ;;((set @t) (cue d))) |=(i=@t s+i))]
                ?:  =(t.sch 'map')   [%o (~(run by ;;((map @t @t) (cue d))) |=(i=@t s+i))]
                !!
              $(index +(index), result [[name.sch t] result])
          %vote
            :~  ['up' b+up.data.row]
                ['parent-type' (en-db-type parent-type.data.row)]
                ['parent-id' (row-id-to-json parent-id.data.row)]
                ['parent-path' s+(spat parent-path.data.row)]
            ==
          %comment
            :~  ['txt' s+txt.data.row]
                ['parent-type' (en-db-type parent-type.data.row)]
                ['parent-id' (row-id-to-json parent-id.data.row)]
                ['parent-path' s+(spat parent-path.data.row)]
            ==
          %relay
            :~  ['id' (row-id-to-json id.data.row)]
                ['parent-type' (en-db-type type.data.row)]
                ['path' s+(spat path.data.row)]
                ['revision' (numb revision.data.row)]
            ==
          %creds
            :~  ['endpoint' s+endpoint.data.row]
                ['access-key-id' s+access-key-id.data.row]
                ['secret-access-key' s+secret-access-key.data.row]
                ['buckets' a+(turn ~(tap in buckets.data.row) |=(t=@t s+t))]
                ['current-bucket' s+current-bucket.data.row]
                ['region' s+region.data.row]
            ==
          %chat
            :~  metadata+(metadata-to-json metadata.data.row)
                ['type' s+type.data.row]
                ['pins' a+(turn ~(tap in pins.data.row) row-id-to-json)]
                ['invites' s+invites.data.row]
                ['peers-get-backlog' b+peers-get-backlog.data.row]
                :: return as integer millisecond duration
                ['max-expires-at-duration' (numb (|=(t=@dr ^-(@ud (mul (div t ~s1) 1.000))) max-expires-at-duration.data.row))]
            ==
          %message
            :~  ['chat-id' (row-id-to-json chat-id.data.row)]
                reply-to+(reply-to-to-json reply-to.data.row)
                expires-at+(time-bunt-null expires-at.data.row)
                ['content' a+(turn content.data.row en-msg-part)]
                ['sender' s+(scot %p ship.id.row)]
            ==
          %friend
            :~  ['ship' s+(scot %p ship.data.row)]
                ['status' s+status.data.row]
                ['pinned' b+pinned.data.row]
                ['mtd' (metadata-to-json mtd.data.row)]
            ==
          %passport
            =/  en-pass  enjs:passport-lib
            :~  ['contact' (en-contact:en-pass contact.data.row)]
                ['ship' s+(scot %p ship.contact.data.row)]
                ['cover' ?~(cover.data.row ~ s+u.cover.data.row)]
                ['user-status' s+user-status.data.row]
                ['discoverable' b+discoverable.data.row]
                ['nfts' a+(turn nfts.data.row en-linked-nft:en-pass)]
                ['addresses' a+(turn addresses.data.row en-linked-address:en-pass)]
                ['default-address' s+default-address.data.row]
                ['recommendations' a+(turn ~(tap in recommendations.data.row) en-recommendation:en-pass)]
                ['chain' a+(turn chain.data.row en-link-container:en-pass)]
                ['crypto' (en-p-crypto:en-pass crypto.data.row)]
            ==
          %contact
            :~  ['ship' s+(scot %p ship.data.row)]
                ['avatar' (en-avatar:enjs:passport-lib avatar.data.row)]
                ['color' ?~(color.data.row ~ s+u.color.data.row)]
                ['bio' ?~(bio.data.row ~ s+u.bio.data.row)]
                ['display-name' ?~(display-name.data.row ~ s+u.display-name.data.row)]
            ==
        ==
      =/  keyvals
        :_  basekvs
        data+(pairs dynamickvs)
      (pairs keyvals)
    ::
    ++  en-path-row
      |=  =path-row
      ^-  json
      %-  pairs
      :~  ['path' (path path.path-row)]
          ['host' s+(scot %p host.path-row)]
          ['replication' s+(scot %tas replication.path-row)]
          ['default-access' (en-access-rules default-access.path-row)]
          ['table-access' (en-table-access table-access.path-row)]
          ['constraints' ~]  :: TODO actually do json conversion for constraints
          ['created-at' (time created-at.path-row)]
          ['updated-at' (time updated-at.path-row)]
          ['received-at' (time received-at.path-row)]
      ==
    ::
    ++  en-table-access
      |=  =table-access
      ^-  json
      =/  kvs
        %+  turn
          ~(tap by table-access)
        |=  [k=type:common v=access-rules]
        ^-  [k=@t v=json]
        [(spat /(scot %tas name.k)/(scot %uv hash.k)) (en-access-rules v)]

      :-  %o
      `(map @t json)`(~(gas by *(map @t json)) kvs)
    ::
    ++  en-access-rules
      |=  =access-rules
      ^-  json
      :-  %o
      `(map @t json)`(~(run by access-rules) en-access-rule)
    ::
    ++  en-access-rule
      |=  =access-rule
      ^-  json
      %-  pairs
      :~  ['create' b+create.access-rule]
          ['edit' s+edit.access-rule]
          ['delete' s+delete.access-rule]
      ==
    ::
    ++  en-peer
      |=  =peer
      ^-  json
      %-  pairs
      :~  ['path' (path path.peer)]
          ['ship' s+(scot %p ship.peer)]
          ['role' s+(scot %tas role.peer)]
          ['created-at' (time created-at.peer)]
          ['updated-at' (time updated-at.peer)]
          ['received-at' (time received-at.peer)]
      ==
    ::
    ++  en-paths
      |=  =paths
      ^-  json
      :-  %a
      (turn ~(val by paths) en-path-row)
    ::
    ++  en-peers
      |=  =peers
      ^-  json
      :-  %a
      (turn `(list peer)`(zing ~(val by peers)) en-peer)
    ::
    ++  en-schemas
      |=  =schemas
      ^-  json
      :-  %a
      (turn ~(tap by schemas) en-schema-kv)
    ::
    ++  en-schema-kv
      |=  [=type:common v=schema]
      ^-  json
      %-  pairs
      :~  ['type' (en-db-type type)]
          ['schema' a+(turn v |=(col=[name=@t t=@t] (pairs ~[['name' s+name.col] ['type' s+t.col]])))]
      ==
    ::
    ++  en-msg-part
      |=  =msg-part:common
      %-  pairs
      :~  content-type+(ft-typeify formatted-text.msg-part)
          metadata+(metadata-to-json metadata.msg-part)
          content-data+(ft-dataify formatted-text.msg-part)
      ==
    ::
    ++  ft-typeify
      |=  =formatted-text:common
      ^-  json
      ?+  -.formatted-text
        ::default here
        [%s `@t`-.formatted-text]
        %custom  [%s `@t`-.+.formatted-text]
      ==
    ::
    ++  ft-dataify
      |=  =formatted-text:common
      ?+  -.formatted-text
        ::default here
        [%s +.formatted-text]
        %ship     [%s `@t`(scot %p p.formatted-text)]
        %break    ~
        %custom   [%s +.+.formatted-text]
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
    ++  reply-to-to-json
      |=  reply-to=u-path-id:common
      ^-  json
      ?~  reply-to
        ~
      %-  pairs
      :~  path+[%s (spat -.u.reply-to)]
          id+(row-id-to-json +.u.reply-to)
      ==
    ::
    ++  metadata-to-json
      |=  m=(map cord cord)
      ^-  json
      o+(~(rut by m) |=([k=cord v=cord] s+v))
    ::
    ++  time-bunt-null
      |=  t=@da
      ?:  =(t *@da)
        ~
      (time t)
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
++  transform-tables-0-to-tables
  |=  [old=tables-0 s=schemas-0]
  ^-  tables-1
  =/  new=tables-1  *tables-1
  =/  all-rows=(list row-1)
    %-  zing
    %+  turn
      ~(val by old)
    |=  pt=pathed-table-0
    ^-  (list row-1)
    %-  zing
    %+  turn
      ~(val by pt)
    |=  t=table-0
    ^-  (list row-1)
    %+  turn
      ~(val by t)
    |=  r=row-0
    ^-  row-1
    =/  hash=@uvH   (hash-for-type type.r (~(get by s) [type.r v.r]))
    [
      path.r
      id.r
      [type.r hash]
      (cols-0-to-cols data.r s)
      created-at.r
      updated-at.r
      received-at.r
    ]
  |-
    ?:  =(0 (lent all-rows))
      new
    =/  rw=row-1  (snag 0 all-rows)
    =.  new
      ?:  (~(has by new) type.rw)
        =/  ptbl    (~(got by new) type.rw)
        ?:  (~(has by ptbl) path.rw)
          :: type + path already exist so just update them
          =/  tbl     (~(got by ptbl) path.rw)
          =.  tbl     (~(put by tbl) id.rw rw)
          =.  ptbl    (~(put by ptbl) path.rw tbl)
          (~(put by new) type.rw ptbl)
        :: new path in existing type-tbl
        =/  tbl     (~(put by *table-1) id.rw rw)
        =.  ptbl    (~(put by ptbl) path.rw tbl)
        (~(put by new) type.rw ptbl)
      :: new type, initialize both type and path
      =/  tbl     (~(put by *table-1) id.rw rw)
      =/  ptbl    (~(put by *pathed-table-1) path.rw tbl)
      (~(put by new) type.rw ptbl)

    $(new new, all-rows +.all-rows)
::
++  hash-for-type
  |=  [name=type-prefix:common sch=(unit schema)]
  ^-  @uvH
  ?~  sch
    ?+  name      (sham ~)
        %vote     0v0
        %rating   0v0
        %comment  0v0
        %tag      0v0
        %link     0v0
        %follow   0v0
        %relay    0v0
        %react    0v0
        %creds    0v0
    ==
  (sham u.sch)
::
++  cols-0-to-cols
  |=  [cols=columns-0 s=schemas-0]
  ^-  columns-1
  ?-  -.cols
      %general
    cols
      %vote
    =/  hash=@uvH   (hash-for-type parent-type.cols (~(get by s) [parent-type.cols 0]))
    [%vote up.cols [parent-type.cols hash] parent-id.cols parent-path.cols]
      %rating
    =/  hash=@uvH   (hash-for-type parent-type.cols (~(get by s) [parent-type.cols 0]))
    [%rating value.cols max.cols format.cols [parent-type.cols hash] parent-id.cols parent-path.cols]
      %comment
    =/  hash=@uvH   (hash-for-type parent-type.cols (~(get by s) [parent-type.cols 0]))
    [%comment txt.cols [parent-type.cols hash] parent-id.cols parent-path.cols]
      %react
    =/  hash=@uvH   (hash-for-type parent-type.cols (~(get by s) [parent-type.cols 0]))
    [%react react.cols [parent-type.cols hash] parent-id.cols parent-path.cols]
      %tag
    =/  hash=@uvH   (hash-for-type parent-type.cols (~(get by s) [parent-type.cols 0]))
    [%tag tag.cols [parent-type.cols hash] parent-id.cols parent-path.cols]
      %link
    =/  hash1=@uvH   (hash-for-type from-type.cols (~(get by s) [from-type.cols 0]))
    =/  hash2=@uvH   (hash-for-type to-type.cols (~(get by s) [to-type.cols 0]))
    [%link key.cols [from-type.cols hash1] from-id.cols from-path.cols [to-type.cols hash2] to-id.cols to-path.cols]
      %follow
    cols
      %relay
    =/  hash=@uvH   (hash-for-type type.cols (~(get by s) [type.cols 0]))
    [%relay id.cols [type.cols hash] path.cols revision.cols protocol.cols deleted.cols]
      %creds
    cols
  ==
::
++  transform-schemas-0-to-schemas
  |=  [old=schemas-0]
  ^-  schemas
  =/  new=schemas  *schemas
  =/  kvs          ~(tap by old)
  |-
    ?:  =(0 (lent kvs))
      new
    =/  k=[type=type-prefix:common v=@ud]  -:(snag 0 kvs)
    =/  v=schema  +:(snag 0 kvs)
    =/  new-key=type:common  [type.k (sham v)]
    $(kvs +.kvs, new (~(put by new) new-key v))
::
++  transform-del-log-0-to-del-log
  |=  [old=del-log-0 schs=schemas-0]
  ^-  del-log
  =/  new=del-log  *del-log
  =/  kvs          ~(tap by old)
  |-
    ?:  =(0 (lent kvs))
      new
    =/  k=@da               -:(snag 0 kvs)
    =/  v=db-del-change-0   +:(snag 0 kvs)
    =/  new-val=db-del-change
      ?-  -.v
          %del-peer  v
          %del-path  v
          %del-row
        =/  hash=@uvH
          (hash-for-type type.v (~(get by schs) [type.v 0])) :: only works assuming everything is still at v0
        [%del-row path.v [type.v hash] id.v t.v]
      ==
    $(kvs +.kvs, new (~(put by new) k new-val))
::
++  transform-paths-0-to-paths
  |=  old=paths-0
  ^-  paths
  =/  new=paths  *paths
  =/  kvs        ~(tap by old)
  |-
    ?:  =(0 (lent kvs))
      new
    =/  k=path         -:(snag 0 kvs)
    =/  v=path-row-0   +:(snag 0 kvs)
    =/  new-val=path-row
      [
        path.v
        host.v
        replication.v
        default-access.v
        ~
        ~
        space.v
        created-at.v
        updated-at.v
        received-at.v
      ]
    $(kvs +.kvs, new (~(put by new) k new-val))
::
++  transform-tables-1-to-tables
  |=  [old=tables-1]
  ^-  tables
  =/  new=tables  *tables
  =/  all-rows=(list row)
    %-  zing
    %+  turn
      ~(val by old)
    |=  pt=pathed-table-1
    ^-  (list row)
    %-  zing
    %+  turn
      ~(val by pt)
    |=  t=table-1
    ^-  (list row)
    %+  turn
      ~(val by t)
    |=  r=row-1
    ^-  row
    [
      path.r
      id.r
      type.r
      (cols-1-to-cols data.r)
      created-at.r
      updated-at.r
      received-at.r
    ]
  |-
    ?:  =(0 (lent all-rows))
      new
    =/  rw=row  (snag 0 all-rows)
    =.  new
      ?:  (~(has by new) type.rw)
        =/  ptbl    (~(got by new) type.rw)
        ?:  (~(has by ptbl) path.rw)
          :: type + path already exist so just update them
          =/  tbl     (~(got by ptbl) path.rw)
          =.  tbl     (~(put by tbl) id.rw rw)
          =.  ptbl    (~(put by ptbl) path.rw tbl)
          (~(put by new) type.rw ptbl)
        :: new path in existing type-tbl
        =/  tbl     (~(put by *table) id.rw rw)
        =.  ptbl    (~(put by ptbl) path.rw tbl)
        (~(put by new) type.rw ptbl)
      :: new type, initialize both type and path
      =/  tbl     (~(put by *table) id.rw rw)
      =/  ptbl    (~(put by *pathed-table) path.rw tbl)
      (~(put by new) type.rw ptbl)

    $(new new, all-rows +.all-rows)
::
++  cols-1-to-cols
  |=  [cols=columns-1]
  ^-  columns
  ?-  -.cols
    %general    cols
    %vote       cols
    %rating     cols
    %comment    cols
    %tag        cols
    %link       cols
    %follow     cols
    %relay      cols
    %react      cols
    %creds      cols
    %message    cols
    %passport   cols
    %friend     cols
    %contact    cols
    %chat
  [
    %chat
    metadata.cols
    type.cols
    pins.cols
    invites.cols
    peers-get-backlog.cols
    max-expires-at-duration.cols
    ~
  ]
  ==
::
--
