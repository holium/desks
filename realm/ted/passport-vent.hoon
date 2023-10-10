:: the point of this is to give js clients a await api.thread({ ... })
:: call they can more conveniently use to get back an actual response
:: from their "poke" instead of the stupid urbit CQRS model
:: it will give back the id of the `%create`ed object
/-  spider, passport
/+  *strandio
|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit action:passport)  !<((unit action:passport) arg)
?~  axn  (strand-fail %no-arg ~)
?.  ?|  ?=(%get -.u.axn)
        ?=(%get-as-row -.u.axn)
        ?=(%get-contact -.u.axn)
        ?=(%add-friend -.u.axn)
        ?=(%cancel-friend-request -.u.axn)
        ?=(%handle-friend-request -.u.axn)
        ?=(%add-link -.u.axn)
        ?=(%change-passport -.u.axn)
        ?=(%change-contact -.u.axn)
    ==
    (strand-fail %bad-action ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  =wire  /vent/(scot %p our)/(scot %da now)

?+  -.u.axn  (strand-fail %type-not-supported ~)
  %get-as-row
    ;<  ~  bind:m  (watch wire [src.req-id.u.axn %passport] wire)
    ;<  ~  bind:m  (poke [src.req-id.u.axn %passport] passport-action+!>([%get-as-row [our now]]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %get
    ;<  ~  bind:m  (watch wire [src.req-id.u.axn %passport] wire)
    ;<  ~  bind:m  (poke [src.req-id.u.axn %passport] passport-action+!>([%get [our now]]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %get-contact
    ;<  ~  bind:m  (watch wire [src.req-id.u.axn %passport] wire)
    ;<  ~  bind:m  (poke [src.req-id.u.axn %passport] passport-action+!>([%get-contact [our now]]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %add-friend
    ;<  ~  bind:m  (watch wire [our %bedrock] wire)  :: IMPORTANT that this subs to bedrock, not passport
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%add-friend [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %cancel-friend-request
    ;<  ~  bind:m  (watch wire [our %passport] wire)
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%cancel-friend-request [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %handle-friend-request
    ;<  ~  bind:m  (watch wire [our %passport] wire)
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%handle-friend-request [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %add-link
    ;<  ~  bind:m  (watch wire [our %passport] wire)
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%add-link [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %change-passport
    ;<  ~  bind:m  (watch wire [our %passport] wire)
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%change-passport [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %change-contact
    ;<  ~  bind:m  (watch wire [our %passport] wire)
    ;<  ~  bind:m  (poke [our %passport] passport-action+!>([%change-contact [our now] +>.u.axn]))
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
