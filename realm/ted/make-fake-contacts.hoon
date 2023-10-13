:: -realm!make-fake-contacts 10
/-  spider, common
/+  *strandio

|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit @ud)  !<((unit @ud) arg)
?~  axn  (strand-fail %no-arg ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  i=@ud  1
|-
  ?:  =(u.axn i)
    (pure:m !>(`@p`i))
  =/  cont=contact:common
  [
    `@p`i
    [~ [%nft nft='https://steamavatar.io/img/1477787732RP7QJ.jpg']]
    [~ '#B17BD7']
    [~ 'Just another test moon']
    [~ 'Paul']
  ]
  ;<  ~   bind:m  (poke [our %bedrock] db-action+!>([%create [our (add now i)] /private contact-type:common [%contact cont] ~]))
  $(i +(i))
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
