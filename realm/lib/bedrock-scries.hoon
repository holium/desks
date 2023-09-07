/-  bedrock=db, common
|%
++  our-passport
  |=  =bowl:gall
  ^-  passport:common
  =/  r=row:bedrock  (first-common passport-type:common /private bowl)
  ?+  -.data.r  !!
    %passport  +.data.r
  ==
::
++  test-bedrock-path-existence
  |=  [=path =bowl:gall]
  ^-  ?
  .=  %.y
  .^
    @ud
    %gx
    %+  weld
      %+  weld
        /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/loobean/path
      path
    /noun
  ==
::
++  test-bedrock-row-existence
  |=  [=path =type:common id=[s=ship t=@da] =bowl:gall]
  ^-  ?
  .=  %.y
  .^
    @ud
    %gx
    %+  weld
      %+  weld
        /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/loobean/row/(scot %t name.type)/(scot %uv hash.type)/(scot %p s.id)/(scot %da t.id)
      path
    /noun
  ==
::
++  scry-bedrock-path-host
  |=  [=path =bowl:gall]
  ^-  ship
  .^
    ship
    %gx
    %+  weld
      %+  weld
        /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/host/path
      path
    /noun
  ==
::
++  scry-bedrock-path
  |=  [=path =bowl:gall]
  ^-  path-row:bedrock
  =/  fp
    .^  fullpath:bedrock
        %gx
        %+  weld
          %+  weld
            /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/path
          path
        /noun
    ==
  path-row.fp
::
++  scry-first-bedrock-chat
  |=  [=path =bowl:gall]
  ^-  row:bedrock
  (first-common chat-type:common path bowl)
::
++  first-common
  |=  [=type:common =path =bowl:gall]
  ^-  row:bedrock
  =/  rows=(list row:bedrock)
    (all-rows-by-path-type type path bowl)
  (snag 0 rows)
::
++  all-rows-by-path-type
  |=  [=type:common =path =bowl:gall]
  ^-  (list row:bedrock)
  =/  all-rows=[=type:common pt=pathed-table:bedrock =schemas:bedrock]
    .^
      [=type:common pt=pathed-table:bedrock =schemas:bedrock]
      %gx
      %+  weld
        %+  weld
          /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/table-by-path/(scot %tas name.type)/(scot %uv hash.type)
        path
      /noun
    ==
  ~(val by (~(got by pt.all-rows) path))
::
++  get-friend
  |=  [=ship =bowl:gall]
  ^-  [=id:common =friend:common]
  =/  rows=(list row:bedrock)  (all-rows-by-path-type friend-type:common /private bowl)
  =/  r=row:bedrock
    %+  snag  0
    %+  skim  rows
    |=  r=row:bedrock
    ^-  ?
    ?+  -.data.r  !!
      %friend  =(ship.data.r ship)
    ==
  :-  id.r
  ?+  -.data.r  !!
    %friend  +.data.r
  ==
::
++  is-friend
  |=  [=ship =bowl:gall]
  ^-  ?
  =/  rows=(list row:bedrock)
    %+  skim  rows
      (all-rows-by-path-type friend-type:common /private bowl)
    |=  r=row:bedrock
    ^-  ?
    ?+  -.data.r  !!
      %friend  =(ship.data.r ship)
    ==
  ?.  (gth (lent rows) 0)  %.n
  =/  r=row:bedrock  (snag 0 rows)
  ?+  -.data.r  %.n
    %friend  =(status.data.r %friend)
  ==
::
++  scry-bedrock-message
  |=  [id=[=ship t=@da] =path =bowl:gall]
  ^-  row:bedrock
  =/  rs=[=row:bedrock =schemas:bedrock]
    .^
      [row:bedrock schemas:bedrock]
      %gx
      %+  weld
        %+  weld
          /(scot %p our.bowl)/bedrock/(scot %da now.bowl)
        /row/message/(scot %uv hash:message-type:common)/(scot %p ship.id)/(scot %da t.id)
      /noun
    ==
  row.rs
::

--
