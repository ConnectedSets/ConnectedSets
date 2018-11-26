/*  aggregate.js

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
*/
( this.undefine || require( 'undefine' )( module, require ) )()
( 'aggregate', [ './stateful' ], function( rs ) {
  'use strict';
  
  var RS               = rs.RS
    , value_equals     = RS.value_equals
    , is_array         = RS.is_array
    , is_object        = RS.is_object
    , extend           = RS.extend
    , Code             = RS.Code
    , Loggable         = RS.Loggable
    , Greedy           = RS.Greedy
    , Set              = RS.Set
    , Options          = RS.Transactions.Options
    , options_forward  = Options.forward
    , options_has_more = Options.has_more
    , get_name         = RS.get_name
    , safe_identifier  = Code.safe_identifier
    , safe_attribute   = Code.safe_attribute
    , safe_dereference = Code.safe_dereference
    , clone            = extend.clone
    , de               = false
    , log              = RS.log.bind( null, 'aggregate' )
    , ug               = ug
    , default_s        = 'default'
    , push             = [].push
  ;
  
  /* --------------------------------------------------------------------------
      Aggregate_Dimensions()
      
      Dimensions Input
  */
  function Aggregate_Dimensions( aggregate, options ) {
    var that = this;
    
    Loggable.call( that, options.name );
    
    that.aggregate = aggregate;
    
    that.input = null;
  } // Aggregate_Dimensions()
  
  Loggable.subclass( 'Aggregate_Dimensions', Aggregate_Dimensions, {
    set_input: function( input ) { // called by Pipelet.._add_input()
      this.input = input;
    }, // Aggregate_Dimensions..set_input()
    
    fetch_all: function( receiver ) {
      this.input.fetch_all( function( dimensions ) {
        receiver( dimensions.map( function( d ) { return d.id } ) )
      } );
    }, // Aggregate_Dimensions..fetch_all()
    
    build_group: function( dimensions ) {
      dimensions.length
      
      ? eval( new Code( get_name( this, 'build_group' ) )
          ._function( 'this.aggregate._group', null, [ 'values' ] )
            ._var( 'groups = {}', 'keys = []', 'i = -1', 'v', 'k', 'g' )
            
            ._while( 'v = values[ ++i ]' )
              ._if( 'g = groups[ k = ' + dimensions.map( safe_dimension_dereference ).join( ' + ' ) + ' ]' )
                .add( 'g.push( v )' )
                .add( 'continue' )
              .end()
              
              .add( 'groups[ k ] = [ v ]' )
              .add( 'keys.push( k )' )
            .end()
            
            .add( 'return { groups: groups, keys: keys };' )
          .end( '_group()' ) // safe from tested variable safe_key_code and constant strings
          
          //.trace()
          
          .get()
        )
      
      : this.aggregate._group = function( values ) { return values };
      
      function safe_dimension_dereference( d ) {
        return '"#" + v' + safe_dereference( d );
      }
    } // Aggregate_Dimensions..build_group()
  } ); // Aggregate_Dimensions instance methods  
  
  var p = Aggregate_Dimensions.prototype;
  
  p._add = p._remove = p._update = function( _, options ) {
    if ( ! options_has_more( options ) ) {
      var that = this;
      
      that.fetch_all( function( dimensions ) {
        that.build_group( dimensions );
        
        that.aggregate._dimensions_changed( dimensions, options );
      } );
    }
  }; // _add() / _remove() / _update()
  
  /* --------------------------------------------------------------------------
     Aggregate_Measures()
     
     Input for Measures
  */
  function Aggregate_Measures( aggregate, options ) {
    var that = this;
    
    Loggable.call( that, options.name );
    
    that.aggregate = aggregate;
    
    that.values = null;
  } // Aggregate_Measures()
  
  function get_values( that ) {
    return that.values || ( that.values = [] );
  } // get_values()
  
  Loggable.subclass( 'Aggregate_Measures', Aggregate_Measures, {
    build_reduce_groups: function( measures, dimensions ) {
      var name               = get_name( this, 'build_reduce_groups' )
        
        , measure_ids        = []
        
        // variables verified safe for evaluation
        // !!! keep these safe at all time by only combining with other safe variables
        , safe_measures      = []
        , safe_measures_init = []
        , safe_first         = ''
        , safe_init
        , safe_measure
        , safe_value
        , safe_inner
        , safe_last
        , safe_vars
        , safe_code
        , safe_indent
        
        // other variables not safe for evaluation
        , ml                 = measures.length
        , dl                 = dimensions.length
        , many_dimensions    = dl > 1 // tested
        , many_measures               // tested
        , i
        , dimension
        , measure
        , measure_id
        , measure_type
        , ___
      ;
      
      if ( ml ) {
        for ( i = -1; measure = measures[ ++i ]; ) { // Measures validation loop
          /* m: { id: 'price', type: 'sum', of: 'Price', default: 0, init: 0, no_null: false }
             
             All attributes are optional except id which must be unique. Optional attributes
             have the defaut values shown above.
          */
          switch( measure_type = measure.type = measure.type || 'sum' ) {
            case 'max':
              safe_default_measure( measure, -Infinity ); // safe
              
              safe_init = []; // safe, constant
            break;
            
            case 'min':
              safe_default_measure( measure, +Infinity ); // safe
              
              safe_init = []; // safe, constant
            break;
            
            case 'sum':
              safe_default_measure( measure, 0 ); // safe, tested
              
              safe_init = 0; // safe, constant
            break;
            
            // ToDo: add count of distinct or count_distinct type for SQL equivalent to count( distinct author)
            // ToDo: add average measure type
            
            default:
              // ToDo: emit error
              log( name + 'unsupported measure type:', measure_type );
              
              measures.splice( i--, 1 );
              
              ml -= 1;
          }
        }
        
        // Note: we must have 2 distinct loops because the first validates measures and may reduce their count
        many_measures = ml > 1;
        
        for ( i = -1; measure = measures[ ++i ]; ) {
          measure_ids.push( measure_id = measure.id );
          
          safe_measures.push( safe_measure = safe_identifier( '_' + measure_id ) ); // safe, tested
          
          safe_measures_init.push( safe_measure + ' = ' + safe_init ); // safe, from tested variables
          
          // Unrolled while content generation
          
          /* Access current value v:
                     g[ ++i ].Price  -- only one measure, when l == 1
             ( o = g[ ++i ] ).Price  -- only the first measure, when i == 0
                            o.Price  -- next iterations
          */
          safe_value = 'v = '
            + ( many_measures ? 0 == i ? '( o = g[ ++i ] )' : 'o' : 'g[ ++i ]' )
            + safe_dereference( measure.of || measure_id )
          ; // safe, tested
          
          // if values can be null or undefined, use default value
          measure.no_null || ( safe_value = '( u == ( ' + safe_value + ' ) ? ' + measure[ default_s ] + ' : v )' ); // safe, from tested variables
          
          switch( measure_type ) {
            case 'sum':
              safe_first += safe_measure + ' += ' + safe_value; // safe, from tested variables
              
              many_measures
                ? safe_first += ';' // safe, from tested variables
                
                : safe_inner = '+ ' + safe_value // safe, from tested variables
              ;
            break;
            
            case 'max':
            case 'min':
              if ( many_measures )
                safe_first += safe_measure + '.push( ' + safe_value + ' );' // safe, from tested variables
              
              else {
                safe_first = safe_measure + '.push( ' + safe_value; // safe, from tested variables
                
                safe_inner = ', ' + safe_value; // safe, from tested variables
                
                safe_last = ' )'; // safe, from tested variables
              }
          } // end switch m.type
        } // end for all measures
      } // end if at least one measure
      
      // Generate variables
      safe_vars = dl ? [ 'hash = {}', 'keys = groups.keys', 'j = -1', 'key', 'g' ] : []; // safe, constant strings
      
      if ( many_dimensions || many_measures ) safe_vars.push( 'o' ); // safe, constant strimg
      
      if ( ml ) {
        push.apply( safe_vars, dl ? safe_measures : safe_measures_init ); // safe, from tested variables
        
        safe_vars.push( dl ? 'l' : 'l = g.length', dl ? 'i' : 'i = -1', 'v', 'u' ); // safe, constant strings
      }
      
      safe_vars.push( dl ? 'out = []': 'out' ); // safe, constant strings
      
      // Generate function _reduce_groups()
      safe_code = new Code( name )
        ._function( 'this.aggregate._reduce_groups', null, [ dl ? 'groups' : 'g' ] ) // safe, constant strings
          ._var( safe_vars ) // safe, from tested variables
          
          dl && safe_code
          .add( 'groups = groups.groups', 1 ) // safe, constant strings
          
          ._while( 'key = keys[ ++j ]' ) // safe, constant strings
          
            .add( 'g = groups[ key ]', 1 ); // safe, constant strings
            
            // aggregate measures
            if ( ml ) {
              dl && safe_code.add( safe_measures_init.join( ',' ) + ', l = g.length, i = -1', 1 ); // safe, from tested variables
              
              safe_code.unrolled_while( safe_first, safe_inner, safe_last ); // safe, from tested variables
            }
            
            // output group
            safe_code
            .line( dl ? 'out.push( hash[ key ] = {' : 'out = {' ); // safe, constant strings
              // Add dimensions' coordinates
              safe_indent = '  '; // safe, constant string
              
              if ( dl )
                for ( i = -1; dimension = dimensions[ ++i ]; )
                  safe_code.line( safe_indent
                    + safe_attribute( dimension ) + ': '
                    + ( i
                        ? 'o'
                        : many_dimensions ? '( o = g[ 0 ] )' : 'g[ 0 ]'
                      )
                    + safe_dereference( dimension )
                    + ','
                  ); // safe, from tested variables, constant strings, and safe functions
              
              else
                safe_code.line( safe_indent + 'id: 1,' ); // safe, from tested variables
              
              // Add aggregated measures
              if ( ml )
                for ( i = -1; ( measure_id = measure_ids[ ++i ] ) !== ___; )
                  safe_code.line( safe_indent + safe_attribute( measure_id ) + ': ' + safe_measures[ i ] + ',' ); // safe, from tested variables and safe function
            
            safe_code
            .line( safe_indent + '_count: ' + ( ml ? 'l' : 'g.length' ) ) // safe, from tested variables
            
            .add( ( dl ? '} )' : '}' ), 1 ); // safe, constant strings
          
          dl && safe_code.end(); // end while dimensions
          
          safe_code.add( 'return { groups: ' + ( dl
            ? 'out, keys: keys, hash: hash }'
            : '[ out ], keys: [ "1" ], hash: { 1: out } }'
          ) ) // safe, constant strings
        .end( '_reduce_groups()' )
        
        //.trace()
      ;
      
      eval( safe_code.get() );
      
      function safe_default_measure( measure, value ) {
        if ( typeof measure[ default_s ] != 'number' ) measure[ default_s ] = value; // safe, testing that default is a number, not a string that could inject code
      }
    }, // Aggregate_Measures..build_reduce_groups()
    
    _update_measures: function( measures, options ) {
      if ( ! options_has_more( options ) ) {
        var that = this;
        
        that.aggregate._dimensions.fetch_all( function( dimensions ) {
          that.build_reduce_groups( measures, dimensions );
          
          that.aggregate._measures_changed( measures, options );
        } );
      }
    }, // Aggregate_Measures.._update_measures()
    
    _add: function( added_measures, options ) {
      var that     = this
        , measures = get_values( that )
      ;
      
      push.apply( measures, clone( added_measures ) );
      
      that._update_measures( measures, options );
    }, // Aggregate_Measures.._add()
    
    _remove: function( removed_measures, options ) {
      var that     = this
        , measures = get_values( that )
        , i        = -1
        , j
        , measure
        , m
      ;
      
      while ( measure = removed_measures[ ++i ] )
        for ( j = -1; m = measures[ ++j ]; )
          if ( measure.id == m.id ) {
            measures.splice( j, 1 );
            
            break;
          }
      
      that._update_measures( measures, options );
    }, // Aggregate_Measures.._remove()
    
    _update: function( updates, options ) {
      var that     = this
        , measures = get_values( that )
        , i        = -1
        , j
        , update
        , m
      ;
      
      while ( update = updates[ ++i ] )
        for ( j = -1; m = measures[ ++j ]; )
          if ( update[ 0 ].id == m.id ) {
            extend( m, update[ 1 ] );
            
            break;
          }
      
      that._update_measures( measures, options );
    } // Aggregate_Measures.._update()
  } ); // Aggregate_Measures instance methods
  
  /* --------------------------------------------------------------------------
      @pipelet aggregate( measures, dimensions, options )
      
      @short Aggregates mesures from source values by dimensions
      
      @parameters
      - **measures** (Pipelet or Array of Objects): optional.
        If no measure is defined, only ```_count``` is computed.
        Measure ```_count```, always computed, counts the number of source
        values in each dimension group.
        Each measure is defined by attributes:
        - **id** (String): measure attribute name
        
        - **of** (String): source attribute name, default is the value
        of ```id```.
        
        - **type** (String): optional, tells how this measures aggregates
        values. Possible values are:
          - ```"sum"```: (default) Sum all values.
          - ```"min"```: Compute the minimum value
            (WIP, not tested, no updtae support)
          - ```"max"```: Compute the maximum value
            (WIP, not tested, no update support)
        
        - **default** (Number): A default value for the aggregate when
        a value is ```null``` or ```undefined``` and option ```no_null```
        is falsy.
        The default value of which depends on type:
          - ```"sum"```: 0
          - ```"min"```: +Infinity
          - ```"max"```: -Infinity
        
        - **no_null** (Boolean):
          - ```true```: source dataflow should not countain any ```null```
          or ```undefined``` values.
          This is a performance optimization allowing to compute sums faster.
          
          - ```false```: (default), ```null``` and ```undefined``` values are
          replaced with ```default``` value.
      
      - **dimensions** (Pipelet or Array of Objects): optional.
        If no dimension is defined, a single group with ```{ id: 1 }``` is
        emitted, aggregating all source values.
        Each dimension is defined by attributes:
        - **id** (String): source attribute name
      
      - **options** (Object): optional @@pipelet:set() options. Do not set
        a key option as it will be automatically set according to dimensions.
        Additional options:
        - **initial_groups** (Object []): Optional groups that will be
          emitted and initialized with zero count and default measures.
          
          Each group must be defined with the same attributes as defined
          in dimensions. These groups are never deleted.
          
          When initial groups are defined, dimensions should never change
          because initial groups cannot change.
          
          If there are no dimensions, i.e. when aggregating all source
          values into a single group, *initial_groups* should be defined
          as an Array of one empty Object: ```[{}]```.
          
          See also pipelet group() which has the same option.
      
      @examples
      - Count the number of cities per state as well as total
        population by state:
        
        In SQL this typically be accomplished as:
        
        ```SQL
        SELECT state, count(*), sum( population )
        FROM cities
        GROUP BY state
        ```
        
        With aggregate() it can be accomplished as the following,
        we also add an always-on group for the state of Danemark:
        
        ```JavaScript
        var population = [ { id: "population" } ]
          , by_state   = [ { id: 'state'      } ]
        ;
        
        cities
          .aggregate( population, by_state, { initial_groups: [ { state: "Danemark" } ] } )
        ;
        ```
        
        Which emits values with the following attributes:
        - **state**: city state value
        - **population**: sum of population values for all cities in each
          unique state
        - **_count**: the number of cities in each state
      
      - Count population and number of cities in entire cities set, always
      providing a group even if there are no cities in that set:
      
        ```javascript
        var population = [ { id: "population" } ];
        
        cities
          .aggregate( population, [], { initial_groups: [ {} ] } )
        ;
        ```
        
        Which always emits one and only one group with these attributes:
        - **id**: always ```1```
        - **population**: sum of population values for all cities
        - **_count**: total number of cities
      
      - Count the number of cities in the entire cities set:
      
        ```javascript
        cities
          .aggregate()
        ;
        ```
        
        Which emits:
        - **id**: always ```1```
        - **_count**: total number of cities
      
      @description
      This is a @@stateful, @@synchronous, @@greedy pipelet.
      
      Groups source values by dimensions and compute aggregate measures
      for each group.
      
      This provides an equivalent to SQL ```GROUP BY``` clause.
      
      The @@key for aggregates is automatically set according to
      its dimensions. If there are no dimensions the key is ```[ "id" ] ```.
      If dimensions change, the key will change and will be propagated
      to downstream @@pipelet:set() pipelets.
  */
  function Aggregate( measures, dimensions, options ) {
    var that           = this
      , initial_groups = options.initial_groups
      , name
      , _dimensions
      , _measures
    ;
    
    Set.call( that, [], options );
    
    name = get_name( that );
    
    that._new_key       = null; // To emit as new key option with non-empty values
    that._group         = null; // Function generated by Aggregate_Dimensions()
    that._reduce_groups = null; // Function generated by Aggregate_Measures()
    
    that._dimensions = _dimensions = new Aggregate_Dimensions( that, options );
    that._measures   = _measures   = new Aggregate_Measures  ( that, options );
    
    that._add_input( dimensions || [], Greedy.Input, name + '-dimensions', _dimensions );
    that._add_input( measures   || [], Greedy.Input, name + '-measures'  , _measures   );
    
    if ( is_array( initial_groups ) && initial_groups.every( is_object ) ) {
      
      _dimensions.fetch_all( function( dimensions ) {
        var aggregates = that._aggregate( initial_groups );
        
        aggregates.always = {};
        
        initial_groups.forEach( function( initial_group ) {
          // if there are no dimensions, there is only one group for all values, which identity is 1
          var identity = dimensions.length ? that._identity( initial_group ) : 1;
          
          // reset count to zero, was one after calling that._aggregate()
          aggregates.hash[ identity ]._count = 0;
          
          // never remove this group
          aggregates.always[ identity ] = 1;
        } );
        
        that._aggregates = aggregates;
      } )
    } // initialize initial_groups
  } // Aggregate()
  
  Set.Build( 'aggregate', Aggregate, {
    _get: function() {
      var aggregates = this._aggregates;
      
      return aggregates && aggregates.groups || [];
    }, // Aggregate..get()
    
    _dimensions_changed: function( dimensions, options ) { // safe from tested safe callers
      var that            = this
        , measures        = that._measures
        , measures_values = measures.values
        , new_key         = that._new_key = that._set_key( dimensions.length && dimensions )
      ;
      
      // If this is the first time, during initialization, measures values are not defined yet
      if ( measures_values ) {
        measures.build_reduce_groups( measures_values, dimensions );
        
        that._input.fetch_all( function( values ) {
          var aggregates = that._aggregates
            , removes    = aggregates && aggregates.groups
            , t
            , adds
          ;
          
          if ( removes ) {
            t = that._transaction( 2, options );
            
            that.__emit_remove( removes, t.next_options() );
            
            options = t.next_options();
          }
          
          that._aggregates = aggregates = that._aggregate( values );
          
          adds = aggregates.groups;
          
          that.__emit_add( adds, that._get_options( adds, options ) );
        } );
      }
    }, // Aggregate.._dimensions_changed()
    
    _get_options: function( values, options ) {
      var new_key = this._new_key;
      
      if ( new_key && values.length ) {
        options = extend( {}, options, { new_key: new_key } );
        
        this._new_key = null;
      }
      
      return options;
    }, // Aggregate.._get_options()
    
    _measures_changed: function( measures, options ) {
      var that       = this
        , aggregates = that._aggregates
      ;
      
      that._build_merge( measures );
      
      that._input._fetch( function( values ) {
        var b    = that._aggregates = that._aggregate( values )
          , adds = b.groups
          , h0
          , h1
        ;
        
        options = that._get_options( adds, options );
        
        if ( aggregates ) {
          // there were previous aggregates, emit an update of all groups
          h0 = aggregates.hash;
          h1 = b.hash;
          
          that.__emit_update(
            b.keys.map( function( key ) { return [ h0[ key ], h1[ key ] ] } ),
            options
          );
        } else
          // ToDo: add test for no previous aggregates on measures change
          that.__emit_add( adds, options )
        ;
      } );
    }, // Aggregate.._measures_changed()
    
    /* ------------------------------------------------------------------------
       Aggregate.._aggregate( values )
       
       This is a low-level method used by _add / _remove / _update to
       calculate aggregates of an array of values.
       
       Aggregates are calculated by reducing values into groups of values
       according to dimensions then reducing each object group into aggregates
       according to measures.
       
       These aggregates are then typically merged into the aggregate's
       previous aggregates, or removed from these if the action is _remove(),
       updates are not currently handled by this method.
       
       This function should not be used directly but could be overloaded by
       derived classes to change its behavior.
       
       Parameters:
         - values: an array of values to aggregate measures by dimensions.
    */
    _aggregate: function( values ) {
      var reduce_groups = this._reduce_groups
        , group         = this._group
      ;
      
      return reduce_groups && group
          
          // Note: reduce_groups() and group() know their context
          && reduce_groups( group( values ) )
      ;
    }, // Aggregate.._aggregate()
    
    /* ------------------------------------------------------------------------
        Aggregate.._build_merge( measures )
        
        Builds _merge() method new measures
    */
    _build_merge: function( measures ) {
      this._merge = function( aggregates, options, operation ) {
        var ml       = measures.length
        
          , a        = this._aggregates
          , groups   = a.groups
          , keys0    = a.keys
          , h0       = a.hash
          , always   = a.always
          
          , keys1    = aggregates.keys
          , h1       = aggregates.hash
          
          , k1
          
          , g0, g1
          
          , all_default
          
          , adds     = []
          , removes  = []
          , updates  = []
          
          , i, j, k
          
          , m, id, kl, v0, v1
        ;
        
        for ( i = -1; k1 = keys1[ ++i ]; ) {
          g0 = h0[ k1 ];
          g1 = h1[ k1 ];
          
          if ( g0 ) {
            all_default = 1; // to account for anti-removes
            
            switch( operation ) {
              case 'add': // can also remove groups using negative counts on updates
                g1._count += g0._count;
                
                for ( j = -1; ++j < ml; ) {
                  m = measures[ j ];
                  id = m.id;
                  
                  switch( m.type ) {
                    case 'sum':
                      if ( ( g1[ id ] += g0[ id ] ) != m[ default_s ] ) all_default = 0;
                    break;
                    
                    case 'max':
                    case 'min':
                      g1[ id ] = g1[ id ].concat( g0[ id ] );
                    break;
                  }
                }
              break;
              
              case 'remove':
                g1._count = g0._count - g1._count;
                
                for ( j = -1; ++j < ml; ) {
                  m = measures[ j ];
                  id = m.id;
                  
                  switch( m.type ) {
                    case 'sum' :
                      if ( ( g1[ id ] = g0[ id ] - g1[ id ] ) != m[ default_s ] ) all_default = 0;
                    break;
                    
                    case 'max':
                    case 'min':
                      // remove all values from g0[ id ] that are found in g1[ id ]
                      v0 = g0[ id ].slice( 0 );
                      v1 = g1[ id ];
                      
                      for ( k = 0, kl = v0.length; ++k < kl; )
                        v0.splice( v1.indexOf( v0[ k ] ), 1 )
                      ;
                      
                      if ( v0.length ) all_default = 0;
                    break;
                  }
                } // end for all measures
              break;
            } // end switch operation
            
            // locate position of k1 in keys0 (which should also be the position of g0 in groups)
            j = keys0.indexOf( k1 );
            
            if ( g1._count || ! all_default || always && always[ k1 ] ) {
              value_equals( g0, g1 ) || updates.push( [ g0, g1 ] );
              
              h0[ k1 ] = groups[ j ] = g1;
            } else {
              // The are no-more any upstream values, remove this group
              removes.push( g0 );
              
              delete h0[ k1 ];
              
              keys0 .splice( j, 1 );
              groups.splice( j, 1 );
            }
          } else {
            // This group is not present in the previous aggregates
            switch( operation ) {
              case 'remove': // anti-group
                g1._count = -g1._count;
                
                for ( j = -1; m = measures[ ++j ]; ) {
                  id = m.id;
                  
                  switch( m.type ) {
                    case 'sum':
                      g1[ id ] = -g1[ id ];
                    break;
                    
                    case 'max':
                    case 'min':
                      g1[ id ] = { removed: g1[ id ] }; // not supported by add, ToDo: fix min/max support of anti-groups
                    break;
                  }
                }
              break;
            }
            
            // Add this new group
            add_group( groups, keys0, h0, k1, g1 );
            
            // emit an add() operation for this group
            adds.push( g1 );
          }
        }
        
        // log( 'emit_operations', adds, removes, updates );
        
        this.__emit_operations( adds, removes, updates, options );
      }; // _merge()
    }, // Aggregate.._build_merge()
    
    /* ------------------------------------------------------------------------
        Aggregate.._add( values [, options ] )
    */
    _add: function( values, options ) {
      options = options_forward( options );
      
      var that = this
        , a    = that._aggregate( values )
        , adds = a.groups
      ;
      
      options = that._get_options( adds, options );
      
      if ( that._aggregates ) return that._merge( a, options, 'add' );
      
      // This is the first time we build or re-build aggregates
      that._aggregates = a;
      
      that.__emit_add( adds, options );
    }, // Aggregate.._add()
    
    /* ------------------------------------------------------------------------
        Aggregate.._remove( values [, options ] )
    */
    _remove: function( values, options ) {
      this._merge( this._aggregate( values ), options_forward( options ), 'remove' )
    }, // Aggregate.._remove()
    
    /* ------------------------------------------------------------------------
        Aggregate.._update( updates [, options ] )
    */
    _update: function( updates, options ) {
      options = options_forward( options );
      
      var that     = this
        , measures = get_values( that._measures )
        , a0       = []
        , a1       = []
        , update
        , i
        , j
        , measure
        , id
        , k0
        , g0
        , g1
      ;
      
      // extract previous and new values in two separate arrays a0 and a1
      for ( i = -1; update = updates[ ++i ]; ) {
        a0.push( update[ 0 ] );
        a1.push( update[ 1 ] );
      }
      
      // Calculate aggregates for separate previous and new values
      a0 = that._aggregate( a0 );
      a1 = that._aggregate( a1 );
      
      // Merge previous and new values
      var keys0  = a0.keys
        , keys1  = a1.keys
        , groups = a1.groups
        , h0     = a0.hash
        , h1     = a1.hash
      ;
      
      for ( i = -1; k0 = keys0[ ++i ]; ) {
        g0 = h0[ k0 ];
        g1 = h1[ k0 ];
        
        if ( g1 ) {
          // updated group, compute measures differences
          g1._count -= g0._count;
          
          for ( j = -1; measure = measures[ ++j ]; ) {
            id = measure.id;
            
            switch ( measure.type ) {
              case 'sum':
                g1[ id ] -= g0[ id ];
              break;
              
              // ToDo: max / min
            }
          }
        } else {
          // removed group, will be added with negated values
          g0._count = -g0._count;
          
          for ( j = -1; measure = measures[ ++j ]; ) {
            id = measure.id;
            
            switch ( measure.type ) {
              case 'sum':
                g0[ id ] = -g0[ id ];
              break;
              
              // ToDo: max / min
            }
          }
          
          add_group( groups, keys1, h1, k0, g0 );
        }
      }
      
      // Merge with previous aggregates
      // log( 'merge a1:', a1 );
      
      that._merge( a1, options, 'add' );
    } // Aggregate.._update()
  } ); // Aggregate instance methods
  
  /* --------------------------------------------------------------------------
    @function add_group( groups, keys, hashes, key, group )
    
    @short Helper for @@method:Aggregate.._merge() and
    @@method:Aggregate.._update().
    
    @parameters
    - **groups** (Array of groups): ```group``` will be pushed to it.
    - **keys** (Array of String): ```key``` will be pushed to it.
    - **hashes** (Object): groups by key, ```{ key: group }``` will be added
      to it.
    - **key** (String): group's key, indexing hashes.
    - **group** (Object): to push to ```groups``` and to ```hashes```
      indexed by ```key```
  */
  function add_group( groups, keys, hashes, key, group ) {
    groups.push( hashes[ key ] = group );
    
    keys.push( key );
  } // add_group()
  
  /* --------------------------------------------------------------------------
     module exports
  */
  RS.Aggregate         = Aggregate;
  Aggregate.Dimensions = Aggregate_Dimensions;
  Aggregate.Measures   = Aggregate_Measures;
  
  return rs;
} ); // aggregate.js
