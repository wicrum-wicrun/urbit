/-  dao=uqbar-dao
/-  tx
/-  meta=dao-metadata
/-  chain=dao-chain
/+  default-agent, dbug, verb
/+  resource, agentio
/+  graphlib=graph, graph-store
/+  pull=inv-pull, push=inv-push
/+  pull-hook
|%
+$  card  card:agent:gall
+$  state-zero
  $:  %0
      daos=(map id:dao dao)
      sub=(map id:dao status:pull-hook)
      pub=(set id:dao)
  ==
--
=|  state-zero
=*  state  -
=<
  %-  agent:dbug
  %+  verb  &
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def  ~(. (default-agent this %|) bowl)
      cor  ~(. +> [bowl ~])
  ++  on-init  
    =^(cards state abet:init:cor [cards this])
  ++  on-save  !>(state)
  ++  on-load
    |=  =vase
    =+  !<(old=state-zero vase)
    `this(state old)
  ++  on-poke
    |=  [=mark =vase]
    =^  cards  state
      abet:(poke:cor mark vase)
    [cards this]
  ::
  ++  on-peek  peek:cor
  ++  on-watch
    |=  =path
    =^  cards  state
      abet:(watch:cor path)
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    =^  cards  state
      abet:(agent:cor wire sign)
    [cards this]
  ::
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
  ++  on-leave  on-leave:def
  --
|_  [=bowl:gall cards=(list card)]
++  abet  [(flop cards) state]
++  cor    .
++  emit  |=(=card cor(cards [card cards]))
++  io    ~(. agentio bowl)
++  pass  pass:io
++  emil  |=(caz=(list card) cor(cards (welp (flop caz) cards)))
++  watch-graph
  (~(watch-our pass /graphs) %graph-store /updates)
++  init  (emit watch-graph)
++  poke
  |=  [=mark =vase]
  ~|  poke/mark
  ?+  mark   ~|(%no-mark !!)
  ::  TODO: remove, debugging purposes
    %noun          cor(state *state-zero)
  ::
    %tx            (handle-tx !<(tx vase))
    %chain-update  (handle-chain !<(update:chain vase))
  ::
      %dao-update
    =+  !<(=update:dao vase)
    abet:(~(diff tao p.update) q.update)
  ::
      %graph-update-3
    =/  res  (~(resource-for-update graphlib bowl) vase)
    |- 
    ?~  res  cor
    =*  rid  i.res
    =/  d=(unit id:dao)  (dao-for-graph rid)
    ?~  d  $(res t.res)
    =/  t  ~(. tao u.d)
    =.  cor  abet:abet:(proxy:(abed:gra:t rid) vase)
    $(res t.res)
  ::
      %graph-create
    =+  !<(=create:graph:dao vase)
    abet:(~(create-graph tao p.create) [q r]:create)
  ==
++  watch
  |=  =path
  ^+  cor
  ~|  watch/path
  ?+  path  ~|(%bad-path !!)
    [%daos @ *]  abet:(watch:(from-wire:tao path) t.t.path)
  ==
::
++  agent
  |=  [=wire =sign:agent:gall]
  ^+  cor
  ~|  agent/-.sign^wire
  ?+  wire  ~|(%no-wire !!)
    [%daos @ *]  abet:(agent:(from-wire:tao wire) t.t.wire sign)
  ::
      [%graphs ~]
    ?+  -.sign  !!
      %kick  (emit watch-graph)
    ::
        %watch-ack
      ?~  p.sign  cor
      %-  (slog leaf/"Failed subscribe to graph-store" u.p.sign)
      cor
    ::
        %fact
      ?.  =(%graph-update-3 p.cage.sign)  cor
      =+  !<(=update:graph-store q.cage.sign)
      =/  resources=(list resource)
        (~(resource-for-update graphlib bowl) q.cage.sign)
      |-
      ?~  resources  cor
      ?.  =(entity.i.resources our.bowl)
        $(resources t.resources)
      ?~  id=(dao-for-graph i.resources)
        $(resources t.resources)
      =/  d  (~(got by daos) u.id)
      =/  [caz=(list card) new=dao]
        `d
      =.  daos  (~(put by daos) u.id new)
      =.  cor  (emil caz)
      $(resources t.resources)
    ==
  ::
  ::  miscellaneous acks
      ~
    ?.  ?=(%poke-ack -.sign)  cor
    ?~  p.sign  cor
    %-  (slog leaf/"Failed poke to {<src.bowl>}" u.p.sign)
    cor

  ==
++  peek
  |=  =path
  ^-  (unit (unit cage))
  [~ ~]
::
++  handle-chain
  |=  =update:chain
  ^+  cor
  ?:  (~(has by daos) p.update)
    abet:(~(bind tao p.update) q.update)
  =/  daoists
    %-  ~(gas by *(map ship daoist:dao))
    %+  turn  ~(tap by members.q.update)
    |=  [s=ship =hash:tx]
    ^-  [ship daoist:dao]
    :-  s
    :: TODO: verify attestation!
    [s now.bowl hash ~]
  =/  d=dao   
    =,  q.update
    [host daoists admins ~ ~]
  =.  daos  (~(put by daos) p.update d)
  ?:  =(host.q.update our.bowl)  
    cor(pub (~(put in pub) p.update))
  abet:~(subscribe tao p.update)
::
::    TODO: move initialisation logic elsewhere, so that you mint the
::    NFT, then poke this agent to setup an dao by scrying out data.
::    Blocked on a working chain implementation

::
++  handle-tx
  |=  =tx
  ^+  cor
  ?+  -.tx  cor  ::   TODO: maybe crash
                 ::   but if subscription, will break
  ::  setup a dao for each nft minted
  ::  TODO: 
      %mint  
    =?  daos  !(~(has by daos) minter.tx)  
      =/  d=dao
        %*  .  *dao
          host  (acc-id-to-ship from.tx)
        ==
      (~(put by daos) minter.tx d)
    abet:(~(mint tao minter.tx) to.tx)
  ::
      %send
    =/  assets  ~(tap by assets.tx)
    |- 
    ?~  assets  cor
    =/  [=account-id:^tx =asset:^tx]  i.assets
    =.  cor   abet:(~(send tao account-id) asset [from to]:tx)
    $(assets t.assets)
  ::
  ==
::
++  tao
  |_  =id:dao
  ++  abet  cor
  ++  area
    `wire`/daos/(scot %ux id)
  ++  from-wire
    |=  =wire
    ?>  ?=([%daos @ *] wire)
    =/  i  (slav %ux i.t.wire)
    tao(id i)
  ::
  ++  tao  .
  ++  emit  |=(=card tao(cor (emit:cor card)))
  ++  pass
    |=  [=wire =dock =task:agent:gall]
    (emit %pass (welp area wire) %agent dock task)
  ++  edit
    |=  f=$-(dao dao)
    tao(daos (~(jab by daos) id f))
  ++  te  (~(got by daos) id)
  ::  TODO: finalise
  ++  bind
    |=  =chain:chain
    ^+  tao
    |^
    =.  tao  host
    =.  tao  members
    admin
    ++  host
      ~|  %host-swapping-unimplemented
      ?>  =(host.chain host:te)
      tao
    ++  members
      tao
    ++  admin
      tao
    --
  ++  create-graph
    |=  [rid=resource =datum:meta]
    ^+  tao
    =/  =state:graph:dao
      [[%pub ~] datum]
    =.  tao
      %-  edit
      |=  dao
      +<(graphs (~(put by graphs) rid state))
    =/  =mark
      ?-  module.datum
        %chat  %graph-validator-chat
        %book  %graph-validator-publish
        %link  %graph-validator-link
      ==
    =/  =update:graph-store
      [now.bowl %add-graph rid *graph:graph-store `mark %.y]
    ::  TODO: handle failure??
    %^  pass  ~  [our.bowl %graph-store]
    [%poke graph-update-3+!>(update)]
  ++  subscribe
    =/  =path  (welp area /dao)
    %^  pass  path  [host:te dap.bowl]
    [%watch path]
    
  ::
  ++  watch
    |=  =path
    ^+  tao
    ?+  path  ~|(%bad-path !!)
    ::
        [%graphs @ @ *]
      =/  ship  (slav %p i.t.path)
      =/  rid=resource  [ship i.t.t.path]
      ::  TODO: respond to graph requests
      tao
    ::
        [%dao ~]



    ==
  :: TODO: work
  ++  revoke
    |=  =ship
    =/  graphs  ~(tap in ~(key by graphs:te))
    |-
    ?~  graphs  tao
    ?.  =(our.bowl entity.i.graphs)  $(graphs t.graphs)
    =/  [caz=(list card) new=dao]
      `te
    =.  cor  (emil caz)
    =.  daos  (~(put by daos) id new)
    $(graphs t.graphs)
  ::
  ++  enlighten
    |=  [=ship =hash:tx]
    =/  light=daoist:dao  [ship now.bowl hash ~]
    %-  edit 
    |=  dao
    +<(daoists (~(put by daoists) ship light))
  ::
  ++  send
    |=  [=asset:tx from=account-id:tx to=account-id:tx]
    ^+  tao
    ?.  ?=(%nft -.asset)  tao
    =/  lost=ship  (acc-id-to-ship from)
    =/  gain=ship  (acc-id-to-ship to)
    =.  tao  (enlighten gain hash.asset)
    =.  tao  
      %-  edit 
      |=  dao
      +<(daoists (~(del by daoists) lost))
    (revoke lost)
  ::
  ++  mint
    |=  to=(list (pair account-id:tx minting-asset:tx))
    ^+  tao
    ?~  to  tao
    ?.  ?=(%nft -.q.i.to)  $(to t.to)
    =/  =ship  `@p`p.i.to  :: TODO: account -> ship lookup
    $(to t.to, tao (enlighten ship hash.q.i.to))
  ::
  ++  diff
    |=  =diff:dao
    |^
    ?-  -.diff
      %create  create
      %delete  delete
      %daoist  abet:(~(diff taoist p.p.diff) q.p.diff)
    ::
        %initial
      %-  edit
      |=(d=dao p.diff)
    ::
        %graphs  
      =*  update  p.diff
      =/  rid=resource  p.p.diff
      =/  [caz=(list card) new=dao]
        `te
      =.  daos  (~(put by daos) id new)
      =.  cor  (emil caz)
      tao
    ==
    ++  create
      =|  =dao
      =.  host.dao  our.bowl
      =.  daos  (~(put by daos) id dao)
      tao
    ++  delete
      =.  daos  (~(del by daos) id)
      tao
    --
  ++  taoist
    |_  =ship
    ++  abet  tao
    ++  taoist  .
    ++  diff
      |=  diff=daoist-diff:dao
      ^+  taoist
      ?-  -.diff
        %join   join
        %leave  leave
        %deputise  (deputise +.diff)
        %undeputise  (undeputise +.diff)
      ==
    ++  edit
      |=  f=$-(daoist:dao daoist:dao)
      =.  tao
        %-  edit:tao
        |=  d=dao
        d(daoists (~(jab by daoists.d) ship f))
      taoist
    ::
    ++  leave
      =.  tao
        %-  edit:tao
        |=  d=dao
        d(daoists (~(del by daoists.d) ship))
      taoist
    ::
    ++  deputise
      |=  b=badge:dao
      %-  edit
      |=  d=daoist:dao
      d(roles (~(put in roles.d) b))
    ::
    ++   undeputise
      |=  b=badge:dao
      %-  edit
      |=  d=daoist:dao
      d(roles (~(del in roles.d) b))
    ::
    ++  join
      ::|=  =tx:dao
      =/   new=daoist:dao 
        %*  .  *daoist:dao
          ship    ship
          joined  now.bowl
          attest  *hash:tx
        ==
      =.  tao
        %-  edit:tao
        |=  d=dao
        d(daoists (~(put by daoists.d) ship new))
      taoist
    --
  ::
  ++  agent
    |=  [=wire =sign:agent:gall]
    ?+  wire  !!
        ~
      ?.  ?=(%poke-ack -.sign)  tao
      %.  tao
      ?~  p.sign  same
      (slog leaf/"Failed poke" u.p.sign)
    ::
        [%graphs @ @ *]
      =/  ship  (slav %p i.t.wire)
      =/  rid=resource  [ship i.t.t.wire]
      =/  [caz=(list card) new=dao]
        `te
      =.  daos  (~(put by daos) id new)
      =.  cor  (emil caz)
      tao
    ==
  ::
  ++  net-graphs-pull-handler
    |_  rid=resource
    ++  resource-for-update
      |=  =vase
      =/  res  (silt (~(resource-for-update graphlib bowl) vase))
      (~(has in res) rid)
    ::
    ++  on-pull-kick
      ^-  (unit knot)
      =/  maybe-time  (~(peek-update-log graphlib bowl) rid)
      ?~  maybe-time  `%$
      `(scot %da u.maybe-time)
    ::
    ++  on-pull-nack
      *(list card)
    --
  ++  net-graphs-pull
    %:  pull
      `wire`(snoc area %graphs)
      net-graphs-pull-handler
      %graph-store
      %graph-update
      3  3
    ==
  ++  net-graphs-push-handler
    |_  rid=resource
    ++  resource-for-update
      |=  =vase
      =/  res  (silt (~(resource-for-update graphlib bowl) vase))
      (~(has in res) rid)
    ::
    ++  initial-watch
      |=  resub=knot
      =*  gra  ~(. graphlib bowl)
      =/  time=(unit time)   (slaw %da resub)
      !>  ^-  update:graph-store
      ?~  time  (get-graph:gra rid)
      :-  (fall time *^time)
      :+  %run-updates  rid
      (get-update-log-subset:gra rid u.time)
    --
  ++  net-graphs-push
    %:  push
      `wire`(snoc area %graphs)
      net-graphs-push-handler
      %graph-store
      %graph-update
      3  3
    ==
  ++  gra
    |_  [rid=resource =state:graph:dao]
    ++  gra  .
    ++  lib  ~(. graphlib bowl)
    ++  abed
      |=  r=resource
      gra(rid r, state (~(got by graphs:te) r))
    ::
    ++  abet  
      (edit:tao |=(dao +<(graphs (~(put by graphs) rid state))))
    ++  area  `wire`(snoc ^area %graphs)
    ++  pass
      |=  [=wire =dock =task:agent:gall]
      =.  cor  
        (emit:cor %pass (welp area wire) %agent dock task)
      gra
    ++  mark  (get-mark:lib rid)
    ++  proxy
      |=  =vase
      =+  !<(=update:graph-store vase)
      =/  mar  (fall mark %$)
      |^  
      =/  =dock  [our.bowl %graph-store]
      =.  gra  
        (pass /proxy dock %poke %graph-update-3 vase)
      =/  valid=?  
      ::
        ?+   -.q.update  !!
        ::
            %add-nodes
          ?+  mar  !!
            %graph-validator-chat     (chat-add nodes.q.update)
            %graph-validator-link     (link-add nodes.q.update)
            %graph-validator-post     (post-add nodes.q.update)
            %graph-validator-publish     (publish-add nodes.q.update)
          ==
        ::
            %remove-posts
          ?+  mar  !!
            %graph-validator-chat     (chat-del indices.q.update)
            %graph-validator-link     (link-del indices.q.update)
            %graph-validator-post     (post-del indices.q.update)
            %graph-validator-publish     (publish-del indices.q.update)
          ==
        ==
      ?>  valid
      gra  ::: XX: fix, possibly the ugliest syntax ever committed
      ++  daoist  (~(got by daoists:te) src.bowl)
      +$  nodes   (map index:graph-store node:graph-store)
      +$  indices  (set index:graph-store)
      ++  get-parent
        |=  =index:graph-store
        =/  len  (lent index)
        (got-node:lib rid (scag (dec len) index))
      ++  is-self-child
        |=  =index:graph-store
        =/  parent=node:graph-store  (get-parent index)
        ?>  ?=(%& -.post.parent)
        =(author.p.post.parent src.bowl)
      ::
      ++  is-self
        |=  =index:graph-store
        =/  =node:graph-store  (got-node:lib rid index)
        ?>  ?=(%& -.post.node)
        =(src.bowl author.p.post.node)
      ::
      ++  has-policy
        |=  =policy:meta
        =,  perms.datum.state
        =/  shared=(set badge:dao)
          (~(int in ~(key by juris)) roles:daoist)
        ?|  (~(has in default) policy)
        ::
            %-  ~(any in shared)
            |=  =badge:dao
            =/  =policies:meta  (~(gut by juris) badge ~)
            (~(has in policies) policy)
        ==
      ::
      ++  add
        |=  [=nodes f=$-(post:graph-store ?)]
        %-  ~(all by nodes)
        |=  =node:graph-store
        ?>  ?=(%& -.post.node)
        &((f p.post.node) =(src.bowl author.p.post.node))
      ::
      ++  chat-add
        |=  =nodes
        %+  add  nodes
        |=  =post:graph-store
        ?&  (has-policy %write)
            ?=([@ ~] index.post)
        ==
      ::  TODO: deletes
      ++  chat-del
        |=  =indices
        %-  ~(all in indices)
        |=  =index:graph-store
        =/  remove  (has-policy %remove-posts)
        ?|(remove (is-self index))
      ::
      ++  post-add
        |=  =nodes
        %+  add  nodes
        |=  =post:graph-store
        =/  writer  (has-policy %write)
        ?:  ?=([@ ~] index.post)
          writer
        |(writer (has-policy %comment))
      ::
      ++  post-del
        |=  =indices
        %-  ~(all in indices)
        |=  =index:graph-store
        |((is-self index) (has-policy %remove-posts))
      ::
      ++  link-add
        |=  =nodes
        %+  add  nodes
        |=  =post:graph-store
        =/  writer  (has-policy %write)
        ?+  index.post  %.n
          [@ ~]  writer  :: new link
        ::
        :: new comment
            [@ @ ~]
        |(writer (has-policy %comment))
        :: 
        :: edit comment
            [@ @ @ ~]
        (is-self-child index.post)
      ==
      ::
      ++  link-del
        |=  =indices
        %-  ~(all in indices)
        |=  =index:graph-store
        =/  remove  |((is-self index) (has-policy %remove-posts))
        ?+  index  %.n
          [@ ~]      remove
          [@ @ ~]    remove
          [@ @ @ ~]  remove
        ==
      ::
      ++  publish-add
        |=  =nodes
        %+  add  nodes
        |=  =post:graph-store
        =/  writer  (has-policy %write)
        ?+  index.post  |
            [@ ~]  writer
          ::
          :: new comment
              [@ %2 @ ~]
          |(writer (has-policy %comment))
          :: edit note
              [@ %1 @ ~]
          (is-self-child index.post)
        ==
      ++  publish-del
        |=  =indices
        %-  ~(all in indices)
        |=  =index:graph-store
        =/  remove  |((is-self index) (has-policy %remove-posts))
        ?+  index  %.n
          [@ ~]            remove
          [@ %1 @ @ ~]     remove
          [@ %2 @ ~]       remove
          [@ %2 @ @ ~]     remove
        ==
      --
    --
  --
::  TODO: maybe replace with cached index from graph -> dao ids
++  dao-for-graph
  |=  rid=resource
  ^-  (unit id:dao)
  =/  daos=(list [=id:dao d=dao])  ~(tap by daos)
  |-  
  ?~  daos  ~
  ?.  (~(has by graphs.d.i.daos) rid)
    $(daos t.daos)
  `id.i.daos
 ::  TODO: either lookup on chain, or submit attestation
::  
++  acc-id-to-ship
  |=  =account-id:tx
  `@p`account-id
--
    
