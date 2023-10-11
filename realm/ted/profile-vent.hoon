:: the point of this is to give js clients a await api.thread({ ... })
:: call they can more conveniently use to get back an actual response
:: from their "poke" instead of the stupid urbit CQRS model
:: it will give back the id of the `%create`ed object
/-  spider, store=profile
/+  *strandio
|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit action:store)  !<((unit action:store) arg)
?~  axn  (strand-fail %no-arg ~)
?.  ?|  =(%initialize -.u.axn)
        =(%save-opengraph-image -.u.axn)
    ==
    (strand-fail %bad-action ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  =wire  /vent/(scot %p our)/(scot %da now)

?-  -.u.axn
  %save-opengraph-image
    ;<  ~  bind:m  (watch wire [our %profile] wire)
    ;<  ~  bind:m  (poke [our %profile] profile-action+!>([%save-opengraph-image [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))

  %initialize
    ;<  ~  bind:m  (watch wire [our %profile] wire)
    ;<  ~  bind:m  (poke [our %profile] profile-action+!>([%initialize [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
==
::
++  take-fact-or-kick
  |=  =wire
  =/  m  (strand ,(unit cage))
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
    ::
      [~ %agent * %fact *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done (some cage.sign.u.in.tin)]
    ::
      [~ %agent * %kick *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done ~]
  ==
--
