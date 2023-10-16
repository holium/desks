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
      =paths-table
      =messages-table
      =peers-table
      =del-log
  ==
+$  state-3
  $:  %3
      =paths-table
      =messages-table
      =peers-table
      =del-log
      allowed-migration-hosts=(set @p)
  ==
+$  state-and-changes   [s=state-3 ch=db-change]
--
