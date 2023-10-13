:: -realm!send-all-contacts ~bus
/-  spider
/+  *strandio, passport

|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit @p)  !<((unit @p) arg)
?~  axn  (strand-fail %no-arg ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  bol=bowl:gall  *bowl:gall
=.  our.bol  our
=.  now.bol  now
~&  >>>  "starting send-all-contacts {<now>}"
;<  ~   bind:m  (poke [u.axn %passport] passport-action+!>([%receive-contacts (current-contacts:passport bol)]))
(pure:m !>('sent'))
--
