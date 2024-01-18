::  thread boilerplate and helper libraries
/-  spider
/+  *strandio
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m

::  pull in and cast the three cord arguments (payload can also be null)
=/  theargs=[@t @t ?(@t ~)]  (need !<((unit [@t @t ?(@t ~)]) arg))
=/  protocolanddomain=tape  (trip -.theargs)
=/  purpose=tape  (trip +<.theargs)
=/  payload=?(tape ~)  ?~  +>.theargs  ~  (trip +>.theargs)

::  1st action: retrieve the current bowl and verify that
::  this thread was started by ourselves
;<  mybowl=bowl:spider  bind:m  get-bowl
?>  =(our.mybowl src.mybowl)

::  define a http request body based on if a payload is included
=/  thebody=@t  %-  crip  ;:  weld  
  "\7b\"ship\":\"{(scow %p our.mybowl)}\",\"purpose\":\""  purpose
?~  payload  "\",\"payload\":null}"
;:  weld  "\",\"payload\":"  payload  "}"  ==
==

~&  protocolanddomain
~&  'Submitting the following request body:'
~&  thebody

::  define a target URL for the prepare-order request
=/  url1=@t  (crip (weld protocolanddomain "/prepare-request"))

::  use the request body and URL to make a request...
=/  myrequest=request:http  :^  
        %'POST' 
      url1 
    ~[[key='Content-Type' value='application/json']] 
  (some (as-octs:mimes:html thebody))

::  ...as a task for the %iris vane...
=/  mytask=task:iris  [%request myrequest *outbound-config:iris]

::  ...whose I/O to this thread will be handled by %arvo 
=/  mycard=card:agent:gall  [%pass /http-req %arvo %i mytask]

::  2nd action: start the I/O
;<  ~  bind:m  (send-raw-card mycard)

::  3rd action: wait to see what sort of response comes back
;<  res=(pair wire sign-arvo)  bind:m  take-sign-arvo

::  proceed if correct type of response...
?.  ?=([%iris %http-response %finished *] q.res)
  (strand-fail:strand %bad-sign ~)
  
::  ...with actual content...
?~  full-file.client-response.q.res
  (strand-fail:strand %no-body ~)
  
::  ...and a 200 status code
?.  =(status-code.response-header.client-response.q.res 200)
  =/  theerror=@t  `@t`q.data.u.full-file.client-response.q.res
  ~&  'Failure response received'
  (pure:m !>(theerror))

::  check if response is json  
=/  possiblejson=(unit json)  (de:json:html q.data.u.full-file.client-response.q.res)
?~  possiblejson  (strand-fail:strand %non-json-response ~)

::  pull the nonce from the json response ({"nonce":<our value>})
=/  thenonce=?(%missing @t)  %-  
  (ou:dejs:format ~[nonce+(uf:dejs:format [%missing so:dejs:format])])  
+:possiblejson
  
::  check to see if nonce was missing
?:  =(thenonce %missing)  (strand-fail:strand %no-nonce ~)

::  prepare a random thread identifier for calling the signing thread as a child thread
=/  tid  `@ta`(cat 3 'strand_' (scot %uv (sham %signer eny.mybowl)))

::  4th action: attach the I/O of the child thread to the current thread
;<  ~  bind:m  (watch-our /awaiting/[tid] %spider /thread-result/[tid])

::  5th action: poke the child thread with the nonce returned from the first request
;<  ~  bind:m  %-  poke-our  :+  %spider
    %spider-start
  !>([`tid.mybowl `tid byk.mybowl(r da+now.mybowl) %signer !>((some thenonce))])

::  6th action: register a handler for the fact that will be returned by child thread
;<  =cage  bind:m  (take-fact /awaiting/[tid])      

::  7th action: register a handler to unsubscribe to child thread responses when done                
;<  ~  bind:m  (take-kick /awaiting/[tid])

::  test a result and proceed if %thread-done
?.  ?|(=(%thread-done p.cage) =(%thread-fail p.cage))  
  ~|([%strange-thread-result p.cage %signer tid] !!)
?:  =(%thread-fail p.cage)  (strand-fail:strand %failed-thread ~)
  
~&  'Success response received'
  
::  set up the nonce and signed_nonce values (cord and hex)
=/  left=@t  ?@  +<.q.cage  `@t`+<.q.cage  !!
=/  right=@ux  ?@  +>.q.cage  `@ux`+>.q.cage  !! 
   
::  second request to execute-signed-order endpoint is handled just like the first
=/  thebody2=@t  %-  crip
"\7b\"nonce\":\"{(trip left)}\",\"signed_nonce\":\"{(scow %ux right)}\"}"
~&  'Submitting the follow-up request body:'
~&  thebody2
=/  url2=@t  (crip (weld protocolanddomain "/execute-signed-request"))
=/  myrequest2=request:http  :^ 
        %'POST' 
      url2 
    ~[[key='Content-Type' value='application/json']] 
  (some (as-octs:mimes:html thebody2))
=/  mytask2=task:iris  [%request myrequest2 *outbound-config:iris]
=/  mycard2=card:agent:gall  [%pass /http-req %arvo %i mytask2]
;<  ~  bind:m  (send-raw-card mycard2)
;<  res2=(pair wire sign-arvo)  bind:m  take-sign-arvo
?.  ?=([%iris %http-response %finished *] q.res2)
  (strand-fail:strand %bad-sign ~)
?~  full-file.client-response.q.res2
  (strand-fail:strand %no-body ~)
=/  finalststus=@tas  ?:  =(status-code.response-header.client-response.q.res2 200)
    %success
  %failure
=/  finalresponse=@t  `@t`q.data.u.full-file.client-response.q.res2

::  return the final response
(pure:m !>([finalststus finalresponse]))
