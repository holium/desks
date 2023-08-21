/-  bedrock=db
|%

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
  |=  [=path type=@tas id=[s=ship t=@da] =bowl:gall]
  ^-  ?
  .=  %.y
  .^
    @ud
    %gx
    %+  weld
      %+  weld
        /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/loobean/row/(scot %t type)/(scot %p s.id)/(scot %da t.id)
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
  =/  all-chats=[@tas pt=pathed-table:bedrock =schemas:bedrock]
    .^
      [@tas pt=pathed-table:bedrock =schemas:bedrock]
      %gx
      %+  weld
        %+  weld
          /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/table-by-path/chat
        path
      /noun
    ==
  =/  rows=(list row:bedrock)  ~(val by (~(got by pt.all-chats) path))
  (snag 0 rows)
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
        /row/message/(scot %p ship.id)/(scot %da t.id)
      /noun
    ==
  row.rs
::

--
