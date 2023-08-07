|%
::  basic types
::
+$  address  @t
+$  network  ?(%bitcoin %btctestnet %ethereum)
+$  transaction
  $:  hash=@t
      =network
      type=?(%sent %received)
      initiated-at=@t
      completed-at=(unit @t)
      our-address=@t
      their-patp=(unit @p)
      their-address=@t
      =status
      failure-reason=(unit @t)
      notes=@t
  ==
+$  help-transaction
  $:  hash=@t
      =network
      type=?(%sent %received)
      initiated-at=@t
      completed-at=(unit @t)
      our-address=@t
      their-patp=(unit @t)
      their-address=@t
      =status
      failure-reason=(unit @t)
      notes=@t
  ==
+$  status  ?(%pending %failed %succeeded)
+$  eth-type  ?(%erc20 %erc721 %eth)
+$  wallet
  $:  =address
      path=@t
      nickname=@t
      transactions=(map net=@t (map hash=@t transaction))
      token-txns=(map net=@t (map @t (map hash=@t transaction)))
  ==
+$  mode  ?(%on-demand %default)
+$  pending-tx  [txh=(unit @ux) from=@ux to=@ux amount=@ud]
+$  txn  [block=@ud txh=@ux log-index=@ud from=@ux to=@ux amount=@ud]
+$  txn-log  (list txn)
+$  contract-type  ?(%erc20 %erc721)
+$  sharing
  $:  who=?(%nobody %friends %anybody)
      wallet-creation=mode
  ==

::  State 0 - wallet as @u instead of @t
::
+$  address-0  @u
+$  wallet-0
  $:  address=address-0
      path=@t
      nickname=@t
      transactions=(map net=@t (map hash=@t transaction))
      token-txns=(map net=@t (map @t (map hash=@t transaction)))
  ==
+$  wallets-0  (map =network (map @ud wallet-0))
::
::  poke actions
::
+$  action
  $%  [%initialize ~]
      [%set-xpub =network xpub=@t]
      [%set-network-settings =network =mode who=?(%nobody %friends %anybody) blocked=(set who=@p) share-index=@ud =sharing]
      [%set-passcode-hash hash=@t]
      [%set-wallet-creation-mode =network =mode]
      [%set-sharing-mode =network who=?(%nobody %friends %anybody)]
      [%set-sharing-permissions type=%block who=@p]
      [%set-default-index =network index=@ud]
      [%set-wallet-nickname =network index=@ud nickname=@t]
      [%create-wallet sndr=ship =network nickname=@t]
      [%request-address =network from=@p]
      [%receive-address =network address=(unit address)]
      [%set-transaction =network net=@t wallet=@ud contract=(unit @t) hash=@ =transaction]
      [%save-transaction-notes =network net=@t wallet=@ud contract=(unit @t) hash=@t notes=@t]
  ==
::  subscription updates
::
+$  update
  $%  [%eth-xpub xpub=(unit @t)]
      [%address =ship =network address=(unit address)]
      [%transaction =network net=@t wallet=@ud contract=(unit @t) hash=@t transaction]
::      [%history transactions]
      [%wallet =network @t =wallet]
      [%wallets wallets]
      [%settings settings]
      [%passcode passcode-hash=@t]
  ==
::  stores
::
+$  wallets  (map =network (map @ud wallet))
+$  settings
  $:  passcode-hash=@t
      networks=(map network [xpub=(unit @t) default-index=@ud =sharing])
      blocked=(set @p)
  ==
--
