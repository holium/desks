/-  membership, spaces-path
|%
::
+$  space-path    path:spaces-path
+$  chat-access
  $%  [%role =role:membership]        :: ships in the members map with status %joined or %host, and a specified role
      [%all ~]                        :: any ship in the members map, regardless of status
      [%whitelist ships=(set ship)]   :: specific ships, must also be in members map
      [%blacklist ships=(set ship)]   :: all ships in members map, except specific ships
  ==
::
+$  chat
  $:  =path
      access=chat-access
  ==
::
+$  chats         (map path chat)
+$  space-chats   (map space-path chats)
::
+$  state-0       [%0 chats=space-chats]
::
+$  action
  $%  [%create-channel path=space-path =chat]
      [%init ~]
      :: [%delete-channel path=space-path]
      :: [%set-access path=space-path chat-path=path access=chat-access]
  ==
::
--
