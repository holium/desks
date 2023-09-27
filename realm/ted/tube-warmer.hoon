:: https://github.com/tinnus-napbus/tube-warmer
:: Tube-warming measurably boosts performance where several successive
:: mark conversions happen with high frequency.
::
/-  spider
/+  *strandio
=,  strand=strand:spider
=<
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
;<  =bowl:rand  bind:m  get-bowl
:: accepts a desk as argument; can warm tubes of any desk
::
=/  =desk  (need !<((unit desk) arg))
:: get list of mark file names of hoon files from desk's mar directory
::
;<  paths=(list path)  bind:m  (scry (list path) %ct /[desk]/mar)
=.  paths  (turn (skim (turn paths flop) |=(=path ?=([%hoon *] path))) flop)
:: build the mark files
::
;<  files=(map path vase)  bind:m
  (build-all-files our.bowl desk now.bowl paths)
:: get list of all possible mark conversions (tubes) in the desk
::
=/  mars=(list mars:clay)
  %~  tap  in
  %-  ~(gas in *(set mars:clay))
  %-  zing
  %+  turn  ~(tap by files)
  mark-pairs
:: warm all the tubes
::
;<  ~  bind:m  (read-all-tubes our.bowl desk now.bowl mars)
:: end thread
::
(pure:m !>(~))
::
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
::
++  get-marks
  |=  =vase
  ^-  [grab=(list mark) grow=(list mark)]
  :: if the grab/grow arm exists (slob),
  :: run it (slap) and list its arms (sloe)
  ::
  :-  ?.  (slob %grab -:vase)  ~
      (sloe -:(slap vase [%limb %grab]))
  ?.  (slob %grow -:vase)  ~
  (sloe -:(slap vase [%limb %grow]))
:: remove mar and hoon from /mar/foo/.../bar/hoon
::
++  en-fit
  |=  =path
  ^-  @tas
  =.  path  ?>(?=([%mar *] path) (flop t.path))
  =.  path  ?>(?=([%hoon *] path) (flop t.path))
  (rap 3 (join '-' path))
:: takes a mark filepath name
:: and the corresponding mark core as a vase
:: returns pairs
::   - from mark to grab arms
::   - to mark from grow arms
::
++  mark-pairs
  |=  [=path =vase]
  ^-  (list mars:clay)
  =/  fit=@tas  (en-fit path)
  =/  [grab=(list mark) grow=(list mark)]
    (get-marks vase)
  %+  weld  (turn grab |=(=mark [mark fit]))
  (turn grow |=(=mark [fit mark]))
::
++  build-tube-soft
  |=  [[=ship =desk =case] =mars:clay]
  =/  m  (strand ,(unit tube:clay))
  ^-  form:m
  :: Presumably, when you ask for this tube it is built
  :: and cached until the next desk commit...
  :: To "warm" the tube, all you have to do is ask for it.
  ::
  ;<  =riot:clay  bind:m
    (warp ship desk ~ %sing %c case /[a.mars]/[b.mars])
  ?~  riot
    (pure:m ~)
  ?>  =(%tube p.r.u.riot)
  (pure:m `!<(tube:clay q.r.u.riot))
::
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
--
