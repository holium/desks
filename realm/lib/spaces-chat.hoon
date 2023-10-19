/-  sstore=spaces-store, mstore=membership, visas, chat-db
/-  store=spaces-chat
/+  memb-lib=membership, rc-lib=realm-chat
=<  [store .]
=,  store
|%
++  init-spaces
  |=  [state=state-0:store =bowl:gall]
  ^-  (quip card:agent:gall state-0)
  ?.  =(0 (lent ~(key by chats.state)))  `state
  ~&  "{<dap.bowl>}: initializing..."
  =/  spaces-scry       .^(view:sstore %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/all/noun)
  ?>  ?=(%spaces -.spaces-scry)
  =/  spaces            spaces.spaces-scry
  =/  to-add-chat=(list [k=space-path:sstore v=space:sstore])
      %+  skim  ~(tap by spaces)
        |=  kv=[k=space-path:sstore v=space:sstore]
        &(=(ship.path.v.kv our.bowl) ?!(=(space.k.kv 'our')))
  =/  new-chats
    %+  turn  to-add-chat
      |=  [sk=space-path:sstore sv=space:sstore]
      =/  members-scry      .^(view:mstore %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/(scot %p ship.sk)/(scot %tas space.sk)/members/noun)
      ?>  ?=(%members -.members-scry)
      =/  members           members.members-scry
      =/  chat-and-cards    (create-space-chat sv [%role %member] members now.bowl our.bowl)
      =/  chat              +.chat-and-cards
      =/  cards
        %+  weld
          -.chat-and-cards
        (create-channel-pokes sk chat members)
      [k=sk c=chat cd=cards]
  =/  cards
    %+  roll  new-chats
      |=  [[k=space-path:sstore c=chat:store cd=(list card:agent:gall)] acc=(list card:agent:gall)]
      (weld acc cd)
  =/  chats
    %+  turn  new-chats
    |=  [k=space-path:sstore c=chat:store cd=(list card:agent:gall)]
    =/  chats-map       `chats:store`~
    =/  chats-map       (~(put by chats-map) path.c c)
    [k chats-map]
  =.  chats.state   `space-chats:store`(malt chats)
  [cards state]
::
++  pathify-space-path
  |=  =space-path:sstore
  ^-  path
  /(scot %p ship.space-path)/(wood space.space-path)
:: TODO make this smart enough to actually do different logic based on
:: the value of `chat-access`, instead of just always doing the logic
:: for [%role %member]
++  create-space-chat
  |=  [=space:sstore =chat-access:store =members:mstore t=@da our=ship]
  ^-  (quip card:agent:gall chat:store)
  ~&  %create-space-chat
  ::  spaces chats path format: /spaces/<space-path>/chats/<@uv>
  =/  chat-path  (weld /spaces (weld (pathify-space-path path.space) /chats/(scot %uv (sham path.space))))
  =/  metadata-settings
    :~  ['image' '']
        ['title' 'General']
        ['description' '']
        ['creator' (scot %p ship.path.space)]
        ['reactions' 'true']
        ['space' (spat (pathify-space-path path.space))]
    ==
  =/  metadata=(map cord cord)   (~(gas by *(map cord cord)) metadata-settings)
  ::  TODO when making new channels make sure we can disable chat history for new members or enable it
  =/  pathrow=path-row:chat-db  [chat-path metadata %space t t ~ %host %.y *@dr *@da ~]
  =/  all-peers=ship-roles:chat-db
      %+  turn  (skim-init-members members)
      |=  kv=[k=ship v=member:mstore]
      [k.kv ?:(=(status.v.kv %host) %host %member)]
    :: TODO logic for peers lists for %admins %invited %whitelist and %blacklist
  =/  new-chat      [chat-path chat-access]
  =/  cards=(list card:agent:gall)  ::  poke %chat-db to create the chat
    :-  (create-path-bedrock-poke:rc-lib our pathrow all-peers)
    :-  (create-chat-bedrock-poke:rc-lib our pathrow all-peers ~)
    %+  turn  all-peers
    |=  [s=ship role=@tas]
    (create-path-db-poke:rc-lib s pathrow all-peers)
  [cards new-chat]

:: matching members are status %joined or %host AND have
:: either %member or %admin or %owner roles
++  skim-init-members
  |=  =members:mstore
  ^-  (list [ship member:mstore])
  %+  skim  ~(tap by members)
    |=  kv=[k=ship v=member:mstore]
    ?&  |(=(status.v.kv %joined) =(status.v.kv %host))
        ?|  (~(has in roles.v.kv) %member)
            (~(has in roles.v.kv) %admin)
            (~(has in roles.v.kv) %owner)
        ==
    ==
  
++  skim-joined-members
  |=  =members:mstore
  ^-  (list [ship member:mstore])
  %+  skim  ~(tap by members)
    |=  kv=[k=ship v=member:mstore]
    ?&  =(status.v.kv %joined)
        ?|  (~(has in roles.v.kv) %member)
            (~(has in roles.v.kv) %admin)
            (~(has in roles.v.kv) %owner)
        ==
    ==

++  create-channel-pokes
  |=  [=space-path:sstore =chat:store =members:mstore]
  ^-  (list card:agent:gall)
  %+  turn  (skim-joined-members members)
    |=  [s=ship v=member:mstore]
    ^-  card:agent:gall
    [%pass / %agent [s %spaces-chat] %poke %spaces-chat-action !>([%create-channel space-path chat])]

::  creates the necessary cards for poking %chat-db to add the new ship
::  to all the relevant chats it should be added to
++  add-ship-to-matching-chats
  |=  [=ship =member:mstore =space-path:store =chats:store =bowl:gall]
  ^-  (list card:agent:gall)
  %-  zing
  %+  turn
    ~(tap by chats)
  |=  kv=[k=path v=chat:store]
  ^-  (list card:agent:gall)
  ?+  -.access.v.kv  ~ :: TODO handle other modes of chat access
    %role
      ?.  &((~(has in roles.member) role.access.v.kv) |(=(%joined status.member) =(%host status.member)))  ~
      =/  pathpeers   (scry-peers:rc-lib k.kv bowl)
      =/  matches     (skim pathpeers |=(p=peer-row:chat-db =(patp.p ship)))
      ?:  (gth (lent matches) 0)  ~  :: this ship is already in this chat, so no need to add them
      :~
        [%pass /rcpoke %agent [our.bowl %realm-chat] %poke %chat-action !>([%add-ship-to-chat *@da k.kv ship ~ ~])]
        [%pass / %agent [ship %spaces-chat] %poke %spaces-chat-action !>([%create-channel space-path v.kv])]
      ==
  ==

:: ::  creates the necessary cards for poking %chat-db to remove the new ship
:: ::  to all chats within the space
++  remove-ship-from-space-chats
  |=  [=ship =chats:store =bowl:gall]
  ^-  (list card:agent:gall)
  %-  zing
  %+  turn
    ~(tap by chats)
  |=  kv=[k=path v=chat:store]
  ^-  (list card:agent:gall)
  [%pass /rcpoke %agent [our.bowl %realm-chat] %poke %chat-action !>([%remove-ship-from-chat k.kv ship])]~

--
