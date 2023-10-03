/+  vio=ventio, dbug, verb, default-agent
:: There is no way around this. Threads cannot do state.
:: The venter needs STATE in order to enforce uniqueness on its vent-ids.
::
:: %venter is also responsible for warming %realm desk's tubes....
:: improves vent performance when using /ted/vent.hoon
:: https://github.com/tinnus-napbus/tube-warmer
::
|%
+$  state-0  [%0 =vents:vio tube-verb=_|]
+$  card     card:agent:gall
+$  vent-id  vent-id:vio
--
%-  agent:dbug
%+  verb  |
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  =/  =@ud  +(ud:.^(cass:clay %cw /(scot %p our.bowl)/realm/(scot %da now.bowl)))
  :_  this
  :~  [%pass /next %arvo %c %warp our.bowl %realm ~ %many %.y ud+ud ud+ud /]
      [%pass /tube-warmer %arvo %k %fard %realm %tube-warmer noun+!>(`[%realm tube-verb])]
  ==
::
++  on-save   !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  =/  =@ud  +(ud:.^(cass:clay %cw /(scot %p our.bowl)/realm/(scot %da now.bowl)))
  :_  this
  :~  [%pass /next %arvo %c %warp our.bowl %realm ~ %many %.y ud+ud ud+ud /]
      [%pass /tube-warmer %arvo %k %fard %realm %tube-warmer noun+!>(`[%realm tube-verb])]
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    mark  (on-poke:def mark vase)
    %noun  `this(tube-verb (tail !<([%verb ?] vase)))
    ::
      %tally-vent
    :: ~&  %venter-tallying
    =+  !<([=dock vid=vent-id] vase)
    `this(vents (~(put ju vents) dock vid))
    ::
      %clear-vent
    :: ~&  %venter-clearing
    =+  !<([=dock vid=vent-id] vase)
    `this(vents (~(del ju vents) dock vid))
    ::
      %clear-dead
    =+  .^(pats=(list path) %gx /(scot %p our.bowl)/spider/(scot %da now.bowl)/tree/noun)
    =/  tids=(set tid:rand)  (~(gas in *(set tid:rand)) (turn pats rear))
    :-  ~
    %=    this
        vents
      %-  ~(gas by *vents:vio)
      %+  murn  ~(tap by vents)
      |=  [=dock vids=(set vent-id)]
      =;  new=(set vent-id)
        ?:(?=(~ new) ~ `[dock new])
      %-  ~(gas in *(set vent-id))
      %+  murn  ~(tap in vids)
      |=  vid=vent-id
      ?.((~(has in tids) q.vid) ~ `vid)
    ==
    ::
      %vent-request
    =+  !<([vid=vent-id:vio req=page] vase)
    =/  =path  (en-path:vio vid)
    ?+    p.req  (on-poke:def mark vase)
        %scry
      =+  ;;(scry=^path q.req)
      ?>  ?=(^ scry)
      ?>  ?=(^ t.scry)
      =+  .^(p=* i.scry (scot %p our.bowl) i.t.scry (scot %da now.bowl) t.t.scry)
      :_  this
      :~  [%give %fact ~[path] noun+!>(p)]
          [%give %kick ~[path] ~]
      ==
    ==
  ==
::
++  on-watch
  |=  =(pole knot)
  ^-  (quip card _this)
  ?+    pole  (on-watch:def pole)
    [%vent @ @ @ ~]  ?>(=(src our):bowl `this)
  ==
++  on-leave  on-leave:def
::
++  on-peek
  |=  =(pole knot)
  ^-  (unit (unit cage))
  ?+    pole  (on-peek:def pole)
    [%x %vents ~]  ``noun+!>(vents)
  ==
::
++  on-agent  on-agent:def
::
++  on-arvo
  |=  [=(pole knot) sign=sign-arvo]
  ^-  (quip card _this)
  ?+    pole  (on-arvo:def pole sign)
      [%tube-warmer ~]
    ?.  ?=([%khan %arow *] sign)  (on-arvo:def pole sign)
    %-  (slog ?:(?=(%.y -.p.sign) ~ p.p.sign))
    `this
    ::
      [%next ~]
    ?.  ?=([%clay %writ ~] sign)  `this
    =/  =@ud  +(ud:.^(cass:clay %cw /(scot %p our.bowl)/realm/(scot %da now.bowl)))
    :_  this
    :~  [%pass /next %arvo %c %warp our.bowl %realm ~ %many %.y ud+ud ud+ud /]
        [%pass /tube-warmer %arvo %k %fard %realm %tube-warmer noun+!>(`[%realm tube-verb])]
    ==
  ==
::
++  on-fail   on-fail:def
--
