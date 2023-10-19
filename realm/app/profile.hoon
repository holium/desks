:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: author: lodlev-migdev
:: purpose: http/web interface into passport profile
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/-  *passport, common, *docket, store=profile, hood
/+  *server, default-agent, multipart, dbug, verb
:: =*  card  card:agent:gall
|%
+$  card  card:agent:gall
+$  versioned-state
    $%  state-0
    ==
+$  state-0
  $:  %0
      ::  map of filename => mime data
      toc=glob
      :: registry is a list of ships that want to be notified when the passport
      ::  UI is updated
      registry=(set =ship)
      ::  passport profile open graph image. used in <meta> tag of served passport page
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
  %-  (slog leaf+"getting realm hash..." ~)
  =/  hash  .^(@uv %cz [(scot %p our.bowl) %realm (scot %da now.bowl) ~])
  =/  hood-path  /(scot %p our.bowl)/hood/(scot %da now.bowl)
  %-  (slog leaf+"getting hood pikes..." ~)
  =/  peaks=pikes:hood  .^(pikes:hood %gx (welp hood-path /kiln/pikes/kiln-pikes))
  ::  find %realm in the list of desks
  =/  realm-pike=(unit pike:hood)     (~(get by peaks) %realm)
    ?~  realm-pike
      ~&  >>>  "error: %realm desk not found"  !!
  =/  register-card=(list card)
    ?~  sync.u.realm-pike
      %-  (slog leaf+"warn: no sync found for %realm. passport assets cannot be downloaded." ~)
      `(list card)`~
    :: do our hashes match? .. if not, do not attempt to register
    ?.  =(hash hash.u.realm-pike)
      ~&  >>  "warn: %realm hashes do not match. skipping host {<ship.u.sync.u.realm-pike>} registration."
      `(list card)`~
    ~&  >  "registering with {<ship.u.sync.u.realm-pike>}..."
    [%pass /crux/register %agent [ship.u.sync.u.realm-pike %profile] %poke profile-interaction+!>([%register our.bowl])]~
  =/  init-cards  [%pass /passport-route %arvo %e %connect `/'passport' %profile]~
  [(weld init-cards register-card) this]
::
++  on-save
    ^-  vase
    !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  %-  (slog leaf+"reloading %profile agent" ~)
  =^  cards  this  on-init
  =/  old  !<(versioned-state old-state)
  [cards this(state old)]
  :: %-  (slog leaf+"nuking old %profile state" ~) ::  temporarily doing this for making development easier
  :: =^  cards  this  on-init
  :: :_  this
  :: =-  (welp - cards)
  :: %+  turn  ~(tap in ~(key by wex.bowl))
  :: |=  [=wire =ship =term]
  :: ^-  card
  :: [%pass wire %agent [ship term] %leave ~]
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
      :: =.  authenticated.req  %.y
      :: ~&  authenticated.req
      (handle-http-request:ext id req)

        %profile-interaction
      =/  =interaction:store  !<(interaction:store vase)
      ?-  -.interaction  ::(on-poke:def mark vase)

      ::
        %register
        ?:  =(our.bowl src.bowl)
          %-  (slog leaf+"{<dap.bowl>}: skipping self registration..." ~)
          `state
      %-  (slog leaf+"{<dap.bowl>}: registering {<src.bowl>}..." ~)
      =.  registry.state
        ?.  (~(has in registry.state) src.bowl)
          %-  (slog leaf+"{<dap.bowl>}: {<src.bowl>} not found. adding..." ~)
          (~(put in registry.state) src.bowl)
        %-  (slog leaf+"{<dap.bowl>}: {<src.bowl>} found. skipping..." ~)
        registry.state

        :: if the calling ship is registering and we have files in our toc, poke
        ::   them that there are files waiting for download
        =/  notify-card  ?:  (gth ~(wyt in ~(key by toc.state)) 0)
          ^-  (list card)
          :~  :*  %pass
            /crux/update-available
            %agent
            [src.bowl %profile]
            %poke
            profile-interaction+!>([%update-available ~])
          ==  ==
        `(list card)`~
        :: =/  vent-cards
        ::   ^-  (list card)
        ::   :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
        ::       kickcard
        ::   ==
        :: [(weld vent-cards notify-card) state]
        [notify-card state]

      ::
        %update-available
        %-  (slog leaf+"{<dap.bowl>}: updates available. starting download from {<src.bowl>}..." ~)
        :: if the calling ship is registering and we have files in our toc, poke
        ::   them that there are files waiting for download
        :_  state
        :~  :*  %pass
          /crux/start-download
          %agent
          [src.bowl %profile]
          %poke
          profile-interaction+!>([%start-download ~])
        ==  ==

      ::
        %start-download
          %-  (slog leaf+"{<dap.bowl>}: starting download. sending files to {<src.bowl>}..." ~)
          =/  updates=(list card)
          :~  :*  %pass
              /crux/update-files
              %agent
              [src.bowl %profile]
              %poke
              profile-interaction+!>([%update-files toc.state])
          ==  ==
          :: %+  turn  ~(tap by toc.state)
          :: |=  [=path =mime]
          :: :*  %pass
          ::     /crux/update-file
          ::     %agent
          ::     [src.bowl %profile]
          ::     %poke
          ::     profile-interaction+!>([%update-file path mime])
          :: ==
          :: =/  updates
          :: %+  snoc  updates
          :: :*  %pass
          ::     /crux/end-download
          ::     %agent
          ::     [src.bowl %profile]
          ::     %poke
          ::     profile-interaction+!>([%end-download ~])
          :: ==
          [updates state]
      ::
        %update-files
        %-  (slog leaf+"{<dap.bowl>}: {<src.bowl>} sent us its file listing. updating..." ~)
        =.  toc.state  toc.interaction :: (~(put by toc.state) key.interaction data.interaction)
        `state

      ::
        %end-download
        %-  (slog leaf+"{<dap.bowl>}: download complete" ~)
        `state

          :: for now, if update available, start downlod
          :: =/  vent-path=path  /vent/(scot %p src.req-id.action)/(scot %da now.req-id.action)
          :: =/  kickcard=card  [%give %kick ~[vent-path] ~]
          :: :_  state
          :: :~  ::[%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
          ::     ::kickcard
          ::     [%pass /crux/update %agent [our.bowl %profile] %poke profile-interaction+!>([%update-crux ~])]
          :: ==
          :: =/  listing  .^((list path) %gx /(scot %p src.bowl)/profile/(scot %da now.bowl)/'crux-listing'/noun)
          :: ~&  "processing {<(lent listing)>} files..."
          :: =.  toc.state  ~
          :: =/  result
          :: %+  roll  listing
          :: |=  [=path acc=[files-processed=(map path mime)]]
          :: :: ~&  >>  "processing file: {<path>}..."
          :: =/  glob  .^((unit mime) %gx (weld (weld /(scot %p src.bowl)/profile/(scot %da now.bowl)/'glob' path) /noun))
          :: ?~  glob  ~&  >>  "warning: null glob returned by %profile blob scry"  acc
          :: :: =/  key  (stab path)
          :: (~(put by files-processed.acc) path `mime`u.glob)
          :: :: =.  toc.state  (~(put by toc.state) key u.glob)
          :: :: (add num-files-processed.acc 1)
          :: ~&  >  "total # of files processed: {<~(wyt in ~(key by files-processed.result))>}"
          :: =.  toc.state  files-processed.result
          :: `state

      ::
        :: %update-crux
        ::   ~&  >>  "byk => {<byk.bowl>}"
        ::   =/  listing  .^((list path) %gx /(scot %p -.byk.bowl)/profile/(scot %da now.bowl)/'crux-listing'/noun)
        ::   ~&  "processing {<(lent listing)>} files..."
        ::   =.  toc.state  ~
        ::   =/  result
        ::   %+  roll  listing
        ::   |=  [=path acc=[files-processed=(map path mime)]]
        ::   :: ~&  >>  "processing file: {<path>}..."
        ::   =/  glob  .^((unit mime) %gx (weld (weld /(scot %p -.byk.bowl)/profile/(scot %da now.bowl)/'glob' path) /noun))
        ::   ?~  glob  ~&  >>  "warning: null glob returned by %profile blob scry"  acc
        ::   :: =/  key  (stab path)
        ::   (~(put by files-processed.acc) path `mime`u.glob)
        ::   :: =.  toc.state  (~(put by toc.state) key u.glob)
        ::   :: (add num-files-processed.acc 1)
        ::   ~&  >  "total # of files processed: {<~(wyt in ~(key by files-processed.result))>}"
        ::   =.  toc.state  files-processed.result
        ::   `state
          :: :_  state
          :: :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
          ::     kickcard
          :: ==
        ==

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

      ::
      ::   %register
      :: %-  (slog leaf+"{<dap.bowl>}: registering {<src.bowl>}..." ~)
      :: =/  vent-path=path  /vent/(scot %p src.req-id.action)/(scot %da now.req-id.action)
      :: =/  kickcard=card  [%give %kick ~[vent-path] ~]
      :: =.  registry.state
      ::   ?.  (~(has in registry.state) src.bowl)
      ::     %-  (slog leaf+"{<dap.bowl>}: {<src.bowl>} not found. adding..." ~)
      ::     (~(put in registry.state) src.bowl)
      ::   %-  (slog leaf+"{<dap.bowl>}: {<src.bowl>} found. skipping..." ~)
      ::   registry.state

      ::   :: if the calling ship is registering and we have files in our toc, poke
      ::   ::   them that there are files waiting for download
      ::   =/  notify-card  ?:  (gth ~(wyt in ~(key by toc.state)) 0)
      ::     ^-  (list card)
      ::     :~  :*  %pass
      ::       /crux/check
      ::       %agent
      ::       [src.bowl %profile]
      ::       %poke
      ::       profile-action+!>([%update-available [our.bowl now.bowl] ~])
      ::     ==  ==
      ::   `(list card)`~
      ::   =/  vent-cards
      ::     ^-  (list card)
      ::     :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
      ::         kickcard
      ::     ==
      ::   [(weld vent-cards notify-card) state]

      :: ::
      ::   %update-available
      ::   %-  (slog leaf+"{<dap.bowl>}: updates available. starting download from {<src.bowl>}..." ~)
      ::     :: for now, if update available, start downlod
      ::     =/  vent-path=path  /vent/(scot %p src.req-id.action)/(scot %da now.req-id.action)
      ::     =/  kickcard=card  [%give %kick ~[vent-path] ~]
      ::     :_  state
      ::     :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
      ::         kickcard
      ::         [%pass /crux/update %agent [src.bowl %profile] %poke profile-action+!>([%update-crux [our.bowl now.bowl] ~])]
      ::     ==

      :: ::
      ::   %update-crux
      ::     ~&  >>  "byk => {<byk.bowl>}"
      ::     =/  listing  .^((list path) %gx /(scot %p -.byk.bowl)/profile/(scot %da now.bowl)/'crux-listing'/noun)
      ::     ~&  "processing {<(lent listing)>} files..."
      ::     =.  toc.state  ~
      ::     =/  result
      ::     %+  roll  listing
      ::     |=  [=path acc=[files-processed=(map path mime)]]
      ::     :: ~&  >>  "processing file: {<path>}..."
      ::     =/  glob  .^((unit mime) %gx (weld (weld /(scot %p -.byk.bowl)/profile/(scot %da now.bowl)/'glob' path) /noun))
      ::     ?~  glob  ~&  >>  "warning: null glob returned by %profile blob scry"  acc
      ::     :: =/  key  (stab path)
      ::     (~(put by files-processed.acc) path `mime`u.glob)
      ::     :: =.  toc.state  (~(put by toc.state) key u.glob)
      ::     :: (add num-files-processed.acc 1)
      ::     ~&  >  "total # of files processed: {<~(wyt in ~(key by files-processed.result))>}"
      ::     =/  vent-path=path  /vent/(scot %p src.req-id.action)/(scot %da now.req-id.action)
      ::     =/  kickcard=card  [%give %kick ~[vent-path] ~]
      ::     =.  toc.state  files-processed.result
      ::     :_  state
      ::     :~  [%give %fact ~[vent-path] profile-vent+!>([%ack ~])]
      ::         kickcard
      ::     ==
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
        ~&  >>  "{<team:title>}, {<[our src]:bowl>}"
        :: ?>  (team:title [our src]:bowl)
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
  ::
    [%x %crux-listing ~]
      :: =/  keys  (turn ~(tap in ~(key by toc.state)) spat)
      =/  keys  ~(tap in ~(key by toc.state))
      ``noun+!>(keys)
  ::
    [%x %glob *]
      :: ~&  >>  "requested {<t.t.path>}"
      :: =/  paff  (stab `@t`i.t.t.path)
      =/  pod  (~(get by toc.state) t.t.path)
      ?~  pod
        ~&  >>  "{<t.t.path>} not found"
        ``noun+!>(~)
      :: ~&  >>  "found"
      ``noun+!>((some u.pod))
  ::
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
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
    [%crux %register ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?~  p.sign
            :: ~&  >  "{<dap.bowl>}: successfully registered with app host"
            `this
          ~&  >>>  "{<dap.bowl>}: register poke failed"
          `this
      ==

    [%crux %update-available ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?~  p.sign
            :: ~&  >  "{<dap.bowl>}: successfully updated from app host"
            `this
          ~&  >>>  "{<dap.bowl>}: update-available poke failed"
          `this
      ==

    [%crux %start-download ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?~  p.sign
            :: ~&  >  "{<dap.bowl>}: successfully notified from app host"
            `this
          ~&  >>>  "{<dap.bowl>}: start-download poke failed"
          `this
      ==

    [%crux %update-files ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?~  p.sign
            :: ~&  >  "{<dap.bowl>}: successfully notified from app host"
            `this
          ~&  >>>  "{<dap.bowl>}: update-files poke failed"
          `this
      ==

    [%crux %end-download ~]
      ?+  -.sign  (on-agent:def wire sign)
        %poke-ack
          ?~  p.sign
            :: ~&  >  "{<dap.bowl>}: successfully notified from app host"
            `this
          ~&  >>>  "{<dap.bowl>}: end-download"
          `this
      ==
  ==
::
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
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card _state)
  ~&  >>  "authenticated: {<authenticated.req>}, url: {<url.request.req>}"

  :: =.  authenticated.req  %.y
  ::
  =;  [payload=simple-payload:http caz=(list card) =_state]
    :: ~&  >  ?~(data.payload ~ (html-response:gen u.data.payload))
    :_  state
    %+  weld  caz
    (give-simple-payload:app eyre-id payload)
    :: (give-simple-payload:app eyre-id payload)

  ::
  ::NOTE  we don't use +require-authorization-simple here because we want
  ::      to short-circuit all the below logic for the unauthenticated case.
  ?.  authenticated.req
    :_  [~ state]
    =-  [[307 ['location' -]~] ~]
    (cat 3 '/~/login?redirect=' url.request.req)
  ::
  =*  headers   header-list.request.req
  =/  dict      `(map @t @t)`(malt header-list.request.req)
  =/  req-line  (parse-request-line url.request.req)

  :: ~&  >>  dict
  ::
  |^  ?+  method.request.req  [[405^~ ~] ~ state]
        %'GET'   [handle-get-request ~ state]
        %'POST'  handle-upload
      ==
  ::
  ++  handle-get-request
    ^-  simple-payload:http
    :: ~&  >>  req-line
    ?+  [site ext]:req-line  (redirect:gen '/apps/grid/')
        [[%session ~] [~ %js]]
      %-  inline-js-response
      (rap 3 'window.ship = "' (rsh 3 (scot %p our.bowl)) '";' ~)
    ::
        [[%passport %upload ~] ?(~ [~ %html])]
      [[200 ~] `(upload-page ~)]
    ::
        [[%passport %our ~] ?(~ [~ %json])]
      =/  jon  .^(json %gx /(scot %p our.bowl)/passport/(scot %da now.bowl)/'our-passport'/json)
      =/  data   (as-octs:mimes:html (en:json:html jon))
       [[200 [['content-type' 'application/json'] ~]] (some data)]
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
        [[%passport %edit ~] ?(~ [~ %html])]
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
      :: inform all subscribers that there is an update available
      =/  card-set=(set card)
      %-  ~(run in registry.state)
      |=  =ship
      [%pass /crux/update-available %agent [ship %profile] %poke profile-interaction+!>([%update-available ~])]
      [~(tap in card-set) state(toc glob)]
    ::
    ?~  parts=(de-request:multipart [header-list body]:request.req)
      ~&  headers=header-list.request.req
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
    :: ~&  >>  [u.type (slag 1 `path`u.filp)]
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
    =/  suffix=^path
      (weld site.what (drop ext.what))
    :: ~&  >  suffix
    ?:  =(suffix /desk/js)
      %-  inline-js-response
      (rap 3 'window.desk = "' q.byk.bowl '";' ~)
    =/  requested
      ?:  (~(has by toc) suffix)  suffix
      /passport/html
    =/  data=mime
      (~(got by toc) requested)
    =/  mime-type=@t  (rsh 3 (crip <p.data>))
    =;  headers
      [[200 headers] `q.data]
    :-  content-type+mime-type
    ?:  =(/passport/html requested)  ~
    ~[max-1-wk:gen]
  :: Thomas (nod to ~dister-dozzod-niblyx-malnus)
  ++  replace-html
    |=  [host=(unit @t) htm=@t =passport:common]
    ^-  (unit octs)
    =/  host  ?~  host  ~&  >>>  "host is null"  !!  u.host
    ~&  >>  "{<host>}"
    =/  prefix
    ?:  ?&  =(~ (rush 'localhost' (jest host)))
            =(~ (rush '127.0.0.1' (jest host)))
            =(~ (rush '0.0.0.0' (jest host)))
        ==  "https:/"  "http:/"
    =/  url   (crip (weld prefix (spud /[host]/'passport')))
    =/  display-name  ?~(display-name.contact.passport '' (need display-name.contact.passport))
    =/  bio  ?~(bio.contact.passport '' (need bio.contact.passport))
    =/  opengraph-image  ?~(opengraph-image '' (need opengraph-image.state))
    =/  script  (crip "<script>window.ship = '{<our.bowl>}'; window.shipUrl = {<(crip (weld prefix (spud /[host])))>};</script></head>")
    =/  rus
      %+  rush  htm
      %-  star
      ;~  pose
        (cold (scot %p our.bowl) (jest '{og-title}'))
        (cold display-name (jest '{og-username}'))
        (cold bio (jest '{og-description}'))
        (cold url (jest '{og-url}'))
        (cold opengraph-image (jest '{og-image}'))
        (cold script (jest '</head>'))
        next
      ==
    ?~(rus ~ (some (as-octs:mimes:html (rap 3 u.rus)))) :: `(rap 3 u.rus))
  --
--