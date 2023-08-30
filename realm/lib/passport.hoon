::  db [realm]:
::  TODO:
::  - constraints via paths-table settings
/-  *passport, common, db
|%
::
:: helpers
::
++  maybe-log
  |=  [hide-debug=? msg=tape]
  ?:  =(%.y hide-debug)  ~
  ~&  msg
  ~
::
:: pokes
++  add-link
::passport &passport-action [%add-link passport-link]
  |=  [[=req-id:db ln=passport-link:common] state=state-0 =bowl:gall]
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
      ==
    ::
    ++  add-link
      |=  jon=json
      ^-  [req-id input-row]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ?~  request-id
        [[~zod ~2000.1.1] (de-add-link jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-add-link jon)]
    ::
    ++  add-link
      %-  ot
      :~  [%path pa]
          [%ship de-ship]
          [%role (se %tas)]
      ==
    ::
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
          %1
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
++  transform-tables-0-to-tables
  |=  [old=tables-0 s=schemas-0]
  ^-  tables
  =/  new=tables  *tables
  =/  all-rows=(list row)
    %-  zing
    %+  turn
      ~(val by old)
    |=  pt=pathed-table-0
    ^-  (list row)
    %-  zing
    %+  turn
      ~(val by pt)
    |=  t=table-0
    ^-  (list row)
    %+  turn
      ~(val by t)
    |=  r=row-0
    ^-  row
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
++  hash-for-type
  |=  [name=type-prefix:common sch=(unit schema)]
  ^-  @uvH
  ?~  sch
    ?+  name      (sham ~)
        %vote     (sham -:!>(*vote:common))
        %rating   (sham -:!>(*rating:common))
        %comment  (sham -:!>(*comment:common))
        %tag      (sham -:!>(*tag:common))
        %link     (sham -:!>(*link:common))
        %follow   (sham -:!>(*follow:common))
        %relay    (sham -:!>(*relay:common))
        %react    (sham -:!>(*react:common))
        %creds    (sham -:!>(*creds:common))
    ==
  (sham u.sch)
::
++  cols-0-to-cols
  |=  [cols=columns-0 s=schemas-0]
  ^-  columns
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
--
