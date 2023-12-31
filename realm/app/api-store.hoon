::  app/api-store.hoon
/-  *api-store, db, common
/+  dbug, scries=bedrock-scries
=|  state-0
=*  state  -
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      core  ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  default-state=state-0   *state-0
    =/  default-cards=(list card)
      :~  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %api-store-action !>([%sync-to-bedrock ~])]
          [%pass /storage %agent [our.bowl %storage] %watch /all]
      ==
    [default-cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    =/  default-cards=(list card)
      :~  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %api-store-action !>([%sync-to-bedrock ~])]
      ==
    =.  default-cards
      ?:  =(wex.bowl ~)  
        :-  [%pass /storage %agent [our.bowl %storage] %watch /all]
        default-cards
      default-cards
    [default-cards this(state old)]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%api-store-action mark)
    =/  act  !<(action vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      %sync-to-bedrock
        (sync-to-bedrock:core state)
      %set-creds
        (set-creds:core +.act state)
    ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    `this
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    ::
      [%x %configuration ~]
        =/  fp=fullpath:db  .^(fullpath:db %gx /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/path/private/noun)
        =/  ucreds=(unit table:db)  (~(get by tables.fp) creds-type:common)
        ?~  ucreds
          ``api-store-configuration+!>([%configuration ~ '' '' ~])
        =/  creds=row:db  (snag 0 (sort ~(val by u.ucreds) |=([a=row:db b=row:db] (gth t.id.a t.id.b))))
        ?+  -.data.creds  !!
            %creds
          ``api-store-configuration+!>([%configuration buckets.data.creds current-bucket.data.creds region.data.creds ~])
        ==
    ::
      [%x %credentials ~]
        =/  fp=fullpath:db  .^(fullpath:db %gx /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/path/private/noun)
        =/  ucreds=(unit table:db)  (~(get by tables.fp) creds-type:common)
        ?~  ucreds
          ``api-store-credentials+!>(['credentials' '' '' ''])
        =/  creds=row:db  (snag 0 (sort ~(val by u.ucreds) |=([a=row:db b=row:db] (gth t.id.a t.id.b))))
        ?+  -.data.creds  !!
            %creds
          ``api-store-credentials+!>(['credentials' endpoint.data.creds access-key-id.data.creds secret-access-key.data.creds])
        ==
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  `this
      [%storage ~]
    ~&  >  "got new creds from %storage agent, syncing to bedrock"
    :_  this  
    [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %api-store-action !>([%sync-to-bedrock ~])]~
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ~&  "Unsubscribe by: {<src.bowl>} on: {<path>}"
    `this
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    `this
  ::
  ++  on-fail
    |=  [=term =tang]
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
  --
|_  [=bowl:gall cards=(list card)]
::
++  core  .
++  sync-to-bedrock
::api-store &api-store-action [%sync-to-bedrock ~]
  |=  [state=state-0]
  ^-  (quip card state-0)
  =/  s3-store=store-results
    ?:  .^(? %gu /(scot %p our.bowl)/s3-store/(scot %da now.bowl)/$)
      ;;([@t @t @t @t] .^(* %gx /(scot %p our.bowl)/s3-store/(scot %da now.bowl)/credentials/noun))
    ['' '' '' '']
  =/  storage=store-results  ;;([@t @t @t @t] .^(* %gx /(scot %p our.bowl)/storage/(scot %da now.bowl)/credentials/noun))
  =/  s3-conf=store-conf
    ?:  .^(? %gu /(scot %p our.bowl)/s3-store/(scot %da now.bowl)/$)
      ;;(store-conf [.^(* %gx /(scot %p our.bowl)/s3-store/(scot %da now.bowl)/configuration/noun) ~])
    [%configuration ~ '' '' ~]
  =/  stoconf=store-conf  ;;(store-conf .^(* %gx /(scot %p our.bowl)/storage/(scot %da now.bowl)/configuration/noun))
  =/  merged=[%creds @t @t @t (set @t) @t @t]
      [
        %creds
        ?:(=('' endpoint.s3-store) endpoint.storage endpoint.s3-store)
        ?:(=('' access-key-id.s3-store) access-key-id.storage access-key-id.s3-store)
        ?:(=('' secret-access-key.s3-store) secret-access-key.storage secret-access-key.s3-store)
        ?:(=(~ buckets.s3-conf) buckets.stoconf buckets.s3-conf)
        ?:(=('' current-bucket.s3-conf) current-bucket.stoconf current-bucket.s3-conf)
        ?:(=('' region.s3-conf) region.stoconf region.s3-conf)
      ]
  =/  creds  [%create [our.bowl now.bowl] [/private creds-type:common merged ~]]
  =/  cards=(list card)
  ?:  (test-bedrock-path-existence:scries /private bowl)
    ?:  (test-bedrock-table-existence:scries creds-type:common bowl)
      =/  del-old-creds=(list card)
        %+  turn
          (all-rows-by-path-type:scries creds-type:common /private bowl)
        |=  r=row:db
        ^-  card
        ~&  id.r
        ?+  -.data.r  !!
          %creds
        [
          %pass
          /dbpoke
          %agent
          [our.bowl %bedrock]
          %poke
          %db-action
          !>([%remove [our.bowl now.bowl] creds-type:common path.r id.r])
        ]
        ==
      :-  [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>(creds)]
      del-old-creds
    :~  [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>(creds)]
    ==
  =/  private-path  [%create-path /private %host ~ ~ ~ [our.bowl %host]~]
  :~  [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>(private-path)]
      [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>(creds)]
  ==
  [cards state]
::
++  set-creds
::api-store &api-store-action [%set-creds set-storage-agent=%.y 'endpoint' 'access-key-id' 'secret-access-key' (silt ['bucket1' ~]) 'current-bucket' 'region']
  |=  [[set-storage-agent=? =creds:common] state=state-0]
  ^-  (quip card state-0)

  =/  creds  [%create [our.bowl *@da] [/private creds-type:common [%creds creds] ~]]

  =/  cards=(list card)  
  :~  [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>(creds)]
  ==

  =.  cards
  ?.  &(.^(? %gu /(scot %p our.bowl)/storage/(scot %da now.bowl)/$) set-storage-agent)
    cards
  =/  stoconf=store-conf  ;;(store-conf .^(* %gx /(scot %p our.bowl)/storage/(scot %da now.bowl)/configuration/noun))
  %+  weld
    %+  weld  cards
    %+  weld
      %+  turn  ~(tap in buckets.stoconf)
      |=  b=@t
      (stor-poke !>([%remove-bucket b]))
    %+  turn  ~(tap in buckets.creds)
    |=  b=@t
    (stor-poke !>([%add-bucket b]))
  :~  (stor-poke !>([%set-endpoint endpoint.creds]))
      (stor-poke !>([%set-access-key-id access-key-id.creds]))
      (stor-poke !>([%set-secret-access-key secret-access-key.creds]))
      (stor-poke !>([%set-current-bucket current-bucket.creds]))
      (stor-poke !>([%set-region region.creds]))
  ==

  [cards state]

++  stor-poke
  |=  =vase
  ^-  card
  [%pass /dbpoke %agent [our.bowl %storage] %poke %storage-action vase]
--
