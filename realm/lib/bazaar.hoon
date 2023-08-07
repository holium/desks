/-  store=bazaar-store, spaces-store, docket=bazaar-docket, treaty=bazaar-treaty
/+  docket-lib=docket, realm=realm
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
          [%pin add-pin]
          [%unpin rem-pin]
          [%reorder-pins reorder-pins]
          [%recommend add-rec]
          [%unrecommend rem-rec]
          [%suite-add suite-add]
          [%suite-remove suite-remove]
          [%install-app install-app]
          [%uninstall-app uninstall-app]
          [%reorder-app reorder-app]
          [%initialize ul]
          [%rebuild-catalog ul]
          [%rebuild-stall rebuild-stall]
          [%clear-stall clear-stall]
          [%set-host set-host]
          [%delete-catalog-entry del-cat-entry]
          [%add-catalog-entry add-cat-entry]
      ==
    ::
    ++  install-app
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
          [%desk so]
      ==
    ::
    ++  uninstall-app
      %-  ot
      :~  [%desk so]
      ==
    ::
    ++  reorder-app
      %-  ot
      :~  [%desk so]
          [%index ni]
      ==
    ::
    ++  add-pin
      %-  ot
      :~  [%path pth]
          [%app-id so]
          [%index (mu ni)]
      ==
    ::
    ++  rem-pin
      %-  ot
      :~  [%path pth]
          [%app-id so]
      ==
    ::
    ++  reorder-pins
      %-  ot
      :~  [%path pth]
          [%dock (ar so)]
      ==
    ::
    ++  add-rec
      %-  ot
      :~  [%app-id so]
      ==
    ::
    ++  rem-rec
      %-  ot
      :~  [%app-id so]
      ==
    ::
    ++  suite-add
      %-  ot
      :~  [%path pth]
          [%app-id so]
          [%index ni]
      ==
    ::
    ++  suite-remove
      %-  ot
      :~  [%path pth]
          [%index ni]
      ==
    ::
    ++  pth
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
          [%space so]
      ==
    ::
    ++  rebuild-stall
      %-  ot
      :~  [%path pth]
          [%args ul]
      ==
    ::
    ++  clear-stall
      %-  ot
      :~  [%path pth]
          [%args ul]
      ==
    ::
    ++  set-host
      %-  ot
      :~  [%app-id so]
          [%host (su ;~(pfix sig fed:ag))]
      ==
    ::
    ++  del-cat-entry
      %-  ot
      :~  [%app-id so]
      ==
    ::
    ++  add-cat-entry
      %-  ot
      :~  [%app-id so]
          [%native-app native-app]
      ==
      :: %-  of
      :: :~  [%native native-app]
      ::     [%web ~]                :: currently not supported
      ::     [%urbit ~]              :: currently not supported
      :: ==
    ::
    ++  native-app
      %-  ot
      :~  [%title so]
          [%info so]
          [%color so]
          [%icon so]
          [%config cfg]
      ==
    ::
    ++  cfg
      %-  ot
      :~  [%size (at ~[ni ni])]
          [%titlebar-border bo]
          [%show-titlebar bo]
      ==
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
      ::
        %initial
      %-  pairs
      :~  [%catalog (catalog-js:encode catalog.rct)]
          [%stalls (stalls-js:encode stalls.rct)]
          [%docks (docks-js:encode docks.rct)]
          [%recommendations a+(turn ~(tap in recommendations.rct) |=(=app-id:store s+app-id))]
          [%grid (grid-index-js:encode grid-index.rct)]
      ==
      ::
        %app-install-update
      (urbit-app-update:encode app-id.rct urbit-app.rct grid-index.rct)
      ::
        %dock-update
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%dock a+(turn dock.rct |=(=app-id:store s+app-id))]
      ==
      ::
        %recommended
      %-  pairs
      :~  [%id s+app-id.rct]
          [%stalls (stalls-js:encode stalls.rct)]
      ==
      ::
        %unrecommended
      %-  pairs
      :~  [%id s+app-id.rct]
          [%stalls (stalls-js:encode stalls.rct)]
      ==
    ::
        %suite-added
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%id s+app-id.rct]
          [%app (app-detail:encode app-id.rct app.rct)]
          [%index (numb index.rct)]
      ==
      ::
        %suite-removed
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%index (numb index.rct)]
      ==
      ::
        %joined-bazaar
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%catalog (catalog-js:encode catalog.rct)]
          [%stall (stall-js:encode stall.rct)]
      ==
      ::
        %stall-update
      =/  data=(list [@tas json])
          ?~  det.rct         [%none ~]~
          ?~  app.u.det.rct   [%remove-app s+app-id.u.det.rct]~
          [%add-app (app-detail:encode app-id.u.det.rct (need app.u.det.rct))]~
      =/  data
        %+  weld  data
        ^-  (list [@tas json])
        :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
            [%stall (stall-js:encode stall.rct)]
        ==
      %-  pairs
      data
      ::
        %treaties-loaded
      %-  pairs
      :~  [%ship s+(scot %p ship.rct)]
      ==
      ::
        %new-ally
      %-  pairs
      :~  [%ship s+(scot %p ship.rct)]
          [%desks (alliance:encode alliance.rct)]
      ==
      ::
        %ally-deleted
      %-  pairs
      :~  [%ship s+(scot %p ship.rct)]
      ==
      ::
      ::   %treaty-added
      :: :-  %treaty-added
      :: %-  pairs
      :: :~  [%ship s+(crip "{<ship.rct>}")]
      ::     [%desk s+desk.rct]
      ::     [%docket (dkt:encode docket.rct)]
      :: ==
        %rebuild-catalog
      %-  pairs
      :~  [%catalog (catalog-js:encode catalog.rct)]
          [%grid (grid-index-js:encode grid-index.rct)]
      ==
      ::
        %rebuild-stall
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
          [%catalog (catalog-js:encode catalog.rct)]
          [%stall (stall-js:encode stall.rct)]
      ==
      ::
        %clear-stall
      %-  pairs
      :~  [%path s+(spat /(scot %p ship.path.rct)/(scot %tas space.path.rct))]
      ==
      ::
        %reorder-grid-index
      %-  pairs
      :~  [%grid (grid-index-js:encode grid-index.rct)]
      ==
      ::
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
        %catalog
      (catalog-js:encode catalog.vi)
      ::
        %installed
      (catalog-js:encode catalog.vi)
      ::
        %allies
      (allies-js:encode allies.vi)
      ::
        %treaties
      (treaty-map:encode treaties.vi)
      ::
        %app-hash
      s+(scot %uv hash.vi)
      ::
        %version
      (version:encode version.vi)
      ::
    ==
  --
::
++  encode
  =,  enjs:format
  |%
  ::
  ++  grid-index-js
    |=  =grid-index:store
    ^-  json
    %-  pairs
    %+  turn  ~(tap by grid-index)
      |=  [idx=@ud desk=@tas]
      ^-  [cord json]
      [(cord (scot %ud idx)) s+(scot %tas desk)]
  ::
  ++  urbit-app-update
    |=  [=app-id app=urbit-app:store =grid-index:store]
    ^-  json
    %-  pairs
    :~  ['appId' s+app-id]
        ['app' (urbit-app:encode app-id app)]
        ['grid' (grid-index-js:encode grid-index)]
    ==
  ::
  ++  merge
    |=  [a=json b=json]
    ^-  json
    ?>  &(?=(%o -.a) ?=(%o -.b))
    [%o (~(uni by p.a) p.b)]
  ::
  ++  stalls-js
    |=  =stalls:store
    ^-  json
    %-  pairs
    %+  turn  ~(tap by stalls)
      |=  [pth=space-path:spaces-store =stall:store]
      =/  spc-path      (spat /(scot %p ship.pth)/(scot %tas space.pth))
      ^-  [cord json]
      [spc-path (stall-js:encode stall)]
  ::
  ++  stall-js
    |=  =stall:store
    ^-  json
    %-  pairs
    :~  ['suite' (suite-js:encode suite.stall)]
        ['recommended' (recommended-js:encode recommended.stall)]
    ==
  ::
  ++  docks-js
    |=  =docks:store
    ^-  json
    %-  pairs
    %+  turn  ~(tap by docks)
      |=  [pth=space-path:spaces-store =dock:store]
      =/  spc-path      (spat /(scot %p ship.pth)/(scot %tas space.pth))
      ^-  [cord json]
      [spc-path a+(turn dock |=(=app-id:store s+app-id))]
  ::
  ++  suite-js
    |=  =suite:store
    ^-  json
    %-  pairs
    %+  turn  ~(tap by suite)
      |=  [index=@ud =app-id:store]
      ^-  [cord json]
      [(scot %ud index) s+(cord app-id)]
  ::
  ++  recommended-js
    |=  =recommended:store
    ^-  json
    %-  pairs
    ::  TODO sort and only return the last 4
    %+  turn  ~(tap by recommended)
      |=  [=app-id:store =member-set:store]
      ^-  [cord json]
      [app-id (numb ~(wyt in member-set))]
  ::
  ++  catalog-js
    |=  [=catalog:store]
    ^-  json
    %-  pairs
    %+  turn  ~(tap by catalog)
      |=  [=app-id:store app=app:store]
      ^-  [cord json]
      [app-id (app-detail:encode app-id app)]
  ::
  ++  app-detail
    |=  [=app-id:store =app:store]
    ?-  -.app
      ::
      %native
        ^-  json
        %-  pairs
        :~  ['id' s+app-id]
            ['type' s+%native]
            ['title' s+title.native-app.app]
            ['info' s+info.native-app.app]
            ['color' s+color.native-app.app]
            ['icon' s+icon.native-app.app]
            ['config' (config:enjs:realm config.native-app.app)]
        ==
      ::
      %web
        ^-  json
        %-  pairs
        :~  ['id' s+app-id]
            ['title' s+title.web-app.app]
            ['href' s+href.web-app.app]
            ['favicon' s+favicon.web-app.app]
            ['config' (config:enjs:realm config.web-app.app)]
        ==
      ::
      %urbit   (urbit-app:encode app-id +.app)
      ::
    ==
  ::
  ++  urbit-app
    |=  [=app-id app=urbit-app:store]
    %+  merge  (dkt docket.app)
    %-  pairs
    :~
      ['id' s+app-id]
      ['installStatus' [%s `@t`install-status.app]]
      ['config' (config:enjs:realm config.app)]
      ['host' ?~(host.app ~ s+(scot %p u.host.app))]
    ==
  ::
  ++  dkt
    |=  [=docket:docket]
    ^-  json
    %-  pairs
    :~  type+s+%urbit
        title+s+title.docket
        info+s+info.docket
        color+s+(scot %ux color.docket)
        href+(href href.docket)
        image+?~(image.docket ~ s+u.image.docket)
        version+(version version.docket)
        license+s+license.docket
        website+s+website.docket
    ==
  ::
  ++  href
    |=  h=href:docket
    %+  frond  -.h
    ?-    -.h
        %site  s+(spat path.h)
        %glob
      %-  pairs
      :~  base+s+base.h
          glob-reference+(glob-reference glob-reference.h)
      ==
    ==
  ::
  ++  glob-reference
    |=  ref=glob-reference:docket
    %-  pairs
    :~  hash+s+(scot %uv hash.ref)
        location+(glob-location location.ref)
    ==
  ::
  ++  glob-location
    |=  loc=glob-location:docket
    ^-  json
    %+  frond  -.loc
    ?-  -.loc
      %http  s+url.loc
      %ames  s+(scot %p ship.loc)
    ==
  ::
  ++  version
    |=  v=version:docket
    ^-  json
    :-  %s
    %-  crip
    "{(num major.v)}.{(num minor.v)}.{(num patch.v)}"
  ::
  ++  num
    |=  a=@u
    ^-  ^tape
    =/  p=json  (numb a)
    ?>  ?=(%n -.p)
    (trip p.p)
  ::
  ++  allies-js
    |=  =allies:ally:treaty
    ^-  json
    %-  pairs
      %+  turn  ~(tap by allies)
      |=  [s=^ship a=alliance:treaty]
      [(scot %p s) (alliance a)]
  ::
  ++  treaty-map
    |=  t-map=(map [=^ship =desk] =treaty:treaty)
    ^-  json
    %-  pairs
    %+  turn  ~(tap by t-map)
      |=  [[s=^ship =desk] t=treaty:treaty]
      [(foreign-desk s desk) (treaty-js t)]
  ::
  ++  treaty-js
    |=  t=treaty:treaty
    ^-  json
    %+  merge  (dkt docket.t)
    %-  pairs
    :~  ['ship' s+(scot %p ship.t)]
        ['desk' s+desk.t]
        ['cass' (case case.t)]
        ['hash' s+(scot %uv hash.t)]
    ==
  ::
  ++  foreign-desk
    |=  [s=^ship =desk]
    ^-  cord
    (crip "{(scow %p s)}/{(trip desk)}")
  ::
  ++  case
    |=  c=^case
    %+  frond  -.c
    ?-  -.c
      %da   s+(scot %da p.c)
      %tas  s+(scot %tas p.c)
      %ud   (numb p.c)
      %uv   s+(scot %uv p.c)
    ==
  ::
  ++  alliance
    |=  a=alliance:treaty
    ^-  json
    :-  %a
    %+  turn  ~(tap in a)
      |=  [=^ship =desk]
      ^-  json
      s+(foreign-desk ship desk)
  ::
  --
--
