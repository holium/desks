/-  store=realm-beacon, h=hark
=<  [store .]
=,  store
|%
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~
          [%saw-note note]
          [%saw-inbox seam]
          [%saw-all ul]
      ==
    ::
    ++  note
      %-  ot
      [%id id]~
    ::
    ++  seam
    %-  of
    :~  all/ul
        desk/so
        group/flag
    ==
    ++  flag  (su ;~((glue fas) ;~(pfix sig fed:ag) ^sym))
    ::
    ++  slan  |=(mod=@tas |=(txt=@ta (need (slaw mod txt))))
    ::
    ++  id
      ^-  $-(json @uvH)
      (cu (slan %uv) so)
    --
  --
::
::  json
::
++  enjs
  =,  enjs:format
  |%
  ++  reaction
    |=  rct=^reaction
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.rct
    ?-  -.rct
        %seen
      %-  pairs
      :~  id/s/(scot %uv id.rct)
      ==
        %seen-inbox
        %-  pairs
        :~  
          desk/s/des.rope.rct
          inbox/s/(spat ted.rope.rct)
          :: group/?~(gop.r ~ s/(flag u.gop.r))
          :: channel/?~(can.r ~ s/(nest u.can.r))
        ==
      ::
        %new-note
      %-  pairs
      :~  id/s/(scot %uv id.note.rct)
          desk/s/desk.note.rct
          inbox/s/inbox.note.rct
          content/a/(turn content.note.rct content-js:encode)
          type/s/type.note.rct
          time/(time time.note.rct)
          seen/b/%.n
      ==
    ==
  ::
  ++  view  :: encodes for on-peek
    |=  vi=view:store
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.vi
    ?-  -.vi
      ::
        %all
      (notes-js:encode notes.vi)
      ::
        %seen
      (notes-js:encode notes.vi)
      ::
        %unseen
      (notes-js:encode notes.vi)
      ::
    ==
  --
::
++  encode
  =,  enjs:format
  |%
  ::
  ++  notes-js
    |=  ns=(map id:h note:store)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by ns)
    |=  [i=id:h n=note:store]
    [(scot %uv i) (note-js n)]
  ::
  ++  note-js
    |=  n=note:store
    ^-  json
    %-  pairs
    :~  id/s/(scot %uv id.n)
        desk/s/desk.n
        inbox/s/inbox.n
        content/a/(turn content.n content-js)
        type/s/type.n
        time/(time time.n)
        seen/b/seen.n
    ==
  ::
  ++  content-js
    |=  c=content:h
    ^-  json
    ?@  c  (frond text/s/c)
    ?-  -.c
      %ship  (frond ship/s/(scot %p p.c))
      %emph  (frond emph/s/p.c)
    ==
  --
--
