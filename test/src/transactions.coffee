###
    transactions.coffee

    Copyright (c) 2013-2020, Reactive Sets

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

utils   = require( './tests_utils.js' ) unless this.expect?

expect  = this.expect || utils.expect
rs      = this.rs     || utils.rs
RS      = rs.RS
log     = RS.log
pretty  = log.pretty
uuid_v4 = RS.uuid.v4
clone   = RS.extend.clone
slice   = Array.prototype.slice

# ----------------------------------------------------------------------------------------------
# Require tested modules
# ----------------------

require '../../lib/core/transactions.js' unless RS.Transactions?

Transactions        = RS.Transactions

Transaction         = Transactions.Transaction

IO_Transactions     = Transactions.IO_Transactions
Input_Transactions  = Transactions.Input_Transactions
Output_Transactions = Transactions.Output_Transactions

IO_Transactions     = Transactions.IO_Transactions
Input_Transaction   = Transactions.Input_Transaction
Output_Transaction  = Transactions.Output_Transaction

Options             = Transactions.Options

# ----------------------------------------------------------------------------------------------
# Some constants
# --------------

valid_uuid_v4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

# ----------------------------------------------------------------------------------------------
# Transactions test suite
# -----------------------

describe 'Transactions test suite', ->
  describe 'RS.uuid.v4()', ->
    # Generate 10 random uuid v4 to verify that they al match
    v4_0 = uuid_v4()
    v4_1 = uuid_v4()
    v4_2 = uuid_v4()
    v4_3 = uuid_v4()
    v4_4 = uuid_v4()
    v4_5 = uuid_v4()
    v4_6 = uuid_v4()
    v4_7 = uuid_v4()
    v4_8 = uuid_v4()
    v4_9 = uuid_v4()

    it '10 uuid_v4() should return a uuid v4 string: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx where x is hexadecimal and y [89ab]', ->
      expect( v4_0 ).to.match( valid_uuid_v4 ) and
      expect( v4_1 ).to.match( valid_uuid_v4 ) and
      expect( v4_2 ).to.match( valid_uuid_v4 ) and
      expect( v4_3 ).to.match( valid_uuid_v4 ) and
      expect( v4_4 ).to.match( valid_uuid_v4 ) and
      expect( v4_5 ).to.match( valid_uuid_v4 ) and
      expect( v4_6 ).to.match( valid_uuid_v4 ) and
      expect( v4_7 ).to.match( valid_uuid_v4 ) and
      expect( v4_8 ).to.match( valid_uuid_v4 ) and
      expect( v4_9 ).to.match( valid_uuid_v4 )
  
  # RS.uuid_v4()
  
  describe 'Options', ->
    describe 'Options.get_tid( options )', ->
      get_tid = Options.get_tid
      
      it 'should be a function with one parameter', ->
        expect( get_tid ).to.be.a( 'function' )
        expect( get_tid.length ).to.be.eql 1
      
      it 'should return undefined when no options are provided', ->
        expect( get_tid() ).to.be.eql undefined
      
      it 'should return undefined when no transaction object is present', ->
        expect( get_tid {} ).to.be.eql undefined
      
      it 'should return undefined when no transaction id is present in transaction object', ->
        expect( get_tid { _t: {} } ).to.be.eql undefined
      
      it 'should return a transaction identifier is present in options transaction object', ->
        expect( get_tid { _t: { id: 42 } } ).to.be 42
    
    describe 'Options.get_tid( options )', ->
      get_tid = Options.get_tid
      set_tid = Options.set_tid
      
      it 'should be a function with one parameter', ->
        expect( set_tid ).to.be.a( 'function' )
        expect( set_tid.length ).to.be.eql 1
      
      it 'should not modify options if a transaction identifier is present in options transaction object', ->
        options_in  = { _t: { id: 42 } }
        options_out = set_tid( options_in )
        
        expect( options_out ).to.be options_in
        expect( get_tid options_out ).to.be 42
      
      it 'should modify options to set a valid uuid_v4 in a transaction object', ->
        options_in  = { _t: {} }
        options_out = set_tid( options_in )
        log( 'options_out:', pretty( options_out ) )
        
        expect( options_out ).to.not.be options_in
        expect( get_tid options_out ).to.match( valid_uuid_v4 )
      
      it 'should modify options to set a valid uuid_v4 in a new transaction object', ->
        options_in  = {}
        options_out = set_tid( options_in )
        
        expect( options_out ).to.not.be options_in
        expect( get_tid options_out ).to.match( valid_uuid_v4 )
      
      it 'should create options with a transaction object and a valid uuid_v4 tid', ->
        expect( get_tid set_tid() ).to.match( valid_uuid_v4 )
    
    describe 'Options.forward( more )', ->
      options_forward = Options.forward
      uuid = uuid_v4()
      
      it 'should be a function with one parameter', ->
        expect( options_forward ).to.be.a( 'function' ) &&
        expect( options_forward.length ).to.be.eql 1
      
      it 'should return undefined when called with no source options', ->
        expect( options_forward() ).to.be.eql undefined
      
      it 'should return { _t: { more: false } } with options { a: 1, b: {}, _t: { more: false } }', ->
        expect( options_forward { a: 1, b: {}, _t: { more: false } } ).to.be.eql { _t: { more: false } }
      
      it 'should return undefined with options { a: 1; b: {} }', ->
        expect( options_forward { a: 1, b: {} } ).to.be.eql undefined
      
      it 'should return { _t: { more: true, id: uuid } } with options { a: 1, _t: { more: true, id: uuid } }', ->
        more = { a: 1, _t: { more: true, id: uuid } }
        
        expect( options_forward more ).to.be.eql {
          _t: { more: true, id: uuid }
        }
      
      it 'should return { _t: { id: uuid } } with options { _t: { more: false, id: uuid } )', ->
        more = { _t: { more: false, id: uuid } }
        
        expect( options_forward more ).to.be.eql {
          _t: { id: uuid, more: false }
        }
        
      it 'should return { _t: { more: true, id: uuid } } with options { _t: { more: 1, id: uuid } }', ->
        more = { _t: { more: 1, id: uuid } }
        
        expect( options_forward more ).to.be.eql {
          _t: { more: true, id: uuid }
        }
        
      it 'should return { _t: { id: uuid } } with options { _t: { id: uuid } }', ->
        more = { _t : { id: uuid } }
        
        expect( options_forward( more ) ).to.be.eql {
          _t: { id: uuid }
        }
    # options_forward( more )
    
    describe 'Options.has_more( options )', ->
      has_more = Options.has_more
      
      it 'should return falsy if options is undefined', ->
        expect( !!has_more() ).to.be false
      
      it 'should return falsy if options has no transaction', ->
        expect( !!has_more( {} ) ).to.be false
      
      it 'should return falsy if options has a transaction with more not true', ->
        expect( !!has_more( { _t: {} } ) ).to.be false
      
      it 'should return true if options has a transaction with more set to true', ->
        expect( has_more( { _t: { more: true } } ) ).to.be true
    # has_more( options )
    
    describe 'Options.last_fork_tag( options )', ->
      last_fork_tag = Options.last_fork_tag
      
      it 'should return undefined if there is no transaction', ->
        expect( last_fork_tag() ).to.be undefined
      
      it 'should return undefined there is a transaction with no forks', ->
        expect( last_fork_tag( {} ) ).to.be undefined
      
      it 'should return 0 if there is a transaction with empty forks', ->
        expect( last_fork_tag( { forks: [] } ) ).to.be 0
      
      it 'should return fork tag if options has a transaction with a fork tag', ->
        fork_tag = 'a tag';
        
        expect( last_fork_tag( { forks: [ fork_tag ] } ) ).to.be fork_tag
      
      it 'should return last fork tag if there is a transaction with more than one fork tag', ->
        fork_tag = 'a tag';
        
        expect( last_fork_tag( { forks: [ 'a first tag', 'a second tag', fork_tag ] } ) ).to.be fork_tag
     # last_fork_tag( options )
     
     describe 'Options.add_fork_tag( options, tag )', ->
       add_fork_tag = Options.add_fork_tag
       options = null
       
       it 'add_fork_tag() should be a function', ->
         expect( add_fork_tag ).to.be.a Function
       
       describe 'With undefined options', ->

         it 'should return an options object', ->
           options = add_fork_tag( null, 'a tag' )
           
           expect( typeof( options ) ).to.be.eql 'object'
         
         it 'should have a transaction object', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
         
         it 'should have a valid uuid for id', ->
           expect( options._t.id ).to.match( valid_uuid_v4 )
         
         it 'should have more undefined', ->
           expect( options._t.more ).to.be undefined
           
         it 'should have a forks Array', ->
           expect( options._t.forks ).to.be.an Array
         
         it 'should have a single fork tag', ->
           expect( options._t.forks ).to.be.eql [ 'a tag' ]
       
       describe 'With an options object with no transaction', ->
         input_options = {}
         
         it 'should return another options object', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options ).to.not.be input_options
           
           expect( typeof( options ) ).to.be.eql 'object'
         
         it 'should have a transaction object', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
         
         it 'should have a valid uuid for id', ->
           expect( options._t.id ).to.match( valid_uuid_v4 )
         
         it 'should have more undefined', ->
           expect( options._t.more ).to.be undefined
         
         it 'should have a forks Array', ->
           expect( options._t.forks ).to.be.an Array
         
         it 'should have a single fork tag', ->
           expect( options._t.forks ).to.be.eql [ 'a tag' ]
       
       describe 'With options object and an ended transaction, with no fork tag', ->
         uuid = uuid_v4()
         
         input_options = { _t: { id: uuid } }
         
         it 'should return another options object', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options ).to.not.be input_options
           
           expect( typeof( options ) ).to.be.eql 'object'
         
         it 'should have a distinct transaction object', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
           
           expect( options._t ).to.not.be input_options._t
         
         it 'should have the same uuid as input options', ->
           expect( options._t.id ).to.be uuid
         
         it 'should have more undefined', ->
           expect( options._t.more ).to.be undefined
         
         it 'should have a forks Array', ->
           expect( options._t.forks ).to.be.an Array
         
         it 'should have a single fork tag', ->
           expect( options._t.forks ).to.be.eql [ 'a tag' ]
         
         it 'should have no other attributes', ->
           expect( options ).to.be.eql { _t: { id: uuid, forks: [ 'a tag' ] } }
       
       describe 'With options object and an ongoing transaction, with no fork tag', ->
         uuid = uuid_v4()
         
         input_options = { _t: { id: uuid, more: true } }
         
         it 'should return another options object', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options ).to.not.be input_options
         
         it 'should have a transaction object distinct from input options', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
           
           expect( options._t ).to.not.be input_options._t
         
         it 'should have the same uuid as input options', ->
           expect( options._t.id ).to.be uuid
         
         it 'should have more set to true', ->
           expect( options._t.more ).to.be true
         
         it 'should have a single fork tag', ->
           expect( options._t.forks ).to.be.eql [ 'a tag' ]
         
         it 'should have no other attributes', ->
           expect( options ).to.be.eql { _t: { id: uuid, more: true, forks: [ 'a tag' ] } }
       
       describe 'With options object and an ongoing transaction, and the same fork tag', ->
         uuid = uuid_v4()
         
         input_options = { _t: { id: uuid, more: true, forks: [ 'a tag' ] } }
         
         it 'should return the same options object, same transaction object and same forks array', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options          ).to.be input_options
           expect( options._t       ).to.be input_options._t
           expect( options._t.forks ).to.be input_options._t.forks
         
         it 'should have no other attributes', ->
           expect( options ).to.be.eql { _t: { id: uuid, more: true, forks: [ 'a tag' ] } }
       
       describe 'With options object and an ongoing transaction with an upstream fork tag', ->
         uuid = uuid_v4()
         
         input_options = { _t: { id: uuid, more: true, forks: [ 'upstream tag' ] } }
         
         it 'should return another options object', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options ).to.not.be input_options
         
         it 'should return an options object', ->
           expect( typeof( options ) ).to.be.eql 'object'
         
         it 'should have a distinct transaction object', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
           
           expect( options._t ).to.not.be input_options._t
         
         it 'should have the same uuid as input options', ->
           expect( options._t.id ).to.be uuid
         
         it 'should have more set to true', ->
           expect( options._t.more ).to.be true
         
         it 'should have a distinct forks Array', ->
           expect( options._t.forks ).to.be.an Array
           
           expect( options._t.forks ).to.not.be input_options._t.forks
         
         it 'should have two fork tags, with the new tag last', ->
           expect( options._t.forks ).to.be.eql [ 'upstream tag', 'a tag' ]
         
         it 'should have no other attributes', ->
           expect( options ).to.be.eql { _t: { id: uuid, more: true, forks: [ 'upstream tag', 'a tag' ] } }
       
       describe 'On an ending transaction with an upstream fork tag', ->
         uuid = uuid_v4()
         
         input_options = { _t: { id: uuid, forks: [ 'upstream tag' ] } }
         
         it 'should return another options object', ->
           options = add_fork_tag( input_options, 'a tag' )
           
           expect( options ).to.not.be input_options
         
         it 'should return an options object', ->
           expect( typeof( options ) ).to.be.eql 'object'
         
         it 'should have a distinct transaction object', ->
           expect( typeof( options._t ) ).to.be.eql 'object'
           
           expect( options._t ).to.not.be input_options._t
         
         it 'should have the same uuid as input options', ->
           expect( options._t.id ).to.be uuid
         
         it 'should have more set to true', ->
           expect( options._t.more ).to.be undefined
         
         it 'should have a distinct forks Array', ->
           expect( options._t.forks ).to.be.an Array
           
           expect( options._t.forks ).to.not.be input_options._t.forks
         
         it 'should have two fork tags, with the new tag last', ->
           expect( options._t.forks ).to.be.eql [ 'upstream tag', 'a tag' ]
         
         it 'should have no other attributes', ->
           expect( options ).to.be.eql { _t: { id: uuid, forks: [ 'upstream tag', 'a tag' ] } }
       
     # add_fork_tag( options, tag )
     
  describe 'RS.Transactions() and RS.Transaction()', ->
    start_count = Transaction.count
    
    describe 'Transaction with no options or pipelet', ->
      t = new Transaction 4
      
      options = undefined
      tid = undefined
      
      it 'should be a Transaction with a count of 4', ->
        expect( t ).to.be.a Transaction
        expect( t.source_options ).to.be undefined
        expect( t.options ).to.be undefined
        #expect( t.o.__t ).to.be t
        
      it 't.toJSON() should return a representation of the new transaction', ->
        expect( t.toJSON() ).to.be.eql {
          number        : start_count + 1
          name          : 'Transaction(  #' + ( start_count + 1 ) + ' )'
          tid           : undefined
          count         : 4
          source_more   : false
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'after t.next(), count should be 3', ->
        expect( t.next().toJSON() ).to.be.eql {
          number        : start_count + 1
          name          : 'Transaction(  #' + ( start_count + 1 ) + ' )'
          tid           : undefined
          count         : 3
          source_more   : false
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 't.emit_options() should provide "more" and a uuid v4 "transaction_id"', ->
        options = t.emit_options()
        _t = options._t
        tid = _t.id
        
        expect( tid ).to.match valid_uuid_v4
        
        expect( _t ).to.be.eql {
          more: true
          id: tid
        }
      
      it 'need_close should be true', ->
        expect( t.toJSON() ).to.be.eql {
          number        : start_count + 1
          name          : 'Transaction(  #' + ( start_count + 1 ) + ' )'
          tid           : tid
          count         : 3
          source_more   : false
          need_close    : true
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should continue to provide "more" and the same "transaction_id" after next_options()', ->
        expect( t.next_options() ).to.be     options
        expect( options          ).to.be.eql { _t: {
          id: tid
          more: true
        } }
      
      it 'should decrease count to 1 and set adds_length to 2 after t.add( [{}{}] )', ->
        expect( t.add( [{},{}] ).toJSON() ).to.be.eql {
          number        : start_count + 1
          name          : 'Transaction(  #' + ( start_count + 1 ) + ' )'
          tid           : tid
          count         : 1
          source_more   : false
          need_close    : true
          closed        : false
          adds_length   : 2
          updates_length: 0
          removes_length: 0
        }
      
      it 'should decrease count to zero and close the transaction and flush after t.remove( [{}] )', ->
        expect( t.remove( [{}] ).toJSON() ).to.be.eql {
          number        : start_count + 1
          name          : 'Transaction(  #' + ( start_count + 1 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : false
          need_close    : false
          closed        : true
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should throw an exception after 1 more t.next()', ->
        expect( () -> t.next() ).to.throwException()
    
    describe 'Transactions()..get_transaction() for four operations with pseudo pipelet, options with more', ->
      transactions = new Transactions()
      
      output = {
        _operations: []
        
        _get_name: -> 'output'
        
        emit : ( operation, values, options ) ->
          this._operations.push( slice.call( arguments, 0 ) )
          
          return this
      }
      
      tid = uuid_v4()
      
      options = { _t: { id: tid, more: true }, a: 1, b: [1,2] }
      
      no_more = clone options
      delete no_more._t.more
      
      t = transactions.get_transaction 4, options, output
      
      it 'should create a transaction with a count of 4, and a name', ->
        expect( t.get_tid()   ).to.be tid
        expect( t.is_closed() ).to.be false
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 4
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should set one transaction in transactions', ->
        expect( transactions.get_tids() ).to.be.eql [ tid ]
        expect( transactions.get( tid ) ).to.be t
        
      it 'should decrease count after t.emit_nothing()', ->
        t.emit_nothing()
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 3
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should decrease count after t.add( [] )', ->
        t.add( [] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 2
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
        
      it 'should decrease count and increse adds_length after t.add( [ { id: 1 } ] )', ->
        t.add( [ { id: 1 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 1
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 1
          updates_length: 0
          removes_length: 0
        }
        
      it 'should decrease count and need close after t.add( [ { id: 2 } ], true )', ->
        t.add( [ { id: 2 } ], true )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : true
          need_close    : true
          closed        : false
          adds_length   : 1
          updates_length: 0
          removes_length: 0
        }
      
      it 'should have emited an add operation to the pipelet', ->
        expect( output._operations ).to.be.eql [
          [ 'add', [ { id: 2 } ], options ]
        ]
      
      it 'should raise an exception on extra t.add( [ { id: 1 } ], true )', ->
        expect( -> t.add( [ { id: 3 } ], true ) ).to.throwException()
      
      it 'should still be not closed, have a count set to zero and adds_length to 1', ->
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : true
          need_close    : true
          closed        : false
          adds_length   : 1
          updates_length: 0
          removes_length: 0
        }
      
      it 'should not have removed the transaction from transactions', ->
        expect( transactions.get_tids() ).to.be.eql [ tid ]
      
      it 'should have emited one operation in total to the pipelet', ->
        expect( output._operations ).to.be.eql [
          [ 'add', [ { id: 2 } ], options ]
        ]
      
      it 'should return the same transaction after follow-up transactions.get_transaction() for 2 more operations', ->
        t1 = transactions.get_transaction 2, no_more, output
        
        expect( t1 ).to.be t
        
      it 'should have increased transaction\'s operations count by 2 and source_more should not be false', ->
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 2
          source_more   : false
          need_close    : true
          closed        : false
          adds_length   : 1
          updates_length: 0
          removes_length: 0
        }
      
      it 'should increase removes_length to 2 after t.remove( [ { id:1 }, { id: 2 } ] )', ->
        t.remove( [ { id:1 }, { id: 2 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 1
          source_more   : false
          need_close    : true
          closed        : false
          adds_length   : 1
          updates_length: 0
          removes_length: 2
        }
      
      it 'should close the transaction after t.add( [ { id:4 }, { id: 5 } ] )', ->
        t.add( [ { id: 4 }, { id: 5 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 2
          name          : 'Transaction( output #' + ( start_count + 2 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : false
          need_close    : false
          closed        : true
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should have emitted all operations', ->
        expect( output._operations ).to.be.eql [
          [ 'add'   , [ { id: 2 }                       ], options ]
          [ 'remove', [ { id: 1 }, { id: 2 }            ], options ]
          [ 'add'   , [ { id: 1 }, { id: 4 }, { id: 5 } ], no_more ]
        ]
      
      it 'should have removed the transaction from transactions', ->
        expect( transactions.get_tids() ).to.be.eql []
    
    describe 'Transactions()..get_transaction() with a fork tag', ->
      transactions = new Transactions()
      
      # Create pseudo output pipelet
      output = {
        _operations: []
        
        _get_name: -> 'output'
        
        emit : ( operation, values, options ) ->
          this._operations.push( slice.call( arguments, 0 ) )
          
          return this
      }
      
      tid = uuid_v4()
      
      options = { _t: { id: tid, more: true }, a: 1, b: [1,2] }
      
      options_with_tag = clone options
      options_with_tag._t.forks = [ 'fork_tag' ]
      
      options_with_tag_no_more = clone options_with_tag
      delete options_with_tag_no_more._t.more
      
      t = transactions.get_transaction 2, options, output, 'fork_tag'
      
      it 'should create a transaction with a count of 3, a name, and a fork tag', ->
        expect( t.get_tid()   ).to.be tid
        expect( t.is_closed() ).to.be false
        expect( t.fork        ).to.be 'fork_tag'
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 3
          name          : 'Transaction( output #' + ( start_count + 3 ) + ' )'
          tid           : tid
          count         : 2
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
      
      it 'should decrease count and increse adds_length after t.add( [ { id: 1 }, { id: 2 }  ] )', ->
        t.add( [ { id: 1 }, { id: 2 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 3
          name          : 'Transaction( output #' + ( start_count + 3 ) + ' )'
          tid           : tid
          count         : 1
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 2
          updates_length: 0
          removes_length: 0
        }
        
      it 'should decrease count and need close after t.add( [ { id: 3 } ] )', ->
        t.add( [ { id: 3 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 3
          name          : 'Transaction( output #' + ( start_count + 3 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : true
          need_close    : false
          closed        : false
          adds_length   : 3
          updates_length: 0
          removes_length: 0
        }
      
      it 'should have emited no add operation to the pipelet', ->
        expect( output._operations ).to.be.eql []
      
      it 'should return the same transaction after follow-up transactions.get_transaction() with no more', ->
        delete options._t.more
        
        orginal_options = clone options
        
        t1 = transactions.get_transaction 1, options, output
        
        expect( t1 ).to.be t
        
      it 'should have increased transaction\'s operations count by 1', ->
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 3
          name          : 'Transaction( output #' + ( start_count + 3 ) + ' )'
          tid           : tid
          count         : 1
          source_more   : false
          need_close    : true
          closed        : false
          adds_length   : 3
          updates_length: 0
          removes_length: 0
        }
      
      it 'should close the transaction after t.remove( [ { id:1 }, { id: 2 } ] )', ->
        t.remove( [ { id:1 }, { id: 2 } ] )
        
        expect( t.toJSON()    ).to.be.eql {
          number        : start_count + 3
          name          : 'Transaction( output #' + ( start_count + 3 ) + ' )'
          tid           : tid
          count         : 0
          source_more   : false
          need_close    : false
          closed        : true
          adds_length   : 0
          updates_length: 0
          removes_length: 0
        }
        
      it 'should have output two operations', ->
        expect( output._operations ).to.be.eql [
          [ 'remove', [ { id:1 }, { id: 2 } ], options_with_tag ]
          [ 'add', [ { id:1 }, { id: 2 }, { id: 3 } ], options_with_tag_no_more ]
        ]
    
    describe 'Input / Output Transactions()', ->
      describe 'I/O Transactions on a tagged input, with single tagged transaction', ->
        input    = new RS.Loggable 'input'
        
        input_transactions = input.transactions = new Input_Transactions( 'input', input )
        input_transactions.set_tag( 'source' )
        input_transactions.add_branches( 2 )
        
        output_1_transactions = new Output_Transactions 'output_1'
        output_2_transactions = new Output_Transactions 'output_2'
        
        returned_input = null
        input_transaction = null
        output_1_transaction = null
        output_2_transaction = null
        
        tid = uuid_v4()
        
        no_more_origin = {
          _t: {
            id: tid
            forks: [
              'source'
            ]
          }
        }
        
        no_more = clone no_more_origin
        no_more_out = clone no_more
        delete no_more_out._t.forks
        
        more_origin = clone no_more_origin
        more_origin._t.more = true
        more = clone more_origin
        more_out = clone more
        delete more_out._t.forks
        
        o = output_1_transactions.get_options input, more
        
        it 'output_1_transactions concurrent options should be returned with more and removed forks array', ->
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'should be an Input Transaction', ->
          input_transaction = input_transactions.get_from_tid tid
          
          expect( input_transaction ).to.be.a Input_Transaction
        
        it 'input_transactions should have input_transaction', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should have one output transaction', ->
          expect( input_transaction.count ).to.be 1
        
        it 'input_transaction should have output_1_transactions', ->  
          expect( input_transaction.get output_1_transactions ).to.be output_1_transactions
        
        it 'input_transaction should have no source terminated', ->
          expect( input_transaction.terminated_count ).to.be 0
        
        it 'input_transaction should be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
          
        it 'output_1_transactions should have one input', ->
          expect( output_1_transactions.count ).to.be 1
        
        it 'output_1_transaction retrieved with tid should be an Output_Transaction', ->
          output_1_transaction = output_1_transactions.get_from_tid tid
          
          expect( output_1_transaction ).to.be.a Output_Transaction
        
        it 'output_1_transactions should have output_1_transaction', ->
          expect( output_1_transactions.has output_1_transaction ).to.be output_1_transaction
        
        it 'output_1_transaction should have one counterpart', ->
          expect( output_1_transaction.count ).to.be 1
        
        it 'output_1_transaction should have input', ->
          expect( output_1_transaction.get input ).to.be input
        
        it 'concurrent options should have more even after sending no more, without forks', ->
          o = output_1_transactions.get_options input, no_more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'it should be the same input_transaction as earlier', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should now have one terminated source output', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should still be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
        
        it 'output_1_transactions should have zero inputs', ->
          expect( output_1_transactions.count ).to.be 0
        
        it 'output_1_transactions.get_from_tid( tid ) should now be undefined', ->
          expect( output_1_transactions.get_from_tid tid ).to.be undefined
        
        it 'output_2_transactions concurrent options (more) without forks', ->
          o = output_2_transactions.get_options input, more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should show ongoing progress of transaction from output_2_transactions', ->
          expect( input_transactions.count ).to.be 1
        
        it 'input transaction should still be input_transaction', ->
          expect( input_transactions.get_from_tid tid ).to.be input_transaction
        
        it 'should have one counterpart', ->
          expect( input_transaction.count ).to.be 1
        
        it 'should have one counterpart terminated', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should have a null reference to terminated output_1_transactions', ->
          expect( input_transaction.get output_1_transactions ).to.be null
        
        it 'should have output_2_transactions ongoing', ->
          expect( input_transaction.get output_2_transactions ).to.be output_2_transactions
        
        it 'output_2_transactions should have one input transactions', ->
          expect( output_2_transactions.count ).to.be 1
        
        it 'it should be found by tid and should be an Output_Transaction', ->
          output_2_transaction = output_2_transactions.get_from_tid tid
          
          expect( output_2_transaction ).to.be.a Output_Transaction
        
        it 'it should not be output_1_transaction', ->
          expect( output_2_transaction ).to.not.be.eql output_1_transaction
        
        it 'it should have one input transactions counterpart', ->
          expect( output_2_transaction.count ).to.be 1
        
        it 'this counterpart should be input', ->
          expect( output_2_transaction.get input ).to.be input
        
        it 'concurrent options for output_2_transactions should have no more after sending no more, and no forks', ->
          o = output_2_transactions.get_options input, no_more
          
          expect( o ).to.be.eql no_more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'output_2_transaction should now be empty', ->
          expect( output_2_transaction.count ).to.be 0
        
        it 'input_transactions should no longer hold any input transactions', ->
          expect( input_transactions.transactions ).to.be.eql {}
          expect( input_transactions.count ).to.be 0
        
        it 'output_2_transactions should have zero inputs', ->
          expect( output_2_transactions.count ).to.be 0
        
      describe 'I/O Transactions on a tagged input, with single tagged transaction with another tag', ->
        input    = new RS.Loggable 'input'
        
        input_transactions = input.transactions = new Input_Transactions( 'input', input )
        input_transactions.set_tag( 'source' )
        input_transactions.add_branches( 2 )
        
        output_1_transactions = new Output_Transactions 'output_1'
        output_2_transactions = new Output_Transactions 'output_2'
        
        input_transaction = null
        output_1_transaction = null
        output_2_transaction = null
        
        tid = uuid_v4()
        
        no_more_origin = {
          _t: {
            id: tid
            forks: [
              'other source'
            ]
          }
        }
        
        no_more = clone no_more_origin
        no_more_out = clone no_more
        
        more_origin = clone no_more_origin
        more_origin._t.more = true
        more = clone more_origin
        more_out = clone more
        
        o = output_1_transactions.get_options input, more
        
        it 'output_1_transactions concurrent options should be returned with more and removed forks array', ->
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'should be an Input_Transaction', ->
          input_transaction = input_transactions.get_from_tid tid
          
          expect( input_transaction ).to.be.a Input_Transaction
        
        it 'input_transactions should have input_transaction', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should have one output transaction', ->
          expect( input_transaction.count ).to.be 1
        
        it 'input_transaction should have output_1_transactions', ->  
          expect( input_transaction.get output_1_transactions ).to.be output_1_transactions
        
        it 'input_transaction should have no source terminated', ->
          expect( input_transaction.terminated_count ).to.be 0
        
        it 'input_transaction should be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
          
        it 'output_1_transactions should have one input', ->
          expect( output_1_transactions.count ).to.be 1
        
        it 'output_1_transaction retrieved with tid should be an Output_Transaction', ->
          output_1_transaction = output_1_transactions.get_from_tid tid
          
          expect( output_1_transaction ).to.be.a Output_Transaction
        
        it 'output_1_transactions should have output_1_transaction', ->
          expect( output_1_transactions.has output_1_transaction ).to.be output_1_transaction
        
        it 'output_1_transaction should have one counterpart', ->
          expect( output_1_transaction.count ).to.be 1
        
        it 'output_1_transaction should have input', ->
          expect( output_1_transaction.get input ).to.be input
        
        it 'concurrent options should have more even after sending no more, without forks', ->
          o = output_1_transactions.get_options input, no_more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'it should be the same input_transaction as earlier', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should now have one terminated source output', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should still be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
        
        it 'output_1_transactions should have zero inputs', ->
          expect( output_1_transactions.count ).to.be 0
        
        it 'output_1_transactions.get_from_tid( tid ) should now be undefined', ->
          expect( output_1_transactions.get_from_tid tid ).to.be undefined
        
        it 'output_2_transactions concurrent options (more) without forks', ->
          o = output_2_transactions.get_options input, more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should show ongoing progress of transaction from output_2_transactions', ->
          expect( input_transactions.count ).to.be 1
        
        it 'input transaction should still be input_transaction', ->
          expect( input_transactions.get_from_tid tid ).to.be input_transaction
        
        it 'should have one counterpart', ->
          expect( input_transaction.count ).to.be 1
        
        it 'should have one counterpart terminated', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should have a null reference to terminated output_1_transactions', ->
          expect( input_transaction.get output_1_transactions ).to.be null
        
        it 'should have output_2_transactions ongoing', ->
          expect( input_transaction.get output_2_transactions ).to.be output_2_transactions
        
        it 'output_2_transactions should have one input transactions', ->
          expect( output_2_transactions.count ).to.be 1
        
        it 'it should be found by tid and should be an Output_Transaction', ->
          output_2_transaction = output_2_transactions.get_from_tid tid
          
          expect( output_2_transaction ).to.be.a Output_Transaction
        
        it 'it should not be output_1_transaction', ->
          expect( output_2_transaction ).to.not.be.eql output_1_transaction
        
        it 'it should have one input transactions counterpart', ->
          expect( output_2_transaction.count ).to.be 1
        
        it 'this counterpart should be input', ->
          expect( output_2_transaction.get input ).to.be input
        
        it 'concurrent options for output_2_transactions should have no more after sending no more, and no forks', ->
          o = output_2_transactions.get_options input, no_more
          
          expect( o ).to.be.eql no_more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'output_2_transaction should now be empty', ->
          expect( output_2_transaction.count ).to.be 0
        
        it 'input_transactions should no longer hold any input transactions', ->
          expect( input_transactions.transactions ).to.be.eql {}
          expect( input_transactions.count ).to.be 0
        
        it 'output_2_transactions should have zero inputs', ->
          expect( output_2_transactions.count ).to.be 0
        
      describe 'I/O Transactions on a non-tagged input, with single tagged transaction with a tag', ->
        input    = new RS.Loggable 'input'
        
        input_transactions = input.transactions = new Input_Transactions( 'input', input )
        input_transactions.add_branches( 2 )
        
        output_1_transactions = new Output_Transactions 'output_1'
        output_2_transactions = new Output_Transactions 'output_2'
        
        input_transaction = null
        output_1_transaction = null
        output_2_transaction = null
        
        tid = uuid_v4()
        
        no_more_origin = {
          _t: {
            id: tid
            forks: [
              'source'
            ]
          }
        }
        
        no_more = clone no_more_origin
        no_more_out = clone no_more
        
        more_origin = clone no_more_origin
        more_origin._t.more = true
        more = clone more_origin
        more_out = clone more
        
        o = output_1_transactions.get_options input, more
        
        it 'output_1_transactions concurrent options should be returned with more and removed forks array', ->
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'should be an Input_Transaction', ->
          input_transaction = input_transactions.get_from_tid tid
          
          expect( input_transaction ).to.be.a Input_Transaction
        
        it 'input_transactions should have input_transaction', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should have one output transaction', ->
          expect( input_transaction.count ).to.be 1
        
        it 'input_transaction should have output_1_transactions', ->  
          expect( input_transaction.get output_1_transactions ).to.be output_1_transactions
        
        it 'input_transaction should have no source terminated', ->
          expect( input_transaction.terminated_count ).to.be 0
        
        it 'input_transaction should be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
          
        it 'output_1_transactions should have one input', ->
          expect( output_1_transactions.count ).to.be 1
        
        it 'output_1_transaction retrieved with tid should be an Output_Transaction', ->
          output_1_transaction = output_1_transactions.get_from_tid tid
          
          expect( output_1_transaction ).to.be.a Output_Transaction
        
        it 'output_1_transactions should have output_1_transaction', ->
          expect( output_1_transactions.has output_1_transaction ).to.be output_1_transaction
        
        it 'output_1_transaction should have one counterpart', ->
          expect( output_1_transaction.count ).to.be 1
        
        it 'output_1_transaction should have input', ->
          expect( output_1_transaction.get input ).to.be input
        
        it 'concurrent options should have more even after sending no more, without forks', ->
          o = output_1_transactions.get_options input, no_more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'it should be the same input_transaction as earlier', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should now have one terminated source output', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should still be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
        
        it 'output_1_transactions should have zero inputs', ->
          expect( output_1_transactions.count ).to.be 0
        
        it 'output_1_transactions.get_from_tid( tid ) should now be undefined', ->
          expect( output_1_transactions.get_from_tid tid ).to.be undefined
        
        it 'output_2_transactions concurrent options (more) without forks', ->
          o = output_2_transactions.get_options input, more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should show ongoing progress of transaction from output_2_transactions', ->
          expect( input_transactions.count ).to.be 1
        
        it 'input transaction should still be input_transaction', ->
          expect( input_transactions.get_from_tid tid ).to.be input_transaction
        
        it 'should have one counterpart', ->
          expect( input_transaction.count ).to.be 1
        
        it 'should have one counterpart terminated', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should have a null reference to terminated output_1_transactions', ->
          expect( input_transaction.get output_1_transactions ).to.be null
        
        it 'should have output_2_transactions ongoing', ->
          expect( input_transaction.get output_2_transactions ).to.be output_2_transactions
        
        it 'output_2_transactions should have one input transactions', ->
          expect( output_2_transactions.count ).to.be 1
        
        it 'it should be found by tid and should be an Output_Transaction', ->
          output_2_transaction = output_2_transactions.get_from_tid tid
          
          expect( output_2_transaction ).to.be.a Output_Transaction
        
        it 'it should not be output_1_transaction', ->
          expect( output_2_transaction ).to.not.be.eql output_1_transaction
        
        it 'it should have one input transactions counterpart', ->
          expect( output_2_transaction.count ).to.be 1
        
        it 'this counterpart should be input', ->
          expect( output_2_transaction.get input ).to.be input
        
        it 'concurrent options for output_2_transactions should have no more after sending no more, and no forks', ->
          o = output_2_transactions.get_options input, no_more
          
          expect( o ).to.be.eql no_more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'output_2_transaction should now be empty', ->
          expect( output_2_transaction.count ).to.be 0
        
        it 'input_transactions should no longer hold any input transactions', ->
          expect( input_transactions.transactions ).to.be.eql {}
          expect( input_transactions.count ).to.be 0
        
        it 'output_2_transactions should have zero inputs', ->
          expect( output_2_transactions.count ).to.be 0
        
      describe 'I/O Transactions on a tagged input, with nested tagged transaction', ->
        input    = new RS.Loggable 'input'
        
        input_transactions = input.transactions = new Input_Transactions( 'input', input )
        input_transactions.set_tag( 'source' )
        input_transactions.add_branches( 2 )
        
        output_1_transactions = new Output_Transactions 'output_1'
        output_2_transactions = new Output_Transactions 'output_2'
        
        input_transaction = null
        output_1_transaction = null
        output_2_transaction = null
        
        tid = uuid_v4()
        
        no_more_origin = {
          _t: {
            id: tid
            forks: [
              'top'
              'source'
            ]
          }
        }
        
        no_more = clone no_more_origin
        no_more_out = clone no_more
        no_more_out._t.forks = [ 'top' ]
        
        more_origin = clone no_more_origin
        more_origin._t.more = true
        more = clone more_origin
        more_out = clone more
        more_out._t.forks = [ 'top' ]
        
        o = output_1_transactions.get_options input, more
        
        it 'output_1_transactions concurrent options should be returned with more and removed last fork tag', ->
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'should be an Input_Transaction', ->
          input_transaction = input_transactions.get_from_tid tid
          
          expect( input_transaction ).to.be.a Input_Transaction
        
        it 'input_transactions should have input_transaction', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should have one output transaction', ->
          expect( input_transaction.count ).to.be 1
        
        it 'input_transaction should have output_1_transactions', ->  
          expect( input_transaction.get output_1_transactions ).to.be output_1_transactions
        
        it 'input_transaction should have no source terminated', ->
          expect( input_transaction.terminated_count ).to.be 0
        
        it 'input_transaction should be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
          
        it 'output_1_transactions should have one input', ->
          expect( output_1_transactions.count ).to.be 1
        
        it 'output_1_transaction retrieved with tid should be an Output_Transaction', ->
          output_1_transaction = output_1_transactions.get_from_tid tid
          
          expect( output_1_transaction ).to.be.a Output_Transaction
        
        it 'output_1_transactions should have output_1_transaction', ->
          expect( output_1_transactions.has output_1_transaction ).to.be output_1_transaction
        
        it 'output_1_transaction should have one counterpart', ->
          expect( output_1_transaction.count ).to.be 1
        
        it 'output_1_transaction should have input', ->
          expect( output_1_transaction.get input ).to.be input
        
        it 'concurrent options should have more even after sending no more, without the last fork tag', ->
          o = output_1_transactions.get_options input, no_more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'input transactions should have one transaction waiting for another output to terminate', ->
          expect( input_transactions.count ).to.be 1
        
        it 'it should be the same input_transaction as earlier', ->
          expect( input_transactions.has input_transaction ).to.be input_transaction
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should still have no more source counterpart', ->
          expect( input_transaction.count ).to.be 0
        
        it 'input_transaction should now have one terminated source output', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should still be concurrent', ->
          expect( input_transaction.concurrent ).to.be true
        
        it 'output_1_transactions should have zero inputs', ->
          expect( output_1_transactions.count ).to.be 0
        
        it 'output_1_transactions.get_from_tid( tid ) should now be undefined', ->
          expect( output_1_transactions.get_from_tid tid ).to.be undefined
        
        it 'output_2_transactions concurrent options (more) should have removed last fork', ->
          o = output_2_transactions.get_options input, more
          
          expect( o ).to.be.eql more_out
        
        it 'should not have altered input options', ->
          expect( more ).to.eql more_origin
        
        it 'input transactions should show ongoing progress of transaction from output_2_transactions', ->
          expect( input_transactions.count ).to.be 1
        
        it 'input transaction should still be input_transaction', ->
          expect( input_transactions.get_from_tid tid ).to.be input_transaction
        
        it 'should have one counterpart', ->
          expect( input_transaction.count ).to.be 1
        
        it 'should have one counterpart terminated', ->
          expect( input_transaction.terminated_count ).to.be 1
        
        it 'should have a null reference to terminated output_1_transactions', ->
          expect( input_transaction.get output_1_transactions ).to.be null
        
        it 'should have output_2_transactions ongoing', ->
          expect( input_transaction.get output_2_transactions ).to.be output_2_transactions
        
        it 'output_2_transactions should have one input transactions', ->
          expect( output_2_transactions.count ).to.be 1
        
        it 'it should be found by tid and should be an Output_Transaction', ->
          output_2_transaction = output_2_transactions.get_from_tid tid
          
          expect( output_2_transaction ).to.be.a Output_Transaction
        
        it 'it should not be output_1_transaction', ->
          expect( output_2_transaction ).to.not.be.eql output_1_transaction
        
        it 'it should have one input transactions counterpart', ->
          expect( output_2_transaction.count ).to.be 1
        
        it 'this counterpart should be input', ->
          expect( output_2_transaction.get input ).to.be input
        
        it 'concurrent options for output_2_transactions should have no more after sending no more, and removed last fork tag', ->
          o = output_2_transactions.get_options input, no_more
          
          expect( o ).to.be.eql no_more_out
        
        it 'should not have altered input options', ->
          expect( no_more ).to.eql no_more_origin
        
        it 'output_2_transaction should now be empty', ->
          expect( output_2_transaction.count ).to.be 0
        
        it 'input_transactions should no longer hold any input transactions', ->
          expect( input_transactions.transactions ).to.be.eql {}
          expect( input_transactions.count ).to.be 0
        
        it 'output_2_transactions should have zero inputs', ->
          expect( output_2_transactions.count ).to.be 0
        
      describe 'I/O Transactions with no fork or tag', ->
        input    = new RS.Loggable 'input'
        
        input_transactions = input.transactions = new Input_Transactions( 'input', input )
        input_transactions.set_tag( 'source' )
        input_transactions.add_branches( 2 )
        
        output_1_transactions = new Output_Transactions 'output_1'
        output_2_transactions = new Output_Transactions 'output_2'
        
        input_transaction = null
        output_1_transaction = null
        output_2_transaction = null
        
        tid = uuid_v4()
        
        no_more_origin = { _t: { id: tid } }
        no_more = clone no_more_origin
        
        more_origin = clone no_more
        more_origin._t.more = true
        more = clone more_origin
        
        o = output_1_transactions.get_options input, more
        
        it 'get_options( input, input_transactions, more ) should return more', ->
          expect( o ).to.be more
          expect( more ).to.be.eql more_origin
        
        it 'output_1_transactions should have one output transaction', ->
          expect( output_1_transactions.count ).to.be 1

        it 'this output transaction should be an Output_Transaction', ->
          output_1_transaction = output_1_transactions.get_from_tid tid
          
          expect( output_1_transaction ).to.be.a Output_Transaction
        
        it 'should have one input transactions countrerpart', ->
          expect( output_1_transaction.count ).to.be 1
        
        it 'should have input as a counterpart', ->
          expect( output_1_transaction.get input ).to.be input
        
        it 'input_transactions should have one input transaction', ->
          expect( input_transactions.count ).to.be 1
          
        it 'should be an Input_Transaction', ->
          input_transaction = input_transactions.get_from_tid tid
          
          expect( input_transaction ).to.be.a Input_Transaction
        
        it 'should have output_1_transactions as a counterpart', ->
          expect( input_transaction.get output_1_transactions ).to.be output_1_transactions
        
        it 'output_1_transactions.terminate( no_more ) should return list of terminated destination with transaction object', ->
          expect( output_1_transactions.terminate( no_more._t ) ).to.be.eql [ { _t: no_more._t, input: input } ]
          expect( no_more ).to.be.eql no_more_origin
        
        it 'output_1_transactions should have no output transactions', ->
          expect( output_1_transactions.count ).to.be 0
        
        it 'input_transactions should have no input transactions', ->
          expect( input_transactions.count ).to.be 0
        
        
  # RS.Transactions() and RS.Transaction()
