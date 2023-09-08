/-  common, db, cd=chat-db
|%
+$  cid  @t
:: blocks define a standard format
:: for displaying timeline posts
::
++  block
  =<  block
  |%
  +$  block
    $%  [%text text]
        [%link link]
    ==
  ::
  +$  text
    $:  text=@t
        size=?(%sm %md %lg)
        weight=?(%normal %bold)
        style=?(%normal %italic)
    ==
  ::
  ++  link
    =<  link
    |%
    +$  link  [url=@t =metadata]
    ++  metadata
      =<  metadata
      |%
      +$  metadata
        $%  [%image image]
            [%video video]
            [%audio audio]
            [%file file]
            [%link link]
            [%misc misc]
        ==
      :: metadata currently stubbed out
      ::
      +$  image
        $:  width=(unit @ud)
            height=(unit @ud)
        ==
      ::
      +$  video
        $:  type=?(%youtube %vimeo %dailymotion %file)
            orientation=(unit ?(%portrait %landscape))
        ==
      ::
      +$  audio  ~
      :: potential future features:
      :: join
      ::   join a group
      ::   join a chat
      ::   join a space
      :: app
      ::
      +$  file  ~
      +$  link
        $%  [%raw ~]
            $:  %opengraph
                description=(unit @t)
                image=(unit @t)
                site-name=(unit @t)
                title=(unit @t)
                type=(unit @t)
                author=(unit @t)
            ==
        ==
      ::
      +$  misc  (map @t @t)
      --
    --
  --
::
+$  parent
  $:  =type:common
      =id:common
      =path
  ==
:: possible source application information
::
+$  app
  $:  name=@t
      icon=@t
      action=@t
  ==
::
+$  timeline-post
  $:  parent=(unit parent)
      app=(unit app)
      blocks=(list block)
  ==
::
+$  timeline
  $:  =path
      curators=(set ship) :: additional permission information?
      posts=(map path timeline-post):: ((mop @ timeline-post) gth) ? :: @ is time in unix-ms
  ==
::
+$  action
  $%  [%create-timeline =path curators=(set ship)]
      [%delete-timeline =path]
      [%create-timeline-post =path post=timeline-post]
      [%delete-timeline-post =path key=path]
      [%add-forerunners force=?]
      [%create-bedrock-timeline =path]
      [%create-bedrock-timeline-post =path req-id=[@p @da] post=timeline-post]
      [%add-forerunners-bedrock force=?]
  ==
::
+$  update  ~
+$  view
  $%  [%messages msgs=messages-table:cd]
      [%types types=(set [term (set cord)])]
      [%timeline =timeline]
      [%timelines timelines=(map path timeline)]
  ==
--
