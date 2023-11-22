/-  spider
/+  *strandio, *server
=,  strand=strand:spider
^-  thread:spider
::
=<
::
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
~&  %extracting-server
=/  server=@p          (need !<((unit @p) arg))
~&  %getting-eauth-url
:: =/  url=@t  'http://localhost:8080/~/scry/goals/pools/index.json'
:: ;<  cookie-test=request:http  bind:m
::   (en-home-auth-request ~ [%'GET' url ~ ~])
:: ;<  =iris-response  bind:m  (send-iris-request cookie-test lag)
:: ~&  test-response+iris-response
;<  eauth=@t           bind:m  (get-eauth-url server lag)
~&  %parsing-host
=/  host=@t            (host-from-eauth-url eauth)
~&  %getting-client
;<  client=@p          bind:m  get-our
~&  %sending-initial-request
;<  url=@t             bind:m  (send-initial-request client host)
~&  %getting-home-cookie
;<  home-cookie=@t     bind:m  get-home-cookie
~&  home-cookie+home-cookie
~&  %getting-token-redirect
;<  token-redirect=@t  bind:m  (get-token-redirect url host home-cookie)
~&  token-redirect+token-redirect
;<  host-cookie=@t     bind:m  (get-host-cookie token-redirect)
~&  host-cookie+host-cookie
:: =/  test=request:http  
::   :^  %'GET'  'https://niblyx-malnus.arvo.network/foo'
::   :~  ['cookie' host-cookie]
::       ['connection' 'keep-alive']
::   ==
::   ~
:: ;<  =iris-response     bind:m  (send-iris-request test lag)
:: ~&  test-response+iris-response
::
(pure:m !>(~))
::
|%
++  lag  ~s30
+$  iris-response  [=response-header:http data=(unit mime)]
++  de-mite  |=(=@t `(unit mite)`(rush (cat 3 '/' t) stap))
::
++  take-sign-arvo-on-wire
  |=  =wire
  =/  m  (strand ,sign-arvo)
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~
    `[%wait ~]
  ::
      [~ %sign *]
    ?.  =(wire wire.u.in.tin)
      `[%skip ~]
    `[%done sign-arvo.u.in.tin]
  ==
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
++  en-home-auth-request
  |=  [cookie=(unit @t) =request:http]
  =/  m  (strand ,request:http)
  ^-  form:m
  ;<  cookie-header=@t  bind:m
    =/  m  (strand ,@t)
    ^-  form:m
    ?^  cookie  (pure:m u.cookie)
    ;<  new-cookie=@t  bind:m  get-home-cookie
    (pure:m new-cookie)
  %-  pure:m
  %=    request
      header-list
    :_  header-list.request
    ['cookie' cookie-header]
  ==
::
++  send-iris-request
  |=  [=request:http lag=@dr]
  =/  m  (strand ,iris-response)
  ^-  form:m
  %+  (set-timeout ,iris-response)  lag
  =/  =task:iris  [%request request *outbound-config:iris]
  =/  =card:agent:gall  [%pass /http-req %arvo %i task]
  ;<  ~  bind:m  (send-raw-card card)
  ~&  %taking-sign-arvo
  ;<  =sign-arvo  bind:m  (take-sign-arvo-on-wire /http-req)
  ~&  %took-sign-arvo
  ?.  ?=([%iris %http-response %finished *] sign-arvo)
    (strand-fail:strand %bad-sign ~)
  =+  client-response.sign-arvo
  ?~  full-file
    (pure:m [response-header ~])
  (pure:m [response-header `[(need (de-mite type.u.full-file)) data.u.full-file]])
::
++  get-home-cookie
  =/  m  (strand ,@t)
  ^-  form:m
  ;<  eauth-url=(unit @t)  bind:m  (scry ,(unit @t) /ex//eauth/url)
  =/  host=@t  (host-from-eauth-url (need eauth-url))
  =/  url=@t  (cat 3 host '/~/login?redirect=/')
  ;<  our=@p   bind:m  get-our
  ;<  code=@p  bind:m  (scry ,@p /j/code/(scot %p our))
  =/  form=@t  (cat 3 'password=' (rsh 3 (scot %p code)))
  ~&  form+form
  =/  data=octs  (as-octs:mimes:html form)
  =/  =header-list:http
    :~  ['content-type' 'application/x-www-form-urlencoded']
        ['content-length' (crip (a-co:co p.data))]
    ==
  =/  =request:http  [%'POST' url header-list `data]
  ~&  request+request
  %+  (set-timeout ,@t)  lag
  |-
  ;<  =iris-response  bind:m  (send-iris-request request lag)
  ~&  get-own-session+iris-response
  =+  response-header.iris-response
  ?+    status-code
    (strand-fail:strand (cat 3 'server-response-' (scot %ud status-code)) ~)
    %204  (pure:m (need (get-header:http 'set-cookie' headers)))
    ::
      ?(%301 %302 %303 %307 %308)
    ~&  %got-a-redirect
    $(request request(url (need (get-header:http 'location' headers))))
  ==
::
++  initial-request
  |=  [client=@p host=@t]
  ^-  request:http
  =/  url=@t  (cat 3 host '/~/login?redirect=/')
  =/  name=@t  (rsh [3 1] (scot %p client))
  =/  form=@t  (rap 3 'name=%7E' name '&redirect=%2F&eauth=' ~)
  =/  data=octs  (as-octs:mimes:html form)
  =/  =header-list:http
    :~  ['content-type' 'application/x-www-form-urlencoded']
        ['content-length' (crip (a-co:co p.data))]
    ==
  [%'POST' url header-list `data]
::
++  host-from-eauth-url
  |=  eauth-url=@t
  ^-  @t
  =/  host=@t  (rev 3 (met 3 eauth-url) eauth-url) :: flip
  =.  host     (rsh [3 (met 3 '/~/eauth')] host)   :: crop
  (rev 3 (met 3 host) host) :: flip back
::
++  get-eauth-url
  |=  [server=@p lag=@dr]
  =/  m  (strand ,@t)
  ^-  form:m
  %+  (set-timeout ,@t)  lag
  ;<  now=@da  bind:m  get-time
  =/  =spar:ames  [server /e/x/(scot %da now)//eauth/url]
  ;<  ~        bind:m  (keen /keen spar)
  ;<  [* roar=(unit roar:ames)]  bind:m
     %^  (pulse-message ,[* (unit roar:ames)])  %taking-tune  ~s3
    (take-tune /keen)
  =/  eauth-url=@t  (need ;;((unit @t) q:(need q.dat:(need roar))))
  (pure:m eauth-url)
::
++  get-host
  |=  [server=@p lag=@dr]
  =/  m  (strand ,@t)
  ^-  form:m
  ;<  eauth-url=@t  bind:m  (get-eauth-url server lag)
  (pure:m (host-from-eauth-url eauth-url))
::
++  send-initial-request
  |=  [client=@p host=@t]
  =/  m  (strand ,@t)
  ^-  form:m
  =/  =request:http  (initial-request client host)
  ~&  http-request+request
  %+  (set-timeout ,@t)  lag
  |-
  ;<  =iris-response  bind:m  (send-iris-request request lag)
  ~&  send-initial-response+iris-response
  =+  response-header.iris-response
  ?+    status-code
    (strand-fail:strand (cat 3 'server-response-' status-code) ~)
    :: extract server and nonce from redirect
    ::
    %303  (pure:m (need (get-header:http 'location' headers)))
    :: redirect
    ::
      ?(%301 %302 %307 %308)
    =/  redirect=@t  (need (get-header:http 'location' headers))
    $(request request(url redirect))
  ==
::
++  get-token-request
  |=  [url=@t cookie=@t]
  =/  m  (strand ,request:http)
  ^-  form:m
  ;<  eauth-url=(unit @t)  bind:m  (scry ,(unit @t) /ex//eauth/url)
  =/  host=@t  (host-from-eauth-url (need eauth-url))
  =+  (parse-request-line (rsh [3 (met 3 host)] url))
  =/  server=(unit @p)  (biff (get-header:http 'server' args) (cury slaw %p))
  =/  nonce=(unit @uv)  (biff (get-header:http 'nonce' args) (cury slaw %uv))
  =/  form=@t
    %+  rap  3
    :~  (cat 3 'server=%7E' (rsh [3 1] (biff server (cury scot %p))))
        (cat 3 '&nonce=' (biff nonce (cury scot %uv)))
        '&grant=grant'
    ==
  =/  data=octs  (as-octs:mimes:html form)
  =/  =header-list:http
    :~  ['cookie' cookie]
        ['content-type' 'application/x-www-form-urlencoded']
        ['content-length' (crip (a-co:co p.data))]
    ==
  =/  login=@t  (cat 3 host '/~/login?redirect=/')
  (pure:m [%'POST' url header-list `data])
::
++  get-token-redirect
  |=  [our-url=@t host=@t cookie=@t]
  =/  m  (strand ,@t)
  ^-  form:m
  ;<  =request:http   bind:m  (get-token-request our-url cookie)
  ~&  get-token-redirect+request
  %+  (set-timeout ,@t)  lag
  |-
  ;<  =iris-response  bind:m  (send-iris-request request lag)
  ~&  get-token-redirect+iris-response
  =+  response-header.iris-response
  ?+    status-code
    (strand-fail:strand (cat 3 'server-response-' status-code) ~)
    :: extract server and nonce from redirect
    ::
      %303
    =/  redirect=@t  (need (get-header:http 'location' headers))
    =/  rel=@t  (rsh [3 (met 3 host)] redirect)
    =+  (parse-request-line rel)
    =/  token=(unit @uv)
      (biff (get-header:http 'token' args) (cury slaw %uv))
    ?^  token
      (pure:m redirect)
    $(request request(url redirect))
    :: redirect
    ::
      ?(%301 %302 %307 %308)
    =/  redirect=@t  (need (get-header:http 'location' headers))
    $(request request(url redirect))
  ==
::
++  get-host-cookie
  |=  token-redirect=@t
  =/  m  (strand ,@t)
  ^-  form:m
  =/  =request:http  [%'GET' token-redirect ~ ~]
  ~&  get-host-cookie+request
  %+  (set-timeout ,@t)  lag
  |-
  ;<  =iris-response  bind:m  (send-iris-request request lag)
  ~&  get-host-cookie+iris-response
  =+  response-header.iris-response
  ?+    status-code
    (strand-fail:strand (cat 3 'server-response-' status-code) ~)
    :: extract server and nonce from redirect
    ::
      %303
    =/  redirect=@t  (need (get-header:http 'location' headers))
    ?^  cookie=(get-header:http 'set-cookie' headers)
      (pure:m u.cookie)
    $(request request(url redirect))
    :: redirect
    ::
      ?(%301 %302 %307 %308)
    =/  redirect=@t  (need (get-header:http 'location' headers))
    $(request request(url redirect))
  ==
--
