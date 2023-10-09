/+  eth=ethereum
|%
++  num-to-hex  num-to-hex:eth
::
++  split-sig
  |=  sig=@
  ^-  [v=@ r=@ s=@]
  |^
    =^  v  sig  (take 3)
    =^  s  sig  (take 3 32)
    =^  r  sig  (take 3 32)
    =?  v  (gte v 27)  (sub v 27)
    [v r s]
  ::
  ++  take
    |=  =bite
    [(end bite sig) (rsh bite sig)]
  --
::
++  recover-pub-key
  |=  [msg=@t sig=@t addr=@t]  ^-  @ux
  =/  hashed-msg=@ux
    %-  keccak-256:keccak:crypto
    %-  as-octs:mimes:html
    %-  crip
    ^-  tape
    %+  weld
    (trip '\19Ethereum Signed Message:\0a')
    %+  weld
    %-  trip
    (en:json:html (numb:enjs:format (lent (trip msg))))
    (trip msg)
    ::export function hashMessage(message: Bytes | string): string {
    ::    if (typeof(message) === "string") { message = toUtf8Bytes(message); }
    ::    return keccak256(concat([
    ::        toUtf8Bytes(messagePrefix),
    ::        toUtf8Bytes(String(message.length)),
    ::        message]));
  =/  ux-sig=@ux  (hex-to-num:eth sig)
  =/  vrs         (split-sig ux-sig)
  ::SigningKey.recoverPublicKey(digest, signature)
  %-  serialize-point:secp256k1:secp:crypto
  (ecdsa-raw-recover:secp256k1:secp:crypto hashed-msg vrs)
::
++  verify-message
  |=  [msg=@t sig=@t addr=@t]  ^-  ?
  =/  pubkey=@ux  (recover-pub-key msg sig addr)
  :: if the passed in address equals the address for the the recovered public key of the sig, then it is verified
  =((hex-to-num:eth addr) (address-from-pub:key:eth pubkey))
::
++  ether-hash-to-ux
  |=  str=@t
  ^-  @ux
  =/  ta=tape  (cass (slag 2 (trip str)))
  =/  reordered=tape  ""
  =/  i=@ud  0
  =/  ready=tape
    |-
      ?:  =(0 (lent ta))
        +.reordered
      =/  b1=@t  (snag 0 ta)
      =/  b2=@t  (snag 1 ta)
      ?:  =(1 (mod i 2))
        $(reordered ['.' b1 b2 reordered], ta +.+.ta, i +(i))
      $(reordered [b1 b2 reordered], ta +.+.ta, i +(i))
  |- :: handle the urbit bullshit %ux parsing rules
    ?:  =('0' (snag 0 ready))
      $(ready +.ready)
    ?:  =('.' (snag 0 ready))
      $(ready +.ready)
    `@ux`(slav %ux (crip ['0' 'x' ready]))
::
--
