/-  sur=group-view, spider
/+  resource, strandio, metadata=metadata-store, store=group-store
^?
=<  [. sur]
=,  sur
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  create+create
        remove+remove
        join+join
        leave+leave
        invite+invite
        hide+dejs-path:resource
    ==
  ::
  ++  create
    %-  ot
    :~  name+so
        policy+policy:dejs:store
        title+so
        description+so
    ==
  ::
  ++  remove  dejs:resource
  ::
  ++  leave  dejs:resource
  ::
  ++  join
    %-  ot
    :~  resource+dejs:resource
        ship+(su ;~(pfix sig fed:ag))
    ==
  ::
  ++  invite
    %-  ot
    :~  resource+dejs:resource
        ships+(as (su ;~(pfix sig fed:ag)))
        description+so
    ==
  --
::
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  upd=^update
    %+  frond  %group-view-update
    %+  frond  -.upd
    ?-  -.upd
      %initial  (initial +.upd)
      %progress  (progress +.upd)
      %hide      s+(enjs-path:resource +.upd)
    ==
  ::
  ++  progress
    |=  [rid=resource prog=^progress]
    %-  pairs
    :~  resource+s+(enjs-path:resource rid)
        progress+s+prog
    ==
  ++  request
    |=  req=^request
    %-  pairs
    :~  hidden+b+hidden.req
        started+(time started.req)
        ship+(ship ship.req)
        progress+s+progress.req
    ==
  ::
  ++  initial
    |=  init=(map resource ^request)
    %-  pairs
    %+  turn  ~(tap by init)
    |=  [rid=resource req=^request]
    :_  (request req)
    (enjs-path:resource rid)
  --
++  cleanup-md
  |=  rid=resource
  =/  m  (strand:spider ,~)
  ^-  form:m
  ;<  =associations:metadata  bind:m  
    %+  scry:strandio  associations:metadata
    %+  weld  /gx/metadata-store/group 
    (snoc (en-path:resource rid) %noun)
  ~&  associations
  =/  assocs=(list [=md-resource:metadata association:metadata])
    ~(tap by associations) 
  |-  
  =*  loop  $
  ?~  assocs
    (pure:m ~)
  ;<  ~  bind:m
    %+  poke-our:strandio  %metadata-store
    metadata-action+!>([%remove rid md-resource.i.assocs])
  loop(assocs t.assocs)
--
