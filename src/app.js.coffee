# JS Manifest
# Use Sprockets to define JS load order here
#= require learning_objectives

root = exports ? this

root.app = {
  init: ->
    @model = new Content.Collection(sr)
    @model.setElement('test').setMode('edit').render()
}

Content = {
  getClass: (type,mode) ->
    cname = type.camelize()
    mname = mode.camelize()
    if this[cname] and this[cname][mname]
      this[cname][mname]
    else if mode == 'edit'
      this.Block.Edit
    else
      this.Block
}

makeNode = (obj) ->
  if obj.name
    node = document.createElement(obj.name)
    node.setAttribute(k,v) for k,v of obj.attrs

    if obj.children?.length
      node.appendChild makeNode(c) for c in obj.children

    if obj.content
      node.appendChild document.createTextNode(obj.content)

  else
    node = document.createTextNode(obj.content)

  return node


class Content.Collection
  constructor: (response) ->
    @data = response.content
    @type = @data.type
    @mode = 'read'
    @setBlocks()
    @resetNode()

    document.addEventListener 'click', (event) =>
      @handleClick(event) if @mode == 'edit'

  setBlocks: ->
    @blocks = []
    for c in @data.children
      Klass = Content.getClass(c.type,@mode)
      @blocks.push new Klass(c)

  setMode: (mode) ->
    @mode = mode
    @setBlocks()
    this

  setElement: (id) ->
    @node = document.getElementById(id)
    @resetNode()
    this

  resetNode: ->
    newNode = document.createElement(@data.name)
    newNode.setAttribute(k,v) for k,v of @data.attrs
    @node.parentNode.replaceChild(newNode,@node) if @node
    @node = newNode

  render: ->
    @resetNode()
    @node.appendChild(b.render().node) for b in @blocks
    this

  handleClick: (event) ->
    node = event.target
    while node isnt document.body
      if node.className.has('model')
        match = node
        break
      node = node.parentNode

    if match
      for b in @blocks
        if b.node is match
          b.startEditing() unless b.editing
        else
          b.stopEditing() if b.editing
    else
      b.stopEditing() for b in @blocks when b.editing
      console.log 'editing nothing'


class Content.Block
  constructor: (content) ->
    @type = content.type
    @data = content

  render: ->
    @node = makeNode(@data)
    @bindEvents()
    this

  bindEvents: -> undefined


class Content.Block.Edit extends Content.Block
  render: ->
    @node = @makeWrapper()
    @blockNode = makeNode(@data)
    @node.appendChild(@blockNode)
    this

  makeWrapper: ->
    wrapper = document.createElement('div')
    wrapper.className = 'model wraper'
    wrapper

  startEditing: (event) ->
    @editing = true
    @node.className += " editing"

  stopEditing: ->
    if @editing
      @editing = false
      @node.className = @node.className.replace " editing", ""
      console.log "Send to server:", @blockNode.outerHTML

Content.LearningObjectives = {}
class Content.LearningObjectives.Edit extends Content.Block.Edit
  render: ->
    super
    @node.className += " red"
    this

  startEditing: (event) ->
    super
    @formNode = document.createElement('div')
    @formNode.innerHTML = JST['learning_objectives'](@dataMap())
    elements = @formNode.querySelectorAll('[data-name]')
    @fields = []
    for el in elements
      nib = new Nib.Editor node: el, plugins:['bold','italic','underline']
      nib.activate()
      @fields.push(nib)
    @node.replaceChild(@formNode,@blockNode)

  stopEditing: ->
    if @editing
      @parseForm()
      @blockNode = makeNode(@data)
      @node.replaceChild(@blockNode,@formNode)
    super

  dataMap: ->
    {
      title: @data.children[0],
      description: @data.children[1],
      list: @data.children[2].children
    }

  parseForm: ->
    for nib in @fields
      name = nib.node.dataset.name
      if i = nib.node.dataset.index
        @dataMap()[name][i].content = nib.node.innerHTML
      else
        @dataMap()[name].content = nib.node.innerHTML
