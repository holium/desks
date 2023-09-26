/-  spider
/+  *ventio, db, server
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  dap=dude:gall  %timeline
=/  req=(unit [ship request])  !<((unit [ship request]) arg)
?~  req  (strand-fail %no-arg ~)
=/  [src=ship vid=vent-id =mark =noun]  u.req
;<  =vase         bind:m  (unpage mark noun)
;<  =bowl:spider  bind:m  get-bowl
=/  [our=ship now=@da eny=@uvJ byk=beak]  [our now eny byk]:bowl
:: expose bedrock state
::
=+  .^(state-1:db %gx /(scot %p our)/bedrock/(scot %da now)/db/db-state)
=*  bedrock-state  -
::
;<  ~  bind:m  (trace %running-timeline-vine ~)
::
|^
=,  bedrock-state
?+    mark  (punt [our dap] mark vase) :: poke normally
    %handle-http-request
  =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
  ?^  cat=(catch-public-scry url.request.req)
    =+  handle-http-response+!>([eyre-id u.cat])
    ;<  ~  bind:m  (poke [our dap] -)
    (pure:m !>(~))
  :: watch the http-response path on docket
  ::
  =/  docket-path  /http-response/[eyre-id]
  ;<  ~  bind:m  (watch docket-path [our %docket] docket-path)
  :: poke %docket with a spoofed %handle-http-request
  ::
  ~&  [url.request.req (authenticate url.request.req)]
  ::
  =?  req  (authenticate url.request.req)  req(authenticated &)
  =+  handle-http-request+!>([eyre-id req])
  ;<  ~  bind:m  (poke [our %docket] -)
  :: accept the response
  ::
  ;<  a=cage    bind:m  (take-fact docket-path)
  ;<  b=cage    bind:m  (take-fact docket-path)
  ;<  ~         bind:m  (take-kick docket-path)
  :: propagate this back to eyre
  ::
  =+  handle-http-response+!>([eyre-id (extract-simple-payload a b)])
  ;<  ~  bind:m  (poke [our %calendar] -)
  (pure:m !>(~))
==
:: accepts trailing fas
::
++  purl  |=(url=@t (rash url ;~(pfix fas (most fas urs:ab))))
::
++  catch-public-scry
  |=  url=@t
  ^-  (unit simple-payload:http)
  =/  =(pole knot)  (purl url)
  ?.  ?=([%apps %timeline %scry %timeline host=@ta name=@ta ~] pole)  ~
  `(give-public-scry [(slav %p host.pole) name.pole])
::
++  fullpath
  |=  [host=ship name=@ta]
  .^  fullpath:db  %gx
    /(scot %p our)/calendar/(scot %da now)/bedrock/db/timeline/(scot %p host)/[name]/db-path
  ==
::
++  is-public
  |=  [host=ship name=@ta]
  ^-  ?
  =/  =path  /timeline/(scot %p host)/[name]
  :: if timeline type doesn't exist, no valid timelines
  ::
  ?~  tim=(~(get by tables) [%timeline 0v0])  |
  ?~  get=(~(get by u.tim) path)  |
  =/  rows=(list row:db)  ~(val by u.get)
  ?>  &(=(1 (lent rows)) ?=(^ rows))
  =/  =row:db  i.rows
  ?>  ?=(%timeline -.data.row)
  public.data.row
::
++  give-public-scry
  |=  [host=ship name=@ta]
  |^   ^-  simple-payload:http
  ?.  (is-public host name)  fail
  (json-response:gen:server (en-fullpath:enjs:db (fullpath host name)))
  ++  fail
    ^-  simple-payload:http
    :-  [500 [['content-type' 'application/json'] ~]]
    `(as-octs:mimes:html (en:json:html ~))
  --
::
++  authenticate
  |=  url=@t
  ^-  ?
  =/  =(pole knot)  (purl url)
  ?:  ?=([%apps %timeline %'desk.js' ~] pole)  &
  ?:  ?=([%apps %timeline %assets *] pole)  &
  ?.  ?=([%apps %timeline %public host=@ta name=@ta *] pole)  |
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
