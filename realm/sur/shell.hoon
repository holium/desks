/-  *spaces, *apps
::
::  %shell: window manager state and preferences
::      
::    This agent should store window manager metadata to persist 
::    window position and status as well as any session information
::
|%
::
::  shell-context: a context for the window-manager
::  
::  Examples
::    Our shell:
::  [/spaces/~labruc-dillyx-lomder-librun]
::    A spaces shell:
::  [/spaces/~hatryx-lastud/other-life]
::
+$  shell-context  [=path:space]  ::  todo add room id to the context 
::
+$  window-id  @tas               ::  usually refers to a desk
+$  dimensions                    ::  should be normalized by client
  $:  x=@s
      y=@s
      width=@u
      height=@u
  ==
::
::
::
+$  window
  $:  id=window-id
      title=@t
      z-index=@u
      type=?(%urbit %web %native %dialog)
      =dimensions
  ==
::
::
::
+$  window-manager
  $:  active-window=window-id
      windows=(map window-id window)
  ==
::
+$  shells  (map shell-context window-manager)
::
:: actions
+$  action
  $%  [%open-window =shell-context =window]                             ::  opens a new window
      [%update-window-z =shell-context =window-id z-index=@u]           ::  updates window z-index
      [%update-window-dimensions =shell-context =window-id =dimensions] ::  should only be updated when dragging stops
      [%close-window =shell-context =window-id]
      [%add-shell =shell-context]                                       ::  registers a new shell context
      [%remove-shell =shell-context]                                    ::  removes a shell context
  ==

:: updates
+$  update
  $%  [%window-opened =shell-context =window]       ::  sends updates to watchers of context
      [%window-closed =shell-context =window]
      [%window-updated =shell-context =window]
  ==
