/-  common
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      =peers
      hide-logs=?  :: default hidden %.y
  ==
::
+$  peers    (map ship contact:common) :: all known peers
::
+$  action
  $%
      [%receive-contacts m=(map ship contact:common)]  :: other ship is dumping us its peers list
      [%request-contacts ~] :: other ship send this to us to ask us to give them our whole peers list
      [%get =req-id]  :: when a client wants to threadpoke and get a full passport for a given ship
      [%add-friend =req-id =ship mtd=(map @t @t)]     :: client to ship
      [%get-friend mtd=(map @t @t)]                   :: ship to ship
      [%handle-friend-request =req-id accept=? =ship] :: client to ship
      [%respond-to-friend-request accept=?]           :: ship to ship

      [%change-contact =req-id c=contact:common]   :: client to ship, we change our own contact info
      [%add-link =req-id ln=passport-link-container:common]  :: client to ship, we add a passport link
      [%change-passport =req-id p=passport:common]  :: client->ship, DOES NOT UPDATE `chain` or `crypto`, MUST use %add-link for that

      [%toggle-hide-logs toggle=?]

      [%init-our-passport ~]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%link =passport-link:common]
      [%passport =passport:common]
      [%friend =friend:common]
      [%ack ~]
  ==
--