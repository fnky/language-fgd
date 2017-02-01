describe 'FGD grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-fgd')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.fgd')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.fgd'

  describe 'strings', ->
    it 'tokenizes single-line strings', ->
      scope = 'string.quoted.double.fgd'
      {tokens} = grammar.tokenizeLine '"x"'

      expect(tokens[0].value).toEqual '"'
      expect(tokens[0].scopes).toEqual ['source.fgd', scope, 'punctuation.definition.string.begin.fgd']
      expect(tokens[1].value).toEqual 'x'
      expect(tokens[1].scopes).toEqual ['source.fgd', scope]
      expect(tokens[2].value).toEqual '"'
      expect(tokens[2].scopes).toEqual ['source.fgd', scope, 'punctuation.definition.string.end.fgd']

  describe 'numbers', ->
    it 'tokenizes integers', ->
      {tokens} = grammar.tokenizeLine('1234')
      expect(tokens[0]).toEqual value: '1234', scopes: ['source.fgd', 'constant.numeric.fgd']

    it 'tokenizes invalid numbers (decimals)', ->
      {tokens} = grammar.tokenizeLine('1.0')
      expect(tokens[0]).toEqual value: '1', scopes: ['source.fgd', 'constant.numeric.fgd']
      expect(tokens[1]).toEqual value: '.', scopes: ['source.fgd', 'constant.numeric.fgd', 'invalid.illegal.fgd']
      expect(tokens[2]).toEqual value: '0', scopes: ['source.fgd', 'constant.numeric.fgd']

    it 'does not tokenize numbers that are part of a variable', ->
      {tokens} = grammar.tokenizeLine 'foo1'
      expect(tokens[0]).toEqual value: 'foo1', scopes: ['source.fgd']

      {tokens} = grammar.tokenizeLine 'foo$1'
      expect(tokens[0]).toEqual value: 'foo$1', scopes: ['source.fgd']

      {tokens} = grammar.tokenizeLine 'foo_1'
      expect(tokens[0]).toEqual value: 'foo_1', scopes: ['source.fgd']

  describe 'comments', ->
    it 'tokenizes empty // comments', ->
      {tokens} = grammar.tokenizeLine '//'
      expect(tokens[0]).toEqual value: '//', scopes: ['source.fgd', 'comment.line.double-slash.fgd', 'punctuation.definition.comment.fgd']

    it "tokenizes // comments", ->
      {tokens} = grammar.tokenizeLine('// comment')
      expect(tokens[0]).toEqual value: '//', scopes: ['source.fgd', 'comment.line.double-slash.fgd', 'punctuation.definition.comment.fgd']
      expect(tokens[1]).toEqual value: ' comment', scopes: ['source.fgd', 'comment.line.double-slash.fgd']

    it "tokenizes comments inside entity definitions", ->
      methodDefinitionScope = 'meta.function.method.definition.fgd'

      {tokens} = grammar.tokenizeLine('spawnflags(flags) // comment')
      expect(tokens[0]).toEqual value: 'spawnflags', scopes: ['source.fgd', methodDefinitionScope, 'entity.name.function.fgd']
      expect(tokens[1]).toEqual value: '(', scopes: ['source.fgd', methodDefinitionScope, 'meta.parameters.fgd', 'punctuation.definition.parameters.begin.bracket.round.fgd']
      expect(tokens[2]).toEqual value: 'flags', scopes: ['source.fgd', methodDefinitionScope, 'meta.parameters.fgd', 'storage.type.fgd']
      expect(tokens[3]).toEqual value: ')', scopes: ['source.fgd', methodDefinitionScope, 'meta.parameters.fgd', 'punctuation.definition.parameters.end.bracket.round.fgd']
      expect(tokens[5]).toEqual value: '//', scopes: ['source.fgd', 'comment.line.double-slash.fgd', 'punctuation.definition.comment.fgd']
      expect(tokens[6]).toEqual value: ' comment', scopes: ['source.fgd', 'comment.line.double-slash.fgd']

    describe 'storage types', ->
      types = ['string', 'integer', 'float', 'choices', 'void', 'flags']

      for type in types
        it "tokenizes the #{type} storage type", ->
          {tokens} = grammar.tokenizeLine type
          expect(tokens[0]).toEqual value: type, scopes: ['source.fgd', 'storage.type.fgd']

    describe 'class declarations', ->
      it "tokenizes class declaration", ->
        {tokens} = grammar.tokenizeLine '@SolidClass = worldspawn'
        expect(tokens[0]).toEqual value: '@SolidClass', scopes: ['source.fgd', 'support.class.fgd']
        expect(tokens[2]).toEqual value: '=', scopes: ['source.fgd', 'meta.class.fgd', 'keyword.operator.assignment.fgd']
        expect(tokens[4]).toEqual value: 'worldspawn', scopes: ['source.fgd', 'meta.class.fgd', 'support.class.fgd']

      it "tokenizes class declaration with properties", ->
        {tokens} = grammar.tokenizeLine '@BaseClass base(foo) = Bar'
        expect(tokens[0]).toEqual value: '@BaseClass', scopes: ['source.fgd', 'support.class.fgd']
        expect(tokens[2]).toEqual value: 'base', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'entity.name.function.fgd']
        expect(tokens[3]).toEqual value: '(', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'punctuation.definition.parameters.begin.bracket.round.fgd']
        expect(tokens[4]).toEqual value: 'foo', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'variable.parameter.function.fgd']
        expect(tokens[5]).toEqual value: ')', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'punctuation.definition.parameters.end.bracket.round.fgd']
        expect(tokens[7]).toEqual value: '=', scopes: ['source.fgd', 'meta.class.fgd', 'keyword.operator.assignment.fgd']
        expect(tokens[9]).toEqual value: 'Bar', scopes: ['source.fgd', 'meta.class.fgd', 'support.class.fgd']

      it "tokenizes class declaration with description", ->
        {tokens} = grammar.tokenizeLine '@SolidClass = worldspawn : "x"'
        expect(tokens[0]).toEqual value: '@SolidClass', scopes: ['source.fgd', 'support.class.fgd']
        expect(tokens[2]).toEqual value: '=', scopes: ['source.fgd', 'meta.class.fgd', 'keyword.operator.assignment.fgd']
        expect(tokens[4]).toEqual value: 'worldspawn', scopes: ['source.fgd', 'meta.class.fgd', 'support.class.fgd']
        expect(tokens[6]).toEqual value: ':', scopes: ['source.fgd', 'meta.class.fgd', 'keyword.operator.descriptor.fgd']
        expect(tokens[8]).toEqual value: '"', scopes: ['source.fgd', 'string.quoted.double.fgd', 'punctuation.definition.string.begin.fgd']
        expect(tokens[9]).toEqual value: 'x', scopes: ['source.fgd', 'string.quoted.double.fgd']
        expect(tokens[10]).toEqual value: '"', scopes: ['source.fgd', 'string.quoted.double.fgd', 'punctuation.definition.string.end.fgd']

    describe 'entity properties', ->
      it "tokenizes entity  property", ->
        {tokens} = grammar.tokenizeLine 'foo(integer) : "x" : 0'
        expect(tokens[0]).toEqual value: 'foo', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'entity.name.function.fgd']
        expect(tokens[1]).toEqual value: '(', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'punctuation.definition.parameters.begin.bracket.round.fgd']
        expect(tokens[2]).toEqual value: 'integer', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'storage.type.fgd']
        expect(tokens[3]).toEqual value: ')', scopes: ['source.fgd', 'meta.function.method.definition.fgd', 'meta.parameters.fgd', 'punctuation.definition.parameters.end.bracket.round.fgd']
        expect(tokens[5]).toEqual value: '"', scopes: ['source.fgd', 'string.quoted.double.fgd', 'punctuation.definition.string.begin.fgd']
        expect(tokens[6]).toEqual value: 'x', scopes: ['source.fgd', 'string.quoted.double.fgd']
        expect(tokens[7]).toEqual value: '"', scopes: ['source.fgd', 'string.quoted.double.fgd', 'punctuation.definition.string.end.fgd']
        expect(tokens[9]).toEqual value: '0', scopes: ['source.fgd', 'constant.numeric.fgd']
