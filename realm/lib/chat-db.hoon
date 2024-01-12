::  chat-db [realm]:
::
::  Chat message lib within Realm. Mostly handles [de]serialization
::    to/from json from types stored in courier sur.
::
/-  *versioned-state, sur=chat-db, common, db
/+  db-scry=bedrock-scries, crypto-helper
|%
::
::  random helpers
::
++  is-valid-editor :: %host or %admin
  |=  [editor=@p peers=(list peer-row:sur)]
  ^-  ?
  =/  admins=(list ship)
  %+  turn
    (skim peers |=(p=peer-row:sur |(=(role.p %host) =(role.p %admin))))
  |=  p=peer-row:sur
  ^-  ship
  patp.p

  %+  lien
    admins
  |=  s=@p
  =(s editor)
::
++  is-valid-inviter
  |=  [=path-row:sur peers=(list peer-row:sur) src=ship patp=ship]
  ^-  ?
  ?:  &(=(invites.path-row %open) =(src patp))   %.y :: if the invites are set to open, you can invite yourself, otherwise, normal rules apply

  :: add-peer pokes are only valid from:
  :: a ship within the peers list
  =/  src-peer  (snag 0 (skim peers |=(p=peer-row:sur =(patp.p src)))) :: will crash if src not in list
  :: AND
  :: any peer-ship if set to %anyone or %open
  :: OR a ship whose role matches the path-row `invites` setting
  :: OR whose role is the %host
  ?|  =(invites.path-row %anyone)
      =(invites.path-row %open)
      =(role.src-peer invites.path-row)
      =(role.src-peer %host)
  ==
::
++  fill-out-minimal-fragment
  |=  [frag=minimal-fragment:sur =path =msg-id:sur index=@ud updated-at=@da expires-at=@da now=@da]
  ^-  msg-part:sur
  [path msg-id index content.frag reply-to.frag metadata.frag timestamp.msg-id updated-at expires-at now]
::
++  get-full-message
  |=  [tbl=messages-table:sur =msg-id:sur]
  ^-  message:sur
  =/  index  0
  =/  result=message:sur  *message:sur
  |-
  ?.  (has:msgon:sur tbl [msg-id index])
    result
  $(index +(index), result (snoc result (got:msgon:sur tbl [msg-id index])))
::
++  make-msg-from-minimal-frags
  |=  [msg-act=insert-message-action:sur id=msg-id:sur updated-at=@da now=@da]
  ^-  message:sur
  =/  result        *message:sur
  =/  counter=@ud   0
  |-
  ?:  =(counter (lent fragments.msg-act)) :: stop condition
    result
  $(result (snoc result (fill-out-minimal-fragment (snag counter fragments.msg-act) path.msg-act id counter updated-at expires-at.msg-act now)), counter +(counter))
::
++  add-message-to-table
  |=  [tbl=messages-table:sur msg-act=insert-message-action:sur sender=@p updated-at=@da now=@da]
  =/  msg=message:sur     (make-msg-from-minimal-frags msg-act [timestamp.msg-act sender] updated-at now)
  =/  key-vals            (turn msg |=(a=msg-part:sur [[msg-id.a msg-part-id.a] a]))
  [(gas:msgon:sur tbl key-vals) msg]
::
++  keys-from-kvs  |=(kvs=msg-kvs:sur (turn kvs |=(kv=[k=uniq-id:sur v=msg-part:sur] k.kv)))
::
++  swap-id-parts
  |=  =msg-id:sur
  ^-  [=ship t=@da]
  [sender.msg-id timestamp.msg-id]
::
++  rm-msg-parts
  |=  [ids=(list uniq-id:sur) tbl=messages-table:sur]
  ^-  messages-table:sur
  |-
  ?:  =(0 (lent ids))
    tbl
  $(tbl +:(del:msgon:sur tbl (snag 0 ids)), ids +:ids)
::
++  remove-ids-from-pins
  |=  [ids=(list msg-id:sur) state=state-5 now=@da]
  ^-  state-and-changes
  =/  tbl  paths-table.state
  =/  changes=db-change:sur  *db-change:sur
  =/  result
    |-
    ?:  =(0 (lent ids))
      [tbl changes]
    =/  current  (snag 0 ids)
    =/  msg=msg-part:sur  (got:msgon:sur messages-table.state [current 0])
    =/  pathrow=path-row:sur  (~(got by tbl) path.msg)
    =/  oldrow=path-row:sur   (~(got by tbl) path.msg)
    =/  pinned                (~(has in pins.pathrow) current)
    =.  pins.pathrow          ?:(pinned (~(del in pins.pathrow) current) pins.pathrow)
    =.  updated-at.pathrow    ?:(pinned now updated-at.pathrow)
    $(tbl (~(put by tbl) path.msg pathrow), ids +:ids, changes ?:(pinned [[%upd-paths-row pathrow oldrow] changes] changes))
  =.  paths-table.state  -:result
  [state +:result]
::
:: helper that is smart enough to remove the pins first,
:: then add the del-log,
:: and then remove the actual messages
++  remove-messages
  |=  [messages=msg-kvs:sur state=state-5 now=@da]
  ^-  state-and-changes
  =/  keys=(list uniq-id:sur)  (keys-from-kvs messages)

  :: remove them from pins in their respective paths
  =/  s-ch      (remove-ids-from-pins (turn messages |=(kv=[k=uniq-id:sur v=msg-part:sur] msg-id.v.kv)) state now)
  =.  state     s.s-ch
  =/  changes   ch.s-ch

  :: log the deletes
  =/  logged                (log-deletes-for-msg-parts state keys now)
  =.  del-log.state         -.logged
  =.  changes               (weld `db-change:sur`changes `db-change:sur`+:logged)

  :: remove the actual messages
  =.  messages-table.state  (rm-msg-parts keys messages-table.state)

  [state changes]
::
:: given a msg-id, remove all the `msg-part`s associated with it
++  remove-message
  |=  [state=state-5 =msg-id:sur now=@da]
  ^-  state-and-changes

  =/  part-counter=@ud  0
  =/  kvs  *msg-kvs:sur
  =.  kvs
    |-
    ?:  (has:msgon:sur messages-table.state `uniq-id:sur`[msg-id part-counter])
      $(part-counter +(part-counter), kvs [[[msg-id part-counter] (got:msgon:sur messages-table.state [msg-id part-counter])] kvs])
    kvs

  (remove-messages kvs state now)
::
:: remove all `msg-part`s associated with a given path
++  remove-messages-for-path
  |=  [state=state-5 =path now=@da]
  ^-  state-and-changes
  %^  remove-messages
      (skim (tap:msgon:sur messages-table.state) |=(kv=[k=uniq-id:sur v=msg-part:sur] =(path.v.kv path)))
    state
  now
::
++  remove-messages-for-path-before
  |=  [state=state-5 =path before=time now=@da]
  ^-  state-and-changes

  =/  start=uniq-id:sur  [[before ~zod] 0]
  =/  badkvs=msg-kvs:sur
    %+  skim
      (tap:msgon:sur (lot:msgon:sur messages-table.state `start ~))
    |=(kv=[k=uniq-id:sur v=msg-part:sur] =(path.v.kv path))

  (remove-messages badkvs state now)
::
++  expire-old-msgs
  |=  [state=state-5 now=@da]
  ^-  state-and-changes
  =/  old-msgs=msg-kvs:sur
    %+  skim
      :: TODO efficiency by lot:msgon:sur from the last del-log time
      :: since we know we checked then ?
      (tap:msgon:sur messages-table.state)
    |=([k=uniq-id:sur v=msg-part:sur] &(?!(=(*@da expires-at.v)) (gth now expires-at.v)))

  (remove-messages old-msgs state now)
::
++  log-deletes-for-msg-parts
  |=  [state=state-5 ids=(list uniq-id:sur) now=@da]
  ^-  [del-log:sur (list db-del-type:sur)]
  =/  change-rows=(list db-del-type:sur)
    %+  turn
      ids
    |=  a=uniq-id:sur
    =/  pat  path:(got:msgon:sur messages-table.state a)
    [%del-messages-row pat a now]
  =/  index=@ud     0
  =/  len=@ud       (lent change-rows)
  =/  new-log       del-log.state
  |-
  ?:  =(index len)
    [new-log change-rows]
                                                    :: adding index to now in order to ensure unique keys
  $(index +(index), new-log (put:delon:sur new-log `@da`(add now index) (snag index change-rows)))
::
++  messages-start-paths
  |=  [=bowl:gall]
  ^-  (list path)
  =/  len-three  (skim ~(val by sup.bowl) |=(a=[p=ship q=path] (gte (lent q.a) 3)))
  =/  matching  (skim len-three |=(a=[p=ship q=path] =([-:q.a +<:q.a +>-:q.a ~] /db/messages/start)))
  (turn matching |=(a=[p=ship q=path] q.a))
::
++  delete-logs-for-path :: used for clearing del-log when the path itself is deleted, to keep things clean
  |=  [state=state-5 =path]
  ^-  del-log:sur
  =/  removables
    %+  skim :: get all the [k v] pairs of logs we can remove
      (tap:delon:sur del-log.state)
    |=  [k=time v=db-change-type:sur]
    ?+  -.v  %.n :: only possibly remove messages and peers row since we don't want to remove the log that we removed the whole path
      %del-messages-row   =(path path.v)
      %del-peers-row      =(path path.v)
    ==
  =/  index=@ud     0
  =/  len=@ud       (lent removables)
  =/  new-log       del-log.state
  |-
  ?:  =(index len)
    new-log
  $(index +(index), new-log +:(del:delon:sur new-log -:(snag index removables)))
::
::  poke actions
::
:: MUST EXPLICITLY INCLUDE SELF, this function will not add self into peers list
++  create-path
::chat-db &chat-db-action [%create-path [/example ~ %group *@da *@da ~ %host %.y *@dr *@da (some ['0x000386E3F7559d9B6a2F5c46B4aD1A9587D59Dc3' 'eth-mainnet' 'ERC721'])] ~[[~zod %host] [~bus %member]] 100 ~ %.n]
  |=  [[row=path-row:sur peers=ship-roles:sur expected-msg-count=@ud t=(unit @da) join-silently=?] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  ?>  ?!((~(has by paths-table.state) path.row))  :: ensure the path doesn't already exist!!!
  =.  received-at.row     now.bowl
  =.  paths-table.state   (~(put by paths-table.state) path.row row)

  =/  thepeers=(list peer-row:sur)
    %+  turn
      peers
    |=([s=@p role=@tas] [path.row s role now.bowl now.bowl now.bowl])

  =.  peers-table.state  (~(put by peers-table.state) path.row thepeers)
  =/  thechange  chat-db-change+!>((limo [[%add-row %paths row join-silently] (turn thepeers |=(p=peer-row:sur [%add-row %peers p]))]))
  =/  vent-path=path
    ?~  t  /chat-vent/(scot %da created-at.row)
    /chat-vent/(scot %da u.t)
  =/  gives  :~
    [%give %fact [/db (weld /db/path path.row) ~] thechange]
    :: give vent response
    [%give %fact ~[vent-path] chat-vent+!>([%path-and-count row expected-msg-count])]
    [%give %kick ~[vent-path] ~]
  ==
  [gives state]
::
++  edit-path
::  :chat-db &db-action [%edit-path /a/path/to/a/chat ~ %.n %host *@dr]
  |=  [[=path metadata=(map cord cord) peers-get-backlog=? invites=@tas max-expires-at-duration=@dr] state=state-5 =bowl:gall]
  ^-  (quip card state-5)

  =/  original-peers-list   (~(got by peers-table.state) path)
  :: assert that this edit comes from the %host or an %admin
  ?>  (is-valid-editor src.bowl original-peers-list)

  =/  row=path-row:sur        (~(got by paths-table.state) path)
  =/  oldrow=path-row:sur     (~(got by paths-table.state) path)
  =.  updated-at.row          now.bowl
  =.  received-at.row         now.bowl
  =.  metadata.row            metadata
  =.  peers-get-backlog.row   peers-get-backlog
  =.  invites.row             invites
  =.  max-expires-at-duration.row   max-expires-at-duration

  =.  paths-table.state  (~(put by paths-table.state) path row)

  =/  thechange  chat-db-change+!>(~[[%upd-paths-row row oldrow]])
  =/  gives  :~
    [%give %fact [/db (weld /db/path path) ~] thechange]
  ==
  [gives state]
::
++  edit-path-pins
::  :chat-db &db-action [%edit-path-pins /a/path/to/a/chat ~]
  |=  [[=path =pins:sur] state=state-5 =bowl:gall]
  ^-  (quip card state-5)

  =/  original-peers-list   (~(got by peers-table.state) path)
  :: edit-path-pins pokes are only valid from the ship which is
  :: the %host of the path
  =/  host-peer-row         (snag 0 (skim original-peers-list |=(p=peer-row:sur =(role.p %host))))
  ?>  =(patp.host-peer-row src.bowl)

  =/  row=path-row:sur   (~(got by paths-table.state) path)
  =/  oldrow=path-row:sur     (~(got by paths-table.state) path)
  =.  pins.row           pins
  =.  received-at.row    now.bowl
  =.  updated-at.row     now.bowl
  =.  paths-table.state  (~(put by paths-table.state) path row)

  =/  thechange  chat-db-change+!>(~[[%upd-paths-row row oldrow]])
  =/  gives  :~
    [%give %fact [/db (weld /db/path path) ~] thechange]
  ==
  [gives state]
::
++  leave-path
::  :chat-db &db-action [%leave-path /a/path/to/a/chat]
  |=  [=path state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?>  =(our.bowl src.bowl)  :: leave pokes are only valid from ourselves. if others want to kick us, that is a different matter
  ~&  "%leaving-path {<path>}"
  =.  messages-table.state  messages-table:s:(remove-messages-for-path state path now.bowl)
  =.  paths-table.state  (~(del by paths-table.state) path)
  =.  peers-table.state  (~(del by peers-table.state) path)
  :: for now we are assuming that subscribed clients are intelligent
  :: enough to realize that a %del-paths-row also means remove the
  :: related messages and peers
  =/  change-row      [%del-paths-row path now.bowl]
  =.  del-log.state   (delete-logs-for-path state path)
  =.  del-log.state   (put:delon:sur del-log.state now.bowl change-row)
  =/  thechange       chat-db-change+!>(~[change-row])
  =/  gives  :~
    [%give %fact [/db (weld /db/path path) ~] thechange]
  ==
  [gives state]
::
++  insert
:: :chat-db &db-action [%insert ~2023.2.2..23.11.10..234a /a/path/to/a/chat (limo [[[%plain '0'] ~ ~] [[%plain '1'] ~ ~] [[%plain '1'] ~ ~] [[%plain '3'] ~ ~] ~]) ~2000.1.1]
  |=  [msg-act=insert-message-action:sur state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  =/  thepeers   (silt (turn (~(got by peers-table.state) path.msg-act) |=(a=peer-row:sur patp.a)))
  ?>  (~(has in thepeers) src.bowl)  :: messages can only be inserted by ships which are in the peers-list
  
  :: logic to force-set expires-at on messages when the path has a
  :: max-expires-at-duration specified
  =/  thepath   (~(got by paths-table.state) path.msg-act)
  =/  max-exp   (add max-expires-at-duration.thepath now.bowl)
  =.  expires-at.msg-act
    ?:  =(max-expires-at-duration.thepath *@dr)  expires-at.msg-act  :: allow any expires-at if the max-expires-at-duration is "null"
    ?:  =(expires-at.msg-act *@da)  max-exp               :: otherwise, if the expires-at is "unset" set it to the max expiration
    ?:  (lth expires-at.msg-act now.bowl)  max-exp        :: otherwise, if the expires-at is in the past, set to max-expiration
    ?:  (lte expires-at.msg-act max-exp)  expires-at.msg-act :: otherwise, ensure the expires-at is less than the max-expiration
    max-exp  :: else, set it to the max-expiration based on the max-expires-at-duration defined in thepath

  =/  add-result  (add-message-to-table messages-table.state msg-act src.bowl timestamp.msg-act now.bowl)
  =.  messages-table.state  -.add-result
  =/  thechange  chat-db-change+!>((turn +.add-result |=(a=msg-part:sur [%add-row [%messages a]])))
  :: message-paths is all the sup.bowl paths that start with
  :: /db/messages/start since every new message will need to go out to
  :: those subscriptions
  =/  message-paths  (messages-start-paths bowl)
  =/  vent-path=path  /chat-vent/(scot %da timestamp.msg-act)
  =/  gives  :~
    [%give %fact (weld message-paths (limo [/db (weld /db/path path.msg-act) ~])) thechange]
    :: give vent response
    [%give %fact ~[vent-path] chat-vent+!>([%msg +.add-result])]
    [%give %kick ~[vent-path] ~]
  ==
  [gives state]
::
++  insert-backlog
:: :chat-db &db-action [%insert-backlog list-of-msg-parts]
  |=  [=message:sur state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  ?:  =(0 (lent message))  `state  :: if the list is empty, don't do anything
  =/  index=@ud   0
  =/  changes=db-change:sur  *db-change:sur
  =/  changes-and-state=[db-change:sur state-5]
    |-
      ?:  =(index (lent message))
        [changes state]
      =/  msg=msg-part:sur  (snag index message)
      ::
      :: backlog-pokes are only allowed if all the following are true:
      ::
      :: we already have that path in our table, and the associated peers
      =/  pathrow   (~(got by paths-table.state) path.msg)
      =/  peers     (~(got by peers-table.state) path.msg)
      :: the created-at of our peer-row for the path is gth
      :: created-at.msg (because the message was from *before* we
      :: joined the chat)
      =/  us-peer   (snag 0 (skim peers |=(p=peer-row:sur =(patp.p our.bowl))))
      ?:  (lth created-at.us-peer created-at.msg)  $(index +(index))  :: skip msgs from after we joined
      :: has to be from a ship that has invite-potential in the path
      ?>  (is-valid-inviter pathrow peers src.bowl our.bowl)
      :: the path has to be %.y on peers-get-backlog
      ?>  peers-get-backlog.pathrow
      =.  received-at.msg   now.bowl

      %=  $
        messages-table.state    (put:msgon:sur messages-table.state [msg-id.msg msg-part-id.msg] msg)
        index                   +(index)
        changes                 [[%add-row %messages msg] changes]
      ==

  :: message-paths is all the sup.bowl paths that start with
  :: /db/messages/start since every new message will need to go out to
  :: those subscriptions
  =/  message-paths  (messages-start-paths bowl)
  =/  gives  :~
    [%give %fact (weld message-paths (limo [/db (weld /db/path path:(snag 0 message)) ~])) chat-db-change+!>(-.changes-and-state)]
  ==
  [gives +.changes-and-state]
::
++  edit
::  :chat-db &db-action [%edit [[~2023.2.2..23.11.10..234a ~zod] /a/path/to/a/chat (limo [[[%plain 'poop'] ~ ~] ~])]]
  |=  [[=msg-id:sur p=path fragments=(list minimal-fragment:sur)] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  ?>  =(sender.msg-id src.bowl)  :: edit pokes are only valid from the ship which is the original sender
  ?>  (has:msgon:sur messages-table.state [msg-id 0])  :: edit pokes are only valid if there is a fragment 0 in the table for the msg-id

  =/  original-expires-at   expires-at:(got:msgon:sur messages-table.state [msg-id 0])
  =/  remove-result         (remove-message state msg-id now.bowl)
  :: we don't want to update the del-log here so manually pull out the
  :: tables we do want to update
  =.  messages-table.state          messages-table.s.remove-result

  =/  add-result            (add-message-to-table messages-table.state [timestamp.msg-id p fragments original-expires-at] sender.msg-id now.bowl now.bowl)
  =.  messages-table.state  -.add-result

  =/  thechange   chat-db-change+!>(~[[%upd-messages msg-id +.add-result]])
  :: message-paths is all the sup.bowl paths that start with
  :: /db/messages/start AND have a timestamp after the timestamp in the
  :: subscription path since they explicitly DONT care about the ones
  :: from earlier
  =/  all-message-paths  (messages-start-paths bowl)
  =/  message-paths  (skim all-message-paths |=(a=path (gth timestamp.msg-id `@da`(slav %da +>+>-:a))))
  =/  gives  :~
    [%give %fact (weld (limo [/db (weld /db/path p) ~]) message-paths) thechange]
  ==
  [gives state]
::
++  delete
::  :chat-db &db-action [%delete [timestamp=~2023.2.2..23.11.10..234a sender=~zod]]
  |=  [=msg-id:sur state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  :: delete pokes are only valid if there is a fragment 0 in the table for the msg-id
  =/  msg-part=msg-part:sur       (got:msgon:sur messages-table.state `uniq-id:sur`[msg-id 0])
  =/  peers=(list peer-row:sur)   (~(got by peers-table.state) path.msg-part)
  =/  host=peer-row:sur           (snag 0 (skim peers |=(p=peer-row:sur =(role.p %host))))
  :: delete pokes are only valid either:
  ?.  ?|  =(sender.msg-id src.bowl)  :: from the ship which is the original sender
          =(src.bowl patp.host)      :: from the host of the chat
      ==
      ~&  >>>  "an invalid :delete poke was received from {(scow %p src.bowl)}... ignoring."
      `state   :: we just no-op instead of crashing

  =/  remove-result   (remove-message state msg-id now.bowl)
  =.  state           s.remove-result
  =/  thechange       chat-db-change+!>(ch.remove-result)

  :: message-paths is all the sup.bowl paths that start with
  :: /db/messages/start AND have a timestamp after the timestamp in the
  :: subscription path since they explicitly DONT care about the ones
  :: from earlier
  =/  all-message-paths  (messages-start-paths bowl)
  =/  message-paths  (skim all-message-paths |=(a=path (gth timestamp.msg-id `@da`(slav %da +>+>-:a))))
  =/  gives  :~
    [%give %fact (weld (limo [/db (weld /db/path path.msg-part) ~]) message-paths) thechange]
  ==
  [gives state]
::
++  delete-backlog
:: deletes all messages from all users before a certain time for a path
::chat-db &db-action [%delete-backlog path=/a/path/to/a/chat before=~2023.2.2..23.11.10..234a]
  |=  [[=path before=time] state=state-5 =bowl:gall]
  ^-  (quip card state-5)

  =/  peers     (~(got by peers-table.state) path)
  =/  host-peer  (snag 0 (skim peers |=(p=peer-row:sur =(%host role.p))))
  ?>  =(patp.host-peer src.bowl)  :: delete-backlog pokes are only valid from the host ship

  =/  remove-result=state-and-changes  (remove-messages-for-path-before state path before now.bowl)
  =.  state         s.remove-result

  =/  gives  :~
    [%give %fact (weld (limo [/db (weld /db/path path) ~]) (messages-start-paths bowl)) chat-db-change+!>(ch.remove-result)]
  ==
  [gives state]
::
++  add-peer
::chat-db &chat-db-action [%add-peer now /example ~fed (some ['' '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'])]
  |=  [act=[t=@da =path patp=ship =nft-sig:sur] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ~&  "{<dap.bowl>}%add-peer {<act>}"
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked

  =/  original-peers-list   (~(got by peers-table.state) path.act)
  =/  pathrow               (~(got by paths-table.state) path.act)
  ?>  (is-valid-inviter pathrow original-peers-list src.bowl patp.act)
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
    (check-alchemy:crypto-helper path.act patp.act t.act chain:(need nft.pathrow) (need nft-sig.act))
  (finish-add-peer act state bowl)
::
++  finish-add-peer
  |=  [act=[t=@da =path patp=ship =nft-sig:sur] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked
  =/  original-peers-list   (~(got by peers-table.state) path.act)
  :: don't double-add a peer
  =/  ships=(set @p)  %-  silt
  %+  turn  original-peers-list
  |=(p=peer-row:sur patp.p)
  ?:  (~(has in ships) patp.act)  `state

  =/  row=peer-row:sur   [
    path.act
    patp.act
    %member
    now.bowl
    now.bowl
    now.bowl
  ]
  =/  peers  (snoc original-peers-list row)
  =.  peers-table.state  (~(put by peers-table.state) path.act peers)
  =/  thechange  chat-db-change+!>(~[[%add-row [%peers row]]])
  =/  vent-path=path  /chat-vent/(scot %da t.act)
  =/  gives  :~
    [%give %fact [/db (weld /db/path path.act) ~] thechange]
    :: give vent response
    [%give %fact ~[vent-path] chat-vent+!>([%path (~(got by paths-table.state) path.act)])]
    [%give %kick ~[vent-path] ~]
  ==
  [gives state]
::
++  edit-peer
::chat-db &chat-db-action [%edit-peer now /a/path/to/a/chat ~bus %admin]
  |=  [act=[t=@da =path patp=ship role=@tas] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked
  ?.  (~(has by paths-table.state) path.act)
    `state  :: do nothing if we get an edit-peer on a path we aren't in

  =/  original-pr   (~(got by paths-table.state) path.act)
  =/  original-peers-list   (~(got by peers-table.state) path.act)

  :: assert that this edit comes from the %host or an %admin
  ?>  (is-valid-editor src.bowl original-peers-list)
  :: assert that the target ship being edited is NOT the host (host is stuck as %host)
  =/  host-peer-row         (snag 0 (skim original-peers-list |=(p=peer-row:sur =(role.p %host))))
  ?<  =(patp.host-peer-row patp.act)
  :: assert that the target ship being edited is already a peer
  =/  og-peer=peer-row:sur  (snag 0 (skim original-peers-list |=(p=peer-row:sur =(patp.act patp.p))))

  ::  do the update
  =/  row=peer-row:sur   [
    path.act
    patp.act
    role.act
    created-at.og-peer
    t.act
    now.bowl
  ]
  =/  peers=(list peer-row:sur)
  %+  snoc
    (skip original-peers-list |=(p=peer-row:sur =(patp.act patp.p)))
  row
  =.  peers-table.state  (~(put by peers-table.state) path.act peers)

  :: return response
  =/  thechange  chat-db-change+!>(~[[%add-row [%peers row]]])
  =/  vent-path=path  /chat-vent/(scot %da t.act)
  =/  gives  :~
    [%give %fact [/db (weld /db/path path.act) ~] thechange]
    :: give vent response
    [%give %fact ~[vent-path] chat-vent+!>([%peers peers])]
    [%give %kick ~[vent-path] ~]
  ==
  [gives state]
::
++  kick-peer
::  :chat-db &chat-db-action [%kick-peer /a/path/to/a/chat ~bus]
  |=  [act=[=path patp=ship] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?<  (~(has in blocked.state) src.bowl)  ::assert that this message is NOT coming from someone we blocked
  ?.  (~(has by paths-table.state) path.act)
    `state  :: do nothing if we get a kick-peer on a path we have already left

  =/  original-pr   (~(got by paths-table.state) path.act)
  =/  original-peers-list   (~(got by peers-table.state) path.act)

  :: handle someone leaving a %dm by leaving it ourselves as well
  =/  ship-set=(set @p)
  %-  silt
  %+  turn  original-peers-list
  |=(p=peer-row:sur patp.p)
  =/  from-member=?  (~(has in ship-set) src.bowl)
  ?:  &(=(type.original-pr %dm) from-member)
    =/  bol  bowl
    =.  src.bol  our.bowl :: permissions-tinkering to make the leave-path call work
    (leave-path path.act state bol)

  :: kick-peer pokes are only valid from the ship which is the
  :: %host of the path, OR from the ship being kicked (kicking yourself)
  =/  host-peer-row         (snag 0 (skim original-peers-list |=(p=peer-row:sur =(role.p %host))))
  ?>  |(=(patp.host-peer-row src.bowl) =(src.bowl patp.act))

  ?:  =(our.bowl patp.act)
    :: if we were the one kicked, it's the same as if we deleted the path
    =/  bol  bowl
    =.  src.bol  our.bowl :: permissions-tinkering to make the leave-path call work
    (leave-path path.act state bol)

  =/  peers  (skip (~(got by peers-table.state) path.act) |=(a=peer-row:sur =(patp.a patp.act)))
  =.  peers-table.state  (~(put by peers-table.state) path.act peers)

  =/  change-row  [%del-peers-row path.act patp.act now.bowl]
  =.  del-log.state   (put:delon:sur del-log.state now.bowl change-row)
  =/  thechange   chat-db-change+!>(~[change-row])

  =/  gives  :~
    [%give %fact [/db (weld /db/path path.act) ~] thechange]
  ==
  [gives state]
::
++  dump-to-bedrock
::  :chat-db &chat-db-action [%dump-to-bedrock ~]
  |=  [state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  =/  our-paths=(list path-row:sur)  :: the list of paths we need to host in bedrock
    %+  skim
      ~(val by paths-table.state)
    |=  =path-row:sur
    =/  peers=(list peer-row:sur)  (~(got by peers-table.state) path.path-row)
    ?:  =(type.path-row %dm)
      =/  first-peer=peer-row:sur  (snag 0 (sort peers |=([a=peer-row:sur b=peer-row:sur] (gth patp.a patp.b))))
      :: if we're the "first-peer" then we'll be the bedrock host of %dm
      =(patp.first-peer our.bowl)
    :: not a %dm
    =/  host=ship  patp:(snag 0 (skim peers |=(p=peer-row:sur =(role.p %host))))
    =(our.bowl host)

  :: first, test bedrock to see if we have already dumped stuff there
  ?:  %+  levy
        our-paths
      |=  =path-row:sur
      (test-bedrock-path-existence:db-scry path.path-row bowl)
    ~&  >>>  "already dumped our-paths to bedrock"
    `state  :: since the path already exists in bedrock, assume we have already dumped

  :: second, push everything into bedrock
  =/  create-path-pokes=(list card)
    %+  turn 
      our-paths
    |=  =path-row:sur
    ^-  card
    =/  peers=ship-roles:sur  (turn (~(got by peers-table.state) path.path-row) |=(p=peer-row:sur [patp.p role.p]))
    [%pass /bedrockpoke %agent [our.bowl %bedrock] %poke %db-action !>([%create-path path.path-row %host ~ ~ ~ peers])]

  =/  create-chat-pokes=(list card)
    %+  turn 
      our-paths
    |=  =path-row:sur
    ^-  card
    =/  peers=ship-roles:sur  (turn (~(got by peers-table.state) path.path-row) |=(p=peer-row:sur [patp.p role.p]))
    =/  chat  [
      metadata.path-row
      type.path-row
      (silt (turn ~(tap in pins.path-row) swap-id-parts))
      invites.path-row
      peers-get-backlog.path-row
      max-expires-at-duration.path-row
    ]
    [%pass /bedrockpoke %agent [our.bowl %bedrock] %poke %db-action !>([%create [our.bowl created-at.path-row] path.path-row chat-type:common [%chat chat] ~])]

  =/  cards=(list card)
   %+  snoc
      %+  weld
        create-path-pokes
      create-chat-pokes
    :: split into two parts because we need all these create-path and
    :: create-chat pokes to be processed so we can connect messages with chat-id
    [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %chat-db-action !>([%dump-to-bedrock-messages our-paths])]
  [cards state]
::
++  dump-to-bedrock-messages
::  :chat-db &db-action [%dump-to-bedrock-messages ~]
  |=  [our-paths=(list path-row:sur) state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  =/  messages-to-dump=(list msg-part:sur)  :: the list of initial msg-parts we need to host in bedrock
    %+  turn
      %+  skim
        (tap:msgon:sur messages-table.state)
      |=  [k=uniq-id:sur v=msg-part:sur]
      ^-  ?
      ?:  (gth msg-part-id.k 0)  %.n  :: only want the initial msg-parts
      (lien our-paths |=(p=path-row:sur =(path.p path.v)))
    |=([k=uniq-id:sur v=msg-part:sur] v)

  :: first, test bedrock to see if we have already dumped stuff there
  ?:  %+  levy
        messages-to-dump
      |=  =msg-part:sur
      =/  ex=?  (test-bedrock-row-existence:db-scry path.msg-part message-type:common (swap-id-parts msg-id.msg-part) bowl)
      ex
    ~&  >>>  "already dumped to bedrock"
    `state  :: since the path already exists in bedrock, assume we have already dumped

  :: second, push everything into bedrock
  =/  cards=(list card)
    :-  [%pass /dbpoke %agent [our.bowl %bedrock] %poke %db-action !>([%refresh-chat-paths ~])]
    %+  turn 
      messages-to-dump
    |=  =msg-part:sur
    ^-  card
    =/  chat=(unit row:db)  (scry-first-bedrock-chat:db-scry path.msg-part bowl)
    ?~  chat  *card
    =/  chat-id=[=ship t=@da]  id.u.chat
    =/  msg  [
      chat-id
      ?~(reply-to.msg-part ~ (some [-.u.reply-to.msg-part (swap-id-parts q.u.reply-to.msg-part)]))
      expires-at.msg-part
      (turn (get-full-message messages-table.state msg-id.msg-part) |=(m=msg-part:sur [content.m metadata.m]))
    ]
    [
      %pass
      /dbpoke
      %agent
      [our.bowl %bedrock]
      %poke
      %db-action
      !>([%create [sender.msg-id.msg-part created-at.msg-part] path.msg-part message-type:common [%message msg] ~])
    ]

  [cards state]
::
++  de-dup-peers-and-leave-empty-dms
::  :chat-db &chat-db-action [%de-dup-peers ~]
  |=  [state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  =.  peers-table.state
  %-  ~(run by peers-table.state)
  |=  peers=(list peer-row:sur)
  ^-  (list peer-row:sur)
  =/  semi-peers=(set [=path patp=@p role=@tas])
    %-  silt
    %+  turn  peers
    |=  p=peer-row:sur
    [path.p patp.p role.p]
  %+  turn
    ~(tap in semi-peers)
  |=  sp=[=path patp=@p role=@tas]
  ^-  peer-row:sur
  %+  snag  0
  %+  skim  peers
  |=  p=peer-row:sur
  ^-  ?
  &(=(path.sp path.p) =(patp.sp patp.p) =(role.sp role.p))

  =/  empty-dms=(list path-row:sur)
  %+  skim  ~(val by paths-table.state)
  |=  p=path-row:sur
  :: find all the paths that are %dm and only have 1 peer
  ?&  =(type.p %dm)
      =(1 (lent (~(got by peers-table.state) path.p)))
  ==

  =/  cards=(list card)  ~
  |-
    ?:  =((lent empty-dms) 0)
      [cards state]
    =/  empty-dm=path-row:sur  (snag 0 empty-dms)
    =/  cs  (leave-path path.empty-dm state bowl)
    $(empty-dms +.empty-dms, cards (weld -.cs cards), state +.cs)
::
++  toggle-block
::chat-db &chat-db-action [%toggle-block ~zod %.y]
  |=  [[=ship block=?] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?>  =(src.bowl our.bowl)
  =.  blocked.state
    ?:  block  (~(put in blocked.state) ship)
    (~(del in blocked.state) ship)
  `state
::
++  set-allowed-migrate-host
::chat-db &chat-db-action [%set-allowed-migrate-host ~zod]
  |=  [=ship state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?>  =(src.bowl our.bowl)
  =.  allowed-migration-hosts.state  (~(put in allowed-migration-hosts.state) ship)
  `state
::
++  remove-allowed-migrate-host
::chat-db &chat-db-action [%remove-allowed-migrat-host ~zod]
  |=  [=ship state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?>  =(src.bowl our.bowl)
  =.  allowed-migration-hosts.state  (~(del in allowed-migration-hosts.state) ship)
  `state
::
++  migrate-chat
::chat-db &chat-db-action [%migrate-chat ~bus /realm-chat/path-id]
  |=  [[=ship =path] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ?>  =(src.bowl our.bowl)
  =/  pr=path-row:sur  (~(got by paths-table.state) path)
  =/  peers=(list peer-row:sur)  (~(got by peers-table.state) path)
  :: ensure that the transferring peer exists in the peer-list
  =/  matching-peer=peer-row:sur
  %+  snag  0
  (skim peers |=(p=peer-row:sur =(ship patp.p)))
  =/  msg=message:sur
  %+  turn  (tap:msgon:sur (path-msgs:from messages-table.state path))
  |=([k=* v=msg-part:sur] v)
  ::  get all messages on path
  =/  cards=(list card)
  %+  snoc
    %+  turn  peers
    |=  p=peer-row:sur
    ^-  card
    [%pass /dbpoke %agent [patp.p dap.bowl] %poke chat-db-action+!>([%migrating-host ship path])]
  [
    %pass
    /migrate-response
    %agent
    [ship dap.bowl]
    %poke
    %chat-db-action
    !>([%receive-migrated-chat pr peers msg])
  ]
  [cards state]
::
++  migrating-host
:: signal from a former host to a normal peer that they want to migrate
:: we just mark down that they wanted to do this, and wait for
:: confrimation from the new host
::chat-db &chat-db-action [%migrating-host ~bus /realm-chat/path-id]
  |=  [[=ship =path] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ~&  "%migrating-host {<ship>} {<path>}"
  =/  pr=path-row:sur  (~(got by paths-table.state) path)
  =/  peers=(list peer-row:sur)  (~(got by peers-table.state) path)
  =/  original-host=peer-row:sur
  %+  snag  0
  (skim peers |=(p=peer-row:sur =(%host role.p)))
  ?>  =(src.bowl patp.original-host)
  ~&  "%migrating-host passed security checks"
  =.  ongoing-migrations.state
  (~(put in ongoing-migrations.state) [ship path])
  [~ state]
::
++  migrated-host
:: signal from a new host to a normal peer that they have accepted the migration
::chat-db &chat-db-action [%migrated-host ~bus /realm-chat/path-id]
  |=  [[=ship =path] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ~&  "%migrated-host {<ship>} {<path>}"
  :: we require that we heard from the original host that we was
  :: migrating to `ship`
  ?>  (~(has in ongoing-migrations.state) [ship path])
  :: and that `ship` is the one who sent this confirmation of migration
  ?>  =(src.bowl ship)
  ~&  "%migrated-host passed security checks"
  =/  pr=path-row:sur  (~(got by paths-table.state) path)
  =/  peers=(list peer-row:sur)  
  %+  turn  (~(got by peers-table.state) path)
  |=  p=peer-row:sur
  ^-  peer-row:sur
  =.  role.p
    ?:  =(ship patp.p)    %host
    ?:  =(%host role.p)   %member
    role.p
  p
  =/  new-host=peer-row:sur
  %+  snag  0
  (skim peers |=(p=peer-row:sur =(%host role.p)))
  =.  peers-table.state  (~(put by peers-table.state) path peers)
  =.  ongoing-migrations.state
  (~(del in ongoing-migrations.state) [ship path])
  =/  cards=(list card)  :~
    [%give %fact [/db (weld /db/path path) ~] chat-db-change+!>(~[[%add-row [%peers new-host]]])]
  ==
  [cards state]
::
++  receive-migrated-chat
::chat-db &chat-db-action [%receive-migrated-chat path-row peers message]
  |=  [[=path-row:sur peers=(list peer-row:sur) msgs=message:sur] state=state-5 =bowl:gall]
  ^-  (quip card state-5)
  ~&  "%receive-migrated-chat {<path-row>}"
  ?>  (~(has in allowed-migration-hosts.state) src.bowl)
  ~&  >  "%receive-migrated-chat passed security checks"
  =.  paths-table.state  (~(put by paths-table.state) path.path-row path-row)
  =.  peers-table.state  (~(put by peers-table.state) path.path-row peers)
  =.  messages-table.state
  %+  gas:msgon:sur
    messages-table.state
  %+  turn
    msgs
  |=  =msg-part:sur
  ^-  [k=uniq-id:sur v=msg-part:sur]
  [[msg-id.msg-part msg-part-id.msg-part] msg-part]

  =/  cards=(list card)
  %+  turn  peers
  |=  p=peer-row:sur
  ^-  card
  [%pass /dbpoke %agent [patp.p dap.bowl] %poke chat-db-action+!>([%migrated-host our.bowl path.path-row])]

  [cards state]
::
::
::  mini helper lib
::
++  from
  |%
  ++  start-lot
    :: this is very efficient, but does not capture the updated-at rows
    :: so we will use ++start (below) until this is necessary
    |=  [=msg-id:sur tbl=messages-table:sur]
    ^-  messages-table:sur
    =/  start=uniq-id:sur  [msg-id 0]
    (lot:msgon:sur tbl ~ `start)
  ::
  ++  start
    |=  [t=time tbl=messages-table:sur]
    ^-  messages-table:sur
    %+  gas:msgon:sur
      *messages-table:sur
    %+  skim
      (tap:msgon:sur tbl)
    |=([k=uniq-id:sur v=msg-part:sur] (gth received-at.v t))
  ::
  ++  path-msgs
    |=  [tbl=messages-table:sur =path]
    ^-  messages-table:sur
    %+  gas:msgon:sur
      *messages-table:sur
    %+  skim
      (tap:msgon:sur tbl)
    |=([k=uniq-id:sur v=msg-part:sur] =(path.v path))
  ::
  ++  path-msgs-count
    |=  [tbl=messages-table:sur =path]
    ^-  @ud
    %-  lent
    %+  skim
      (tap:msgon:sur tbl)
    |=([k=uniq-id:sur v=msg-part:sur] =(path.v path))
  ::
  ++  path-start
    |=  [t=time tbl=paths-table:sur]
    ^-  paths-table:sur
    %-  malt
    %+  skim
      ~(tap by tbl)
    |=([k=path v=path-row:sur] (gth received-at.v t))
  ::
  ++  peer-start
    |=  [t=time tbl=peers-table:sur]
    ^-  peers-table:sur

    =/  individual-rows=(list peer-row:sur)  (zing ~(val by tbl))
    =/  valid-rows
      %+  skim
        individual-rows
      |=(r=peer-row:sur (gth received-at.r t))

    =/  index=@ud  0
    =/  len=@ud    (lent valid-rows)
    =/  result=peers-table:sur  *peers-table:sur
    |-
    ?:  =(index len)
      result
    =/  i  (snag index valid-rows)
    =/  pre  (~(get by result) path.i)
    =/  lis
    ?~  pre
      (limo ~[i])
    (snoc (need pre) i)
    $(result (~(put by result) path.i lis), index +(index))
  ++  paths-list
    |=  [tbl=paths-table:sur]
    ^-  (list path)
    (turn ~(val by tbl) |=(a=path-row:sur path.a))
  --
::
::  JSON
::
++  enjs
  =,  enjs:format
  |%
    ++  db-dump :: encodes for on-watch
      |=  db=db-dump:sur
      ^-  json
      %-  pairs
      :_  ~
      ^-  [cord json]
      :-  -.db
      ?-  -.db
        %tables
          (all-tables:encode tables.db)
      ==
    ++  db-change :: encodes for on-watch
      |=  db=db-change:sur
      ^-  json
      (changes:encode db)
    ::
    ++  messages-table :: encodes for on-watch
      |=  tbl=messages-table:sur
      ^-  json
      (messages-table:encode tbl)
    ::
    ++  path-row :: encodes for on-watch
      |=  =path-row:sur
      ^-  json
      (path-row:encode path-row)
  --
++  encode
  =,  enjs:format
  |%
    ++  del-log
      |=  log=del-log:sur
      ^-  json
      :-  %a
      %+  turn  (tap:delon:sur log)
      |=  [k=@da v=db-change-type:sur]
      %-  pairs
      :~
        ['timestamp' (time k)]
        ['change' (individual-change v)]
      ==
    ::
    ++  all-tables
      |=  =tables:sur
      ^-  json
      %-  pairs
      %+  turn  tables
        |=  =table:sur
        ?-  -.table
          %paths      paths+(paths-table +.table)
          %messages   messages+(messages-table +.table)
          %peers      peers+(peers-table +.table)
        ==
    ::
    ++  paths-table
      |=  tbl=paths-table:sur
      ^-  json
      [%a ~(val by (~(run by tbl) path-row))]
    ::
    ++  peers-table
      |=  tbl=peers-table:sur
      ^-  json
      a+(zing (turn ~(val by tbl) |=(a=(list peer-row:sur) (turn a peer-row))))
    ::
    ++  messages-table
      |=  tbl=messages-table:sur
      ^-  json
      [%a (turn (tap:msgon:sur tbl) messages-row)]
    ::
    ++  changes
      |=  ch=db-change:sur
      ^-  json
      [%a (turn ch individual-change)]
    ::
    ++  individual-change
      |=  ch=db-change-type:sur
      %-  pairs
      ?-  -.ch
        %add-row
          :~(['type' %s -.ch] ['table' %s -.+.ch] ['row' (any-row db-row.ch)])
        %upd-messages
          :~
            ['type' %s %update]
            ['table' %s %messages]
            ['msg-id' (msg-id-to-json msg-id.ch)]
            ['message' a+(turn message.ch |=(m=msg-part:sur (messages-row [[msg-id.m msg-part-id.m] m])))]
          ==
        %upd-paths-row
          :~
            ['type' %s %update]
            ['table' %s %paths]
            ['row' (path-row path-row.ch)]
            ['old-row' (path-row old.ch)]
          ==
        %del-paths-row
          :~(['type' %s -.ch] ['table' %s %paths] ['path' s+(spat path.ch)] ['timestamp' (time timestamp.ch)])
        %del-peers-row
          :~(['type' %s -.ch] ['table' %s %peers] ['path' s+(spat path.ch)] ['ship' s+(scot %p ship.ch)] ['timestamp' (time timestamp.ch)])
        %del-messages-row
          :~
            ['type' %s -.ch]
            ['table' %s %messages]
            ['path' s+(spat path.ch)]
            ['msg-id' (msg-id-to-json msg-id.uniq-id.ch)]
            ['msg-part-id' (numb msg-part-id.uniq-id.ch)]
            ['timestamp' (time timestamp.ch)]
          ==
      ==
    ::
    ++  any-row
      |=  =db-row:sur
      ^-  json
      ?-  -.db-row
        %paths
          (path-row path-row.db-row)
        %messages
          (messages-row [msg-id.msg-part.db-row msg-part-id.msg-part.db-row] msg-part.db-row)
        %peers
          (peer-row peer-row.db-row)
      ==
    ::
    ++  path-row
      |=  =path-row:sur
      ^-  json
      %-  pairs
      :~  path+s+(spat path.path-row)
          metadata+(metadata-to-json metadata.path-row)
          type+s+type.path-row
          created-at+(time created-at.path-row)
          updated-at+(time updated-at.path-row)
          pins+a+(turn ~(tap in pins.path-row) msg-id-to-json)
          invites+s+invites.path-row
          peers-get-backlog+b+peers-get-backlog.path-row
          :: return as integer millisecond duration
          max-expires-at-duration+(numb (|=(t=@dr ^-(@ud (mul (div t ~s1) 1.000))) max-expires-at-duration.path-row))
          received-at+(time received-at.path-row)
          nft+(en-nft-info nft.path-row)
      ==
    ::
    ++  en-nft-info
      |=  nft=(unit [contract=@t chain=@t standard=@t])
      ^-  json
      ?~  nft  ~
      %-  pairs
      :~  contract+s+contract.u.nft
          chain+s+chain.u.nft
          standard+s+standard.u.nft
      ==
    ::
    ++  messages-row
      |=  [k=uniq-id:sur =msg-part:sur]
      ^-  json
      %-  pairs
      :~  path+s+(spat path.msg-part)
          sender+s+(scot %p sender.msg-id.msg-part)
          msg-id+(msg-id-to-json msg-id.msg-part)
          msg-part-id+(numb msg-part-id.msg-part)
          content-type+(content-typeify content.msg-part)
          content-data+(content-dataify content.msg-part)
          reply-to+(reply-to-to-json reply-to.msg-part)
          metadata+(metadata-to-json metadata.msg-part)
          created-at+(time created-at.msg-part)
          updated-at+(time updated-at.msg-part)
          expires-at+(time-bunt-null expires-at.msg-part)
          received-at+(time received-at.msg-part)
      ==
    ::
    ++  en-vent
      |=  =chat-vent:sur
      ^-  json
      ?-  -.chat-vent
        %ack     s/%ack
        %msg     a+(turn message.chat-vent |=(m=msg-part:sur (messages-row [msg-id.m msg-part-id.m] m)))
        %path    (path-row path-row.chat-vent)
        %peers
        :-  %a
        (turn peers.chat-vent peer-row)
        %path-and-count
      =/  prj=json  (path-row path-row.chat-vent)
      ?>  ?=([%o *] prj)
      :-  %o
      (~(put by p.prj) %msg-count (numb msg-count.chat-vent))
      ==
    ::
    ++  time-bunt-null
      |=  t=@da
      ?:  =(t *@da)
        ~
      (time t)
    ::
    ++  reply-to-to-json
      |=  =reply-to:sur
      ^-  json
      ?~  reply-to
        ~
      %-  pairs
      :~  path+[%s (spat -.+.reply-to)]
          msg-id+(msg-id-to-json +.+.reply-to)
      ==
    ::
    ++  content-typeify
      |=  =content:sur
      ^-  json
      ?+  -.content
        ::default here
        [%s `@t`-.content]
        %custom  [%s `@t`-.+.content]
      ==
    ::
    ++  content-dataify
      |=  =content:sur
      ?+  -.content
        ::default here
        [%s +.content]
        %ship     [%s `@t`(scot %p p.content)]
        %break    ~
        %custom   [%s +.+.content]
      ==
    ::
    ++  msg-id-to-json
      |=  =msg-id:sur
      ^-  json
      s+(msg-id-to-cord msg-id)
    ::
    ++  msg-id-to-cord
      |=  =msg-id:sur
      ^-  cord
      (spat ~[(scot %da timestamp.msg-id) (scot %p sender.msg-id)])
    ::
    ++  metadata-to-json
      |=  m=(map cord cord)
      ^-  json
      o+(~(rut by m) |=([k=cord v=cord] s+v))
    ::
    ++  peer-row
      |=  =peer-row:sur
      ^-  json
      %-  pairs
      :~  path+s+(spat path.peer-row)
          ship+s+(scot %p patp.peer-row)
          role+s+role.peer-row
          created-at+(time created-at.peer-row)
          updated-at+(time updated-at.peer-row)
          received-at+(time received-at.peer-row)
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
      :~  [%toggle-block (ot ~[ship+de-ship block+bo])]
      ==
    ++  de-ship  (su ;~(pfix sig fed:ag))
    --
  --
--
