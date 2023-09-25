/-  spider
/+  *strandio
|%
+$  vent-id  (pair @p @da)
+$  request  (pair vent-id page)
+$  package
  $:  =dock     :: destination ship/agent
      input=[=desk =mark]  :: mark of input and its location
      output=[=desk =mark] :: mark of output and its location
      body=json :: actual data to send to agent in vent-request
  ==
:: track your vents so you can make unique vent-ids
::
+$  vents  (jug dock vent-id)
::
++  en-path
  |=  vid=vent-id
  ^-  path
  /vent/(scot %p p.vid)/(scot %da q.vid)
::
++  de-path
  |=  =path
  ^-  vent-id
  =+  ;;([%vent p=@ta q=@ta ~] path)
  [(slav %p p.-) (slav %da q.-)]
:: forward vent requests directly to the vine
::
++  to-vine
  |=  [=vase =bowl:gall]
  ^-  card:agent:gall
  =/  [vid=vent-id =mark =noun]  !<(request vase)
  =/  args=cage          noun+!>((some src.bowl vid mark noun))
  :: vine must have same desk and same name as agent in /ted/vines
  ::
  =/  =(fyrd:khan cage)  [q.byk.bowl (cat 3 'vines-' dap.bowl) args]
  [%pass (en-path vid) %arvo %k %fard fyrd]
::
++  en-arow  |*(a=* `sign-arvo`[%khan %arow %& %noun !>(a)])
++  en-eror  |=(=goof `sign-arvo`[%khan %arow %| goof])
::
++  vent-arow
  |=  [=path arow=(avow:khan cage)]
  ^-  (list card:agent:gall)
  =/  vid=vent-id  (de-path path)
  =/  =cage  ?-(-.arow %& p.arow, %| goof+!>(p.arow))
  :~  [%give %fact ~[path] cage]
      [%give %kick ~[path] ~]
  ==
:: translates poke-ack to vent for regular poke
::
++  punt
  |=  [=dock =cage]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  ~  bind:m  (poke dock cage)
  (pure:m !>(~))
::
++  unpackage
  |=  [body=json =desk =mark]
  =/  m  (strand ,page)
  ^-  form:m
  ;<  =tube:clay  bind:m  (scry tube:clay /cc/[desk]/json/[mark])
  (pure:m [mark q:(tube !>(body))])
:: generic thread for vent-based "thread-pokes"
::   flexible but less performant
::   performance issues SIGNIFICANTLY ameliorated with tube-warming:
::     https://github.com/tinnus-napbus/tube-warmer
::   check this with: |pass [%c %stir %verb 1]
:: /ted/venter.hoon
:: /+  *ventio
:: venter
::
++  venter
  =,  strand=strand:spider
  ^-  thread:spider
  |=  arg=vase
  =/  m  (strand ,vase)
  ^-  form:m
  =/  pak=(unit package)  !<((unit package) arg)
  ?~  pak  (strand-fail %no-arg ~)
  =+  u.pak :: expose dock, input, output, and body
  ;<  =page  bind:m  (unpackage body input)
  ((vent-dyn output) dock page)
::
++  vent
  |*  a=mold
  =/  m  (strand ,a)
 :: accept a cage for historical reasons;
 :: nested vases don't do well when converting between marks
 :: so ultimately a page is used instead of a cage here
 ::
  |=  [=dock =cage]
  ^-  form:m
  ;<  =vase  bind:m  (vent-raw dock p.cage q.q.cage)
  (pure:m ;;(a q.vase))
::
++  unpage
  |=  =page
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  byk=beak:spider  bind:m  get-beak
  ;<  =tube:clay       bind:m  (scry tube:clay /cc/[q.byk]/noun/[p.page])
  ;<  ~                bind:m  (trace (cat 3 'mark: ' p.page) ~)
  (pure:m (tube !>(q.page)))
::
++  vent-dyn
  |=  [=desk =mark]
  |=  [=dock =page]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =vase       bind:m  (vent-raw dock page)
  ;<  =tube:clay  bind:m  (scry tube:clay /cc/[desk]/noun/[mark])
  (pure:m (tube vase))
::
++  vent-raw
  |=  [=dock req=page]
  =/  m  (strand ,vase)
  ^-  form:m
  :: get existing vents
  :: 
  ;<  =vents  bind:m  (scry vents /gx/venter/vents/noun)
  :: define the vent id
  ::
  ;<  =bowl:strand  bind:m  get-bowl
  =/  vid=vent-id   (unique-vent dock vents [our now]:bowl)
  :: listen for updates along this path
  ::
  =/  vent-path=path  (en-path vid)
  ;<  ~  bind:m  (watch vent-path dock vent-path)
  :: tally the vent-path
  ::
  ;<  ~  bind:m  (poke [our.bowl %venter] tally-vent+!>([dock vid]))
  :: poke the agent on the destination ship with the vent id and page
  ::
  ;<  ~  bind:m  (poke dock vent-request+!>([vid req]))
  :: take vent update on vent-path
  ::
  ;<  rep=cage  bind:m  (take-fact vent-path)
  ;<  ~         bind:m  (take-kick vent-path)
  :: clear the vent-path
  ::
  ;<  ~  bind:m  (poke [our.bowl %venter] clear-vent+!>([dock vid]))
  ::
  :: return vent result or strand-fail on error
  ::
  ?.  ?=(%goof p.rep)
    (pure:m q.rep)
  (strand-fail !<(goof q.rep))
::
++  unique-vent
  |=  [=dock =vents our=@p now=@da]
  ^-  vent-id
  ?.  (~(has ju vents) dock [our now])
    [our now]
  $(now +(now))
:: miscellaneous utils
::
++  take-special-fact
  |*  [=wire =mark =mold]
  |=  take=$-(mold ?)
  =/  m  (strand ,mold)
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %fact *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    ?.  =(mark p.cage.sign.u.in.tin)
      `[%skip ~]
    =+  !<(a=mold q.cage.sign.u.in.tin)
    ?.  (take a)
      `[%skip ~]
    `[%done a]
  ==
--
