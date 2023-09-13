::  db [realm]:
::  TODO:
::  - constraints via paths-table settings
/-  *passport, common, db
/+  scries=bedrock-scries, eth=ethereum
|%
::
:: helpers
::
++  split-sig
  |=  sig=@
  ^-  [v=@ r=@ s=@]
  |^
    =^  v  sig  (take 3)
    =^  s  sig  (take 3 32)
    =^  r  sig  (take 3 32)
    =?  v  (gte v 27)  (sub v 27)
    [v r s]
  ::
  ++  take
    |=  =bite
    [(end bite sig) (rsh bite sig)]
  --
++  verify-message
  |=  [msg=@t sig=@t addr=@t]  ^-  ?
  =/  hashed-msg=@ux
    %-  keccak-256:keccak:crypto
    %-  as-octs:mimes:html
    %-  crip
    ^-  tape
    %+  weld
    (trip '\19Ethereum Signed Message:\0a')
    %+  weld
    (en-json:html (numb:enjs:format (lent (trip msg))))
    (trip msg)
    ::export function hashMessage(message: Bytes | string): string {
    ::    if (typeof(message) === "string") { message = toUtf8Bytes(message); }
    ::    return keccak256(concat([
    ::        toUtf8Bytes(messagePrefix),
    ::        toUtf8Bytes(String(message.length)),
    ::        message]));
  ~&  >>>  hashed-msg

  =/  ux-sig=@ux  (hex-to-num:eth sig)
  =/  vrs         (split-sig ux-sig)
  =/  pubkey=@ux::SigningKey.recoverPublicKey(digest, signature)
    %-  serialize-point:secp256k1:secp:crypto
    (ecdsa-raw-recover:secp256k1:secp:crypto hashed-msg vrs)
  ~&  >>>  pubkey
  ~&  >>>  "addr {<addr>} address-from-pub {<(address-from-pub:key:eth pubkey)>}"

  :: if the passed in address equals the address for the the recovered public key of the sig, then it is verified
  =((hex-to-num:eth addr) (address-from-pub:key:eth pubkey))
++  ether-hash-to-ux
  |=  str=@t
  ^-  @ux
  =/  ta=tape  (cass (slag 2 (trip str)))
  =/  reordered=tape  ""
  =/  i=@ud  0
  =/  ready=tape
    |-
      ?:  =(0 (lent ta))
        +.reordered
      =/  b1=@t  (snag 0 ta)
      =/  b2=@t  (snag 1 ta)
      ?:  =(1 (mod i 2))
        $(reordered ['.' b1 b2 reordered], ta +.+.ta, i +(i))
      $(reordered [b1 b2 reordered], ta +.+.ta, i +(i))
  `@ux`(slav %ux (crip ['0' 'x' ready]))
::
++  parse-signing-key
  |=  ln=passport-link-container:common
  ^-  @t
  =/  pr=passport-crypto:common           (passport-root:dejs (need (de-json:html data.ln)))
  ?:  =('PASSPORT_ROOT' link-type.ln)     signing-key.sig-chain-settings.pr
  ?:  =('KEY_ADD' link-type.ln)           ''::signing-public-key:link-metadata:(passport-data-link:dejs (need (de-json:html data.ln)))
  ?:  =('KEY_REMOVE' link-type.ln)        ''::signing-public-key:link-metadata:(passport-data-link:dejs (need (de-json:html data.ln)))
  ?:  =('NAME_RECORD_SET' link-type.ln)   ''::signing-public-key:link-metadata:(passport-data-link:dejs (need (de-json:html data.ln)))
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
++  edit-req
  |=  [our=ship =type:common =id:common data=columns:db =req-id]
  ^-  card
  [%pass /dbpoke %agent [our %bedrock] %poke %db-action !>([%edit req-id id /private type data ~])]
::
++  edit
  |=  [our=ship =type:common =id:common data=columns:db]
  (edit-req our type id data [our *@da])
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
    (some (remove-newlines u.display-name.contact))
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
:: pokes
++  receive-contacts
:: our ship gets this from another ship when they are giving us some contacts
::passport &passport-action [%receive-contacts (malt [~zod [~zod [%image ''] ~ [~ 'ZOOOD']]]~)]
  |=  [m=peers state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%receive-contacts: {<m>}")

  :: loop through the ships they sent us
  =/  ships=(list ship)  ~(tap in ~(key by m))
  |-
    ?:  =(0 (lent ships))
      [~ state]
    =/  shp=ship  (snag 0 ships)
    =/  con=contact:common  (~(got by m) shp)
    =.  avatar.con
      ?~  avatar.con  ~
      %-  some
      ?-  -.u.avatar.con
          %image
        [%image (url-encode img.u.avatar.con)]
          %nft
        [%nft (url-encode nft.u.avatar.con)]
      ==
    %=  $
      :: add to the peers map
      peers.state   (~(put by peers.state) ship.con con)
      ships         +.ships
    ==
::
++  request-contacts
:: our ship gets this from another ship who wants to learn our contacts
::passport &passport-action [%request-contacts ~]
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%request-contacts from {<src.bowl>}")

  =/  ourcontact=contact:common  contact:(our-passport:scries bowl)
  =/  response  !>([%receive-contacts (~(put by peers.state) our.bowl ourcontact)])
  =/  cards=(list card)
    [%pass /contacts %agent [src.bowl dap.bowl] %poke %passport-action response]~
  [cards state]
::
++  add-friend
::passport &passport-action [%add-friend [our now] ~zod ~]
  |=  [[=req-id =ship mtd=(map @t @t)] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-friend: {<req-id>} {<ship>}")

  :: TODO check that we don't already have a friendship with this ship
  =/  new-fren=friend:common  [ship %requested %.n mtd]

  =/  cards=(list card)
    :~  (create-req our.bowl friend-type:common [%friend new-fren] req-id)
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%get-friend mtd])]
        (req ship dap.bowl)
    ==
  [cards state]
::
++  get-friend
::passport &passport-action [%get-friend ~]
  |=  [mtd=(map @t @t) state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%get-friend: {<mtd>} from {<src.bowl>}")

  =/  new-fren=friend:common  [src.bowl %pending %.n mtd]

  =/  cards=(list card)
    :~  (req src.bowl dap.bowl)
        (create our.bowl friend-type:common [%friend new-fren])
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
  =.  status.friend.new-fren    ?:(accept %friend %rejected)

  =/  cards=(list card)
    :~  [%give %fact ~[vent-path] passport-vent+!>([%friend friend.new-fren])]
        kickcard
        (edit our.bowl friend-type:common id.new-fren [%friend friend.new-fren])
        [%pass /selfpoke %agent [ship dap.bowl] %poke %passport-action !>([%respond-to-friend-request accept])]
        (req ship dap.bowl)
    ==
  [cards state]
::
++  respond-to-friend-request
::passport &passport-action [%respond-to-friend-request %.y]
  |=  [accept=? state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%respond-to-friend-request: {<accept>} from {<src.bowl>}")

  =/  new-fren                  (get-friend:scries src.bowl bowl)
  =.  status.friend.new-fren    ?:(accept %friend %rejected)

  =/  cards=(list card)
    :~  (req src.bowl dap.bowl)
        (edit src.bowl friend-type:common id.new-fren [%friend friend.new-fren])
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

  ~&  "getting passport"
  =/  pass=passport:common   (our-passport:scries bowl)
  ~&  >  pass
  =/  src-fren=?  (is-friend:scries src.bowl bowl)
  ~&  >  src-fren
  :: only actually give out the passport if we are discoverable
  :: OR we are friends with the requester
  ?>  |(discoverable.pass src-fren)

  =/  cards=(list card)
    :-  [%give %fact ~[vent-path] passport-vent+!>([%passport pass])]
    :-  kickcard
    ~
  [cards state]
::
++  change-contact
::passport &passport-action [%change-contact [our now] ~zod [%image 'url'] [~ '#fcfcfc'] [~ 'my bio'] [~ 'ZOOOD']]
  |=  [[=req-id c=contact:common] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%change-contact: {<req-id>} {<c>}")
  :: assure it's us, and we're editing our self
  ?>  =(our.bowl src.bowl)
  ?>  =(our.bowl ship.c)

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  p=passport:common  (our-passport:scries bowl)
  =.  contact.p  (cleanup-contact c)

  =/  cards=(list card)
    :~  (edit-req our.bowl passport-type:common (our-passport-id:scries bowl) [%passport p] req-id)
        [%give %fact ~[vent-path] passport-vent+!>([%passport p])]
        kickcard
    ==
  [cards state]
::
++  add-link
::passport &passport-action [%add-link passport-link-container]
  |=  [[=req-id ln=passport-link-container:common] state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%add-link: {<req-id>} {<ln>}")
  :: assure it's us
  ?>  =(our.bowl src.bowl)

  =/  vent-path=path  /vent/(scot %p src.req-id)/(scot %da now.req-id)
  =/  kickcard=card  [%give %kick ~[vent-path] ~]

  =/  p=passport:common   (our-passport:scries bowl)
  :: TODO verify the link is valid, then save it to bedrock
  :: also probably need to make updates to `crypto.p` and the pki state

  ~&  ln
  ~&  (ether-hash-to-ux hash.ln)
  ~&  `@ux`(shax data.ln)
  ~&  (parse-signing-key ln)
  ~&  `@ux`(hex-to-num:eth hash.ln)
  :: validate the hash of data is what the payload claims it is
  ?>  =((shax data.ln) (ether-hash-to-ux hash.ln))

  :: parse the signer address
  =/  addr=@t  (parse-signing-key ln)
  ~&  >  (verify-message hash.ln hash-signature.ln addr)
  ?>  (verify-message hash.ln hash-signature.ln addr)
  :: and verify that the signing key matches the signature and the message
  :: TODO translate the strings into urbit-atoms bytes
  ::=.  chain.p             (snoc chain.p ln)

  =/  cards=(list card)
    :~  (edit our.bowl passport-type:common (our-passport-id:scries bowl) [%passport p])
        [%give %fact ~[vent-path] passport-vent+!>([%passport p])]
        kickcard
    ==
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
++  init-our-passport  :: (does nothing if already exists)
  |=  [state=state-0 =bowl:gall]
  ^-  (quip card state-0)
  =/  log1  (maybe-log hide-logs.state "%init-our-passport: at {<now.bowl>}")
  ?.  =(peers.state ~)  `state
  :: TODO ask %pals for as many contacts to prepopulate as we can and
  :: TODO create a poke to auto-add friends from mutuals in %pals
  =/  old-friends  .^(json %gx /(scot %p our.bowl)/friends/(scot %da now.bowl)/all/noun)
  =/  contacts=(list contact:common)
    %+  turn
      (contacts-from-friends:dejs old-friends)
    cleanup-contact
  =/  our-contact=contact:common
    %+  snag  0
    (skim contacts |=(c=contact:common =(our.bowl ship.c)))
  =/  p=passport:common
    [our-contact ~ %online %.y ~ ~ '' ~ ~ *passport-crypto:common]
  =.  peers.state  (malt (turn contacts |=(c=contact:common [ship.c c])))
  =/  cards=(list card)
    :~  (create our.bowl passport-type:common [%passport p])
    ==
  [cards state]
::
::
::  JSON
::
++  dejs
  =,  dejs:format
  |%
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
          %nft    [%nft (so (~(got by p.jon) 'nft'))]
        ==
    ==
  ::
  ++  hex-str  :: convert @ux formatted string into web #FFAA00 color format string
    |=  jon=json
    ^-  @t
    =/  urbit-format=@t  (so jon)
    ?:  =('0x0' urbit-format)  '#000000'
    =/  tr=tape  (trip urbit-format)
    ?:  (lth (lent tr) 9)  '#000000' :: for weird parsing, just "forget" the color
    (crip ['#' (oust [2 1] (slag 2 tr))])
  ::
  ++  passport-data-link
    %-  ot
    :~  [%link-metadata de-passport-data-link-metadata]
        [%link-data de-passport-link]
    ==
  ::
  ++  de-passport-link
    |=  jon=json
    ^-  passport-link:common
    ?>  ?=([%o *] jon)
    =/  gt  ~(got by p.jon)
    =/  link-type=@tas   ((se %tas) (gt 'link-type'))
    ?+  link-type  !!
        %edge-add
      [%edge-add (so (gt 'from-link-hash')) (so (gt 'to-link-hash')) (so (gt 'key')) (so (gt 'value'))]
        %edge-remove
      [%edge-remove (so (gt 'link-hash'))]
        %entity-add
      [%entity-add (so (gt 'public-key')) (so (gt 'public-key-type')) (so (gt 'name'))]
        %key-add
      [%key-add (so (gt 'public-key')) (so (gt 'public-key-type')) (so (gt 'name'))]
        %key-remove
      [%key-remove (so (gt 'name'))]
        %post-add
      [%post-add (so (gt 'type')) (gt 'data')]
        %post-edit
      [%post-edit (so (gt 'link-hash')) (so (gt 'type')) (gt 'data')]
        %post-remove
      [%post-remove (so (gt 'link-hash'))]
        %name-record-set
      [%name-record-set (so (gt 'name')) (so (gt 'record'))]
        %token-burn
      [%token-burn (so (gt 'from-entity')) (ne (gt 'amount'))]
        %token-mint
      [%token-mint (so (gt 'to-entity')) (ne (gt 'amount'))]
        %token-transfer
      [%token-transfer (so (gt 'to-entity')) (ne (gt 'amount'))]
    ==
  ::
  ++  de-passport-data-link-metadata
    %-  ot
    :~  [%from-entity so]
        [%signing-public-key so]
        [%value ni]
        [%link-id so]
        [%epoch-block-number ni]
        [%previous-epoch-nonce ni]
        [%previous-epoch-hash so]
        [%nonce ni]
        [%previous-link-hash so]
        [%data-block-number ni]
        [%timestamp di]
    ==
  ::
  ++  passport-root
    %-  ot
    :~  ['link_id' so]
        ['epoch_block_number' ni]
        ['data_block_number' ni]
        ['timestamp' di]
        ['previous_epoch_hash' so]
        ['pki_state' de-pki-state]
        ['transaction_types' (ot ~[['link_names' (ar so)] ['link_structs' so]])]
        ['data_structs' (ot ~[['struct_names' (ar so)] ['struct_types' so]])]
        ['sig_chain_settings' (ot ~[['new_entity_balance' ni] ['epoch_length' ni] ['signing_key' so] ['data_state' nuthing]])]
    ==
  ::
  ++  nuthing
    |=  jon=json
    ^-  json
    jon
  ::
  ++  de-pki-state
    %-  ot
    :~  ['chain_owner_entities' (ar so)]
        ['entity_to_public_keys' (om (ar so))]
        ['public_key_to_nonce' (om ni)]
        ['entity_to_value' (om ni)]
        ['public_key_to_entity' (om so)]
    ==
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
          [%add-friend de-add-friend]
          [%handle-friend-request de-handle-friend-request]
          [%change-contact de-change-contact]
      ==
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
    ++  de-contact
      %-  ot
      :~  [%ship de-ship]
          [%avatar de-avatar]
          [%color so:dejs-soft:format]
          [%bio so:dejs-soft:format]
          [%display-name so:dejs-soft:format]
      ==
    ::
    ++  de-add-friend
      |=  jon=json
      ^-  [req-id ship (map @t @t)]
      ?>  ?=([%o *] jon)
      =/  gt  ~(got by p.jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      =/  id=id:common  
        ?~  request-id  [~zod ~2000.1.1]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
        (de-id u.request-id)
      :*  id
          (de-ship (gt 'ship'))
          ((om so) (gt 'mtd'))
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
      ^-  [req-id passport-link-container:common]
      ?>  ?=([%o *] jon)
      =/  request-id=(unit json)  (~(get by p.jon) 'request-id')
      ~&  jon
      ?~  request-id
        [[~zod ~2000.1.1] (de-add-link jon)]  :: if the poke-sender didn't care enough to pass a request id, just use a fake one
      [(de-id u.request-id) (de-add-link jon)]
    ::
    ++  de-add-link
      %-  ot
      :~  ['link_type' so]
          [%data so]
          [%hash so]
          ['signature_of_hash' so]
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
          ['chain' a+(turn chain.p en-link)]
          ['crypto' (en-p-crypto crypto.p)]
      ==
    ::
    ++  en-p-crypto
      |=  cryp=passport-crypto:common
      ^-  json
      %-  pairs
      :~  ['link-id' s+link-id.cryp]
          ['epoch-block' (numb epoch-block.cryp)]
          ['data-block' (numb data-block.cryp)]
          ['timestamp' (time timestamp.cryp)]
          ['previous-epoch-hash' s+previous-epoch-hash.cryp]
          ['pki-state' s+%not-implemented]
          ['transaction-types' s+%not-implemented]
          ['data-structs' s+%not-implemented]
          :-  'sig-chain-settings'
          %-  pairs
          :~  ['new-entity-balance' (numb new-entity-balance.sig-chain-settings.cryp)]
              ['epoch-length' (numb epoch-length.sig-chain-settings.cryp)]
              ['signing-key' s+signing-key.sig-chain-settings.cryp]
          ==
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
            ['public-key' s+public-key.ln]
            ['public-key-type' s+public-key-type.ln]
            ['name' s+name.ln]
        ==
          %entity-remove
        :~  ['link-type' [%s -.ln]]
            ['name' s+name.ln]
        ==
          %key-add
        :~  ['link-type' [%s -.ln]]
            ['public-key' s+public-key.ln]
            ['public-key-type' s+public-key-type.ln]
            ['name' s+name.ln]
        ==
          %key-remove
        :~  ['link-type' [%s -.ln]]
            ['name' s+name.ln]
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
          %nft  ['nft' s+nft.u.a]
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
