::  notif-db [realm]:
::
/-  *notif-versioned-state, sur=notif-db, chat-db
/+  cdb-lib=chat-db
|%
::
:: helpers
::
++  mark-row-unread
  |=  [r=notif-row:sur t=@da]
  =.  read.r        %.n
  =.  updated-at.r  t
  r
::
++  mark-row-read
  |=  [r=notif-row:sur now=@da]
  =.  read-at.r     now
  =.  updated-at.r  now
  =.  read.r        %.y
  r
::
++  mark-app-read
  |=  [tbl=notifs-table:sur app=@tas now=@da]
  =/  kvs  (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(read.v %.n))))
  =/  ids=(list id:sur)  (turn kvs |=([k=@ud v=notif-row:sur] k))
  =/  index=@ud  0
  =/  stop=@ud   (lent ids)
  |-
  ?:  =(stop index)
    [tbl ids]
  $(index +(index), tbl (put:notifon:sur tbl (snag index ids) (mark-row-read +:(snag index kvs) now)))
::
++  mark-path-read
  |=  [tbl=notifs-table:sur app=@tas =path now=@da]
  =/  kvs  (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(path path.v) =(app app.v) =(read.v %.n))))
  =/  ids=(list id:sur)  (turn kvs |=([k=@ud v=notif-row:sur] k))
  =/  index=@ud  0
  =/  stop=@ud   (lent ids)
  |-
  ?:  =(stop index)
    [tbl ids]
  $(index +(index), tbl (put:notifon:sur tbl (snag index ids) (mark-row-read +:(snag index kvs) now)))
::
++  toggle-dismissed
  |=  [r=notif-row:sur now=@da d=?]
  =.  dismissed-at.r   now
  =.  updated-at.r    now
  =.  dismissed.r      d
  r
::
++  mark-app-dismiss
  |=  [tbl=notifs-table:sur app=@tas now=@da]
  =/  kvs  (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(dismissed.v %.n))))
  =/  ids=(list id:sur)  (turn kvs |=([k=@ud v=notif-row:sur] k))
  =/  index=@ud  0
  =/  stop=@ud   (lent ids)
  |-
  ?:  =(stop index)
    [tbl ids]
  $(index +(index), tbl (put:notifon:sur tbl (snag index ids) (toggle-dismissed +:(snag index kvs) now %.y)))
::
++  mark-path-dismiss
  |=  [tbl=notifs-table:sur app=@tas =path now=@da]
  =/  kvs  (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(path path.v) =(app app.v) =(dismissed.v %.n))))
  =/  ids=(list id:sur)  (turn kvs |=([k=@ud v=notif-row:sur] k))
  =/  index=@ud  0
  =/  stop=@ud   (lent ids)
  |-
  ?:  =(stop index)
    [tbl ids]
  $(index +(index), tbl (put:notifon:sur tbl (snag index ids) (toggle-dismissed +:(snag index kvs) now %.y)))
++  ids-by-path
  |=  [tbl=notifs-table:sur app=@tas =path]
  ^-  (list id:sur)
  %+  turn
    (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(path path.v))))
  |=([k=@ud v=notif-row:sur] k)
::
++  ids-by-link
  |=  [tbl=notifs-table:sur app=@tas link=cord]
  ^-  (list id:sur)
  %+  turn
    (skim (tap:notifon:sur tbl) |=([k=@ud v=notif-row:sur] &(=(app app.v) =(link link.v))))
  |=([k=@ud v=notif-row:sur] k)
::
++  generate-uniq-notif-ids-to-del
  |=  [state=state-0 deleted-msg-id-cords=(list cord) deleted-paths=(list path)]
  ^-  (list id:sur)
  =/  notif-ids-to-del-set=(set id:sur)
  %-  silt
  ^-  (list id:sur)
  %+  weld
    ^-  (list id:sur)
    %-  zing
    %+  turn
      deleted-msg-id-cords
    |=  =cord
    ^-  (list id:sur)
    (ids-by-link notifs-table.state %realm-chat cord)
  ^-  (list id:sur)
  %-  zing
  %+  turn
    deleted-paths
  |=  =path
  ^-  (list id:sur)
  (ids-by-path notifs-table.state %realm-chat path)

  ~(tap in notif-ids-to-del-set)
::
::
::  poke actions
::
++  create
:: :notif-db &notif-db-poke [%create %chat-db /realm-chat/path-id %message 'Title' 'the message' '' ~ '' ~ %.n]
  |=  [act=create-action:sur state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  row=notif-row:sur  [
    next.state
    app.act
    path.act
    type.act
    title.act
    content.act
    image.act
    buttons.act
    link.act
    metadata.act
    now.bowl
    now.bowl
    *@da
    %.n
    ?:(dismissed.act now.bowl *@da)
    dismissed.act
  ]
  =.  notifs-table.state  (put:notifon:sur notifs-table.state next.state row)
  =.  next.state          +(next.state)
  =/  thechange  notif-db-change+!>((limo [[%add-row row] ~]))
  =/  gives  :~
    [%give %fact [/db /new ~] thechange]
  ==
  [gives state]
::
++  read-id
::  :notif-db &notif-db-poke [%read-id 0]
  |=  [=id:sur state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  row  (mark-row-read (got:notifon:sur notifs-table.state id) now.bowl)
  =.  notifs-table.state  (put:notifon:sur notifs-table.state id row)
  =/  thechange  notif-db-change+!>((limo [[%update-row row] ~]))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  read-app
::  :notif-db &notif-db-poke [%read-app %chat-db]
  |=  [app=@tas state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ::  mark-result is like: [notifs-table ids]
  =/  mark-result  (mark-app-read notifs-table.state app now.bowl)
  =.  notifs-table.state  -:mark-result
  =/  thechange  notif-db-change+!>((turn +:mark-result |=(id=@ud [%update-row (got:notifon:sur notifs-table.state id)])))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  read-path
::  :notif-db &notif-db-poke [%read-path %chat-db /realm-chat/path-id]
  |=  [act=[app=@tas =path] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ::  mark-result is like: [notifs-table ids]
  =/  mark-result  (mark-path-read notifs-table.state app.act path.act now.bowl)
  =.  notifs-table.state  -:mark-result
  =/  thechange  notif-db-change+!>((turn +:mark-result |=(id=@ud [%update-row (got:notifon:sur notifs-table.state id)])))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  read-all
::  :notif-db &notif-db-poke [%read-all %.y]
  |=  [flag=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  t  now.bowl
  =.  notifs-table.state  (run:notifon:sur notifs-table.state |=(r=notif-row:sur ?:(flag (mark-row-read r t) (mark-row-unread r t))))
  =/  thechange  notif-db-change+!>((limo [[%update-all flag] ~]))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  dismiss-id
::  :notif-db &notif-db-poke [%dismiss-id 0]
  |=  [=id:sur state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  row  (toggle-dismissed (got:notifon:sur notifs-table.state id) now.bowl %.y)
  =.  notifs-table.state  (put:notifon:sur notifs-table.state id row)
  =/  thechange  notif-db-change+!>((limo [[%update-row row] ~]))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  dismiss-app
::  :notif-db &notif-db-poke [%dismiss-app %chat-db]
  |=  [app=@tas state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ::  mark-result is like: [notifs-table ids]
  =/  mark-result  (mark-app-dismiss notifs-table.state app now.bowl)
  =.  notifs-table.state  -:mark-result
  =/  thechange  notif-db-change+!>((turn +:mark-result |=(id=@ud [%update-row (got:notifon:sur notifs-table.state id)])))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  dismiss-path
::  :notif-db &notif-db-poke [%dismiss-path %chat-db /realm-chat/path-id]
  |=  [act=[app=@tas =path] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ::  mark-result is like: [notifs-table ids]
  =/  mark-result  (mark-path-dismiss notifs-table.state app.act path.act now.bowl)
  =.  notifs-table.state  -:mark-result
  =/  thechange  notif-db-change+!>((turn +:mark-result |=(id=@ud [%update-row (got:notifon:sur notifs-table.state id)])))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  update
:: :notif-db &notif-db-poke [%update 0 %chat-db /realm-chat/path-id %message 'T2' 'the mes...' '' ~ '' ~]
  |=  [act=[=id:sur =create-action:sur] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  row  (got:notifon:sur notifs-table.state id.act)
  =.  app.row        app.create-action.act
  =.  path.row       path.create-action.act
  =.  type.row       type.create-action.act
  =.  title.row      title.create-action.act
  =.  content.row    content.create-action.act
  =.  image.row      image.create-action.act
  =.  buttons.row    buttons.create-action.act
  =.  link.row       link.create-action.act
  =.  metadata.row   metadata.create-action.act
  =.  updated-at.row      now.bowl
  =.  notifs-table.state  (put:notifon:sur notifs-table.state id.act row)
  =/  thechange  notif-db-change+!>([[%update-row row] ~])
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  delete
::  :notif-db &notif-db-poke [%delete 0]
  |=  [=id:sur state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =.  notifs-table.state  +:(del:notifon:sur notifs-table.state id)
  =.  del-log.state       (put:delon:sur del-log.state now.bowl [%del-row id])
  =/  thechange  notif-db-change+!>((limo [[%del-row id] ~]))
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives state]
::
++  delete-old-realm-chat-notifs
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  del-log-kvs
    %-  tap:delon:chat-db
    .^(del-log:chat-db %gx /(scot %p our.bowl)/chat-db/(scot %da now.bowl)/delete-log/start-ms/0/noun)

  =/  deleted-msg-id-cords=(list cord)
  %+  turn 
    %+  skim
      del-log-kvs
    |=  [k=time v=db-change-type:chat-db]
    ?+  -.v  %.n
      %del-messages-row  %.y
    ==
  |=  [k=time v=db-change-type:chat-db]
  ^-  cord
  ?+  -.v  !!
    %del-messages-row  (msg-id-to-cord:encode:cdb-lib msg-id.uniq-id.v)
  ==

  =/  deleted-paths
  %+  turn 
    %+  skim
      del-log-kvs
    |=  [k=time v=db-change-type:chat-db]
    ?+  -.v  %.n
      %del-paths-row  %.y
    ==
  |=  [k=time v=db-change-type:chat-db]
  ^-  path
  ?+  -.v  !!
    %del-paths-row  path.v
  ==

  =/  notif-ids-to-del=(list id:sur)
  (generate-uniq-notif-ids-to-del state deleted-msg-id-cords deleted-paths)

  =/  index=@ud  0
  =/  changes=db-change:sur  ~
  =/  cs=[db-change:sur state-0]
    |-
      ?:  =(index (lent notif-ids-to-del))
        [changes state]
      =/  id=id:sur  (snag index notif-ids-to-del)
      =/  ch=db-change-type:sur  [%del-row id]
      =.  notifs-table.state  +:(del:notifon:sur notifs-table.state id)
      =.  del-log.state       (put:delon:sur del-log.state (add now.bowl index) ch)
      $(index +(index), changes (snoc changes ch))

  =/  thechange  notif-db-change+!>(-.cs)
  =/  gives  :~
    [%give %fact [/db ~] thechange]
  ==
  [gives +.cs]
::
::
::  JSON
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%create de-create]
          [%read-id ni]
          [%read-app (se %tas)]
          [%read-path app-and-path]
          [%read-all bo]
          [%dismiss-id ni]
          [%dismiss-app (se %tas)]
          [%dismiss-path app-and-path]
          [%update de-update]
          [%delete ni]
      ==
    ::
    ++  de-update
      %-  ot
      :-  [%id ni]
      de-create-list
    ::
    ++  de-create  (ot de-create-list)
    ::
    ++  de-create-list
      :~  [%app (se %tas)]
          [%path pa]
          [%type (se %tas)]
          [%title so]
          [%content so]
          [%image so]
          [%buttons (ar button)]
          [%link so]
          [%metadata (om so)]
          [%dismissed bo]
      ==
    ::
    ++  button
      %-  ot
      :~  [%label so]
          [%path pa]
          [%data so]
          [%metadata (om so)]
      ==
    ::
    ++  app-and-path
      %-  ot
      :~  [%app (se %tas)]
          [%path pa]
      ==
    --
  --
++  enjs
  =,  enjs:format
  |%
    ++  db-change :: encodes for on-watch
      |=  db=db-change:sur
      ^-  json
      (changes:encode db)
    ::
    ++  rows :: encodes for on-peek
      |=  rws=(list notif-row:sur)
      ^-  json
      (notifs:encode rws)
  --
++  encode
  =,  enjs:format
  |%
    ++  del-log
      |=  log=del-log:sur
      ^-  json
      :-  %a
      %+  turn  (tap:delon:sur log)
      |=  [k=@da v=db-change-type:sur]
      %-  pairs
      :~
        ['timestamp' (time k)]
        ['change' (individual-change v)]
      ==
    ::
    ++  notifs
      |=  rows=(list notif-row:sur)
      ^-  json
      [%a (turn rows notifs-row)]
    ::
    ++  notifs-row
      |=  =notif-row:sur
      ^-  json
      %-  pairs
      :~  id+(numb id.notif-row)
          app+s+app.notif-row
          path+s+(spat path.notif-row)
          type+s+type.notif-row
          title+s+title.notif-row
          content+s+content.notif-row
          image+s+image.notif-row
          buttons+a+(turn buttons.notif-row button-up)
          link+s+link.notif-row
          metadata+(metadata-to-json metadata.notif-row)
          created-at+(time created-at.notif-row)
          updated-at+(time updated-at.notif-row)
          read-at+(time-or-null read-at.notif-row)
          read+b+read.notif-row
          dismissed-at+(time-or-null dismissed-at.notif-row)
          dismissed+b+dismissed.notif-row
      ==
    ::
    ++  time-or-null
      |=  t=@da
      ^-  json
      ?:  =(t *@da)
        ~
      (time t)
    ::
    ++  changes
      |=  ch=db-change:sur
      ^-  json
      [%a (turn ch individual-change)]
    ++  individual-change
      |=  ch=db-change-type:sur
      %-  pairs
      ?-  -.ch
        %add-row
          :~(['type' %s -.ch] ['row' (notifs-row notif-row.ch)])
        %update-all
          :~(['type' %s -.ch] ['read' %b flag.ch])
        %update-row
          :~(['type' %s -.ch] ['row' (notifs-row notif-row.ch)])
        %del-row
          :~(['type' %s -.ch] ['id' (numb id.ch)])
      ==
    ++  button-up
      |=  b=button:sur
      ^-  json
      %-  pairs
      :~  ['label' %s label.b]
          ['path' s+(spat path.b)]
          ['data' s+data.b]
          ['metadata' (metadata-to-json metadata.b)]
      ==
    ++  metadata-to-json
      |=  m=(map cord cord)
      ^-  json
      o+(~(rut by m) |=([k=cord v=cord] s+v))
  --
--
