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
  ::
  ++  timeline
    |=  =timeline:tl
    ^-  json
    %-  pairs
    :~  [%path (path path.timeline)]
        [%curators a+(turn ~(tap in curators.timeline) |=(=@p s+(scot %p p)))]
        [%posts (posts posts.timeline)]
    ==
  ::
  ++  timelines
    |=  timelines=(map ^path timeline:tl)
    ^-  json
    :-  %o
    %-  malt
    %+  turn  ~(tap by timelines)
    |=  [k=^path v=timeline:tl]
    ^-  [@t json]
    [(spat k) (timeline v)]
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json action:tl)
    %-  of
    :~  [%create-timeline (ot ~[path+pa curators+(as (su fed:ag))])]
        [%delete-timeline (ot ~[path+pa])]
        :: [%create-timeline-post (ot ~[path+pa post+de-timeline-post:(action):dejs:db])]
        [%delete-timeline-post (ot ~[path+pa key+pa])]
        [%add-forerunners (ot ~[force+bo])]
    ==
  --
--
