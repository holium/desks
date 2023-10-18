/-  bedrock=db, common
|%
++  our-passport
  |=  =bowl:gall
  ^-  passport:common
  =/  r=row:bedrock  (our-passport-row bowl)
  ?+  -.data.r  !!
    %passport  +.data.r
  ==
::
++  our-passport-row
  |=  =bowl:gall
  ^-  row:bedrock
  %+  snag  0
  %+  skim
    (all-rows-by-path-type passport-type:common /private bowl)
  |=  r=row:bedrock  ^-  ?
  ?+  -.data.r  %.n
    %passport  =(ship.contact.data.r our.bowl)
  ==
::
++  our-passport-id
  |=  =bowl:gall
  ^-  id:common
  =/  r=row:bedrock
    %+  snag  0
    %+  skim
      (all-rows-by-path-type passport-type:common /private bowl)
    |=  r=row:bedrock  ^-  ?
    ?+  -.data.r  %.n
      %passport  =(ship.contact.data.r our.bowl)
    ==
  id.r
::
++  our-contact-id
  |=  =bowl:gall
  ^-  id:common
  =/  r=row:bedrock
    %+  snag  0
    %+  skim
      (all-rows-by-path-type contact-type:common /private bowl)
    |=  r=row:bedrock  ^-  ?
    ?+  -.data.r  %.n
      %contact  =(ship.data.r our.bowl)
    ==
  id.r
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
++  test-bedrock-table-existence
  |=  [=type:common =bowl:gall]
  ^-  ?
  .=  %.y
  .^
    @ud
    %gx
    %+  weld
      /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/loobean/table
    :-  name.type
    /(scot %uv hash.type)/noun
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
++  how-many-peers-in-path
  |=  [=path =bowl:gall]
  ^-  @ud
  =/  fp
    .^  fullpath:bedrock
        %gx
        %+  weld
          %+  weld
            /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/path
          path
        /noun
    ==
  (lent peers.fp)
::
++  scry-first-bedrock-chat
  |=  [=path =bowl:gall]
  ^-  (unit row:bedrock)
  =/  all-chats=[=type:common pt=pathed-table:bedrock =schemas:bedrock]
    .^
      [=type:common pt=pathed-table:bedrock =schemas:bedrock]
      %gx
      %+  weld
        %+  weld
          /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/table-by-path/chat/0v0
        path
      /noun
    ==
  =/  chat=(unit table:bedrock)  (~(get by pt.all-chats) path)
  ?~  chat  ~
  =/  rows=(list row:bedrock)  ~(val by u.chat)
  ?:  =(0 (lent rows))  ~
  (some (snag 0 rows))
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
    ;;  [=type:common pt=pathed-table:bedrock =schemas:bedrock]  :: hard-casting for efficeincy?
    .^
      *
      %gx
      %+  weld
        %+  weld
          /(scot %p our.bowl)/bedrock/(scot %da now.bowl)/db/table-by-path/(scot %tas name.type)/(scot %uv hash.type)
        path
      /noun
    ==
  ~(val by (~(got by pt.all-rows) path))
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
++  get-friends
  |=  =bowl:gall
  ^-  (list friend:common)
  ?.  (test-bedrock-table-existence friend-type:common bowl)  ~
  =/  rows=(list row:bedrock)  (all-rows-by-path-type friend-type:common /private bowl)
  %+  turn  rows
  |=  r=row:bedrock
  ^-  friend:common
  ?+  -.data.r  !!
    %friend  +.data.r
  ==
::
++  our-contacts
  |=  =bowl:gall
  :: @da is updated-at
  ^-  (list [id:common @da contact:common])
  ?.  (test-bedrock-table-existence contact-type:common bowl)  ~
  %+  turn
    (all-rows-by-path-type contact-type:common /private bowl)
  |=  r=row:bedrock
  ^-  [id:common @da contact:common]
  ?+  -.data.r  !!
    %contact  [id.r updated-at.r +.data.r]
  ==
::
++  contact-info
  |=  [=ship =bowl:gall]
  ^-  (unit contact:common)
  ?.  (test-bedrock-table-existence contact-type:common bowl)  ~
  =/  rows=(list row:bedrock)
  %+  skim
    (all-rows-by-path-type contact-type:common /private bowl)
  |=  r=row:bedrock  ^-  ?
  ?+  -.data.r  !!
    %contact  =(ship ship.data.r)
  ==
  ?:  =(0 (lent rows))  ~
  =/  r  (snag 0 rows)
  %-  some
  ?+  -.data.r  !!
    %contact  +.data.r
  ==
::
++  is-friend
  |=  [=ship =bowl:gall]
  ^-  ?
  ?.  (test-bedrock-table-existence friend-type:common bowl)  %.n
  =/  rows=(list row:bedrock)
    %+  skim
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
--
