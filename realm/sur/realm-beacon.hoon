/-  hark
|%
::
+$  g-flag  (pair ship term)
+$  g-nest  (pair dude:gall flag)

+$  note
  $:  id=@uvH                         :: note id (from hark)
      desk=@tas
      inbox=cord
      content=(list content:hark)     :: content as markdown (cord)
      time=time                       :: note time sent
      type=?(%hark %realm)
      :: space=(unit space-path)
      seen=?                          :: seen/unseen
  ==
::
+$  action
  $%
      [%saw-note =id:hark]
      [%saw-inbox =seam:hark]
      [%saw-all ~]
  ==
::
+$  reaction
  $%  [%seen =id:hark]
      [%seen-inbox =rope:hark]
      [%new-note =note]
  ==
::
+$  view
  $%  [%all notes=(map id:hark note)]
      [%seen notes=(map id:hark note)]
      [%unseen notes=(map id:hark note)]
  ==
--