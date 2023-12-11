|_  in=[domain=@t purpose=@t payload=?(@t ~)]
++  grad  %noun
++  grow
  |%
  ++  noun  in
  ++  json  (pairs:enjs:format ~[domain+s+domain.in purpose+s+purpose.in [%payload ?~(payload.in ~ s+payload.in)]])
  --
++  grab
  |%
  ++  noun  [@t @t ?(@t ~)]
  ++  json
    |=  jon=^json
    ^-  [domain=@t purpose=@t payload=?(@t ~)]
    ?>  ?=([%o *] jon)
    =/  upay    (~(get by p.jon) 'payload')
    =/  pay=?(@t ~)
      ?~  upay  ~
      ?~  u.upay  ~
      (so:dejs:format u.upay)
    =/  firsttwo=[d=@t p=@t]
    %-
      %-  ot:dejs:format
      :~  domain+so:dejs:format
          purpose+so:dejs:format
      ==
    jon
    [d.firsttwo p.firsttwo pay]
  --
--

