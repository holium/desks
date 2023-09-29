/-  spider, *timeline
/+  *ventio, db, server, scries=bedrock-scries
=>  |%
    +$  gowl     bowl:gall
    +$  sowl     bowl:spider
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
?+    mark  (punt [our dap]:gowl mark vase) :: poke normally
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
  =+  !<(axn=action vase)
  ?+    -.axn  (punt [our dap]:gowl mark vase)
      %create-timeline
    ?>  =(src our):gowl
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    ?:  (test-bedrock-path-existence:scries path gowl)
      ~&  >>  %timeline-already-exists
      (pure:m !>([~[%timeline-already-exists] path]))
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
    (pure:m !>(~))
    ::
      %follow-timeline
    ?>  =(src our):gowl
    =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
    =/  =cage  db-action+!>([%handle-follow-request name])
    ;<  ~  bind:m  (poke [(slav %p host) %bedrock] cage)
    (pure:m !>(~))
    ::
      %handle-follow-request
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    :: TODO: check that the timeline is public
    =/  =cage  db-action+!>([%add-peer path src.gowl %$])
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
    ::
      %leave-timeline
    ?>  =(src our):gowl
    =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
    =/  =cage  db-action+!>([%handle-leave-request name])
    ;<  ~  bind:m  (poke [(slav %p host) %bedrock] cage)
    (pure:m !>(~))
    ::
      %handle-leave-request
    =/  =path  /timeline/(scot %p our.gowl)/[name.axn]
    =/  =cage  db-action+!>([%kick-peer path src.gowl])
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
    ::
      %create-react
    =/  =cage
      :-  %db-action  !>
      :*  %create   [our now]:gowl
          path.axn  [%react 0v0]
          [%react react.axn]  ~
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
    ::
      %delete-react
    =/  =cage
      :-  %db-action  !>
      :*  %remove  [our now]:gowl
          [%react 0v0]  path.axn  id.axn
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
    ::
      %create-comment
    =/  =cage
      :-  %db-action  !>
      :*  %create   [our now]:gowl
          path.axn  [%comment 0v0]
          [%comment comment.axn]  ~
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
    ::
      %delete-comment
    =/  =cage
      :-  %db-action  !>
      :*  %remove  [our now]:gowl
          [%comment 0v0]  path.axn  id.axn
      ==
    ;<  ~  bind:m  (poke [our.gowl %bedrock] cage)
    (pure:m !>(~))
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
--
