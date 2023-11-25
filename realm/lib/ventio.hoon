/-  spider
/+  *strandio
=,  tid=tid:rand
|%
+$  vent-id  (trel @p tid @da)
::
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
++  unique-vent
  |=  [=dock =vents our=@p =tid now=@da]
  ^-  vent-id
  ?.  (~(has ju vents) dock [our tid now])
    [our tid now]
  $(now +(now))
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
::
++  unpage
  |=  =page
  =/  m  (strand ,vase)
  ^-  form:m
  =/  warning
    ?:  ?=(~ (mole |.(;;(type -.q.page))))  [0 ~]
    [2 leaf+"WARNING: unpage may be passing cage"]
  ~>  %slog.warning
  ;<  byk=beak:spider  bind:m  get-beak
  ;<  =tube:clay       bind:m  (build-our-tube q.byk %noun p.page)
  ;<  ~                bind:m  (trace (cat 3 'mark: ' p.page) ~)
  (pure:m (tube !>(q.page)))
:: vap (local venter agent) must be %[desk-name]-venter
::
++  get-vap
  =/  m  (strand ,dude:gall)
  ^-  form:m
  ;<  =desk  bind:m  get-desk
  =/  vap=dude:gall  (cat 3 desk '-venter')
  ;<  dudes=(set [=dude:gall live=?])  bind:m
    (scry ,(set [dude:gall ?]) /ge/[desk]/$)
  ?:  (~(has in dudes) [vap &])
    (pure:m vap)
  ~|("{(trip vap)} is not running" !!)
::
++  vent-soft
  |=  [=dock req=page]
  =/  m  (strand ,thread-result)
  ^-  form:m
  ;<  vap=dude:gall  bind:m  get-vap :: get local venter agent
  :: get existing vents
  :: 
  ;<  =vents  bind:m  (scry vents /gx/[vap]/vents/noun)
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
  ;<  ~  bind:m  (poke [our.bowl vap] tally-vent+!>([dock vid]))
  :: poke the agent on the destination ship with the vent id and page
  ::
  ;<  p=(unit tang)  bind:m  (poke-soft dock vent-request+!>([vid req]))
  ?^  p
    :: clear the vent-path
    ::
    ;<  ~  bind:m  (poke [our.bowl vap] clear-vent+!>([dock vid]))
    (pure:m %| [%vent-request-poke-fail u.p])
  :: take vent update on vent-path
  ::
  ;<  rep=cage  bind:m  (take-fact vent-path)
  ;<  ~         bind:m  (take-kick vent-path)
  :: clear the vent-path
  ::
  ;<  ~  bind:m  (poke [our.bowl vap] clear-vent+!>([dock vid]))
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
++  vent-as-mark
  |=  [=desk =mark]
  |=  [=dock =page]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =vase       bind:m  (vent-raw dock page)
  ;<  =tube:clay  bind:m  (build-our-tube desk %noun mark)
  (pure:m (tube vase))
::
++  vent
  |*  a=mold
  =/  m  (strand ,a)
  |=  [=dock =page]
  ^-  form:m
  ;<  =vase  bind:m  (vent-raw dock p.page q.page)
  (pure:m ;;(a q.vase))
:: generic thread for vent-based "thread-pokes":
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
  ;<  =page       bind:m  (unpackage body input)
  ;<  =vase       bind:m  ((vent-as-mark output) dock page)
  :: convert to json - this allows for generic
  :: /spider/realm/venter-package/vent/json thread format
  ::
  ;<  =tube:clay  bind:m  (build-our-tube desk.output mark.output %json)
  (pure:m (tube vase))
::
+$  vine  $-([gowl vent-id cage] shed:khan)
::
++  vine-thread
  |=  =vine
  =,  strand=strand:spider
  ^-  thread:spider
  |=  arg=vase
  =/  m  (strand ,vase)
  ^-  form:m
  =+  !<(req=(unit [gowl request]) arg)
  ?~  req  (strand-fail %no-arg ~)
  =/  [=gowl vid=vent-id =mark =noun]  u.req
  ;<  =vase  bind:m  (unpage mark noun)
  (vine gowl vid mark vase)
:: miscellaneous utils
::
+$  gowl     bowl:gall   :: gall bowl alias
+$  sowl     bowl:spider :: spider bowl alias
:: common vase strand functions
::
++  vand     (strand ,vase)
++  form-m   form:vand :: shed:khan
++  bind-m   bind:vand
++  pure-m   pure:vand
::
++  get-tid
  =/  m  (strand ,tid)
  ^-  form:m
  |=  tin=strand-input:strand
  `[%done tid.bowl.tin]
::
++  get-desk
  =/  m  (strand ,desk)
  ^-  form:m
  |=  tin=strand-input:strand
  `[%done q.byk.bowl.tin]
:: only works for agents which use lib/vent.hoon agent transformer
::
++  agent-send-cards
  |=  [=dude:gall cards=(list card:agent:gall)]
  =/  m  (strand ,~)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  (poke [our dude] send-cards+!>(`noun`cards))
::
++  agent-send-card
  |=  [=dude:gall =card:agent:gall]
  =/  m  (strand ,~)
  ^-  form:m
  (agent-send-cards dude ~[card])
:: watch from an agent (goes into wex.bowl)
::
++  agent-watch-path
  |=  [=dude:gall =wire =dock =path]
  =/  m  (strand ,~)
  ^-  form:m
  |^
  :: watch dude for on-agent updates
  ::
  ;<  our=ship  bind:m  get-our
  ;<  ~  bind:m  (watch /[dude]/vent-on-agent [our dude] /vent-on-agent)
  :: send %watch card
  ::
  =/  =card:agent:gall  [%pass wire %agent dock %watch path]
  ;<  ~  bind:m  (agent-send-card dude card)
  :: catch the %watch-ack
  ::
  ;<  [=bowl:gall wyre=^wire =sign:agent:gall]  bind:m  take-watch-ack
  ?>  ?=(%watch-ack -.sign)
  ?~  p.sign
    (pure:m ~)
  (strand-fail %agent-watch-ack-fail u.p.sign)
  ::
  ++  take-watch-ack
    %-  %^    take-special-fact
            /[dude]/vent-on-agent
          %noun
        ,[bowl:gall ^wire sign:agent:gall]
    |=  [=bowl:gall wyre=^wire =sign:agent:gall]
    &(=(wyre wire) ?=(%watch-ack -.sign))
  --
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
    =+  ;;(a=mold q.cage.sign.u.in.tin)
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
:: TODO: FIX: continues to pulse when thread dies?
::
++  pulse-message
  |*  computation-result=mold
  =/  m  (strand ,computation-result)
  |=  [=cord time=@dr computation=form:m]
  ^-  form:m
  ;<  now=@da  bind:m  get-time
  =/  when  (add now time)
  =/  =card:agent:gall
    [%pass /pulse/(scot %da when) %arvo %b %wait when]
  ;<  ~        bind:m  (send-raw-card card)
  |=  tin=strand-input:strand
  =/  c-res  (computation tin)
  :: if done or failed, cancel timer and return result
  ::
  ?:  ?=(?(%done %fail) -.next.c-res)
    =/  =card:agent:gall
      [%pass /pulse/(scot %da when) %arvo %b %rest when]
    c-res(cards [card cards.c-res])
  :: received pulse timer wake
  ::
  ?.  ?&  ?=([~ %sign [%pulse @ ~] %behn %wake *] in.tin)
          =((scot %da when) i.t.wire.u.in.tin)
      ==
    :: if continuing, modify self to be like this code
    ::
    =?  c-res  ?=(%cont -.next.c-res)
      c-res(self.next ..$(computation self.next.c-res))
    c-res
  :: print the message
  ::
  %-  (slog cord ~)
  :: set a new pulse timer
  ::
  =.  when  (add now.bowl.tin time)
  =/  =card:agent:gall
    [%pass /pulse/(scot %da when) %arvo %b %wait when]
  =.  cards.c-res  [card cards.c-res]
  :: propagate state changes (when)
  ::
  ?-  -.next.c-res
    %cont  c-res(self.next ..$(computation self.next.c-res))
    ?(%skip %wait)  c-res(next [%cont ..$])
  ==
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
  ;<  vap=dude:gall  bind:m  get-vap :: get local venter agent
  ;<  our=@p  bind:m  get-our
  ;<  =thread-result  bind:m  (vent-soft [our vap] scry+path)
  ?-    -.thread-result
    %|  (pure:m %| p.thread-result)
      %&
    =/  res  (mole |.(;;(mold q.p.thread-result)))
    ?~  res  (pure:m %| %error-molding-scry-result ~)
    (pure:m %& u.res)
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
::
+$  iris-response  [=response-header:http data=(unit mime)]
::
++  de-mite  |=(=@t `(unit mite)`(rush (cat 3 '/' t) stap))
::
++  send-iris-request
  |=  [=request:http lag=@dr]
  =/  m  (strand ,iris-response)
  ^-  form:m
  %+  (set-timeout ,iris-response)  lag
  =/  =task:iris  [%request request *outbound-config:iris]
  =/  =card:agent:gall  [%pass /http-req %arvo %i task]
  ;<  ~  bind:m  (send-raw-card card)
  ;<  =sign-arvo  bind:m  (take-sign /http-req)
  ?.  ?=([%iris %http-response %finished *] sign-arvo)
    (strand-fail:strand %bad-sign ~)
  =+  client-response.sign-arvo
  ?~  full-file
    (pure:m [response-header ~])
  =/  =mite  (fall (de-mite type.u.full-file) /text/plain)
  (pure:m [response-header `[mite data.u.full-file]])
--
