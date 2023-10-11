/-  spider
/+  *strandio
=,  tid=tid:rand
|%
+$  vent-id  (trel @p tid @da)
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
  /vent/(scot %p p.vid)/[q.vid]/(scot %da r.vid)
::
++  de-path
  |=  =path
  ^-  vent-id
  =+  ;;([%vent p=@ta q=@ta r=@ta ~] path)
  [(slav %p p.-) q.- (slav %da r.-)]
:: forward vent requests directly to the vine
::
++  to-vine
  |=  [=vase =bowl:gall]
  ^-  card:agent:gall
  =/  [vid=vent-id =mark =noun]  !<(request vase)
  =/  args=cage          noun+!>((some bowl vid mark noun))
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
++  just-poke
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
  ;<  =tube:clay  bind:m  (build-our-tube desk %json mark)
  (pure:m [mark q:(tube !>(body))])
:: generic thread for vent-based "thread-pokes":
::   flexible but less performant
::   performance issues SIGNIFICANTLY ameliorated with tube-warming:
::     https://github.com/tinnus-napbus/tube-warmer
::   check this with: |pass [%c %stir %verb 1]
:: /ted/vent.hoon
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
  ;<  =page       bind:m  (unpackage body input)
  ;<  =vase       bind:m  ((vent-as-mark output) dock page)
  :: convert to json - this allows for generic
  :: /spider/realm/venter-package/vent/json thread format
  ::
  ;<  =tube:clay  bind:m  (build-our-tube desk.output mark.output %json)
  (pure:m (tube vase))
::
++  vent
  |*  a=mold
  =/  m  (strand ,a)
  |=  [=dock =page]
  ^-  form:m
  ;<  =vase  bind:m  (vent-raw dock p.page q.page)
  (pure:m ;;(a q.vase))
::
++  unpage
  |=  =page
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  byk=beak:spider  bind:m  get-beak
  ;<  =tube:clay       bind:m  (build-our-tube q.byk %noun p.page)
  ;<  ~                bind:m  (trace (cat 3 'mark: ' p.page) ~)
  (pure:m (tube !>(q.page)))
::
++  vent-as-mark
  |=  [=desk =mark]
  |=  [=dock =page]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =vase       bind:m  (vent-raw dock page)
  ;<  =tube:clay  bind:m  (build-our-tube desk %noun mark)
  (pure:m (tube vase))
::
++  vent-soft
  |=  [=dock req=page]
  =/  m  (strand ,thread-result)
  ^-  form:m
  :: get existing vents
  :: 
  ;<  =vents  bind:m  (scry vents /gx/venter/vents/noun)
  :: define the vent id
  ::
  ;<  =bowl:strand  bind:m  get-bowl
  =/  vid=vent-id   (unique-vent dock vents [our tid now]:bowl)
  :: listen for updates along this path
  ::
  =/  vent-path=path  (en-path vid)
  ;<  ~  bind:m  (watch vent-path dock vent-path)
  :: tally the vent-path
  ::
  ;<  ~  bind:m  (poke [our.bowl %venter] tally-vent+!>([dock vid]))
  :: poke the agent on the destination ship with the vent id and page
  ::
  ;<  p=(unit tang)  bind:m  (poke-soft dock vent-request+!>([vid req]))
  ?^  p
    :: clear the vent-path
    ::
    ;<  ~  bind:m  (poke [our.bowl %venter] clear-vent+!>([dock vid]))
    (pure:m %| [%vent-request-poke-fail u.p])
  :: take vent update on vent-path
  ::
  ;<  rep=cage  bind:m  (take-fact vent-path)
  ;<  ~         bind:m  (take-kick vent-path)
  :: clear the vent-path
  ::
  ;<  ~  bind:m  (poke [our.bowl %venter] clear-vent+!>([dock vid]))
  ::
  :: return vent result or error
  ::
  ?.  ?=(%goof p.rep)
    ~?  >>>  !?=(%noun p.rep)
      %venting-unexpected-mark
    (pure:m %& q.rep)
  (pure:m %| !<(goof q.rep))
::
++  vent-raw
  |=  [=dock req=page]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =thread-result  bind:m  (vent-soft dock req)
  ?-  -.thread-result
    %&  (pure:m p.thread-result)
    %|  (strand-fail p.thread-result)
  ==
::
++  unique-vent
  |=  [=dock =vents our=@p =tid now=@da]
  ^-  vent-id
  ?.  (~(has ju vents) dock [our tid now])
    [our tid now]
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
::
++  build-our-tube
  |=  [des=desk =mars:clay]
  =/  m  (strand ,tube:clay)
  ^-  form:m
  ;<  our=ship  bind:m  get-our
  ;<  now=time  bind:m  get-time
  (build-tube [our des da+now] mars)
:: this works -- strandio's +await-thread doesn't seem to...
::
++  run-thread-soft
  |=  [=desk file=term args=vase]
  =/  m  (strand ,thread-result)
  ^-  form:m
  ;<  =bowl:spider  bind:m  get-bowl
  =/  tid  (scot %ta (cat 3 'strand_' (scot %uv (sham desk file eny.bowl))))
  =.  q.byk.bowl  desk
  =/  poke-vase  !>(`start-args:spider`[`tid.bowl `tid byk.bowl file args])
  ;<  ~      bind:m  (watch-our /awaiting/[tid] %spider /thread-result/[tid])
  ;<  ~      bind:m  (poke-our %spider %spider-start poke-vase)
  ;<  =cage  bind:m  (take-fact /awaiting/[tid])
  ;<  ~      bind:m  (take-kick /awaiting/[tid])
  ?+  p.cage  ~|([%strange-thread-result p.cage file tid] !!)
    %thread-done  (pure:m %& q.cage)
    %thread-fail  (pure:m %| ;;([term tang] q.q.cage))
  ==
::
++  run-thread
  |=  [=desk file=term args=vase]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =thread-result  bind:m  (run-thread-soft desk file args)
  ?-  -.thread-result
    %&  (pure:m p.thread-result)
    %|  (strand-fail p.thread-result)
  ==
:: printf utils
::
++  vase-to-wain  |=(=vase `wain`(turn (wash [0 80] (sell vase)) crip))
++  vase-to-cord  |=(=vase (of-wain:format (vase-to-wain vase)))
::
++  take-poke-ack-soft
  |=  =wire
  =/  m  (strand ,(unit tang))
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
      [~ %agent * %poke-ack *]
    ?.  =(wire wire.u.in.tin)
      `[%skip ~]
    `[%done p.sign.u.in.tin]
  ==
::
++  poke-soft
  |=  [=dock =cage]
  =/  m  (strand ,(unit tang))
  ^-  form:m
  =/  =card:agent:gall  [%pass /poke %agent dock %poke cage]
  ;<  ~  bind:m  (send-raw-card card)
  (take-poke-ack-soft /poke)
:: These won't crash spider if the scry fails
:: (Because a different agent, %venter, is responsible for scrying...)
::
++  scry-soft
  |*  [=mold =path]
  =/  m  (strand ,(each mold goof))
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  ;<  =thread-result  bind:m  (vent-soft [our %venter] scry+path)
  ?-  -.thread-result
    %|  (pure:m %| p.thread-result)
    %&  (pure:m %& ;;(mold p.thread-result))
  ==
::
++  scry-hard
  |*  [=mold =path]
  =/  m  (strand ,mold)
  ^-  form:m
  ;<  a=(each mold goof)  bind:m  (scry-soft mold path)
  ?-  -.a
    %&  (pure:m p.a)
    %|  (strand-fail p.a)
  ==
::
++  unit-scry
  |*  [=mold =path]
  =/  m  (strand ,(unit mold))
  ^-  form:m
  ;<  a=(each mold goof)  bind:m  (scry-soft mold path)
  ?.  -.a
    (pure:m ~)
  (pure:m `p.a)
::
++  pass-arvo
  |=  [=wire =note-arvo]
  =/  m  (strand ,~)
  ^-  form:m
  (send-raw-card %pass wire %arvo note-arvo)
::
++  take-sign
  |=  =wire
  =/  m  (strand ,sign-arvo)
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
    ~  `[%wait ~]
      [~ %sign *]
    ?.  =(wire wire.u.in.tin)
      `[%skip ~]
    `[%done sign-arvo.u.in.tin]
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
    `[%done `cage.sign.u.in.tin]
    ::
      [~ %agent * %kick *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done ~]
  ==
--
