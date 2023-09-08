/-  tl=timeline, common
|%
++  enjs
  =,  enjs:format
  |%
  ++  en-id
    |=  =id:common
    ^-  json
    s+(spat /(scot %p ship.id)/(scot %da t.id))
  ::
  ++  en-type
    |=  =type:common
    ^-  json
    s+(spat /[name.type]/(scot %uv hash.type))
  ::
  ++  parent
    |=  =parent:tl
    ^-  json
    %-  pairs
    :~  [%type (en-type type.parent)]
        [%id (en-id id.parent)]
        [%path (path path.parent)]
    ==
  ::
  ++  app
    |=  =app:tl
    ^-  json
    %-  pairs
    :~  [%name s+name.app]
        [%icon s+icon.app]
        [%action s+action.app]
    ==
  ::
  ++  block
    |=  =block:tl
    |^  ^-  json
    ?-  -.block
      %text  (frond %text (text +.block))
      %link  (frond %link (link +.block))
    ==
    ++  text
      |=  =text:block:tl
      ^-  json
      %-  pairs
      :~  [%text s+text.text]
          [%size s+size.text]
          [%weight s+weight.text]
          [%style s+style.text]
      ==
    ++  link
      |=  =link:block:tl
      |^  ^-  json
      %-  pairs
      :~  [%url s+url.link]
          [%metadata (metadata metadata.link)]
      ==
      ++  metadata
        |=  =metadata:link:block:tl
        |^  ^-  json
        %+  frond  -.metadata
        ?-  -.metadata
          %image  (image +.metadata)
          %video  (video +.metadata)
          %audio  (audio +.metadata)
          %file   (file +.metadata)
          %link   (link +.metadata)
          %misc   (misc +.metadata)
        ==
        ++  image
          |=  =image:metadata:link:block:tl
          ^-  json
          %+  frond  %size
          %-  pairs
          :~  [%width ?~(width.image ~ (numb u.width.image))]
              [%height ?~(height.image ~ (numb u.height.image))]
          ==
        ++  video
          |=  =video:metadata:link:block:tl
          ^-  json
          %-  pairs
          :~  [%type s+type.video]
              [%orientation ?~(orientation.video ~ s+u.orientation.video)]
          ==
        ++  audio  _~
        ++  file   _~
        ++  link
          |=  =link:metadata:link:block:tl
          ^-  json
          %+  frond  -.link
          ?-    -.link
            %raw  ~
            ::
              %opengraph
            %-  pairs
            :~  [%description ?~(description.link ~ s+u.description.link)]
                [%image ?~(image.link ~ s+u.image.link)]
                [%site-name ?~(site-name.link ~ s+u.site-name.link)]
                [%title ?~(title.link ~ s+u.title.link)]
                [%type ?~(type.link ~ s+u.type.link)]
                [%author ?~(author.link ~ s+u.author.link)]
            ==
          ==
        ::
        ++  misc
          |=  =misc:metadata:link:block:tl
          ^-  json
          :-  %o
          %-  malt
          %+  turn  ~(tap by misc)
          |=([k=@t v=@t] [k s+v])
        --
      --
    --
  ++  blocks  |=(blocks=(list block:tl) `json`a+(turn blocks block))
  ++  timeline-post
    |=  post=timeline-post:tl
    ^-  json
    %-  pairs
    :~  [%parent ?~(parent.post ~ (parent u.parent.post))]
        [%app ?~(app.post ~ (app u.app.post))]
        [%blocks a+(turn blocks.post block)]
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
  :: taken from /lib/db.hoon in realm desk
  ++  de-id
    %+  cu
      path-to-id
    pa
  ::
  ++  path-to-id
    |=  p=path
    ^-  id:common
    [`@p`(slav %p +2:p) `@da`(slav %da +6:p)]
  ::
  ++  de-type
    %+  cu
      path-to-type
    pa
  ::
  ++  path-to-type
    |=  p=path
    ^-  type:common
    [`@tas`(slav %tas +2:p) `@uvH`(slav %uv +6:p)]
  ::
  ++  parent
    ^-  $-(json parent:tl)
    %-  ot
    :~  [%type de-type]
        [%id de-id]
        [%path pa]
    ==
  ::
  ++  app
    ^-  $-(json app:tl)
    %-  ot
    :~  name+so
        icon+so
        action+so
    ==
  ::
  ++  block
    =<  block
    |%
    ++  block
      ^-  $-(json block:tl)
      %-  of
      :~  text+text
          link+link
      ==
    ::
    ++  text
      ^-  $-(json text:block:tl)
      %-  ot
      :~  text+so
          size+(cu ?(%sm %md %lg) so)
          weight+(cu ?(%normal %bold) so)
          style+(cu ?(%normal %italic) so)
      ==
    ::
    ++  link
      =<  link
      |%
      ++  link  `$-(json link:block:tl)`(ot ~[url+so metadata+metadata])
      ::
      ++  metadata
        =<  metadata
        |%
        ++  metadata
          ^-  $-(json metadata:link:block:tl)
          %-  of
          :~  [%image image]
              [%video video]
              [%audio audio]
              [%file file]
              [%link link]
              [%misc misc]
          ==
        ++  image
          ^-  $-(json image:metadata:link:block:tl)
          %-  ot
          :~  width+|=(jon=json ?~(jon ~ `(ni jon)))
              height+|=(jon=json ?~(jon ~ `(ni jon)))
          ==
        ::
        ++  video
          ^-  $-(json video:metadata:link:block:tl)
          %-  ot 
          :~  type+(cu ?(%youtube %file) so)
              :-  %orientation
              |=  jon=json
              ?~(jon ~ `((cu ?(%portrait %landscape) so) jon))
          ==
        ::
        ++  audio  ul
        ++  file  ul
        ++  link
          ^-  $-(json link:metadata:link:block:tl)
          %-  of
          :~  [%raw |=(jon=json ?>(?=(~ jon) ~))]
              :-  %opengraph
              %-  ot
              :~  description+|=(jon=json ?~(jon ~ `(so jon)))
                  image+|=(jon=json ?~(jon ~ `(so jon)))
                  site-name+|=(jon=json ?~(jon ~ `(so jon)))
                  title+|=(jon=json ?~(jon ~ `(so jon)))
                  type+|=(jon=json ?~(jon ~ `(so jon)))
                  author+|=(jon=json ?~(jon ~ `(so jon)))
              ==
          ==
        ::
        ++  misc  `$-(json misc:metadata:link:block:tl)`(om so)
        --
      --
    --
  ::
  ++  timeline-post
    ^-  $-(json timeline-post:tl)
    %-  ot
    :~  parent+|=(jon=json ?~(jon ~ `(parent jon)))
        app+|=(jon=json ?~(jon ~ `(app jon)))
        blocks+(ar block)
    ==
  ::
  ++  action
    ^-  $-(json action:tl)
    %-  of
    :~  [%create-timeline (ot ~[path+pa curators+(as (su fed:ag))])]
        [%delete-timeline (ot ~[path+pa])]
        [%create-timeline-post (ot ~[path+pa post+timeline-post])]
        [%delete-timeline-post (ot ~[path+pa key+pa])]
        [%add-forerunners (ot ~[force+bo])]
    ==
  --
--
