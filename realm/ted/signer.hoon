::  thread boilerplate and helper libraries
/-  spider
/+  *strandio
=,  strand=strand:spider
=,  card=card:agent:gall
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::  
;<  our=@p   bind:m  get-our
;<  bol=bowl:rand      bind:m  get-bowl
?>  =(our src.bol)
=/  signcord=@t  (need ;;((unit @t) +.arg))
=/  c1=card  [%pass /sub-privkeys %arvo %j %private-keys ~]
;<  ~  bind:m  (send-raw-card c1)
;<  res=[=wire =sign-arvo]  bind:m  take-sign-arvo
?>  ?=([%sub-privkeys ~] wire.res)
?>  ?=([%jael %private-keys *] sign-arvo.res)
=/  keykey=@u  +>+<+.sign-arvo.res
=/  signedpayload=@ux  (sigh:as:(nol:nu:crub:crypto keykey) signcord)
(pure:m !>([original=signcord signed=signedpayload]))
