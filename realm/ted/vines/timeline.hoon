/-  spider
/+  *ventio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  req=(unit [ship request])  !<((unit [ship request]) arg)
?~  req  (strand-fail %no-arg ~)
=/  [src=ship vid=vent-id =mark =noun]  u.req
;<  =vase         bind:m  (unpage mark noun)
;<  =bowl:spider  bind:m  get-bowl
=/  [our=ship now=@da eny=@uvJ byk=beak]  [our now eny byk]:bowl
::
;<  ~  bind:m  (trace %running-timeline-vine ~)
::
|^
?+    mark  (punt [our %timeline] mark vase) :: poke normally
    %stub
  ~&  %stubbing
  (pure:m !>(~))
==
::
++  sour  (scot %p our)
++  snow  (scot %da now)
--
