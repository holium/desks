/+  vio=ventio, dbug, verb, default-agent
:: There's no way around this. Threads can't do state.
:: The venter needs STATE in order to enforce uniqueness on its vent-ids.
::
|%
+$  state-0  [%0 =vents:vio]
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
  `this
::
++  on-save   !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    mark  (on-poke:def mark vase)
      %tally-vent
    ~&  %tallying
    =+  !<([=dock vid=vent-id] vase)
    `this(vents (~(put ju vents) dock vid))
    ::
      %clear-vent
    ~&  %clearing
    =+  !<([=dock vid=vent-id] vase)
    `this(vents (~(del ju vents) dock vid))
  ==
::
++  on-watch  on-watch:def
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
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
