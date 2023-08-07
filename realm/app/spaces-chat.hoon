/-  store=spaces-chat
/-  sstore=spaces-store
/-  vstore=visas
/-  mstore=membership
/+  lib=spaces-chat
/+  dbug, default-agent
|%
+$  card  card:agent:gall
+$  versioned-state  $%(state-0)
+$  state-0          state-0:store
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
    %-  (slog leaf+"{<dap.bowl>}: watching %spaces /updates..." ~)
    :_  this
    ^-  (list card)
    :~
      [%pass /self %agent [our.bowl %spaces-chat] %poke %spaces-chat-action !>([%init ~])]
      [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
    ?+  mark  (on-poke:def mark vase)
      %spaces-chat-action    (action:hol !<(action:store vase))
    ==
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =/  wirepath  `path`wire
    ?+    wire  (on-agent:def wire sign)
      [%self ~]
        ~&  "on-agent %self {<-.sign>}"
        `this
      [%spaces ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to spaces" ~)  `this
            ~&  >>>  "{<dap.bowl>}: spaces subscription failed"
            `this
          %kick
            ~&  >  "{<dap.bowl>}: spaces kicked us, resubscribing..."
            :_  this
            :~  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
            ==
          %fact
            ?+    p.cage.sign   (on-agent:def wire sign)
                  %spaces-reaction
                =^  cards  state
                  (spaces-reaction:hol !<(=reaction:sstore q.cage.sign))
                [cards this]
                ::
                  %visa-reaction
                =^  cards  state
                  (visas-reaction:hol !<(=reaction:vstore q.cage.sign))
                [cards this]
            ==
        ==
      ==
  ::
  ++  on-save  !>(state)
  ++  on-load
    |=  ole=vase
    ^-  (quip card _this)
    :: do a quick check to make sure we are subbed to /updates in %spaces
    =/  cards=(list card)
      ?:  =(wex.bowl ~)  
        [%pass /spaces %agent [our.bowl %spaces] %watch /updates]~
      ~
    =/  old=state-0  !<(state-0 ole)
    [cards this(state old)]
  ::
  ++  on-peek   |=(path ~)
  ++  on-watch  |=(path !!)
  ++  on-arvo   |=([wire sign-arvo] !!)
  ++  on-leave  |=(path `..on-init)
  ++  on-fail   |=([term tang] `..on-init)
--
|_  [=bowl:gall cards=(list card)]
::
++  hol  .
::
++  action
  |=  =action:store
  ^-  (quip card _state)
  ?-  -.action
    %create-channel   (handle-create-channel +.action)
    %init             (init-spaces:lib state bowl)
  ==
  ::
  ++  handle-create-channel
    ::  We need members to keep track of the channels in a space.
    ::  This poke is sent by the host of the space when a new channel is created.
    |=  [path=space-path:store =chat:store]
    %-  (slog leaf+"{<dap.bowl>}: creating chat channel for {<path>}" ~)
    =/  chats-map        (~(gut by chats.state) path ~)
    =/  chats-map        (~(put by chats-map) path.chat chat)
    =.  chats.state      (~(put by chats.state) path chats-map)
    [cards state]
::
++  spaces-reaction
  |=  [rct=reaction:sstore]
  ~&  %spaces-reaction
  ^-  (quip card _state)
  |^
  ?+  -.rct         `state
    %add            (on-add +.rct)
    %remove         (on-remove +.rct)
  ==
  ::
  ++  on-add
    |=  [new-space=space:sstore =members:mstore]
    ~&  %on-add
    ?.  (is-host:hol path.new-space) :: only host can create chats
      `state
    %-  (slog leaf+"{<dap.bowl>}: creating chat for {<path.new-space>}" ~)
    =/  access-type=chat-access:store    [%role %member]
    =/  cards-and-space       (create-space-chat:lib new-space access-type members now.bowl)
    =/  cards=(list card)     -.cards-and-space
    =/  new-chat              +.cards-and-space
    =/  chats-map             `chats:store`~
    =.  chats-map             (~(put by chats-map) path.new-chat new-chat)
    =.  chats.state           (~(put by chats.state) path.new-space chats-map)
    [cards state]
  ::
  ++  on-remove
    |=  [path=space-path:sstore]
    ?.  (is-host:hol path)  
      =/  chats-map           (~(del by chats.state) path)
      =.  chats.state         chats-map
      `state   
    %-  (slog leaf+"{<dap.bowl>}: deleting chats for {<path>}" ~)
    ::  only host can delete space chats
    =/  chats-to-rm         (~(get by chats.state) path)
    ?~  chats-to-rm         `state
    =/  remove-cards        (remove-ship-from-space-chats:lib our.bowl (need chats-to-rm) bowl)
    =/  chats-map           (~(del by chats.state) path)
    =.  chats.state         chats-map
    [remove-cards state]
    ::
  --
::
++  visas-reaction
  |=  [rct=reaction:vstore]
  ^-  (quip card _state)
  |^
  ?+  -.rct             `state
    %invite-accepted    (on-accepted +.rct)
    %kicked             (on-kicked +.rct)
  ==
  ::
  ++  on-accepted
    |=  [path=space-path:sstore =ship =member:mstore]
    ^-  (quip card _state)
    ?.  (is-host:hol path)  `state   ::  only host can add
    ::  if we are here, we are the host
    =/  chats           (~(get by chats.state) path)
    ?~  chats           `state
    %-  (slog leaf+"{<dap.bowl>}: adding {<ship>} to chats for {<path>}" ~)
    =/  add-cards       (add-ship-to-matching-chats:lib ship member path (need chats) bowl)
    [add-cards state]
  ::
  ++  on-kicked
    |=  [path=space-path:sstore =ship]
    ^-  (quip card _state)
    ::  we were kicked from a space. Host will remove us from chats
    ?:  =(ship our.bowl)  ::  but we need to delete our record of the chats
      %-  (slog leaf+"{<dap.bowl>}: kicked from {<path>}, removing chat records" ~)
      =/  chats-map       (~(del by chats.state) path)
      =.  chats.state     chats-map
      `state
    ?.  (is-host:hol path)  `state   ::  only host can remove
    =/  chats             (~(get by chats.state) path)
    ?~  chats             `state
    %-  (slog leaf+"{<dap.bowl>}: removing {<ship>} from chats for {<path>}" ~)
    =/  remove-cards      (remove-ship-from-space-chats:lib ship (need chats) bowl)
    [remove-cards state]
  --
::
++  is-host
  |=  [path=space-path:store]
  =(our.bowl ship.path)
::
--
