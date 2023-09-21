/-  *chat-db
|%

+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
      state-1
      state-2
      state-3
  ==
+$  state-0
  $:  %0
      =paths-table-1
      =messages-table-1
      =peers-table-1
      del-log=del-log-0
  ==
+$  state-1
  $:  %1
      =paths-table-1
      =messages-table-1
      =peers-table-1
      =del-log-1
  ==
+$  state-2
  $:  %2
      =paths-table-2
      =messages-table
      =peers-table
      =del-log-2
  ==
+$  state-3
  $:  %3
      =paths-table
      =messages-table
      =peers-table
      =del-log
  ==
+$  state-and-changes   [s=state-3 ch=db-change]
--
