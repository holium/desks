/-  spaces=spaces-store, docket=bazaar-docket, treaty=bazaar-treaty, *realm
|%
+$  app-id  @tas
+$  native-app
  $:  title=@t
      info=@t
      color=cord
      icon=cord
      =config
  ==
::
+$  web-app
  $:  title=@t
      href=cord
      favicon=cord
      =config
  ==
::
+$  install-status   ?(%started %failed %suspended %installed %uninstalled %desktop %treaty)
+$  urbit-app
  $:  =docket:docket
      host=(unit ship)
      =install-status
      =config
  ==
::
+$  app
  $%  [%native =native-app]
      [%web =web-app]
      [%urbit =docket:docket host=(unit ship) install-status=?(%started %failed %suspended %installed %uninstalled %desktop %treaty) =config]
  ==
::
::  $catalog: for efficiencies sake, this is the one "master" list of apps
::    a ship is aware of; from the apps installed on the ship to apps 'imported'
::    from remote spaces. this is to reduce memory req's for apps that are
::    included across multiple spaces. [app-header] data is referenced to orient an
::    app (tags/ranks) relative to a given space
::
+$  catalog           (map app-id app)
+$  grid-index        (map @ud app-id)  ::  tracks the order of installed apps for our app grid
+$  recommendations   (set app-id)      ::  all of our recommended apps
::
::  $stalls: a stall tracks metadata around the suite and recommended apps
::
+$  member-set        (set ship)
+$  recommended       (map app-id member-set)
+$  suite             (map @ud app-id)
+$  stalls            (map space-path:spaces stall)
+$  stall
  $:  =suite
      =recommended
    ==
::
::  $docks:  tracks the pinned apps per space
::
+$  docks              (map space-path:spaces dock)
+$  dock               (list app-id)
::
+$  action
  $%
      [%pin path=space-path:spaces =app-id index=(unit @ud)]
      [%unpin path=space-path:spaces =app-id]
      [%reorder-pins path=space-path:spaces =dock]
      [%recommend =app-id]
      [%unrecommend =app-id]
      [%suite-add path=space-path:spaces =app-id index=@ud]
      [%suite-remove path=space-path:spaces index=@ud]
      [%install-app =ship =desk]
      [%uninstall-app =desk]
      [%reorder-app =app-id index=@ud]
      [%initialize args=(map cord cord)]
      [%rebuild-catalog args=(map cord cord)]
      [%rebuild-stall path=space-path:spaces args=(map cord cord)]
      [%clear-stall path=space-path:spaces args=(map cord cord)]
      [%set-host app-id=desk host=ship]
      [%delete-catalog-entry =app-id]
      [%add-catalog-entry =app-id =native-app]
  ==
::
+$  interaction
  $%
      [%member-recommend path=space-path:spaces =app-id =app]
      [%member-unrecommend path=space-path:spaces =app-id]
      [%suite-add path=space-path:spaces =app-id =app index=@ud]
  ==
::
+$  reaction
  $%  [%initial =catalog =stalls =docks =recommendations =grid-index]
      [%dock-update path=space-path:spaces =dock]
      [%recommended =app-id =stalls]
      [%unrecommended =app-id =stalls]
      [%suite-added path=space-path:spaces =app-id =app index=@ud]
      [%suite-removed path=space-path:spaces index=@ud]
      [%app-install-update =app-id =urbit-app =grid-index]
      [%joined-bazaar =path:spaces-path:spaces =catalog =stall]
      [%stall-update =path:spaces-path:spaces =stall det=(unit [=app-id app=(unit app)])]
      [%treaties-loaded =ship]
      [%new-ally =ship =alliance:treaty]
      [%ally-deleted =ship]
      [%rebuild-catalog =catalog =grid-index]
      [%rebuild-stall path=space-path:spaces =catalog =stall]
      [%clear-stall path=space-path:spaces]
      [%reorder-grid-index =grid-index]
  ==
+$  view
  $%  [%catalog =catalog]
      [%installed =catalog]
      [%allies =allies:ally:treaty]
      [%treaties treaties=(map [=ship =desk] =treaty:treaty)]
      [%app-hash hash=@uv]
      [%version =version:docket]
  ==
--

