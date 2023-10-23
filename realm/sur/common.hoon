|%
+$  type-prefix
  $?  %vote
      %rating
      %comment
      %tag
      %link
      %follow
      %relay
      %react
      %creds
      %chat
      %message
      %passport
      %friend
      %contact
      @tas
  ==
+$  type      [name=type-prefix hash=@uvH]  :: hash is (sham schema) for %general, and incrementing @uv for common types
+$  id        [=ship t=@da] :: ship is who created the row, t is when it was created since that's inherently unique in one-at-a-time only creation fashion
+$  rich-ref  [=id =path =type mtd=(map @t @t)]
+$  u-path-id  (unit [=path =id])
::
:: pre-built data-types
::

:: like/dislike upvote/downvote
+$  vote
  $:  up=?              :: true for like/upvote, false for dislike/downvote  0 -> 2
      parent-type=type  :: table name of the thing this vote is attached to  1 -> 6
      parent-id=id      :: id of the thing this vote is attached to          2 -> 14
      parent-path=path  ::                                                   3 -> 30
  ==
++  vote-type  `type`[%vote 0v0]
+$  vote-0
  $:  up=?              :: true for like/upvote, false for dislike/downvote  0 -> 2
      parent-type=type-prefix  :: table name of the thing this vote is attached to  1 -> 6
      parent-id=id      :: id of the thing this vote is attached to          2 -> 14
      parent-path=path  ::                                                   3 -> 30
  ==

:: 5 star rating, 100% scoring, etc
+$  rating
  $:  value=@rd         :: the rating. any real number. up to app to parse properly
      max=@rd           :: the maximum rating the application allows. (useful for aggregating, and making display agnostic)
      format=@tas       :: an app-specific code for indicating what "kind" of rating it is (5-star or 100% or 7/10 cats or whatever)
      parent-type=type  :: table name of the thing being rated
      parent-id=id      :: id of the thing being rated
      parent-path=path
  ==
++  rating-type  `type`[%rating 0v0]
+$  rating-0
  $:  value=@rd         :: the rating. any real number. up to app to parse properly
      max=@rd           :: the maximum rating the application allows. (useful for aggregating, and making display agnostic)
      format=@tas       :: an app-specific code for indicating what "kind" of rating it is (5-star or 100% or 7/10 cats or whatever)
      parent-type=type-prefix  :: table name of the thing being rated
      parent-id=id      :: id of the thing being rated
      parent-path=path
  ==

:: plain text snippet referencing some other object
+$  comment
  $:  txt=@t            :: the comment
      parent-type=type  :: table name of the thing being commented on
      parent-id=id      :: id of the thing being commented on
      parent-path=path
  ==
++  comment-type  `type`[%comment 0v0]
+$  comment-0
  $:  txt=@t            :: the comment
      parent-type=type-prefix  :: table name of the thing being commented on
      parent-id=id      :: id of the thing being commented on
      parent-path=path
  ==

:: reaction (emoji)
+$  react
  $:  react=@t          :: the emoji code
      parent-type=type  :: table name of the thing being commented on
      parent-id=id      :: id of the thing being commented on
      parent-path=path
  ==
++  react-type  `type`[%react 0v0]
+$  react-0
  $:  react=@t          :: the emoji code
      parent-type=type-prefix  :: table name of the thing being reacted to
      parent-id=id      :: id of the thing being reacted to
      parent-path=path
  ==

:: tag some <thing> with metadata (ex: 'funny' 'based' 'programming' etc)
+$  tag
  $:  tag=@t            :: the tag (ex: 'based')
      parent-type=type  :: table name of the thing being tagged
      parent-id=id      :: id of the thing being tagged
      parent-path=path
  ==
++  tag-type  `type`[%tag 0v0]
+$  tag-0
  $:  tag=@t            :: the tag (ex: 'based')
      parent-type=type-prefix  :: table name of the thing being tagged
      parent-id=id      :: id of the thing being tagged
      parent-path=path
  ==

:: directionally link two objects in some way
:: ex: ~zod has a :comment and a :post that expands upon it. he can
:: connect the two with a :link like:
::   ['inspiration' 'inspired by' ~zod %comment [~zod 0] %post [~zod 1]]
:: which the ui can then display at the bottom of the post with some fancy styling.
+$  link
  $:  key=@t            :: the key of the link, what the computer uses to find (ex: 'based')
      from-type=type    :: table name of the thing being linked from
      from-id=id        :: id of the thing being linked from
      from-path=path
      to-type=type      :: table name of the thing being linked to
      to-id=id          :: id of the thing being linked to
      to-path=path
  ==
++  link-type  `type`[%link 0v0]
+$  link-0
  $:  key=@t            :: the key of the link, what the computer uses to find (ex: 'based')
      from-type=type-prefix    :: table name of the thing being linked from
      from-id=id        :: id of the thing being linked from
      from-path=path
      to-type=type-prefix      :: table name of the thing being linked to
      to-id=id          :: id of the thing being linked to
      to-path=path
  ==

:: classic social graph information
+$  follow
  $:  leader=ship
      follower=ship     
      domain=path   :: maybe I only want to follow ~zod's %recipes, not their %rumors posts
  ==

:: the relay table is necessary for making retweets work on urbit
:: the goal includes the ability to count retweets within a space
::  (should come with ability to relay to all paths or just to a
::  particular path)
+$  relay-protocol  ?(%static %edit %all)
:: %static relays never change
:: %edit relays will push new versions when edits come through
:: %all will also delete when/if the original is deleted
+$  relay
  $:  =id   :: the id of what is being relayed
      =type :: type of what is being relayed
      =path :: where the thing originally came from
      revision=@ud
      protocol=relay-protocol
      deleted=?
  ==
++  relay-type  `type`[%relay 0v0]
+$  relay-0
  $:  =id   :: the id of what is being relayed
      type=type-prefix :: type of what is being relayed
      =path :: where the thing originally came from
      revision=@ud
      protocol=relay-protocol
      deleted=?
  ==

:: s3 storage creds
+$  creds
  $:
    endpoint=@t
    access-key-id=@t
    secret-access-key=@t
    buckets=(set @t)
    current-bucket=@t
    region=@t
  ==
++  creds-type  `type`[name=%creds hash=0v0]

::
+$  friend
  $:  =ship
      ::pending-outgoing = WE asked `ship` to be friend
      ::pending-incoming = `ship` asked US to be friend
      ::friend = pending `ship` accepted to be friend
      ::rejected = pending `ship` rejected to be friend
      status=?(%pending-outgoing %pending-incoming %friend %rejected)
      pinned=?
      mtd=(map @t @t)
  ==
++  friend-type  `type`[name=%friend hash=0v0]
::
+$  passport
  $:  =contact
      cover=(unit @t)
      user-status=?(%invisible %online)
      discoverable=?
      nfts=(list linked-nft)
      addresses=(list linked-address)
      default-address=@t
      recommendations=(set rich-ref)
      chain=passport-chain
      crypto=passport-crypto
  ==
++  passport-type  `type`[name=%passport hash=0v0]
::
+$  contact
  $:  =ship
      avatar=(unit avatar)
      color=(unit @t) :: i.e. #FCFCFC
      bio=(unit @t)
      display-name=(unit @t)
  ==
::
++  contact-type  `type`[name=%contact hash=0v0]
::
+$  avatar
  $%  [%image img=@t]
      [%nft nft=@t]
  ==
::
+$  linked-nft
  $:  chain-id=?(@tas %eth-mainnet %eth-testnet)
      token-id=@t         :: i.e. 8739
      contract-address=@t :: i.e. 0x789e...fee7
      name=@t             :: i.e. "Pixelady #599"
      image-url=@t
      owned-by=@t         :: the wallet address that owns the NFT
      token-standard=@t   :: i.e. ERC-721
  ==
::
+$  linked-address
  $:  wallet=@t   :: "rainbow", "metamask", etc
      address=@t
      pubkey=@t
      =crypto-signature
  ==
::
+$  crypto-signature
  $:  data=@t   ::  the full data blob being signed
      hash=@t   ::  a hash of the data (sha-256)
      signature-of-hash=@t :: the private-key encryption of the hash
      pubkey=@t :: the pubkey needed to decrypt the signature
  ==
::
+$  passport-chain  (list passport-link-container)
+$  passport-link-container   [link-type=@t data=@t hash=@t hash-signature=@t]
+$  passport-link
  $%  [%edge-add from-link-hash=@t to-link-hash=@t key=@t value=@t]
      [%edge-remove link-hash=@t]
      [%entity-add address=@t address-type=@t name=@t]
      [%entity-remove name=@t]
      [%key-add address=@t address-type=@t name=@t]
      [%key-remove address=@t]
      [%post-add type=@t data=json]
      [%post-edit link-hash=@t type=@t data=json]
      [%post-remove link-hash=@t]
      [%name-record-set name=@t record=@t]
      [%token-burn from-entity=@t amount=@rd]
      [%token-mint to-entity=@t amount=@rd]
      [%token-transfer to-entity=@t amount=@rd]
      [%signed-key-add address=@t address-type=@t key-signature=@t name=@t nonce=@ud timestamp=@ud]
  ==
+$  passport-data-link
  $:  mtd=passport-data-link-metadata
      data=passport-link
  ==
+$  passport-data-link-metadata
  $:  from-entity=@t
      signing-address=@t
      value=@ud
      link-id=@t
      epoch-block-number=@ud
      previous-epoch-nonce=@ud
      previous-epoch-hash=@t
      nonce=@ud
      previous-link-hash=@t
      data-block-number=@ud
      timestamp=@da
  ==
+$  pki-state
  $:  chain-owner-entities=(list @t)
      entity-to-addresses=(map @t (list @t))
      address-to-nonce=(map @t @ud)
      entity-to-value=(map @t @ud)
      address-to-entity=(map @t @t)
  ==
+$  passport-crypto
  $:  link-id=@t
      epoch-block=@ud
      data-block=@ud
      timestamp=@da
      previous-epoch-hash=@t
      =pki-state
      transaction-types=[link-names=(list @t) link-structs=@t]
      data-structs=[struct-names=(list @t) struct-types=@t]
      sig-chain-settings=[new-entity-balance=@ud epoch-length=@ud signing-key=@t data-state=json]
  ==

:: chat-db stuff
+$  chat
  $:  metadata=(map cord cord)
      type=@tas     :: not officially specified, up to user to interpret for maybe %dm vs %group or %chat vs %board or whatever
                    :: if %nft-gated, the `nft` logic comes into play
      pins=(set id)
      invites=@tas  :: must either match `peer-role` type or be keyword %anyone, or else no one will be able to invite
      peers-get-backlog=?
      max-expires-at-duration=@dr  :: optional chat-wide enforced expires-at on messages. 0 or *@dr means "not set"
      nft=(unit [contract=@t chain=@t standard=@t]) :: contract is the 0x789... address, chain is "eth-mainnet" or whatever, standard is "ERC-721"
  ==
++  chat-type  `type`[name=%chat hash=0v0]
+$  chat-0
  $:  metadata=(map cord cord)
      type=@tas     :: not officially specified, up to user to interpret for maybe %dm vs %group or %chat vs %board or whatever
      pins=(set id)
      invites=@tas  :: must either match `peer-role` type or be keyword %anyone, or else no one will be able to invite
      peers-get-backlog=?
      max-expires-at-duration=@dr  :: optional chat-wide enforced expires-at on messages. 0 or *@dr means "not set"
  ==
+$  message
  $:  chat-id=id
      reply-to=u-path-id
      expires-at=@da  :: *@da is treated as "unset"
      content=(list msg-part)
  ==
++  message-type  `type`[name=%message hash=0v0]
+$  msg-part  [=formatted-text metadata=(map cord cord)]
+$  formatted-text
  $%  [%custom name=cord value=cord] :: general data type
      [%markdown p=cord]
      [%plain p=cord]
      [%bold p=cord]
      [%italics p=cord]
      [%strike p=cord]
      [%bold-italics p=cord]
      [%bold-strike p=cord]
      [%italics-strike p=cord]
      [%bold-italics-strike p=cord]
      [%blockquote p=cord]
      [%inline-code p=cord]
      [%ship p=ship]
      [%code p=cord]
      [%link p=cord]
      [%image p=cord]
      [%ur-link p=cord]      :: for links to places on the urbit network
      [%react p=cord]        :: for emojii reactions to messages
      [%status p=cord]       :: for automated messages like "X joined the chat"
      [%break ~]
  ==
--
