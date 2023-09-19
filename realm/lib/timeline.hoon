/-  *timeline, cd=chat-db
|%
++  convert-messages
  |=  $:  our=@p
          created-at=@da
          =msg-id:cd
          =msg-part-id:cd
          =content:cd
          metadata=(map cord cord)
      ==
  ^-  (unit [[@p @da] timeline-post])
  ?+    -.content  ~
      %image
    =/  width=(unit @ud)
      ?~  get=(~(get by metadata) 'width')  ~
      ?~  rus=(rush u.get (cook head ;~(plug dem (jest 'px'))))
        ~&(failed-to-parse-width+u.get ~)
      rus
    =/  height=(unit @ud)
      ?~  get=(~(get by metadata) 'height')  ~
      ?~  rus=(rush u.get (cook head ;~(plug dem (jest 'px'))))
        ~&(failed-to-parse-height+u.get ~)
      rus
    :-  ~
    :-  [our created-at]  :-  ~  :-  ~
    :~  [%text 'This is a test.' %md %bold %italic]
        [%link p.content %image width height]
    ==
    ::
      %link
    ?^  vid=(parse-video p.content)
      :-  ~
      :-  [our created-at]
      :-  ~  :-  ~
      :~  :*  %text
              'This is a test.'
              %md  %bold  %italic
          ==
          :*  %link
              p.content
              %video
              [~ ~]
              u.vid
              ~
          ==
      ==
    ?:  (parse-image-extension p.content)
      =/  width=(unit @ud)
        ?~  get=(~(get by metadata) 'width')  ~
        ?~  rus=(rush u.get (cook head ;~(plug dem (jest 'px'))))
          ~&(failed-to-parse-width+u.get ~)
        rus
      =/  height=(unit @ud)
        ?~  get=(~(get by metadata) 'height')  ~
        ?~  rus=(rush u.get (cook head ;~(plug dem (jest 'px'))))
          ~&(failed-to-parse-height+u.get ~)
        rus
      :-  ~
      :-  [our created-at]  :-  ~  :-  ~
      :~  [%text 'This is a test.' %md %bold %italic]
          [%link p.content %image width height]
      ==
    =/  description=(unit @t)  ?~(get=(~(get by metadata) 'ogDescription') ~ get)
    =/  image=(unit @t)        ?~(get=(~(get by metadata) 'ogImage') ~ get)
    =/  site-name=(unit @t)    ?~(get=(~(get by metadata) 'ogSiteName') ~ get)
    =/  title=(unit @t)        ?~(get=(~(get by metadata) 'ogTitle') ~ get)
    =/  type=(unit @t)         ?~(get=(~(get by metadata) 'ogType') ~ get)
    ?:  =([~ ~ ~ ~ ~] [description image site-name title type])
      :-  ~
      :-  [our created-at]  :-  ~  :-  ~
      :~  [%text 'This is a test.' %md %bold %italic]
          [%link p.content %raw ~]
      ==
    :-  ~
    :-  [our created-at]
    :-  ~  :-  ~
    :~  :*  %text
            'This is a test.'
            %md  %bold  %italic
        ==
        :*  %link
            p.content
            %opengraph
            description
            image
            site-name
            title
            type
            ~
        ==
      ==
  ==
::
++  parse-video
  |=  link=@t
  ^-  (unit ?(%youtube %vimeo %dailymotion %file))
  ?^  src=(parse-video-source link)
    src
  (parse-video-extension link)
::
++  parse-video-source
  |=  link=@t
  ^-  (unit ?(%youtube %vimeo %dailymotion %file))
  %+  rush  link
  ;~  pose
    %+  cold  %vimeo
    ;~  plug
      (opt ;~(plug (jest 'http') (opt (just 's')) (jest '://')))
      (opt (jest 'www.'))
      (jest 'vimeo.com/')
      (star ;~(pose aln cab))
    ==
    %+  cold  %dailymotion
    ;~  plug
      (opt ;~(plug (jest 'http') (opt (just 's')) (jest '://')))
      (opt (jest 'www.'))
      (jest 'dailymotion.com/video/')
      (star ;~(pose aln cab))
    ==
    %+  cold  %youtube
    ;~  plug
      (opt ;~(plug (jest 'http') (opt (just 's')) (jest '://')))
      (opt (jest 'www.'))
      ;~  pose
        (jest 'youtube.com/watch?v=')
        (jest 'youtu.be/')
        (jest 'youtube.com/embed/')
        (jest 'youtube.com/v/')
      ==
      (star ;~(pose aln cab))
    ==
  ==
::
++  parse-video-extension
  |=  link=@t
  ^-  (unit ?(%youtube %vimeo %dailymotion %file))
  :: flip link text and send to lowercase; parse backwards
  :: (parsing happens from left to right)
  ::
  %+  rush  (crip (flop (cass (trip link))))
  %+  cold  %file
  ;~  plug
    ;~  pose
      (jest (crip (flop ".mp4")))
      (jest (crip (flop ".webm")))
      (jest (crip (flop ".ogg")))
      (jest (crip (flop ".ogv")))
      (jest (crip (flop ".avi")))
      (jest (crip (flop ".mov")))
      (jest (crip (flop ".wmv")))
      (jest (crip (flop ".flv")))
      (jest (crip (flop ".mpg")))
      (jest (crip (flop ".mpeg")))
    ==
    (star prn)
  ==
::
++  parse-image-extension
  |=  link=@t
  ^-  ?
  =-  ?=(^ -)
  :: flip link text and send to lowercase; parse backwards
  :: (parsing happens from left to right)
  ::
  %+  rush  (crip (flop (cass (trip link))))
  ;~  plug
    ;~  pose
      (jest (crip (flop ".jpg")))
      (jest (crip (flop ".webp")))
      (jest (crip (flop ".jpeg")))
      (jest (crip (flop ".png")))
      (jest (crip (flop ".gif")))
      (jest (crip (flop ".svg")))
      (jest (crip (flop ".avif")))
      (jest (crip (flop ".tiff")))
    ==
    (star prn)
  ==
::
++  opt
  |*  =rule
  (may rule ~)
::
++  may
  |*  [=rule else=*]
  ;~(pose rule (easy else))
::
++  random-reacts
  |=  [=path =id:common]
  ^-  (list react:common)
  =|  reacts=(list react:common)
  :: number of different emojis
  ::
  =/  num=@ud  +((mod (sham [%0 path id]) 3))
  =|  i=@ud
  |-
  ?:  =(i num)  reacts
  :: which emoji
  ::
  =/  emoji=@t
    (snag (mod (sham [%2 path id]) (lent some-emojis)) some-emojis)
  :: number of emojis of this type
  ::
  =/  count=@ud  +((mod (sham [%1 path id]) 3))
  =|  j=@ud
  |-
  ?:  =(j count)  ^$(i +(i))
  =/  =react:common  [emoji [%timeline-post 0v0] id path]
  $(j +(j), reacts [react reacts])
::
++  some-emojis
  ^-  (list @t)
  :~  '😀'
      '😁'
      '😂'
      '🤣'
      '😃'
      '😄'
      '😅'
      '😆'
      '😉'
      '😊'
      '😋'
      '😎'
      '😍'
      '😘'
      '😗'
      '😙'
      '😚'
      '☺'
      '🙂'
      '🤗'
      '🤩'
      '🤔'
      '🤨'
      '😐'
      '😑'
      '😶'
      '🙄'
      '😏'
      '😣'
      '😥'
      '😮'
      '🤐'
      '😯'
      '😪'
      '😫'
      '😴'
      '😌'
      '😛'
      '😜'
      '😝'
      '🤤'
      '😒'
      '😓'
      '😔'
      '😕'
      '🙃'
      '🤑'
      '😲'
      '☹'
      '🙁'
      '😖'
      '😞'
      '😟'
      '😤'
      '😢'
      '😭'
      '😦'
      '😧'
      '😨'
      '😩'
      '🤯'
      '😬'
      '😰'
      '😱'
      '😳'
      '🤪'
      '😵'
      '😡'
      '😠'
      '🤬'
      '😷'
      '🤒'
      '🤕'
      '🤢'
      '🤮'
      '🤧'
      '😇'
      '🤠'
      '🤡'
      '🤥'
      '🤫'
      '🤭'
      '🧐'
      '🤓'
      '😈'
      '👿'
      '👹'
      '👺'
      '💀'
      '👻'
      '👽'
      '🤖'
      '💩'
      '🤳'
      '💪'
      '👈'
      '👉'
      '☝'
      '👆'
      '🖕'
      '👇'
      '✌'
      '🤞'
      '🖖'
      '🤘'
      '🖐'
      '✋'
      '👌'
      '👍'
      '👎'
      '✊'
      '👊'
      '🤛'
      '🤜'
      '🤚'
      '👋'
      '🤟'
      '✍'
      '👏'
      '👐'
      '🙌'
      '🤲'
      '🙏'
      '🤝'
      '🙈'
      '🙉'
      '🙊'
      '🔥'
      '💧'
      '🌊'
  ==
--