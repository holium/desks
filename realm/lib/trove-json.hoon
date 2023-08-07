/-  *trove
|%
++  enjs
  =,  enjs:format
  |%
  ++  enjs-ship  |=(p=@p `json`((lead %s) (scot %p p)))
  ::
  ++  enta-trail
    |=(t=trail =+(p=(path t) ?>(?=([%s *] p) p.p)))
  ::
  ++  enta-space
    |=(s=space `@t`(rap 3 (scot %p -.s) '/' +.s ~))
  ::
  ++  enta-tope
    |=(t=space `@t`(rap 3 (scot %p -.t) '/' +.t ~))
  ::
  ++  enjs-node
    |=  n=node
    ^-  json
    (pairs ~[type+s/'record' url+s/url.n dat+(enjs-data dat.n)])
  ::
  ++  enjs-tract
    |=  tat=tract
    ^-  json
    %-  pairs
    :~  from+(sect from.tat)
        by+(ship by.tat)
        :-  %files
        =-  o/(malt -)
        %+  turn  ~(tap by +.tat)
        |=  [k=@uv v=node]
        [(scot %uv k) `json`(enjs-node v)]
    ==
  ::
  ++  enjs-trove
    |=  axe=(axal tract)
    ^-  json
    =-  o/(malt -)
    ^-  (list [@t json])
    %+  turn  ~(tap by ~(tar of axe))
    |=  [k=trail v=tract]
    [(enta-trail k) (enjs-tract v)]
  ::
  ++  enjs-troves
    |=  =troves
    ^-  json
    %-  pairs
    %+  turn  ~(tap by troves)
    |=  [=tope trove-data]
    ^-  [@t json]
    :-  (enta-tope tope) 
    %-  pairs
    :~  name+s/name
        perms+(enjs-perms perms) 
        trove+(enjs-trove trove)
    ==
  ::
  ++  enjs-hoard
    |=  hoard=(map space [=banned =troves])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by hoard)
    |=  [=space =banned =troves]
    ^-  [@t json]
    :-  (enta-space space)
    %-  pairs
    :~  banned+a/(turn ~(tap in banned) enjs-ship)
        troves+(enjs-troves troves)
    ==
  ::
  ++  enjs-perms
    |=  =perms
    ^-  json
    %-  pairs
    :~  admins+s/admins.perms
        member+?~(m=member.perms ~ s/m)
        :-  %custom
        %-  pairs
        %+  turn  ~(tap by custom.perms)
        |=  [=^ship r=?(%r %rw)]
        ^-  [@t json]
        [(scot %p ship) s/r]
    ==
  ::
  ++  enjs-data
    |=  dat=fimet
    ^-  json
    %-  pairs
    :~  from+(sect from.dat)
        by+(ship by.dat)
        title+s/title.dat
        description+s/description.dat
        extension+s/extension.dat
        size+s/size.dat
        key+s/key.dat
    ==
  ::
  ++  enjs-view
    |=  =view
    ^-  json
    %+  frond  %view
    %+  frond  -.view
    ?-    -.view
        %hoard   (enjs-hoard hoard.view)
        %troves  (enjs-troves troves.view)
        %trove   (enjs-trove trove.view)
    ==
  ::
  ++  enjs-space-action
    |=  axn=space-action:action
    ^-  json
    %+  frond  -.axn
    ?-    -.axn
        %add-trove
      %-  pairs
      :~  name+s/name.axn
          perms+(enjs-perms perms.axn)
      ==
        %rem-trove
      %-  frond
      tope+s/(enta-tope tope.axn)
        %banned
      %+  frond  %banned
      a/(turn ~(tap in banned.axn) enjs-ship)
    ==
  ::
  ++  enjs-trove-action
    |=  axn=trove-action:action
    ^-  json
    %+  frond  -.axn
    ?+    -.axn  !!
        %reperm
      (frond perms+(enjs-perms perms.axn))
        %edit-name
      (frond name+s/name.axn)
        %add-folder
      (frond trail+s/(enta-trail trail.axn))
        %rem-folder
      (frond trail+s/(enta-trail trail.axn))
        %move-folder
      %-  pairs
      :~  from+s/(enta-trail from.axn)
          to+s/(enta-trail to.axn)
      ==
        %rem-node
      %-  pairs
      :~  trail+s/(enta-trail trail.axn)
          id+s/(scot %uv id.axn)
      ==
        %edit-node
      %-  pairs
      :~  trail+s/(enta-trail trail.axn)
          id+s/(scot %uv id.axn)
          title+?~(tut.axn ~ s/u.tut.axn)
          description+?~(dus.axn ~ s/u.dus.axn)
      ==
        %move-node
      %-  pairs
      :~  from+s/(enta-trail from.axn)
          id+s/(scot %uv id.axn)
          to+s/(enta-trail to.axn)
      ==
    ==
  ::
  ++  enjs-update
    |=  upd=update
    ^-  json
    ?-    -.upd
      %initial  (frond %initial (enjs-hoard hoard.upd))
      ::
        %space
      %-  pairs
      :~  space+s/(enta-space space.upd)
          :-  %update
          ?+    +>-.upd  (enjs-space-action +>.upd)
              %add-trove
            %+  frond  %add-trove
            %-  pairs
            :~  tope+s/(enta-tope tope.upd)
                name+s/name.upd
                perms+(enjs-perms perms.upd)
                trove+(enjs-trove trove.upd)
            ==
              %add-troves
            %+  frond  %add-troves
            %-  pairs
            :~  banned+a/(turn ~(tap in banned.upd) enjs-ship)
                troves+(enjs-troves troves.upd)
            ==
              %rem-troves
            [%s %rem-troves]
          ==
      ==
      ::
        %trove
      %-  pairs
      :~  space+s/(enta-space space.upd)
          tope+s/(enta-tope tope.upd)
          :-  %update
          ?+    +>-.upd  (enjs-trove-action +>.upd)
              %add-node
            %+  frond  %add-node
            %-  pairs
            :~  trail+s/(enta-trail trail.upd)
                id+s/(scot %uv id.upd)
                node+(enjs-node node.upd)
            ==
            ::
              %add-folder
            %+  frond  %add-folder
            %-  pairs
            :~  trail+s/(enta-trail trail.upd)
                tract+(enjs-tract tract.upd)
            ==
          ==
      ==
    ==
  --
++  dejs
  =,  dejs:format
  |%
  ++  space-rule
    ;~  (glue fas)
      ;~(pfix sig fed:ag)
      (cook crip (star prn))
    ==
  ++  tope-rule  space-rule
  ++  rw-rule
    |=  jon=json
    =/  r  ((su ;~(pose (jest %rw) (jest %r))) jon)
    ?>(?=(?(%r %rw) r) r)
  ::
  ++  custom-perms
    |=  jon=json
    ^-  (map ship ?(%r %rw))
    %-  ~(gas by *(map ship ?(%r %rw)))
    %+  turn
      %~  tap  by
      ((om (su ;~(pose (jest %rw) (jest %r)))) jon)
    |=  [s=@t r=@t]
    ^-  [ship ?(%r %rw)]
    ?>  ?=(?(%r %rw) r)
    [(slav %p s) r]
::
  ++  dejs-perms
    ^-  $-(json perms)
    %-  ot
    :~  admins+rw-rule
        member+|=(jon=json ?~(jon ~ (rw-rule jon)))
        custom+custom-perms
    ==
  ::
  ++  dejs-fimet
    ^-  $-(json fimet)
    %-  ot
    :~  from+du
        by+(se %p)
        title+so
        description+so
        extension+so
        size+so
        key+so
    ==
  ::
  ++  dejs-node
    ^-  $-(json node)
    (ot ~[url+so dat+dejs-fimet])
  ::
  ++  space-action
    ^-  $-(json space-action:action)
    %-  of
    :~  :-  %add-trove
        %-  ot
        :~  name+so
            perms+dejs-perms
        ==
        rem-trove+(ot [tope+(su tope-rule)]~)
        banned+(ot [banned+(as (su fed:ag))]~)
    ==
  ::
  ++  trove-action
    ^-  $-(json trove-action:action)
    %-  of
    :~  reperm+(ot ~[perms+dejs-perms])
        edit-name+(ot ~[name+so])
        add-folder+(ot ~[trail+pa])
        rem-folder+(ot ~[trail+pa])
        move-folder+(ot ~[from+pa to+pa])
        :-  %add-node
        %-  ot
        :~  trail+pa
            url+so
            title+so
            description+so
            extension+so
            size+so
            key+so
        ==
        rem-node+(ot ~[trail+pa id+(se %uv)])
        :-  %edit-node
        %-  ot
        :~  trail+pa
            id+(se %uv)
            tut+so:dejs-soft:format
            dus+so:dejs-soft:format
        ==
        move-node+(ot ~[from+pa id+(se %uv) to+pa])
    ==
  ::
  ++  dejs-action
    ^-  $-(json action)
    %-  of
    :~  space+(ot ~[space+(su space-rule) axn+space-action])
        :-  %trove
        %-  ot
        :~  st+(ot ~[space+(su space-rule) tope+(su tope-rule)])
            axn+trove-action
        ==
    ==
  --
--
