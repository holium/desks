/-  store=visas, spaces-store, member-store=membership
/+  spaces-lib=spaces
=<  [store .]
=,  store
|%
++  new-visa
  |=  [path=space-path:spaces-store inviter=ship =ship =role:membership =space:spaces-store message=@t invited-at=@da]
  ^-  invite:store
  =/  new-invite
    [
      inviter=inviter
      path=path
      role=role
      message=message
      name=name:space
      type=type:space
      picture=picture:space
      color=color:space
      invited-at=invited-at
    ]
  new-invite
::
::  json
::
++  enjs
  =,  enjs:format
  |%
  ++  action
    |=  act=^action
    ^-  json
    %+  frond  %invite-action
    %-  pairs
    :_  ~
    ^-  [cord json]
    ?-  -.act
        %send-invite
      :-  %send-invite
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
          [%ship s+(scot %p ship.act)]
          [%role s+(scot %tas role.act)]
          [%message s+message.act]
      ==
      ::
        %invited
      :-  %invited
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
          [%invite (invite:encode invite.act)]
      ==
      ::
        %accept-invite
      :-  %accept-invite
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
      ==
        %decline-invite
      :-  %accept-invite
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
      ==
      ::
        %stamped
      :-  %stamped
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
      ==
      ::
        %kick-member
      :-  %kick-member
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
          [%ship s+(scot %p ship.act)]
      ==
        %group-kick-member
      :-  %group-kick-member
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
          [%ship s+(scot %p ship.act)]
      ==
        %revoke-invite
      :-  %revoke-invite
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
      ==
        %edit-member-role
      :-  %edit-member-role
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.act)/(scot %tas space.path.act))]
          [%ship s+(scot %p ship.act)]
          :-  %roles
            :-  %a
            ^-  (list json)
            %+  turn  ~(tap in role-set.act)
            |=  =role:membership
            s+(scot %tas role)
      ==
    ==
  ::
  ++  reaction
    |=  rct=^reaction
    ^-  json
    %+  frond  %visa-reaction
    %-  pairs
    :_  ~
    ^-  [cord json]
    ?-  -.rct
        %invite-sent
      :-  %invite-sent
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%ship s+(scot %p ship.rct)]
          [%invite (invite:encode invite.rct)]
          [%member (memb:encode member.rct)]
      ==
      ::
       %invite-received
      :-  %invite-received
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%invite (invite:encode invite.rct)]
      ==
      ::
        %invite-removed
      :-  %invite-removed
      %-  pairs
      [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]~
      ::
        %invite-accepted
      :-  %invite-accepted
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%ship s+(scot %p ship.rct)]
          [%member (memb:encode member.rct)]
      ==
      ::
        %kicked
      :-  %kicked
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%ship s+(scot %p ship.rct)]
      ==
      ::
        %edited
      :-  %edited
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%ship s+(scot %p ship.rct)]
          :-  %roles
            :-  %a
            ^-  (list json)
            %+  turn  ~(tap in role-set.rct)
            |=  =role:membership
            s+(scot %tas role)
      ==
    ==
  ::
  ::
  ++  view
    |=  view=^view
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    ?-  -.view
        %invitations
      [%invitations (invitations:encode invites.view)]
      ::
      ::   %incoming
      :: [%invites (incoming-map:encode invites.view)]
      ::
    ==
  --
::
++  encode
  =,  enjs:format
  |%
  ++  invitations
    |=  =invitations:store
    ^-  json
    %-  pairs
    %+  turn  ~(tap by invitations)
    |=  [pth=space-path:spaces-store inv=invite:store]
    =/  spc-path  (spat /(scot %p ship.pth)/(scot %tas space.pth))
    ^-  [cord json]
    [spc-path (invite inv)]
  :: ++  outgoing-map
  ::   |=  outgoing=outgoing-invitations:store
  ::   ^-  json
  ::   %-  pairs
  ::   %+  turn  ~(tap by outgoing)
  ::   |=  [pth=space-path:spaces-store invitations=space-invitations:store]
  ::   =/  spc-path  (spat /(scot %p ship.pth)/(scot %tas space.pth))
  ::   ^-  [cord json]
  ::   [spc-path (invite-map invitations)]
  ::
  :: ++  incoming-map
  ::   |=  incoming=incoming-invitations:store
  ::   ^-  json
  ::   %-  pairs
  ::   %+  turn  ~(tap by incoming)
  ::   |=  [pth=space-path:spaces-store inv=invite:store]
  ::   =/  spc-path  (spat /(scot %p ship.pth)/(scot %tas space.pth))
  ::   ^-  [cord json]
  ::   [spc-path (invite inv)]
  ::
  :: ++  invite-map
  ::   |=  =space-invitations:store
  ::   ^-  json
  ::   %-  pairs
  ::   %+  turn  ~(tap by space-invitations)
  ::   |=  [=^ship inv=invite:store]
  ::   ^-  [cord json]
  ::   [(scot %p ship) (invite inv)]
  ::
  ++  invite
    |=  =invite:store
    ^-  json
    %-  pairs:enjs:format
    :~  ['inviter' s+(scot %p inviter.invite)]
        ['path' s+(spat /(scot %p ship.path.invite)/(scot %tas space.path.invite))]
        ['role' s+(scot %tas role.invite)]
        ['message' s+message.invite]
        ['name' s+name.invite]
        ['type' s+type.invite]
        ['picture' s+picture.invite]
        ['color' s+color.invite]
        ['invitedAt' (time invited-at.invite)]
    ==
  ::
  ++  memb
    |=  =member:member-store
    ^-  json
    %-  pairs:enjs:format
    :~  ['roles' a+(turn ~(tap in roles.member) |=(rol=role:member-store s+(scot %tas rol)))]
        ['alias' s+alias.member]
        ['status' s+(scot %tas status.member)]
    ==
  ::
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    |=  jon=json
    ^-  action:store
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%send-invite send-invite-payload]
          [%accept-invite accept-invite-payload]
          [%decline-invite accept-invite-payload]
          [%invited invited-payload]
          [%stamped path-payload]
          [%kick-member kicked-payload]
          [%revoke-invite path-payload]
          [%edit-member-role edit-member-role-payload]
      ==
    ::
    ++  kicked-payload
      %-  ot
      :~  [%path pth]
          [%ship (su ;~(pfix sig fed:ag))]
      ==
    ::
    ::
    ++  path-payload
      %-  ot
      :~  [%path pth]
      ==
    ::
    ++  accept-invite-payload
      %-  ot
      :~  [%path pth]
      ==
    ::
    ++  invited-payload
      %-  ot
      :~  [%path pth]
          [%invite invite]
      ==
    ::
    ++  invite
      %-  ot
      :~  [%inviter (su ;~(pfix sig fed:ag))]
          [%path pth]
          [%role rol]
          [%message so]
          [%name so]
          [%type space-type:action:dejs:spaces-lib]
          [%picture so]
          [%color so]
          [%invited-at di]
      ==
    ::
    ++  send-invite-payload
      %-  ot
      :~  [%path pth]
          [%ship (su ;~(pfix sig fed:ag))]
          [%role rol]
          [%message so]
      ==
    ::
    ++  pth
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
          [%space so]
      ==
    ::
    ++  rol
      |=  =json
      ^-  role:member-store
      ?>  ?=(%s -.json)
      ?:  =('initiate' p.json)   %initiate
      ?:  =('member' p.json)     %member
      ?:  =('admin' p.json)      %admin
      ?:  =('owner' p.json)      %owner
      !!
    ::
    ++  status
      |=  =json
      ^-  status:member-store
      ?>  ?=(%s -.json)
      ?:  =('invited' p.json)     %invited
      ?:  =('joined' p.json)      %joined
      ?:  =('host' p.json)        %host
      !!
    ::
    ++  edit-member-role-payload
      %-  ot
      :~  [%path pth]
          [%ship (su ;~(pfix sig fed:ag))]
          :: expects an array of roles
          [%roles (as rol)]
      ==
    --
  --
  ::
--
