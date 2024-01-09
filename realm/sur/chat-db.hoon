::  chat-db [realm]
::
|%

::  3 bits of info in a uniq-id: timestamp, sender, msg-part-id
::  order by timestamp first
::  then sender
::  then msg-part-id
++  idx-sort
  |=  [a=uniq-id b=uniq-id]
  ?.  =(timestamp.msg-id.a timestamp.msg-id.b)
    (gth timestamp.msg-id.a timestamp.msg-id.b)
  :: same timestamp, so either ships sent msg at same time, or order by
  :: msg-part-id
  ?:  =(sender.msg-id.a sender.msg-id.b)
    :: they are the same ship, so order by msg-part-id
    (gth msg-part-id.a msg-part-id.b)
  :: they are different ships, so just order by ship id
  (gth sender.msg-id.a sender.msg-id.b)
::
::  database types
::
+$  pins  (set msg-id)
+$  path-row
  $:  =path
      metadata=(map cord cord)
      type=@tas     :: not officially specified, up to user to interpret for maybe %dm vs %group or %chat vs %board or whatever
                    :: if %nft-gated, the `nft` logic comes into play
      created-at=time
      updated-at=time  :: updated when %edit-path-medatata is hit
      =pins
      invites=@tas  :: must either match `peer-role` type or be keyword %anyone, or else no one will be able to invite
      peers-get-backlog=?
      max-expires-at-duration=@dr  :: optional chat-wide enforced expires-at on messages. 0 or *@dr means "not set"
      received-at=time
      nft=(unit [contract=@t chain=@t standard=@t]) :: contract is the 0x789... address, chain is "eth-mainnet" or whatever, standard is "ERC-721"
  ==
::
+$  paths-table  (map path path-row)
::
+$  msg-id    [timestamp=@da sender=ship] :: paired with ship for uniqueness in global scope (like when two ships happen to send messages at exactly the same time)
+$  msg-part-id  @ud            :: continuously incrementing numeric id, but only within a message
+$  message   (list msg-part)   :: all the msg-part that have the same msg-id and path
+$  reply-to  (unit (pair path msg-id))
+$  msg-part
  $:  =path
      =msg-id
      =msg-part-id
      =content
      =reply-to
      metadata=(map cord cord)
      created-at=@da
      updated-at=@da  :: set to now.bowl when %edit action. means it can be out of sync between ships, but shouldn't matter
      expires-at=@da  :: *@da is treated as "unset"
      received-at=@da
  ==
+$  content
  $%  [%custom name=cord value=cord] :: general data type
      [%markdown p=cord]
      [%plain p=cord]
      [%bold p=cord]
      [%italics p=cord]
      [%strike p=cord]
      [%bold-italics p=cord]
      [%bold-strike p=cord]
      [%italics-strike p=cord]
      [%bold-italics-strike p=cord]
      [%blockquote p=cord]
      [%inline-code p=cord]
      [%ship p=ship]
      [%code p=cord]
      [%link p=cord]
      [%image p=cord]
      [%ur-link p=cord]      :: for links to places on the urbit network
      [%react p=cord]        :: for emojii reactions to messages
      [%status p=cord]       :: for automated messages like "X joined the chat"
      [%break ~]
  ==
::
+$  uniq-id  [=msg-id =msg-part-id]
+$  messages-table  ((mop uniq-id msg-part) idx-sort)
++  msgon           ((on uniq-id msg-part) idx-sort)
+$  tbl-and-ids     [tbl=messages-table ids=(list uniq-id)]
+$  msg-kvs         (list [k=uniq-id v=msg-part])
::
+$  peer-row
  $:  =path
      patp=ship
      role=@tas
      created-at=time
      updated-at=time  :: not used really yet, but if we implement a way to change peers role, then this would be needed
      received-at=time
  ==
::
+$  peers-table  (map path (list peer-row))
::
+$  table-name   ?(%paths %messages %peers)
+$  table
  $%  [%paths =paths-table]
      [%messages =messages-table]
      [%peers =peers-table]
  ==
+$  tables  (list table)
::
::  agent details
::
+$  ship-roles  (list [s=@p role=@tas])
+$  nft-sig    (unit [sig=@t addr=@t name=@t nonce=@ud t=@ud])
+$  action
  $%  
      [%create-path =path-row peers=ship-roles expected-msg-count=@ud t=(unit @da) join-silently=?]
      [%edit-path =path metadata=(map cord cord) peers-get-backlog=? invites=@tas max-expires-at-duration=@dr]
      [%edit-path-pins =path =pins]
      [%leave-path =path]
      [%insert =insert-message-action]
      [%insert-backlog =message]
      [%edit =edit-message-action]
      [%delete =msg-id]
      [%delete-backlog =path before=time]
      [%add-peer t=@da =path patp=ship =nft-sig]
      [%edit-peer t=@da =path patp=ship role=@tas]
      [%kick-peer =path patp=ship]
      [%dump-to-bedrock ~]
      [%dump-to-bedrock-messages our-paths=(list path-row)]
      [%de-dup-peers ~]

      [%toggle-block =ship block=?]
      [%set-allowed-migrate-host =ship]
      [%remove-allowed-migrate-host =ship]
      [%migrate-chat new-host=ship =path]
      [%migrating-host new-host=ship =path]
      [%migrated-host new-host=ship =path]
      [%receive-migrated-chat =path-row peers=(list peer-row) =message]
  ==
+$  minimal-fragment        [=content =reply-to metadata=(map cord cord)]
+$  insert-message-action   [timestamp=@da =path fragments=(list minimal-fragment) expires-at=@da]
+$  edit-message-action     [=msg-id =path fragments=(list minimal-fragment)]
::
+$  db-dump
  $%  
      [%tables =tables]
  ==
+$  db-del-type
  $%
    [%del-paths-row =path timestamp=@da]
    [%del-peers-row =path =ship timestamp=@da]
    [%del-messages-row =path =uniq-id timestamp=@da]
  ==
+$  db-change-type
  $%
    [%add-row =db-row]
    [%upd-messages =msg-id =message]
    [%upd-paths-row =path-row old=path-row]
    db-del-type
  ==
+$  db-row
  $%  [%paths =path-row join-silently=?]
      [%messages =msg-part]
      [%peers =peer-row]
  ==
+$  db-change  (list db-change-type)
+$  del-log  ((mop time db-del-type) gth)
++  delon  ((on time db-del-type) gth)
::
+$  chat-vent
  $%  [%msg =message]
      [%path =path-row]
      [%peers peers=(list peer-row)]
      [%path-and-count =path-row msg-count=@ud]
      [%ack ~]
  ==
::
:: old versions
::
+$  del-log-0  ((mop time db-change-type-0) gth)
+$  db-change-type-0
  $%
    [%add-row =db-row]
    [%upd-messages =msg-id =message]
    [%upd-paths-row =path-row]
    [%del-paths-row =path timestamp=@da]
    [%del-peers-row =path =ship timestamp=@da]
    [%del-messages-row =path =uniq-id timestamp=@da]
  ==
+$  del-log-1  ((mop time db-change-type-1) gth)
+$  db-change-type-1
  $%
    [%add-row =db-row-1]
    [%upd-messages =msg-id message=(list msg-part-1)]
    [%upd-paths-row =path-row-1 old=path-row-1]
    [%del-paths-row =path timestamp=@da]
    [%del-peers-row =path =ship timestamp=@da]
    [%del-messages-row =path =uniq-id timestamp=@da]
  ==
+$  db-row-1
  $%  [%paths =path-row-1]
      [%messages =msg-part-1]
      [%peers =peer-row-1]
  ==
+$  content-1
  $%  [%custom name=cord value=cord]
      [%plain p=cord]
      [%bold p=cord]
      [%italics p=cord]
      [%strike p=cord]
      [%bold-italics p=cord]
      [%bold-strike p=cord]
      [%italics-strike p=cord]
      [%bold-italics-strike p=cord]
      [%blockquote p=cord]
      [%inline-code p=cord]
      [%ship p=ship]
      [%code p=cord]
      [%link p=cord]
      [%image p=cord]
      [%ur-link p=cord]
      [%react p=cord]
      [%status p=cord]
      [%break ~]
  ==
+$  msg-part-1
  $:  =path
      =msg-id
      =msg-part-id
      content=content-1
      =reply-to
      metadata=(map cord cord)
      created-at=@da
      updated-at=@da
      expires-at=@da
  ==
+$  messages-table-1  ((mop uniq-id msg-part-1) idx-sort)
++  msgon-1           ((on uniq-id msg-part-1) idx-sort)
+$  path-row-1
  $:  =path
      metadata=(map cord cord)
      type=@tas
      created-at=time
      updated-at=time
      =pins
      invites=@tas
      peers-get-backlog=?
      max-expires-at-duration=@dr
  ==
+$  paths-table-1  (map path path-row-1)
+$  peer-row-1
  $:  =path
      patp=ship
      role=@tas
      created-at=time
      updated-at=time
  ==
+$  peers-table-1  (map path (list peer-row-1))
::
+$  path-row-2
  $:  =path
      metadata=(map cord cord)
      type=@tas
      created-at=time
      updated-at=time
      =pins
      invites=@tas
      peers-get-backlog=?
      max-expires-at-duration=@dr
      received-at=time
  ==
+$  paths-table-2  (map path path-row-2)
+$  db-change-type-2
  $%
    [%add-row =db-row-2]
    [%upd-messages =msg-id =message]
    [%upd-paths-row =path-row-2 old=path-row-2]
    [%del-paths-row =path timestamp=@da]
    [%del-peers-row =path =ship timestamp=@da]
    [%del-messages-row =path =uniq-id timestamp=@da]
  ==
+$  db-row-2
  $%  [%paths =path-row-2]
      [%messages =msg-part]
      [%peers =peer-row]
  ==
+$  del-log-2  ((mop time db-change-type-2) gth)
+$  del-log-3  ((mop time db-change-type-3) gth)
++  delon-3  ((on time db-change-type-3) gth)
+$  db-change-type-3
  $%
    [%add-row db-row=db-row-3]
    [%upd-messages =msg-id =message]
    [%upd-paths-row =path-row old=path-row]
    db-del-type
  ==
+$  db-row-3
  $%  [%paths =path-row]
      [%messages =msg-part]
      [%peers =peer-row]
  ==
--
