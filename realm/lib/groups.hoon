/-  store=groups, member-store=membership, *resource, mtd=metadata-store, g=new-groups
=<  [store .]
=,  store
|%
::  TODO break this out into seperate gates
++  our-groups
  |=  [our=ship now=@da]
  ^-  (list group-space)
  =/  has-groups  .^(? %gu /(scot %p our)/groups/(scot %da now)/$)
  ?.  has-groups  *(list group-space)
  =/  groups  .^(groups:g %gx /(scot %p our)/groups/(scot %da now)/groups/groups)
  ::  find ours
  =/  hosted
    ^-  (list [f=flag:g g=group-ui:g])
    %+  skim  ~(tap by groups)
      |=  [f=flag:g g=group-ui:g]
      =(our -.f)
  ::  get metadata for each
  %+  turn  hosted
    |=  [=flag:g =group-ui:g]
    ^-  group-space
    =/  access
      ?:  =(-.cordon.group-ui %open)
        %public
      %private
    =/  metadata  meta.group-ui
    ::  Get group data
    =/  member-count=@u
      (lent ~(tap by fleet.group-ui))
    ::  Get metadata
    =/  title=@t     title.metadata
    =/  image=@t     image.metadata
    =/  first-char   (trim 1 (trip image))
    ?:  =(p.first-char "#")
      [our +.flag title access '' image member-count]
    [our +.flag title access image '' member-count]
  ::
++  skim-group-dms
  |=  [resource=[entity=ship name=@tas]]
  =/  name      (cord name.resource)
  =/  name-da   (slaw %da name)
  ?~  name-da   %.y   %.n
::
++  get-group
  |=  [rid=[entity=ship name=@tas] our=ship now=@da]
  ^-  group-ui:g
  =/  groups  .^(groups:g %gx /(scot %p our)/groups/(scot %da now)/groups/groups)
  (~(got by groups) rid)
::
::  JSON
::
++  enjs
  =,  enjs:format
  |%
  ++  view :: encodes for on-peek
    |=  vi=view:store
    ^-  json
    %-  pairs
    :_  ~
    ^-  [cord json]
    :-  -.vi
    ?-  -.vi
      ::
        %group
      (group:encode group.vi)
      ::
        %groups
      (groups:encode groups.vi)
      ::
        %members
      (members:encode members.vi)
    ==
  --
::
++  encode
  =,  enjs:format
  |%
  ++  groups
    |=  grps=(list group-space)
    ^-  json
    %-  pairs
    %+  turn  grps
      |=  grp=group-space
      =/  path  (spat /(scot %p creator.grp)/(scot %tas name.grp))
      [path (group grp)]
  ::
  ++  group
    |=  grp=group-space
    ^-  json
    %-  pairs
    :~  ['creator' s+(scot %p creator.grp)]
        ['path' s+(spat /(scot %p creator.grp)/(scot %tas name.grp))]
        ['name' s+title.grp]
        ['access' s+access.grp]
        ['picture' s+picture.grp]
        ['color' s+color.grp]
        ['memberCount' n+(scot %u member-count.grp)]
    ==
  ::
  ++  members
    |=  fl=fleet:g
    %-  pairs
    %+  turn  ~(tap by fl)
    |=  [her=@p v=vessel:fleet:g]
    [(scot %p her) (member-vessel v)]
  ++  member-vessel
    |=  v=vessel:fleet:g
    %-  pairs
    =/  roles  (turn ~(tap in sects.v) (lead %s))
    =/  status
      ?~  roles
        'invited'
      'joined'
    =?  roles  =(~ roles)
      [s+%member]~
    :~  :-  'primaryRole'
            ?:  (~(has in (silt roles)) s+'admin')
              s+'admin'
            s+'member'
        ['status' s+status]
        ['alias' s+'']
        [roles/a/[roles]]
    ==
  --
--