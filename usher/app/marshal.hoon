::
::  marshal - realm deployment utility agent
::
/-  store=marshal
/+  default-agent, verb, dbug
::
=>
  |%
  +$  card  card:agent:gall
  +$  versioned-state
      $%  state-0
      ==
  +$  state-0
    $:  %0
    ==
  --
=|  state-0
=*  state  -
=<
  %+  verb  &
  %-  agent:dbug
  |_  =bowl:gall
  +*  this    .
      def     ~(. (default-agent this %|) bowl)
      core    ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    `this
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    |=  =vase
    ^-  (quip card _this)
    =/  old=(unit state-0)
      (mole |.(!<(state-0 vase)))
    ?^  old
      `this(state u.old)
    ~&  >>  'nuking old %marshal state' ::  temporarily doing this for making development easier
    =^  cards  this  on-init
    :_  this
    =-  (welp - cards)
    %+  turn  ~(tap in ~(key by wex.bowl))
    |=  [=wire =ship =term]
    ^-  card
    [%pass wire %agent [ship term] %leave ~]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
    ?+  mark                    (on-poke:def mark vase)
      %marshal-action           (action:marshal:core !<(action:store vase))
    ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    `this
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ~
  ::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?-    -.sign
          ::
          :: Print error if poke failed
          ::
        %poke-ack
          %-  (slog leaf+"{<dap.bowl>}: %poke-ack on wire {<wire>} => {<sign>}" ~)
          `this
          ::
          :: Print error if subscription failed
          ::
        %watch-ack
          %-  (slog leaf+"{<dap.bowl>}: %watch-ack on wire {<wire>} => {<sign>}" ~)
          `this
          ::
          :: Do nothing if unsubscribed
          ::
        %kick
          %-  (slog leaf+"{<dap.bowl>}: %kick on wire {<wire>} => {<sign>}" ~)
          `this
          ::
          :: Update remote counter when we get a subscription update
          ::
        %fact
          %-  (slog leaf+"{<dap.bowl>}: %fact on wire {<wire>} => {<sign>}" ~)
          `this
  ==
  ::
  ++  on-arvo
    |=  [wire sign-arvo]
    ^-  (quip card _this)
    %-  (slog leaf+"{<dap.bowl>}: on-arvo on wire {<wire>} => {<sign-arvo>}" ~)
    `this
  ::
  ++  on-leave  |=(path `..on-init)
  ::
  ++  on-fail
    |=  [=term =tang]
    ^-  (quip card _this)
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
--
|_  [=bowl:gall cards=(list card)]
::
++  core  .
++  marshal
  |%
  ++  action
    |=  =action:store
    ^-  (quip card _state)
    |^
    ?-  -.action
      %commit           (on-commit +.action)
    ==
    ::  %commit to clay
    ++  on-commit
      |=  [mount-point=term]  :: doco says %desk, but check this out: https://developers.urbit.org/reference/arvo/clay/tasks#dirk---commit
      ^-  (quip card _state)
      %-  (slog leaf+"{<dap.bowl>}: on-commit called. committing {<mount-point>}..." ~)
      :_  state
      :~  [%pass /commit %arvo %c [%dirk mount-point]]
      ==

    --
  ::
  ++  scry
    |%
    ::
    ++  realm
      |=  [mount-point=@tas]
      ~
    --
  ++  helpers
    |%
    ::
    --
  --
::
--