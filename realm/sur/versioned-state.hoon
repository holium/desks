/-  *chat-db
|%

+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
      state-1
      state-2
      state-3
      state-4
      state-5
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
      =paths-table-2
      =messages-table
      =peers-table
      =del-log-2
      allowed-migration-hosts=(set @p)
      ongoing-migrations=(set [=ship =path])
  ==
+$  state-4
  $:  %4
      =paths-table
      =messages-table
      =peers-table
      del-log=del-log-3
      allowed-migration-hosts=(set @p)
      ongoing-migrations=(set [=ship =path])
  ==
+$  state-5
  $:  %5
      =paths-table
      =messages-table
      =peers-table
      =del-log
      allowed-migration-hosts=(set @p)
      ongoing-migrations=(set [=ship =path])
      blocked=(set @p)
  ==
+$  state-and-changes   [s=state-5 ch=db-change]
--
