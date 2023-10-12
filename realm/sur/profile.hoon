|%
+$  action
  $%
      [%save-opengraph-image =req-id img=@t]
  ==
+$  interaction
  $%
      [%register =ship]
      [%update-available arg=(unit ship)]
      [%start-download ~]
      [%update-files toc=(map path mime)] :: key=path data=mime]
      [%end-download ~]
      :: [%update-crux arg=(unit @t)]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%ack ~]
  ==
--