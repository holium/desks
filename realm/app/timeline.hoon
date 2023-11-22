/-  *timeline, db
/+  *timeline, timeline-json, cd=chat-db, scries=bedrock-scries,
    vio=ventio, server, dbug, verb, default-agent
:: Import during development to force compilation...
::
/=  x  /mar/timeline/view
/=  x  /mar/timeline/action
/=  x  /ted/vines/timeline
::
|%
+$  state-0  [%0 ~]
+$  card     card:agent:gall
+$  vent-id  vent-id:vio
--
=|  state-0
=*  state  -
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  ~&  %initing
  :~  [%pass /eyre/connect %arvo %e %connect `/apps/timeline dap.bowl]
      [%pass / %agent [our dap]:bowl %poke timeline-action+!>([%create-personal-timeline ~])]
  ==
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  :_  this
  ~&  %loading
  [%pass / %agent [our dap]:bowl %poke timeline-action+!>([%create-personal-timeline ~])]~
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  :: forward vent requests directly to the vine
  ::
  ?:  ?=(%vent-request mark)  :_(this ~[(to-vine:vio vase bowl)])
  ::
  ?+    mark  (on-poke:def mark vase)
      %timeline-action
    :: re-interpret as vent-request
    ::
    =^  cards  this
      (on-poke vent-request+!>([*vent-id mark q.vase]))
    [cards this]
    ::
      %handle-http-request
    :: re-interpret as vent-request
    :: necessary -- %eyre hits %timeline with a poke
    ::
    =^  cards  this
      (on-poke vent-request+!>([*vent-id mark q.vase]))
    [cards this]
    ::
      %handle-http-response
    :: only we can tell ourselves to give an http-response
    ::
    ?>  =(src our):bowl
    =+  !<([eyre-id=@ta pay=simple-payload:http] vase)
    :_(this (give-simple-payload:app:server eyre-id pay))
  ==
::
++  on-watch
  |=  =(pole knot)
  ^-  (quip card _this)
  ?+    pole  (on-watch:def pole)
    [%vent @ @ @ ~]       `this
    [%http-response *]  `this
  ==
::
++  on-agent  on-agent:def
::
++  on-peek
  |=  =(pole knot)
  ^-  (unit (unit cage))
  ?+    pole  (on-peek:def pole)
      [%x %timelines ~]
    =+  .^(=state-2:db %gx /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/db-state)
    =/  paths=(list path)
      :: if timeline type doesn't exist, no valid timelines
      ::
      ?~  tim=(~(get by tables.state-2) [%timeline 0v0])  ~
      :: for each path
      ::
      %+  murn  ~(tap in ~(key by paths.state-2))
      |=  =(^pole knot)
      :: check the timeline path format is correct
      ::
      ?.  ?=([%timeline ship=@ta @ta ~] pole)  ~
      ?~  (rush ship.pole ;~(pfix sig fed:ag))  ~
      :: check the timeline type exists on that path
      ::
      ?.((~(has by u.tim) pole) ~ `pole)
    ``timeline-view+!>(paths+paths)
    ::
      [%x %chat-db ~]
    =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
    ?>  ?=(%tables -.dump)
    =/  tables=(map term table:cd)
      %-  ~(gas by *(map term table:cd))
      (turn tables.dump |=(=table:cd [-.table table]))
    =/  =table:cd  (~(got by tables) %messages)
    ?>  ?=(%messages -.table)
    ``timeline-view+!>(messages+messages-table.table)
    ::
      [%x %chat-db %types ~]
    =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
    ?>  ?=(%tables -.dump)
    =/  tables=(map term table:cd)
      %-  ~(gas by *(map term table:cd))
      (turn tables.dump |=(=table:cd [-.table table]))
    =/  =table:cd  (~(got by tables) %messages)
    ?>  ?=(%messages -.table)
    =/  types=(set [term (set cord)])
      %-  ~(gas in *(set [term (set cord)]))
      %+  turn  (tap:msgon:cd messages-table.table)
      |=([* msg-part:cd] [-.content ~(key by metadata)])
    ``timeline-view+!>(types+types)
    ::
      [%x %chat-db %types t=@t ~]
    =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
    ?>  ?=(%tables -.dump)
    =/  tables=(map term table:cd)
      %-  ~(gas by *(map term table:cd))
      (turn tables.dump |=(=table:cd [-.table table]))
    =/  =table:cd  (~(got by tables) %messages)
    ?>  ?=(%messages -.table)
    =/  types=(set [term (set cord)])
      %-  ~(gas in *(set [term (set cord)]))
      %+  murn  (tap:msgon:cd messages-table.table)
      |=  [* msg-part:cd]
      ?.  =(t.pole -.content)  ~
      `[-.content ~(key by metadata)]
    ``timeline-view+!>(types+types)
  ==
::
++  on-arvo
  |=  [=(pole knot) sign=sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?+    pole  (on-arvo:def pole sign)
      [%vent @ @ @ ~]
    ?.  ?=([%khan %arow *] sign)  (on-arvo:def pole sign)
    %-  (slog ?:(?=(%.y -.p.sign) ~ p.p.sign))
    :_(this (vent-arow:vio pole p.sign))
    ::
      [%eyre %connect ~]
    ?>  ?=([%eyre %bound *] sign)
    ?:  accepted.sign
      ((slog leaf+"/apps/timeline bound successfully!" ~) `this)
    ((slog leaf+"Binding /apps/timeline failed!" ~) `this)
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
