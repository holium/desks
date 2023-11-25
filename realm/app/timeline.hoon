/-  *timeline, db
/+  *timeline, timeline-json, cd=chat-db, scries=bedrock-scries,
    vent, server, dbug, verb, default-agent
:: Import during development to force compilation...
::
/=  x  /mar/timeline/view
/=  x  /mar/timeline/action
/=  x  /ted/vines/timeline
::
|%
+$  state-0  [%0 ~]
+$  card     card:agent:gall
--
=|  state-0
=*  state  -
%-  agent:vent
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    vnt   ~(. (utils:vent this) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /eyre/connect %arvo %e %connect `/apps/timeline dap.bowl]
      =/  =cage  timeline-action+!>([%create-personal-timeline ~])
      [%pass / %agent [our dap]:bowl %poke cage]
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
  =/  =cage  timeline-action+!>([%create-personal-timeline ~])
  [%pass / %agent [our dap]:bowl %poke cage]~
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
    %timeline-action      (poke-to-vent:vnt mark vase)
    %handle-http-request  (poke-to-vent:vnt mark vase)
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
  ==
::
++  on-arvo
  |=  [=(pole knot) sign=sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?+    pole  (on-arvo:def pole sign)
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
