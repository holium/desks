/-  store=spaces-store
/-  membership-store=membership
/-  vstore=visas
/-  hark=hark-store
/-  g=new-groups
/+  default-agent, dbug, agentio, lib=spaces, visa-lib=visas, grp=groups
^-  agent:gall
::
::  %spaces [realm]: A store for Realm space metadata and members.
::
=>
  |%
  +$  card  card:agent:gall
  +$  versioned-state
      $%  state-1
          state-0
      ==
  ::
  +$  state-1
    $:  %1
        =spaces:store
        =invitations:vstore
        =membership:membership-store
        current=space-path:store
    ==
  ::
  +$  state-0
    $:  %0
        =spaces:store
        =invitations:vstore
        =membership:membership-store
    ==
  --
=|  state-1
=*  state  -
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      core  ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  our-name                `@t`(scot %p our.bowl)
    =/  our-space               (create-space:lib our.bowl 'our' [name=our-name '' %our %private '' '#000000' %home] now.bowl)
    =/  our-member              [roles=(silt `(list role:membership-store)`~[%owner %admin]) alias='' status=%host]
    =/  our-members             (malt `(list (pair ship member:membership-store))`~[[our.bowl our-member]])
    =/  initial-membs           `membership:membership-store`(malt `(list (pair space-path:store members:membership-store))`~[[path.our-space our-members]])
    =/  initial-spaces          `spaces:store`(~(put by spaces.state) [path:our-space our-space])
    =.  state                   [%1 spaces=initial-spaces invitations=~ membership=initial-membs current=path:our-space]
    `this
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  `this(state [%1 spaces=spaces.old invitations=invitations.old membership=membership.old current=[our.bowl 'our']])
      %1  `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    |^
    =^  cards  state
    ?+  mark                    (on-poke:def mark vase)
      %spaces-action            (action:spaces:core !<(action:store vase))
      %visa-action              (action:visas:core !<(action:vstore vase))
    ==
    [cards this]
    --
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path                  (on-peek:def path)
        [%x %all ~]
      ``spaces-view+!>([%spaces spaces.state])
      ::
        [%x %groups ~]
      =/  groups                (our-groups:grp our.bowl now.bowl)
      ``groups-view+!>([%groups groups])
      ::
        [%x %groups @ @ %members ~]
      =/  =ship                `@p`(slav %p i.t.t.path)
      =/  name                 (woad i.t.t.t.path)
      =/  group                (get-group:grp [ship name] our.bowl now.bowl)
      ``groups-view+!>([%members fleet.group])
      ::
        [%x @ @ ~]
      =/  =ship                 `@p`(slav %p i.t.path)
      =/  space-pth             (woad i.t.t.path)
      =/  space                 (~(got by spaces.state) [ship space-pth])
      ``spaces-view+!>([%space space])
      ::
        [%x %invitations ~]
      ``visa-view+!>([%invitations invitations.state])
      ::
        [%x @ @ %members ~]     ::  ~/scry/spaces/~zod/our/members.json
      =/  host                  `@p`(slav %p i.t.path)
      =/  space-pth             (woad i.t.t.path)
      =/  members               (~(got by membership.state) [host space-pth])
      ``membership-view+!>([%members members])
      ::
        [%x @ @ %members @ ~]   ::  ~/scry/spaces/~zod/our/members/~dev.json
      =/  host                  `@p`(slav %p i.t.path)
      =/  space-pth             (woad i.t.t.path)
      =/  patp                  `@p`(slav %p i.t.t.t.t.path)
      =/  members               (~(get by membership.state) [host space-pth])
      =/  member                (~(get by (need members)) patp)
      ?~  member                ``membership-view+!>([%member (silt ~[~])])
      ``membership-view+!>([%member (need member)])
      :: ::
        [%x @ @ %is-member @ ~] ::  ~/scry/spaces/~zod/our/is-member/~fes.json
      =/  host                  `@p`(slav %p i.t.path)
      =/  space-pth             (woad i.t.t.path)
      =/  patp                  `@p`(slav %p i.t.t.t.t.path)
      =/  members               (~(get by membership.state) [host space-pth])
      ?~  members               ``membership-view+!>([%is-member %.n])
      =/  is-member             (~(has by (need members)) patp)
      ``membership-view+!>([%is-member is-member])
      ::
        [%x %current ~] :: ~/scry/current.json
      ``spaces-reaction+!>([%current current.state])
      ::
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
      ?+    path                      (on-watch:def path)
          [%updates ~]
        ?>  =(our.bowl src.bowl)      ::  only host should get all updates
        [%give %fact [/updates ~] spaces-reaction+!>([%initial spaces.state membership.state invitations.state current.state])]~
        ::
          [%spaces ~]  :: Sends %add reaction when user joins a new space
        ?>  =(our.bowl src.bowl)
        %+  turn  ~(tap in ~(key by spaces.state))
        |=  =space-path:store
        [%give %fact ~ spaces-reaction+!>([%add (~(got by spaces.state) space-path) (~(got by membership.state) space-path)])]
        ::
          [%spaces @ @ ~]  :: The space level watch subscription
        =/  host                `@p`(slav %p i.t.path)
        =/  space-pth             (woad i.t.t.path)
        =/  space               (~(got by spaces.state) [host space-pth])
        ?>  ?|  (check-member:security [host space-pth] src.bowl)     ::  only members should subscribe
                =(access.space %public)                               :: allow public spaces to be watched
            ==
        =/  members             (~(got by membership.state) [host space-pth])
        [%give %fact ~ spaces-reaction+!>([%remote-space [host space-pth] space members])]~
        ::
          [%current ~]  :: get the currently opened space
        ?>  =(our.bowl src.bowl)  :: only we should know what space we're in
        [%give %fact ~ spaces-reaction+!>([%current current])]~
        ::
      ==
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =/  wirepath  `path`wire
    ?+    wire  (on-agent:def wire sign)
      [%groups @ @ *]  ::  getting new group members
        ?+    -.sign            (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  `this
            ~&  >>>  "{<dap.bowl>}: spaces to groups subscription failed"
            `this
          %kick
            =/  =ship           `@p`(slav %p i.t.wire)
            ~&  >  "{<dap.bowl>}: groups kicked us, resubscribing... {<ship>}"
            =/  watch-path  /groups/(scot %p our.bowl)/[(snag 2 `(list knot)`wire)]/updates/init
            :_  this
            :~  [%pass watch-path %agent [our.bowl %groups] %watch watch-path]
            ==
          %fact
            ?+  p.cage.sign  `this
                %group-update-0
              =/  groups-update  q:!<(update:g q.cage.sign)
              ?+  -.groups-update  `this
                  %cordon
                ?-  +<.groups-update
                    %shut
                  ?-  +>-.groups-update
                      %add-ships
                    ?+  +>+<.groups-update  `this
                        %pending
                      =^  cards  state
                        %^  spin  ~(tap in `(set ship)`+>+>.groups-update)
                          state
                        |=  [=ship =_state]
                        ^-  [(list card) _state]
                        =/  join-action
                          ^-  action:vstore
                          :*  %send-invite
                              ^-  space-path:store
                              :-  (slav %p (snag 1 `(list knot)`wire))
                              (snag 2 `(list knot)`wire)
                              ship
                              role=%member
                              message='Join the space for the group'
                          ==
                        %-  action:visas:core
                        join-action
                      =/  cards  (zing cards)
                      [cards this]
                    ==
                      %del-ships
                    `this
                  ==
                    %open
                  :: TODO: sync bans
                  `this
                    %swap
                  :: TODO: sync entry policy
                  `this
                ==
                  %fleet
                ?+  -.q.groups-update  `this
                    %add
                  =/  join-action
                    ^-  action:vstore
                    :*  %send-invite
                        ^-  space-path:store
                        :-  (slav %p (snag 1 `(list knot)`wire))
                        (snag 2 `(list knot)`wire)
                        ship=(snag 0 ~(tap in p.groups-update))
                        role=%member
                        message='Join the space for the group'
                    ==
                  =^  cards  state
                    %-  action:visas:core
                    join-action
                  [cards this]
                    %del
                  =/  kick-action
                    ^-  action:vstore
                    :*  %group-kick-member
                        ^-  space-path:store
                        :-  (slav %p (snag 1 `(list knot)`wire))
                        (snag 2 `(list knot)`wire)
                        ship=(snag 0 ~(tap in p.groups-update))
                    ==
                  =^  cards  state
                    %-  action:visas:core
                    kick-action
                  [cards this]
                ==
              ==
            ==
        ==
      [%spaces @ @ ~]  ::  only members will subscribe on this wire
        ?+    -.sign            (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  `this
            ~&  >>>  "{<dap.bowl>}: spaces subscription failed"
            :_  this
            ::  bunted update indicates failure
            [%give %fact [/updates ~] spaces-reaction+!>([%remote-space [*ship *@t] *space:store ~])]~
          %kick
            =/  =ship           `@p`(slav %p i.t.wire)
            =/  space-pth       `@t`i.t.t.wire
            %-  (slog leaf+"{<dap.bowl>}: spaces kicked us, resubscribing... {<ship>} {<space-pth>}" ~)
            =/  watch-path      [/spaces/(scot %p ship)/(scot %tas space-pth)]
            :_  this
            :~  [%pass watch-path %agent [ship %spaces] %watch watch-path]
            ==
          %fact
            ?+    p.cage.sign   (on-agent:def wire sign)
                %spaces-reaction
              =^  cards  state
                (reaction:spaces:core !<(=reaction:store q.cage.sign))
              [cards this]
                %visa-reaction
              =^  cards  state
                (reaction:visas:core !<(=reaction:vstore q.cage.sign))
              [cards this]
            ==
        ==

    ==
  ++  on-arvo   |=([wire sign-arvo] !!)
  ::
  ++  on-fail
    |=  [=term =tang]
    ^-  (quip card _this)
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
  ::
  ++  on-leave  |=(path `..on-init)
  --
::
|_  [=bowl:gall cards=(list card)]
::
++  core  .
++  spaces
  |%
  ++  action
    |=  [act=action:store]
    ^-  (quip card _state)
    |^
    ?-  -.act
      %add            (handle-add +.act)
      %update         (handle-update +.act)
      %remove         (handle-remove +.act)
      %join           (handle-join +.act)
      %leave          (handle-leave +.act)
      %current        (handle-current +.act)
      :: %kicked         (handle-kicked +.act)
    ==
    ::
    ++  handle-add
      |=  [slug=@t payload=add-payload:store members=members:membership-store]
      ^-  (quip card _state)
      ?>  (team:title our.bowl src.bowl)
      =.  slug                  (find-available-path [our.bowl slug] spaces.state)
      =/  new-space             (create-space:lib our.bowl slug payload now.bowl)
      =.  spaces.state          (~(put by spaces.state) [path.new-space new-space])
      ::  we need to set a host + member value and exclude the host from make-invitations
      =.  members               (~(put by members) [our.bowl [roles=(silt `(list role:membership-store)`~[%owner %admin]) alias='' status=%host]])
      =.  membership.state      (~(put by membership.state) [path.new-space members])
      =/  visa-cards            (initial-visas:helpers path.new-space members new-space)
      ::  return updated state and a combination of invitations (pokes)
      ::   to new members and gifts to any existing/current subscribers (weld)
      =/  cards
        ^-  (list card)
        %+  weld   visa-cards
        ^-  (list card)
        :~
          [%give %fact [/updates ~] spaces-reaction+!>([%add new-space members])]
          [%give %fact [/current ~] spaces-reaction+!>([%current path.new-space])]
          [%give %fact [/spaces ~] spaces-reaction+!>([%add new-space members])]
        ==
      =?  cards  =(%group type.payload)
        %+  weld  cards
        =/  watch-path  /groups/(scot %p our.bowl)/[+.path.new-space]/updates/init
        `(list card)`[%pass watch-path %agent [our.bowl %groups] %watch watch-path]~
      :-  cards
      state(current path.new-space)
    ::
    ++  find-available-path
      |=  [spath=[=ship slug=@t] =spaces:store]
      ^-  @t
      |-
        ?.  (~(has by spaces) spath)   :: if the path is empty, return the valid slug
          slug.spath
        $(spath [ship.spath (increment-slug slug.spath)])  :: if the slug was already taken, try incrementing
    ::
    ++  increment-slug
      |=  slug=@t
      ^-  @t
      =/  last-char  (snag 0 (flop (trip slug)))
      ?:  &((gte last-char '0') (lte last-char '9')) :: if last-char is a numeric digit
        (crip (snoc (snip (trip slug)) `@t`(add 1 last-char))) :: increment the digit
      (crip (snoc (trip slug) '1')) :: else append '1' to the slug
    ::
    ++  handle-update
      |=  [path=space-path:store edit-payload=edit-payload:store]
      ^-  (quip card _state)
      ?>  (has-at-least-auth:security path src.bowl %admin)
      ?:  (is-host:core ship.path)
        (host-handle-update path edit-payload)
      (member-handle-update path)
    ++  member-handle-update
      |=  [path=space-path:store]
      ^-  (quip card _state)
      :_  state
      [%pass / %agent [ship.path dap.bowl] %poke spaces-action+!>(act)]~
    ++  host-handle-update
      |=  [path=space-path:store edit-payload=edit-payload:store]
      ^-  (quip card _state)
      =/  old                   (~(got by spaces.state) path)
      =/  updated               `space:store`(edit-space old edit-payload)
      ?:  =(old updated)        :: if the old type equals new
          [~ state]             :: return state unchanged
      =.  updated-at.updated    now.bowl
      =/  watch-paths           [/updates /spaces/(scot %p ship.path)/(scot %tas space.path) ~]
      =.  spaces.state          (~(put by spaces.state) path updated)
      :_  state
      [%give %fact watch-paths spaces-reaction+!>([%replace updated])]~
      ::
      ++  edit-space
        |=  [=space:store edit=edit-payload:store]
        ^-  space:store
        =.  name.space  name.edit
        =.  description.space  description.edit
        =.  access.space  access.edit
        =.  picture.space  picture.edit
        =.  color.space  color.edit
        =.  theme.space  theme.edit
        space
    ::
    ++  handle-remove
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?>  (has-auth:security path src.bowl %owner)
      ?:  =('our' space.path) :: we cannot delete our space
        `state
      =.  spaces.state                (~(del by spaces.state) path)
      =/  watch-paths                 [/updates /spaces/(scot %p ship.path)/(scot %tas space.path) ~]
      =/  cards  `(list card)`[%give %fact watch-paths spaces-reaction+!>([%remove path])]~
      ::  if we are removing current space, set to our space
      =/  update-current  =(path current.state)
      =?  current.state  update-current
        [our.bowl 'our']
      =?  cards  update-current
        %+  welp  cards
        [%give %fact [/current ~] spaces-reaction+!>([%current current.state])]~
      =/  space-members  `(map ship member:membership-store)`(~(got by membership.state) path)
      =.  cards
        %+  weld  cards
        %+  murn  ~(tap by space-members)
        |=  [=ship =member:membership-store]
        ^-  (unit card)
        ?.  =(%invited status.member)  ~
        `[%pass / %agent [ship dap.bowl] %poke visa-action+!>([%revoke-invite path])]
      =.  membership.state            (~(del by membership.state) path)
      [cards state]
    ::
    ++  handle-join
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?:  (is-host:core ship.path)
        (host-handle-join path src.bowl)
      (member-handle-join path)
      ::
      ++  member-handle-join
        |=  [path=space-path:store]
        ^-  (quip card _state)
        :_  state
        [%pass / %agent [ship.path dap.bowl] %poke spaces-action+!>([%join path])]~
      ::
      ++  host-handle-join
        |=  [path=space-path:store =ship]
        ^-  (quip card _state)
        =.  membership.state
          =/  space-members   (~(got by membership.state) path)
          =/  space  (~(got by spaces.state) path)
          =/  member
            ?:  =(%public access.space)
              ^-  (unit member:membership-store)
              :*  ~
                  roles=(silt [%member]~)
                  alias=''
                  status=%joined
              ==
            (~(get by space-members) ship)
          =?  space-members  !=(~ member)
            ?~  member  !!
            =.  status.u.member  %joined
            (~(put by space-members) [ship u.member])
          (~(put by membership.state) [path space-members])
        ::  just created a new member, so we need to tell everyone they joined
        =/  new-members             (~(got by membership.state) path)
        =/  member                  (~(got by new-members) ship)
        =/  member-path             /spaces/(scot %p ship.path)/(scot %tas space.path)
        =/  watch-paths             [member-path /updates ~]
        =/  cards
          ^-  (list card)
          ::  temporarily using %invite-accepted until we can add a new action
          :~  [%pass / %agent [ship %spaces] %poke visa-action+!>([%stamped path])]                 ::  Send stamp confirmation
              :: [%pass / %agent [our.bowl %contact-push-hook] %poke contact-share+!>([%share accepter])]  ::  share our contact
              [%give %fact watch-paths visa-reaction+!>([%invite-accepted path ship member])]      ::  Notify watchers
          ==
        =?  cards  =(%group type:(~(got by spaces.state) path))
          %+  weld  cards
            =/  action  [path now.bowl %fleet (silt ~[ship]) %add ~]
            `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(action)]~  :: Add member to group
        [cards state]
        :: :~
        ::   [%give %fact watch-paths visa-reaction+!>([%invite-accepted path ship member])]
        ::   [%pass watch-path %agent [ship.path %spaces] %watch watch-path]
        :: ==
    ::
    ++  handle-leave
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?.  (is-host:core ship.path)
        (member-handle-leave path)
      (host-handle-leave path src.bowl)
      ::
      ++  member-handle-leave
        |=  [path=space-path:store]
        =.  spaces.state          (~(del by spaces.state) path)
        =.  membership.state      (~(del by membership.state) path)
        =/  has-incoming          (~(get by invitations.state) path)
        =/  watch-path            [/spaces/(scot %p ship.path)/(scot %tas space.path)]
        =/  cards
          ^-  (list card)
          :~
            [%pass / %agent [ship.path dap.bowl] %poke spaces-action+!>([%leave path])]
            [%give %fact [/updates ~] spaces-reaction+!>([%remove path])]
            [%pass watch-path %agent [ship.path %spaces] %leave ~]
          ==
        =/  update-current  =(path current.state)
        =?  current.state  update-current
          [our.bowl 'our']
        =?  cards  update-current
          %+  welp  cards
          [%give %fact [/current ~] spaces-reaction+!>([%current current.state])]~
        ?~  has-incoming
          :_  state
          cards
        =.  invitations.state    (~(del by invitations.state) path)
        :_  state
        cards
      ::
      ++  host-handle-leave
        |=  [path=space-path:store =ship]
        =/  membs                   (~(got by membership.state) path)
        =.  membs                   (~(del by membs) ship)
        =.  membership.state        (~(put by membership.state) [path membs])
        =/  watch-paths             [/updates /spaces/(scot %p ship.path)/(scot %tas space.path) ~]
        =/  cards  `(list card)`[%give %fact watch-paths visa-reaction+!>([%kicked path ship])]~
        =?  cards  =(%group type:(~(got by spaces.state) path))
          %+  weld  cards
            =/  action  [path now.bowl %fleet (silt ~[ship]) %del ~]
            `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(action)]~  :: Add member to group
        [cards state]
    ::
    ++  handle-current
      |=  [path=space-path:store]
      ^-  (quip card _state)
      =.  space.path  (woad space.path)
      ?>  =(our.bowl src.bowl) :: only we can set current
      ?:  =(current.state path)
        `state
      =/  cards  `(list card)`[%give %fact [/current /updates ~] spaces-reaction+!>([%current path])]~
      ?>  (~(has by spaces.state) path)
      :-  cards
      state(current path)
    ::
    --
  ++  reaction
    |=  [rct=reaction:store]
    ^-  (quip card _state)
    |^
    ?-  -.rct
      %initial        (on-initial +.rct)
      %add            (on-add +.rct)
      %replace        (on-replace +.rct)
      %remove         (on-remove +.rct)
      %remote-space   (on-remote-space +.rct)
      %current        (on-current +.rct)
    ==
    ::
    ++  on-initial
      |=  [=spaces:store =membership:membership-store =invitations:vstore current=space-path:store]
      ^-  (quip card _state)
      `state
    ::
    ++  on-add
      |=  [space=space:store members=members:membership-store]
      ^-  (quip card _state)
      `state
    ::
    ++  on-replace
      |=  [space=space:store]
      ^-  (quip card _state)
      =.  spaces.state      (~(put by spaces.state) path.space space)
      =/  watch-paths                     [/updates ~]
      :_  state
      [%give %fact [/updates ~] spaces-reaction+!>([%replace space])]~

    ::
    ++  on-remove
      |=  [path=space-path:store]
      ^-  (quip card _state)
      =.  spaces.state          (~(del by spaces.state) path)
      ?.  (is-host:core ship.path)
        (member-on-remove path)
      (host-on-remove path)
      ::
      ++  member-on-remove
        |=  [path=space-path:store]
        =/  has-incoming                    (~(get by invitations.state) path)
        ?~  has-incoming                    ::  we dont have an invitation, so we are a member, simply remove
          `state(membership (~(del by membership.state) path))
        =.  membership.state                (~(del by membership.state) path)
        =.  invitations.state               (~(del by invitations.state) path)
        =/  update-current  =(path current.state)
        =?  current.state  update-current
          [our.bowl 'our']
        =/  watch-paths                     [/updates ~]
        =/  cards
          ^-  (list card)
          :~
            [%pass /spaces/(scot %p ship.path)/(space-name:encode:lib space.path) %agent [ship.path %spaces] %leave ~]
            [%give %fact watch-paths spaces-reaction+!>([%remove path])]
          ==
        =?  cards  update-current
          %+  welp  cards
          [%give %fact [/current ~] spaces-reaction+!>([%current current.state])]~
        [cards state]
      ::
      ++  host-on-remove
        |=  [path=space-path:store]
        =/  members                       (~(got by membership.state) path)
        =.  members                       (~(del by members) our.bowl)
        =.  membership.state              (~(del by membership.state) path)
        =/  watch-path                    [/spaces/(scot %p ship.path)/(scot %tas space.path) ~]
        :_  state
        :~
          [%give %kick watch-path ~]
          [%give %fact watch-path spaces-reaction+!>([%remove path])]
        ==
    ::
    ++  on-remote-space
      |=  [path=space-path:store =space:store =members:membership-store]
      ^-  (quip card _state)
      =.  spaces.state          (~(put by spaces.state) [path space])
      =.  membership.state      (~(put by membership.state) [path members])
      :_  state
      %+  weld
      :~
        [%give %fact [/updates ~] spaces-reaction+!>([%remote-space path space members])]
        [%give %fact [/spaces ~] spaces-reaction+!>([%add space members])]
      ==
      ::  share contact with all members
      %+  murn  ~(tap in ~(key by members))
      |=  =ship
      ^-  (unit card)
      ?~  =(our.bowl ship)  ~
      =/  cage  friends-action+!>([%share-contact ship])
      `[%pass / %agent [our.bowl %friends] %poke cage]
    ::
    ++  on-current
      |=  [path=space-path:store]
      ^-  (quip card _state)
      :_  state(current path)
      [%give %fact [/current ~] spaces-reaction+!>([%current path])]~
    ::
    --
  ++  helpers
    |%
    ++  initial-visas
      |=  [path=space-path:store =members:membership-store =space:store]
      ^-  (list card)
      ::  loop thru each member, and build a list of invitations/pokes (acc)
      =.  members                       (~(del by members) our.bowl)
      %-  ~(rep by members)
        |=  [[=ship =member:membership-store] acc=(list card)]
        =/  role                        (snag 0 ~(tap in roles.member))
        =/  new-visa                    (new-visa:visa-lib path src.bowl ship role space '' now.bowl)
        %+  snoc  acc
        [%pass / %agent [ship dap.bowl] %poke visa-action+!>([%invited path new-visa])]
    ::
    --
  --
++  visas
  |%
  ++  action
    |=  [act=action:vstore]
    ^-  (quip card _state)
    |^
    ?-  -.act
      %send-invite          (handle-send +.act)
      %invited              (handle-invited +.act)
      %accept-invite        (handle-accept +.act)
      %decline-invite       (handle-decline +.act)
      %stamped              (handle-stamped +.act)
      %kick-member          (handle-kick +.act)
      %group-kick-member    (group-handle-kick +.act)
      %revoke-invite        (handle-deported +.act)
      %edit-member-role     (handle-edit-role +.act)
    ==
    ::
    ++  handle-send  ::  Sends an invite to a ship
      |=  [path=space-path:store =ship =role:membership-store message=@t]
      ^-  (quip card _state)
      ?>  (check-member:security path src.bowl) ::  only members can invite
      ?>  (has-at-least-auth:security path src.bowl %admin)   :: and they have to be at least an admin
      ?:  (check-member:security path ship)     ::  target ship must not be a member already to be invited
        `state
      =/  space                (~(got by spaces.state) path)
      =/  new-visa             (new-visa:visa-lib path src.bowl ship role space message now.bowl)
      ?.  (is-host:core ship.path)
        (member-handle-send path ship new-visa)
      (host-handle-send path ship role new-visa)
      ::
      ++  member-handle-send
        |=  [path=space-path:store =ship new-visa=invite:vstore]
        :_  state
        [%pass / %agent [ship.path dap.bowl] %poke visa-action+!>(act)]~   ::  Send invite request to host
      ::
      ++  host-handle-send
        |=  [path=space-path:store =ship =role:membership-store new-visa=invite:vstore]
        ?>  ?!(=(our.bowl ship))        ::  Dont invite yourself
        =/  members                   (~(gut by membership.state) path `members:membership-store`[~])
        =/  new-member
          [
            roles=(silt `(list role:membership-store)`~[role])
            alias=''
            status=%invited
          ]
        =.  members                     (~(put by members) [ship new-member])
        =.  membership.state            (~(put by membership.state) [path members])
        =/  watch-paths                 [/updates /spaces/(scot %p ship.path)/(scot %tas space.path) ~]
        :_  state
        :~  [%pass / %agent [ship dap.bowl] %poke visa-action+!>([%invited path new-visa])]             ::  Send invite request to invited
            [%give %fact watch-paths visa-reaction+!>([%invite-sent path ship new-visa new-member])]    ::  Notify watchers
        ==
    ::
    ++  handle-invited  ::  when an invite is received
      |=  [path=space-path:store =invite:vstore]
      ^-  (quip card _state)
      =.  invitations.state           (~(put by invitations.state) [path invite])
      =/  notify=action:hark          (notify path /invite (crip " invited you to {<`@t`(scot %tas name.invite)>} in Realm."))
      :_  state
      :~  [%pass / %agent [our.bowl %hark-store] %poke hark-action+!>(notify)]                      ::  send notification to ship
          [%give %fact [/updates ~] visa-reaction+!>([%invite-received path invite])]
      ==
    ::
    ++  handle-accept
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?.  (is-host:core ship.path)
        (member-handle-accept path)
      (host-handle-accept path)
      ::
      ++  member-handle-accept
        |=  [path=space-path:store]
        :_  state
        [%pass / %agent [ship.path %spaces] %poke visa-action+!>(act)]~
      ::
      ++  host-handle-accept
        |=  [path=space-path:store]
        =/  accepter                    src.bowl
        =/  members                     (~(gut by membership.state) path `members:membership-store`[~])
        =/  upd-mem                     (~(got by members) accepter)
        =.  status.upd-mem              %joined
        =.  members                     (~(put by members) [accepter upd-mem])
        =.  membership.state            (~(put by membership.state) [path members])
        =/  member-path                 /spaces/(scot %p ship.path)/(scot %tas space.path)
        =/  watch-paths                 [/updates member-path ~]
        =/  cards=(list card)
          :~  [%pass / %agent [accepter %spaces] %poke visa-action+!>([%stamped path])]                 ::  Send stamp confirmation
              :: [%pass / %agent [our.bowl %contact-push-hook] %poke contact-share+!>([%share accepter])]  ::  share our contact
              [%give %fact watch-paths visa-reaction+!>([%invite-accepted path accepter upd-mem])]      ::  Notify watchers
          ==
        =?  cards  =(%group type:(~(got by spaces.state) path))
          %+  weld  cards
            =/  action  [path now.bowl %fleet (silt ~[src.bowl]) %add ~]
            `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(`action:g`action)]~  :: Add member to group
        [cards state]
    ::
    ++  handle-decline
      |=  [path=space-path:store]
      ^-  (quip card _state)
      ?.  (is-host:core ship.path)
        (member-handle-decline path)
      (host-handle-decline path)
      ::
      ++  member-handle-decline  ::  If we are invited we will send the invite action to the host
        |=  [path=space-path:store]
        =.  invitations.state         (~(del by invitations.state) path)
        =/  watch-path                /spaces/(scot %p ship.path)/(scot %tas space.path)
        :_  state
        :~  [%pass watch-path %agent [ship.path %spaces] %poke visa-action+!>(act)]
            [%give %fact [/updates ~] visa-reaction+!>([%invite-removed path])]
        ==
      ::
      ++  host-handle-decline
        |=  [path=space-path:store]
        =/  decliner                    src.bowl
        =/  membs                       (~(got by membership.state) path)
        =.  membs                       (~(del by membs) decliner)
        =.  membership.state            (~(put by membership.state) [path membs])
        :_  state
        [%give %fact [/updates ~] visa-reaction+!>([%kicked path decliner])]~
    ::
    ++  handle-stamped
      |=  [path=space-path:store]
      ^-  (quip card _state)
      =.  invitations.state           (~(del by invitations.state) path)
      =/  watch-path                  [/spaces/(scot %p ship.path)/(scot %tas space.path)]
      :_  state
      ::  watch the spaces and passports path once invite flow is complete
      :~
        [%pass watch-path %agent [ship.path %spaces] %watch watch-path]
        [%give %fact [/updates ~] visa-reaction+!>([%invite-removed path])]                   ::  we want to remove the invite after accepted
      ==
    ::
    ++  group-handle-kick
      |=  [path=space-path:store =ship]
      ^-  (quip card _state)
      ?>  (has-at-least-auth:security path src.bowl %admin)
      ?>  ?!((has-auth:security path ship.path %owner))  :: cannot be trying to kick the owner
      ?>  (is-host:core ship.path)
      (host-handle-kick path ship %.y)
    ::
    ++  handle-kick
      |=  [path=space-path:store =ship]
      ^-  (quip card _state)
      ?>  (has-at-least-auth:security path src.bowl %admin)
      ?>  ?!((has-auth:security path ship %owner))  :: cannot be trying to kick the owner
      ?.  (is-host:core ship.path)
        (member-handle-kick path)
      (host-handle-kick path ship %.n)
      ::
      ++  member-handle-kick
        |=  [path=space-path:store]
        :_  state
        [%pass / %agent [ship.path %spaces] %poke visa-action+!>(act)]~
      ::
      ++  host-handle-kick
        |=  [path=space-path:store =ship group=?]
        =/  membs                   (~(got by membership.state) path)
        =.  membs                   (~(del by membs) ship)
        =.  membership.state        (~(put by membership.state) [path membs])
        :: =/  notify=action:hark        (notify path /realm (crip " issued you a invite to join {<`@t`(scot %tas name.invite)>} in Realm."))
        =/  watch-path              /spaces/(scot %p ship.path)/(scot %tas space.path)
        =/  cards
          ^-  (list card)
          :~  [%give %fact [watch-path /updates ~] visa-reaction+!>([%kicked path ship])]
              [%give %kick ~[/spaces/(scot %p ship.path)/(scot %tas space.path)] (some ship)]
              [%pass / %agent [ship %spaces] %poke visa-action+!>([%revoke-invite path])]
          ==
        =?  cards
          ?&  =(%group type:(~(got by spaces.state) path))
              !group
          ==
          %+  weld  cards
            =/  action  [path now.bowl %fleet (silt ~[ship]) %del ~]
            `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(action)]~  :: Add member to group
        [cards state]
    ::
    ++  handle-deported
      |=  [path=space-path:store]
      ^-  (quip card _state)
      =.  invitations.state           (~(del by invitations.state) path)
      :_  state
      [%give %fact [/updates ~] visa-reaction+!>([%invite-removed path])]~
    ::
    ++  handle-edit-role
      |=  [path=space-path:store member=ship role-set=(set role:membership-store)]
      ^-  (quip card _state)
      ?>  (has-at-least-auth:security path src.bowl %admin)
      ?>  ?!((has-auth:security path member %owner))  :: cannot be trying to edit the owner
      ?.  (is-host:core ship.path)
        (member-handle-edit-role path)
      (host-handle-edit-role path member role-set)
      ::
      ++  member-handle-edit-role
        |=  [path=space-path:store]
        :_  state
        [%pass / %agent [ship.path %spaces] %poke visa-action+!>(act)]~
    ++  host-handle-edit-role
      |=  [path=space-path:store member=ship role-set=(set role:membership-store)]
      ^-  (quip card _state)
      =/  src-roles           roles:(~(got by (~(got by membership) path)) src.bowl)
      =/  target-roles        roles:(~(got by (~(got by membership) path)) member)
      ?>  ?!((~(has in target-roles) %owner))  :: can't edit owner's roles
      ?>  ?|  (~(has in src-roles) %admin)
              (~(has in src-roles) %owner)
          ==
      =/  space-members       (~(got by membership) path)
      =/  member-state        (~(got by space-members) member)
      =.  roles.member-state  role-set
      =.  space-members       (~(put by space-members) [member member-state])
      =.  membership          (~(put by membership) [path space-members])
      =/  watch-paths         [/updates /spaces/(scot %p ship.path)/(scot %tas space.path) ~]
      =/  cards
        ^-  (list card)
        [%give %fact [/spaces/(scot %p ship.path)/(scot %tas space.path) /updates ~] visa-reaction+!>([%edited path member role-set])]~
      =?  cards  =(%group type:(~(got by spaces.state) path))
        %+  weld  cards
          ?:  (~(has in role-set) %admin)
            ::  %member to %admin
            =/  action  [path now.bowl %fleet (silt ~[member]) %add-sects (sy [%admin ~])]
            `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(action)]~  :: Edit member in group
          ::  remove %admin status
          =/  action  [path now.bowl %fleet (silt ~[member]) %del-sects (sy [%admin ~])]
          `(list card)`[%pass / %agent [our.bowl %groups] %poke group-action+!>(action)]~  :: Edit member in group
      [cards state]
    ::
    --
  ++  reaction
    |=  [rct=reaction:vstore]
    ^-  (quip card _state)
    |^
    ?-  -.rct
      %invite-sent        (on-sent +.rct)
      %invite-received    `state
      %invite-removed     `state
      %invite-accepted    (on-accepted +.rct)
      %kicked             (on-kicked +.rct)
      %edited             (on-edited +.rct)
    ==
    ::
    ++  on-sent
      |=  [path=space-path:store =ship =invite:vstore =member:membership-store]
      ^-  (quip card _state)
      =/  passes                      (~(gut by membership.state) path `members:membership-store`[~])
      =.  passes                      (~(put by passes) [ship [roles=(silt `(list role:membership-store)`~[role.invite]) alias='' status=%invited]])
      =.  membership.state            (~(put by membership.state) [path passes])
      :_  state
      [%give %fact [/updates ~] visa-reaction+!>([%invite-sent path ship invite member])]~
    ::
    ++  on-accepted
      |=  [path=space-path:store =ship =member:membership-store]
      ^-  (quip card _state)
      :: ?:  =(our.bowl ship)            ::  we've accepted an invite
      =/  passes                      (~(gut by membership.state) path `members:membership-store`[~])
      =.  passes                      (~(put by passes) [ship member])
      =.  membership.state            (~(put by membership.state) [path passes])
      :_  state
      [%give %fact [/updates ~] visa-reaction+!>([%invite-accepted path ship member])]~
    ::
    ++  on-kicked
      |=  [path=space-path:store =ship]
      ^-  (quip card _state)
      ?>  (has-auth:security path src.bowl %owner)  :: only pay attantion to kicked signals from the owner, since other ships could be lying/wrong
      ?:  =(our.bowl ship)            ::  we've been kicked
        =.  spaces.state              (~(del by spaces.state) path)
        =.  membership.state          (~(del by membership.state) path)
        =.  invitations.state         (~(del by invitations.state) path)
        =/  update-current  =(path current.state)
        =?  current.state  update-current
          [our.bowl 'our']
        =/  cards
          ^-  (list card)
          :~
            [%give %fact [/updates ~] spaces-reaction+!>([%remove path])]
            [%pass /spaces/(scot %p ship.path)/(space-name:encode:lib space.path) %agent [ship.path %spaces] %leave ~]
          ==
        =?  cards  update-current
          %+  welp  cards
          [%give %fact [/current ~] spaces-reaction+!>([%current current.state])]~
        [cards state]
      =/  membs                       (~(got by membership.state) path)
      =.  membs                       (~(del by membs) ship)
      =.  membership.state            (~(put by membership.state) [path membs])
      :_  state
      [%give %fact [/updates ~] visa-reaction+!>([%kicked path ship])]~
    ::
    ++  on-edited
      |=  [path=space-path:store =ship role-set=(set role:membership-store)]
      ^-  (quip card _state)
      =/  members  (~(got by membership.state) path)
      =/  member   (~(got by members) ship)
      =.  roles.member  role-set
      =.  members  (~(put by members) [ship member])
      =.  membership.state  (~(put by membership.state) [path members])
      :_  state
      [%give %fact [/updates ~] visa-reaction+!>([%edited path ship roles.member])]~
    --
  ::
  ++  helpers
    |%
    :: ++  set-outgoing
    ::   |=  [path=space-path:store =ship inv=invite:vstore]
    ::   =/  space-invites               (~(gut by outgoing.invitations.state) path `space-invitations:vstore`[~])
    ::   =.  space-invites               (~(put by space-invites) [ship inv])
    ::   (~(put by outgoing.invitations.state) [path space-invites])
    :: ::
    --
  --
::
::
++  security
  |%
  :: %initiate < %member < %admin < %owner, so passing in %initiate
  :: always returns true, if they are in the membership list
  ++  has-at-least-auth
    |=  [path=space-path:store =ship =role:membership-store]
    ^-  ?
    =/  member        (~(got by (~(got by membership.state) path)) ship)
    ?-  role
      %initiate       %.y
      %member
        ?|  (~(has in roles.member) %member)
            (~(has in roles.member) %admin)
            (~(has in roles.member) %owner)
        ==
      %admin
        ?|  (~(has in roles.member) %admin)
            (~(has in roles.member) %owner)
        ==
      %owner          (~(has in roles.member) role)
    ==
  ++  has-auth
    |=  [path=space-path:store =ship =role:membership-store]
    ^-  ?
    =/  member        (~(got by (~(got by membership.state) path)) ship)
    (~(has in roles.member) role)
  ::
  ++  check-member
    |=  [path=space-path:store =ship]
    ^-  ?
    =/  members   (~(get by membership.state) path)
    ?~  members
      %.n
    (~(has by (need members)) ship)
  ::
  --
::
++  is-host
  |=  [=ship]
  =(our.bowl ship)
::
++  notify
  |=  [pth=space-path:store slug=path msg=cord]
  ^-  action:hark
  :+  %add-note  `bin:hark`[/ [%realm /spaces/(scot %p ship.pth)]]
  :*  [ship/ship.pth text/msg ~]
      ~
      now.bowl
      /
      %-  weld
      :-  /spaces/(scot %p ship.pth)/(scot %tas space.pth)
      slug
  ==
--
