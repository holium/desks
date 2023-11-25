:: https://github.com/tinnus-napbus/tube-warmer
:: Tube-warming measurably boosts performance where several successive
:: mark conversions happen with high frequency.
:: See marks building with: |pass [%c %stir %verb 1]
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
=/  [=desk verb=?]  (need !<((unit [desk ?]) arg))
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
=/  marks=(list mark)  (turn paths en-fit)
=/  mars=(list mars:clay)
  %~  tap  in
  %-  ~(gas in *(set mars:clay))
  %-  zing
  %+  turn  ~(tap by files)
  (mark-pairs (sy marks))
:: warm all the tubes
::
;<  ~  bind:m  (build-all-tubes verb our.bowl desk now.bowl mars)
:: warm all dais
::
;<  ~  bind:m  (build-all-dais verb our.bowl desk now.bowl marks)
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
  |=  marks=(set mark)
  |=  [=path =vase]
  ^-  (list mars:clay)
  =/  fit=mark  (en-fit path)
  =/  [grab=(list mark) grow=(list mark)]
    (get-marks vase)
  ;:  weld  [fit fit]~
    (murn grab |=(=mark ?.((~(has in marks) mark) ~ `[mark fit])))
    (murn grow |=(=mark ?.((~(has in marks) mark) ~ `[fit mark])))
  ==
::
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
::
++  build-dais-soft
  |=  [[=ship =desk =case] mak=mark]
  =/  m  (strand ,(unit dais:clay))
  ^-  form:m
  ;<  =riot:clay  bind:m
    (warp ship desk ~ %sing %b case /[mak])
  ?~  riot
    (pure:m ~)
  ?>  =(%dais p.r.u.riot)
  (pure:m `!<(dais:clay q.r.u.riot))
::
++  build-all-tubes
  |=  [verb=? our=@p des=desk now=@da mars=(list mars:clay)]
  |-
  =/  m  (strand ,~)
  ^-  form:m
  =*  loop  $
  ?~  mars  (pure:m ~)
  ;<  tub=(unit tube:clay)  bind:m
    (build-tube-soft [our des da+now] i.mars)
  ?~  tub
    ~?  >>>  verb  [%build-tube-failed i.mars]
    loop(mars t.mars)
  ~?  >  verb  [%built-tube i.mars]
  loop(mars t.mars)
::
++  build-all-dais
  |=  [verb=? our=@p des=desk now=@da marks=(list mark)]
  |-
  =/  m  (strand ,~)
  ^-  form:m
  =*  loop  $
  ?~  marks  (pure:m ~)
  ;<  das=(unit dais:clay)  bind:m
    (build-dais-soft [our des da+now] i.marks)
  ?~  das
    ~?  >>>  verb  [%build-dais-failed i.marks]
    loop(marks t.marks)
  ~?  >  verb  [%built-dais i.marks]
  loop(marks t.marks)
--
