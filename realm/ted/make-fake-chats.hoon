:: -realm!make-fake-chats 10
/-  spider, chat-db, realm-chat
/+  *strandio

|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit @ud)  !<((unit @ud) arg)
?~  axn  (strand-fail %no-arg ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  =wire  /chat-vent/(scot %da now)
;<  ~   bind:m  (watch wire [our %chat-db] wire)
;<  ~   bind:m  (poke [our %realm-chat] chat-action+!>([%vented-create-chat now ~ %chat ~[~bud ~dev] %host *@dr %.y]))
;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
?~  cage  (pure:m !>([%ack ~]))
=/  ven=chat-vent:chat-db    !<(chat-vent:chat-db q.u.cage)
=/  pth=path
?+  -.ven  !!
  %path  path.path-row.ven
  %path-and-count  path.path-row.ven
==
;<  ~   bind:m  (poke [our %realm-chat] chat-action+!>([%edit-chat pth ~ %.y %host *@dr]))
=/  i=@ud  1
|-
  ?:  =(u.axn i)
    (pure:m q.u.cage)
  =/  frag=minimal-fragment:chat-db
  ?:  =(0 (mod i 2))
    [[%bold (scot %ud i)] ~ ~]
  [[%plain (scot %ud i)] ~ ~]
  ;<  ~   bind:m  (poke [our %realm-chat] chat-action+!>(`action:realm-chat`[%vented-send-message (add now i) pth [frag ~] *@dr]))
  $(i +(i))
::
++  take-fact-or-kick
  |=  =wire
  =/  m  (strand ,(unit cage))
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
    ::
      [~ %agent * %fact *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done (some cage.sign.u.in.tin)]
    ::
      [~ %agent * %kick *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done ~]
  ==
--
