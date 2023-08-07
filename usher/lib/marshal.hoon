/-  store=marshal
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
          [%commit commit]
      ==
    ::
    ++  commit
      %-  ot
      :~  [%mount-point so]
      ==
    --
  --
--