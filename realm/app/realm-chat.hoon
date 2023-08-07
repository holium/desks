::  app/realm-chat.hoon
/-  *realm-chat, db-sur=chat-db, ndb=notif-db, fr=friends, spc=spaces-store
/+  dbug, lib=realm-chat, db-lib=chat-db
=|  state-1
=*  state  -
:: ^-  agent:gall
=<
  %-  agent:dbug
  |_  =bowl:gall
  +*  this  .
      core   ~(. +> [bowl ~])
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  default-state=state-1
      :*  %1
          %.y            :: hide-debug
          '82328a88-f49e-4f05-bc2b-06f61d5a733e'  :: app-id
          (sham our.bowl)                         :: uuid
          *(map @t @t)
          %.y            :: push-enabled
          ~              :: set of muted chats
          ~              :: set of pinned chats
          %.y            :: msg-preview-notif
      ==

    =/  cards=(list card)
    :~  [%pass /db %agent [our.bowl %chat-db] %watch /db]
        [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action !>([%create-notes-to-self-if-not-exists ~])]
    ==
    [cards this(state default-state)]
  ++  on-save   !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    :: do a quick check to make sure we are subbed to /db in %chat-db
    =/  cards=(list card)
      ?:  =(wex.bowl ~)  
        :~  [%pass /db %agent [our.bowl %chat-db] %watch /db]
            [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action !>([%create-notes-to-self-if-not-exists ~])]
        ==
      [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action !>([%create-notes-to-self-if-not-exists ~])]~

    =/  old  !<(versioned-state old-state)
    ?-  -.old
      %0  (on-load !>([%1 %.y +.old]))
      %1
        =.  app-id.old  '82328a88-f49e-4f05-bc2b-06f61d5a733e'  :: app-id
        [cards this(state old)]
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  ?=(%chat-action mark)
    =/  act  !<(action vase)
    =^  cards  state
    ?-  -.act  :: each handler function here should return [(list card) state]
      :: meta-chat management pokes
      %create-chat
        (create-chat:lib +.act state bowl)
      %vented-create-chat
        (vented-create-chat:lib +.act state bowl)
      %edit-chat
        (edit-chat:lib +.act state bowl)
      %pin-message
        (pin-message:lib +.act state bowl)
      %clear-pinned-messages
        (clear-pinned-messages:lib +.act state bowl)
      %add-ship-to-chat
        (add-ship-to-chat:lib +.act state bowl)
      %remove-ship-from-chat
        (remove-ship-from-chat:lib +.act state bowl)
      :: message management pokes
      %send-message
        (send-message:lib +.act state bowl)
      %vented-send-message
        (vented-send-message:lib +.act state bowl)
      %edit-message
        (edit-message:lib +.act state bowl)
      %delete-message
        (delete-message:lib +.act state bowl)
      %delete-backlog
        (delete-backlog:lib +.act state bowl)
      :: notification preferences pokes
      %disable-push
        (disable-push:lib state bowl)
      %enable-push
        (enable-push:lib state bowl)
      %remove-device
        (remove-device:lib +.act state bowl)
      %set-device
        (set-device:lib +.act state bowl)
      %mute-chat
        (mute-chat:lib +.act state bowl)
      %pin-chat
        (pin-chat:lib +.act state bowl)
      %toggle-msg-preview-notif
        (toggle-msg-preview-notif:lib +.act state bowl)
      %toggle-hide-debug
        (toggle-hide-debug:lib +.act state bowl)

      %create-notes-to-self-if-not-exists
        (create-notes-to-self-if-not-exists:lib state bowl)
    ==
    [cards this]
  ::  realm-chat supports no subscriptions
  ::  realm-chat does not care
  ::  (users/frontends shoulc sub to %chat-db agent)
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    !!
  :: we support devices peek for push notifications
  :: and pins peek for list of pinned chats
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  !!
    ::
      [%x %devices ~]
        ?>  =(our.bowl src.bowl)
        ``notify-view+!>(devices.state)
    ::
      [%x %pins ~]
        ?>  =(our.bowl src.bowl)
        ``chat-pins+!>(pins.state)
    ::
      [%x %mutes ~]
        ?>  =(our.bowl src.bowl)
        ``chat-mutes+!>(mutes.state)
    ::
      [%x %settings ~]
        ?>  =(our.bowl src.bowl)
        ``chat-settings+!>([push-enabled.state msg-preview-notif.state])
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  !!
      [%dbpoke ~]
      :: [%dbpoke *]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            =/  log1  (maybe-log hide-debug.state "%realm-chat: {<(spat wire)>} dbpoke failed")
            :: ~&  >>>  p.sign
            `this
            :: ?~  +.wire
            ::   ~&  >>>  "%realm-chat: {<(spat wire)>} dbpoke failed in an unhandled way"
            ::   ~&  >>>  p.sign
            ::   `this
            :: ~&  >>>  "kicking {<src.bowl>} from {(spud +.wire)} because /dbpoke got a poke-nack"
            :: =/  fakebowl   bowl
            :: =.  src.fakebowl  our.bowl
            :: =/  cs  (remove-ship-from-chat:lib [+.wire src.bowl] state fakebowl)
            :: [-.cs this(state +.cs)]
        ==
      [%selfpoke ~]
        ?+    -.sign  `this
          %poke-ack
            ?~  p.sign  `this
            =/  log1  (maybe-log hide-debug.state "%realm-chat: {<(spat wire)>} selfpoke failed")
            `this
        ==
      [%db ~]
        ?+    -.sign  !!
          %watch-ack
            ?~  p.sign  `this
            =/  log1  (maybe-log hide-debug.state "{<dap.bowl>}: /db subscription failed")
            `this
          %kick
            =/  log1  (maybe-log hide-debug.state "{<dap.bowl>}: /db kicked us, resubscribing...")
            :_  this
            :~
              [%pass /db %agent [our.bowl %chat-db] %watch /db]
            ==
          %fact
            ?+    p.cage.sign  `this
              %chat-db-dump
                `this
              %chat-db-change
                =/  thechange=db-change:db-sur  !<(db-change:db-sur q.cage.sign)

                =/  new-msg-parts=(list msg-part:db-sur)
                  %+  turn
                    %+  skim
                      thechange 
                    |=(ch=db-change-type:db-sur &(=(-.ch %add-row) =(%messages -.+.ch)))
                  |=  ch=db-change-type:db-sur
                  ?+  -.ch    !!
                    %add-row
                    ?+  -.db-row.ch   !!
                      %messages       msg-part.db-row.ch
                    ==
                  ==
                =/  new-msg-ids=(list msg-id:db-sur)
                  ~(tap in (silt (turn new-msg-parts |=(m=msg-part:db-sur msg-id.m))))
                =/  new-msg-notif-cards=(list card)
                  %-  zing
                  %+  turn
                    new-msg-ids
                  |=  id=msg-id:db-sur
                  ^-  (list card)
                  =/  parts     (skim new-msg-parts |=(p=msg-part:db-sur =(msg-id.p id)))
                  =/  first-msg-part  (snag 0 parts)
                  ?:  =(-.content.first-msg-part %status) :: don't send notifs on %status msgs
                    ~
                  =/  thepath   path.first-msg-part
                  ?:  =(sender.id our.bowl) :: if it's our message, don't do anything
                    ~
                  ::  if it's a %react AND it's not reacting to our
                  ::  message, don't do anything
                  =/  not-replying-to-us=?
                    ?~  reply-to.first-msg-part  %.y
                      ?!(=(our.bowl +:+:(need reply-to.first-msg-part)))
                  ?:  &(=(-.content.first-msg-part %react) not-replying-to-us)  ~
                  ?:  (~(has in mutes.state) thepath)               :: if it's a muted path, send a pre-dismissed notif to notif-db
                    =/  notif-db-card  (notif-new-msg:core parts our.bowl %.y bowl)
                    [notif-db-card ~]
                  =/  notif-db-card  (notif-new-msg:core parts our.bowl %.n bowl)
                  ?:  :: if we should do a push notification also,
                  ?&  push-enabled.state                  :: push is enabled
                      (gth (lent ~(tap by devices.state)) 0) :: there is at least one device
                  ==
                    =/  prow            (scry-path-row:lib thepath bowl)
                    =/  mess            (scry-message:lib id bowl)
                    =/  space-scry=(unit view:spc)
                      ?.  =(%space type.prow)  ~
                      =/  uspace  (~(get by metadata.prow) 'space')
                      ?~  uspace  ~
                      =/  path-first=path   /(scot %p our.bowl)/spaces/(scot %da now.bowl)
                      =/  path-second=path  (stab u.uspace)
                      =/  path-final=path   (weld (weld path-first path-second) /noun)
                      (some .^(view:spc %gx path-final))

                    =/  push-title      (notif-from-nickname-or-patp sender.id bowl)
                    =/  push-subtitle   
                      ?~  space-scry
                        (group-name-or-blank prow)
                      ?.  =(%space type.prow)
                        (group-name-or-blank prow)
                      ?>  ?=(%space -.u.space-scry)
                      (crip [name.space:(need space-scry) ' - ' (group-name-or-blank prow) ~])
                    =/  push-contents   (notif-msg parts bowl)
                    =/  unread-count    +(.^(@ud %gx /(scot %p our.bowl)/notif-db/(scot %da now.bowl)/db/unread-count/(scot %tas %realm-chat)/noun))
                    =/  avatar=(unit @t)
                      ?:  =(%dm type.prow)      (scry-avatar-for-patp:lib sender.id bowl)
                      ?:  =(%group type.prow)   (~(get by metadata.prow) 'image')
                      ?:  =(%space type.prow)
                        ?~  space-scry  ~
                        ?>  ?=(%space -.u.space-scry)
                        ?:  =('' picture.space.u.space-scry)
                          (some wallpaper.theme.space.u.space-scry)
                        (some picture.space.u.space-scry)
                      ~  :: default to null if we don't know what type of chat this is
                    =/  push-card
                      %:  push-notification-card:lib
                          bowl
                          state
                          prow
                          push-title
                          push-subtitle
                          push-contents
                          unread-count
                          avatar
                          mess
                      ==
                    [push-card notif-db-card ~]
                  :: otherwise, just send to notif-db
                  [notif-db-card ~]

                =/  cards=(list card)
                  %-  zing
                  %+  turn
                    thechange 
                  |=  ch=db-change-type:db-sur
                  ^-  (list card)
                  ?+  -.ch  ~
                    %add-row
                    ?+  -.db-row.ch  ~
                      %paths
                        =/  pathrow  path-row.db-row.ch
                        =/  pathpeers  (scry-peers:lib path.pathrow bowl)
                        =/  host  (snag 0 (skim pathpeers |=(p=peer-row:db-sur =(role.p %host))))
                        ?:  =(patp.host our.bowl) :: if it's our own creation, don't do anything
                          ~
                        =/  send-status-message
                          !>([%send-message path.pathrow ~[[[%status (crip "{(scow %p our.bowl)} joined the chat")] ~ ~]] *@dr])
                        [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action send-status-message]~
                    ==

                    %upd-paths-row
                      =/  pathpeers  (scry-peers:lib path.path-row.ch bowl)
                      =/  host  (snag 0 (skim pathpeers |=(p=peer-row:db =(role.p %host))))
                      ?:  ?&  =(patp.host our.bowl) :: only host will send the status update
                              ?!(=(max-expires-at-duration.path-row.ch max-expires-at-duration.old.ch)) :: only do the status if the max duration changed
                          ==
                        =/  send-status-message
                          ?:  =(max-expires-at-duration.path-row.ch *@dr)
                            !>([%send-message path.path-row.ch ~[[[%status (crip "Messages now last forever")] ~ ~]] *@dr])
                          !>([%send-message path.path-row.ch ~[[[%status (crip "You set disappearing messages to {(scow %dr max-expires-at-duration.path-row.ch)}")] ~ ~]] *@dr])
                        [%pass /selfpoke %agent [our.bowl %realm-chat] %poke %chat-action send-status-message]~
                      ~

                    %del-paths-row
                      =/  notif-ids=(list @ud)
                        %+  turn
                          (scry-notifs-for-path path.ch bowl)
                        |=(n=notif-row:ndb id.n)
                      %+  turn  notif-ids
                      |=  id=@ud
                      ^-  card
                      [%pass /dbpoke %agent [our.bowl %notif-db] %poke %notif-db-poke !>([%delete id])]
                  ==
                [(weld cards new-msg-notif-cards) this]
            ==
        ==
    ==
  ::
  ++  on-leave
    |=  path
      `this
  :: we don't care about arvo
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    `this
  ::
  ++  on-fail
    |=  [=term =tang]
    %-  (slog leaf+"error in {<dap.bowl>}" >term< tang)
    `this
  --
|_  [=bowl:gall cards=(list card)]
::
++  this  .
++  core  .
++  maybe-log
  |=  [hide-debug=? msg=*]
  ?:  =(%.y hide-debug)  ~
  ~&  >>>  msg
  ~
++  is-new-message
  |=  ch=*
  ^-  ?
  ?+  -.ch  %.n
    %add-row  =(-.+.ch %messages)
  ==
::
++  scry-notifs-for-path
  |=  [=path =bowl:gall]
  ^-  (list notif-row:ndb)
  =/  scry-path  (weld /(scot %p our.bowl)/notif-db/(scot %da now.bowl)/db/path/realm-chat path)
  .^  (list notif-row:ndb)
      %gx
      (weld scry-path /noun)
  ==
::
++  notif-new-msg
  |=  [=message:db-sur =ship dismissed=? =bowl:gall]
  ^-  card
  =/  msg-part  (snag 0 message)
  =/  title     (notif-msg message bowl)
  =/  content   (notif-from-nickname-or-patp sender.msg-id.msg-part bowl)
  :: NOTE, %notif-db agent now depends on us setting this properly so it
  :: can delete notifs for deleted messages automatically
  =/  link      (msg-id-to-cord:encode:db-lib msg-id.msg-part)
  [
    %pass
    /dbpoke
    %agent
    [ship %notif-db]
    %poke
    %notif-db-poke
    !>([%create %realm-chat path.msg-part %message title content '' ~ link ~ dismissed])
  ]
::  returns either 'New Message' or a preview of the actual message
::  depending on `msg-preview-notif.state` flag
++  notif-msg
  |=  [=message:db-sur =bowl:gall]
  ^-  @t
  ?.  msg-preview-notif.state  'New Message'
  =/  str=tape
    ^-  tape
    %+  join
      ' '
    %+  turn
      message
    |=  part=msg-part:db-sur
    ^-  @t
    :: show the content text from the types where it makes sense to do
    :: so. For the others, just show the name of the type (like "image")
    ?+  -.content.part      -.content.part
      %plain                p.content.part
      %bold                 p.content.part
      %italics              p.content.part
      %strike               p.content.part
      %bold-italics         p.content.part
      %bold-strike          p.content.part
      %italics-strike       p.content.part
      %bold-italics-strike  p.content.part
      %blockquote           p.content.part
      %inline-code          p.content.part
      %code                 p.content.part
      %status               p.content.part
      %link                 p.content.part
      %image                'Shared an image'
      %react
        ?~  reply-to.part   'Reacted to a message'
        =/  prev-msg  (scry-message:lib +.u.reply-to.part bowl)
        =/  prev-summary  (notif-msg prev-msg bowl)
        (crip "Reacted {(emoji-codepoint-to-character-as-tape p.content.part)} to: \"{(trip prev-summary)}\"")
    ==
  (crip `tape`(swag [0 140] str)) :: only show the first 140 characters of the message in the preview
++  emoji-codepoint-to-character-as-tape
::0x4E3E -> 0b100.1110.0011.1110
::          1110xxxx 10xxxxxx 10xxxxxx
::fills  -> 11100100 10111000 10111110
::'1f44d' goal -> `@ub`0x8d91.9ff0 -> 1000 1101 1001 0001 1001 1111 1111 0000
::                                        00 01 1111 01 0001 00 1101
::                                    10xx xxxx 10xx xxxx 10xx xxxx 1111 00xx
  |=  t=@t
  ^-  tape
  =/  working  (trip t)
  ?:  =(9 (lent working))
    %+  weld
    (emoji-codepoint-to-character-as-tape (crip (scag 4 working)))
    (emoji-codepoint-to-character-as-tape (crip (oust [0 5] working)))
  ?:  =(4 (lent working))
  =/  parsed=@     (slav %ux (crip (weld "0x" working)))
  :: fixed str-bin
  =/  f=tape  (fix-str-bin-for-emoji parsed 16)
  =/  fillin=tape  "0b10{(trip (snag 10 f))}{(trip (snag 11 f))}.{(trip (snag 12 f))}{(trip (snag 13 f))}{(trip (snag 14 f))}{(trip (snag 15 f))}.10{(trip (snag 4 f))}{(trip (snag 5 f))}.{(trip (snag 6 f))}{(trip (snag 7 f))}{(trip (snag 8 f))}{(trip (snag 9 f))}.1110.{(trip (snag 0 f))}{(trip (snag 1 f))}{(trip (snag 2 f))}{(trip (snag 3 f))}"
  (trip `@t`(slav %ub (crip fillin)))
  ?.  =(5 (lent working))  "?"
  =/  parsed=@    (slav %ux (crip (weld "0x" (into working 1 '.'))))
  :: fixed str-bin
  =/  f=tape  (fix-str-bin-for-emoji parsed 20)
  =/  fillin=tape  "0b10{(trip (snag 14 f))}{(trip (snag 15 f))}.{(trip (snag 16 f))}{(trip (snag 17 f))}{(trip (snag 18 f))}{(trip (snag 19 f))}.10{(trip (snag 8 f))}{(trip (snag 9 f))}.{(trip (snag 10 f))}{(trip (snag 11 f))}{(trip (snag 12 f))}{(trip (snag 13 f))}.10{(trip (snag 2 f))}{(trip (snag 3 f))}.{(trip (snag 4 f))}{(trip (snag 5 f))}{(trip (snag 6 f))}{(trip (snag 7 f))}.1111.00{(trip (snag 0 f))}{(trip (snag 1 f))}"
  (trip `@t`(slav %ub (crip fillin)))
::
++  fix-str-bin-for-emoji
::  take a @ux parsed version of the codepoint and turn it into a string
::  representation of the binary where it's zero-padded to the goal
::  length on the left side, and there are no prefixes or periods
::  ex: "1010110101001011"
  |=  [parsed=@ goal=@ud]
  ^-  tape
  =/  str-bin=tape   (oust [0 2] (scow %ub `@ub`parsed))
  =/  res=tape  ""
  =/  index=@ud    0
  |-
    ?:  =(index (lent str-bin))
      ?:  =(goal (lent res))
        res
      (left-pad res '0' goal)
    =/  char  (snag index str-bin)
    ?:  =(char '.')
      $(index +(index))
    $(index +(index), res (snoc res char))
::
++  left-pad
  |=  [t=tape c=@t n=@ud]
  ^-  tape
  |-
    ?:  (gte (lent t) n)
      t
    $(t (weld (trip c) t))
::
++  group-name-or-blank
  |=  [=path-row:db-sur]
  ^-  @t
  =/  title       (~(get by metadata.path-row) 'title')
  ?:  =(type.path-row %dm)   '' :: always blank for DMs
  ?~  title     'Group Chat'    :: if it's a group chat without a title, just say "group chat"
  (need title)                  :: otherwise, return the title of the group
::
++  notif-from-nickname-or-patp
  |=  [patp=ship =bowl:gall]
  ^-  @t
  =/  cv=view:fr
    .^  view:fr
        %gx
        /(scot %p our.bowl)/friends/(scot %da now.bowl)/contact-hoon/(scot %p patp)/noun
    ==
  =/  nickname=@t
    ?+  -.cv  (scot %p patp) :: if the scry came back wonky, just fall back to patp
      %contact-info
        nickname.contact-info.cv
    ==
  ?:  =('' nickname)
    (scot %p patp)
  nickname
--
