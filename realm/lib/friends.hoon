::  people [realm]:
::
::  People management lib within Realm. Mostly handles [de]serialization
::    to/from json from types stored in people sur.
::
::  Permissions management is centralized in the spaces agent. People
::   agent synch's permissions with spaces. People agent also
::   synch's contacts from contact-store.
::
::
/-  sur=friends
/+  res=resource
=<  [sur .]
=,  sur
|%
++  contact-to-friend
  |=  [ufriend=(unit friend:sur) =contact:sur]
  ^-  friend:sur
  =/  friend  ?~(ufriend *friend:sur u.ufriend)
  =/  contact-info
    :*  nickname.contact
        bio.contact
        color.contact
        avatar.contact
        cover.contact
        :: groups.contact
    ==
  friend(contact-info `contact-info)
::
++  rolodex-to-friends
  |=  [=friends:sur =rolodex:sur]
  ^-  friends:sur
  %-  ~(gas by friends)
  %+  turn  ~(tap by rolodex)
  |=  [=ship =contact:sur]
  ^-  [^ship friend:sur]
  =/  ufriend  (~(get by friends) ship)
  [ship (contact-to-friend ufriend contact)]
::
++  purge-contact-info
  |=  =old=friend:sur
  ^-  friend:sur
  =|  =new=friend:sur
  %=  new-friend
    pinned  pinned.old-friend
    tags    tags.old-friend
    status  status.old-friend
  ==
::
++  field-edit
  |=  [=friend:sur field=edit-field:sur]
  ^-  friend:sur
  =/  contact-info
    ?~  contact-info.friend  *contact-info:sur
    u.contact-info.friend
  =/  new-contact-info
    ?+  -.field      contact-info
      %nickname      contact-info(nickname nickname.field)
      %bio           contact-info(bio bio.field)
      %color         contact-info(color color.field)
      %avatar        contact-info(avatar avatar.field)
      :: %add-group     contact-info(groups (~(put in groups.contact-info) resource.field))
      :: %remove-group  contact-info(groups (~(del in groups.contact-info) resource.field))
      %cover         contact-info(cover cover.field)
    ==
  friend(contact-info `new-contact-info)
::
++  nu                                              ::  parse number as hex
  |=  jon=json
  ?>  ?=([%s *] jon)
  (rash p.jon hex)
::
++  enjs
  =,  enjs:format
  |%
  ++  reaction
    |=  rct=^reaction
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    ?-  -.rct
        %friends
      [%friends (frens:encode friends.rct)]
      ::
        %friend
      :-  %friend
      %-  pairs
      :~  [%ship s+(scot %p ship.rct)]
          [%friend (fren:encode friend.rct)]
      ==
      ::
        %new-friend
      :-  %new-friend
      %-  pairs
      :~  [%ship s+(scot %p ship.rct)]
          [%friend (fren:encode friend.rct)]
      ==
      ::
        %bye-friend
      :-  %bye-friend
      (pairs [%ship s+(scot %p ship.rct)]~)
    ==
  ::
  ++  action
    |=  act=^action
    ^-  json
    %+  frond  %visa-action
    %-  pairs
    :_  ~
    ^-  [cord json]
    ?-  -.act
    ::
        %add-friend
      :-  %add-friend
      %-  pairs
      :~  [%ship s+(scot %p ship.act)]
      ==
    ::
        %edit-friend
      :-  %edit-friend
      %-  pairs
      :~  [%ship s+(scot %p ship.act)]
          [%pinned [%b pinned.act]]
          [%tags [%a (turn ~(tap in tags.act) |=(tag=cord s+tag))]]
      ==
    ::
        %remove-friend
      :-  %remove-friend
      %-  pairs
      :~  [%ship s+(scot %p ship.act)]
      ==
    ::
    ::  Receiving
    ::
        %be-fren
      :-  %be-fren
      ~
    ::
        %yes-fren
      :-  %yes-fren
      ~
    ::
        %bye-fren
      :-  %bye-fren
      ~
        %set-contact
      :-  %set-contact
      ~
        %share-contact
      :-  %set-contact
      ~
        %set-sync
      :-  %set-sync
      ~
    ==
  ::
  ++  view :: encodes for on-peek
    |=  view=^view
    ^-  json
    ?-  -.view
        %friends
      %-  pairs
      :_  ~
      ^-  [cord json]
      [%friends (frens:encode friends.view)]
        %contact-info
      (enjs-contact-info:encode contact-info.view)
    ==
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%add-friend add-friend]
          [%edit-friend edit-friend]
          [%remove-friend remove-friend]
          [%be-fren ul]
          [%yes-fren ul]
          [%bye-fren ul]
          [%set-contact set-contact]
          [%set-sync bo]
      ==
    ::
    ++  json-to-ux
      =,  dejs:format
      |=  =json
      ^-  @ux
      (scan (trip (so json)) ;~(pfix (jest '0x') hex))
    ::
    ++  add-friend
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
      ==
    ::
    ++  edit-friend
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
          [%pinned bo]
          [%tags (as cord)]
      ==
    ::
    ++  remove-friend
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
      ==
    ::
    ++  set-contact
      %-  ot
      :~  [%ship (se %p)]
          [%contact-info json-to-contact-info]
      ==
    ::
    ++  json-to-contact-info
      |=  =json
      ^-  contact-info-edit
      %.  json
      :~  (ot ~[nickname+so:dejs-soft:format bio+so:dejs-soft:format color+(mu nu) avatar+so:dejs-soft:format cover+so:dejs-soft:format])
      ==
    ::
    --
  --
::
++  encode
  =,  enjs:format
  |%
  ++  frens
    |=  =friends
    ^-  json
    %-  pairs
    %+  turn  ~(tap by friends)
    |=  [=^ship =friend]
    ^-  [cord json]
    [(scot %p ship) (fren friend)]
  ::
  ++  fren
    |=  =friend
    ^-  json
    %-  pairs:enjs:format
    :~  ['pinned' b+pinned.friend]
        ['tags' [%a (turn ~(tap in tags.friend) |=(tag=cord s+tag))]]
        ['status' s+status.friend]
        :-  'contactInfo'
          ?~  contact-info.friend  ~
          %-  pairs
          ^-  (list [@t json])
          :~  ['nickname' s+nickname.u.contact-info.friend]
              ['bio' s+bio.u.contact-info.friend]
              ['color' s+(scot %ux color.u.contact-info.friend)]
              ['avatar' ?~(avatar.u.contact-info.friend ~ s+u.avatar.u.contact-info.friend)]
              ['cover' ?~(cover.u.contact-info.friend ~ s+u.cover.u.contact-info.friend)]
          ==
    ==
  ::
  ++  enjs-contact-info
    |=  =contact-info
    %-  pairs
    ^-  (list [@t json])
    :~  ['nickname' s+nickname.contact-info]
        ['bio' s+bio.contact-info]
        ['color' s+(scot %ux color.contact-info)]
        ['avatar' ?~(avatar.contact-info ~ s+u.avatar.contact-info)]
        ['cover' ?~(cover.contact-info ~ s+u.cover.contact-info)]
    ==
  ::
  --
--
