###
    pipelet.coffee

    Copyright (c) 2013-2017, Reactive Sets

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

###

# ----------------------------------------------------------------------------------------------
# rs test utils
# -------------

utils  = require( './tests_utils.js' ) unless this.expect

expect = this.expect || utils.expect
rs     = this.rs     || utils.rs

RS      = rs.RS
Pipelet = RS.Pipelet

# ----------------------------------------------------------------------------------------------
# pipelet test suite
# ------------------

describe 'Pipelet', ->
  describe 'Add( name, pipelet_factory )', ->
    factory = ( source, parameters ) ->
    
    it 'should allow a name of 4 characters long starting with one lower case letters', ->
      expect( -> Pipelet.Add 'a_0b', factory ).to.not.throwException()
    
    it 'should allow a name of 4 characters long starting starting with $, then one lower case letter', ->
      expect( -> Pipelet.Add '$a_0', factory ).to.not.throwException()
    
    it 'should not allow a name already used', ->
      expect( -> Pipelet.Add 'a_0b', factory ).to.throwException()
    
    it 'should not allow a name of less than 4 characters long', ->
      expect( -> Pipelet.Add 'abc', factory ).to.throwException()
    
    it 'should not allow a name of less than 4 characters long starting with $', ->
      expect( -> Pipelet.Add '$bc', factory ).to.throwException()
    
    it 'should not allow a name to start with underscore', ->
      expect( -> Pipelet.Add '_aaaaaaaaaaaaa', factory ).to.throwException()
    
    it 'should not allow a name to start with $ followed by underscore', ->
      expect( -> Pipelet.Add '$_aaaaaaaaaaaaa', factory ).to.throwException()
    
    it 'should not allow a name starting with a digit', ->
      expect( -> Pipelet.Add '0abcde', factory ).to.throwException()
    
    it 'should not allow a name starting with $ followed by a digit', ->
      expect( -> Pipelet.Add '$0abcde', factory ).to.throwException()
    
    it 'should not allow a name with a capital letter', ->
      expect( -> Pipelet.Add 'abcdeFg', factory ).to.throwException()
    
    it 'should not allow a factory function wih less than 2 parameters', ->
      expect( -> Pipelet.Add 'ab_0c2', ( source ) -> ).to.throwException()
    
    it 'should not allow a factory function wih more than 2 parameters', ->
      expect( -> Pipelet.Add 'ab_0c3', ( source, parameters, extra_parameter ) -> ).to.throwException()
  
  describe 'Pipelet.safe_identity_code()', ->
    code = null
    
    it 'should return valid code with no parameter', ->
      code = Pipelet.safe_identity_code()
      
      expect( code ).to.be.eql '"#" + o.id'
    
    it 'should return valid code with a string parameter', ->
      code = Pipelet.safe_identity_code( 'a string' )
      
      expect( code ).to.be.eql '"#" + o.id'
    
    it 'should return valid code with an object parameter', ->
      code = Pipelet.safe_identity_code( { length: 1 } )
      
      expect( code ).to.be.eql '"#" + o.id'
    
    it 'should return valid code with an empty array', ->
      code = Pipelet.safe_identity_code( [] )
      
      expect( code ).to.be.eql '"#" + o.id'
    
    it 'should return valid code with an array of one element', ->
      code = Pipelet.safe_identity_code( [ 'year' ] )
      
      expect( code ).to.be.eql '"#" + o.year'
    
    it 'should return valid code with an array of one element including a space', ->
      code = Pipelet.safe_identity_code( [ 'birth year' ] )
      
      expect( code ).to.be.eql '"#" + o[ "birth year" ]'
    
    it 'should return valid code with an array of two elements', ->
      code = Pipelet.safe_identity_code( [ 'birth year', 'author' ] )
      
      expect( code ).to.be.eql '"#" + o[ "birth year" ] + "#" + o.author'
    
    it 'should return valid code with an array of three elements including a code injection attempt', ->
      code = Pipelet.safe_identity_code( [ 'birth year', 'author', 'ending " \\with escape\\' ] )
      
      expect( code ).to.be.eql '"#" + o[ "birth year" ] + "#" + o.author + "#" + o[ "ending \\" \\\\with escape\\\\" ]'
    
    it 'should allow to build a function that returns an expected string from an Object', ->  
      f = new Function 'o', 'return ' + code
      
      expect( f { "birth year": 1934, "ending \" \\with escape\\": 4 } ).to.be.eql "#1934#undefined#4"
  
  describe 'create_namespace()', ->
    child = null
    grandchild = null
    
    factory = ( source, parameters ) ->
    
    it 'should allow to create a child namespace', ->
      child = rs.create_namespace( 'child', true );
      
      expect( child.namespace() ).to.be child
    
    it 'should provide access to RS', ->
      expect( child.RS ).to.be RS
    
    it 'should have rs as a parent class', ->
      expect( child._is_a 'Namespace.root' ).to.be true

    it 'should allow to create a grand-child namespace', ->
      grandchild = child.create_namespace( 'grandchild', true );
      
      expect( child.namespace() ).to.be child
    
    it 'should be a child of child namespace', ->
      expect( child._is_a 'Namespace.child' ).to.be true
    
    it 'should allow to use child to add a factory using Pipelet.Add()', ->
      expect( -> Pipelet.Add 'child_abc', factory, child ).to.not.throwException()
    
    it 'should allow access to factory', ->
      expect( child.child_abc ).to.be.a Function
    
    it 'should not not be accessible from rs', ->
      expect( rs.child_abc ).to.be undefined
    
    it 'but it should be accessible from grand-child namespace', ->
      expect( grandchild.child_abc ).to.be child.child_abc
    
    it 'should allow child to mixin factory into an object', ->
      object = child._scope._mixin {}
      
      expect( Object.keys object ).to.be.eql [ 'child_abc' ]
      expect( object.child_abc ).to.be child.child_abc
    
    it 'should not allow grandchild to mixin factory into an object', ->
      object = grandchild._scope._mixin {}
      
      expect( Object.keys object ).to.be.eql []
    
    it 'rs.set_output( "_rs" ).output( "_rs" ) should be rs', ->
      expect( rs.set_output( '_rs' ).output( '_rs' ) ).to.be rs
    
    it 'set output should be accessible from child namespace', ->
      expect( child.output( '_rs' ) ).to.be rs
    
    it 'set output should be accessible from grand-child namespace', ->
      expect( grandchild.output( '_rs' ) ).to.be rs
    
    it 'child.set_output( "_child" ).output( "_child" ) should be child', ->
      expect( child.set_output( '_child' ).output( '_child' ) ).to.be child
    
    it 'rs.output( "_child" ) should throw an Error', ->
      expect( -> rs.output( '_child' ) ).to.throwException()
    
    it 'grandchild.output( "_child" ) should be child', ->
      expect( grandchild.output( '_child' ) ).to.be child
    
    it 'grandchild.set_output( "_child" ) should throw and error', ->
      expect( -> grandchild.set_output( "_child" ) ).to.throwException()
    
    it 'should allow rs.set_output( "_child" ).output( "_child" ) to return rs', ->
      expect( rs.set_output( "_child" ).output( "_child" ) ).to.be rs
    
    it 'child.output( "_child" ) should keep returning child', ->
      expect( child.output( '_child' ) ).to.be child
    
  describe 'set_default_options()', ->
    as_array            = ( a ) -> Array.prototype.slice.call a, 0
    
    set_default_options = null
    source              = null
    source_path         = null
    f                   = null
    defaults            = null
    
    expect_name = ( parameters, defaults, position ) ->
      name = parameters[ position ].name
      
      if defaults.name
        expect( name.slice( 0, defaults.name.length ) ).to.be.eql defaults.name
        
        expect( name.length ).to.be.above defaults.name.length
      
      name
    
    it 'should return parameters with all default options set', ->
      set_default_options = Pipelet.set_default_options
      
      source = {}
      
      source_path = {
        _key: [ 'path' ]
      }
      
      f = ( p, options ) ->
      
      f.default_options = {
        test: true
      }
      
      defaults = {
        other: 'other'
        name: 'default_name'
      }
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source, parameters, defaults )
          
          expect( parameters  ).to.be.eql [
            'p1'
            {
              source_key: [ 'id' ]
              test: true
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1' )
    
    it 'should use source._key if provided', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              test: true
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1' )
    
    it 'should still work if options is set to undefined', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              test: true
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1', undefined )
    
    it 'should work if no defaults are provided', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              test: true
              name: expect_name parameters, {}, 1
            }
          ]
      )( 'p1' )
    
    it 'should work pipelet defaults options is null', ->
      f.default_options = null
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              name: expect_name parameters, {}, 1
            }
          ]
      )( 'p1' )
    
    it 'should work pipelet defaults options is not defined', ->
      delete f.default_options
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              name: expect_name parameters, {}, 1
            }
          ]
      )( 'p1' )
    
    it 'should work pipelet defaults options is provided by a function', ->
      f.default_options = ( p1, options ) -> { p1: 'test ' + p1 }
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              p1: 'test p1'
              name: expect_name parameters, {}, 1
            }
          ]
      )( 'p1' )
    
    it 'should throw if pipelet defaults options is not a function or an object', ->
      f.default_options = true
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          expect( () -> set_default_options( f, source_path, parameters ) ).to.throwException()
      )( 'p1' )
    
    it 'should extend options when provided by caller', ->
      f.default_options = ( p1, options ) -> { p1: 'test ' + p1 }
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              p1: 'test p1'
              from_caller: 1
              name: expect_name parameters, {}, 1
            }
          ]
      )( 'p1', { from_caller: 1 } )
    
    it 'should not mutate options parameter from invocation', ->
      f.default_options = ( p1, options ) -> { p1: 'test ' + p1 }
      
      original_options = { from_caller: 1 }
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              p1: 'test p1'
              from_caller: 1
              name: expect_name parameters, {}, 1
            }
          ]
          
          expect( options ).to.be.eql original_options
      )( 'p1', RS.extend.clone( original_options ) )
    
    it 'caller options should supercede pipelet default options', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              p1: 'from caller'
              name: 'caller name'
            }
          ]
      )( 'p1', { p1: 'from caller', name: 'caller name' } )
    
    it 'caller options should supercede other default options', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              p1: 'test p1'
              other: 'from caller'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1', { other: 'from caller' } )
    
    it 'caller key option should supercede default key', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              key: [ 'node-id', 'id' ]
              p1: 'test p1'
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1', { key: [ 'node-id', 'id' ] } )
    
    it 'defaults key option should supercede default key', ->
      defaults.key = [ 'uuid' ]
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'p1'
            {
              source_key: [ 'path' ]
              key: [ 'uuid' ]
              p1: 'test p1'
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'p1' )
    
    it 'pipelet default options key option should supercede default key', ->
      f.default_options = ( p1, options ) -> { p1: 'test ' + p1, key: [ p1 ] }
      
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'path'
            {
              source_key: [ 'path' ]
              key: [ p1 ]
              p1: 'test path'
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'path' )
    
    it 'should throw if options parameter is not an object', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          expect( () -> set_default_options( f, source_path, parameters, defaults ) ).to.throwException()
      )( 'path', 'not an object' )
    
    it 'should throw if too many parameters are provided', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          expect( () -> set_default_options( f, source_path, parameters, defaults ) ).to.throwException()
      )( 'path', {}, {} )
    
    it 'should accept null options', ->
      ( ( p1, options ) ->
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.eql [
            'path'
            {
              source_key: [ 'path' ]
              key: [ p1 ]
              p1: 'test path'
              other: 'other'
              name: expect_name parameters, defaults, 1
            }
          ]
      )( 'path', null )
    
    it 'should allow no parameter and no default_options property', ->
      ( ( p1, options ) ->
          delete f.default_options;
          
          parameters = as_array( arguments )
          
          set_default_options( f, source_path, parameters, defaults )
          
          expect( parameters ).to.be.an Array
          expect( parameters[ 0 ] ).to.be.eql undefined
          expect( parameters[ 1 ] ).to.be.eql {
            source_key: [ 'path' ]
            key: [ 'uuid' ]
            other: 'other'
            name: expect_name parameters, defaults, 1
          }
      )()
    
  describe 'Lazy and Greedy Pipelet Connections', ->
    values = null
    source = null
    lazy   = null
    greedy = null
    
    describe 'add_source()', ->
      it 'Attempting to use _input.add_source() with a Pipelet instead of an Output should throw', ->
        values = [ { id: 1 }, { id: 2 } ]
        
        source = new Pipelet().set_namespace( rs )
        lazy   = new Pipelet().set_namespace( rs )
        greedy = rs.greedy()
        
        expect( () -> greedy._input.add_source source ).to.throwException()
      
      it 'Adding as "source" as a source to "lazy", "source" should have "lazy" input as desintations', ->
        lazy._add_source source
        
        expect( source._output.destinations ).to.be.eql [ lazy._input ]
      
      it '"lazy" should have "source._output" as its input source', ->
        expect( lazy._input.source ).to.be source._output
      
      it '"source" query tree should not have "lazy" as a subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql []
      
      it 'after adding "greedy", "source" should now have "lazy" and "greedy" inputs as destinations', ->
        greedy._input.add_source source._output
        
        expect( source._output.destinations ).to.be.eql [ lazy._input, greedy._input ]
      
      it '"greedy" should have "source._output" as its input source', ->
        expect( greedy._input.source ).to.be source._output
      
      it '"source" query tree should have "greedy" as the only subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql [ greedy._input ]
      
      it 'Trying to add "source" as a source of "lazy" a second time should throw', ->
        expect( () -> lazy._add_source source ).to.throwException()
      
      it 'Trying to add "source" as a source of "greedy" a second time should throw', ->
        expect( () -> greedy._input.add_source source._output ).to.throwException()
      
      it 'Trying to add "lazy" as a source of "greedy" should throw', ->
        expect( () -> greedy._add_source lazy ).to.throwException()
      
    describe 'remove_source()', ->
      it 'Attempting to use _input.remove_source() with a Pipelet instead of an Output should throw', ->
        expect( () -> greedy._input.remove_source source ).to.throwException()
      
      it 'After removing "source" as a source of "lazy", "source" should have only "greedy" as a destination', ->
        lazy._remove_source source
        
        expect( source._output.destinations ).to.be.eql [ greedy._input ]
      
      it 'Trying to remove "source" as a source of "lazy" a second time should throw', ->
        expect( () -> lazy._remove_source source ).to.throwException()
      
      it 'After removing "source" as a source of "greedy", "source" should no-longer have destinations', ->
        greedy._input.remove_source source._output
        
        expect( source._output.destinations ).to.be.eql []
      
      it '"source" query tree should no-longer have "greedy" as a subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql []
      
      it 'Trying to remove "source" as a source of "greedy" a second time should throw', ->
        expect( () -> greedy._remove_source source ).to.throwException()
      
    describe 'add_destination()', ->
      it 'Attempting to use _output.add_destination() with a Pipelet instead of an Input should throw', ->
        expect( () -> source._output.add_destination greedy ).to.throwException()
      
      it 'Adding "lazy" as a destination to "source", "source" should have "lazy" input as desintations', ->
        # Reinitialize lazy because the previous operation threw an exception but left it in a greedy state
        lazy = new Pipelet().set_namespace( rs )
        
        source._add_destination lazy
        
        expect( source._output.destinations ).to.be.eql [ lazy._input ]
      
      it '"lazy" should have "source._output" as its input source', ->
        expect( lazy._input.source ).to.be source._output
      
      it '"source" query tree should not have "lazy" as a subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql []
      
      it 'after adding "greedy", "source" should now have "lazy" and "greedy" inputs as destinations', ->
        source._output.add_destination greedy._input
        
        expect( source._output.destinations ).to.be.eql [ lazy._input, greedy._input ]
      
      it '"greedy" should have "source._output" as its input source', ->
        expect( greedy._input.source ).to.be source._output
      
      it '"source" query tree should have "greedy" as the only subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql [ greedy._input ]
      
      it 'Trying to add "lazy" as a destination to "source" a second time should throw', ->
        expect( () -> source._add_destination lazy ).to.throwException()
      
      it 'Trying to add "greedy" as a destination to "source" a second time should throw', ->
        expect( () -> source._output._input.add_destination greedy._input ).to.throwException()
      
      it 'Trying to add "greedy" as a destination to "greedy" should throw', ->
        expect( () -> lazy._add_destination greedy ).to.throwException()
      
    describe 'remove_destination()', ->
      it 'Attempting to use _output.remove_destination() with a Pipelet instead of an Input should throw', ->
        expect( () -> source._output.remove_destination greedy ).to.throwException()
      
      it 'After removing "lazy" as a destionation to "source", "source" should have only "greedy" as a destination', ->
        source._remove_destination lazy
        
        expect( source._output.destinations ).to.be.eql [ greedy._input ]
      
      it 'Trying to remove "lazy" as a destination to "source" a second time should throw', ->
        expect( () -> source._remove_destination lazy ).to.throwException()
      
      it 'After removing "greedy" as a destionation to "source", "source" should no-longer have destinations', ->
        source._output.remove_destination greedy._input
        
        expect( source._output.destinations ).to.be.eql []
      
      it '"source" query tree should no-longer have "greedy" as a subscriber in its top node', ->
        expect( source._output.tree.top.subscribers ).to.be.eql []
      
      it 'Trying to remove "greedy" as a destination to "source" a second time should throw', ->
        expect( () -> source._remove_destination greedy ).to.throwException()
      
    # ToDo: add / remove _ source / destination on an Array of objects
    
    describe 'Fetching contend on connections through the dot "." operator', ->
      it 'should have fetched content into a set through a stateless pipelet', ->
        s = rs.set( values ).pass_through().set()
        
        expect( s.a ).to.be.eql values
    
    describe 'Fetching content on add_destination()', ->
      it 'should have fetched content into a set even if stateless pipelet is pluged last into upstream pipelet', ->
        s = rs.set( values )
        
        p = rs.pass_through()
        
        s1 = p.set()
        
        s._output.add_destination( p._input )
        
        expect( s1.a ).to.be.eql values

