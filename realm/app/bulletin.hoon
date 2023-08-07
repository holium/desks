/-  store=bulletin
/+  dbug, default-agent
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0  
  $:  %0
      =provider:store
      =spaces:store
  ==
--
=|  state-0
=*  state  -
%-  agent:dbug
=<
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      hol   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =.  provider.state  ~hostyv
    =.  spaces.state    ~
    :_  this
    [%pass /updates %agent [provider.state dap.bowl] %watch /updates]~
  ::
  ++  on-save  !>(state)
  ::
  ++  on-load
    |=  ole=vase
    ^-  (quip card _this)
    =/  old=state-0  !<(state-0 ole)
    `this(state old)
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    |^
    =^  cards  state
    ?+  mark              (on-poke:def mark vase)
      %bulletin-action    (action:bulletin:hol !<(action:store vase))
    ==
    [cards this]
    --
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
        [%x %spaces ~]
      ``bulletin-reaction+!>([%initial spaces.state])
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
    ?+    path  (on-watch:def path)
        [%updates ~]
      [%give %fact ~ bulletin-reaction+!>([%initial spaces.state])]~
      ::
        [%ui ~]
      ?>  =(our.bowl src.bowl)
      [%give %fact ~ bulletin-reaction+!>([%initial spaces.state])]~
    ==
    [cards this]

  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
        [%updates ~]
      :: ?<  =(our.bowl src.bowl)
      ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  
            %.  `this
            (slog leaf+"{<dap.bowl>}: subscribed to /updates" ~)
            ~&  >>>  "{<dap.bowl>}: subscription to /updates failed"
            `this
          %kick
            ~&  >  "{<dap.bowl>}: kicked, resubscribing..."
            =/  prov         provider.state
            :_  this
            [%pass /updates %agent [prov dap.bowl] %watch /updates]~
          ::
          %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %bulletin-reaction
                =^  cards  state
                  (reaction:bulletin:hol !<(=reaction:store q.cage.sign))
                [cards this]
            ==
        ==
    ==
  ::
  ++  on-arvo   on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-fail   on-fail:def
--
|_  [=bowl:gall cards=(list card)]
::
++  hol  .
++  bulletin
  |%
  ++  action
    |=  =action:store
    ^-  (quip card _state)
    ?-  -.action
      %set-provider   (set-provider +.action)
      %add-space      (add-space +.action)
      %remove-space   (remove-space +.action)
    ==
    ::
    ++  set-provider
      |=  [new-prov=provider:store]
      ^-  (quip card _state)
      =/  old-prov        provider.state
      ?:  =(new-prov old-prov)
        ~&  >>>  "{<dap.bowl>}: already subscribed to {<new-prov>}"
        `state
      =.  provider.state  new-prov
      =.  spaces.state    ~
      :_  state
      :~
        [%pass /updates %agent [old-prov dap.bowl] %leave ~]
        [%pass /updates %agent [new-prov dap.bowl] %watch /updates]
      ==
    ::
    ++  add-space
      |=  [space=space-listing:store]
      ^-  (quip card _state)
      ?>  =(our.bowl src.bowl)
      ?>  =(our.bowl provider.state)
      =.  spaces.state  (~(put by spaces.state) path.space space)
      =/  w-pths        [/ui /updates ~]
      :_  state
      [%give %fact w-pths bulletin-reaction+!>([%space-added space])]~
    ::
    ++  remove-space
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?>  =(our.bowl src.bowl)
      ?>  =(our.bowl provider.state)
      =.  spaces.state  (~(del by spaces.state) path)
      =/  w-pths        [/ui /updates ~]
      :_  state
      [%give %fact w-pths bulletin-reaction+!>([%space-removed path])]~
    --
  ++  reaction
    |=  [rct=reaction:store]
    ^-  (quip card _state)
    ?-  -.rct
      %initial          (on-initial +.rct)
      %space-added      (on-space-added +.rct)
      %space-removed    (on-space-removed +.rct)
    ==
    ::
    ++  on-initial
      |=  [=spaces:store]
      ^-  (quip card _state)
      =.  spaces.state  spaces
      :_  state
      [%give %fact [/ui ~] bulletin-reaction+!>([%initial spaces])]~
    ::
    ++  on-space-added
      |=  [space=space-listing:store]
      ^-  (quip card _state)
      =.  spaces.state  (~(put by spaces.state) path.space space)
      :_  state
      [%give %fact [/ui ~] bulletin-reaction+!>([%space-added space])]~
    ::
    ++  on-space-removed
      |=  [path=space-path:store]
      ^-  (quip card _state)
      =.  spaces.state  (~(del by spaces.state) path)
      :_  state
      [%give %fact [/ui ~] bulletin-reaction+!>([%space-removed path])]~
    :: --
  --
::
:: --
