/-  common
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      ~
  ==
+$  store-results  [@t endpoint=@t access-key-id=@t secret-access-key=@t]
+$  store-conf  [%configuration buckets=(set @t) current-bucket=@t region=@t *]
+$  action
  $%  [%sync-to-bedrock ~]
      [%set-creds set-storage-agent=? =creds:common]
  ==
--
