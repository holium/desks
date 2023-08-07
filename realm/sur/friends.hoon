::  friends [realm]
::
/-  resource, *contact-store, membership
|%
::
::  $friends: specifically used for the our space.
::
+$  friends-0     (map ship friend-0)
+$  friends   (map ship friend)
+$  is-public   ?
::
::  $friend: specifically used for the our space, keeps track of another
::    ship and allows metadata.
::
+$  friend-state  ?(%added %mutual)
+$  friend-tags   (set cord)
+$  friend-0
  $:  pinned=?
      tags=friend-tags
      status=?(%fren %following %follower)
  ==  
+$  friend
  $:  pinned=_|
      tags=friend-tags
      status=?(%fren %following %follower %contact %our)
      contact-info=(unit contact-info)
  ==
+$  contact-info
  $:  nickname=@t
      bio=@t
      color=@ux
      avatar=(unit @t)
      cover=(unit @t)
  ==
+$  contact-info-edit
  $:  nickname=(unit @t)
      bio=(unit @t)
      color=(unit @ux)
      avatar=(unit @t)
      cover=(unit @t)
  ==
::
::
+$  action
  $%  
      [%add-friend =ship]
      [%edit-friend =ship pinned=? tags=friend-tags]
      [%remove-friend =ship]
      ::  Poke friend actions
      [%be-fren ~]
      [%yes-fren ~]
      [%bye-fren ~]
      [%set-contact =ship contact-info=contact-info-edit]
      [%share-contact =ship]
      [%set-sync sync=?]
  ==
::
+$  reaction
  $%  
      [%friends =friends]
      [%friend =ship =friend]       :: reacts when old friend is updated
      [%new-friend =ship =friend]   :: reacts when a new friend is added
      [%bye-friend =ship]           :: reacts when a friend is removed 
  ==
::
::  Scry views
::
+$  view
  $%  
      [%friends =friends]
      [%contact-info =contact-info]
  ==
--
