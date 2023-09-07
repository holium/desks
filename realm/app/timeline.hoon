/-  *timeline, db
/+  scries=bedrock-scries, *timeline, timeline-json, cd=chat-db, dbug, verb, default-agent
::
/=  tv-  /mar/timeline/view
/=  ta-  /mar/timeline/action
::
|%
+$  state-0
  $:  timelines=(map path timeline)
      collections=(map cid (set path))
  ==
+$  card  card:agent:gall
:: ++  pon   ((on @da timeline-post) gth)
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
  =^  cards  this
    (on-poke timeline-action+!>([%add-forerunners |]))
  [cards this]
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  =^  cards  this
    (on-poke timeline-action+!>([%add-forerunners |]))
  [cards this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl :: replace with more robust permissions later
  ?+    mark  (on-poke:def mark vase)
      %timeline-action
    =+  !<(axn=action vase)
    ?-    -.axn
        %create-bedrock-timeline
      =|  =input-path-row:db
      =/  =cage
        :-  %db-action  !>
        :-  %create-path
        %=  input-path-row
          path         (weld /timeline/(scot %p our.bowl) path.axn)
          replication  %host
          peers        ~[[our.bowl %host]]
        ==
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %create-bedrock-timeline-post
      =.  path.axn  (weld /timeline/(scot %p our.bowl) path.axn)
      =/  =cage
        :-  %db-action  !>
        :*  %create   [our now]:bowl
            path.axn  [%timeline-post 0v0]
            [%timeline-post post.axn]  ~
        ==
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %create-timeline
      ?<  (~(has by timelines) path.axn)
      =.  timelines
        (~(put by timelines) path.axn [path.axn curators.axn ~])
      `this
      :: 
        %delete-timeline
      =.  timelines
        (~(del by timelines) path.axn)
      `this
      ::
        %create-timeline-post
      =/  =timeline  (~(got by timelines) path.axn)
      :: =.  posts.timeline  (put:pon posts.timeline now.bowl post.axn)
      =/  post-id=path
        |-
        =/  pid=path  /(scot %p our.bowl)/(scot %da now.bowl)
        ?.  (~(has by posts.timeline) pid)
          pid
        $(now.bowl +(now.bowl))
      ::
      =.  posts.timeline  (~(put by posts.timeline) post-id post.axn)
      `this(timelines (~(put by timelines) path.axn timeline))
      ::
        %delete-timeline-post
      =/  =timeline  (~(got by timelines) path.axn)
      :: =.  posts.timeline  +:(del:pon posts.timeline key.axn)
      =.  posts.timeline  (~(del by posts.timeline) key.axn)
      `this(timelines (~(put by timelines) path.axn timeline))
      ::
        %add-forerunners
      =/  fore=path  /spaces/~lomder-librun/realm-forerunners/chats/0v2.68end.ets6m.29fgc.ntejl.jbeo7
      ?:  &(!force.axn (~(has by timelines) fore))
        ~&(%forerunners-already-imported `this)
      =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
      ?>  ?=(%tables -.dump)
      =/  tables=(map term table:cd)
        %-  ~(gas by *(map term table:cd))
        (turn tables.dump |=(=table:cd [-.table table]))
      =/  =table:cd  (~(got by tables) %messages)
      ?>  ?=(%messages -.table)
      =|  posts=(map path timeline-post)
      =.  posts
        %-  ~(gas by posts) 
        %+  murn  (tap:msgon:cd messages-table.table)
        |=  [* msg-part:cd]
        ?.  =(fore path)  ~
        (convert-messages msg-id msg-part-id content metadata)
      =/  =timeline  [fore (sy ~[our.bowl]) posts]
      `this(timelines (~(put by timelines) fore timeline))
      ::
        %add-forerunners-bedrock
      =/  fore=path  /spaces/~lomder-librun/realm-forerunners/chats/0v2.68end.ets6m.29fgc.ntejl.jbeo7
      =/  db-fore=path  [%timeline (scot %p our.bowl) fore]
      ?:  ?&  !force.axn
              (test-bedrock-path-existence:scries db-fore bowl)
          ==
        ~&(%forerunners-already-imported-to-bedrock `this)
      =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
      ?>  ?=(%tables -.dump)
      =/  tables=(map term table:cd)
        %-  ~(gas by *(map term table:cd))
        (turn tables.dump |=(=table:cd [-.table table]))
      =/  =table:cd  (~(got by tables) %messages)
      ?>  ?=(%messages -.table)
      =|  posts=(map path timeline-post)
      =.  posts
        %-  ~(gas by posts) 
        %+  murn  (tap:msgon:cd messages-table.table)
        |=  [* msg-part:cd]
        ?.  =(fore path)  ~
        (convert-messages msg-id msg-part-id content metadata)
      =^  tl-cards  this
        (on-poke timeline-action+!>([%create-bedrock-timeline fore]))
      =/  post-cards
        %+  turn  ~(val by posts)
        |=  post=timeline-post
        ^-  card
        =/  =cage  timeline-action+!>([%create-bedrock-timeline-post fore post])
        [%pass / %agent [our dap]:bowl %poke cage]
      :_(this (weld post-cards tl-cards))
    ==
  ==
::
++  on-watch  on-watch:def
++  on-agent  on-agent:def
::
++  on-peek
  |=  =(pole knot)
  ^-  (unit (unit cage))
  ?+    pole  (on-peek:def pole)
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
    ::
      [%x %timelines ~]
    ``timeline-view+!>(timelines+timelines)
    ::
      [%x %timeline rest=*]
    ``timeline-view+!>(timeline+(~(got by timelines) rest.pole))
  ==
::
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
