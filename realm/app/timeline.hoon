/-  *timeline, db
/+  scries=bedrock-scries, *timeline, timeline-json, cd=chat-db,
    dbug, verb, default-agent
::
/=  tv-  /mar/timeline/view
/=  ta-  /mar/timeline/action
::
|%
+$  state-0  [%0 ~]
+$  card  card:agent:gall
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
    (on-poke timeline-action+!>([%add-forerunners-bedrock &]))
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
    (on-poke timeline-action+!>([%add-forerunners-bedrock |]))
  [cards this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %timeline-action
    =+  !<(axn=action vase)
    ?-    -.axn
        %create-timeline
      ?>  =(src our):bowl
      =/  =path  /timeline/(scot %p our.bowl)/[name.axn]
      ?:  (test-bedrock-path-existence:scries path bowl)
        ~&(%timeline-already-exists `this)
      =|  row=input-path-row:db
      =:  path.row         path
          replication.row  %host
          peers.row        ~[[our.bowl %host]]
        ==
      =/  =cage  db-action+!>([%create-path row])
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      :: 
        %delete-timeline
      ?>  =(src our):bowl
      =/  =path  /timeline/(scot %p our.bowl)/[name.axn]
      ?.  (test-bedrock-path-existence:scries path bowl)
        ~&(%timeline-does-not-exist `this)
      =/  =cage  db-action+!>([%delete-path path])
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %follow-timeline
      ?>  =(src our):bowl
      =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
      =/  =cage  db-action+!>([%handle-follow-request name])
      :_(this [%pass / %agent [(slav %p host) %bedrock] %poke cage]~)
      ::
        %handle-follow-request
      =/  =path  /timeline/(scot %p our.bowl)/[name.axn]
      :: TODO: check that the timeline is public
      =/  =cage  db-action+!>([%add-peer path src.bowl %$])
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %leave-timeline
      ?>  =(src our):bowl
      =+  ;;([%timeline host=@ta name=@ta ~] path.axn)
      =/  =cage  db-action+!>([%handle-leave-request name])
      :_(this [%pass / %agent [(slav %p host) %bedrock] %poke cage]~)
      ::
        %handle-leave-request
      =/  =path  /timeline/(scot %p our.bowl)/[name.axn]
      :: TODO: check that the timeline is public
      =/  =cage  db-action+!>([%kick-peer path src.bowl])
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %create-timeline-post
      =/  =cage
        :-  %db-action  !>
        :*  %create   [(scot %p our.bowl) (scot %da now.bowl)]
            path.axn  [%timeline-post 0v0]
            [%timeline-post post.axn]  ~
        ==
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %delete-timeline-post
      =/  =cage
        :-  %db-action  !>
        :*  %remove  [(scot %p our.bowl) (scot %da now.bowl)]
            [%timeline-post 0v0]  path.axn  id.axn
        ==
      :_(this [%pass / %agent [our.bowl %bedrock] %poke cage]~)
      ::
        %add-forerunners-bedrock
      =/  fore=path  /spaces/~lomder-librun/realm-forerunners/chats/0v2.68end.ets6m.29fgc.ntejl.jbeo7
      =/  db-fore=path  [%timeline (scot %p our.bowl) fore]
      ?:  &(!force.axn (test-bedrock-path-existence:scries db-fore bowl))
        ~&(%forerunners-already-imported-to-bedrock `this)
      =+  .^(dump=db-dump:cd %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/chat-db-dump)
      ?>  ?=(%tables -.dump)
      =/  tables=(map term table:cd)
        %-  ~(gas by *(map term table:cd))
        (turn tables.dump |=(=table:cd [-.table table]))
      =/  =table:cd  (~(got by tables) %messages)
      ?>  ?=(%messages -.table)
      =/  posts=(list [[@p @da] timeline-post])
        %+  murn  (tap:msgon:cd messages-table.table)
        |=  [* msg-part:cd]
        ?.  =(fore path)  ~
        (convert-messages our.bowl created-at msg-id msg-part-id content metadata)
      =^  tl-cards  this
        (on-poke timeline-action+!>([%create-bedrock-timeline fore]))
      =/  post-cards
        %+  turn  posts
        |=  [req-id=[@p @da] post=timeline-post]
        ^-  card
        =/  =cage  timeline-action+!>([%create-bedrock-timeline-post fore req-id post])
        [%pass / %agent [our dap]:bowl %poke cage]
      :_(this (weld tl-cards post-cards))
      ::
        %add-random-emojis
      =/  fore=path  /spaces/~lomder-librun/realm-forerunners/chats/0v2.68end.ets6m.29fgc.ntejl.jbeo7
      =/  db-fore=path  [%timeline (scot %p our.bowl) fore]
      =+  .^  [* pt=pathed-table:db *]  %gx
              ;:  welp
                /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/table-by-path/timeline-post/0v0
                db-fore  /noun
              ==
          ==
      =/  cards=(list card)
        %-  zing
        %+  turn
          ~(tap in ~(key by (~(got by pt) db-fore)))
        |=  =id:common
        ^-  (list card)
        %+  turn  (random-reacts db-fore id)
        |=  =react:common
        =;  =cage
          [%pass / %agent [our.bowl %bedrock] %poke cage]
        :-  %db-action  !>
        :*  %create  [our now]:bowl
            db-fore  [%react 0v0]
            [%react react]  ~
        ==
      [cards this]
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
  ==
::
++  on-arvo   on-arvo:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
