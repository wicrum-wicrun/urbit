recl       = React.createClass

module.exports = 
  codemirror: require './CodeMirror.coffee'
  search:     require './SearchComponent.coffee'
  list:       require './ListComponent.coffee'
  kids:       require './KidsComponent.coffee'
  toc:        require './TocComponent.coffee'
  lost:       recl render: -> (div {}, "lost")
