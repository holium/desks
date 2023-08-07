|%
+$  type 
  $?  %vote
      %rating
      %comment
      %tag
      %link
      %follow
      %relay
      %react
      %creds
      @tas
  ==
+$  id        [=ship t=@da] :: ship is who created the row, t is when it was created since that's inherently unique in one-at-a-time only creation fashion
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

:: 5 star rating, 100% scoring, etc
+$  rating
  $:  value=@rd         :: the rating. any real number. up to app to parse properly
      max=@rd           :: the maximum rating the application allows. (useful for aggregating, and making display agnostic)
      format=@tas       :: an app-specific code for indicating what "kind" of rating it is (5-star or 100% or 7/10 cats or whatever)
      parent-type=type  :: table name of the thing being rated
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

:: reaction (emoji)
+$  react
  $:  react=@t          :: the emoji code
      parent-type=type  :: table name of the thing being commented on
      parent-id=id      :: id of the thing being commented on
      parent-path=path
  ==

:: tag some <thing> with metadata (ex: 'funny' 'based' 'programming' etc)
+$  tag
  $:  tag=@t            :: the tag (ex: 'based')
      parent-type=type  :: table name of the thing being tagged
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
--

