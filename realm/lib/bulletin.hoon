/-  store=bulletin
=<  [store .]
=,  store
|%
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
      :~  [%set-provider set-prov]
          [%add-space de-space]
          [%remove-space rem-space]
      ==
    ::
    ++  de-space
      %-  ot
      :~  [%path pth]
          [%name so]
          [%description so]
          [%picture so]
          [%color so]
      ==
    ::
    ++  set-prov
      %-  ot
      [%provider (su ;~(pfix sig fed:ag))]~
    ::
    ++  rem-space
      %-  ot
      [%path pth]~
    ::
    ++  pth
      %-  ot
      :~  [%ship (su ;~(pfix sig fed:ag))]
          [%space so]
      ==
    ::
    --
  --
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
        %initial
      %-  pairs
      [%spaces (spaces-map spaces.rct)]~
        %space-added
      %-  pairs
      [%space (spc space.rct)]~
        %space-removed
      %-  pairs
      [%path s+(pat path.rct)]~
    ==
    ++  spaces-map
      |=  =spaces:store
      ^-  json
      %-  pairs
      %+  turn  ~(tap by spaces)
      |=  [pth=space-path:store space=space-listing:store]
      ^-  [cord json]
      [(pat pth) (spc space)]
    ::
    ++  spc
      |=  space=space-listing:store
      ^-  json
      %-  pairs
      :~  ['path' s+(pat path.space)]
          ['name' s+name.space]
          ['description' s+description.space]
          ['picture' s+picture.space]
          ['color' s+color.space]
      ==
    ::
    ++  pat
      |=  path=space-path:store
      ^-  cord
      (spat /(scot %p ship.path)/(scot %tas space.path))
  --
::
--
