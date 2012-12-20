# ----------------------------------------------------------------------------------------------
# deep clone of object
# --------------------

clone = ( o ) ->
  return o if typeof o isnt 'object' or o is null

  r = if o instanceof Array then [] else {}

  r[ p ] = clone o[ p ] for p of o when o.hasOwnProperty p

  return r


describe 'clone():', ->
  foo =
    id: 10
    array: [ 1, 2, "a", "b", 3, { x: 10, y: undefined, z: null } ]
    obj:
      coordinate: 1
      label: "Coordinate"
      values: [ 24, null, undefined ]

  bar = clone foo

  it 'foo should be deep equal to bar', ->
    bar.should.be.eql foo

# ----------------------------------------------------------------------------------------------
# xs unit test suite
# ------------------

# include modules
XS = if require? then ( require '../src/xs.js' ).XS else this.XS 

chai = require 'chai' if require?
chai?.should()

describe 'XS test suite:', ->
  it 'XS should be defined:', ->
    XS.should.exist
  
  describe 'XS.extend():', ->
    extend = XS.extend
    
    it 'extend() should be a function', ->
      extend.should.be.a 'function'
    
    o1 = 
      id: 1
      name: 'khalifa'
    
    o2 = 
      email: 'knassik@gmail.com'
    
    _o2 = clone o2
    
    o3 =
      country: 'Morocco'
      name: 'khalifa nassik'
      email: 'khalifan@gmail.com'

    _o3 = clone o3
    
    it 'extend( object ) should be equal to object', ->
      result = extend o1
      
      result.should.be.eql o1
    
    it 'extend( object1, object2 ) should be equal to object', ->
      result = extend o1, o2
      
      result.should.be.eql { id: 1, name: 'khalifa', email: 'knassik@gmail.com' }
    
    it 'o2 should be deep equal to _o2', ->
      o2.should.be.eql _o2
    
    it 'extend( object1, object2, object3 ) should be equal to object', ->
      result = extend o1, o2, o3
      
      result.should.be.eql { id: 1, name: 'khalifa nassik', email: 'khalifan@gmail.com', country: 'Morocco' }
     
    it 'o2 should be deep equal to _o2', ->
       o2.should.be.eql _o2
    
    it 'o3 should be deep equal to _o3', ->
      o3.should.be.eql _o3
    
  describe 'XS.subclass():', ->
    subclass = XS.subclass
    
    it 'subclass() should be a function', ->
      subclass.should.be.a 'function'
    
    Animal = ( name ) -> @name = name
    
    a = new Animal 'Sam'
    
    it 'a should be an instance of Animal', ->
      a.should.be.an.instanceof Animal
      
    Snake = ( name ) ->
    
    subclass( Animal, Snake );
    
    s = new Snake( "Barry the Snake" )
    
    it 's should be an instance of Snake', ->
      s.should.be.an.instanceof Snake
    
    it 's should be an instance of Animal', ->
      s.should.be.an.instanceof Animal
    
    it 'a should not be an instance of Snake', ->
      a.should.not.be.an.instanceof Snake
    
  describe 'XS.Code():', ->
    code = new XS.Code( 'Code Test' )
      .function( null, 'f', [] )
        .add( 'var i' )
        .loop( 'i = -1', ' ++i < 10' )
        .end()
        .add( 'return i' )
      .end()
      .get()
    
    eval code
    
    i = f()
    
    it 'f should be a function', ->
      f.should.be.a 'function'
    
    it 'i should be equal to 10', ->
      i.should.be.eql 10
    
    test = 'a[ ++i ] === n'
    
    code = new XS.Code( 'Test unfolded while' )
      .function( 'g = ', null, [ 'n' ] )
        .vars( [ 'a = [ 34, 65, 98, 8, 52, 10, 21, 13, 1, 90, 14 ]', 'l = a.length', 'i = -1' ] )
        .unfolded_while( 'if ( ' + test, '|| ' + test, ') return i' )
        .add( 'return -1' )
      .end( '' )
      .get()
    ;
    
    eval code
    
    it 'the index of 34 should be 0', ->
      g( 34 ).should.be.eql 0
  
    it 'the index of 52 should be 4', ->
      g( 52 ).should.be.eql 4
  
    it 'the index of 90 should be 9', ->
      g( 90 ).should.be.eql 9
  
    it 'the index of 1 should be 8', ->
      g( 1 ).should.be.eql 8
  
  describe 'XS.Set():', ->
    Set = XS.Set
    
    set = new Set []
    
    it 'set should be a Set', ->
      set.should.be.an.instanceof Set
    
    cities = new Set [
      { id: 1, name: "Marrakech", country: "Morocco"  }
      { id: 2, name: "Mountain View", country: "USA", state: "California" }
      { id: 3, name: "Paris", country: "France" }
    ]
    
    cars = new Set [
          { id: 1, brand: "Mercedes", model: "C Class" }
          { id: 2, brand: "Mercedes", model: "S Class" }
          { id: 3, brand: "BMW"     , model: "M Serie" }
        ]
      , { key: [ "id", "model" ] }
    
    employee = new XS.Set [
      { id:  1, name: "Stephen C. Cox" , salary: "$3000", customer_id: "222", order_id: "1222" }
      { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
      { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
      { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
      { id:  5, name: "Alex Frog"      , salary: "$3000", customer_id: "226", order_id: "1226" }
      { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
    ]
    
    describe 'get():', ->
      it 'set.get() should be empty', ->
        set.get().should.be.eql []
      
      it 'cars.get() should be equal to result', ->
        result = [
          { id: 1, brand: "Mercedes", model: "C Class" }
          { id: 2, brand: "Mercedes", model: "S Class" }
          { id: 3, brand: "BMW"     , model: "M Serie" }
        ]
        
        cars.get().should.be.eql result
    
    describe 'add():', ->
      cities.add [ { id: 4, name: "Berlin", country: "Germany" } ]
      
      it 'cities.add( object ) should be a Set', ->
        cities.should.be.an.instanceof Set
      
      result = new Set [
        { id: 1, name: "Marrakech", country: "Morocco"  }
        { id: 2, name: "Mountain View", country: "USA", state: "California" }
        { id: 3, name: "Paris", country: "France" }
        { id: 4, name: "Berlin", country: "Germany" }
      ]
      
      it 'cities.add( object ) should be equal to result', ->
        cities.get().should.be.eql result.get()
    
    describe 'index_of():', ->
      it 'set.index_of( { id: 2 } ) should be -1: empty set', ->
        set.index_of( { id: 2 } ).should.be.eql -1
      
      it 'cities.index_of( { id: 2 } ) should be 1', ->
        cities.index_of( { id: 2 } ).should.be.eql 1
      
      it 'cars.index_of( { id: 2, model: "S Class" } ) should be 1', ->
        cars.index_of( { id: 2, model: "S Class" } ).should.be.eql 1
      
      it 'cars.index_of( { id: 3, model: "S Class" } ) should be -1: not found', ->
        cars.index_of( { id: 3, model: "S Class" } ).should.be.eql -1
    
    describe 'remove():', ->
      it 'set.remove( [ { id: 1 } ] ) should be equal to set: empty set', ->
        set.remove( [ { id: 1 } ] ).get().should.be.eql set.get()
      
      it 'employee.remove( [ { id: 15 } ] ) should be equal to employee: record with id 15 doesn\'t exist', ->
        employee.remove( [ { id: 15 } ] )
        
        employee.get().should.be.equal employee.get()
      
      it 'employee.remove( [ { id: 1 } ] ) should be equal to result: first record', ->
        result = new Set [
          { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
          { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
          { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
          { id:  5, name: "Alex Frog"      , salary: "$3000", customer_id: "226", order_id: "1226" }
          { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
        ]
        
        employee.remove( [ { id: 1 } ] )
        
        employee.get().should.be.eql result.get()

      it 'employee.remove( [ { id: 5 } ] ) should be equal to result: record in the middle', ->
        result = new Set [
          { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
          { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
          { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
          { id:  6, name: "Tim Hancook"    , salary: "$1500", customer_id: "227", order_id: "1227" }
        ]
        
        employee.remove( [ { id: 5 } ] )
        
        employee.get().should.be.eql result.get()
      
      it 'employee.remove( [ { id: 6 } ] ) should be equal to result: last record', ->
        result = new Set [
          { id:  2, name: "Josephin Tan"   , salary: "$1500", customer_id: "223", order_id: "1223" }
          { id:  3, name: "Joyce Ming"     , salary: "$2000", customer_id: "224", order_id: "1224" }
          { id:  4, name: "James A. Pentel", salary: "$1750", customer_id: "225", order_id: "1225" }
        ]
        
        employee.remove( [ { id: 6 } ] )
        
        employee.get().should.be.eql result.get()
    
    describe 'update():', ->
      it 'set.update( [ [ { id: 1 } ] ] ) should be equal to set: empty set', ->
        set.update( [ [ { id: 1 } ] ] ).get().should.be.eql set.get()
      
      it 'employee.update( [ [ { id: 15, name: "Khalifa P Nassik", Salary: "$1500" } ] ] ) should be equal to employee: record with id 15 doesn\'t exist', ->
        employee.update( [ [ { id: 15, name: "Khalifa P Nassik", Salary: "$1500" } ] ] )
	
        employee.get().should.be.equal employee.get()
      
      it 'employee.update( [ [ { id: 3 }, { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" ] ] } ) should be equal to result', ->
        result = new Set [
          { id: 2, name: "Josephin Tan"    , salary: "$1500", customer_id: "223", order_id: "1223" }
          { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" }
          { id: 4, name: "James A. Pentel" , salary: "$1750", customer_id: "225", order_id: "1225" }
        ]

        employee.update( [ [ { id: 3 }, { id: 3, name: "Khalifa P Nassik", Salary: "$1500", customer_id: "224", order_id: "1224" } ] ] )

        employee.get().should.be.eql result.get()
    
    describe 'filter():', ->
      is_in_usa = ( o ) ->
        return o.country is 'USA'
      
      cities_in_usa = cities.filter is_in_usa
      
      it 'cities_in_usa should be a Set', ->
        cities_in_usa.should.be.an.instanceof Set
      
      it 'cities_in_usa should only contain cities in USA', ->
        cities_in_usa.get().should.be.eql [ { id: 2, name: "Mountain View", country: "USA", state: "California" } ]
      
      describe 'add():', ->
        it 'cities_in_usa should be equal to result: cities.add( [ { id: 5, name: "New York", country: "USA", state: "New York" } ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "New York", country: "USA", state: "New York" }
          ]

          cities.add [ { id: 5, name: "New York", country: "USA", state: "New York" } ]

          cities_in_usa.get().should.be.eql result
        
        it 'cities_in_usa should be equal to result: cities.add( [ { id: 6, name: "Casablanca", country: "Morocco" }, { id: 7, name: "Housten", country: "USA", state: "Texas" } ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "New York", country: "USA", state: "New York" }
            { id: 7, name: "Housten", country: "USA", state: "Texas" }
          ]

          cities.add [ { id: 6, name: "Casablanca", country: "Morocco" }, { id: 7, name: 'Housten', country: 'USA', state: 'Texas' } ]
          
          cities_in_usa.get().should.be.eql result
      
      describe 'update', ->
        it 'cities_in_usa should be equal to result: cities.update( [ [ { id: 5 }, { id: 5, name: "NY", country: "USA", state: "NY" } ] ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "NY", country: "USA", state: "NY" }
            { id: 7, name: "Housten", country: "USA", state: "Texas" }
          ]

          cities.update [ [ { id: 5, name: "New York", country: "USA", state: "New York" }, { id: 5, name: "NY", country: "USA", state: "NY" } ] ]

          cities_in_usa.get().should.be.eql result
        
        it 'cities_in_usa should be equal to result: cities.update( [ [ { id: 7 }, { id: 7, name: "Venice", country: "Italy" } ] ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "NY", country: "USA", state: "NY" }
          ]
          
          cities.update [ [ { id: 7, name: "Housten", country: "USA", state: "Texas" }, { id: 7, name: "Venice", country: "Italy" } ] ]
          
          cities_in_usa.get().should.be.eql result
        
        it 'cities_in_usa should be equal to result: cities.update( [ [ { id: 3 }, { id: 8, name: "Detroit", country: "USA", state: "Michigan" } ] ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "NY", country: "USA", state: "NY" }
            { id: 8, name: "Detroit", country: "USA", state: "Michigan" }
          ]
          
          cities.update [ [ { id: 3, name: "Paris", country: "France" }, { id: 8, name: "Detroit", country: "USA", state: "Michigan" } ] ]
          
          cities_in_usa.get().should.be.eql result
        
        it 'cities_in_usa should be equal to result: cities.update( [ [ { id: 3 }, { id: 9, name: "Madrid", country: "Spain" } ] ] )', ->
          result = [
            { id: 2, name: "Mountain View", country: "USA", state: "California" }
            { id: 5, name: "NY", country: "USA", state: "NY" }
            { id: 8, name: "Detroit", country: "USA", state: "Michigan" }
          ]
          
          cities.update [ [ { id: 3, name: "Paris", country: "France" }, { id: 9, name: "Madrid", country: "Spain" } ] ]
          
          cities_in_usa.get().should.be.eql result
        
      describe 'remove()', ->
        it 'cities_in_usa should be equal to result: cities.remove( [ { id: 2, name: "Mountain View", country: "USA", state: "California" } ] )', ->
          result = [
            { id: 5, name: "NY", country: "USA", state: "NY" }
            { id: 8, name: "Detroit", country: "USA", state: "Michigan" }
          ]
          
          cities.remove [ { id: 2, name: "Mountain View", country: "USA", state: "California" } ]
          
          cities_in_usa.get().should.be.eql result
        
        it 'cities_in_usa should be equal to result: cities.remove( [ { id: 7, name: "Venice", country: "Italy" } ] )', ->
          result = [
            { id: 5, name: "NY", country: "USA", state: "NY" }
            { id: 8, name: "Detroit", country: "USA", state: "Michigan" }
          ]
          
          cities.remove [ { id: 7, name: "Venice", country: "Italy" } ]
          
          cities_in_usa.get().should.be.eql result
      
      
      