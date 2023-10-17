/-  spider, db
/+  *strandio, *ventio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
;<  our=@p     bind:m  get-our
;<  =tid:rand  bind:m  get-tid
~&  [%tid tid]
;<  ~          bind:m  (watch /db/common [our %bedrock] /db/common)
|-
;<  fak=(unit cage)  bind:m  (take-fact-or-kick /db/common)
?~  fak  ~&(%kicked (pure:m !>(~)))
?.  ?=(%db-changes p.u.fak)
  ~&(%unexpected-fact $)
~&(ted-watch+!<(db-changes:db q.u.fak) $)
