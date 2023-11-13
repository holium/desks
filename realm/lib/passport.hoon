/-  *passport, common, db
/+  scries=bedrock-scries, crypto-helper
|%
::
:: helpers
::
++  prev-link-hash-matches
  ::  tells us if the previous-link-hash matches what we expect
  |=  [link=passport-data-link:common chain=passport-chain:common]
  ^-  ?
  ?:  =((lent chain) 0)  =('0x00000000000000000000000000000000' previous-link-hash.mtd.link)
  :: first link in the chain is an "epoch_block" so there's still not a
  :: real previous linke hash
  ?:  =((lent chain) 1)  =('0x00000000000000000000000000000000' previous-link-hash.mtd.link)
  =/  last  (snag (dec (lent chain)) chain)
  =(hash.last previous-link-hash.mtd.link)
::
++  validate-signing-key
  |=  [p=passport:common ln=passport-link-container:common]
  ^-  ?
  :: only allow keys that are already in the crypto state to add other keys
  =/  parsed-link=passport-data-link:common   (passport-data-link:dejs (need (de:json:html data.ln)))
  =/  entity=@t     from-entity.mtd.parsed-link
  =/  key=@t        signing-address.mtd.parsed-link
  =/  keys=(list @t)  (~(got by entity-to-addresses.pki-state.crypto.p) entity)
  ?~  (find [key]~ keys)  %.n  ::invalid signing key
  %.y
::
++  parse-signing-key
  |=  ln=passport-link-container:common
  ^-  @t
  ?:  =('PASSPORT_ROOT' link-type.ln)
    =/  pr=passport-crypto:common           (passport-root:dejs (need (de:json:html data.ln)))
    signing-key.sig-chain-settings.pr
  ?:  ?|  =('KEY_ADD' link-type.ln)
          =('SIGNED_KEY_ADD' link-type.ln)
          =('KEY_REMOVE' link-type.ln)
          =('NAME_RECORD_SET' link-type.ln)
      ==
    =/  pd=passport-data-link:common  (passport-data-link:dejs (need (de:json:html data.ln)))
    signing-address.mtd.pd
  !!
::
++  req
  |=  [=ship dap=@tas]
  ^-  card
  [%pass /contacts %agent [ship dap] %poke %passport-action !>([%request-contacts ~])]
::
++  create-req
  |=  [our=ship =type:common data=columns:db =req-id]
  ^-  card
  [%pass /dbpoke %agent [our %bedrock] %poke %db-action !>([%create req-id /private type data ~])]
::
++  create
  |=  [our=ship =type:common data=columns:db]
  (create-req our type data [our *@da])
::
++  create-many
  |=  [our=ship args=(list [req-id input-row:db])]
  [%pass /dbpoke %agent [our %bedrock] %poke %db-action !>([%create-many args])]
::
++  edit-req
  |=  [our=ship =type:common =id:common data=columns:db =req-id]
  ^-  card
  [%pass /dbpoke %agent [our %bedrock] %poke %db-action !>([%edit req-id id /private type data ~])]
::
++  edit
  |=  [our=ship =type:common =id:common data=columns:db]
  (edit-req our type id data [our *@da])
::
++  remove-req
  |=  [our=ship =type:common =id:common =req-id]
  ^-  card
  [%pass /dbpoke %agent [our %bedrock] %poke %db-action !>([%remove req-id type /private id])]
::
++  remove
  |=  [our=ship =type:common =id:common]
  (remove-req our type id [our *@da])
::
++  maybe-log
  |=  [hide-debug=? msg=tape]
  ?:  =(%.y hide-debug)  ~
  ~&  msg
  ~
::
++  url-encode
  |=  url=@t
  ^-  @t
  =/  trl=tape  (trip url)
  =/  result=tape  ""
  |-
    ?:  =(0 (lent trl))
      (crip result)
    =/  curr=@t  (snag 0 trl)
    =/  char=tape
::      ?:  =(curr ':')  "%3A"
::      ?:  =(curr '/')  "%2F"
::      ?:  =(curr '?')  "%3F"
      ?:  =(curr '#')  "%23"
::      ?:  =(curr '[')  "%5B"
::      ?:  =(curr ']')  "%5D"
      ?:  =(curr '@')  "%40"
      ?:  =(curr '!')  "%21"
      ?:  =(curr '$')  "%24"
::      ?:  =(curr '&')  "%26"
      ?:  =(curr '\'')  "%27"
      ?:  =(curr '(')  "%29"
      ?:  =(curr ')')  "%2A"
      ?:  =(curr '*')  "%2B"
      ?:  =(curr '+')  "%2C"
      ?:  =(curr ',')  "%2D"
      ?:  =(curr ';')  "%3B"
      ?:  =(curr '=')  "%3D"
      ?:  =(curr '%')  "%25"
      ?:  =(curr ' ')  "%20"
      (trip curr)
    %=  $
      trl       +.trl
      result    (weld result char)
    ==
::
++  remove-newlines
  |=  str=@t
  ^-  @t
  =/  tp=tape  (trip str)
  =/  result=tape  ""
  |-
    ?:  =(0 (lent tp))
      (crip result)
    =/  curr=@t  (snag 0 tp)
    %=  $
      tp        +.tp
      result    ?:(=(curr '\0a') result (snoc result curr))
    ==
::
++  trim-whitespace
  |=  str=@t
  ^-  @t
  =/  tp=tape  (flop (trip str))
  =/  result=tape  ""
  |-
    ?:  =(0 (lent tp))
      ''
    =/  curr=@t  (snag 0 tp)
    ?:  ?|  =(curr '\09')  :: tab
            =(curr '\0a')  :: newline
            =(curr '\0d')  :: carriage return
            =(curr ' ')    :: space
        ==
      $(tp +.tp)
    (crip (flop tp))
::
++  truncate
  |=  [str=@t n=@ud]
  ^-  @t
  (crip (scag n (trip str)))
::
++  cleanup-contact
  |=  =contact:common
  ^-  contact:common
  =.  display-name.contact
    ?~  display-name.contact  ~
    (some (trim-whitespace (remove-newlines u.display-name.contact)))
  =.  avatar.contact
    ?~  avatar.contact  ~
    ?-  -.u.avatar.contact
      %image
        ?:  =('' img.u.avatar.contact)  ~
        (some [%image (url-encode img.u.avatar.contact)])
      %nft
        ?:  =('' nft.u.avatar.contact)  ~
        (some [%nft (url-encode nft.u.avatar.contact)])
    ==
  =.  bio.contact
    ?~  bio.contact  ~
    ?:  =('' (trim-whitespace u.bio.contact))  ~
    (some (truncate (trim-whitespace u.bio.contact) 240))
  contact
::
++  find-contact
  |=  [c=contact:common ls=(list [=id:common @da =contact:common])]
  ^-  (unit @)
  =/  ships=(list ship)  (turn ls |=(con=[=id:common @da =contact:common] ship.contact.con))
  (find [ship.c ~] ships)
::
++  current-contacts  :: includes 'our' contact
  |=  =bowl:gall
  ^-  (list [@da contact:common])
  (turn (our-contacts:scries bowl) |=(c=[id:common @da =contact:common] +.c))
::
:: pokes
++  receive-contacts
:: our ship gets this from another ship when they are giving us some contacts
::passport &passport-action [%receive-contacts [now [~zod ~ ~ ~ [~ 'ZOOOD']]]~]
  |=  [contacts=(list [t=@da =contact:common]) state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ?<  =(src.bowl our.bowl)  :: assert we aren't receiving from ourself
  =/  log1  (maybe-log hide-logs.state "%receive-contacts: {<contacts>}")

  :: loop through the contacts they sent us
  =/  old=(list [id:common @da contact:common])  (our-contacts:scries bowl)
  =/  cards=(list card)  ~
  =/  create-args=(list [req-id input-row:db])  ~
  |-
    ?:  =(0 (lent contacts))
      ?:  =(0 (lent create-args))
        [cards state]
      :_  state
      :-  (create-many our.bowl create-args)
      cards
    =/  con=contact:common  (cleanup-contact contact:(snag 0 contacts))
    =/  is-sender-contact  =(src.bowl ship.con)
    ?:  |(=(our.bowl ship.con) ?!(is-sender-contact))  :: don't create a contact record for ourselves, or for others who aren't the sender
      $(contacts +.contacts)
    =/  index=(unit @)      (find-contact con old)
    ?~  index
      %=  $
        contacts      +.contacts
        create-args   [[[our.bowl *@da] [/private contact-type:common [%contact con] ~]] create-args]
      ==
    =/  old-con=[=id:common t=@da =contact:common]   (snag u.index old)
    ?:  (gth t.old-con t:(snag 0 contacts))  $(contacts +.contacts)  :: if our old record is newer than the one we are getting, ignore it
    %=  $
      contacts  +.contacts
      cards     [(edit our.bowl contact-type:common id.old-con [%contact con]) cards]
    ==
::
++  request-contacts
:: our ship gets this from another ship who wants to learn our contacts
::passport &passport-action [%request-contacts ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%request-contacts from {<src.bowl>}")

  =/  response  !>([%receive-contacts (current-contacts bowl)])
  =/  cards=(list card)
    [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action response]~
  [cards state]
::
++  add-friend
::passport &passport-action [%add-friend [our now] ~zod ~]
  |=  [[=req-id =ship mtd=(map @t @t)] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-friend: {<req-id>} {<ship>}")

  =/  new-fren=friend:common      [ship %pending-outgoing %.n mtd]
  =/  pass=passport:common   (our-passport:scries bowl)
  =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)

  :: check that we don't already have a friendship with this ship
  =/  frs=(list friend:common)    (get-friends:scries bowl)
  =/  ships=(list @p)    (turn frs |=(f=friend:common ship.f))
  =/  cards=(list card)
    ?~  (find [ship ~] ships)
      :~  (create-req our.bowl friend-type:common [%friend new-fren] req-id)
          [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%get-friend mtd])]
          [%pass /contacts %agent [ship dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.pass] ~]])]
      ==
    ~
  [cards state]
::
++  get-friend
::passport &passport-action [%get-friend ~]
  |=  [mtd=(map @t @t) state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get-friend: {<mtd>} from {<src.bowl>}")

  =/  new-fren=friend:common  [src.bowl %pending-incoming %.n mtd]
  =/  pass=passport:common   (our-passport:scries bowl)
  =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)

  =/  cards=(list card)
    :~  [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.pass] ~]])]
        (create our.bowl friend-type:common [%friend new-fren])
    ==
  [cards state]
::
++  cancel-friend-request
::passport &passport-action [%cancel-friend-request ~zod]
  |=  [[=req-id =ship] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%cancel-friend-request: {<req-id>} {<ship>}")
  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  ?>  =(src.bowl our.bowl) ::only we can cancel our own requests
  ?>  ?!(=(our.bowl ship)) ::has to be for a different ship than ourselves

  =/  new-fren              (get-friend:scries ship bowl)
  ?>  =(status.friend.new-fren %pending-outgoing) :: we can only cancel pending-outgoing requests

  =/  cards=(list card)
    :~  [%give %fact ~[vent-path] passport-vent+!>([%ack ~])]
        kickcard
        (remove our.bowl friend-type:common id.new-fren)
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%revoke-friend-request ~])]
    ==
  [cards state]
::
++  revoke-friend-request
::passport &passport-action [%revoke-friend-request ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%revoke-friend-request: from {<src.bowl>}")
  ?>  ?!(=(src.bowl our.bowl)) :: we can only process responses from other ships

  =/  new-fren                  (get-friend:scries src.bowl bowl)
  ?>  =(status.friend.new-fren %pending-incoming) :: we can only process responses for pending-incoming requests
  ?>  =(src.bowl ship.friend.new-fren) :: must come from the requester

  =/  cards=(list card)
    :~  (remove our.bowl friend-type:common id.new-fren)
    ==
  [cards state]
::
++  handle-friend-request
::passport &passport-action [%handle-friend-request [our now] %.y ~zod]
  |=  [[=req-id accept=? =ship] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%handle-friend-request: {<req-id>} {<accept>} {<ship>}")
  ?>  =(src.bowl our.bowl) ::only we can accept/reject requests

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  new-fren                  (get-friend:scries ship bowl)
  ?>  ?|  =(status.friend.new-fren %pending-incoming) :: we can only handle pending-incoming requests
          =(status.friend.new-fren %friend) :: or %friend (in order to end a friendship)
          =(status.friend.new-fren %rejected) :: or %rejected (in order to change our mind about starting a friendship)
      ==
  =.  status.friend.new-fren    ?:(accept %friend %rejected)

  =/  cards=(list card)
    :~  [%give %fact ~[vent-path] passport-vent+!>([%friend friend.new-fren])]
        kickcard
        (edit our.bowl friend-type:common id.new-fren [%friend friend.new-fren])
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%respond-to-friend-request accept])]
    ==
  [cards state]
::
++  respond-to-friend-request
::passport &passport-action [%respond-to-friend-request %.y]
  |=  [accept=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%respond-to-friend-request: {<accept>} from {<src.bowl>}")
  ?>  ?!(=(src.bowl our.bowl)) :: we can only process responses from other ships

  =/  new-fren                  (get-friend:scries src.bowl bowl)
  ?>  =(status.friend.new-fren %pending-outgoing) :: we can only process responses for pending-outgoing requests
  ?>  =(src.bowl ship.friend.new-fren) :: must come from the requestee
  =.  status.friend.new-fren    ?:(accept %friend %rejected)

  =/  cards=(list card)
    :~  (edit our.bowl friend-type:common id.new-fren [%friend friend.new-fren])
    ==
  [cards state]
::
++  get
:: for getting our passport
::passport &passport-action [%get [our now]]
  |=  [=req-id state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get: {<req-id>} from {<src.bowl>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  pass=passport:common   (our-passport:scries bowl)
  =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)
  =/  src-fren=?  (is-friend:scries src.bowl bowl)
  :: only actually give out the passport if we are discoverable
  :: OR we are friends with the requester
  ?>  |(discoverable.pass src-fren)

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] passport-vent+!>([%passport pass])]
    :-  kickcard
    :-  [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.pass] ~]])]
    ~
  [cards state]
::
++  get-as-row
:: for getting our passport
::passport &passport-action [%get-as-row [our now]]
  |=  [=req-id state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get: {<req-id>} from {<src.bowl>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  r=row:db   (our-passport-row:scries bowl)
  =/  pass=passport:common   
  ?+  -.data.r  !!
    %passport  +.data.r
  ==
  =/  src-fren=?  (is-friend:scries src.bowl bowl)
  :: only actually give out the passport if we are discoverable
  :: OR we are friends with the requester
  ?>  |(discoverable.pass src-fren)

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] db-vent+!>([%row r ~])]
    :-  kickcard
    :-  [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action !>([%receive-contacts [[updated-at.r contact.pass] ~]])]
    ~
  [cards state]
::
++  get-contact
:: for getting our contact
::passport &passport-action [%get-contact [our now]]
  |=  [=req-id state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get: {<req-id>} from {<src.bowl>}")

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  pass=passport:common   (our-passport:scries bowl)
  =/  src-fren=?  (is-friend:scries src.bowl bowl)
  :: only actually give out the passport if we are discoverable
  :: OR we are friends with the requester
  ?>  |(discoverable.pass src-fren)
  =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] passport-vent+!>([%contact contact.pass])]
    :-  kickcard
    :-  [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.pass] ~]])]
    ~
  [cards state]
::
++  change-contact
::passport &passport-action [%change-contact [our now] ~zod [~ [%image 'url']] [~ '#fcfcfc'] [~ 'my bio'] [~ 'ZOOOD']]
  |=  [[=req-id c=contact:common] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%change-contact: {<req-id>} {<c>}")
  :: assure it's us, and we're editing our self
  ?>  =(our.bowl src.bowl)
  ?>  =(our.bowl ship.c)

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  p=passport:common  (our-passport:scries bowl)
  =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)
  =/  old-contact=contact:common  contact.p
  =.  contact.p  (cleanup-contact c)

  =/  cards=(list card)
    :~  (edit-req our.bowl passport-type:common (our-passport-id:scries bowl) [%passport p] req-id)
        (edit our.bowl contact-type:common (our-contact-id:scries bowl) [%contact contact.p])
        [%give %fact ~[vent-path] passport-vent+!>([%passport p])]
        kickcard
    ==
  =.  cards
    ?:  =(contact.p old-contact)  cards :: don't poke everyone if the contact is the same as it was
    %+  weld  cards
    %+  turn
      %+  skip  (our-contacts:scries bowl)
      |=  c=[id:common @da =contact:common]
      ^-  ?
      =(our.bowl ship.contact.c)
    |=  c=[id:common @da =contact:common]
    ^-  card
    [%pass /contacts %agent [ship.contact.c dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.p] ~]])]

  [cards state]
::
++  add-link
::passport &passport-action [%add-link passport-link-container]
  |=  [[=req-id ln=passport-link-container:common wallet-source=(unit @t)] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-link: {<req-id>} {<ln>}")
  :: assure it's us
  ?>  =(our.bowl src.bowl)

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  p=passport:common   (our-passport:scries bowl)
  =/  old-contact=contact:common  contact.p
  :: verify the link is valid, then save it to bedrock
  :: validate the hash of data is what the payload claims it is
  ?>  =((shax data.ln) (ether-hash-to-ux:crypto-helper hash.ln))

  :: parse the signer address
  =/  addr=@t  (parse-signing-key ln)
  :: and verify that the signing key matches the signature and the message
  ?>  (verify-message:crypto-helper hash.ln hash-signature.ln addr)
  =/  t-pk=@t
  %-  crip
  %-  num-to-hex:crypto-helper
  (recover-pub-key:crypto-helper hash.ln hash-signature.ln addr)

  =.  p
    ?:  =('PASSPORT_ROOT' link-type.ln)
      ?>  =((lent chain.p) 0) :: only allow passport_root as first link in chain
      =.  crypto.p   (passport-root:dejs (need (de:json:html data.ln)))
      =.  default-address.p   addr
      =/  sig=crypto-signature:common  [data.ln hash.ln hash-signature.ln t-pk]
      =.  addresses.p   [(need wallet-source) addr t-pk sig]~
      p

    =/  parsed-link=passport-data-link:common   (passport-data-link:dejs (need (de:json:html data.ln)))
    ?>  (prev-link-hash-matches parsed-link chain.p)
    :: only allow keys that are already in the crypto state to make changes
    ?>  (validate-signing-key p ln)   
    ?:  =('KEY_ADD' link-type.ln)
      =/  entity=@t     from-entity.mtd.parsed-link
      =/  key=@t        signing-address.mtd.parsed-link
      ?+  -.data.parsed-link  !!
        %key-add
      =/  new-key=@t        address.data.parsed-link
      =/  new-entity=@t     name.data.parsed-link
      ::  add new key to the pki-state for the new-entity
      =/  keys=(list @t)  (~(got by entity-to-addresses.pki-state.crypto.p) new-entity)
      =.  entity-to-addresses.pki-state.crypto.p  (~(put by entity-to-addresses.pki-state.crypto.p) new-entity (snoc keys new-key))
      =.  address-to-entity.pki-state.crypto.p   (~(put by address-to-entity.pki-state.crypto.p) new-key new-entity)

      =.  address-to-nonce.pki-state.crypto.p  :: increment signing key nonce
        (~(put by address-to-nonce.pki-state.crypto.p) key +((~(got by address-to-nonce.pki-state.crypto.p) key)))
      :: set new-key nonce to 0
      =.  address-to-nonce.pki-state.crypto.p    (~(put by address-to-nonce.pki-state.crypto.p) new-key 0)
      :: update known addresses
      =/  sig=crypto-signature:common  [data.ln hash.ln hash-signature.ln t-pk]
      =.  addresses.p  (snoc addresses.p [address-type.data.parsed-link new-key '' sig])
      p
      ==
    ?:  =('SIGNED_KEY_ADD' link-type.ln)
      =/  entity=@t     from-entity.mtd.parsed-link
      =/  key=@t        signing-address.mtd.parsed-link
      ?+  -.data.parsed-link  !!
        %signed-key-add
      =/  new-sig=@t        key-signature.data.parsed-link
      =/  new-key=@t        address.data.parsed-link
      =/  new-entity=@t     name.data.parsed-link
      =/  msg=@t
        %:  signed-key-add-msg:crypto-helper
          new-entity
          new-key
          nonce.data.parsed-link
          timestamp.data.parsed-link
        ==
      ?>  (verify-message:crypto-helper msg new-sig new-key)
      ::  add new key to the pki-state for the new-entity
      =/  keys=(list @t)  (~(got by entity-to-addresses.pki-state.crypto.p) new-entity)
      =.  entity-to-addresses.pki-state.crypto.p  (~(put by entity-to-addresses.pki-state.crypto.p) new-entity (snoc keys new-key))
      =.  address-to-entity.pki-state.crypto.p   (~(put by address-to-entity.pki-state.crypto.p) new-key new-entity)

      =.  address-to-nonce.pki-state.crypto.p  :: increment signing key nonce
        (~(put by address-to-nonce.pki-state.crypto.p) key +((~(got by address-to-nonce.pki-state.crypto.p) key)))
      :: set new-key nonce to 0
      =.  address-to-nonce.pki-state.crypto.p    (~(put by address-to-nonce.pki-state.crypto.p) new-key 0)
      :: update known addresses
      =/  sig=crypto-signature:common  [data.ln hash.ln hash-signature.ln t-pk]
      =/  new-pk=@t
      %-  crip
      %-  num-to-hex:crypto-helper
      (recover-pub-key:crypto-helper msg new-sig new-key)
      =.  addresses.p  (snoc addresses.p [address-type.data.parsed-link new-key new-pk sig])
      p
      ==
    ?:  =('KEY_REMOVE' link-type.ln)
      =/  entity=@t     from-entity.mtd.parsed-link
      =/  key=@t        signing-address.mtd.parsed-link
      ?+  -.data.parsed-link  !!
        %key-remove
      =/  bye-key=@t        address.data.parsed-link
      ::  remove key from the pki-state
      =.  entity-to-addresses.pki-state.crypto.p  (~(run by entity-to-addresses.pki-state.crypto.p) |=(ts=(list @t) (skip ts |=(t=@t =(t bye-key)))))
      =.  address-to-entity.pki-state.crypto.p   (~(del by address-to-entity.pki-state.crypto.p) bye-key)

      =.  address-to-nonce.pki-state.crypto.p  :: increment signing key nonce
        (~(put by address-to-nonce.pki-state.crypto.p) key +((~(got by address-to-nonce.pki-state.crypto.p) key)))
      :: set new-key nonce to 0
      =.  address-to-nonce.pki-state.crypto.p    (~(del by address-to-nonce.pki-state.crypto.p) bye-key)
      :: update known addresses
      =.  addresses.p  (skip addresses.p |=(a=linked-address:common =(address.a bye-key)))
      p
      ==
    ?:  =('NAME_RECORD_SET' link-type.ln)
      :: update the `addresses` record of this signing key to fill in
      :: their public key
      =.  addresses.p
        %+  turn
          addresses.p
        |=  a=linked-address:common
        ^-  linked-address:common
        ?.  =(address.a addr)  a
        [wallet.a addr t-pk crypto-signature.a]
      :: do the name record update
      ?+  -.data.parsed-link  !!
        %name-record-set
      ?:  =('display-name' name.data.parsed-link)
        =.  display-name.contact.p  (some record.data.parsed-link)
        p
      ?:  =('avatar' name.data.parsed-link)
        =.  avatar.contact.p  (some [%image record.data.parsed-link])
        p
      ?:  =('color' name.data.parsed-link)
        =.  color.contact.p  (some record.data.parsed-link)
        p
      ?:  =('bio' name.data.parsed-link)
        =.  bio.contact.p  (some record.data.parsed-link)
        p
      ?:  =('cover' name.data.parsed-link)
        =.  cover.p  (some record.data.parsed-link)
        p
      ?:  =('user-status' name.data.parsed-link)
        =.  user-status.p  ?:(=(record.data.parsed-link 'invisible') %invisible %online)
        p
      ?:  =('discoverable' name.data.parsed-link)
        =.  discoverable.p  =(record.data.parsed-link 'true')
        p
      ?:  =('nfts' name.data.parsed-link)
        =.  nfts.p  (linked-nfts:dejs (need (de:json:html record.data.parsed-link)))
        p
      ?:  =('contact' name.data.parsed-link)
        =.  contact.p  (de-contact:dejs (need (de:json:html record.data.parsed-link)))
        p
      ~&  >>>  'unrecognized NAME_RECORD_SET "name" property'
      !!
      ==
    !!

  =.  chain.p    (snoc chain.p ln)
  =.  contact.p  (cleanup-contact contact.p)

  =/  cards=(list card)
    :~  (edit our.bowl passport-type:common (our-passport-id:scries bowl) [%passport p])
        (edit our.bowl contact-type:common (our-contact-id:scries bowl) [%contact contact.p])
        [%give %fact ~[vent-path] passport-vent+!>([%passport p])]
        kickcard
    ==
  =.  cards
    ?.  discoverable.p
      :: not discoverable, delete contact
      :_  cards
      [%pass /contacts %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%remove-contact ~])]
    :: if discoverable, 
    ?:  =(contact.p old-contact)  cards :: don't poke if the contact is the same as it was
    :: otherwise, update-contact
    :_  cards
    [%pass /contacts %agent [~halnus %explore-reverse-proxy] %poke %noun !>([%update-contact contact.p])]
  =.  cards
    ?:  =(contact.p old-contact)  cards :: don't poke everyone if the contact is the same as it was
    =/  pass-time=@da  updated-at:(our-passport-row:scries bowl)
    %+  weld  cards
    %+  turn
      %+  skip  (our-contacts:scries bowl)
      |=  c=[id:common @da =contact:common]
      ^-  ?
      =(our.bowl ship.contact.c)
    |=  c=[id:common @da =contact:common]
    ^-  card
    [%pass /contacts %agent [ship.contact.c dap.bowl] %poke %passport-action !>([%receive-contacts [[pass-time contact.p] ~]])]
  [cards state]
::
++  change-passport
:: DOES NOT UPDATE `chain` or `crypto`, MUST use %add-link for those
::passport &passport-action [%change-passport passport]
  |=  [[=req-id pi=passport:common] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%change-passport: {<req-id>} {<pi>}")
  :: assure it's us
  ?>  =(our.bowl src.bowl)

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  p=passport:common   (our-passport:scries bowl)
  =.  contact.p           (cleanup-contact contact.pi)
  =.  cover.p             cover.pi
  =.  user-status.p       user-status.pi
  =.  discoverable.p      discoverable.pi
  =.  discoverable.p      discoverable.pi
  =.  nfts.p              nfts.pi
  =.  addresses.p         addresses.pi
  =.  default-address.p   default-address.pi
  =.  recommendations.p   recommendations.pi
  :: INTENTIONALLY SKIPPING chain.p and crypto.p

  =/  cards=(list card)
    :~  (edit our.bowl passport-type:common (our-passport-id:scries bowl) [%passport p])
        [%give %fact ~[vent-path] passport-vent+!>([%passport p])]
        kickcard
    ==
  [cards state]
::
++  toggle-hide-logs
::passport &passport-action [%toggle-hide-logs %.n]
  |=  [toggle=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =.  hide-logs.state  toggle
  `state
::
::
::  initializers (also pokes)
::
++  reset
::passport &passport-action [%reset ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  ?>  =(src.bowl our.bowl)
  =/  id  (our-passport-id:scries bowl)
  =/  cid  (our-contact-id:scries bowl)
  :_  state
  :~  [%pass /dbpoke %agent [our.bowl %bedrock] %poke db-action+!>([%remove [our.bowl *@da] passport-type:common /private id])]
      [%pass /dbpoke %agent [our.bowl %bedrock] %poke db-action+!>([%remove [our.bowl *@da] contact-type:common /private cid])]
      [%pass /dbpoke %agent [our.bowl dap.bowl] %poke passport-action+!>([%init-our-passport ~])]
  ==
::
++  add-pals-as-friends
::passport &passport-action [%add-pals-as-friends ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  :: make sure they are actually running %pals
  ?.  .^(? %gu /(scot %p our.bowl)/pals/(scot %da now.bowl)/$)  `state

  =/  mutuals=(set ship)
  .^((set ship) %gx /(scot %p our.bowl)/pals/(scot %da now.bowl)/mutuals/noun)
  =/  targets=(set ship)
  .^((set ship) %gx /(scot %p our.bowl)/pals/(scot %da now.bowl)/targets/noun)

  =/  cards=(list card)
  %+  weld
    %+  turn  ~(tap in targets)
    |=  s=ship
    :: get-contact for the ships we were just "following"
    [%pass /selfpoke %agent [s dap.bowl] %poke %passport-action !>([%get-contact [our.bowl *@da]])]
  %+  turn  ~(tap in mutuals)
  |=  s=ship
  :: add-friend for the ships we were "mutuals" with
  [%pass /selfpoke %agent [our.bowl dap.bowl] %poke %passport-action !>([%add-friend [our.bowl *@da] s ~])]

  [cards state]
::
++  init-our-passport  :: (does nothing if already exists)
::passport &passport-action [%init-our-passport ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%init-our-passport: at {<now.bowl>}")
  =/  passports
    ?:  (test-bedrock-table-existence:scries passport-type:common bowl)
      (all-rows-by-path-type:scries passport-type:common /private bowl)
    ~
  ?.  =((lent passports) 0)  `state
  :: TODO ask %pals for as many contacts to prepopulate as we can and
  :: TODO create a poke to auto-add friends from mutuals in %pals
 
  :: if we already have a bunch of contacts, just re-create ourself,
  :: don't do the whole big import
  ?:  (gth (lent (our-contacts:scries bowl)) 2)
    =/  our-contact-info=[%contact-info n=@t b=@t c=@ux a=(unit @t) v=(unit @t)]
    .^([%contact-info @t @t @ux (unit @t) (unit @t)] %gx /(scot %p our.bowl)/friends/(scot %da now.bowl)/contact-hoon/(scot %p our.bowl)/noun)
    =/  our-contact=contact:common
    %-  cleanup-contact
    [
      our.bowl
      ?~  a.our-contact-info  ~
      (some [%image u.a.our-contact-info])
      (some (hex-str:dejs s+(scot %ux c.our-contact-info)))
      (some b.our-contact-info)
      (some n.our-contact-info)
    ]
    =/  p=passport:common
      [our-contact ~ %online %.y ~ ~ '' ~ ~ *passport-crypto:common]
    =/  cards=(list card)
    :: ~s0..1000 create these records 1/16 of a second in the
    :: future to prevent delete-log confusion
    :~  (create-req our.bowl passport-type:common [%passport p] [our.bowl (add ~s0..1000 now.bowl)])
        (create-req our.bowl contact-type:common [%contact contact.p] [our.bowl (add ~s0..1000 now.bowl)])
    ==
    [cards state]
    
  =/  old-friends  .^(json %gx /(scot %p our.bowl)/friends/(scot %da now.bowl)/all/noun)
  =/  frens=(list friend:common)  (new-friends-from-old:dejs old-friends)
  =/  contacts=(list contact:common)
    %+  turn
      (contacts-from-friends:dejs old-friends)
    cleanup-contact
  =/  maybe-our-contacts
    (skim contacts |=(c=contact:common =(our.bowl ship.c)))
  =/  our-contact=contact:common
    ?:  =((lent maybe-our-contacts) 0)
      [our.bowl ~ [~ '#000000'] ~ ~]
    (snag 0 maybe-our-contacts)
  =/  log2  (maybe-log hide-logs.state "%init-our-passport: contact {<our-contact>}")
  =/  p=passport:common
    [our-contact ~ %online %.y ~ ~ '' ~ ~ *passport-crypto:common]
  =/  cards=(list card)
    :: ~s0..1000 create these records 1/16 of a second in the
    :: future to prevent delete-log confusion
    :-  (create-req our.bowl passport-type:common [%passport p] [our.bowl (add ~s0..1000 now.bowl)])
    :-  (create-req our.bowl contact-type:common [%contact contact.p] [our.bowl (add ~s0..1000 now.bowl)])
    ^-  (list card)
    %+  weld
      ^-  (list card)
      %+  turn  frens
      |=  f=friend:common
      (create our.bowl friend-type:common [%friend f])
    ^-  (list card)
    %+  turn
      %+  skip  contacts  :: don't save our own contact again, or any contacts that are just blank
      |=  c=contact:common
      ^-  ?
      ?|  =(our.bowl ship.c)
          &(=(color.c [~ '#000000']) =(avatar.c ~) =(bio.c ~) =(display-name.c ~))
      ==
    |=  c=contact:common
    (create our.bowl contact-type:common [%contact c])
  [cards state]
::
::
::  JSON
::
++  dejs
  =,  dejs:format
  |%
  ++  new-friends-from-old
    |=  jon=json
    ^-  (list friend:common)
    ?>  ?=([%o *] jon)
    =/  jn=json  (~(got by p.jon) 'friends')
    ?>  ?=([%o *] jn)
    %+  turn
      %+  skim
        %+  turn
          ~(tap by p.jn)
        |=  [shp=@t fr=json]
        ^-  (unit friend:common)
        ?>  ?=([%o *] fr)
        =/  status=@tas  ((se %tas) (~(got by p.fr) 'status'))
        ?:  =(%contact status)  ~
        ?:  =(%our status)      ~
        %-  some
        ^-  friend:common
        :*  `@p`(slav %p shp)
            ?+  status    %rejected
              %fren       %friend
              %follower   %pending-incoming
              %following  %pending-outgoing
            ==
            (bo (~(got by p.fr) 'pinned'))
            ~
        ==
      |=  uf=(unit friend:common)
      ^-  ?
      ?~(uf %.n %.y)
    |=  uf=(unit friend:common)
    ^-  friend:common
    (need uf)
  ::
  ++  contacts-from-friends
    |=  jon=json
    ^-  (list contact:common)
    ?>  ?=([%o *] jon)
    =/  jn=json  (~(got by p.jon) 'friends')
    ?>  ?=([%o *] jn)
    %+  turn
      %+  skim
        %+  turn
          ~(tap by p.jn)
        |=  [shp=@t fr=json]
        ^-  (unit contact:common)
        ?>  ?=([%o *] fr)
        =/  c=(unit json)  (~(get by p.fr) 'contactInfo')
        ?~  c  ~
        ?~  u.c  ~
        ?>  ?=([%o *] u.c)
        =/  raw-bio   (so (~(got by p.u.c) 'bio'))
        =/  raw-name  (so (~(got by p.u.c) 'nickname'))
        %-  some
        ^-  contact:common
        :*  `@p`(slav %p shp)
            (de-avatar (~(got by p.u.c) 'avatar'))
            (some (hex-str (~(got by p.u.c) 'color')))
            ?:(=(raw-bio '') ~ (some raw-bio))
            ?:(=(raw-name '') ~ (some raw-name))
        ==
      |=  uc=(unit contact:common)
      ^-  ?
      ?~(uc %.n %.y)
    |=  uc=(unit contact:common)
    ^-  contact:common
    (need uc)
  ::
  ++  de-avatar
    |=  jon=json
    ^-  (unit avatar:common)
    ?+  jon   !!
      [%s *]  (some [%image (so jon)])
      ~       ~
      [%o *]
        =/  typ=json  (~(got by p.jon) 'type')
        ?>  ?=([%s *] typ)
        %-  some
        ?+  `@tas`p.typ  !!
          %image  [%image (so (~(got by p.jon) 'img'))]
          %nft    [%nft (so (~(got by p.jon) 'img'))]
        ==
    ==
  ::
  ++  hex-str  :: convert @ux formatted string into web #FFAA00 color format string
    |=  jon=json
    ^-  @t
    =/  urbit-format=@t  (so jon)
    ?:  =('0x0' urbit-format)  '#000000'
    =/  tr=tape  (skip (slag 2 (trip urbit-format)) |=(c=@t =('.' c)))
    |-
      ?:  =((lent tr) 6)
        %-  crip
        :-  '#'
        tr
      $(tr ['0' tr])
  ::
  ++  passport-data-link
    |=  jon=json
    ^-  passport-data-link:common
    ?>  ?=([%o *] jon)
    =/  gt  ~(got by p.jon)
    =/  pmtd=passport-data-link-metadata:common  (de-passport-data-link-metadata (gt 'link-metadata'))
    [
      pmtd
      (de-passport-link (gt 'link-data') link-id.pmtd)
    ]
  ::
  ++  de-passport-link
    |=  [jon=json typ=@t]
    ^-  passport-link:common
    ?>  ?=([%o *] jon)
    =/  gt  ~(got by p.jon)
    ?:  =('KEY_ADD' typ)
      [%key-add (so (gt 'address')) (so (gt 'address-type')) (so (gt 'entity-name'))]
    ?:  =('SIGNED_KEY_ADD' typ)
      :*  %signed-key-add
          (so (gt 'address'))
          (so (gt 'address-type'))
          (so (gt 'key-signature'))
          (so (gt 'entity-name'))
          (ni (gt 'nonce'))
          (ni (gt 'timestamp'))
      ==
    ?:  =('KEY_REMOVE' typ)
      [%key-remove (so (gt 'address'))]
    ?:  =('NAME_RECORD_SET' typ)
      [%name-record-set (so (gt 'name')) (so (gt 'record'))]
    !!
::    ?+  link-type  !!
::        %edge-add
::      [%edge-add (so (gt 'from-link-hash')) (so (gt 'to-link-hash')) (so (gt 'key')) (so (gt 'value'))]
::        %edge-remove
::      [%edge-remove (so (gt 'link-hash'))]
::        %entity-add
::      [%entity-add (so (gt 'address')) (so (gt 'address-type')) (so (gt 'name'))]
::        %key-add
::      [%key-add (so (gt 'address')) (so (gt 'address-type')) (so (gt 'name'))]
::        %key-remove
::        %post-add
::      [%post-add (so (gt 'type')) (gt 'data')]
::        %post-edit
::      [%post-edit (so (gt 'link-hash')) (so (gt 'type')) (gt 'data')]
::        %post-remove
::      [%post-remove (so (gt 'link-hash'))]
::        %name-record-set
::      [%name-record-set (so (gt 'name')) (so (gt 'record'))]
::        %token-burn
::      [%token-burn (so (gt 'from-entity')) (ne (gt 'amount'))]
::        %token-mint
::      [%token-mint (so (gt 'to-entity')) (ne (gt 'amount'))]
::        %token-transfer
::      [%token-transfer (so (gt 'to-entity')) (ne (gt 'amount'))]
::    ==
  ::
  ++  de-passport-data-link-metadata
    %-  ot
    :~  ['from-entity' so]
        ['signing-address' so]
        ['value' ni]
        ['link-id' so]
        ['epoch-block-number' ni]
        ['previous-epoch-nonce' ni]
        ['previous-epoch-hash' so]
        ['nonce' ni]
        ['previous-link-hash' so]
        ['data-block-number' ni]
        ['timestamp' di]
    ==
  ::
  ++  passport-root
    %-  ot
    :~  ['link-id' so]
        ['epoch-block-number' ni]
        ['data-block-number' ni]
        ['timestamp' di]
        ['previous-epoch-hash' so]
        ['pki-state' de-pki-state]
        ['transaction-types' (ot ~[['link-names' (ar so)] ['link-structs' so]])]
        ['data-structs' (ot ~[['struct-names' (ar so)] ['struct-types' so]])]
        ['sig-chain-settings' (ot ~[['new-entity-balance' ni] ['epoch-length' ni] ['signing-key' so] ['data-state' nuthing]])]
    ==
  ::
  ++  nuthing
    |=  jon=json
    ^-  json
    jon
  ::
  ++  linked-nfts
    %-  ar
    %-  ot
    :~  [%chain-id de-chain-id]
        [%token-id so]
        [%contract-address so]
        [%name so]
        [%image-url so]
        [%owned-by so]
        [%token-standard so]
    ==
  ::
  ++  de-chain-id
    |=  jon=json
    ^-  ?(@tas %eth-mainnet %eth-testnet)
    ?+  ((se %tas) jon)  ((se %tas) jon)
      %eth-mainnet    %eth-mainnet
      %eth-testnet    %eth-testnet
    ==
  ++  de-pki-state
    %-  ot
    :~  ['chain-owner-entities' (ar so)]
        ['entity-to-addresses' (om (ar so))]
        ['address-to-nonce' (om ni)]
        ['entity-to-value' (om ni)]
        ['address-to-entity' (om so)]
    ==
  ::
  ++  de-contact
    %-  ot
    :~  [%ship de-ship]
        [%avatar de-avatar]
        [%color so:dejs-soft:format]
        [%bio so:dejs-soft:format]
        [%display-name so:dejs-soft:format]
    ==
  ::
  ++  de-type
    %+  cu
      path-to-type
    pa
  ::
  ++  path-to-type
    |=  p=path
    ^-  type:common
    [`@tas`(slav %tas +2:p) `@uvH`(slav %uv +6:p)]
  ::
  ++  de-id
    %+  cu
      path-to-id
    pa
  ::
  ++  path-to-id
    |=  p=path
    ^-  id:common
    [`@p`(slav %p +2:p) `@da`(slav %da +6:p)]
  ::
  ++  de-space-path
    %+  cu
      path-to-space-path
    pa
  ::
  ++  path-to-space-path
    |=  p=path
    ^-  [=ship space=cord]
    [`@p`(slav %p +2:p) `@t`(slav %tas +6:p)]
  ::
  ++  de-ship  (su ;~(pfix sig fed:ag))
  ::
  ++  dri   :: specify in integer milliseconds, returns a @dr
    (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) ni)
  ::
  ++  action
    |=  jon=json
    ^-  ^action
    =<  (decode jon)
    |%
    ++  decode
      %-  of
      :~  [%add-link add-link]
          [%get de-get]
          [%get-as-row de-get]
          [%reset null]
          [%get-contact de-get]
          [%add-friend de-add-friend]
          [%cancel-friend-request de-cancel-friend-request]
          [%handle-friend-request de-handle-friend-request]
          [%change-contact de-change-contact]
      ==
    ::
    ++  null
      |=  jon=json
      ^-  ~
      ~
    ::
    ++  de-change-contact
      |=  jon=json
      ^-  [req-id contact:common]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  id=id:common
        ?~  request-id  [~zod ~2000.1.1]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        (de-id u.request-id)
      :-  id
      (de-contact jon)
    ::
    ++  de-add-friend
      |=  jon=json
      ^-  [req-id ship (map @t @t)]
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  mtd=(unit json)  (~(get by p.jon) 'mtd')
      =/  id=id:common
        ?~  request-id  [~zod ~2000.1.1]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        (de-id u.request-id)
      :*  id
          (de-ship (gt 'ship'))
          ?~(mtd ~ ((om so) u.mtd))
      ==
    ::
    ++  de-cancel-friend-request
      |=  jon=json
      ^-  [req-id ship]
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  id=id:common
        ?~  request-id  [~zod ~2000.1.1]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        (de-id u.request-id)
      :*  id
          (de-ship (gt 'ship'))
      ==
    ::
    ++  de-handle-friend-request
      |=  jon=json
      ^-  [req-id ? ship]
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  id=id:common
        ?~  request-id  [~zod ~2000.1.1]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        (de-id u.request-id)
      :*  id
          (bo (gt 'accept'))
          (de-ship (gt 'ship'))
      ==
    ::
    ++  add-link
      |=  jon=json
      ^-  [req-id passport-link-container:common (unit @t)]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  wallet=(unit json)  (~(get by p.jon) 'wallet-source')
      ?~  request-id
      :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        [[~zod ~2000.1.1] (de-add-link jon) (so:dejs-soft:format ?~(wallet ~ u.wallet))]
      [(de-id u.request-id) (de-add-link jon) (so:dejs-soft:format ?~(wallet ~ u.wallet))]
    ::
    ++  de-add-link
      %-  ot
      :~  [%link-type so]
          [%data so]
          [%hash so]
          [%signature-of-hash so]
      ==
    ++  de-get
      :: allow people to pass {"request-id": "/~zod/~2000.1.1"} or {"ship": "~zod"}
      |=  jon=json
      ^-  req-id
      ?>  ?=([%o *] jon)
      =/  rq  (~(get by p.jon) 'request-id')
      ?~  rq  `id:common`[`@p`(slav %p (so (~(got by p.jon) 'ship'))) *@da]
      (de-id u.rq)
    ::
    --
  --
::
++  enjs
  =,  enjs:format
  |%
    ++  state
      |=  st=versioned-state
      ^-  json
      ?-  -.st
          %0
        %-  pairs
        :~  ['state-version' (numb `@`-.st)]
        ==
      ==
    ::
    ++  en-vent
      |=  =vent
      ^-  json
      ?-  -.vent
        %ack        s/%ack
        %passport   (en-passport passport.vent)
        %contact    (en-contact contact.vent)
        %friend     (en-friend friend.vent)
        %link       ~
      ==
    ::
    ++  en-passport
      |=  p=passport:common
      ^-  json
      %-  pairs
      :~  ['contact' (en-contact contact.p)]
          ['cover' ?~(cover.p ~ s+u.cover.p)]
          ['user-status' s+user-status.p]
          ['discoverable' b+discoverable.p]
          ['nfts' a+(turn nfts.p en-linked-nft)]
          ['addresses' a+(turn addresses.p en-linked-address)]
          ['default-address' s+default-address.p]
          ['recommendations' a+(turn ~(tap in recommendations.p) en-recommendation)]
          ['chain' a+(turn chain.p en-link-container)]
          ['crypto' (en-p-crypto crypto.p)]
      ==
    ::
    ++  en-p-crypto
      |=  cryp=passport-crypto:common
      ^-  json
      %-  pairs
      :~  ['link-id' s+link-id.cryp]
          ['epoch-block-number' (numb epoch-block.cryp)]
          ['data-block-number' (numb data-block.cryp)]
          ['timestamp' (time timestamp.cryp)]
          ['previous-epoch-hash' s+previous-epoch-hash.cryp]
          ['pki-state' (en-pki-state pki-state.cryp)]
          :-  'transaction-types'
          %-  pairs
          :~  ['link-names' a+(turn link-names.transaction-types.cryp |=(t=@t s+t))]
              ['link-structs' s+link-structs.transaction-types.cryp]
          ==
          :-  'data-structs'
          %-  pairs
          :~  ['struct-names' a+(turn struct-names.data-structs.cryp |=(t=@t s+t))]
              ['struct-types' s+struct-types.data-structs.cryp]
          ==
          :-  'sig-chain-settings'
          %-  pairs
          :~  ['new-entity-balance' (numb new-entity-balance.sig-chain-settings.cryp)]
              ['epoch-length' (numb epoch-length.sig-chain-settings.cryp)]
              ['signing-key' s+signing-key.sig-chain-settings.cryp]
              ['data-state' data-state.sig-chain-settings.cryp]
          ==
      ==
    ::
    ++  en-pki-state
      |=  pki=pki-state:common
      ^-  json
      %-  pairs
      :~  ['chain-owner-entities' a+(turn chain-owner-entities.pki |=(e=@t s+e))]
          ['entity-to-addresses' (map-t-list-t entity-to-addresses.pki)]
          ['address-to-entity' (metadata-to-json address-to-entity.pki)]
          ['address-to-nonce' (map-t-ud address-to-nonce.pki)]
          ['entity-to-value' (map-t-ud entity-to-value.pki)]
      ==
    ::
    ++  en-link-container
      |=  ln=passport-link-container:common
      ^-  json
      %-  pairs
      :~  [%link-type s+link-type.ln]
          ['data' s+data.ln]
          ['hash' s+hash.ln]
          [%signature-of-hash s+hash-signature.ln]
      ==
    ::
    ++  en-link
      |=  ln=passport-link:common
      ^-  json
      %-  pairs
      ?+  -.ln  !!
          %edge-add
        :~  ['link-type' [%s -.ln]]
            ['from-link-hash' s+from-link-hash.ln]
            ['to-link-hash' s+to-link-hash.ln]
            ['key' s+key.ln]
            ['value' s+value.ln]
        ==
          %edge-remove
        :~  ['link-type' [%s -.ln]]
            ['link-hash' s+link-hash.ln]
        ==
          %entity-add
        :~  ['link-type' [%s -.ln]]
            ['address' s+address.ln]
            ['address-type' s+address-type.ln]
            ['name' s+name.ln]
        ==
          %entity-remove
        :~  ['link-type' [%s -.ln]]
            ['name' s+name.ln]
        ==
          %key-add
        :~  ['link-type' [%s -.ln]]
            ['address' s+address.ln]
            ['address-type' s+address-type.ln]
            ['name' s+name.ln]
        ==
          %key-remove
        :~  ['link-type' [%s -.ln]]
            ['address' s+address.ln]
        ==
          %post-add
        :~  ['link-type' [%s -.ln]]
            ['type' s+type.ln]
            ['data' data.ln]
        ==
          %post-edit
        :~  ['link-type' [%s -.ln]]
            ['link-hash' s+link-hash.ln]
            ['type' s+type.ln]
            ['data' data.ln]
        ==
          %post-remove
        :~  ['link-type' [%s -.ln]]
            ['link-hash' s+link-hash.ln]
        ==
          %name-record-set
        :~  ['link-type' [%s -.ln]]
            ['name' s+name.ln]
            ['record' s+record.ln]
        ==
      ==
    ::
    ++  en-contact
      |=  n=contact:common
      ^-  json
      %-  pairs
      :~  ['ship' s+(scot %p ship.n)]
          ['avatar' (en-avatar avatar.n)]
          ['color' ?~(color.n ~ s+u.color.n)]
          ['bio' ?~(bio.n ~ s+u.bio.n)]
          ['display-name' ?~(display-name.n ~ s+u.display-name.n)]
      ==
    ::
    ++  en-avatar
      |=  a=(unit avatar:common)
      ^-  json
      ?~  a  ~
      %-  pairs
      :-
        ?-  -.u.a
          %image  ['img' s+img.u.a]
          %nft    ['img' s+nft.u.a]
        ==
      :~  ['type' [%s -.u.a]]
      ==
    ::
    ++  en-linked-nft
      |=  n=linked-nft:common
      ^-  json
      %-  pairs
      :~  ['chain-id' s+chain-id.n]
          ['token-id' s+token-id.n]
          ['contract-address' s+contract-address.n]
          ['name' s+name.n]
          ['image-url' s+image-url.n]
          ['owned-by' s+owned-by.n]
          ['token-standard' s+token-standard.n]
      ==
    ::
    ++  en-linked-address
      |=  n=linked-address:common
      ^-  json
      %-  pairs
      :~  ['wallet' s+wallet.n]
          ['address' s+address.n]
          ['pubkey' s+pubkey.n]
          :-  'crypto-signature'
          %-  pairs
          :~  ['data' s+data.crypto-signature.n]
              ['hash' s+hash.crypto-signature.n]
              ['signature-of-hash' s+signature-of-hash.crypto-signature.n]
              ['pubkey' s+pubkey.crypto-signature.n]
          ==
      ==
    ::
    ++  en-recommendation
      |=  r=rich-ref:common
      ^-  json
      %-  pairs
      :~  ['id' (row-id-to-json id.r)]
          ['path' s+(spat path.r)]
          ['type' (en-db-type type.r)]
          ['mtd' (metadata-to-json mtd.r)]
      ==
    ::
    ++  en-friend
      |=  n=friend:common
      ^-  json
      %-  pairs
      :~  ['ship' s+(scot %p ship.n)]
          ['status' s+status.n]
          ['pinned' b+pinned.n]
          ['mtd' (metadata-to-json mtd.n)]
      ==
    ::
    ++  en-pdl-metadata
      |=  m=passport-data-link-metadata:common
      ^-  json
      %-  pairs
      :~  ['from-entity' s+from-entity.m]
          ['signing-address' s+signing-address.m]
          ['value' (numb value.m)]
          ['link-id' s+link-id.m]
          ['epoch-block-number' (numb epoch-block-number.m)]
          ['previous-epoch-nonce' (numb previous-epoch-nonce.m)]
          ['previous-epoch-hash' s+previous-epoch-hash.m]
          ['nonce' (numb nonce.m)]
          ['previous-link-hash' s+previous-link-hash.m]
          ['data-block-number' (numb data-block-number.m)]
          ['timestamp' (time timestamp.m)]
      ==
    ::
    ++  row-id-to-json
      |=  =id:common
      ^-  json
      s+(row-id-to-cord id)
    ::
    ++  row-id-to-cord
      |=  =id:common
      ^-  cord
      (spat ~[(scot %p ship.id) (scot %da t.id)])
    ::
    ++  en-db-type
      |=  =type:common
      ^-  json
      s+(db-type-to-cord type)
    ::
    ++  db-type-to-cord
      |=  =type:common
      ^-  cord
      (spat ~[(scot %tas name.type) (scot %uv hash.type)])
    ::
    ++  metadata-to-json
      |=  m=(map cord cord)
      ^-  json
      o+(~(rut by m) |=([k=cord v=cord] s+v))
    ::
    ++  map-t-list-t
      |=  m=(map cord (list cord))
      ^-  json
      :-  %o
      %-  ~(rut by m)
      |=([k=cord v=(list cord)] a+(turn v |=(a=cord s+a)))
    ::
    ++  map-t-ud
      |=  m=(map cord @ud)
      ^-  json
      :-  %o
      %-  ~(rut by m)
      |=([k=cord v=@ud] (numb v))
    ::
    ++  numbrd
      |=  a=@rd
      ^-  json
      :-  %n
      (crip (flop (snip (snip (flop (trip (scot %rd a)))))))
    ::
    ++  time-dr
      |=  a=@dr
      ^-  json
      (numb (mul (div a ~s1) 1.000))
    ::
  --
::
:: state format upgrade helpers
::

:: none yet
--
