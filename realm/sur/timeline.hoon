/-  common, db, cd=chat-db
|%
+$  cid  @t
::
+$  timeline-post  timeline-post:common
::
+$  action
  $%  [%create-timeline name=@ta]
      [%delete-timeline name=@ta]
      [%follow-timeline =path]
      [%handle-follow-request name=@ta]
      [%leave-timeline =path]
      [%handle-leave-request name=@ta]
      [%create-timeline-posts =path posts=(list timeline-post)]
      [%delete-timeline-post =path =id:common]
      [%relay-timeline-post from=path =id:common to=(list path)]
      [%create-react =path =react:common]
      [%delete-react =path =id:common]
      [%create-comment =path =comment:common]
      [%delete-comment =path =id:common]
      [%add-forerunners-bedrock force=?]
      [%convert-message =msg-id:cd =msg-part-id:cd to=(list path)]
      [%add-random-emojis ~]
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
  $@  ~
  $%  [%timeline =path]
      [%timeline-post =id:common]
  ==
--
