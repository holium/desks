::
::  %bazaar [realm]:
::
::  A store for metadata on app dockets and installs.
::
/-  store=bazaar-store, docket, spaces-store, vstore=visas
/-  membership-store=membership, hark=hark-store
/-  treaty, hood
/+  dbug, default-agent
=>
  |%
  +$  card  card:agent:gall
  +$  versioned-state
      $%  state-0
      ==
  +$  state-0
    $:  %0
        =catalog:store
        =stalls:store
        =docks:store
        =grid-index:store
        =recommendations:store
        pending-installs=(map desk ship)
    ==
  --
=|  state-0
=*  state  -
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this    .
      def     ~(. (default-agent this %|) bowl)
      core    ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    :_  this
    :~  [%pass / %agent [our.bowl %bazaar] %poke bazaar-action+!>([%initialize ~])]
    ==
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    :: |=  old-state=vase
    :: ^-  (quip card _this)
    :: =/  old  !<(versioned-state old-state)
    :: ?-  -.old
    ::   %0  `this(state old)
    :: ==
    |=  =vase
    ^-  (quip card:agent:gall agent:gall)
    =/  old=(unit state-0)
      (mole |.(!<(state-0 vase)))
    ?^  old  ::  `this(state u.old)
      =|  lexicon-app=native-app:store
        =.  title.lexicon-app            'Lexicon'
        =.  color.lexicon-app            '#EEDFC9'
        =.  icon.lexicon-app             'AppIconLexicon'
        =.  config.lexicon-app           [size=[3 7] titlebar-border=%.n show-titlebar=%.y]
      =|  trove-app=native-app:store
        =.  title.trove-app            'Trove'
        =.  color.trove-app            '#DCDCDC'
        =.  icon.trove-app             'AppIconTrove'
        =.  config.trove-app           [size=[7 8] titlebar-border=%.n show-titlebar=%.y]
      =.  catalog.u.old  (~(del by catalog.u.old) %os-notes)
      =.  catalog.u.old  (~(del by catalog.u.old) %lexicon)
      =.  catalog.u.old  (~(del by catalog.u.old) %trove)
      :_  this(state u.old)
      :: add two new app entries for Realm's new "native" apps: %trove, and %lexicon
      :~  [%pass / %agent [our.bowl %bazaar] %poke bazaar-action+!>([%add-catalog-entry [%os-lexicon lexicon-app]])]
          [%pass / %agent [our.bowl %bazaar] %poke bazaar-action+!>([%add-catalog-entry [%os-trove trove-app]])]
      ==
    %-  (slog leaf+"nuking old %bazaar state" ~) ::  temporarily doing this for making development easier
    =^  cards  this  on-init
    :_  this
    =-  (welp - cards)
    %+  turn  ~(tap in ~(key by wex.bowl))
    |=  [=wire =ship =term]
    ^-  card
    [%pass wire %agent [ship term] %leave ~]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
    ?+  mark                    (on-poke:def mark vase)
      %bazaar-action            (action:bazaar:core !<(action:store vase))
      %bazaar-interaction       (interaction:bazaar:core !<(interaction:store vase))
    ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    =/  cards=(list card)
    ?+  path                  (on-watch:def path)
      [%updates ~]
        ?>  (is-host:core src.bowl)
        [%give %fact [/updates ~] bazaar-reaction+!>([%initial catalog.state stalls.state docks.state recommendations.state grid-index.state])]~
      ::
      [%bazaar @ @ ~]         :: The space level watch subscription
        =/  host              `@p`(slav %p i.t.path)
        =/  space-path        `@t`i.t.t.path
        :: https://developers.urbit.org/guides/core/app-school/8-subscriptions#incoming-subscriptions
        ::  recommends crash on permission check or other failure
        =/  path              [host space-path]
        ?>  (check-member:security:core path src.bowl)
        %-  (slog leaf+"{<dap.bowl>}: [on-watch]. {<src.bowl>} subscribing to {<(spat /(scot %p host)/(scot %tas space-path))>}..." ~)
        =/  space-data        (filter-space-data:helpers:bazaar path)
        [%give %fact ~ bazaar-reaction+!>([%joined-bazaar path catalog.space-data stall.space-data])]~
      ::
    ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
      ::
      [%x %app-hash @ ~]     ::  ~/scry/bazaar/app-hash/app-name
        =/  hash  .^(@uv %cz [(scot %p our.bowl) i.t.t.path (scot %da now.bowl) ~])
        ``bazaar-view+!>([%app-hash hash])
      ::
      [%x %catalog ~]     ::  ~/scry/bazaar/catalog
        ``bazaar-view+!>([%catalog catalog.state])
      ::
      [%x %installed ~]   ::  ~/scry/bazaar/installed
        =/  apps          (skim ~(tap by catalog.state) skim-installed:helpers:bazaar:core)
       ``bazaar-view+!>([%installed `catalog:store`(malt apps)])
      ::
      [%x %allies ~]     ::  ~/scry/bazaar/allies
        =/  allies   allies:scry:bazaar:core
        ``bazaar-view+!>([%allies allies])
      ::
      [%x %treaties ship=@ ~]     ::  ~/scry/bazaar/allies
        =/  =ship      (slav %p i.t.t.path)
        =/  treaties   (treaties:scry:bazaar:core ship %.y)
        ~&  >  [treaties]
        ``bazaar-view+!>([%treaties treaties])
      ::
      ::
      [%x %version ~]     ::  ~/scry/bazaar/version
        :: can't search for %realm in our app catalog, since we skip our own desk
        =/  dok  (find-docket:helpers:bazaar:core %realm)
        ?~  dok  ``json+!>(~)
        ``bazaar-view+!>([%version version.u.dok])
      ::
      [%x %pikes ~]     ::  ~/scry/bazaar/pikes
        =/  peaks      get-pikes:core
        ~&  >  [peaks]
        ~
        :: ``bazaar-view+!>([%treaties treaties])
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    =/  wirepath  `path`wire
    ?+    wire  (on-agent:def wire sign)
      [%spaces ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to spaces" ~)  `this
            ~&  >>>  "{<dap.bowl>}: spaces subscription failed"
            `this
      ::
          %kick
            ~&  >  "{<dap.bowl>}: spaces kicked us, resubscribing..."
            :_  this
            :~  [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
            ==
      ::
          %fact
            ?+    p.cage.sign   (on-agent:def wire sign)
                  %spaces-reaction
                =^  cards  state
                  (reaction:spaces:core !<(=reaction:spaces-store q.cage.sign))
                [cards this]
                ::
                  %visa-reaction
                =^  cards  state
                  (reaction:visas:core !<(=reaction:vstore q.cage.sign))
                [cards this]
            ==
        ==

      [%docket ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to docket" ~)  `this
            ~&  >>>  "{<dap.bowl>}: docket/charges subscription failed"
            `this
      ::
          %kick
            ~&  >  "{<dap.bowl>}: docket/charges kicked us, resubscribing..."
            :_  this
            :~  [%pass /docket %agent [our.bowl %docket] %watch /charges]
            ==
      ::
          %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %charge-update
                  =^  cards  state
                    (on:ch:core !<(=charge-update:docket q.cage.sign))
                  [cards this]
            ==
        ==

      [%treaties ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to /treaties" ~)  `this
            ~&  >>>  "{<dap.bowl>}: /treaties subscription failed"
            `this
      ::
          %kick
            ~&  >  "{<dap.bowl>}: /treaties kicked us, resubscribing..."
            :_  this
            :~  [%pass /treaties %agent [our.bowl %treaty] %watch /treaties]
            ==
      ::
          %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %treaty-update-0
                  =^  cards  state
                    (treaty-update:core !<(=update:treaty:treaty q.cage.sign))
                  [cards this]
            ==
        ==

      [%allies ~]
        ?+    -.sign  (on-agent:def wire sign)
          %watch-ack
            ?~  p.sign  %-  (slog leaf+"{<dap.bowl>}: subscribed to /allies" ~)  `this
            ~&  >>>  "{<dap.bowl>}: /allies subscription failed"
            `this
      ::
          %kick
            ~&  >  "{<dap.bowl>}: /allies kicked us, resubscribing..."
            :_  this
            :~  [%pass /allies %agent [our.bowl %treaty] %watch /allies]
            ==
      ::
          %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %ally-update-0
                  =^  cards  state
                    (ally-update:core !<(=update:ally:treaty q.cage.sign))
                  [cards this]
            ==
        ==
      ::  only space members will sub to this
      [%bazaar @ @ ~]
          ?+    -.sign  (on-agent:def wire sign)
            %watch-ack
              ?~  p.sign  `this
              ~&  >>>  "{<dap.bowl>}: bazaar subscription failed"
              `this
            %kick
              =/  =ship       `@p`(slav %p i.t.wire)
              =/  space-pth   `@t`i.t.t.wire
              ~&  >  "{<dap.bowl>}: bazaar kicked us, resubscribing... {<ship>} {<space-pth>}"
              =/  watch-path      [/bazaar/(scot %p ship)/(scot %tas space-pth)]
              :_  this
              :~  [%pass watch-path %agent [ship %bazaar] %watch watch-path]
              ==
            %fact
              ?+    p.cage.sign  (on-agent:def wire sign)
                  %bazaar-reaction
                  =^  cards  state
                    (reaction:bazaar:core !<(=reaction:store q.cage.sign))
                  [cards this]
              ==
          ==
      ==
  ::
  ::  on-arvo:
  ::
  ::    [%tire ~]:
  ::    requires: `[%tire p=(unit ~)]`
  ::      > note: `~ turns on ~ turns off sub
  ::
  ::      > note: likely a stub for future controls
  ::              e.g. `(unit desk)` to subscribe to
  ::              just one desk.
  ::    handles: tire information from clay
  ::             returns an (each rock wave)
  ::
  ::    +$  rock  (map desk [=zest wic=(set weft)])
  ::    +$  wave
  ::      $%  [wait =desk =weft]
  ::          [%warp =desk =weft]
  ::          [%zest =desk =zest]
  ::      ==
  ::    +$  desk  @tas
  ::    +$  zest  $~(%dead ?(%dead %live %held))
  ::    +$  weft  [lal=@tas num=@ud]  :: kelvin ver.
  ::
  ++  on-arvo
    |=  [wir=wire sig=sign-arvo]
    ?>  ?=([%tire ~] wir)
    |^  ^-  (quip card _this)
      =^  cards  state
        ?>  ?=([%clay %tire *] sig)
        ?-  -.p.sig
          %&  (on-rock p.p.sig)
          %|  (on-wave p.p.sig)
        ==
      [cards this]
    ::  +on-rock:  handles rock:tire from kiln, see XX
    ::
    ++  on-rock
      |=  =rock:tire:clay
      ^-  (quip card _state)
      :: ~&  >>  "{<dap.bowl>}: [on-rock] rock={<rock>}"
      =+  peaks=get-pikes:core
      =;  catalog-apps=catalog:store
        `state(catalog (~(uni by catalog.state) catalog-apps))
      :: %-  (slog leaf+"{<dap.bowl>}: [on-rock]" ~)
      :: %-  (slog leaf+"     rock={<rock>}" ~)
      :: %-  (slog leaf+"     peaks={<peaks>}" ~)
      %-  ~(rep by rock)
      |=  [[=desk z=zest:clay wic=(set weft)] cat=catalog:store]
      ?~  app=(~(get by catalog.state) desk)  cat
      ?>  ?=(%urbit -.u.app)
      ::  XX: should we only act on some zests?
      ::  XX: should we only act if we have a peak?
      ?~  pyk=(~(get by peaks) desk)  cat
      ?.  =(%live z)
        ?.  =(%held z)  cat
        cat
      =.  host.u.app  ?~(sync.u.pyk ~ `ship.u.sync.u.pyk)
      :: ~&  >>  "{<dap.bowl>}: %rock [app-install-update] {<[host.u.app install-status.u.app]>}"
      (~(put by cat) `app-id:store`desk u.app)
    ::  +on-wave: handles wave:tire from kiln, see XXs
    ::
    ::    $%(wait+[=desk =weft] warp+[=desk =weft] zest+[=desk =weft]
    ::
    ++  on-wave
      |=  =wave:tire:clay
      ^-  (quip card _state)
      :: ~&  >>  "{<dap.bowl>}: [on-wave] wave={<wave>}"
      =+  peaks=get-pikes:core
      :: ~&  >>  "{<dap.bowl>}: [on-wave] peaks={<peaks>}"
      :: %-  (slog leaf+"{<dap.bowl>}: [on-wave]. " ~)
      :: %-  (slog leaf+"    wave={<wave>}" ~)
      :: %-  (slog leaf+"    peaks={<peaks>}" ~)
      ?-  -.wave
        %wait  `state  ::  XX: blocked - take action?
        %warp  `state  ::  XX: unblocked - take action?
      ::
          %zest
        ?~  app=(~(get by catalog.state) desk.wave)  `state
        ?>  ?=(%urbit -.u.app)
        ?-  zest.wave
        ::  XX: is it right to no-op here?
          %dead
            ?~  pyk=(~(get by peaks) desk.wave)  `state
            :: ~&  >>  ["{<dap.bowl>}: %wave %dead" desk.wave install-status.u.app]
            =.  grid-index
              :: if the status is %uninstalled and %dead, then we should remove
              :: the app from the grid index
              ?:  =(%uninstalled install-status.u.app)
                (rem-grid-index:helpers:bazaar:core desk.wave grid-index.state)
              grid-index.state
            :: ~&  >>  "{<dap.bowl>}: %dead [app-install-update] {<[host.u.app install-status.u.app]>}"
            :_  state
            :~  [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update desk.wave +.u.app grid-index])]
            ==
            ::
            %live
          ?~  pyk=(~(get by peaks) desk.wave)  `state
          :: ~&  >>  ["{<dap.bowl>}: %wave %live" desk.wave install-status.u.app]
          =/  syncs=(map [syd=desk her=ship sud=desk] [nun=@ta kid=(unit desk) let=@ud])  get-syncs:core
          =/  desks=(map desk ship)
            %-  ~(rep by syncs)
              |=  [[det=[syd=desk her=ship sud=desk] other=[nun=@ta kid=(unit desk) let=@ud]] acc=(map desk ship)]
              (~(put by acc) sud.det her.det)
          =.  host.u.app              (~(get by desks) desk.wave)
          :: =.  install-status.u.app    %installed
          :: get rid of the pending-install that may have been added
          =/  pending-install         (~(get by pending-installs.state) desk.wave)
          =.  pending-installs.state  ?~(pending-install pending-installs.state (~(del by pending-installs) desk.wave))
          =.  grid-index              (set-grid-index:helpers:bazaar:core desk.wave grid-index.state)
          =.  catalog.state           (~(put by catalog.state) desk.wave u.app)
          :: ~&  >>  "{<dap.bowl>}: %live [app-install-update] {<[host.u.app install-status.u.app]>}"
          :_  state
          :~  [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update desk.wave +.u.app grid-index])]
          ==
        ::
            %held
          ::  %held seems to be hit when the desk exists and there are no updates, so we should
          ::  set the install status to %suspended if it is %uninstalled.
          ?~  pyk=(~(get by peaks) desk.wave)  `state
          ::  if exists in catalog and not installed, set to suspend
          :: ~&  >>  ["{<dap.bowl>}: %wave %held pre-status: " desk.wave u.pyk install-status.u.app]
          =.  install-status.u.app  ?:(=(install-status.u.app %uninstalled) %suspended install-status.u.app)
          :: ~&  >>  ["{<dap.bowl>}: %wave %held post-status: " install-status.u.app]
          =.  host.u.app            ?~(sync.u.pyk ~ `ship.u.sync.u.pyk)
          =.  grid-index            (set-grid-index:helpers:bazaar:core desk.wave grid-index.state)
          :: ~&  >>  "{<dap.bowl>}: %held [app-install-update] {<[host.u.app install-status.u.app]>}"
          :_  state(catalog (~(put by catalog.state) desk.wave u.app))
          :~  [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update desk.wave +.u.app grid-index])]
          ==
        ==
      ==

    --
  ++  on-leave  |=(path `..on-init)
  ++  on-fail ::  |=([term tang] `..on-init)
    |=  [=term =tang]
    ^-  (quip card _this)
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
  :: |=([term tang] `..on-init)
--
|_  [=bowl:gall cards=(list card)]
::
++  core  .
++  bazaar
  |%
  ++  action
    |=  =action:store
    ^-  (quip card _state)
    |^
    ?-  -.action
      %pin               (add-pin +.action)
      %unpin             (rem-pin +.action)
      %reorder-pins      (reorder-pins +.action)
      %recommend         (recommend +.action)
      %unrecommend       (unrecommend +.action)
      %suite-add         (add-suite +.action)
      %suite-remove      (rem-suite +.action)
      %install-app       (install-app +.action)
      %uninstall-app     (uninstall-app +.action)
      %reorder-app       (reorder-app +.action)
      :: sent during onboarding after realm desk is fully installed and ready
      ::  use this opportunity to refresh app-catalog
      %initialize        (initialize +.action)
      %rebuild-catalog   (rebuild-catalog +.action)
      %rebuild-stall     (rebuild-stall +.action)
      %clear-stall       (clear-stall +.action)
      %set-host          (set-host +.action)
      :: testing helper. remove an app from the ship catalog w/o producing any effects
      %delete-catalog-entry  (delete-catalog-entry +.action)
      %add-catalog-entry  (add-catalog-entry +.action)
    ==    ::  +pre: prefix for scries to hood
    ::
    ++  pre  /(scot %p our.bowl)/hood/(scot %da now.bowl)
    ::  +get-sources:  (map desk [ship desk])
    ::
    ++  get-sources
      ^-  (map desk [=ship =desk])
      .^((map @tas [@p @tas]) %gx (welp pre /kiln/sources/noun))
    ::
    ::  $set-host:
    ::    set the host of an app in the catalog
    ++  set-host
      |=  [app-id=desk host=ship]
      ^-  (quip card _state)
      =/  app  (~(get by catalog.state) app-id)
      ?~  app
        ~&  >>>  "{<dap.bowl>}: [set-host] error. {<desk>} not found in app catalog"
        `state
      ?>  ?=(%urbit -.u.app)
      %-  (slog leaf+"{<dap.bowl>} setting host for catalog app {<app-id>} to {<host>}" ~)
      =.  host.u.app          (some host)
      =.  catalog.state       (~(put by catalog.state) app-id u.app)
      =.  grid-index.state    (set-grid-index:helpers:bazaar:core app-id grid-index.state)
      :_  state
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update app-id +.u.app grid-index.state])]
      ==
    ::
    ++  rebuild-catalog
      |=  [args=(map cord cord)]
      ^-  (quip card _state)
      :: %-  (slog leaf+"{<dap.bowl>}: [rebuild-catalog] => {<args>}" ~)
      ::  you can only request this of yourself
      ?.  =(our.bowl src.bowl)
        ~&  >>  "{<dap.bowl>}: [rebuild-catalog] denied. not self."
        `state
      =/  init  (build-catalog:helpers ~)
      :_  state(catalog catalog.init, grid-index grid-index.init, pending-installs ~)
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%rebuild-catalog catalog.init grid-index.init])]
      ==
    ::
    ++  rebuild-stall
      |=  [path=space-path:spaces-store args=(map cord cord)]
      ^-  (quip card _state)
      :: %-  (slog leaf+"{<dap.bowl>}: [rebuild-stall] => {<[path args]>}" ~)
      ::  if we are not the space host, poke space host so it can push updates
      ::   to members
      ?:  (we-host:helpers path)
        ?.  (check-member:security path src.bowl)
          ~&  >>  "{<dap.bowl>}: [rebuild-stall] denied. host received request from non-member."
          `state
        =/  paths               [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
        =/  stal                (~(get by stalls.state) path)
        ?~  stal                `state
        =/  apps                (get-stall-apps:helpers path args)
        ?~  apps                `state
        :_  state
        :~  [%give %fact paths bazaar-reaction+!>([%rebuild-stall path u.apps u.stal])]
        ==
      ::
      ?.  (check-member:security path our.bowl)
        ~&  >>  "{<dap.bowl>}: [rebuild-stall] denied. not owner, admin, or member of space"
        `state
      ::
      :_  state
      :~  [%pass / %agent [ship.path %bazaar] %poke bazaar-action+!>([%rebuild-stall path args])]
      ==
    ::
    ++  clear-stall
      |=  [path=space-path:spaces-store args=(map cord cord)]
      ^-  (quip card _state)
      :: %-  (slog leaf+"{<dap.bowl>}: [clear-stall] => {<[path args]>}" ~)
      ::  if we are not the space host, poke space host so it can push updates
      ::   to members
      ?:  (we-host:helpers path)
        ?.  (check-member:security path src.bowl)
          ~&  >>  "{<dap.bowl>}: [clear-stall] denied. host received request from non-member."
          `state
        =/  paths               [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
        =/  stal                (clear-stall:helpers path args)
        ?~  stal                `state
        =.  stalls.state        (~(put by stalls.state) path u.stal)
        :_  state
        :~  [%give %fact paths bazaar-reaction+!>([%clear-stall path])]
        ==
      ::
      ?.  (check-member:security path our.bowl)
        ~&  >>  "{<dap.bowl>}: [clear-stall] denied. not owner, admin, or member of space"
        `state
      ::
      :_  state
      :~  [%pass / %agent [ship.path %bazaar] %poke bazaar-action+!>([%clear-stall path args])]
      ==
    ::
    ++  add-pin
      |=  [path=space-path:spaces-store =app-id:store index=(unit @ud)]
      ?>  =(our.bowl src.bowl)
      =/  upd-docks=dock:store      (~(gut by docks.state) path ~)
      =/  index                     ?~(index (lent upd-docks) u.index)
      =/  exists-at                 (find [app-id]~ upd-docks)
      ?~  exists-at                 ::  should only pin if it doesnt exist
        =.  upd-docks               (into upd-docks index app-id)
        =.  docks.state             (~(put by docks.state) [path upd-docks])
        :_  state
        [%give %fact [/updates ~] bazaar-reaction+!>([%dock-update path upd-docks])]~
      `state
    ::
    ++  reorder-pins
      |=  [path=space-path:spaces-store =dock:store]
      ?>  =(our.bowl src.bowl)
      =.  docks.state             (~(put by docks.state) [path dock])
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%dock-update path dock])]~
    ::
    ++  rem-pin
      |=  [path=space-path:spaces-store =app-id:store]
      ?>  =(our.bowl src.bowl)
      =/  upd-docks                 (~(got by docks.state) path)
      =/  index                     (find [app-id]~ upd-docks)
      ?~  index                     `state
      =.  upd-docks                 (oust [(need index) 1] upd-docks)
      =.  docks.state               (~(put by docks.state) [path upd-docks])
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%dock-update path upd-docks])]~
    ::
    ++  add-suite
      |=  [path=space-path:spaces-store =app-id:store index=@ud]
      =/  app  (~(got by catalog.state) app-id)
      ?.  (is-host:core ship.path)
        (member-add-suite path app-id app index)
      (host-add-suite path app-id app index)
      ::
      ++  member-add-suite
        |=  [path=space-path:spaces-store =app-id:store =app:store index=@ud]
        ?>  (check-admin:security path src.bowl)
        :_  state
        [%pass / %agent [ship.path %bazaar] %poke bazaar-interaction+!>([%suite-add path app-id app index])]~
      ::
      ++  host-add-suite
        |=  [path=space-path:spaces-store =app-id:store =app:store index=@ud]
        =/  stall=stall:store   (~(gut by stalls.state) path [suite=~ recommended=~])
        =.  suite.stall         (~(put by suite.stall) [index app-id])
        =.  stalls.state        (~(put by stalls.state) [path stall])
        =/  paths               [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
        :_  state
        [%give %fact paths bazaar-reaction+!>([%suite-added path app-id app index])]~
    ::
    ++  rem-suite
      |=  [path=space-path:spaces-store index=@ud]
      ?.  (is-host:core ship.path)
        (member-remove-suite path index)
      (host-remove-suite path index)
      ::
      ++  member-remove-suite
        |=  [path=space-path:spaces-store index=@ud]
        ?>  (check-admin:security path src.bowl)
        :_  state
        [%pass / %agent [ship.path %bazaar] %poke bazaar-action+!>([%suite-remove path index])]~
      ::
      ++  host-remove-suite
        |=  [path=space-path:spaces-store index=@ud]
        =/  stall               (~(got by stalls.state) path)
        =.  suite.stall         (~(del by suite.stall) index)
        =.  stalls.state        (~(put by stalls.state) [path stall])
        =/  paths               [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
        :_  state
        [%give %fact paths bazaar-reaction+!>([%suite-removed path index])]~
    ::
    ++  install-app
      |=  [=ship =desk]
      ^-  (quip card _state)
      ?>  =(our.bowl src.bowl)
      :: is an installation already happening for this desk?
      =/  pending-install         (~(get by pending-installs.state) desk)
      ?.  =(~ pending-install)
        ~&  >>  "{<dap.bowl>}: skipping {<[ship desk]>} install. pending installation running..."
        `state
      =/  app                     (~(get by catalog.state) desk)
      ?~  app                     (docket-install ship desk ~)
      ?>  ?=(%urbit -.u.app)
      =.  grid-index              (set-grid-index:helpers:bazaar:core desk grid-index.state)
      :: ~&  >>  [%install-app app]
      =.  install-status.u.app
        ?:  =(%uninstalled install-status.u.app)  %suspended
        ?:  =(%desktop install-status.u.app)
          ::  @trent - we can add a check to clay for the desk existing
          ::  and that would do the same skip of suspended that the fresh install does
          =+  peaks=get-pikes:core
          ?.((~(has by peaks) desk) %started install-status.u.app)
        %started
      =.  host.u.app              (some ship)
      =.  catalog.state           (~(put by catalog.state) desk u.app)
      (docket-install ship desk [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update desk +.u.app grid-index.state])]~)
    ::
    ++  reorder-app
      |=  [=app-id:store index=@ud]
      ^-  (quip card _state)
      ?>  =(our.bowl src.bowl)
      =/  new-grid-index  (mov-grid-index:helpers:bazaar:core app-id index grid-index.state)
      =.  grid-index  new-grid-index
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%reorder-grid-index new-grid-index])]~
    ::
    ++  docket-install
      |=  [=ship =desk cards=(list card)]
      ^-  (quip card _state)
      =/  allies         allies:scry:bazaar
        ?.  (~(has by allies) ship)
          %-  (slog leaf+"{<ship>} not an ally. adding {<ship>} as ally..." ~)
          ::  queue this installation request, so that once alliance is complete,
          ::  we can automatically kick off the install
          =.  pending-installs.state  (~(put by pending-installs.state) desk ship)
          :_  state
          (snoc cards [%pass / %agent [our.bowl %treaty] %poke ally-update-0+!>([%add ship])])
        :_  state
        (snoc cards [%pass / %agent [our.bowl %docket] %poke docket-install+!>([ship desk])])
    ::
    ++  initialize
      |=  [args=(map cord cord)]
      ^-  (quip card _state)
      %-  (slog leaf+"{<dap.bowl>}: initializing bazaar..." ~)
      =^  cards  state  initialize:helpers:bazaar:core
      :_  state
      =-  (welp - cards)
      %+  turn  ~(tap in ~(key by wex.bowl))
      |=  [=wire =ship =term]
      ^-  card
      [%pass wire %agent [ship term] %leave ~]
    ::
    ++  uninstall-app
      |=  [=desk]
      ^-  (quip card _state)
      ?>  =(our.bowl src.bowl)
      =/  app                       (~(got by catalog.state) desk)
      ?>  ?=(%urbit -.app)
      =.  install-status.app        %uninstalled
      =.  catalog.state             (~(put by catalog.state) desk app)
      :: =.  grid-index.state          (rem-grid-index:helpers:bazaar:core desk grid-index.state)
      :: ~&  >  ['uninstall-app' (rem-grid-index:helpers:bazaar:core desk grid-index.state)]
      :_  state
      :: ::  if apps have come in from other ships (e.g. recommending) and do not exist in
      :: ::   our catalog, they will not exist in docket. only informat
      :: ?.  (is-app-installed:helpers:bazaar:core desk)   ~
      [%pass / %agent [our.bowl %docket] %poke docket-uninstall+!>([desk])]~
    ::
    ++  recommend
      |=  [=app-id:store]
      ?>  =(our.bowl src.bowl)
      :: ~&  >  ['recommend' our.bowl src.bowl]
      =.  recommendations.state     (~(put in recommendations.state) app-id)
      =/  app                       (~(got by catalog.state) app-id)
      =/  updated-stalls=[=stalls:store cards=(list card)]
      %-  ~(rep by stalls.state)
        |=  [[path=space-path:spaces-store =stall:store] result=[=stalls:store cards=(list card)]]
        ?:  =('our' space.path)  result  ::  return result if our
        ?:  (we-host:helpers path)
          :: ~&  >  ['we host, set recommended']
          =/  rec-members             (~(gut by recommended.stall) app-id ~)
          =.  rec-members             (~(put in rec-members) our.bowl)
          =.  recommended.stall       (~(put by recommended.stall) [app-id rec-members])
          =.  stalls.result           (~(put by stalls.result) [path stall])
          =/  paths                   [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
          =.  cards.result            (snoc cards.result [%give %fact paths bazaar-reaction+!>([%stall-update path stall (some [app-id (some app)])])])
          result
        ::  we need to poke host
        =.  cards.result            (snoc cards.result [%pass / %agent [ship.path %bazaar] %poke bazaar-interaction+!>([%member-recommend path app-id app])])
        result
      =.  stalls.state            (~(uni by stalls.state) stalls.updated-stalls)
      =.  cards.updated-stalls    (snoc cards.updated-stalls [%give %fact [/updates ~] bazaar-reaction+!>([%recommended app-id stalls.state])])
      :: ~&  >>  "{<cards.updated-stalls>}"
      :_  state
      cards.updated-stalls
    ::
    ++  unrecommend
      |=  [=app-id:store]
      ?>  =(our.bowl src.bowl)
      =.  recommendations.state   (~(del in recommendations.state) app-id)
      =/  updated-stalls=[=stalls:store cards=(list card)]
      %-  ~(rep by stalls.state)
        |=  [[path=space-path:spaces-store =stall:store] result=[=stalls:store cards=(list card)]]
        ?:  =('our' space.path)  result  ::  return result if our
        ?:  (we-host:helpers path)
          =/  rec-members             (~(gut by recommended.stall) app-id ~)
          =.  rec-members             (~(del in rec-members) our.bowl)
          =.  recommended.stall
            ?:  =(~(wyt in rec-members) 0)
              (~(del by recommended.stall) app-id)
            (~(put by recommended.stall) [app-id rec-members])
          =.  stalls.result           (~(put by stalls.result) [path stall])
          =/  paths                   [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
          =.  cards.result            (snoc cards.result [%give %fact paths bazaar-reaction+!>([%stall-update path stall (some [app-id ~])])])
          result
        =.  cards.result            (snoc cards.result [%pass / %agent [ship.path %bazaar] %poke bazaar-interaction+!>([%member-unrecommend path app-id])])
        result
      =.  stalls.state            (~(uni by stalls.state) stalls.updated-stalls)
      =.  cards.updated-stalls    (snoc cards.updated-stalls [%give %fact [/updates ~] bazaar-reaction+!>([%unrecommended app-id stalls.state])])
      :_  state
      cards.updated-stalls
    ::
    ::
    ::  $delete-catalog-entry
    ::   remove an app entry from the ship's catalog and produce no effects
    ++  delete-catalog-entry
      |=  [=app-id:store]
      ^-  (quip card _state)
      ?:  (~(has by catalog.state) app-id)
        =.  catalog.state  (~(del by catalog.state) app-id)
        `state
      `state
    ::
    ::
    ::  $add-catalog-entry
    ::   add a new native-app to the catalog. does not currently support %urbit or %web apps.
    ++  add-catalog-entry
      |=  [=app-id:store =native-app:store]
      ^-  (quip card _state)
      :: %-  (slog leaf+"{<dap.bowl>}: [add-catalog-entry] {<app-id>}" ~)
      =.  catalog.state                  (~(put by catalog.state) app-id [%native native-app])
      =.  grid-index.state               (set-grid-index:helpers:bazaar:core app-id grid-index.state)
      `state
    --
  ++  reaction
    |=  [rct=reaction:store]
    ^-  (quip card _state)
    |^
    ?+  -.rct             `state
      %recommended        (on-rec +.rct)
      %unrecommended      (on-unrec +.rct)
      %suite-added        (on-suite-add +.rct)
      %suite-removed      (on-suite-rem +.rct)
      %joined-bazaar      (on-joined +.rct)
      %stall-update
        :: ~&  >>  "{<+.rct>}"
        (on-stall-update +.rct)
      %rebuild-catalog    (on-rebuild-catalog +.rct)
      %rebuild-stall      (on-rebuild-stall +.rct)
      %clear-stall        (on-clear-stall +.rct)
    ==
    ::
    ++  on-rec
      |=  [app-id=@tas =stalls:store]
      `state
    ::
    ++  on-unrec
      |=  [app-id=@tas =stalls:store]
      `state
    ::
    ++  on-suite-add
      |=  [path=space-path:spaces-store app-id=@tas =app:store index=@ud]
      ?:  =(is-host:core ship.path)
        `state
      :: the host is informing us that it's added a new app to the space suite
      =/  updates             (add-to-desktop:helpers:bazaar:core app-id app)
      =.  catalog.state       catalog.updates
      =/  stall               (~(got by stalls.state) path)
      =.  suite.stall         (~(put by suite.stall) [index app-id])
      =.  stalls.state        (~(put by stalls.state) [path stall])
      :: ~&  >>  "{<app.updates>}"
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%suite-added path app-id app.updates index])]~
    ::
    ++  on-suite-rem
      |=  [path=space-path:spaces-store index=@ud]
      ?:  =(is-host:core ship.path)
        `state
      =/  stall               (~(got by stalls.state) path)
      =.  suite.stall         (~(del by suite.stall) index)
      =.  stalls.state        (~(put by stalls.state) [path stall])
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%suite-removed path index])]~
    ::
    ++  on-joined
      |=  [path=space-path:spaces-store =catalog:store =stall:store]
      =.  stalls.state        (~(put by stalls.state) [path stall])
      =.  docks.state         (~(put by docks.state) [path [~]])
      =/  new-catalog-apps=(list [=app-id:store =app:store])
        %-  ~(rep by catalog)
          |=  [entry=[=app-id:store =app:store] result=(list [=app-id:store =app:store])]
          ?:  (~(has by catalog.state) app-id.entry)  ::  if we already have the app
            =.  app.entry  (~(got by catalog.state) app-id.entry)
            (snoc result entry)
          =/  entry
            ?+  -.app.entry  entry
              %urbit
                =.  install-status.app.entry  %desktop
                entry
            ==
          (snoc result entry)
      =/  new-catalog-apps    (malt new-catalog-apps)
      =.  catalog.state       (~(uni by catalog.state) new-catalog-apps)
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%joined-bazaar path new-catalog-apps stall])]~

    ::
    ++  what
      |=  [det=(unit [=app-id:store app=(unit app:store)])]
      ^-  @tas
      ?~  det        %none
      ?~  app.u.det  %delete
      %add
    ::
    ++  on-stall-update
      |=  [path=space-path:spaces-store =stall:store det=(unit [=app-id:store app=(unit app:store)])]
      ::  are we deleting the app, or adding it?
      :: %-  (slog leaf+"{<dap.bowl>}: [on-stall-update] {<det>}" ~)
      =/  wha  (what det)
      =/  updates=[det=(unit [=app-id:store app=(unit app:store)]) =catalog:store]
        ?+  wha     [det catalog.state]
          %none     [det catalog.state]
          ::
          %delete   [det catalog.state]
          ::
          %add
            =/  det  (need det)
            =/  app  (need app.det)
            =/  app
              ?:  (~(has by catalog.state) app-id.det)
                :: if the app *is* in the catalog, leave it's status as is
                (~(got by catalog.state) app-id.det)
              ::  if the app is not in our catalog, update it's installed
              ::   status relative to our ship . %desktop
              ?>  ?=(%urbit -.app)
              ::  place it on the desktop where it can then be installed by an end-user in UI
              =.  install-status.app  %desktop
              app
            [(some [app-id.det (some app)]) (~(put by catalog.state) app-id.det app)]
        ==
      ::
      =.  catalog.state       catalog.updates
      =.  stalls.state        (~(put by stalls.state) [path stall])
      :_  state
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%stall-update path stall det.updates])]
      ==
    ::
    ++  on-rebuild-catalog
      |=  [=catalog:store =grid-index:store]
      :_  state
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%rebuild-catalog path catalog grid-index])]
      ==
    ::
    ++  on-rebuild-stall
      |=  [path=space-path:spaces-store =catalog:store =stall:store]
      ::  only process if received from space host or admin
      ?.  (~(has by stalls.state) path)  `state
      =.  stalls.state    (~(put by stalls.state) path stall)
      =.  catalog.state   (~(gas by catalog) ~(tap by catalog.state))
      :_  state
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%rebuild-stall path catalog stall])]
      ==
    ::
    ++  on-clear-stall
      |=  [path=space-path:spaces-store]
      =/  stal                (clear-stall:helpers path ~)
      ?~  stal                `state
      =.  stalls.state        (~(put by stalls.state) path u.stal)

      :_  state
      :~  [%give %fact [/updates ~] bazaar-reaction+!>([%clear-stall path])]
      ==
    --
  ++  interaction
    |=  [itc=interaction:store]
    ^-  (quip card _state)
    |^
    ?-  -.itc
      %member-recommend          (member-recommend +.itc)
      %member-unrecommend        (member-unrecommend +.itc)
      %suite-add                 (suite-add +.itc)
    ==
    ::
    ++  member-recommend
      |=  [path=space-path:spaces-store =app-id:store =app:store]
      ?>  (check-member:security path src.bowl)
      :: ~&  >  ['recommending' path src.bowl app-id]
      =/  stall                   (~(got by stalls.state) path)
      =/  rec-members             (~(gut by recommended.stall) app-id ~)
      =.  rec-members             (~(put in rec-members) src.bowl)
      =.  recommended.stall       (~(put by recommended.stall) [app-id rec-members])
      =.  stalls.state            (~(put by stalls.state) [path stall])
      ::  per #319, ensure installed status is relative to our ship/catalog
      =/  entry                   (~(get by catalog.state) app-id)
      ::  default to %desktop (will force download button in UI)
      =/  local-install-status    ?~(entry %desktop (get-install-status:helpers:bazaar:core u.entry))
      ::  do not overwrite our current catalog entry with the recommend app; ensure
      ::   only overwriting the install-status
      =/  our-app                 ?~(entry app u.entry)
      =/  our-app
      ?+  -.our-app  our-app
        %urbit
          =.  install-status.our-app  local-install-status
          our-app
      ==
      =.  catalog.state           (~(put by catalog.state) [app-id our-app])
      =/  paths                   [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
      :_  state
      :~
        [%give %fact paths bazaar-reaction+!>([%stall-update path stall (some [app-id (some our-app)])])]
      ==
    ::
    ++  member-unrecommend
      |=  [path=space-path:spaces-store =app-id:store]
      ?>  (check-member:security path src.bowl)
      :: ~&  >  ['unrecommending' path src.bowl app-id]
      =/  stall                   (~(got by stalls.state) path)
      =/  rec-members=member-set:store
        ?:  (~(has by recommended.stall) app-id)
          =/  members     (~(got by recommended.stall) app-id)
          =.  members     (~(del in members) src.bowl)
          members
        ~
      =.  recommended.stall
        ?:  =(~(wyt in rec-members) 0)
          (~(del by recommended.stall) app-id)
        (~(put by recommended.stall) [app-id rec-members])
      =.  stalls.state            (~(put by stalls.state) [path stall])
      =/  paths                   [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
      :_  state
      [%give %fact paths bazaar-reaction+!>([%stall-update path stall (some [app-id ~])])]~
    ::
    ::  this should only ever come into the space host (see "lite" versions add-suite above)
    ++  suite-add
      |=  [path=space-path:spaces-store =app-id:store =app:store index=@ud]
      ?.  (is-host:core ship.path)
        %-  (slog leaf+"{<dap.bowl>}: suite-add-full should only be used to inform the host. use suite-add if acting on behalf of a member ship" ~)
        [~ state]
      (host-suite-add path app-id app index)
      ::
      ++  host-suite-add
        |=  [path=space-path:spaces-store =app-id:store =app:store index=@ud]
        =/  updates             (add-to-desktop:helpers:bazaar:core app-id app)
        =.  catalog.state       catalog.updates
        =/  stall=stall:store   (~(gut by stalls.state) path [suite=~ recommended=~])
        =.  suite.stall         (~(put by suite.stall) [index app-id])
        =.  stalls.state        (~(put by stalls.state) [path stall])
        =/  paths               [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
        :_  state
        [%give %fact paths bazaar-reaction+!>([%suite-added path app-id app.updates index])]~
    --
  ++  scry
    |%
    ++  allies
      ^-  allies:ally:treaty
      =/  allies  .^(update:ally:treaty %gx /(scot %p our.bowl)/treaty/(scot %da now.bowl)/allies/noun)
      ?>  ?=(%ini -.allies)
      init.allies
    ::
    ++  treaties
      |=  [shp=ship filter=?]
      =/  hidden     `(set desk)`(silt ~['realm' 'realm-wallet' 'courier' 'garden'])
      =/  treaties  .^(update:treaty:treaty %gx /(scot %p our.bowl)/treaty/(scot %da now.bowl)/treaties/(scot %p shp)/noun)
      :: ~&  >  [treaties]
      ?>  ?=(%ini -.treaties)
      ?:  =(filter %.n)  init.treaties
      %-  malt
      %+  skip  ~(tap by init.treaties)
        |=  [[trty-ship=ship =desk] trty=treaty:treaty]
        ?:  ?&  =(trty-ship shp)
                (~(has in hidden) desk)
            ==  %.y  %.n
    ::
    ++  config
      |=  =desk
      |^
      =/  config
        ?:  config-exists
          .^(config:store %cx scry-path)
        :*  size=[10 10]
            titlebar-border=%.y
            show-titlebar=%.y
        ==
      =?  size.config
          ?|  (lth -.size.config 1)
              (lth +.size.config 1)
              (gth -.size.config 10)
              (gth +.size.config 10)
          ==
        [10 10]
      config
      ++  scry-path  `path`/(scot %p our.bowl)/[desk]/(scot %da now.bowl)/config/realm
      ++  exists-scry-path  `path`/(scot %p our.bowl)/[desk]/(scot %da now.bowl)
      ++  config-exists
        ?:  =(0 ud:.^(cass:clay %cw exists-scry-path))  %.n
        .^(? %cu scry-path)
      --
    ::
    --
  ++  helpers
    |%
    ::
    ++  initialize
      ^-  (quip card _state)
      =/  init                          (build-catalog ~)
      =.  grid-index.state              grid-index.init
      =/  spaces-scry                   .^(view:spaces-store %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/all/noun)
      ?>  ?=(%spaces -.spaces-scry)
      =/  spaces                        spaces.spaces-scry
      =/  stalls
        %+  turn  ~(tap by spaces)
          |=  [path=space-path:spaces-store =space:spaces-store]
          [path [suite=~ recommended=~]]
      =/  docks
        %+  turn  ~(tap by spaces)
          |=  [path=space-path:spaces-store =space:spaces-store]
          [path [~]]
      =.  stalls.state        (~(gas by stalls.state) stalls)
      =.  docks.state         (~(gas by docks.state) docks)
      =.  catalog.state       catalog.init
      :_  state
      :~  [%pass /docket %agent [our.bowl %docket] %watch /charges]
          [%pass /treaties %agent [our.bowl %treaty] %watch /treaties]
          [%pass /allies %agent [our.bowl %treaty] %watch /allies]
          [%pass /spaces %agent [our.bowl %spaces] %watch /updates]
          [%pass /tire %arvo %c %tire `~]
      ==
    ::
    ++  build-catalog
      |=  [args=(map cord cord)]
      =/  =charge-update:docket         .^(charge-update:docket %gx /(scot %p our.bowl)/docket/(scot %da now.bowl)/charges/noun)
      ?>  ?=([%initial *] charge-update)
      =/  our-space                     [our.bowl 'our']
      =/  init                          (init-catalog:helpers:bazaar:core initial.charge-update)
      =|  =native-app:store
        =.  title.native-app            'Relic Browser'
        =.  color.native-app            '#92D4F9'
        =.  icon.native-app             'AppIconCompass'
        =.  config.native-app           [size=[7 10] titlebar-border=%.y show-titlebar=%.n]
      =.  catalog.init                  (~(put by catalog.init) %os-browser [%native native-app])
      =.  grid-index.init               (set-grid-index:helpers:bazaar:core %os-browser grid-index.init)
      =|  =native-app:store
        =.  title.native-app            'Settings'
        =.  color.native-app            '#ACBCCB'
        =.  icon.native-app             'AppIconSettings'
        =.  config.native-app           [size=[5 6] titlebar-border=%.y show-titlebar=%.n]
      =.  catalog.init                  (~(put by catalog.init) %os-settings [%native native-app])
      =.  grid-index.init               (set-grid-index:helpers:bazaar:core %os-settings grid-index.init)
      =|  =native-app:store
        =.  title.native-app            'Lexicon'
        =.  color.native-app            '#EEDFC9'
        =.  icon.native-app             'AppIconLexicon'
        =.  config.native-app           [size=[3 7] titlebar-border=%.n show-titlebar=%.y]
      =.  catalog.init                  (~(put by catalog.init) %os-lexicon [%native native-app])
      =.  grid-index.init               (set-grid-index:helpers:bazaar:core %os-lexicon grid-index.init)
      =|  =native-app:store
        =.  title.native-app            'Trove'
        =.  color.native-app            '#DCDCDC'
        =.  icon.native-app             'AppIconTrove'
        =.  config.native-app           [size=[7 8] titlebar-border=%.n show-titlebar=%.y]
      =.  catalog.init                  (~(put by catalog.init) %os-trove [%native native-app])
      =.  grid-index.init               (set-grid-index:helpers:bazaar:core %os-trove grid-index.init)
      init
    ::
    ++  get-stall-apps
      |=  [=space-path:spaces-store args=(map cord cord)]
      ^-  (unit catalog:store)
      =/  stal  (~(get by stalls.state) space-path)
      ?~  stal
        ~&  >>>  "{<dap.bowl>}: [get-stall-apps] error. space {<space-path>} does not exist."
        ~
      :: extract all app ids across both the suite and recommended lists
      =/  app-ids
        %+  weld
          %+  turn  ~(tap by recommended.u.stal)
            |=  [=app-id:store =member-set:store]
            app-id
          %+  turn  ~(tap by suite.u.stal)
            |=  [idx=@ud =app-id:store]
            app-id
      :: build a catalog from the app ids
      %-  some
      %-  malt
        %+  turn
        %+  skim  app-ids
          |=  [=app-id:store]
          =/  app  (~(get by catalog.state) app-id)
          ?~  app
            ~&  >>  "{<dap.bowl>}: [rebuild-stall] warn. app {<app-id>} missing from catalog."
            %.n
          %.y
        |=  [=app-id:store]
        [app-id (~(got by catalog.state) app-id)]
    ::
    ++  clear-stall
      |=  [=space-path:spaces-store args=(map cord cord)]
      ^-  (unit stall:store)
      =/  stal  (~(get by stalls.state) space-path)
      ?~  stal
        ~&  >>>  "{<dap.bowl>}: [rebuild-stall] error. space {<space-path>} does not exist."
        ~
      (some [suite=~ recommended=~])
    ::
    ++  add-to-desktop
      |=  [=app-id:store =app:store]
      ::  return the updated app state and app catalog
      ^-  [=app:store =catalog:store]
      =/  app-entry                 (~(get by catalog.state) app-id)
      :: =/  app
        ?~  app-entry  :: app is not in the catalog. add it
            ?+  -.app   [app catalog.state]
              %urbit
                =.  install-status.app   %desktop
                [app (~(put by catalog.state) app-id app)]
            ==
          :: app is already in the catalog. leave as is
          [u.app-entry catalog.state]
      :: [app (~(put by catalog.state) app-id app)]
    ::
    ++  is-app-installed
      |=  [=app-id:store]
      ^-  ?
      =/  =charge-update:docket  .^(charge-update:docket %gx /(scot %p our.bowl)/docket/(scot %da now.bowl)/charges/noun)
      ?>  ?=([%initial *] charge-update)
      (~(has by initial.charge-update) app-id)
    ::
    ++  get-install-status
      |=  [=app:store]
      ^-  install-status:store
      ?>  ?=(%urbit -.app)
      install-status.app
    ::
    ++  determine-app-host
      |=  [host=ship =app:store]
      ^-  (unit ship)
      ?>  ?=(%urbit -.app)
      ::  if the app has a glob-reference of %ames, use the ship value as the
      ::   host/origin of the app; otherwise, use the treaty ship
      ?+  -.href.docket.app  (some host)
        ::
        %glob
          ::
          ?+  -.location.glob-reference.href.docket.app  (some host)
            ::
            %ames  (some ship.location.glob-reference.href.docket.app)
          ==
      ==
    ::
    ++  set-grid-index
      |=  [=app-id:store =grid-index:store]
      ^-  grid-index:store
      =/  grid-list         (sort-grid:helpers:bazaar:core grid-index)
      =/  current-index     (find [app-id]~ grid-list)
      ?~  current-index
        ::  if the app is not in the grid, add it to the end
        =/  new-index         (lent grid-list)
        (~(put by grid-index) [new-index app-id])
      grid-index
    ::
    ++  rem-grid-index
      |=  [=app-id:store =grid-index:store]
      ^-  grid-index:store
      =/  grid-list         (sort-grid:helpers:bazaar:core grid-index)
      =/  current-index     (find [app-id]~ grid-list)
      ?~  current-index     grid-index
      =.  grid-list         (oust [u.current-index 1] grid-list)
      =/  new-grid-index
        %+  turn  (gulf 0 (sub (lent grid-list) 1))
          |=  idx=@ud
          =/  app  (snag idx grid-list)
          [idx app]
      `=grid-index:store`(malt new-grid-index)
    ::
    ++  mov-grid-index
      |=  [=app-id:store index=@ud =grid-index:store]
      ^-  grid-index:store
      =/  grid-list         (sort-grid:helpers:bazaar:core grid-index)
      =/  current-index     (find [app-id]~ grid-list)
      ?~  current-index     !!
      :: it's already in the grid. remove it from its current position
      :: then add it to the specified position (not optimal)
      =.  grid-list         (oust [u.current-index 1] grid-list)
      =.  grid-list         (into grid-list index app-id)
      =/  new-grid-index
        %+  turn  (gulf 0 (sub (lent grid-list) 1))
          |=  idx=@ud
          =/  app  (snag idx grid-list)
          [idx app]
      `=grid-index:store`(malt new-grid-index)
    ::
    ++  sort-grid
      |=  [=grid-index:store]
      ^-  (list @tas)
      =/  sorted-grid
        %+  sort  ~(tap by grid-index)
          |=  [a=[idx=@ud app=@tas] b=[idx=@ud app=@tas]]
          (lth idx.a idx.b)
      %+  turn  sorted-grid
        |=  [idx=@ud app=@tas]
        app
    ::
    ++  update-paths
      |=  [path=space-path:spaces-store]
      ?.  =(space.path %our)
        [/update ~]
      [/updates /bazaar/(scot %p ship.path)/(scot %tas space.path) ~]
    ::
    ++  find-docket
      |=  [=desk]
      :: ^-  (unit docket)

      :: =/  =charge-update:docket         .^(charge-update:docket %gx /(scot %p our.bowl)/docket/(scot %da now.bowl)/charges/noun)
      :: ?>  ?=([%initial *] charge-update)
      :: =/  our-space                     [our.bowl 'our']
      :: =/  init                          (init-catalog:helpers:bazaar:core initial.charge-update)
      :: |=  [charges=(map desk charge:docket)]

      =/  =charge-update:docket  .^(charge-update:docket %gx /(scot %p our.bowl)/docket/(scot %da now.bowl)/charges/noun)
      ?>  ?=([%initial *] charge-update)
      =/  chg  (~(get by initial.charge-update) desk)
      ?~  chg  ~
      (some docket.u.chg)
    ::
    ++  init-catalog
      |=  [charges=(map desk charge:docket)]
      =/  hidden     `(set desk)`(silt ~['realm' 'realm-wallet' 'courier' 'garden' 'landscape'])
      =/  syncs=(map [syd=desk her=ship sud=desk] [nun=@ta kid=(unit desk) let=@ud])  get-syncs:core
      =+  peaks=get-pikes:core
      =/  desks=(map desk ship)
        %-  ~(rep by syncs)
          |=  [[det=[syd=desk her=ship sud=desk] other=[nun=@ta kid=(unit desk) let=@ud]] acc=(map desk ship)]
          (~(put by acc) sud.det her.det)
      :: %-  (slog leaf+"{<desks>}" ~)
      ^-  [=catalog:store =grid-index:store]
      %-  ~(rep by charges)
        |:  [[=desk =charge:docket] acc=[catalog=`catalog:store`~ grid-index=`grid-index:store`~]]
        ?:  (~(has in hidden) desk)  acc
        =/  pyk             (~(get by peaks) desk)
        =/  install-status  ?~  pyk  %desktop
          ?-  zest.u.pyk
            %live  %installed
            %held  %suspended
            %dead  %uninstalled
          ==
        =/  sync                (~(get by desks) desk)
        =/  host=(unit ship)    sync
        :: ~&  >>  [desk -.chad.charge install-status]
        [(~(put by catalog.acc) desk [%urbit docket.charge host install-status (config:scry:bazaar:core desk)]) (set-grid-index desk grid-index.acc)]
    ::
    ++  skim-installed
      |=  [=app-id:store =app:store]
      ?:  =(%urbit -.app)
        ?>  ?=(%urbit -.app)
        =(%installed install-status.app)
      %.y  ::  if not urbit app, is installed
    ::
    ++  we-host
      |=  [path=space-path:spaces-store]
      ?:  =('our' space.path)
        %.n
      =(our.bowl ship.path)
    ::
    ++  filter-space-data
      |=  [path=space-path:spaces-store]
      =/  stall=stall:store       (~(got by stalls.state) path)
      =/  suite-apps              ~(val by suite.stall)
      =/  recommended-apps        ~(tap in ~(key by recommended.stall))
      =/  catalog-apps            (weld suite-apps recommended-apps)
      =/  catalog=(list [app-id:store =app:store])
        %+  turn  catalog-apps
        |=  [=app-id:store]
        [app-id (~(got by catalog.state) app-id)]
      [catalog=(malt catalog) stall=stall]
    ::
    ++  is-system-app
      |=  [=app-id:store]
      ^-  ?
      ?:  ?|  =(app-id %courier)
              =(app-id %realm)
              =(app-id %realm-wallet)
              =(app-id %garden)
          ==
      %.y  %.n
    --
  --
::
++  visas
  |%
  ++  reaction
    |=  [rct=reaction:vstore]
    ^-  (quip card _state)
    |^
    ?+  -.rct         `state
      %kicked         (on-member-kicked +.rct)
    ==
    ++  on-member-kicked
      |=  [path=space-path:spaces-store =ship]
      ^-  (quip card _state)
      =/  update-path    /bazaar/(scot %p ship.path)/(scot %tas space.path)
      ?.  (is-host:core ship.path)
        ?:  =(our.bowl ship)      ::  we were kicked
          =.  stalls.state        (~(del by stalls.state) path)
          =.  docks.state         (~(del by docks.state) path)
          :_  state
          [%pass update-path %agent [ship.path %bazaar] %leave ~]~
        ::  another member was kicked
        `state
      =/  stall               (~(got by stalls.state) path)
      =/  cleaned-recs=[=recommended:store]
        %-  ~(rep by recommended.stall)  ::  remove all recommendations from kicked
          |=  [app=[=app-id:store =member-set:store] result=[=recommended:store]]
          =/  rec-members      (~(del in member-set.app) ship)
          =/  recommeded-map
            ?:  =(~(wyt in rec-members) 0)
              (~(del by recommended.result) app-id.app)
            (~(put by recommended.result) [app-id.app rec-members])
          =.  recommended.result    recommeded-map
          result
      ::
      =.  recommended.stall   recommended.cleaned-recs
      =.  stalls.state        (~(put by stalls.state) [path stall])
      :_  state
      :~
        [%give %fact [update-path /updates ~] bazaar-reaction+!>([%stall-update path stall ~])]
        [%give %kick ~[update-path] (some ship)]
      ==
    --
  --
::
++  spaces
  |%
  ++  reaction
    |=  [rct=reaction:spaces-store]
    ^-  (quip card _state)
    |^
    ?+  -.rct         `state
      %add            (on-add +.rct)
      %remove         (on-remove +.rct)
      %remote-space   (on-remote-space +.rct)
    ==
    ::
    ++  on-add
      |=  [space=space:spaces-store members=members:membership-store]
      ^-  (quip card _state)
      =/  recommended=recommended:store
        %-  ~(rep in recommendations.state)  ::  add all of our recs to the created stall
          |=  [=app-id:store result=[=recommended:store]]
          =.  result          (~(put by recommended.result) [app-id (silt ~[our.bowl])])
          result
      =/  stall=stall:store   [suite=~ recommended=recommended]
      =.  stalls.state        (~(put by stalls.state) [path.space stall])
      =.  docks.state         (~(put by docks.state) [path.space [~]])
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%stall-update path.space stall ~])]~
    ::
    ++  on-remove
      |=  [path=space-path:spaces-store]
      ^-  (quip card _state)
      =.  stalls.state        (~(del by stalls.state) path)
      =.  docks.state         (~(del by docks.state) path)
      =/  update-path         /bazaar/(scot %p ship.path)/(scot %tas space.path)
      :_  state
      [%pass update-path %agent [ship.path %bazaar] %leave ~]~
    ::
    ++  on-remote-space   ::  when we join a new space
      |=  [path=space-path:spaces-store =space:spaces-store =members:membership-store]
      ^-  (quip card _state)
      ?:  =(our.bowl ship.path)  `state
      =/  recs=(list card)
        %+  turn  ~(tap in recommendations.state)
          |=  [=app-id:store]
          =/  app  (~(got by catalog.state) app-id)
        [%pass / %agent [ship.path %bazaar] %poke bazaar-interaction+!>([%member-recommend path app-id app])]
      =/  watch-path    [/bazaar/(scot %p ship.path)/(scot %tas space.path)]
      :_  state
      %+  weld  recs
      ^-  (list card)
      ::  it is possible under very odd circumstances that we get kicked
      ::   by the host's bazaar. note that, according to the docs, getting kicked
      ::   can happen automatically by gall under "certain network conditions"
      ::  under this use-case, our %kicked hander (see on-agent) will automatically
      ::   rejoin the remote bazaar which will send out a %remote-space gift.
      ::  when this happened, this %watch below was causing an 'non-unique channel'
      ::  error because the auto %kicked re-%watch had already happened.
      ::  to prevent this, check the outgoing subscriptions on this ship (wex.boat)
      ::   to ensure we are already listening on the wire before attempting the %watch
      ?:  (~(has by wex.bowl) [watch-path ship.path %bazaar])  ~
      :~
        [%pass watch-path %agent [ship.path %bazaar] %watch watch-path]
      ==
    ::
    --
  --
::
++  treaty-update
  |=  [upd=update:treaty:treaty]
  ^-  (quip card _state)
  |^
  ?+  -.upd    `state
    %ini       (on-ini +.upd)
    %add       (on-add +.upd)
    :: %del       (on-del +.upd)
  ==
  ::
  ::  @~lodlev-migdev - at this point, dockets have been loaded into the app catalog;
  ::   therefore use this as an opportunity to set the host value of each app in the catalog
  ++  on-ini
    |=  [init=(map [=ship =desk] =treaty:treaty)]
    ^-  (quip card _state)
    :: ~&  >>  "{<dap.bowl>}: treaty-update [on-ini] => init={<init>}, treaty={<treaty>}"
    =/  updated-catalog=catalog:store
      %-  ~(rep by init)
        |=  [[[=ship =desk] =treaty:treaty] result=(map app-id:store app:store)]
        :: ~&  >>  "{<dap.bowl>}: treaty-update [on-ini] => ship={<ship>}, desk={<desk>}, treaty"
        =/  app  (~(get by catalog.state) desk)
        ?~  app  result

        ?.  =(%urbit -.u.app)   (~(put by result) desk u.app) ::  host only applies to urbit apps
        ?>  ?=(%urbit -.u.app)                                :: update app host
        =.  host.u.app          (determine-app-host:helpers:bazaar:core ship u.app)
        (~(put by result) desk u.app)
    ::
    =.  catalog.state     (~(uni by catalog.state) updated-catalog)
    `state
  ::
  ++  on-add
    |=  [=treaty:treaty]
    ^-  (quip card _state)
    :: ~&  >>  "{<dap.bowl>}: treaty-update [on-add] => {<[treaty]>}"
    =|  effects=(list card)
    :: if a pending install, auto kick off the docket-install. %live from kiln will remove the
    =/  pending-install         (~(get by pending-installs.state) desk.treaty)
    =.  effects  ?~  pending-install  effects
      %-  (slog leaf+"{<dap.bowl>}: treaty added for pending-install {<desk.treaty>}. sending docket-install..." ~)
      (snoc effects [%pass / %agent [our.bowl %docket] %poke docket-install+!>([ship.treaty desk.treaty])])
    ::  if every desk in the alliance has been added to the treaties listing for the ship,
    ::    send the UI and update indicating its safe to scry the treaties
    =/  allis  allies:scry:bazaar:core
    =/  treats  (treaties:scry:bazaar:core ship.treaty %.n)
    =/  alli  (~(get by allis) ship.treaty)
    =/  effects  ?~  alli  effects
      ?:  %-  ~(all in u.alli)
          |=  [[=ship =desk]]
            (~(has by treats) [ship desk])
        :: ~&  >>  "{<dap.bowl>}: sending treaties-loaded..."
        (snoc effects [%give %fact [/updates ~] bazaar-reaction+!>([%treaties-loaded ship.treaty])])
      effects
    [effects state]
  --
::
++  ally-update
  |=  [upd=update:ally:treaty]
  ^-  (quip card _state)
  |^
  ?+  -.upd       `state
    %new          (on-new +.upd)
    %add          (on-add +.upd)
    %del          (on-del +.upd)
  ==
  ::
  ++  on-new
    |=  [=ship =alliance:treaty]
    ^-  (quip card _state)
    :: ~&  >>  "{<dap.bowl>}: [on-new] => {<[ship alliance]>}"
    :_  state
    :~
      [%give %fact [/updates ~] bazaar-reaction+!>([%new-ally ship alliance])]
    ==
  ::
  ++  on-add
    |=  [=ship]
    ^-  (quip card _state)
    :: =/  treaty    .^(update:treaty:treaty  %gx /(scot %p our.bowl)/treaty/(scot %da now.bowl)/treaties/(scot %p ship)/noun)
    :: ~&  >>  "{<dap.bowl>}: ally-update [on-add] => {<update.treaty>}"
    `state
  ::
  ++  on-del
    |=  [=ship]
    ^-  (quip card _state)
    :_  state
    :~
      [%give %fact [/updates ~] bazaar-reaction+!>([%ally-deleted ship])]
    ==
  --
::  charge arms
++  ch
  |%
  ++  on
    |=  upd=charge-update:docket
    ^-  (quip card _state)
    ?+  -.upd         `state
      %add-charge     (add:ch:core +.upd)
      %del-charge     (rem:ch:core +.upd)
    ==
  ::
  ++  add
    |=  [=desk =charge:docket]
    ^-  (quip card _state)
    ?-  -.chad.charge
      %install          (update-catalog-app desk charge %started)
      %hung             (update-catalog-app desk charge %failed)
      %suspend          (update-catalog-app desk charge %suspended)
      %glob             (update-catalog-app desk charge %installed)
      %site             (update-catalog-app desk charge %installed)
    ==
    ::
    ++  update-catalog-app
      |=  [app-id=desk =charge:docket status=?(%started %failed %suspended %installed)]
      =/  hide-desks              `(set @tas)`(silt ~['realm' 'realm-wallet' 'courier' 'garden'])
      ?:  (~(has in hide-desks) app-id)
        `state
      =/  app                     (~(get by catalog.state) app-id)
      =/  app  ?~  app  [%urbit docket.charge host=~ status (config:scry:bazaar:core app-id)]
      ?>  ?=(%urbit -.u.app)
      :: ~&  >>  "{<dap.bowl>}: update-catalog-app => {<app-id>}, {<install-status.u.app>}, {<status>}"
      =.  install-status.u.app
        ?:  ?&(=(%suspended install-status.u.app) =(%started status))
          install-status.u.app
        ?:  ?&(=(%started install-status.u.app) =(%suspended status))
          %started
        ?:  ?&(=(%desktop install-status.u.app) =(%started status))
          ::  @trent - we can add a check to clay for the desk existing
          ::  and that would do the same skip of suspended that the fresh install does
          =+  peaks=get-pikes:core
          ?.((~(has by peaks) app-id) %started status)
        status
      ::
      =.  docket.u.app          docket.charge
      =.  config.u.app          (config:scry:bazaar:core app-id)
      u.app
      =.  catalog.state           (~(put by catalog.state) app-id app)
      =.  grid-index              (set-grid-index:helpers:bazaar:core app-id grid-index.state)
      :: %-  (slog leaf+"{<dap.bowl>}: [update-app-catalog]" ~)
      :: %-  (slog leaf+"  app-install-update => {<[%app-install-update app-id +.app grid-index.state]>}" ~)
      :_  state
      [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update app-id +.app grid-index.state])]~
  ::
  ++  rem
    |=  [=desk]
    ^-  (quip card _state)
    =/  app  (~(get by catalog.state) desk)
    ?~  app  `state
    ?>  ?=(%urbit -.u.app)
    ::  set to uninstalled, don't delete
    =.  install-status.u.app  %uninstalled
    =.  catalog.state         (~(put by catalog.state) [desk u.app])
    ::  remove from grid index to "uninstall"
    =.  grid-index.state      (rem-grid-index:helpers:bazaar:core desk grid-index.state)
    :_  state
    [%give %fact [/updates ~] bazaar-reaction+!>([%app-install-update desk +.u.app grid-index.state])]~
  --
::
::  $security. member/permission checks
::
++  security
  |%
  ++  check-member
    |=  [path=space-path:spaces-store =ship]
    ^-  ?
    =/  member   .^(view:membership-store %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/(scot %p ship.path)/(scot %tas space.path)/is-member/(scot %p ship)/noun)
    ?>  ?=(%is-member -.member)
    is-member.member
  ::
  ++  check-admin
    |=  [path=space-path:spaces-store =ship]
    ^-  ?
    =/  member   .^(view:membership-store %gx /(scot %p our.bowl)/spaces/(scot %da now.bowl)/(scot %p ship.path)/(scot %tas space.path)/members/(scot %p ship)/noun)
    ?>  ?=(%member -.member)
    (~(has in roles.member.member) %admin)
  ::
  --
++  is-host
  |=  [=ship]
  =(our.bowl ship)
::  +pre: prefix for scries to hood
::
++  pre  /(scot %p our.bowl)/hood/(scot %da now.bowl)
::  +get-sources:  (map desk [ship desk])
::
++  get-sources
  ^-  (map desk [=ship =desk])
  .^((map @tas [@p @tas]) %gx (welp pre /kiln/sources/noun))
::
::  +get-pikes:  (map desk [(unit [@p desk]) hash zest wic])
++  get-pikes
  ^-  pikes:hood
  :: ~&  >>  "{<dap.bowl>}: [get-pikes]"
  .^(pikes:hood %gx (welp pre /kiln/pikes/kiln-pikes))
::
::  +get-syncs:
::
::    (map kiln-sync sync-state)
::    where:
::    %+  map
::       (map [local=desk foreign=ship foreign=desk])
::    [nun=@ta kid=(unit desk) let=@ud]
++  get-syncs
  ^-  (map [syd=desk her=ship sud=desk] [nun=@ta kid=(unit desk) let=@ud])
  .^  (map [@tas @p @tas] [@ta (unit @tas) @ud])
    %gx
    (welp pre /kiln/syncs/noun)
  ==
::
--
