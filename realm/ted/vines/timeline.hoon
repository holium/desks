/-  spider
/+  *ventio, t=timeline, db, cd=chat-db, server, scries=bedrock-scries
=>  |%
    +$  gowl  bowl:gall
    +$  sowl  bowl:spider
    --
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=+  !<(req=(unit [gowl request]) arg)
?~  req  (strand-fail %no-arg ~)
=/  [=gowl vid=vent-id =mark =noun]  u.req
;<  =vase  bind:m  (unpage mark noun)
::
;<  ~  bind:m  (trace %running-timeline-vine ~)
::
|^
?+    mark  (just-poke [our dap]:gowl mark vase) :: poke normally
    %handle-http-request
  =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
  ;<  cat=(unit simple-payload:http)  bind:m
    (catch-public-scry url.request.req)
  ?^  cat
    =+  handle-http-response+!>([eyre-id u.cat])
    ;<  ~  bind:m  (poke [our dap]:gowl -)
    (pure:m !>(~))
  :: watch the http-response path on docket
  ::
  =/  docket-path  /http-response/[eyre-id]
  ;<  ~  bind:m  (watch docket-path [our.gowl %docket] docket-path)
  :: poke %docket with a spoofed %handle-http-request
  ::
  ~&  [url.request.req (authenticate url.request.req)]
  ::
  ;<  aut=?  bind:m  (authenticate url.request.req)
  =?  req  aut  req(authenticated &)
  =+  handle-http-request+!>([eyre-id req])
  ;<  ~  bind:m  (poke [our.gowl %docket] -)
  :: accept the response
  ::
  ;<  a=cage    bind:m  (take-fact docket-path)
  ;<  b=cage    bind:m  (take-fact docket-path)
  ;<  ~         bind:m  (take-kick docket-path)
  :: propagate this back to eyre
  ::
  =+  handle-http-response+!>([eyre-id (extract-simple-payload a b)])
  ;<  ~  bind:m  (poke [our dap]:gowl -)
  (pure:m !>(~))
  ::
    %timeline-action
  =+  !<(axn=action:t vase)
  ?-    -.axn
      %create-timeline
    ?>  =(src our):gowl
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    ?:  (test-bedrock-path-existence:scries path gowl)
      ~&  >>  %timeline-already-exists
      (pure:m !>([~[%timeline-already-exists] [%timeline path]]))
    =|  row=input-path-row:db
    =:  path.row         path
        replication.row  %host
        peers.row        ~[[our.gowl %host]]
      ==
    :: create the timeline path in bedrock
    ::
    ;<  ~  bind:m
      (poke [our.gowl %bedrock] db-action+!>([%create-path row]))
    :: add the %timeline entry at this path
    ::
    =/  =cage
      :-  %db-action  !>
      :*  %create  [our now]:gowl
          path     [%timeline 0v0]
          :: for now defaults to public: true
          [%timeline ~ &]  ~
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    :: return created path
    ::
    (pure:m !>(`[%timeline path]))
    ::
      %delete-timeline
    ?>  =(src our):gowl
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    ?.  (test-bedrock-path-existence:scries path gowl)
      ~&  >>  %timeline-does-not-exist
      (pure:m !>([~[%timeline-does-not-exist] ~]))
    =/  =cage  db-action+!>([%delete-path path])
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %follow-timeline
    ?>  =(src our):gowl
    =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
    =/  =cage  db-action+!>([%handle-follow-request name])
    ;<  ~  bind:m  (poke [(slav %p host) %bedrock] cage)
    (pure:m !>(`~))
    ::
      %handle-follow-request
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    :: TODO: check that the timeline is public
    =/  =cage  db-action+!>([%add-peer path src.gowl %$])
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %leave-timeline
    ?>  =(src our):gowl
    =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
    =/  =cage  db-action+!>([%handle-leave-request name])
    ;<  ~  bind:m  (poke [(slav %p host) %bedrock] cage)
    (pure:m !>(`~))
    ::
      %handle-leave-request
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    =/  =cage  db-action+!>([%kick-peer path src.gowl])
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %create-timeline-posts
    =/  =cage
      :-  %db-action  !>
      :-  %create-many
      %+  turn  posts.axn
      |=  post=timeline-post:t
      :*  [our now]:gowl  path.axn
          [%timeline-post 0v0]
          [%timeline-post post]  ~
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %create-timeline-post
    =/  =action:db
      :-  %create
      :*  [our now]:gowl  path.axn
          [%timeline-post 0v0]
          [%timeline-post post.axn]  ~
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    (pure:m !>(?>(?=(%row -.vnt) `[%timeline-post +.vnt])))
    ::
      %delete-timeline-post
    =/  =action:db
      :*  %remove   [our now]:gowl
          [%timeline-post 0v0]  path.axn  id.axn
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    ?>  ?=(%ack -.vnt)
    (pure:m !>(`~))
    ::
      %relay-timeline-post
    =|  printf=wain
    |-
    ?~  to.axn  (pure:m !>([printf ~]))
    =/  =relay:common:db  [id [%timeline-post 0v0] from 0 %all |]:axn
    =/  row=input-row:db  [i.to.axn [%relay 0v0] [%relay relay] ~]
    ;<  =sowl  bind:m  get-bowl
    =/  =action:db  [%relay [our now]:sowl row]
    ;<  out=thread-result  bind:m  (run-thread-soft %realm %venter !>(`action))
    ?-    -.out
        %&
      =+  ;;(vnt=vent:db q.p.out)
      ?>  ?=(%ack -.vnt)
      $(to.axn t.to.axn)
      ::
        %|
      ~&  >>>  failed+(spat i.to.axn)
      %=  $
        to.axn  t.to.axn
        printf  [(vase-to-cord !>(failed+(spat i.to.axn))) printf]
      ==
    ==
    ::
      %create-react
    =/  =action:db
      :*  %create   [our now]:gowl
          path.axn  [%react 0v0]
          [%react react.axn]  ~
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    (pure:m !>(?>(?=(%row -.vnt) `[%react +.vnt])))
    ::
      %delete-react
    =/  =action:db
      :*  %remove  [our now]:gowl
          [%react 0v0]  path.axn  id.axn
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    ?>  ?=(%ack -.vnt)
    (pure:m !>(`~))
    ::
      %create-comment
    =/  =action:db
      :*  %create   [our now]:gowl
          path.axn  [%comment 0v0]
          [%comment comment.axn]  ~
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    (pure:m !>(?>(?=(%row -.vnt) `[%comment +.vnt])))
    ::
      %delete-comment
    =/  =action:db
      :*  %remove  [our now]:gowl
          [%comment 0v0]  path.axn  id.axn
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    ?>  ?=(%ack -.vnt)
    (pure:m !>(`~))
    ::
      %convert-message
    ;<  post=(unit [req-id=[@p @da] post=timeline-post:t])  bind:m
      (convert-chat-db-msg-part [msg-id msg-part-id]:axn)
    ?~  post
      ~&(>>> %failed-to-process-message-part !!)
    =/  =action:db
      :*  %create  req-id.u.post
          to.axn  [%timeline-post 0v0]
          [%timeline-post post.u.post]  ~
      ==
    ;<  out=^vase  bind:m  (run-thread %realm %venter !>(`action))
    =+  ;;(vnt=vent:db q.out)
    (pure:m !>(?>(?=(%row -.vnt) `[%timeline-post +.vnt])))
    ::
      %add-forerunners-bedrock
    =/  fore=path  /spaces/~lomder-librun/realm-forerunners/chats/0v2.68end.ets6m.29fgc.ntejl.jbeo7
    =/  db-fore=path  /timeline/(scot %p our.gowl)/forerunners
    ?:  &(!force.axn (test-bedrock-path-existence:scries db-fore gowl))
      ~&  >>  %forerunners-timeline-already-exists
      (pure:m !>([~[%forerunners-timeline-already-exists] ~]))
    ;<  *  bind:m
      ((vent ,*) [our dap]:gowl timeline-action+[%create-timeline %forerunners])
    ;<  posts=(list [[@p @da] timeline-post:t])  bind:m
      (convert-chat-db-msg-parts fore)
    =/  =cage
      :-  %db-action  !>
      :-  %create-many
      %+  turn  posts
      |=  [req-id=[@p @da] post=timeline-post:t]
      :*  req-id
          db-fore  [%timeline-post 0v0]
          [%timeline-post post]  ~
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %add-random-emojis
    ;<  ids=(list id:common:db)  bind:m  (timeline-post-ids path.axn)
    =/  =cage
      :-  %db-action  !>
      :-  %create-many
      %-  zing
      %+  turn  ids
      |=  =id:common:db
      %+  turn  (random-reacts:t path.axn id)
      |=  =react:common:db
      :-  [our now]:gowl
      :*  path.axn  [%react 0v0]
          [%react react]  ~
      ==
    ~&  >   %done-creating-emojis
    ~&  >>  %poking-bedrock-with-create-many
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(`~))
    ::
      %scry-test
    ~&  >>  %scrying
    ;<  ~  bind:m  (poke [our.gowl %venter] fail-scry+!>(~))
    ~&  >>  %we-scried
    (pure:m !>([~[%hello] ~]))
    ::
      %crash-test
    ~&  %crash-test
    =|  idx=@ud
    |-
    ;<  a=$-(@ud ^)  bind:m
      (scry-hard ,$-(@ud ^) /gx/timeline/func-scry/noun)
    ?:  =(idx 100)
      ~&  >>  %we-got-here
      ~&  [idx a+(a 43)]
      (pure:m !>(`~))
    $(idx +(idx))
  ==
==
::
++  bedrock-state
  =/  m  (strand ,state-1:db)
  ^-  form:m
  (scry state-1:db /gx/bedrock/db/db-state)
:: accepts trailing fas
::
++  purl  |=(url=@t (rash url ;~(pfix fas (most fas urs:ab))))
::
++  catch-public-scry
  |=  url=@t
  =/  =(pole knot)  (purl url)
  =/  m  (strand ,(unit simple-payload:http))
  ^-  form:m
  ?.  ?=([%apps %timeline %scry %timeline host=@ta name=@ta ~] pole)
    (pure:m ~)
  ;<  pub=simple-payload:http  bind:m
    (give-public-scry [(slav %p host.pole) name.pole])
  (pure:m `pub)
::
++  fullpath
  |=  [host=ship name=@ta]
  =/  m  (strand ,fullpath:db)
  ^-  form:m
  (scry fullpath:db /gx/bedrock/db/path/timeline/(scot %p host)/[name]/db-path)
::
++  is-public
  |=  [host=ship name=@ta]
  =/  =path  /timeline/(scot %p host)/[name]
  =/  m  (strand ,?)
  ^-  form:m
  ;<  state-1:db  bind:m  bedrock-state
  :: if timeline type doesn't exist, no valid timelines
  ::
  ?~  tim=(~(get by tables) [%timeline 0v0])  (pure:m |)
  ?~  get=(~(get by u.tim) path)  (pure:m |)
  =/  rows=(list row:db)  ~(val by u.get)
  ?>  &(=(1 (lent rows)) ?=(^ rows))
  =/  =row:db  i.rows
  ?>  ?=(%timeline -.data.row)
  (pure:m public.data.row)
::
++  http-fail
  =/  m  (strand ,simple-payload:http)
  ^-  form:m
  %-  pure:m
  :-  [500 [['content-type' 'application/json'] ~]]
  `(as-octs:mimes:html (en:json:html ~))
:: TODO: probably don't give the whole table, but a minimal version
::
++  give-public-scry
  |=  [host=ship name=@ta]
  =/  m  (strand ,simple-payload:http)
  ^-  form:m
  ;<  is-public=?  bind:m  (is-public host name)
  ?.  is-public  http-fail
  ;<  =fullpath:db  bind:m  (fullpath host name)
  (pure:m (json-response:gen:server (en-fullpath:enjs:db fullpath)))
::
++  authenticate
  |=  url=@t
  =/  =(pole knot)  (purl url)
  =/  m  (strand ,?)
  ^-  form:m
  ?:  ?=([%apps %timeline %'desk.js' ~] pole)  (pure:m &)
  ?:  ?=([%apps %timeline %assets *] pole)  (pure:m &)
  ?.  ?=([%apps %timeline %public host=@ta name=@ta *] pole)  (pure:m |)
  (is-public (slav %p host.pole) name.pole)
::
++  extract-simple-payload
  |=  [a=cage b=cage]
  |^  ^-  simple-payload:http
  (mod-pay (mod-pay *simple-payload:http a) b)
  :: modify payload
  ::
  ++  mod-pay
    |=  [pay=simple-payload:http =cage]
    ?+    p.cage  !!
        %http-response-header
      pay(response-header !<(response-header:http q.cage))
      ::
        %http-response-data
      pay(data !<((unit octs) q.cage))
    ==
  --
::
++  convert-chat-db-msg-part
  |=  [=msg-id:cd =msg-part-id:cd]
  =/  m  (strand ,(unit [[@p @da] timeline-post:t]))
  ^-  form:m
  ;<  dump=db-dump:cd  bind:m
    (scry db-dump:cd /gx/chat-db/db/chat-db-dump)
  ?>  ?=(%tables -.dump)
  =/  tables=(map term table:cd)
    %-  ~(gas by *(map term table:cd))
    (turn tables.dump |=(=table:cd [-.table table]))
  =/  =table:cd  (~(got by tables) %messages)
  ?>  ?=(%messages -.table)
  =+  (got:msgon:cd messages-table.table [msg-id msg-part-id])
  ;<  our=ship  bind:m  get-our
  %-  pure:m
  (convert-message:t our created-at msg-id msg-part-id content metadata)
::
++  convert-chat-db-msg-parts
  |=  =path
  =/  m  (strand ,(list [[@p @da] timeline-post:t]))
  ^-  form:m
  ;<  dump=db-dump:cd  bind:m
    (scry db-dump:cd /gx/chat-db/db/chat-db-dump)
  ?>  ?=(%tables -.dump)
  =/  tables=(map term table:cd)
    %-  ~(gas by *(map term table:cd))
    (turn tables.dump |=(=table:cd [-.table table]))
  =/  =table:cd  (~(got by tables) %messages)
  ?>  ?=(%messages -.table)
  ;<  our=ship  bind:m  get-our
  %-  pure:m
  %+  murn  (tap:msgon:cd messages-table.table)
  |=  [* msg-part:cd]
  ?.  =(^path path)  ~
  (convert-message:t our created-at msg-id msg-part-id content metadata)
::
++  timeline-post-ids
  |=  =path
  =/  scry-path=^path
    ;:  welp
      /gx/bedrock/db/table-by-path/timeline-post/0v0
      path  /db-table
    ==
  =/  m  (strand ,(list id:common:db))
  ^-  form:m
  ;<  [* pt=pathed-table:db *]  bind:m
    (scry ,[* pt=pathed-table:db *] scry-path)
  (pure:m ~(tap in ~(key by (~(got by pt) path))))
--
