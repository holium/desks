/-  common
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      =peers
      friends=(map ship fren)
      hide-logs=?  :: default hidden %.y
  ==
::
+$  peers    (map ship contact:common) :: all known peers
::
+$  fren
  $:  =ship
      ::requested = WE asked `ship` to be friend
      ::pending = `ship` asked US to be friend
      ::friend = pending `ship` accepted to be friend
      ::rejected = pending `ship` rejected to be friend
      status=?(%requested %pending %friend %rejected)
      pinned=?
      mtd=(map @t @t)
  ==
::
+$  action
  $%
      [%receive-contacts m=(map ship contact:common)]  :: other ship is dumping us its peers list
      [%request-contacts ~] :: other ship send this to us to ask us to give them our whole peers list
      [%get =req-id]  :: when a client wants to threadpoke and get a full passport for a given ship
      [%add-link =req-id ln=passport-link:common]
      [%add-friend =req-id =ship mtd=(map @t @t)]     :: client to ship
      [%get-friend mtd=(map @t @t)]                   :: ship to ship
      [%handle-friend-request =req-id accept=? =ship] :: client to ship
      [%respond-to-friend-request accept=?]           :: ship to ship
      [%toggle-hide-logs toggle=?]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%link =passport-link:common]
      [%passport =passport:common]
      [%ack ~]
  ==
--