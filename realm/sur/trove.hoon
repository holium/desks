/-  spaces-store
|%
+$  space   space-path:spaces-store
+$  tope   (pair ship cord)         :: trove path
::
+$  id      @uvTROVE
::
+$  node    [url=cord dat=fimet]
::
+$  trail   path          :: folder path in trove
+$  tract   [fomet (map id node)] :: metadata and file contents of a trove folder
+$  trove   $~([fil=[~ u=*tract] dir=~] (axal tract)) :: default contains root
+$  banned  (set ship)
+$  troves  (map tope trove-data)
::
+$  trove-data
  $:  name=cord
      =perms
      =trove
  ==
::
++  perms
  $:  admins=?(%r %rw)
      member=?(~ %r %rw)
      custom=(map ship ?(%r %rw))
  ==
:: folder metadata
::
+$  fomet
  $:  from=@da
      by=@p
  ==
:: file metadata
::
+$  fimet
  $:  from=@da
      by=@p
      title=cord
      description=cord
      extension=cord
      size=cord
      key=cord
  ==
:: pokes to ssot (space host) from space members
::
++  action
  =<  action
  |%
  +$  action
    $%  [%util util-action]
        [%space =space space-action]
        [%trove [=space =tope] trove-action]
    ==
  +$  util-action
    $%  [%follow-many spaces=(list space)]
    ==
  +$  space-action
    $%  [%add-trove name=term =perms]
        [%rem-trove =tope]
        [%banned =banned]
    ==
  +$  trove-action
    $%  [%reperm =perms]
        [%edit-name name=cord]
        [%add-folder =trail]
        [%rem-folder =trail]
        [%move-folder from=trail to=trail]
        [%add-node =trail u=cord t=cord d=cord e=cord s=cord k=cord]
        [%rem-node =trail =id]
        [%edit-node =trail =id tut=(unit @t) dus=(unit @t)]
        [%move-node from=trail =id to=trail]
    ==
  --
:: reactions from single source of truth (space host)
::
++  reaction
  =<  reaction
  |%
  +$  reaction
    $%  [%space space-reaction]
        [%trove trove-reaction]
    ==
  +$  space-reaction
    $%  [%watchlist p=(list tope)] :: all troves we can read
        [%banned =banned]
    ==
  +$  trove-reaction
    $%  [%initial trove-data]
        $<  %add-folder
        $<  %add-node
          trove-action:action
        [%add-folder =trail =tract]
        [%add-node =trail =id =node]
    ==
  --
:: ui updates
::
++  update
  $%  [%initial hoard=(map space [=banned =troves])]
      $:  %space  =space
          $%  $<(%add-trove space-action:action)
              [%add-trove =tope trove-data]
              [%add-troves =banned =troves]
              [%rem-troves ~]
      ==  ==
      $:  %trove  [=space =tope]
          $%  $<  %add-folder
              $<  %add-node
                trove-action:action
              [%add-folder =trail =tract]
              [%add-node =trail =id =node]
      ==  ==
  ==
:: peeks
::
++  view
  $%  [%hoard hoard=(map space [=banned =troves])]
      [%troves =troves]
      [%trove =trove]
  ==
--
