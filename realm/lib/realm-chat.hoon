::  realm-chat [realm]:
::
::  Chat message lib within Realm. Mostly handles [de]serialization
::    to/from json from types stored in realm-chat sur.
::
/-  *realm-chat, db=chat-db, bedrock=db, common
/+  chat-db, db-scry=bedrock-scries, passport, crypto-helper
|%
::
:: helpers
::
++  maybe-log
  |=  [hide-debug=? msg=tape]
  ?:  =(%.y hide-debug)  ~
  ~&  >>>  msg
  ~
::
++  scry-avatar-for-patp
  |=  [patp=ship =bowl:gall]
  ^-  (unit @t)
  =/  uc=(unit contact:common)
  (contact-info:db-scry patp bowl)
  ?~  uc  ~
  ?~  avatar.u.uc  ~
  %-  some
  ?-  -.u.avatar.u.uc
    %image  img.u.avatar.u.uc
    %nft    nft.u.avatar.u.uc
  ==
::
++  scry-message
  |=  [=msg-id:db =bowl:gall]
  ^-  message:db
  .^
    message:db
    %gx
    /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/message/(scot %da timestamp.msg-id)/(scot %p sender.msg-id)/noun
  ==
::
++  scry-messages-for-path
  |=  [=path our=@p now=@da]
  ^-  (list [k=uniq-id:db v=msg-part:db])
  =/  paths  (weld /(scot %p our)/chat-db/(scot %da now)/db/messages-for-path path)
  =/  tbls
    .^
      db-dump:db
      %gx
      (weld paths /noun)
    ==
  =/  tbl  `table:db`(snag 0 tables.tbls)
  ?+  -.tbl  !!
    %messages
      (tap:msgon:db messages-table.tbl)
  ==
::
++  scry-message-count-for-path
  |=  [=path =bowl:gall]
  ^-  @ud
  =/  paths  (weld /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/message-count-for-path path)
  .^
    @ud
    %gx
    (weld paths /noun)
  ==
::
++  scry-path-row
  |=  [=path =bowl:gall]
  ^-  path-row:db
  =/  paths  (weld /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/path path)
  =/  tbls
    .^
      db-dump:db
      %gx
      (weld paths /noun)
    ==
  =/  tbl  `table:db`(snag 0 tables.tbls)
  ?+  -.tbl  !!
    %paths  (snag 0 ~(val by paths-table.tbl))
  ==
::
++  scry-peers
  |=  [=path =bowl:gall]
  ^-  (list peer-row:db)
  =/  paths  (weld /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/peers-for-path path)
  =/  tbls
    .^
      db-dump:db
      %gx
      (weld paths /noun)
    ==
  =/  tbl  `table:db`(snag 0 tables.tbls)
  ?+  -.tbl  !!
    %peers  (snag 0 ~(val by peers-table.tbl))
  ==
::
++  scry-paths
  |=  =bowl:gall
  ^-  (list path-row:db)
  =/  tbls
    .^
      db-dump:db
      %gx
      /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/db/paths/noun
    ==
  =/  tbl  `table:db`(snag 0 tables.tbls)
  ?+  -.tbl  !!
    %paths  ~(val by paths-table.tbl)
  ==
::
++  notif-from-nickname-or-patp
  |=  [patp=ship =bowl:gall]
  ^-  @t
  =/  uc=(unit contact:common)
  (contact-info:db-scry patp bowl)
  =/  nickname=@t
  ?~  uc  ''
  ?~  display-name.u.uc  ''
  u.display-name.u.uc
  ?:  =('' nickname)
    (scot %p patp)
  nickname
::
++  group-name-or-blank
  |=  [=path-row:db]
  ^-  @t
  =/  title       (~(get by metadata.path-row) 'title')
  ?:  =(type.path-row %dm)   '' :: always blank for DMs
  ?~  title     'Group Chat'    :: if it's a group chat without a title, just say "group chat"
  (need title)                  :: otherwise, return the title of the group
::
++  into-backlog-msg-poke
  |=  [m=message:db =ship]
  [%pass /dbpoke %agent [ship %chat-db] %poke %chat-db-action !>([%insert-backlog m])]
::
++  into-insert-message-poke
  |=  [p=peer-row:db act=[=path fragments=(list minimal-fragment:db) expires-in=@dr] ts=@da]
  =/  exp-at=@da  ?:  =(expires-in.act *@dr)
    *@da
  (add ts expires-in.act)
  [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%insert ts path.act fragments.act exp-at])]
::
++  into-edit-message-poke
  |=  [p=peer-row:db act=edit-message-action:db]
  [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%edit act])]
::
++  into-delete-backlog-poke
  |=  [p=peer-row:db =path now=time]
  [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%delete-backlog path now])]
::
++  into-delete-message-poke
  |=  [p=peer-row:db =msg-id:db]
  [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%delete msg-id])]
::
++  into-all-peers-kick-pokes
  |=  [kickee=ship peers=(list peer-row:db)]
  ^-  (list card)
  %+  turn
    peers
  |=(p=peer-row:db (into-kick-peer-poke patp.p kickee path.p))
::
++  into-kick-peer-poke
  |=  [target=ship kickee=ship =path]
  ^-  card
  [%pass /dbpoke %agent [target %chat-db] %poke %chat-db-action !>([%kick-peer path kickee])]
::
++  create-path-db-poke
  |=  [=ship row=path-row:db peers=ship-roles:db]
  ^-  card
  [%pass /dbpoke %agent [ship %chat-db] %poke %chat-db-action !>([%create-path row peers 0 ~ %.n])]
::
++  create-path-bedrock-poke
  |=  [=ship row=path-row:db peers=ship-roles:db]
  ^-  card
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%create-path path.row %host ~ ~ ~ peers])]
::
++  create-chat-bedrock-poke
  |=  [=ship row=path-row:db peers=ship-roles:db nft=(unit [contract=@t chain=@t standard=@t])]
  ^-  card
  =/  chat=chat:common  [
    metadata.row
    type.row
    (silt (turn ~(tap in pins.row) swap-id-parts))
    invites.row
    peers-get-backlog.row
    max-expires-at-duration.row
    nft
  ]
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%create [ship *@da] path.row chat-type:common [%chat chat] ~])]
::
++  edit-chat-bedrock-poke
  |=  [host=ship act=[=path metadata=(map cord cord) peers-get-backlog=? invites=@tas max-expires-at-duration=@dr] =bowl:gall]
  ^-  card
  =/  bedrock-chat=(unit row:bedrock)  (scry-first-bedrock-chat:db-scry path.act bowl)
  ?~  bedrock-chat  *card
  ?+  -.data.u.bedrock-chat  !!
      %chat
    =/  chat  [
      metadata.act
      type.data.u.bedrock-chat
      pins.data.u.bedrock-chat
      invites.act
      peers-get-backlog.act
      max-expires-at-duration.act
    ]
    [
      %pass
      /dbpoke
      %agent
      [host %bedrock]
      %poke
      %db-action
      !>([%edit [~zod *@da] id.u.bedrock-chat path.act chat-type:common [%chat chat] ~])
    ]
  ==
::
++  create-bedrock-message-poke
  |=  [=ship act=[=path fragments=(list minimal-fragment:db) expires-in=@dr] ts=@da chat-id=[=ship t=@da]]
  =/  exp-at=@da  ?:  =(expires-in.act *@dr)
    *@da
  (add ts expires-in.act)
  =/  first=minimal-fragment:db  (snag 0 fragments.act)
  =/  msg  [
    chat-id
    ?~(reply-to.first ~ (some [-.u.reply-to.first [sender.q.u.reply-to.first timestamp.q.u.reply-to.first]]))
    exp-at
    (turn fragments.act |=(f=minimal-fragment:db [content.f metadata.f]))
  ]
  [%pass /dbpoke %agent [ship %bedrock] %poke %db-action !>([%create [ship ts] path.act message-type:common [%message msg] ~])]
::
++  edit-bedrock-message-poke
  |=  [host=ship act=edit-message-action:db =bowl:gall]
  =/  first  (snag 0 fragments.act)
  =/  current-bedrock-msg  (scry-bedrock-message:db-scry (swap-id-parts msg-id.act) path.act bowl)
  ?+  -.data.current-bedrock-msg  !!
      %message
    =/  msg  [
      chat-id.data.current-bedrock-msg
      ?~(reply-to.first ~ (some [-.u.reply-to.first [sender.q.u.reply-to.first timestamp.q.u.reply-to.first]]))
      expires-at.data.current-bedrock-msg
      (turn fragments.act |=(f=minimal-fragment:db [content.f metadata.f]))
    ]
    [
      %pass
      /dbpoke
      %agent
      [host %bedrock]
      %poke
      %db-action
      !>([%edit [~zod *@da] (swap-id-parts msg-id.act) path.act message-type:common [%message msg] ~])
    ]
  ==
::
++  delete-bedrock-message-poke
  |=  [host=ship act=[=path =msg-id:db] =bowl:gall]
  [
    %pass
    /dbpoke
    %agent
    [host %bedrock]
    %poke
    %db-action
    !>([%remove message-type:common path.act (swap-id-parts msg-id.act)])
  ]
::
++  add-bedrock-peer-poke
  |=  [host=ship =path newship=ship sig=nft-sig]
  ^-  card
  [%pass /dbpoke %agent [host %bedrock] %poke %db-action !>([%add-peer path newship %member sig])]
::
++  remove-before-bedrock-poke
  |=  [host=ship =path t=@da]
  ^-  card
  [%pass /dbpoke %agent [host %bedrock] %poke %db-action !>([%remove-before message-type:common path t])]
::
++  swap-id-parts
  |=  =msg-id:db
  ^-  [=ship t=@da]
  [sender.msg-id timestamp.msg-id]
::
++  push-notification-card
  |=  [=bowl:gall state=state-1 =path-row:db title=@t subtitle=@t content=@t unread=@ud avatar=(unit @t) =message:db]
  ^-  card
  =/  note=push-notif
    [
      app-id=app-id.state
      data=[path-row unread avatar message]
      title=(malt ~[['en' title]])
      subtitle=?:(=(subtitle '') ~ (malt ~[['en' subtitle]]))
      contents=(malt ~[['en' content]])
    ]
  ::  send http request
  ::
  =/  =header-list:http    ['Content-Type' 'application/json']~
  =|  =request:http
  :: TODO include the unread count in the push notif (perhaps global?)
  =:  method.request       %'POST'
      url.request          'https://onesignal.com/api/v1/notifications'
      header-list.request  header-list
      body.request
        :-  ~
        %-  as-octt:mimes:html
        %-  trip
        %-  en:json:html
        %+  notify-request:encode
          note
        devices.state
  ==

  [%pass /push-notification/(scot %da now.bowl) %arvo %i %request request *outbound-config:iris]
::
++  dm-already-exists
  |=  [typ=@tas peers=(list ship) =bowl:gall]
  ^-  ?
  ?.  =(typ %dm)  %.n  :: if the goal `typ` is not %dm, there is no way for a conflicting dm to already exist
  =/  dmpaths  (turn (skim (scry-paths bowl) |=(pr=path-row:db =(type.pr %dm))) |=(pr=path-row:db path.pr))
  =/  index=@ud  0
  =/  conflict=?   %.n
  =/  setpeers     (silt peers)
  |-
    ?:  |(conflict =(index (lent dmpaths)))
      conflict
    =/  dmpeers  (scry-peers (snag index dmpaths) bowl)
    =/  dmships  (turn dmpeers |=(p=peer-row:db patp.p))
    ?.  =((lent dmships) 2)  $(index +(index))
    =/  firstmatches=?   (~(has in setpeers) (snag 0 dmships))
    =/  secondmatches=?  (~(has in setpeers) (snag 1 dmships))
    $(index +(index), conflict &(firstmatches secondmatches))
::
::
::  poke actions
::
++  create-chat
::realm-chat &chat-action [%create-chat ~ %dm ~[~bus] %host *@dr %.y ~]
::realm-chat &chat-action [%create-chat ~ %group ~[~bus ~dev] %host *@dr %.y (some ['0x000386E3F7559d9B6a2F5c46B4aD1A9587D59Dc3' 'eth-mainnet' 'ERC721'])]
  |=  [act=create-chat-data state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  (vented-create-chat [now.bowl act] state bowl)
::
++  vented-create-chat
  |=  [act=[t=@da c=create-chat-data] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  chat-path  /realm-chat/(scot %uv (sham [our.bowl t.act]))
  =/  pathrow=path-row:db
  [
    chat-path
    metadata.c.act
    type.c.act
    t.act
    t.act
    ~
    invites.c.act
    peers-get-backlog.c.act
    max-expires-at-duration.c.act
    now.bowl
    nft.c.act
  ]
  =/  all-ships
    ?:  (~(has in (silt peers.c.act)) our.bowl)  peers.c.act
    [our.bowl peers.c.act]
  ?:  (dm-already-exists type.c.act all-ships bowl)
    =/  log1  (maybe-log hide-debug.state "dm between {<all-ships>} already exists")
    `state
  =/  all-peers=ship-roles:db
    %+  turn
      all-ships
    |=  s=ship
    =/  rl
      ?:  =(s our.bowl)    %host
      ?:  =(type.c.act %dm)  %host
      %member
    [s rl]

  =/  cards=(list card)
    %+  snoc
      %+  snoc
        %+  turn
          all-peers
        |=  [s=ship role=@tas]
        (create-path-db-poke s pathrow all-peers)
      (create-path-bedrock-poke our.bowl pathrow all-peers)
    (create-chat-bedrock-poke our.bowl pathrow all-peers nft.c.act)
  =/  send-status-message
    ?:  =(2 (lent all-ships)) :: if it's just two ships (and therefore a "dm")
      !>([%send-message chat-path ~[[[%status (crip "{(scow %p our.bowl)} created the chat")] ~ ~]] *@dr])
    !>([%send-message chat-path ~[[[%status (crip "{(scow %p our.bowl)} added {(scow %ud (dec (lent all-ships)))} peers")] ~ ~]] *@dr])
  =.  cards  (snoc cards [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action send-status-message])
  =.  cards
    ?.  =(invites.pathrow %open)  cards
    =/  common-chat=chat:common
    [
      metadata.pathrow
      type.pathrow
      ~
      invites.pathrow
      peers-get-backlog.pathrow
      max-expires-at-duration.pathrow
      nft.pathrow
    ]
    :_  cards
    [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%update-chat our.bowl chat-path common-chat (lent all-peers)])]
  =.  cards
    ?.  =(type.c.act %dm)  cards
    =/  other-ship=@p  (snag 0 (skip all-ships |=(p=@p =(p our.bowl))))
    =/  pass=passport:common   (our-passport:db-scry bowl)
    =/  pass-time=@da  updated-at:(our-passport-row:db-scry bowl)
    :-  [%pass /contacts %agent [other-ship %passport] %poke %passport-action !>([%receive-contacts [[pass-time contact.pass] ~]])]
    :-  [%pass /contacts %agent [other-ship %passport] %poke %passport-action !>([%get-contact [our.bowl now.bowl]])]
    cards
  [cards state]
::
++  edit-chat
::realm-chat &chat-action [%edit-chat /realm-chat/path-id ~ %.y %host *@dr]
  |=  [act=[=path metadata=(map cord cord) peers-get-backlog=? invites=@tas max-expires-at-duration=@dr] state=state-1 =bowl:gall]
  ^-  (quip card state-1)

  =/  pathpeers   (scry-peers path.act bowl)
  =/  src-peer    (snag 0 (skim pathpeers |=(p=peer-row:db =(patp.p src.bowl))))  :: intentionally will crash if the source of this request is not a peer
  =/  host-peer   (snag 0 (skim pathpeers |=(p=peer-row:db =(role.p %host))))
  =/  ogpath      (scry-path-row path.act bowl)

  =/  cards=(list card)
    ?:  &(=(type.ogpath %dm) ?!(=(patp.host-peer our.bowl)))
      :: non-hosts are allowed to edit %dm type chats, but can only do
      :: so by relaying the request through the host-peer, since chat-db
      :: enforces the rule that only hosts can actually edit the path-row
      [%pass /selfpoke %agent [patp.host-peer %realm-chat] %poke %chat-action !>([%edit-chat act])]~

    :::-  (edit-chat-bedrock-poke (scry-bedrock-path-host:db-scry path.act bowl) act bowl)
    :: we poke all peers/members' db with edit-path (including ourselves)
    %:  turn
      pathpeers
      |=(p=peer-row:db [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%edit-path act])])
    ==
  =.  cards
    ?.  =(invites.act %open)  cards
    =/  common-chat=chat:common
    [
      metadata.act
      type.ogpath
      (silt (turn ~(tap in pins.ogpath) swap-id-parts))
      invites.act
      peers-get-backlog.act
      max-expires-at-duration.act
      nft.ogpath
    ]
    :_  cards
    [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%update-chat our.bowl path.ogpath common-chat (lent pathpeers)])]
  [cards state]
::
++  pin-message
::  :realm-chat &action [%pin-message /realm-chat/path-id [*@da ~zod] %.y]
  |=  [act=[=path =msg-id:db pin=?] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)

  =/  pathrow=path-row:db  (scry-path-row path.act bowl)
  =.  pins.pathrow
    ?:  pin.act
      (~(put in pins.pathrow) msg-id.act)
    (~(del in pins.pathrow) msg-id.act)

  =/  pathpeers  (scry-peers path.act bowl)
  =/  cards
    :: we poke all peers/members' db with edit-path-pins (including ourselves)
    %:  turn
      pathpeers
      |=(p=peer-row:db [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%edit-path-pins path.act pins.pathrow])])
    ==
  [cards state]
::
++  clear-pinned-messages
::  :realm-chat &action [%clear-pinned-messages /realm-chat/path-id]
  |=  [=path state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)

  =/  pathpeers  (scry-peers path bowl)
  =/  cards
    :: we poke all peers/members' db with edit-path-pins (including ourselves)
    %:  turn
      pathpeers
      |=(p=peer-row:db [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%edit-path-pins path *pins:db])])
    ==
  [cards state]
::
++  add-ship-to-chat
::realm-chat &chat-action [%add-ship-to-chat now /realm-chat/path-id ~bus ~ ~ %.y]
  |=  [act=[t=@da =path =ship host=(unit ship) =nft-sig join-silently=?] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  =/  log1  (maybe-log hide-debug.state "{<dap.bowl>}%add-ship-to-chat: {<path.act>} {<ship.act>} {<host.act>}")
  ?:  &(=(src.bowl our.bowl) =(our.bowl ship.act))  :: if we are trying to add ourselves, then actually we just need to forward this poke to the host
    ?~  host.act  !!  :: have to pass the host if we are adding ourselves
    =.  nft-sig.act
      ?~  nft-sig.act  ~
      =/  p  (our-passport:db-scry bowl)
      =/  matching-addr
      %+  snag  0
      %+  skim  addresses.p
      |=  a=[@t addr=@t pk=@t *]
      =(addr.a addr.u.nft-sig.act)
      ?<  =(pubkey.matching-addr '')
      ?:  =('account' wallet.matching-addr)
        =/  pc=passport-crypto:common
        (passport-root:dejs:passport (need (de:json:html data.crypto-signature.matching-addr)))
        %-  some
        :*  signature-of-hash.crypto-signature.matching-addr
            address.matching-addr
            hash.crypto-signature.matching-addr
            0
            0
        ==
      =/  link=passport-data-link:common
      (passport-data-link:dejs:passport (need (de:json:html data.crypto-signature.matching-addr)))
      ?+  -.data.link  !!
        %signed-key-add
      %-  some
      :*  key-signature.data.link
          address.matching-addr
          name.data.link
          nonce.data.link
          timestamp.data.link
      ==
      ==
    :_  state
    [%pass /dbpoke %agent [(need host.act) dap.bowl] %poke %chat-action !>([%add-ship-to-chat t.act path.act ship.act host.act nft-sig.act join-silently.act])]~

  =/  pathrow  (scry-path-row path.act bowl)
  ?>  ?|  =(src.bowl our.bowl)
          &(?!(=(src.bowl our.bowl)) =(invites.pathrow %open))
      ==
  ?>  ?~  nft.pathrow  %.y
      :: we need to verify
      :: 1. that they own the addr they passed in (with the signature verification)
      :: 2. that `addr` owns the nft (which we do via calling outside api)
      ?~  nft-sig.act  %.n
      =/  msg=@t
      ?:  &(=(0 nonce.u.nft-sig.act) =(0 t.u.nft-sig.act))
        :: passport root address owns the nft, uses different signing message
        name.u.nft-sig.act
      %:  signed-key-add-msg:crypto-helper
        name.u.nft-sig.act
        addr.u.nft-sig.act
        nonce.u.nft-sig.act
        t.u.nft-sig.act
      ==
      ~&  >>>  msg
      (verify-message:crypto-helper msg sig.u.nft-sig.act addr.u.nft-sig.act)
  ?:  ?~(nft.pathrow %.n %.y)
    :_  state
    (check-alchemy:crypto-helper path.act ship.act t.act chain:(need nft.pathrow) (need nft-sig.act))

  (finish-add-ship-to-chat act state bowl)
::
++  finish-add-ship-to-chat
  |=  [act=[t=@da =path =ship host=(unit ship) =nft-sig join-silently=?] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  =/  pathrow  (scry-path-row path.act bowl)
  =/  pathpeers  (scry-peers path.act bowl)
  =/  all-peers=ship-roles:db
    %+  snoc
      (turn pathpeers |=(p=peer-row:db [patp.p role.p]))
    [ship.act %member]

  =/  expected-msg-count=@ud
    ?.  peers-get-backlog.pathrow  0
    (scry-message-count-for-path path.act bowl)
  ~&  >  "expected: {<expected-msg-count>}"
  =/  backlog-poke-cards=(list card)
    ?.  peers-get-backlog.pathrow  ~
    ?.  (gth expected-msg-count 200)
      (limo [(into-backlog-msg-poke (turn (scry-messages-for-path path.act our.bowl now.bowl) |=([k=uniq-id:db v=msg-part:db] v)) ship.act) ~])
    =/  msgs  (scag 200 (scry-messages-for-path path.act our.bowl now.bowl))
    =/  tid   (cat 3 (spat path.act) ship.act)
    =/  start-args  [~ `tid byk.bowl(r da+now.bowl) %send-backlog !>(`[path.act ship.act])]
    :-  (into-backlog-msg-poke (turn msgs |=([k=uniq-id:db v=msg-part:db] v)) ship.act)
    :-  [%pass /thread/(scot %da now.bowl) %agent [our.bowl %spider] %poke %spider-start !>(start-args)]
    ~

  :: order matters here, for performance
  =/  cards=(list card)
::    :-  (add-bedrock-peer-poke (scry-bedrock-path-host:db-scry path.act bowl) path.act ship.act nft.act)
    %+  weld
      ::  we poke the newly-added ship's db with a create-path,
      ::  since that will automatically handle them joining as a member
      :-  [%pass /dbpoke %agent [ship.act %chat-db] %poke %chat-db-action !>([%create-path pathrow all-peers expected-msg-count `t.act join-silently.act])]
      :: we poke all original peers db with add-peer (including ourselves)
      %+  turn
        pathpeers
      |=(p=peer-row:db [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%add-peer t.act path.act ship.act nft-sig.act])])
    :: then we send the backlog
    backlog-poke-cards
  =.  cards
    :: only send to explore service if %open
    ?.  =(invites.pathrow %open)  cards
    =/  common-chat=chat:common
    [
      metadata.pathrow
      type.pathrow
      (silt (turn ~(tap in pins.pathrow) swap-id-parts))
      invites.pathrow
      peers-get-backlog.pathrow
      max-expires-at-duration.pathrow
      nft.pathrow
    ]
    :_  cards
    [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%update-chat our.bowl path.pathrow common-chat (lent all-peers)])]
  [cards state]
++  edit-ship-role
::realm-chat &chat-action [%edit-ship-role now /realm-chat/path-id ~bus %admin]
  |=  [act=[t=@da =path =ship role=@tas] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  log1
  (maybe-log hide-debug.state "{<dap.bowl>}%edit-ship-role: {<path.act>} {<ship.act>} {<role.act>}")

  =/  cards=(list card)
  %+  turn
    (scry-peers path.act bowl)
  |=  p=peer-row:db
  ^-  card
  [%pass /dbpoke %agent [patp.p %chat-db] %poke %chat-db-action !>([%edit-peer act])]

  [cards state]
::
::  allows self to remove self, or %host to kick others
++  remove-ship-from-chat
::realm-chat &chat-action [%remove-ship-from-chat /realm-chat/path-id ~bus]
  |=  [act=[=path =ship] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  log1  (maybe-log hide-debug.state "{<dap.bowl>}%remove-ship-from-chat: {<path.act>} {<ship.act>}")

  =/  pathrow  (scry-path-row path.act bowl)
  =/  pathpeers  (scry-peers path.act bowl)
  =/  members  (skim pathpeers |=(p=peer-row:db ?!(=(role.p %host)))) :: everyone who's NOT the host
  =/  host  (snag 0 (skim pathpeers |=(p=peer-row:db =(role.p %host))))
  =.  pins.state  :: if we are removing ourself, we are deleting the path, so we should unpin the chat
    ?:  =(ship.act patp.host)
      (~(del in pins.state) path.act)
    pins.state
  =/  pr=path-row:db  (scry-path-row path.act bowl)
  =/  cards=(list card)
    ?:  =(type.pr %dm)
      (into-all-peers-kick-pokes ship.act pathpeers)
    ?:  =(ship.act patp.host)
      :: if src.bowl is %host, we have to leave-path for the host
      :: and then send kick-peer of themselves to all members
      :-  [%pass /dbpoke %agent [patp.host %chat-db] %poke %chat-db-action !>([%leave-path path.act])]
      :-  [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%remove-chat path.pathrow])]
      %+  turn
        members
      |=(p=peer-row:db (into-kick-peer-poke patp.p patp.p path.p))
    :: otherwise we just send kick-peer to all the peers (db will ensure permissions)
    (into-all-peers-kick-pokes ship.act pathpeers)

  =.  cards
    :: only send to explore service if %open
    ?.  =(invites.pathrow %open)  cards
    ?:  =(ship.act patp.host)
      :_  cards
      [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%remove-chat path.pathrow])]
    =/  common-chat=chat:common
    [
      metadata.pathrow
      type.pathrow
      (silt (turn ~(tap in pins.pathrow) swap-id-parts))
      invites.pathrow
      peers-get-backlog.pathrow
      max-expires-at-duration.pathrow
      nft.pathrow
    ]
    :_  cards
    [%pass /dbpoke %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%update-chat our.bowl path.pathrow common-chat (dec (lent pathpeers))])]
  [cards state]
::
++  send-message
::realm-chat &chat-action [%send-message /realm-chat/path-id ~[[[%plain '0'] ~ ~] [[%plain '1'] ~ ~]] *@dr]
  |=  [act=[=path fragments=(list minimal-fragment:db) expires-in=@dr] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  (vented-send-message [now.bowl act] state bowl)
::
++  vented-send-message
  |=  [act=[t=@da =path fragments=(list minimal-fragment:db) expires-in=@dr] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  ?>  (gth (lent fragments.act) 0)  :: no sending empty messages

  :: read the peers for the path
  =/  pathpeers  (scry-peers path.act bowl)
  =/  official-time  t.act
  =/  chat-db-pokes=(list card)
    %+  turn
      pathpeers
    |=(a=peer-row:db (into-insert-message-poke a +.act official-time))
  =/  cards=(list card)  chat-db-pokes
::    ?.  (test-bedrock-path-existence:db-scry path.act bowl)
::      chat-db-pokes
::    ?.  (test-bedrock-table-existence:db-scry chat-type:common bowl)
::      chat-db-pokes
::    =/  bedrock-chat=(unit row:bedrock)  (scry-first-bedrock-chat:db-scry path.act bowl)
::    ?~  bedrock-chat  chat-db-pokes
::    :-  (create-bedrock-message-poke (scry-bedrock-path-host:db-scry path.act bowl) +.act official-time id.u.bedrock-chat)
::    chat-db-pokes
  :: then send pokes to all the peers about inserting a message
  [cards state]
::
++  edit-message
::  :realm-chat &action [%edit-message [~2023.2.22..16.46.28..e019 ~zod] /realm-chat/path-id (limo [[[%plain 'edited'] ~ ~] ~])]
  |=  [act=edit-message-action:db state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)

  :: just pass along the edit-message-action to all the peers chat-db
  :: %chat-db will disallow invalid signals
  =/  pathpeers  (scry-peers path.act bowl)
  =/  chat-db-pokes=(list card)
    %+  turn
      pathpeers
    |=(p=peer-row:db (into-edit-message-poke p act))
  =/  cards=(list card)  chat-db-pokes
::    ?.  (test-bedrock-path-existence:db-scry path.act bowl)
::      chat-db-pokes
::    :-  (edit-bedrock-message-poke (scry-bedrock-path-host:db-scry path.act bowl) act bowl)
::    chat-db-pokes
  [cards state]
::
++  delete-message
::  :realm-chat &chat-action [%delete-message /realm-chat/path-id ~2023.2.3..16.23.37..72f6 ~zod]
  |=  [act=[=path =msg-id:db] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)

  :: just pass along the delete msg-id to all the peers chat-db
  :: %chat-db will disallow invalid signals
  =/  pathpeers  (scry-peers path.act bowl)
  =/  chat-db-pokes=(list card)
    %+  turn
      pathpeers
    |=(p=peer-row:db (into-delete-message-poke p msg-id.act))
  =/  cards=(list card)  chat-db-pokes
::    ?.  (test-bedrock-path-existence:db-scry path.act bowl)
::      chat-db-pokes
::    :-  (delete-bedrock-message-poke (scry-bedrock-path-host:db-scry path.act bowl) act bowl)
::    chat-db-pokes
  [cards state]
::
++  delete-backlog
::  :realm-chat &chat-action [%delete-backlog /realm-chat/path-id]
  |=  [act=[=path] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  :: just pass along the delete-backlog to all the peers chat-db
  :: %chat-db will disallow invalid signals
  =/  pathpeers  (scry-peers path.act bowl)
  =/  cards=(list card)
    :-  (remove-before-bedrock-poke (scry-bedrock-path-host:db-scry path.act bowl) path.act now.bowl)
    %:  turn
      pathpeers
      |=(p=peer-row:db (into-delete-backlog-poke p path.act now.bowl))
    ==
  =/  cleared-status-message
    !>([%send-message path.act ~[[[%status (crip "{(scow %p our.bowl)} cleared the chat history")] ~ ~]] *@dr])
  =.  cards  (snoc cards [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action cleared-status-message])
  [cards state]
::
++  room-action
::  :realm-chat &chat-action [%room-action /realm-chat/path-id %start]
  |=  [act=[=path kind=?(%start %leave %join)] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  log1  (maybe-log hide-debug.state "{<dap.bowl>}%room-action: {<path.act>} {<kind.act>}")
  =/  our-name      (notif-from-nickname-or-patp our.bowl bowl)
  =/  verb=@t
  ?-  kind.act
    %start    ' started '
    %leave    ' left '
    %join     ' joined '
  ==
  =/  contents=@t  (crip [our-name verb 'a call with you' ~])
  (send-message [path.act (limo [[[%status contents] ~ ~] ~]) *@dr] state bowl)
::
++  disable-push
  |=  [state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  push-enabled.state  %.n
  `state
::
++  enable-push
  |=  [state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  push-enabled.state  %.y
  `state
::
++  clear-devices
::realm-chat &chat-action [%clear-devices ~]
  |=  [state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  `state(devices *devices)
::
++  remove-device
  |=  [device-id=cord state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  devices.state         (~(del by devices.state) device-id)
  `state
::
++  set-device
::realm-chat &chat-action [%set-device 'device' 'player']
  |=  [[device-id=cord player-id=cord] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  devices.state         (~(put by devices.state) device-id player-id)
  `state
::
++  mute-chat
  |=  [[chat-path=path mute=?] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  new-mutes
    ?:  mute
      (~(put in mutes.state) chat-path)
    (~(del in mutes.state) chat-path)
  =.  mutes.state   new-mutes
  `state
::
++  pin-chat
  |=  [[chat-path=path pin=?] state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =/  new-pins
    ?:  pin
      (~(put in pins.state) chat-path)
    (~(del in pins.state) chat-path)
  =.  pins.state   new-pins
  `state
::
++  toggle-msg-preview-notif
::realm-chat &chat-action [%toggle-msg-preview-notif %.y]
  |=  [toggle=? state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  msg-preview-notif.state  toggle
  `state
::
++  toggle-hide-debug
::realm-chat &chat-action [%toggle-hide-debug %.y]
  |=  [toggle=? state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  ?>  =(src.bowl our.bowl)
  =.  hide-debug.state  toggle
  `state
::
++  create-notes-to-self-if-not-exists
  |=  [state=state-1 =bowl:gall]
  ^-  (quip card state-1)
  =/  selfpaths=(list path-row:db)  (skim (scry-paths bowl) |=(p=path-row:db =(type.p %self)))
  ?.  =(0 (lent selfpaths))
    `state
  (create-chat [(notes-to-self bowl) %self ~ %host *@dr %.n ~] state bowl)
::
++  notes-to-self  |=(=bowl:gall (malt ~[['title' 'Notes to Self'] ['reactions' 'true'] ['creator' (scot %p our.bowl)] ['description' '']]))
::
::
::  JSON
::
++  encode
  =,  enjs:format
  |%
    ++  paths
      |=  path-set=pins
      ^-  json
      a+(turn `(list ^path)`~(tap in path-set) enpath)
    ::
    ++  enpath
      |=  p=^path
      ^-  json
      s+(spat p)
    ::
    ++  settings
      |=  s=[push-enabled=? msg-preview-notif=?]
      ^-  json
      %-  pairs
      :~  push-enabled+b+push-enabled.s
          msg-preview-notif+b+msg-preview-notif.s
      ==
    ::
    ++  notify-request :: encodes for iris outbound
      |=  [notif=push-notif =devices]
      ^-  json
      =/  player-ids  ~(val by devices)
      =/  base-list
      :~
          ['app_id' s+app-id.notif]
          ['data' (mtd data.notif)]
          ['include_player_ids' a+(turn player-ids |=([id=@t] s+id))]
          ['headings' (contents title.notif)]
          ['ios_badgeType' s+'SetTo']
          ['ios_badgeCount' (numb unread.data.notif)]
      ==
      =/  extended-list
        ?~  subtitle.notif  base-list
        :-  ['subtitle' (contents subtitle.notif)]
        base-list

      ?~  contents.notif
        (pairs extended-list)
      %-  pairs
      :-
        ['contents' (contents contents.notif)]
        extended-list
    ::
    ++  mtd
      |=  mtd=push-mtd
      ^-  json
      %-  pairs
      :~
        ['path-row' (path-row:encode:chat-db path-row.mtd)]
        ['avatar' ?~(avatar.mtd ~ s+u.avatar.mtd)]
        ['msg' a+(turn message.mtd |=(m=msg-part:db (messages-row:encode:chat-db [msg-id.m msg-part-id.m] m)))]
      ==
    ::
    ++  contents
      |=  contents=(map cord cord)
      ^-  json
      =/  message   (~(got by contents) 'en')
      %-  pairs
      ['en' s+message]~
    ::
    ++  en-devices
      |=  =devices
      ^-  json
      %-  pairs
      :~
        :-  %devices
        %-  pairs
        %+  turn  ~(tap by devices)
        |=  [device-id=@t player-id=@t]
        ^-  [cord json]
        [device-id s+player-id]
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
      :~  [%create-chat create-chat]
          [%edit-chat edit-chat]
          [%pin-message pin-message]
          [%clear-pinned-messages (ot ~[[%path pa]])]
          [%add-ship-to-chat path-and-ship-and-unit-host]
          [%edit-ship-role edit-ship-role]
          [%remove-ship-from-chat path-and-ship]
          [%send-message path-and-fragments]
          [%edit-message de-edit-info]
          [%delete-message path-and-msg-id]
          [%delete-backlog (ot ~[[%path pa]])]
          [%room-action (ot ~[[%path pa] [%kind de-kind]])]

          [%enable-push ul]
          [%disable-push ul]
          [%set-device set-device]
          [%remove-device remove-device]
          [%mute-chat mute-chat]
          [%pin-chat pin-chat]
          [%toggle-msg-preview-notif bo]
      ==
    ::
    ++  create-chat
      |=  jon=json
      ^-  create-chat-data
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  unft    (~(get by p.jon) 'nft')
      =/  nft=(unit [contract=@t chain=@t standard=@t])
        ?~  unft  ~
        (some ((ot ~[contract+so chain+so standard+so]) u.unft))
      =/  ubackl    (~(get by p.jon) 'peers-get-backlog')
      [
        ((om so) (gt 'metadata'))
        ((se %tas) (gt 'type'))
        ((ar de-ship) (gt 'peers'))
        ((se %tas) (gt 'invites'))
        (null-or-dri (gt 'max-expires-at-duration')):: specify in integer milliseconds, or null for "not set"
        ?~(ubackl %.n (null-or-bool u.ubackl))
        nft
      ]
    ::
    ++  edit-ship-role
      |=  jon=json
      ^-  [t=@da =path =ship role=@tas]
      ~&  >>>  "asdF"
      =/  tmp
      %-  ot
      :~  [%path pa]
          [%ship de-ship]
          [%role (se %tas)]
      ==
      :: TODO parse the timestamp if we care to let json users specify it
      [*@da (tmp jon)]
    ::
    ++  edit-chat
      %-  ot
      :~  [%path pa]
          [%metadata (om so)]
          [%peers-get-backlog bo]
          [%invites (se %tas)]
          [%max-expires-at-duration null-or-dri]  :: specify in integer milliseconds, or null for "not set"
      ==
    ::
    ++  de-ship  (su ;~(pfix sig fed:ag))
    ::
    ++  set-device
      %-  ot
      :~  [%device-id so]
          [%player-id so]
      ==
    ::
    ++  remove-device
      %-  ot
      :~  [%device-id so]
      ==
    ::
    ++  mute-chat
      %-  ot
      :~  [%path pa]
          [%mute bo]
      ==
    ::
    ++  pin-chat
      %-  ot
      :~  [%path pa]
          [%pin bo]
      ==
    ::
    ++  path-and-ship-and-unit-host
      |=  jon=json
      ^-  [@da path ship (unit ship) nft-sig ?]
      ?>  ?=([%o *] jon)
      =/  ut    (~(get by p.jon) 't')
      =/  uhost    (~(get by p.jon) 'host')
      =/  host=(unit ship)
        ?~  uhost  ~
        (some (de-ship (need uhost)))
      =/  unft    (~(get by p.jon) 'nft-owner')
      =/  nft=nft-sig
        ?~  unft  ~
        %-  some
        ['' (so u.unft) '' 0 0] :: we fill in these values with the matching info from the passport
      [
        ?~(ut *@da (di u.ut))
        (pa (~(got by p.jon) 'path'))
        (de-ship (~(got by p.jon) 'ship'))
        host
        nft
        %.n
      ]
    ::
    ++  path-and-ship
      %-  ot
      :~
          [%path pa]
          [%ship de-ship]
      ==
    ::
    ++  de-edit-info
      %-  ot
      :~
          [%msg-id de-msg-id]
          [%path pa]
          de-frag
      ==
    ::
    ++  de-msg-id
      %+  cu
        path-to-msg-id
      pa
    ::
    ++  path-to-msg-id
      |=  p=path
      ^-  msg-id:db
      [`@da`(slav %da +2:p) `@p`(slav %p +6:p)]
    ::
    ++  de-frag
      [%fragments (ar (ot ~[content+de-content reply-to+(mu path-and-msg-id) metadata+(om so)]))]
    ::
    ++  path-and-fragments
      %-  ot
      :~
          [%path pa]
          de-frag
          [%expires-in null-or-dri]
      ==
    ::
    ++  de-content
      %-  of
      :~
          [%plain so]
          [%markdown so]
          [%bold so]
          [%italics so]
          [%strike so]
          [%bold-italics so]
          [%bold-strike so]
          [%italics-strike so]
          [%bold-italics-strike so]
          [%blockquote so]
          [%inline-code so]
          [%code so]
          [%image so]
          [%ur-link so]
          [%react so]
          [%break ul]
          [%ship de-ship]
          [%link so]
          [%custom (ot ~[[%name so] [%value so]])]
          [%status so]
      ==
    ::
    ++  path-and-msg-id
      %-  ot
      :~
          [%path pa]
          [%msg-id de-msg-id]
      ==
    ::
    ++  pin-message
      %-  ot
      :~
          [%path pa]
          [%msg-id de-msg-id]
          [%pin bo]
      ==
    ::
    ++  de-kind
      |=  jon=json
      ^-  ?(%start %join %leave)
      ?+  jon  !!
        [%s *]
          =/  tas=@tas  `@tas`p.jon
          ?+  tas  !!
            %start  %start
            %join   %join
            %leave  %leave
          ==
        ~       %start
      ==
    ::
    ++  dri   :: specify in integer milliseconds, returns a @dr
      (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) ni)
    ::
    ++  null-or-dri   :: specify in integer milliseconds, returns a @dr
      (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) null-or-ni)
    ::
    ++  null-or-bool  :: accepts either a null or a b+%.y, and converts nulls to false
      |=  jon=json
      ^-  ?
      ?+  jon  !!
        [%b *]  p.jon
        ~       %.n
      ==
    ::
    ++  null-or-ni  :: accepts either a null or a n+'123', and converts nulls to 0, non-null to the appropriate number
      |=  jon=json
      ^-  @ud
      ?+  jon  !!
        [%n *]  (rash p.jon dem)
        ~       0
      ==
    --
  --
--
