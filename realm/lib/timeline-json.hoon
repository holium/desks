/-  tl=timeline, common
/+  db
|%
++  enjs
  =,  enjs:format
  |%
  ++  timeline-post
    |=  post=timeline-post:tl
    ^-  json
    %-  pairs
    :~  ['parent' ?~(parent.post ~ (parent-to-json:enjs:db u.parent.post))]
        ['app' ?~(app.post ~ (app-to-json:enjs:db u.app.post))]
        ['blocks' a+(turn blocks.post block-to-json:enjs:db)]
    ==
  ::
  ++  posts
    |=  posts=(map ^path timeline-post:tl)
    ^-  json
    :-  %o
    %-  malt
    %+  turn  ~(tap by posts)
    |=  [k=^path v=timeline-post:tl]
    ^-  [@t json]
    [(spat k) (timeline-post v)]
  --
::
++  dejs
  =,  dejs:format
  =,  action:dejs:db
  |%
  :: since (se %ta) doesn't work...
  ::
  ++  seta  (cu |=(=@t ?>(((sane %ta) t) t)) so)
  ++  action
    ^-  $-(json action:tl)
    %-  of
    :~  [%create-timeline (ot ~[name+seta])]
        [%delete-timeline (ot ~[name+seta])]
        [%follow-timeline (ot ~[path+pa])]
        [%leave-timeline (ot ~[path+pa])]
        [%create-timeline-post (ot ~[path+pa post+de-timeline-post])]
        [%delete-timeline-post (ot ~[path+pa id+de-id])]
        [%relay-timeline-post (ot ~[from+pa id+de-id to+(ar pa)])]
    ==
  --
--
