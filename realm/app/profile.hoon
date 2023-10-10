:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: author: lodlev-migdev
:: purpose: http/web interface into passport profile
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/-  *passport, common, *docket, store=profile-store
/+  *server, default-agent, multipart, dbug, verb
:: =*  card  card:agent:gall
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0
  $:  %0
      toc=glob
      opengraph-image=(unit @t)
  ==
--
%-  agent:dbug
^-  agent:gall
%+  verb  |
=|  state-0
=*  state  -
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    ext   ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >>  "on-init"
  :: `this
  :_  this
  ::  bind this agent to requests to /passport route
  :~  [%pass /passport-route %arvo %e %connect `/'passport' %profile]
  ==
++  on-save
    ^-  vase
    !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  :_  this(state old)
  ::  bind this agent to requests to /passport route
  :~  [%pass /passport-route %arvo %e %connect `/'passport' %profile]
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  :: |^
  =^  cards  state
    ?+  mark  (on-poke:def mark vase)
    ::
        %handle-http-request
      =+  !<([id=@ta req=inbound-request:eyre] vase)
      (handle-http-request:ext id req)

        %profile-action
      =/  =action:store  !<(action:store vase)
      ?-  -.action  ::(on-poke:def mark vase)
        %save-opengraph-image
          :: assure it's us
          ?>  =(our.bowl src.bowl)
          =/  vent-path=path  /vent/(scot %p src.req-id.action)/(scot %da now.req-id.action)
          =/  kickcard=card  [%give %kick ~[vent-path] ~]
          =/  cards=(list card)
          :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
              kickcard
          ==
          =.  opengraph-image.state  (some img.action)
          [cards state]

      ==
    ==
  [cards this]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path
    (on-watch:def path)
  ::
      [%http-response *]
        ?>  (team:title [our src]:bowl)
        %-  (slog leaf+"Eyre subscribed to {(spud path)}." ~)
        `this

      [%vent @ @ ~] :: poke response comes on this path
        =/  src=ship  (slav %p i.t.path)
        ?>  =(src src.bowl)
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

      [%x %dbug %state ~]
    =-  ``noun+!>(-)
    %_  state
        toc
      :: %-  ~(run by charges)
      :: |=  =charge
      :: =?  chad.charge  ?=(%glob -.chad.charge)
        :: :-  %glob
        %-  ~(run by toc)
        |=(=mime mime(q.q 1.337))
      :: t
    ==
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
::
|_  =bowl:gall
++  def   ~(. (default-agent state %|) bowl)
::
++  handle-http-request
  |=  [eyre-id=@ta inbound-request:eyre]
  ^-  (quip card _state)
  ~&  >>  "{<url.request>}"
  ::
  =;  [payload=simple-payload:http caz=(list card) =_state]
    :_  state
    %+  weld  caz
    (give-simple-payload:app eyre-id payload)
  ::
  ::NOTE  we don't use +require-authorization-simple here because we want
  ::      to short-circuit all the below logic for the unauthenticated case.
  ?.  authenticated
    :_  [~ state]
    =-  [[307 ['location' -]~] ~]
    (cat 3 '/~/login?redirect=' url.request)
  ::
  =*  headers   header-list.request
  =/  dict      `(map @t @t)`(malt header-list.request)
  =/  req-line  (parse-request-line url.request)
  ::
  |^  ?+  method.request  [[405^~ ~] ~ state]
        %'GET'   [handle-get-request ~ state]
        %'POST'  handle-upload
      ==
  ::
  ++  handle-get-request
    ^-  simple-payload:http
    ~&  >>  req-line
    ?+  [site ext]:req-line  (redirect:gen '/apps/grid/')
        [[%session ~] [~ %js]]
      %-  inline-js-response
      (rap 3 'window.ship = "' (rsh 3 (scot %p our.bowl)) '";' ~)
    ::
        [[%passport %upload ~] ?(~ [~ %html])]
      [[200 ~] `(upload-page ~)]
    ::
        [[%passport ~] ?(~ [~ %html])]
      =/  =passport:common  .^(passport:common %gx /(scot %p our.bowl)/passport/(scot %da now.bowl)/'our-passport'/noun)
      =/  content  %+  payload-from-glob
        %passport
      [[ext=[~ ~.html] site=site.req-line] args=~]
      ?~  data.content  content
      =/  bod=[t=@ud c=@t]  ^-([@ud @t] u.data.content)
      =/  host  (~(get by dict) 'host')
      [response-header.content (replace-html host c.bod passport)]
    ::
        [[%passport @ *] *]
      %+  payload-from-glob
        %passport
      req-line(site (slag 1 site.req-line))
    ==
  ::
  ++  upload-page
    |=  msg=(list @t)
    ^-  octs
    %-  as-octt:mimes:html
    %-  en-xml:html
    ^-  manx
    ::  desks: with local globs, eligible for upload
    ::
    =/  desks=(list desk)
      :~  %realm  ==
    ::   %+  murn  ~(tap by charges)
    ::   |=  [d=desk [docket *]]
    ::   ^-  (unit desk)
    ::   ?:(?=(%glob -.href) `d ~)
    ::
    ;html
      ;head
        ;title:"%passport globulator"
        ;meta(charset "utf-8");
        ;style:'''
               * { font-family: monospace; margin-top: 1em; }
               li { margin-top: 0.5em; }
               '''
      ==
      ;body
        ;h2:"%passport globulator"
        ;+  ?.  =(~ msg)
              :-  [%p ~]
              (join `manx`;br; (turn msg |=(m=@t `manx`:/"{(trip m)}")))
            :: ;ol(start "0")
            ::   ;li:"""
            ::       from realm/web-holium-com, run 'yarn install'
            ::       """
            ::   ;li:"from realm/web-holium-com, run 'yarn build'"
            ::   ;li:"""
            ::       for 'data' below, select the ./web-holium-com/out folder as the input
            ::       """
            ::   ;li:"glob!"
            :: ==
            ;div:"- clone the realm repo to <folder>"
            ;div:"- navigate to <folder>/web-holium-com"
            ;div:"- run 'yarn install'"
            ;div:"- run 'yarn build'"
            ;div:"- select the <folder>/web-holium-com/out folder as input below"
            (safari and internet explorer do not support uploading directory
            trees properly. please glob from other browsers.)
        ;+  ?:  =(~ desks)
              ;p:"no desks eligible for glob upload"
            ;form(method "post", enctype "multipart/form-data")
              :: ;label
              ::   ;+  :/"desk: "
              ::   ;select(name "desk")
              ::     ;*  %+  turn  desks
              ::         |=(d=desk =+((trip d) ;option(value -):"{-}"))
              ::   ==
              :: ==
              :: ;br;
              ;label
                ;+  :/"data: "
                ;input
                  =type             "file"
                  =name             "glob"
                  =directory        ""
                  =webkitdirectory  ""
                  =mozdirectory     "";
              ==
              ;br;
              ;button(type "submit"):"glob!"
            ==
      ==
    ==
  ::
  ++  handle-upload
    ^-  [simple-payload:http (list card) _state]
    ?.  ?=([[%passport %upload ~] ?(~ [~ %html])] [site ext]:req-line)
      [[404^~ ~] [~ state]]
    ::
    =;  [=glob err=(list @t)]
      =*  error-result
        :_  [~ state]
        [[400 ~] `(upload-page err)]
      ::
      ?.  =(~ err)  error-result
      ::
      :: =*  cha      ~(. ch desk)
      :: =/  =charge  (~(got by charges) desk)
      ::
      =?  err  =(~ glob)
        ['no files in glob' err]
      :: =?  err  !?=(%glob -.href.docket.charge)
        :: ['desk does not use glob' err]
      ::
      ?.  =(~ err)  error-result
      :-  [[200 ~] `(upload-page 'successfully globbed' ~)]
      :: ?>  ?=(%glob -.href.docket.charge)
      ::
      :: =.  charges  (new-chad:cha glob+glob)
      :: =.  by-base
      ::   =-  (~(put by by-base) - desk)
      ::   base.href.docket.charge
      :: =.  toc  glob
      ::
      `state(toc glob)
    ::
    ?~  parts=(de-request:multipart [header-list body]:request)
      ~&  headers=header-list.request
      [*glob 'failed to parse submitted data' ~]
    ::
    %+  roll  u.parts
    |=  [[name=@t part:multipart] =glob err=(list @t)]
    ^+  [glob err]
    ?:  =('desk' name)
      ::  must be a desk with existing charge
      ::
      ?.  ((sane %ta) body)
        [glob (cat 3 'invalid desk: ' body) err]
      ?.  =(body 'passport')
        [glob (cat 3 'unknown desk: ' body) err]
      [glob err]
    :: :-  desk
    ::  all submitted files must be complete
    ::
    ?.  =('glob' name)  [glob (cat 3 'weird part: ' name) err]
    ?~  file            [glob 'file without filename' err]
    ?~  type            [glob (cat 3 'file without type: ' u.file) err]
    ?^  code            [glob (cat 3 'strange encoding: ' u.code) err]
    =/  filp            (rush u.file fip)
    ?~  filp            [glob (cat 3 'strange filename: ' u.file) err]
    ::  ignore metadata files and other "junk"
    ::TODO  consider expanding coverage
    ::
    ?:  =('.DS_Store' (rear `path`u.filp))
      [glob err]
    ::  make sure to exclude the top-level dir from the path
    ::
    :_  err
    %+  ~(put by glob)  (slag 1 `path`u.filp)
    ~&  >>  [u.type (slag 1 `path`u.filp)]
    [u.type (as-octs:mimes:html body)]
  ::
  ++  fip
    =,  de-purl:html
    ;:  cook
      |=(pork (weld q (drop p)))
      deft
      |=(a=cord (rash a (more fas smeg)))
      crip
      (star ;~(pose (cold '%20' (just ' ')) next))
    ==
  ::
  ++  inline-js-response
    |=  js=cord
    ^-  simple-payload:http
    %.  (as-octs:mimes:html js)
    %*  .  js-response:gen
      cache  %.n
    ==
  ::
  ++  payload-from-glob
    |=  [from=@ta what=request-line]
    ^-  simple-payload:http
    ~&  >>  [from what]
    :: ~&  >>  [from what]
    :: =/  des=(unit desk)
    ::   (~(get by by-base) from)
    :: ?~  des  not-found:gen
    :: =/  cha=(unit charge)
    ::   (~(get by charges) u.des)
    :: ?~  cha  not-found:gen
    :: ?.  ?=(%glob -.chad.u.cha)  not-found:gen
    :: =*  glob  glob.chad.u.cha
    =/  suffix=^path
      (weld site.what (drop ext.what))
    ~&  >  suffix
    ?:  =(suffix /desk/js)
      %-  inline-js-response
      (rap 3 'window.desk = "' q.byk.bowl '";' ~)
    =/  requested
      ?:  (~(has by toc) suffix)  suffix
      /index/html
    ~&  >  requested
    =/  data=mime
      (~(got by toc) requested)
    =/  mime-type=@t  (rsh 3 (crip <p.data>))
    =;  headers
      [[200 headers] `q.data]
    :-  content-type+mime-type
    ?:  =(/index/html requested)  ~
    ~[max-1-wk:gen]
  :: Thomas (nod to ~dister-dozzod-niblyx-malnus)
  ++  replace-html
    |=  [host=(unit @t) htm=@t =passport:common]
    ^-  (unit octs)
    ::  todo: figure out how to determine https vs http
    =/  url   ?~(host '' (crip "https://{<(need host)>}/passport"))
    =/  display-name  ?~(display-name.contact.passport '' (need display-name.contact.passport))
    =/  bio  ?~(bio.contact.passport '' (need bio.contact.passport))
    =/  opengraph-image  ?~(opengraph-image '' (need opengraph-image.state))
    =/  rus
      %+  rush  htm
      %-  star
      ;~  pose
        (cold (scot %p our.bowl) (jest '{og-title}'))
        (cold display-name (jest '{og-username}'))
        (cold bio (jest '{og-description}'))
        (cold url (jest '{og-url}'))
        (cold opengraph-image (jest '{og-image}'))
        next
      ==
    ?~(rus ~ (some (as-octs:mimes:html (rap 3 u.rus)))) :: `(rap 3 u.rus))
  --
--