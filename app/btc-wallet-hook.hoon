::  btc-wallet-hook.hoon
::
::  Subscribes to:
::    btc-provider:
::      - connection status
::      - RPC call results/errors
::
::    btc-wallet-store
::      - requests for address info
::      - updates to existing address info
::
::  Sends updates to:
::    none
::
/-  *btc, *btc-wallet-hook, bws=btc-wallet-store, bp=btc-provider
/+  shoe, dbug, default-agent, bwsl=btc-wallet-store
|%
+$  versioned-state
    $%  state-0
    ==
::  provdider: maybe ship if provider is set
::
+$  state-0
  $:  %0
      provider=(unit [host=ship connected=?])
      pend=back
      fail=back
  ==
::
+$  card  card:shoe
+$  command
  $?  %add-xpub
  ==
::
--
=|  state-0
=*  state  -
%-  agent:dbug
^-  agent:gall
%-  (agent:shoe command)
^-  (shoe:shoe command)
=<
|_  =bowl:gall
+*  this      .
    des   ~(. (default:shoe this command) bowl)
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  command-parser  command-parser:des
++  tab-list  tab-list:des
++  can-connect  can-connect:des
++  on-command  on-command:des
++  on-connect  on-connect:des
++  on-disconnect  on-disconnect:des
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%btc-wallet-hook initialized'
  :_  this
  :~  [%pass /r/[(scot %da now.bowl)] %agent [our.bowl %btc-wallet-store] %watch /requests]
      [%pass /u/[(scot %da now.bowl)] %agent [our.bowl %btc-wallet-store] %watch /updates]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%btc-wallet-hook recompiled'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
  ?+  mark  (on-poke:def mark vase)
      %btc-wallet-hook-action
    (handle-action:hc !<(action vase))
  ==
  [cards this]
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
::  TODO: write up how we can get on-agent %fact (success) or on-arvo Behn timeout
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %watch-ack
    ?+  -.wire  `this
        %set-provider
      ?~  provider  `this
      ?^  p.sign  `this(provider ~)
      ?.  =(src.bowl host.u.provider)  `this
      :_  this(provider `[host.u.provider %.y])
      %+  weld  (retry:hc pend)  (retry:hc fail)
    ==
      ::
      %fact
    =^  cards  state
      ?+  p.cage.sign  `state
          %btc-provider-update
        `state
          %btc-wallet-store-request
        (handle-request:hc !<(request:bws q.cage.sign))
      ==
    [cards this]
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|_  =bowl:gall
++  handle-command
  |=  comm=command
  ^-  (quip card _state)
  ~&  >  comm
  `state
::  set-provider algo: 
::    - add provider, connected false
::    - on negative ack: delete the provider 
::
++  handle-action
  |=  act=action
  ^-  (quip card _state)
  ?-  -.act
      %set-provider
    =*  sub-card
      [%pass /set-prov %agent [provider.act %btc-provider] %watch /clients]
    :_  state(provider [~ provider.act %.n])
    ?~  provider  ~[sub-card]
    :~  [%pass /leave-prov %agent [host.u.provider %btc-provider] %leave ~]
        sub-card
    ==
    ::
      %force-retry
    :_  state
    %+  weld  (retry pend)  (retry fail)
  ==
++  handle-request
  |=  req=request:bws
  ^-  (quip card _state)
  ?-  -.req
      %scan-address
    =/  ri=req-id:bp  (mk-req-id (hash-xpub:bwsl +>.req))
    :_  state(pend (~(put by pend) ri req))
    ?~  provider
      ~&  >  "provider not set"
      ~
    ~[(get-address-info ri host.u.provider a.req)]
  ==
::
++  retry
  |=  =back
  ^-  (list card)
  ?~  provider  ~|("provider not set" !!)
  %+  turn  ~(tap by back)
  |=  [ri=req-id:bp req=request:bws]
  (get-address-info ri host.u.provider a.req)
::
++  get-address-info
  |=  [ri=req-id:bp host=ship a=address]  ^-  card
  :*  %pass  /[(scot %da now.bowl)]  %agent  [host %btc-provider]
      %poke  %btc-provider-action  !>([ri %address-info a])
  ==
++  mk-req-id
  |=  hash=@ux  ^-  req-id:bp
  (scot %ux hash)
--
