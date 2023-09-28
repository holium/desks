/+  *timeline-json, cd=chat-db
|_  vyu=view:tl
++  grow
  |%
  ++  noun  vyu
  ++  json
    =,  enjs:format
    %.  vyu
    |=  vyu=view:tl
    ^-  ^json
    %+  frond  -.vyu
    ?-    -.vyu
      %paths  a+(turn paths.vyu path)
      %messages   (messages-table:encode:cd msgs.vyu)
        %types
      :-  %a
      %+  turn  ~(tap in types.vyu) 
      |=  [=term metadata=(set cord)]
      ^-  ^json
      %-  pairs
      :~  term+s/term
          [%metadata a+(turn ~(tap in metadata) (lead %s))]
      ==
    ==
  --
++  grab
  |%
  ++  noun  view:tl
  --
++  grad  %noun
--
