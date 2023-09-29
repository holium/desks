/-  tl=timeline, common, cd=chat-db
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
  ++  vent
    =,  enjs:db
    |=  =vent:tl
    ^-  json
    %-  pairs
    :~  [%printf a+(turn p.vent (lead %s))]
        :-  %vent
        ?~  q.vent  ~
        %+  frond  -.q.vent
        ?-  -.q.vent
          %timeline       (path path.q.vent)
          %timeline-post  (en-row row.q.vent (~(put by *schemas:db) type.row.q.vent schema.q.vent))
          %react          (en-row row.q.vent (~(put by *schemas:db) type.row.q.vent schema.q.vent))
          %comment        (en-row row.q.vent (~(put by *schemas:db) type.row.q.vent schema.q.vent))
        ==
    ==
  --
::
++  dejs
  =,  dejs:format
  =,  action:dejs:db
  |%
  :: since (se %ta) doesn't work...
  ::
  ++  seta  (cu |=(=@t ?>(((sane %ta) t) t)) so)
  ++  msg-id
    %+  cu
      |=  =path
      ^-  msg-id:cd
      ?>  ?=([@ta @ta ~] path)
      [(slav %da i.path) (slav %p i.t.path)]
    pa
  ::
  ++  action
    ^-  $-(json action:tl)
    %-  of
    :~  [%create-timeline (ot ~[name+seta])]
        [%delete-timeline (ot ~[name+seta])]
        [%follow-timeline (ot ~[path+pa])]
        [%leave-timeline (ot ~[path+pa])]
        [%create-timeline-posts (ot ~[path+pa posts+(ar de-timeline-post)])]
        [%create-timeline-post (ot ~[path+pa post+de-timeline-post])]
        [%delete-timeline-post (ot ~[path+pa id+de-id])]
        [%relay-timeline-post (ot ~[from+pa id+de-id to+(ar pa)])]
        [%create-react (ot ~[path+pa react+de-react])]
        [%delete-react (ot ~[path+pa id+de-id])]
        [%create-comment (ot ~[path+pa comment+de-comment])]
        [%delete-comment (ot ~[path+pa id+de-id])]
        [%add-forerunners-bedrock (ot ~[force+bo])]
        [%convert-message (ot ~[msg-id+msg-id msg-part-id+ni to+pa])]
        [%add-random-emojis (ot ~[path+pa])]
    ==
  --
--
