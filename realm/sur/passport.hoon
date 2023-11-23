/-  common
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      hide-logs=?  :: default hidden %.y
  ==
::
+$  action
  $%
      [%receive-contacts contacts=(list [@da contact:common])]  :: other ship is dumping us its peers list,
                                                                :: @da is updated-at on the bedrock row
      [%request-contacts ~] :: other ship send this to us to ask us to give them our whole peers list
      [%get =req-id]  :: when a client wants to threadpoke and get a full passport for a given ship
      [%get-as-row =req-id]  :: when a client wants to threadpoke and get a full passport for a given ship
      [%get-contact =req-id]  :: when a client wants to threadpoke and get a contact for a given ship
      [%add-friend =req-id =ship mtd=(map @t @t)]     :: client to ship
      [%get-friend mtd=(map @t @t)]                   :: ship to ship
      [%cancel-friend-request =req-id =ship]      :: client to ship
      [%revoke-friend-request ~]                  :: ship to ship
      [%handle-friend-request =req-id accept=? =ship] :: client to ship
      [%respond-to-friend-request accept=?]           :: ship to ship

      [%change-contact =req-id c=contact:common]   :: client to ship, we change our own contact info
      [%add-link =req-id ln=passport-link-container:common wallet-source=(unit @t)]  :: client to ship, we add a passport link
      [%change-passport =req-id p=passport:common]  :: client->ship, DOES NOT UPDATE `chain` or `crypto`, MUST use %add-link for that

      [%toggle-hide-logs toggle=?]

      [%reset ~]
      [%init-our-passport ~]
      [%add-pals-as-friends ~]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%link =passport-link:common]
      [%passport =passport:common]
      [%contact =contact:common]
      [%friend =friend:common]
      [%ack ~]
  ==
--
