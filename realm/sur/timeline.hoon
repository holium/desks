/-  common, db, cd=chat-db
|%
+$  cid  @t
::
+$  timeline-post  timeline-post:common
::
+$  timeline
  $:  =path
      curators=(set ship) :: additional permission information?
      posts=(map path timeline-post):: ((mop @ timeline-post) gth) ? :: @ is time in unix-ms
  ==
::
+$  action
  $%  [%create-timeline =path curators=(set ship)]
      [%delete-timeline =path]
      [%create-timeline-post =path post=timeline-post]
      [%delete-timeline-post =path key=path]
      [%add-forerunners force=?]
      [%create-bedrock-timeline =path]
      [%create-bedrock-timeline-post =path req-id=[@p @da] post=timeline-post]
      [%add-forerunners-bedrock force=?]
  ==
::
+$  update  ~
+$  view
  $%  [%messages msgs=messages-table:cd]
      [%types types=(set [term (set cord)])]
      [%timeline =timeline]
      [%timelines timelines=(map path timeline)]
  ==
--
