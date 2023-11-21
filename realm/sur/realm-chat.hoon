/-  db=chat-db
::  realm-chat [realm]
::
|%
+$  card   card:agent:gall
+$  pins   (set path)
+$  mutes  (set path)
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  state-0
  $:  %0
      app-id=@t           :: constant
      uuid=@uvH           :: (sham @p)
      =devices            :: (map device-id player-id)
      push-enabled=?
      =mutes              :: the list of muted chat `path`s
      =pins               :: the set of pinned chat `path`s
      msg-preview-notif=?
  ==
+$  state-1
  $:  %1
      hide-debug=?
      app-id=@t           :: constant
      uuid=@uvH           :: (sham @p)
      =devices            :: (map device-id player-id)
      push-enabled=?
      =mutes              :: the list of muted chat `path`s
      =pins               :: the set of pinned chat `path`s
      msg-preview-notif=?
  ==
::
+$  devices  (map @t @t)
::
+$  push-notif
  $:  app-id=cord                   ::  the onesignal app-id for realm
      data=push-mtd                 ::  { "path-row": {}, "unread": 0, "avatar": null }
      title=(map cord cord)         ::  {"en": "Sender Name"}
      subtitle=(map cord cord)      ::  (optional) {"en": "Group title"}
      contents=(map cord cord)      ::  {"en": "New Message"} or the actual message
  ==
::
+$  push-mtd
  $:  =path-row:db
      unread=@ud
      avatar=(unit @t)
      =message:db
  ==
::
+$  nft-sig    nft-sig:db
::
+$  action
  $%
      :: interface to %chat-db
      [%create-chat =create-chat-data]
      [%vented-create-chat t=@da c=create-chat-data]
      [%edit-chat =path metadata=(map cord cord) peers-get-backlog=? invites=@tas max-expires-at-duration=@dr]
      [%pin-message =path =msg-id:db pin=?]
      [%clear-pinned-messages =path]
      [%add-ship-to-chat t=@da =path =ship host=(unit ship) =nft-sig join-silently=?]
      [%edit-ship-role t=@da =path =ship role=@tas]
      [%remove-ship-from-chat =path =ship]
      [%send-message =path fragments=(list minimal-fragment:db) expires-in=@dr]
      [%vented-send-message t=@da =path fragments=(list minimal-fragment:db) expires-in=@dr]
      [%edit-message =edit-message-action:db]
      [%delete-message =path =msg-id:db]
      [%delete-backlog =path]
      [%room-action =path kind=?(%start %join %leave)] :: creates a %status message that we start/join/left a room

      :: internal %realm-chat state updaters
      [%enable-push ~]
      [%disable-push ~]
      [%set-device device-id=@t player-id=@t]
      [%remove-device device-id=@t]
      [%clear-devices ~]
      [%mute-chat =path mute=?]  :: toggles the muted-state of the path
      [%pin-chat =path pin=?]    :: toggles the pinned-state of the path
      [%toggle-msg-preview-notif msg-preview-notif=?]
      [%toggle-hide-debug hide-debug=?]

      [%create-notes-to-self-if-not-exists ~]
  ==
+$  create-chat-data
  $:  metadata=(map cord cord)
      type=@tas
      peers=(list ship)
      invites=@tas
      max-expires-at-duration=@dr
      peers-get-backlog=?
      nft=(unit [contract=@t chain=@t standard=@t])
  ==
--
