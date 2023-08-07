/-  sur=membership, spcs=spaces-store, frens-sur=friends
=<  [sur .]
=,  sur
|%
::  TODO add decode
++  enjs
  =,  enjs:format
  |%
  ++  view :: encodes for on-peek
      |=  view=^view
      ^-  json
      %-  pairs
      :_  ~
      ^-  [cord json]
      ?-  -.view
        ::
          %membership
        [%membership (membership-json:encode membership.view)]
        ::
          %members
        [%members (members-json:encode members.view)]
        ::
          %member
        [%member (member-json:encode member.view)]
        ::
          %is-member
        [%is-member b+is-member.view]
        
      ==
    --
++  encode
  =,  enjs:format
  |%
  
  ::
  ++  membership-json
    |=  =membership
    ^-  json
    %-  pairs
    %+  turn  ~(tap by membership)
    |=  [pth=space-path:spcs =members]
    =/  spc-path  (spat /(scot %p ship.pth)/(scot %tas space.pth))  
    ^-  [cord json]
    [spc-path (members-json members)]
  ::
  ++  members-json
    |=  =members
    ^-  json
    %-  pairs
    %+  turn  ~(tap by members)
    |=  [=^ship =member]
    ^-  [cord json]
    [(scot %p ship) (member-json member)]
  ::
  ++  member-json
    |=  =member
    ^-  json
    %-  pairs
    :~
      ['roles' (rols roles.member)]
      ['alias' s+alias.member]
      ['status' s+(scot %tas status.member)]
    ==
  ::
  ++  rols
    |=  =roles
    ^-  json
    [%a (turn ~(tap in roles) |=(rol=role s+(scot %tas rol)))]
  ::
  ++  is-mem
    |=  is=?
    ^-  json
    %-  pairs
    :~
      ['is-member' b+is]
    ==
  ::
  --
--