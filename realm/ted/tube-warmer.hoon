:: https://github.com/tinnus-napbus/tube-warmer
::
/-  spider
/+  *strandio
=,  strand=strand:spider
|%
++  build-all-files
  |=  [our=@p des=desk now=@da paths=(list path)]
  =|  cores=(map path vase)
  |-
  =/  m  (strand ,(map path vase))
  ^-  form:m
  =*  loop  $
  ?~  paths  (pure:m cores)
  ;<  vus=(unit vase)  bind:m  (build-file [our des da+now] i.paths)
  ?~  vus  loop(paths t.paths)
  loop(cores (~(put by cores) i.paths u.vus), paths t.paths)
++  get-marks
  |=  =vase
  ^-  [grab=(list mark) grow=(list mark)]
  :-  ?.  (slob %grab -:vase)  ~
      (sloe -:(slap vase [%limb %grab]))
  ?.  (slob %grow -:vase)  ~
  (sloe -:(slap vase [%limb %grow]))
++  mark-pairs
  |=  [=path =vase]
  ^-  (list mars:clay)
  =/  fit=@tas  (en-fit path)
  =/  [grab=(list mark) grow=(list mark)]
    (get-marks vase)
  %+  weld  (turn grab |=(=mark [mark fit]))
  (turn grow |=(=mark [fit mark]))
++  en-fit
  |=  =path
  ^-  @tas
  =.  path  ?>(?=([%mar *] path) (flop t.path))
  =.  path  ?>(?=([%hoon *] path) (flop t.path))
  (rap 3 (join '-' path))
++  read-all-tubes
  |=  [our=@p des=desk now=@da mars=(list mars:clay)]
  |-
  =/  m  (strand ,~)
  ^-  form:m
  =*  loop  $
  ?~  mars  (pure:m ~)
  ;<  tub=(unit tube:clay)  bind:m  (build-tube-soft [our des da+now] i.mars)
  ?~  tub
    ~&  >>>  [%build-tube-failed i.mars]
    loop(mars t.mars)
  ~&  >  [%built-tube i.mars]
  loop(mars t.mars)
++  build-tube-soft
  |=  [[=ship =desk =case] =mars:clay]
  =/  m  (strand ,(unit tube:clay))
  ^-  form:m
  ;<  =riot:clay  bind:m
    (warp ship desk ~ %sing %c case /[a.mars]/[b.mars])
  ?~  riot
    (pure:m ~)
  ?>  =(%tube p.r.u.riot)
  (pure:m `!<(tube:clay q.r.u.riot))
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  =desk  (need !<((unit desk) arg))
;<  paths=(list path)  bind:m  (scry (list path) %ct /[desk]/mar)
=.  paths  (turn (skim (turn paths flop) |=(=path ?=([%hoon *] path))) flop)
;<  =bowl:rand  bind:m  get-bowl
;<  files=(map path vase)  bind:m
  (build-all-files our.bowl desk now.bowl paths)
=/  mars=(list mars:clay)
  %~  tap  in
  (~(gas in *(set mars:clay)) (zing (turn ~(tap by files) mark-pairs)))
;<  ~  bind:m  (read-all-tubes our.bowl desk now.bowl mars)
(pure:m !>(~))
