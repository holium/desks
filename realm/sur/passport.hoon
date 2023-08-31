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
      pinned=?
      mtd=(map @t @t)
  ==
::
+$  action
  $%
      [%receive-contacts m=(map ship contact:common)]  :: other ship is dumping us its peers list
      [%request-contacts ~] :: other ship send this to us to ask us to give them our whole peers list
      [%get =ship]  :: when a client wants to threadpoke and get a full passport for a given ship
      [%add-link =req-id ln=passport-link:common]
      [%toggle-hide-logs toggle=?]
  ==
::
+$  req-id  [src=ship now=@da] :: the request-id, used for threads and venting
::
+$  vent
  $%  [%link =passport-link:common]
      [%ack ~]
  ==
--
