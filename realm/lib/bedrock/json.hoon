/-  *db, common
|%

++  dejs
  =,  dejs:format
  |%
  ++  decode-row
    |=  [jon=json state=state-2]
    ^-  row
    ?>  ?=([%o *] jon)
    =/  gt  ~(got by p.jon)
    =/  data-type=type:common  (de-type (gt 'type'))
    =/  sch=schema
    ?~  (~(get by schemas.state) data-type)  ~
    (~(got by schemas.state) data-type)
    :*  (pa (gt 'path'))
        (de-id (gt 'id'))
        data-type
        (decode-data (gt 'data') data-type sch)
        (di (gt 'created-at'))
        (di (gt 'updated-at'))
        (di (gt 'received-at'))
    ==
  ::
  ++  decode-data
    |=  [jon=json =type:common =schema]
    ^-  columns
    ?+  name.type
        [%general ((de-cols schema) jon)]
      %vote
        ?:  =(hash.type hash:vote-type:common)
          [%vote (de-vote jon)]
        [%general ((de-cols schema) jon)]
      %comment
        ?:  =(hash.type hash:comment-type:common)
          [%comment (de-comment jon)]
        [%general ((de-cols schema) jon)]
      %relay
        ?:  =(hash.type hash:relay-type:common)
          [%relay (de-relay jon)]
        [%general ((de-cols schema) jon)]
      %creds
        ?:  =(hash.type hash:creds-type:common)
          [%creds (de-creds jon)]
        [%general ((de-cols schema) jon)]
      %chat
        ?:  =(hash.type hash:chat-type:common)
          [%chat (de-chat jon)]
        [%general ((de-cols schema) jon)]
      %message
        ?:  =(hash.type hash:message-type:common)
          [%message (de-message jon)]
        [%general ((de-cols schema) jon)]
    ==
  ::
  ++  de-cols
    |=  sch=schema
    |=  jon=json
    ^-  (list @)
    ?>  ?=([%a *] jon)
    =/  index=@ud   0
    =/  result      *(list @)
    |-
      ?:  =(index (lent p.jon))
        result
      =/  type-key            t:(snag index sch)
      =/  datatom             (snag index `(list json)`p.jon)
      =/  next=@
        ?:  =(type-key 'rd')    (ne datatom)
        ?:  =(type-key 'ud')    (ni datatom)
        ?:  =(type-key 'da')    (di datatom)
        ?:  =(type-key 'dr')    (dri datatom)
        ?:  =(type-key 't')     (so datatom)
        ?:  =(type-key 'f')     (bo datatom)
        ?:  =(type-key 'p')     ((se %p) datatom)
        ?:  =(type-key 'id')    (jam (de-id datatom))
        ?:  =(type-key 'type')  (jam (de-type datatom))
        ?:  =(type-key 'unit')  (jam (so:dejs-soft:format datatom))
        ?:  =(type-key 'path')  (jam (pa datatom))
        ?:  =(type-key 'list')  (jam ((ar so) datatom))
        ?:  =(type-key 'set')   (jam ((as so) datatom))
        ?:  =(type-key 'map')   (jam ((om so) datatom))
        !!
      $(index +(index), result (snoc result next))
  ::
  ++  de-vote
    %-  ot
    :~  [%up bo]
        [%parent-type de-type]
        [%parent-id de-id]
        [%parent-path pa]
    ==
  ::
  ++  de-creds
    %-  ot
    :~  [%endpoint so]
        [%access-key-id so]
        [%secret-access-key so]
        [%buckets (as so)]
        [%current-bucket so]
        [%region so]
    ==
  ::
  ++  de-comment
    %-  ot
    :~  [%txt so]
        [%parent-type de-type]
        [%parent-id de-id]
        [%parent-path pa]
    ==
  ::
  ++  de-relay
    %-  ot
    :~  [%id de-id]
        [%type de-type]
        [%path pa]
        [%revision ni]
        [%protocol de-relay-protocol]
        [%deleted bo]
    ==
  ::
  ++  de-chat
    %-  ot
    :~  [%metadata (om so)]
        [%type (se %tas)]
        [%pins (as de-id)]
        [%invites (se %tas)]
        [%peers-get-backlog bo]
        [%max-expires-at-duration null-or-dri]
        [%nft (ot ~[contract+so chain+so standard+so]):dejs-soft:format]
    ==
  ::
  ++  de-message
    %-  ot
    :~  [%chat-id de-id]
        [%reply-to (mu path-and-id)]
        [%expires-at da-or-bunt-null]
        [%content (ar de-msg-part)]
    ==
  ::
  ++  de-msg-part
    %-  ot
    :~  [%formatted-text de-formatted-text]
        [%metadata (om so)]
    ==
  ::
  ++  de-formatted-text
    %-  of
    :~  
        [%plain so]
        [%markdown so]
        [%bold so]
        [%italics so]
        [%strike so]
        [%bold-italics so]
        [%bold-strike so]
        [%italics-strike so]
        [%bold-italics-strike so]
        [%blockquote so]
        [%inline-code so]
        [%code so]
        [%image so]
        [%ur-link so]
        [%react so]
        [%break ul]
        [%ship de-ship]
        [%link so]
        [%custom (ot ~[[%name so] [%value so]])]
        [%status so]
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
  ++  path-and-id
    %-  ot
    :~  
        [%path pa]
        [%id de-id]
    ==
  ::
  ++  de-relay-protocol
    %+  cu
      tas-to-relay-protocol
    (se %tas)
  ::
  ++  tas-to-relay-protocol
    |=  t=@tas
    ^-  relay-protocol:common
    ?+  t  !!
      %static   %static
      %edit     %edit
      %all      %all
    ==
  ::
  ++  de-ship  (su ;~(pfix sig fed:ag))
  ::
  ++  da-or-bunt-null   :: specify in integer milliseconds, returns a @dr
    |=  jon=json
    ^-  @da
    ?+  jon   !!
      [%n *]  (di jon)
      ~       *@da
    ==
  ::
  ++  dri   :: specify in integer milliseconds, returns a @dr
    (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) ni)
  ::
  ++  null-or-dri   :: specify in integer milliseconds, returns a @dr
    (cu |=(t=@ud ^-(@dr (div (mul ~s1 t) 1.000))) null-or-ni)
  ::
  ++  null-or-ni  :: accepts either a null or a n+'123', and converts nulls to 0, non-null to the appropriate number
    |=  jon=json
    ^-  @ud
    ?+  jon  !!
      [%n *]  (rash p.jon dem)
      ~       0
    ==
  --

--
