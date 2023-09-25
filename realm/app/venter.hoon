/+  vio=ventio, dbug, verb, default-agent
:: There is no way around this. Threads cannot do state.
:: The venter needs STATE in order to enforce uniqueness on its vent-ids.
::
:: %venter is also responsible for warming %realm desk's tubes....
:: improves vent performance when using /ted/vent.hoon
:: https://github.com/tinnus-napbus/tube-warmer
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
  :_  this
  [%pass /tube-warmer %arvo %k %fard %realm %tube-warmer noun+!>(`%realm)]~
::
++  on-save   !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  :_  this
  [%pass /tube-warmer %arvo %k %fard %realm %tube-warmer noun+!>(`%realm)]~
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+    mark  (on-poke:def mark vase)
      %tally-vent
    ~&  %venter-tallying
    =+  !<([=dock vid=vent-id] vase)
    `this(vents (~(put ju vents) dock vid))
    ::
      %clear-vent
    ~&  %venter-clearing
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
::
++  on-arvo
  |=  [=(pole knot) sign=sign-arvo]
  ^-  (quip card _this)
  ?+    pole  (on-arvo:def pole sign)
      [%tube-warmer ~]
    ?.  ?=([%khan %arow *] sign)  (on-arvo:def pole sign)
    %-  (slog ?:(?=(%.y -.p.sign) ~ p.p.sign))
    `this
  ==
::
++  on-fail   on-fail:def
--
