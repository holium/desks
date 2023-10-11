|%
+$  action
  $%
      [%register =req-id =ship]
      [%update-available =req-id parm=(unit ship)]
      [%update-crux =req-id parm=(unit @t)]
      [%save-opengraph-image =req-id img=@t]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%ack ~]
  ==
--