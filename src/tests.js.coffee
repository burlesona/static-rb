assert = chai.assert

describe 'app', ->
  it 'should exist', ->
    assert.ok app
  it 'should have a model', ->
    assert.ok app.model
  it 'should have model content', ->
    assert.ok app.model.content

describe 'scholar response', ->
  it 'should exist', ->
    assert.ok sr

  it 'should have content', ->
    assert.ok sr.content

  it 'should have 18 children',->
    assert.equal sr.content.children.length, 18

describe 'collection', ->
  beforeEach -> @m = app.model

  it 'should have a root', ->
    assert.ok @m.root

describe 'collection root', ->
  beforeEach -> @r = app.model.root

  it 'should be a section', ->
    assert.equal @r.type, 'section'

  it 'should have 18 children', ->
    assert.equal @r.children.length, 18
