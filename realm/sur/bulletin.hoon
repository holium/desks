/-  spc=spaces-path
|%
+$  space-path    path:spc
+$  provider      $~(~hostyv ship)
::
+$  space-listing
  $:  path=space-path :: [ship cord]
      name=cord :: cord
      description=cord :: cord
      picture=@t
      color=@t
  ==
::
+$  spaces  (map space-path space-listing)
::
+$  action
  $%  [%set-provider =provider]
      [%add-space space=space-listing]
      [%remove-space path=space-path]
  ==
::
+$  reaction
  $%  [%initial spaces=spaces]
      [%space-added space=space-listing]
      [%space-removed path=space-path]
  ==
::
--
