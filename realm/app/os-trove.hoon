/-  *trove, m=membership, s=spaces-store, v=visas
/+  dbug, default-agent, verb,
:: import to force compilation during testing
    trove-json
/=  u-  /mar/trove/update
/=  a-  /mar/trove/action
/=  r-  /mar/trove/reaction
/=  v-  /mar/trove/view
|%
+$  versioned-state  $%(state-0)
+$  state-0  [%0 hoard=(map space [=banned =troves])]
+$  card  card:agent:gall
--
::
%-  agent:dbug
%+  verb  |
=|  state-0
=*  state  -
=<
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %|) bowl)
    hc    ~(. +> [bowl ~])
    cc    |=(cards=(list card) ~(. +> [bowl cards]))
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]~
::
++  on-save  `vase`!>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  =.  state  old
  =/  remote-spaces
    %+  murn
      ~(tap in ~(key by hoard))
    |=(=space ?:(=(-.space our.bowl) ~ (some space)))
  =^  cards  state
    abet:(leave-and-refollow:hc remote-spaces)
  ?:  (~(has by wex.bowl) /spaces [our.bowl %spaces])  [cards this]
  :_(this [[%pass /spaces %agent [our.bowl %spaces] %watch /updates] cards])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %trove-action
    =/  axn  !<(action vase)
    ?-    -.axn
        %util
      ?-    +<.axn
          %follow-many
        =^  cards  state
          abet:(follow-many:hc spaces.axn)
        [cards this]
      ==
      ::
        %space
      =^  cards  state
        abet:(handle-space-action:hc +.axn)
      [cards this]
      ::
        %trove
      =^  cards  state
        abet:(handle-trove-action:hc +.axn)
      [cards this]
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    [%x %hoard ~]  ``trove-view+!>(hoard+hoard)
    ::
      [%x %troves @t @t ~]
    =/  =space  [(slav %p i.t.t.path) i.t.t.t.path]
    ``trove-view+!>([%troves +:(~(got by hoard) space)])
    ::
      [%x %trove @t @t @t @t ~]
    =/  [=space =tope]  (de-trove-path:hc t.t.path)
    =/  [=banned =troves]  (~(got by hoard) space)
    ``trove-view+!>([%trove +:(~(got by troves) tope)])
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%spaces ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        =/  tang  [leaf+"%os-trove: subscribed to /updates from %spaces."]~
        ((slog tang) `this)
      =/  tang
        :_  u.p.sign
        leaf+"%os-trove: failed to subscribe to /updates from %spaces."
      ((slog tang) `this)
      ::
        %kick
      :_  this
      [%pass wire %agent [src.bowl %spaces] %watch /updates]~
      ::
        %fact
      ?+    p.cage.sign  `this
          %visas-reaction
        :: TBD how necessary this is...
        =/  rxn  !<(reaction:v q.cage.sign)
        ?+    -.rxn  `this
            %invite-accepted
          ~&  [path ship roles.member]:rxn
          `this
          ::
            %kicked
          ~&  [path ship]:rxn
          `this
          ::
            %edited
          ~&  [path ship role-set]:rxn
          `this
        ==
        ::
          %spaces-reaction
        =/  rxn  !<(reaction:s q.cage.sign)
        ?+    -.rxn  `this
            %initial
          =^  cards  state
            abet:(cof-many:hc ~(tap in ~(key by spaces.rxn)))
          [cards this]
            %add
          =^  cards  state
            abet:(create-or-follow:hc path.space.rxn)
          [cards this]
            %replace
          =^  cards  state
            abet:(create-or-follow:hc path.space.rxn)
          [cards this]
            %remote-space
          =^  cards  state
            abet:(create-or-follow:hc path.space.rxn)
          [cards this]
            %remove
          =^  cards  state
            abet:(delete-or-leave:hc path.rxn)
          [cards this]
        ==
      ==
    == 
    :: updates regarding which troves I can read
    :: 
      [@t @t @t ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        %.  `this
        %-  slog
        :_  ~  
        leaf+"%os-trove: joining {(spud wire)} succeeded!"
      %.  `this
      %-  slog
      :_  u.p.sign
      leaf+"%os-trove: joining {(spud wire)} failed!"
    ::
        %kick
      ~&  "{<dap.bowl>}: got kick from {(spud wire)}, resubscribing..."
      :_(this [%pass wire %agent [src.bowl dap.bowl] %watch wire]~)
    ::
        %fact
      =/  [=space reader=ship]  (de-space-path wire) :: space-path from wire
      ?+    p.cage.sign  (on-agent:def wire sign)
          %trove-reaction
        =/  rxn  !<(reaction q.cage.sign)
        ?>  ?=(%space -.rxn)
        =^  cards  state
          abet:(handle-space-reaction:hc space +.rxn)
        [cards this]
      ==
    ==
    :: updates regarding a specific trove
    :: 
      [@t @t @t @t ~]
    ?+    -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign
        %.  `this
        %-  slog
        :_  ~  
        leaf+"%trove-client: joining {(spud wire)} succeeded!"
      %.  `this
      %-  slog
      :_  u.p.sign
      leaf+"%trove-client: joining {(spud wire)} failed!"
    ::
        %kick
      ~&  "{<dap.bowl>}: got kick from {(spud wire)}, resubscribing..."
      =^  cards  state
        abet:(handle-trove-kick:hc wire)
      [cards this]
    ::
        %fact
      =/  [=space =tope]  (de-trove-path wire)
      ?+    p.cage.sign  (on-agent:def wire sign)
          %trove-reaction
        =/  rxn  !<(reaction q.cage.sign)
        ?>  ?=(%trove -.rxn)
        =^  cards  state
          abet:(handle-trove-reaction:hc space tope +.rxn)
        [cards this]
      ==
    ==
  ==
::
++  on-arvo   on-arvo:def
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%ui ~]  `this :: do nothing; scry for initial
    :: =/  upd=update  [%initial hoard]
    :: :_(this [%give %fact ~ trove-update+!>(upd)]~)
    ::
      [@t @t @t ~]
    =/  [=space reader=ship]  (de-space-path path) :: space-path from wire
    ?>  =(-.space our.bowl)
    ?>  =(reader src.bowl)
    ?>  (is-member:hc space reader)
    =/  rxn=reaction
      [%space %watchlist (get-readable:hc space reader)]
    :_(this [%give %fact ~ trove-reaction+!>(rxn)]~)
    ::
      [@t @t @t @t ~]
    =/  [=space =tope]  (de-trove-path path) :: space-path from wire
    ?>  =(-.space our.bowl)
    ?>  (can-read:hc space tope src.bowl)
    =/  [=banned =troves]  (~(got by hoard) space)
    =/  rxn=reaction
      [%trove %initial (~(got by troves) tope)]
    :_(this [%give %fact ~ trove-reaction+!>(rxn)]~)
  ==
::
++  on-fail   on-fail:def
++  on-leave  on-leave:def
--
|_  [=bowl:gall cards=(list card)]
+*  core  .
    io    ~(. agentio bowl)
++  abet  [(flop cards) state]
++  emit  |=(=card core(cards [card cards]))
++  emil  |=(cadz=(list card) core(cards (weld cadz cards)))
::
++  ui-emit
  |=  upd=update
  (emit %give %fact ~[/ui] trove-update+!>(upd))
::
++  away-space-emil
  |=  [=space rxn=space-reaction:reaction]
  %-  emil
  %+  murn  ~(val by sup.bowl)
  |=  [=ship =path]
  ?.  ?=([@ta @ta @ta ~] path)  ~
  =/  [s=^space p=^ship]  (de-space-path path)
  ?.  =([s p] [space ship])  ~
  (some [%give %fact ~[path] trove-reaction+!>(space+rxn)])
::
++  away-trove-emit
  |=  [=space =tope rxn=trove-reaction:reaction]
  =/  away  (en-trove-path space tope) :: listeners
  (emit %give %fact ~[away] trove-reaction+!>(trove+rxn))
::
++  en-space-path
  |=  [=space reader=ship]
  /(scot %p -.space)/[+.space]/(scot %p reader)
++  de-space-path
  |=  =path
  ^-  [space reader=ship]
  ?>  ?=([@ta @ta @ta ~] path)
  [[(slav %p i.path) i.t.path] (slav %p i.t.t.path)]
::
++  en-trove-path
  |=  [=space =tope]
  /(scot %p -.space)/[+.space]/(scot %p -.tope)/[+.tope]
++  de-trove-path
  |=  =path
  ^-  [space =tope]
  ?>  ?=([@ta @ta @ta @ta ~] path)
  :-  [(slav %p i.path) i.t.path]
  [(slav %p i.t.t.path) i.t.t.t.path]
::
++  create-space
  |=  =space
  ^-  _core
  ?>  =(-.space our.bowl)
  ?:  (~(has by hoard) space)  core
  =.  hoard   (~(put by hoard) space *banned *troves)
  (ui-emit %space space %add-troves *banned *troves)
::
++  follow-space
|=  =space
^-  _core
?<  =(-.space our.bowl)
=/  pite  (en-space-path space our.bowl)
?:  (~(has by wex.bowl) pite -.space dap.bowl)  core
=.  hoard   (~(put by hoard) space *banned *troves)
=.  core  (ui-emit %space space %add-troves *banned *troves)
(emit:core [%pass pite %agent [-.space dap.bowl] %watch pite])
::
++  create-or-follow
|=  =space
^-  _core
?:  =(-.space our.bowl)
  (create-space space)
(follow-space space)
::
++  delete-space
|=  =space
^-  _core
?>  =(-.space our.bowl)
?.  (~(has by hoard) space)  core
=.  hoard  (~(del by hoard) space)
(ui-emit %space space %rem-troves ~)
::
++  leave-trove-card
  |=  [=space =tope]
  ^-  card
  [%pass (en-trove-path space tope) %agent [-.space dap.bowl] %leave ~]
::
++  leave-space
  |=  =space
  ^-  _core
  ?<  =(-.space our.bowl)
  =/  remote-troves  ~(tap in ~(key by troves:(~(got by hoard) space)))
  =.  core  (emil (turn remote-troves (cury leave-trove-card space)))
  =.  hoard  (~(del by hoard) space)
  =.  core  (ui-emit:core %space space %rem-troves ~)
  =/  wire  (en-space-path space our.bowl)
  (emit:core [%pass wire %agent [-.space dap.bowl] %leave ~])
::
++  delete-or-leave
  |=  =space
  ^-  _core
  ?:  =(-.space our.bowl)
    (delete-space space)
  (leave-space space)
::
++  follow-many
  |=  spaces=(list space)
  ^-  _core
  ?~  spaces  core
  $(spaces t.spaces, core (follow-space:core i.spaces))
::
++  leave-many
  |=  spaces=(list space)
  ^-  _core
  ?~  spaces  core
  $(spaces t.spaces, core (leave-space:core i.spaces))
::
++  leave-and-refollow
  |=  spaces=(list space)
  ^-  _core
  %-  emit:(leave-many spaces)
  :*  %pass  /  %agent  [our dap]:bowl  %poke
      trove-action+!>([%util %follow-many spaces])
  ==
::
++  cof-many
  |=  spaces=(list space)
  ^-  _core
  ?~  spaces  core
  $(spaces t.spaces, core (create-or-follow:core i.spaces))
::
++  relay
  |=  axn=action
  ^-  _core
  ?>  =(src our):bowl
  =/  =dock
    :_  dap.bowl
    ?+  -.axn  !!
      %trove  ship.space.axn
      %space  ship.space.axn
    ==
  (emit %pass / %agent dock %poke trove-action+!>(axn))
::
++  get-readable
  |=  [=space reader=ship]
  ^-  (list tope)
  =/  [=banned =troves]  (~(got by hoard) space)
  %+  murn  ~(tap by troves)
  |=  [=tope trove-data]
  ?.((can-read space tope reader) ~ (some tope))
::
++  can-read
  |=  [=space =tope reader=ship]
  ^-  ?
  ?.  (is-member space reader)  |
  ?:  =(-.tope reader)  &
  ?:  (is-admin space reader)  &
  =/  [=banned =troves]  (~(got by hoard) space)
  =+  (~(got by troves) tope) :: expose perms
  ?:  ?=(?(%r %rw) member.perms)  &
  (~(has by custom.perms) reader)
::
++  can-write
  |=  [=space =tope writer=ship]
  ^-  ?
  ?.  (is-member space writer)  |
  ?:  =(-.tope writer)  &
  =/  [=banned =troves]  (~(got by hoard) space)
  =+  (~(got by troves) tope)
  ?:  &((is-admin space writer) ?=(%rw admins.perms))  &
  ?:  ?=(%rw member.perms)  &
  ?~(w=(~(get by custom.perms) writer) | ?=(%rw u.w))
:: tell readers to watch this trove
::
++  send-watchlist
  |=  [=space =tope]
  ^-  _core
  %-  emil
  %+  murn  ~(val by sup.bowl)
  |=  [=ship =path]
  ?.  ?=([@ta @ta @ta ~] path)  ~
  =/  [s=^space p=^ship]  (de-space-path path)
  ?.  =([s p] [space ship])  ~
  ?.  (can-read space tope ship)  ~
  =/  rxn=reaction  [%space %watchlist ~[tope]]
  (some [%give %fact ~[path] trove-reaction+!>(rxn)])
:: kick people without reader perms
::
++  kick-unwelcome
  |=  [=space =tope]
  ^-  _core
  %-  emil
  %+  murn  ~(val by sup.bowl)
  |=  [=ship =path]
  ?.  ?=([@ta @ta @ta @ta ~] path)  ~
  =/  [s=^space t=^tope]  (de-trove-path path)
  ?.  =([s t] [space tope])  ~
  ?:  (can-read s t ship)  ~
  (some [%give %kick ~[path] `ship])
::
++  purge-banned
  |=  [=space =banned]
  ^+  banned
  %-  ~(gas in *^banned)
  %+  murn  ~(tap in banned)
  |=  =ship
  ?.((is-member space ship) ~ (some ship))
::
++  purge-perms
  |=  [=space =perms]
  ^+  perms
  %=    perms
      custom
    %-  ~(gas by *(map ship ?(%r %rw)))
    %+  murn  ~(tap by custom.perms)
    |=  [=ship ?(%r %rw)]
    ?.((is-member space ship) ~ (some +<))
  ==
::
++  handle-space-action
  |=  [=space axn=space-action:action]
  ^-  _core
  :: relay to single source of truth (space host)
  ::
  ?.  =(-.space our.bowl)  (relay [%space space axn])
  =/  [=banned =troves]  (~(got by hoard) space)
  ?-    -.axn
      %add-trove
    ?<  &((~(has in banned) src.bowl) !(is-admin space src.bowl))
    =/  =tope   [src.bowl name.axn]
    ?<  (~(has by troves) tope)
    =/  =trove-data  [q.tope perms.axn *trove]
    =.  troves  (~(put by troves) tope trove-data)
    =.  hoard   (~(put by hoard) space banned troves)
    =.  core    (send-watchlist space tope)
    (ui-emit:core %space space %add-trove tope trove-data)
    ::
      %rem-trove
    ?>  ?|  =(-.tope.axn src.bowl)
            (is-admin space src.bowl)
        ==
    =.  troves  (~(del by troves) tope.axn)
    =.  hoard   (~(put by hoard) space banned troves)
    =/  folo    ~[(en-trove-path space tope.axn)]
    =.  core    (emit %give %kick folo ~)
    (ui-emit:core [%space space %rem-trove tope.axn])
    ::
      %banned
    ?>  (is-admin space src.bowl)
    =.  banned.axn  (purge-banned space banned.axn)
    =.  hoard  (~(put by hoard) space banned.axn troves)
    =.  core   (away-space-emil space banned+banned.axn)
    (ui-emit:core [%space space %banned banned.axn])
  ==
::
++  handle-space-reaction
  |=  [=space rxn=space-reaction:reaction]
  ^-  _core
  ?-    -.rxn
      %banned
    =/  [=banned =troves]  (~(got by hoard) space)
    =.  hoard  (~(put by hoard) space banned.rxn troves)
    (ui-emit %space space %banned banned.rxn)
    :: 
      %watchlist
    %-  emil
    %+  murn  p.rxn
    |=  =tope
    =/  pite  (en-trove-path space tope)
    ?:  (~(has by wex.bowl) pite -.space dap.bowl)  ~
    [~ %pass pite %agent [-.space dap.bowl] %watch pite]
  ==
:: handle trove poke from space member
:: to single source of truth (space host)
::
++  handle-trove-action
  |=  [[=space =tope] axn=trove-action:action]
  ^-  _core
  :: relay to single source of truth (space host)
  ::
  ?.  =(-.space our.bowl)  (relay [%trove [space tope] axn])
  :: assert correct permissions
  ::
  ?>  ?:  ?=(%reperm -.axn)  =(-.tope src.bowl)
      (can-write space tope src.bowl)
  =/  rxn    (axn-rxn space tope axn) :: update to other ships
  =.  hoard  (etch-to space tope rxn) :: etch trove to hoard
  =.  core   (kick-unwelcome space tope)
  =.  core   (send-watchlist space tope)
  =.  core   (away-trove-emit:core space tope rxn)
  (ui-emit:core (axn-upd space tope axn))
:: handle update from single source of truth (space host)
::
++  handle-trove-reaction
  |=  [=space =tope rxn=trove-reaction:reaction]
  ^-  _core
  =.  hoard  (etch-to space tope rxn) :: etch trove to hoard
  (ui-emit (rxn-upd space tope rxn))
:: delete trove but attempt to resubscribe
::
++  handle-trove-kick
  |=  =wire
  =/  [=space =tope]     (de-trove-path wire)
  =/  [=banned =troves]  (~(got by hoard) space)
  =.  troves  (~(del by troves) tope)
  =.  hoard   (~(put by hoard) space banned troves)
  =.  core    (ui-emit %space space %rem-trove tope)
  =/  wite    (en-trove-path space tope)
  (emit:core %pass wite %agent [src dap]:bowl %watch wite)
:: commit a reaction to the local hoard data structure
::
++  etch-to
  |=  [=space =tope rxn=trove-reaction:reaction]
  ^-  _hoard
  =/  [=banned =troves]  (~(got by hoard) space)
  =/  =trove-data
    ?+    -.rxn
        :: typically leave name and perms unchanged
        ::
        =+  (~(got by troves) tope)
        -(trove (~(etch to trove) rxn))
      :: new perms and trove
      ::
        %initial
      +.rxn(perms (purge-perms space perms.rxn))
      :: edit name
      ::
        %edit-name
      =-  -(name name.rxn)
      (~(got by troves) tope)
      :: new perms
      ::
        %reperm
      =+  (~(got by troves) tope)
      -(perms (purge-perms space perms.rxn))
    ==
  =.  troves  (~(put by troves) tope trove-data)
  (~(put by hoard) space banned troves)
::
++  axn-upd
  |=  [=space =tope axn=trove-action:action]
  `update`(rxn-upd space tope (axn-rxn +<))
::
++  axn-rxn
  |=  [=space =tope axn=trove-action:action]
  ^-  trove-reaction:reaction
  ?+    -.axn  axn
      %add-node
    =/  =node  [u.axn dat=[now.bowl src.bowl [t d e s k]:axn]]
    =/  =id  `@uvTROVE`(sham now.bowl trail.axn node)
    [%add-node trail.axn id node]
    ::
      %add-folder
    =|  =tract
    =.  tract  tract(from now.bowl, by src.bowl)
    [%add-folder trail.axn tract]
  ==
::
++  rxn-upd
  |=  [=space =tope rxn=trove-reaction:reaction]
  ^-  update
  ?.  ?=(%initial -.rxn)
    [%trove [space tope] rxn]
  [%space space %add-trove tope [name perms trove]:rxn]
::
++  to
  |_  =trove
  ++  etch
    |=  rxn=trove-reaction:reaction
    ^+  trove
    =;  tov
      ~&([rxn %tov tov] tov)
    ?+    -.rxn  !!
        %add-folder
      ?>  (~(has of trove) (snip trail.rxn))
      ?<  (~(has of trove) trail.rxn)
      (~(put of trove) trail.rxn tract.rxn)
      ::
      %rem-folder  (~(lop of trove) trail.rxn)
      ::
        %move-folder
      ?>  (~(has of trove) from.rxn)
      ?>  (~(has of trove) (snip to.rxn))
      =/  dip  (~(dip of trove) from.rxn)
      =.  trove  (~(lop of trove) from.rxn)
      (dop to.rxn dip)
      ::
        %add-node
      ?>  (~(has of trove) trail.rxn)
      =/  =tract   (need (~(get of trove) trail.rxn))
      =.  +.tract  (~(put by +.tract) [id node]:rxn)
      (~(put of trove) trail.rxn tract)
      ::
        %rem-node
      ?>  (~(has of trove) trail.rxn)
      =/  =tract   (need (~(get of trove) trail.rxn))
      =.  +.tract  (~(del by +.tract) id.rxn)
      (~(put of trove) trail.rxn tract)
      ::
        %edit-node
      ?>  (~(has of trove) trail.rxn)
      =/  =tract   (need (~(get of trove) trail.rxn))
      =/  =node    (~(got by +.tract) id.rxn)
      =.  title.dat.node
        ?~(tut.rxn title.dat.node u.tut.rxn)
      =.  description.dat.node
        ?~(dus.rxn description.dat.node u.dus.rxn)
      =.  +.tract  (~(put by +.tract) id.rxn node)
      (~(put of trove) trail.rxn tract)
      ::
        %move-node
      ?>  (~(has of trove) from.rxn)
      ?>  (~(has of trove) to.rxn)
      =/  fract=tract  (need (~(get of trove) from.rxn))
      =/  =tract       (need (~(get of trove) to.rxn))
      =/  =node        (~(got by +.fract) id.rxn)
      =.  +.fract      (~(del by +.fract) id.rxn)
      =.  +.tract      (~(put by +.tract) id.rxn node)
      %-  ~(gas of trove)
      ~[[from.rxn fract] [to.rxn tract]]
    ==
  :: replace existing sub-axal at tel with tov
  ::
  ++  dop
    |=  [tel=trail tov=^trove]
    |-  ^+  trove
    ?~  tel  tov
    :: [~ ~] will be replaced
    =/  kid  (~(gut by dir.trove) i.tel ^+(tov [~ ~]))
    trove(dir (~(put by dir.trove) i.tel $(trove kid, tel t.tel)))
  --
::
++  sour  (scot %p our.bowl)
++  snow  (scot %da now.bowl)
++  has-spaces  .^(? %gu /[sour]/spaces/[snow]/$)
++  is-member
  |=  [=space =ship]
  ^-  ?
  =/  ship  (scot %p ship)
  =/  host  (scot %p -.space)
  =/  view 
    .^(view:m %gx /[sour]/spaces/[snow]/[host]/[+.space]/is-member/[ship]/membership-view)
  ?>(?=(%is-member -.view) is-member.view)
++  got-member
  |=  [=space =ship]
  ^-  member:m
  =/  ship  (scot %p ship)
  =/  host  (scot %p -.space)
  =/  view 
    .^(view:m %gx /[sour]/spaces/[snow]/[host]/[+.space]/members/[ship]/membership-view)
  ?>(?=(%member -.view) member.view)
++  is-admin
  |=  [=space =ship]
  ^-  ?
  =/  =member:m  (got-member space ship)
  (~(has in roles.member) %admin)
--
