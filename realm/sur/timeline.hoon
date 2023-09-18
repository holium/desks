/-  common, db, cd=chat-db
|%
+$  cid  @t
::
+$  timeline-post  timeline-post:common
::
+$  action
  :: Relay a timeline post from one timeline to another
  :: React to a timeline post
  ::
  $%  [%create-timeline name=@ta]
      [%delete-timeline name=@ta]
      [%follow-timeline =path]
      [%handle-follow-request name=@ta]
      [%leave-timeline =path]
      [%handle-leave-request name=@ta]
      :: [%relay-timeline-post from=path =id:common to=path]
      [%create-timeline-post =path post=timeline-post]
      [%delete-timeline-post =path =id:common]
      [%add-forerunners-bedrock force=?]
      [%add-random-emojis ~]
  ==
::
+$  update  ~
+$  view
  $%  [%messages msgs=messages-table:cd]
      [%types types=(set [term (set cord)])]
  ==
--
