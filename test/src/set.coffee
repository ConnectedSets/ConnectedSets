###
    set.coffee

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

de = false

utils  = require( './tests_utils.js' ) unless this.expect

expect = this.expect || utils.expect
check  = this.check  || utils.check
rs     = this.rs     || utils.rs
RS     = rs.RS
Set    = RS.Set

# ----------------------------------------------------------------------------------------------
# set test suite
# --------------

describe 'set():', ->
  set = rs.set();
  
  it 'set should be a Set', ->
    expect( set ).to.be.a Set
  
  it 'should allow to initialize a set with an Object not instance of Array', ->
    expect( rs.set( { id: 42 } ).a ).to.be.eql [ { id: 42 } ]
  
  it 'should allow to initialize a set with a single scalar', ->
    expect( rs.set( 42 ).a ).to.be.eql [ { id: 42 } ]
  
  cities = rs.set [
    { id: 1, name: "Marrakech"    , country: "Morocco"                      }
    { id: 2, name: "Mountain View", country: "USA"    , state: "California" }
    { id: 3, name: "Paris"        , country: "France"                       }
  ]
  
  delayed_set = rs
    .set( [ { id:1, value: 'delayed' } ] )
    .delay( 100 )
    .debug( de, 'Delayed Set' )
    .filter( () -> true )
  
  cars = rs
    .set( [
          { id: 1, brand: "Mercedes", model: "C Class" }
          { id: 2, brand: "Mercedes", model: "S Class" }
          { id: 3, brand: "BMW"     , model: "M Serie" }
          { flow: 'error', error: 'not found' }
        ]
        { key: [ "id", "model" ] }
    )
    .set_flow( 'car' )
    .set()
  
  employee = rs.set [
    { id:  1, name: "Stephen C. Cox" , salary: "$3000", customer_id: "222", order_id: "1222" }
    { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
    { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
    { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
    { id:  5, name: "Alex Frog"      , salary: "$3000", customer_id: "226", order_id: "1226" }
    { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
  ]
  
  describe 'delayed set (100 ms)', ->
    it 'should eventually equal its source values', ( done ) ->
      delayed_set._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { id:1, value: 'delayed' }
      ]
  
  describe '_fetch_all():', ->
    it 'set._fetch_all() should be empty', ( done ) ->
      set._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql []
    
    it 'cars._fetch_all() should be equal to result', ( done ) ->
      cars._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { flow: "car", id: 1, brand: "Mercedes", model: "C Class" }
        { flow: "car", id: 2, brand: "Mercedes", model: "S Class" }
        { flow: "car", id: 3, brand: "BMW"     , model: "M Serie" }
        { flow: 'error', error: 'not found' }
      ]
  
  describe 'fetch (using fetch_unfiltered) with query', ->
    it 'should emit one city when query is { country: "France" }', ( done ) ->
      rx = ( values ) -> check done, ->
        expect( values ).to.be.eql [
          { id: 3, name: "Paris"        , country: "France"                       }
        ]
      
      cities._output._fetch rx, [ { country: "France" } ]
  
  describe 'nul query fetch (using fetch_unfiltered)', ->
    it 'should emit no cities', ( done ) ->
      rx = ( values ) -> check done, -> expect( values ).to.be.eql []
      
      cities._output._fetch rx, []
  
  describe 'add():', ->
    it 'should contain Berlin after adding it', ( done ) ->
      cities._add [ { id: 4, name: "Berlin", country: "Germany" } ]
      
      cities._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { id: 1, name: "Marrakech"    , country: "Morocco"                      }
        { id: 2, name: "Mountain View", country: "USA"    , state: "California" }
        { id: 3, name: "Paris"        , country: "France"                       }
        { id: 4, name: "Berlin"       , country: "Germany"                      }
      ]
  
  describe '_a_index_of():', ->
    it 'set._a_index_of( { id: 2 } ) should be -1: empty set', ->
      expect( set._a_index_of( { id: 2 } ) ).to.be.eql -1
    
    it 'cities._a_index_of( { id: 2 } ) should be 1', ->
      expect( cities._a_index_of( { id: 2 } ) ).to.be.eql 1
    
    it 'cars._a_index_of( { id: 2, model: "S Class" } ) should be 1', ->
      expect( cars._a_index_of( { id: 2, model: "S Class" } ) ).to.be.eql 1
    
    it 'cars._a_index_of( { id: 3, model: "S Class" } ) should be -1: not found', ->
      expect( cars._a_index_of( { id: 3, model: "S Class" } ) ).to.be.eql -1
  
  describe 'remove():', ->
    it 'set._remove( [ { id: 1 } ] )._add( [ { id: 2 } ] ) should have id 2', ( done ) ->
      set._remove [ { id: 1 } ]
      set._add [ { id: 2 } ]
      
      set._fetch_all ( values ) ->
        check done, ->
          expect( values ).to.be.eql [ { id: 2 } ]
    
    it 'should have an one value in the anti-state', ->
      expect( set.b ).to.be.eql [ { id: 1 } ]
    
    it 'adding back this element should not change the set', ( done ) ->
      set._add [ { id: 1 } ]
      
      set._fetch_all ( values ) ->
        check done, ->
          expect( values ).to.be.eql [ { id: 2 } ]
    
    it 'anti-state should be empty again', ->
      expect( set.b ).to.be.eql []
      
    it 'removing id 2 should left set empty again', ( done ) ->
      set._remove [ { id: 2 } ]
      
      set._fetch_all ( values ) ->
        check done, ->
          expect( values ).to.be.eql []
    
    it 'employee._remove( [ { id: 15 } ] ) should be equal to employee: record with id 15 doesn\'t exist', ( done ) ->
      employee._remove( [ { id: 15 } ] )
      
      employee._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { id:  1, name: "Stephen C. Cox" , salary: "$3000", customer_id: "222", order_id: "1222" }
        { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
        { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
        { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
        { id:  5, name: "Alex Frog"      , salary: "$3000", customer_id: "226", order_id: "1226" }
        { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
      ]
    
    it 'employee._remove( [ { id: 1 } ] ) should be equal to result: first record', ( done ) ->
      employee._remove( [ { id: 1 } ] )
      
      employee._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
        { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
        { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
        { id:  5, name: "Alex Frog"      , salary: "$3000", customer_id: "226", order_id: "1226" }
        { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
      ]

    it 'employee._remove( [ { id: 5 } ] ) should be equal to result: record in the middle', ( done ) ->
      employee._remove( [ { id: 5 } ] )
      
      employee._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql [
        { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
        { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
        { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
        { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
      ]
    
    it 'employee._remove( [ { id: 6 } ] ) should be equal to result: last record', ( done ) ->
      employee._remove [ { id: 6 } ]
      
      employee._fetch_all ( values ) -> check done, ->
          expect( values.sort ( a, b ) -> a.id > b.id ).to.be.eql [
            { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
            { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
            { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
          ]
  
  describe '_update():', ->
    it 'set._update( [ [ { id: 1 }, { id: 1, v: "test" } ] ] ) should be equal to set: empty set', ( done ) ->
      set._update [ [ { id: 1 }, { id: 1, v: 'test' } ] ]
      
      set._fetch_all ( values ) -> check done, -> expect( values ).to.be.eql []
    
    it 'employee with add, _update and remove inverted should end with update done', ( done ) ->
      employee._remove [ { id: 15, name: "Khalifa P Nassik", salary: "$2500" } ]
      
      employee._update [
        [
          { id: 15, name: "Khalifa P Nassik", salary: "$1500" }
          { id: 15, name: "Khalifa P Nassik", salary: "$2500" }
        ]
      ]
      
      employee._add [ { id: 15, name: "Khalifa P Nassik", salary: "$1500" } ]
      
      employee._fetch_all ( values ) -> check done, ->
          expect( values.sort ( a, b ) -> a.id > b.id ).to.be.eql [
            { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
            { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
            { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
          ]
    
    it 'employee._update( [ [ { id: 3 }, { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" ] ] } ) should be equal to result', ( done ) ->
      employee._update( [ [ { id: 3 }, { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" } ] ] )

      employee._fetch_all ( values ) -> check done, ->
        expect( values.sort ( a, b ) -> a.id > b.id ).to.be.eql [
          { id: 2, name: "Josephin Tan"    , salary: "$1500", customer_id: "223", order_id: "1223" }
          { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" }
          { id: 4, name: "James A. Pentel" , salary: "$1750", customer_id: "225", order_id: "1225" }
        ]
