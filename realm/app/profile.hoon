:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: author: lodlev-migdev
:: purpose: http/web interface into passport profile
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/-  *passport, common
/+  *server, default-agent, dbug, verb
:: =*  card  card:agent:gall
|%
+$  card  card:agent:gall
--
%-  agent:dbug
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >>  "on-init"
  `this
  :: :_  this
  :: ::  bind this agent to requests to /passport route
  :: :~  [%pass /passport-route %arvo %e %connect `/'passport' %profile]
  :: ==
++  on-save  on-save:def
++  on-load
  |=  =vase
  ^-  (quip card:agent:gall agent:gall)
  ~&  >>  "on-load"
  :_  this
  ::  bind this agent to requests to /passport route
  :~  [%pass /passport-route %arvo %e %connect `/'profile' %profile]
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+  mark  (on-poke:def mark vase)
      %handle-http-request
    =+  !<([id=@ta req=inbound-request:eyre] vase)
    ~&  >>  [id req]
    :_  this
    %+  give-simple-payload:app  id
    (handle-http-request req)
  ==
  ::
  ++  handle-http-request
    |=  =inbound-request:eyre
    ^-  simple-payload:http
    |^
    =*  req       request.inbound-request
    =*  headers   header-list.req
    =/  req-line  (parse-request-line url.req)
    ?.  =(method.req %'GET')  not-found:gen
    :: /passport page request? extract index.html page from the file-server and use string interpolation
    ::   to set this ship's values
    ~&  >>  "{<dap.bowl>}: {<url.req>}"
    ?:  =(url.req '/profile')
      =/  scry-start=path  /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl)
        :: :*  (scot %p our.bowl)
        ::     q.byk.bowl
        ::     (scot %da now.bowl)
        :: ==
      =/  scry-path  (weld scry-start /app/passport/index/html)
      ~&  (spat scry-path)
      :: =/  file  (as-octs:mimes:html .^(@ %cx scry-path))
      =/  file      .^(@ %cx scry-path)
      =/  content   (replace-html `@t`file)
      ?~  content   not-found:gen
      (html-response:gen (as-octs:mimes:html u.content))
    not-found:gen
    --
    :: Thomas (nod to ~dister-dozzod-niblyx-malnus)
    ++  replace-html
      |=  html=@t
      ^-  (unit @t)
      =/  pass  .^(passport:common %gx /(scot %p our.bowl)/passport/(scot %da now.bowl)/'our-passport'/noun)
      =/  discoverable  ?:  discoverable.pass  'true'  'false'
      =/  rus
        %+  rush  html
        %-  star
        ;~  pose
          :: indicate whether this is a discoverable passport
          (cold discoverable (jest '{passport-discoverable}'))
          (cold (scot %p ~zod) (jest '{og-title}'))
          (cold %desk (jest '{og-description}'))
          next
        ==
      ?~(rus ~ `(rap 3 u.rus))
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path
    (on-watch:def path)
  ::
      [%http-response *]
    %-  (slog leaf+"Eyre subscribed to {(spud path)}." ~)
    `this
  ==
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    ::
    [%x %our ~]     ::  ~/scry/passport/profile/our
      :: scry the passport agent and only return fields necessary to render the public
      ::  facing UI
      =/  pass  .^(passport:common %gx /(scot %p our.bowl)/passport/(scot %da now.bowl)/'our-passport'/noun)
      :: only return this data if the passport has been marked discoverable
      ?.  discoverable.pass  ~  :: 500 if not discoverable
      ``passport+!>(pass)
  ==
::
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%passport-route ~] wire)
    (on-arvo:def [wire sign-arvo])
  ?>  ?=([%eyre %bound *] sign-arvo)
  ?:  accepted.sign-arvo
    %-  (slog leaf+"/passport-route bound successfully!" ~)
    `this
  %-  (slog leaf+"Binding /passport-route failed!" ~)
  `this
++  on-fail   on-fail:def
--
