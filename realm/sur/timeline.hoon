/-  common, db, cd=chat-db
:: create personal timeline 
|%
+$  timeline-post  timeline-post:common
+$  nft  (unit [contract=@t chain=@t standard=@t])
::
+$  action
  $%  [%create-timeline name=@ta]
      [%delete-timeline name=@ta]
      [%set-timeline-nft =path =nft]
      [%follow-timeline =path]
      [%handle-follow-request name=@ta]
      [%leave-timeline =path]
      [%handle-leave-request name=@ta]
      [%create-timeline-posts =path posts=(list timeline-post)]
      [%create-timeline-post =path post=timeline-post]
      [%delete-timeline-post =path =id:common]
      [%relay-timeline-post from=path =id:common to=(list path)]
      [%create-react =path =react:common]
      [%delete-react =path =id:common]
      [%create-comment =path =comment:common]
      [%delete-comment =path =id:common]
      [%add-forerunners-bedrock force=?]
      [%add-chat =path name=@ta force=?]
      [%create-personal-timeline ~]
      [%convert-message =msg-id:cd =msg-part-id:cd to=(list path)]
      [%add-random-emojis =path]
  ==
::
+$  update  ~
+$  view
  $%  [%messages msgs=messages-table:cd]
      [%types types=(set [term (set cord)])]
      [%paths paths=(list path)]
  ==
::
+$  vent
  %+  pair  wain  :: printf
  $@  ~
  $%  [%timeline-path =path]
      [%timeline =row:db =schema:db]
      [%timeline-post =row:db =schema:db]
      [%react =row:db =schema:db]
      [%comment =row:db =schema:db]
  ==
--
