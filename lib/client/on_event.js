/*
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
undefine()( 'on_event', [ 'window', '../core/pipelet' ], function( window, rs ) {
  var extend = rs.RS.extend;
  
  return rs
  
    /* ------------------------------------------------------------------------
        @pipelet $on( event_name, options )
        
        @short Emits DOM events
        
        @parameters
        - event_name (String): the default name of the event to register,
          used for source values that do not provide an ```"event_name"```
          attribute string.
        
        - options (Object): optional pipelet options, plus:
          - last (Boolean): if true, the fetched state of $on() is all last
            events on all source nodes, otherwise, this is the empty state.
          
          - prevent_default (Boolean): optional, default false, if true
            calls ```event.preventDefault()``` when event is triggered.
          
          - jQuery (Function): if provided, events are registered as:
            ```javascript
              jQuery( $node ).on( event_name, function listener() {} )
            ```
            
            And unregistered as:
            ```javascript
              jQuery( $node ).off( event_name, listener )
            ```
        
        @source
        In addition to @@key attributes:
        - $node (EventTarget): to register event using addEventListener()
          or attachEvent() if addEventListener() is not available. $node must
          not be present on remove operations which is the behavior of
          pipelet $to_dom().
        
        - event_name (String): optional, to register instead of using
          parameter ```event_name```.
        
        @emits
        All source value attributes, plus;
        - count (Integer): the number of events fired by this node since
          registration.
          
        - $event  (Event): the fired Event, undefined when fetched before
          first event fired.
        
        @examples
        
          ```javascript
            source
              .$to_dom()
              .$on( 'click' )
              .trace()
              .greedy()
            ;
          ```
        
        @description:
        This is a @@synchronous, @@stateful, @@greedy, @@adds-only pipelet.
        
        When fetched it emits last values if option ```"last"``` is ```true```,
        the empty state otherwise.
        
        It emits nothing on source operations, only un/registers listeners.
        
        Output set @@key is source key plus attribute ```"count"```.
    */
    .Compose( '$on', function( source, event_name, options ) {
      var handlers = {}
        , key      = source._key.concat( [ 'count' ] )
        , last     = options.last
        , jQuery   = options.jQuery
        , output
      ;
      
      return output = source
        .map( function( value, next, operation ) {
          var id          = source._identity( value )
            , handler     = handlers[ id ]
            , $node       = value.$node
            , _event_name = value.event_name || event_name
          ;
          
          if ( handler ) {
            // remove previous handler even if operation is add or update_add
            delete handlers[ id ];
            
            if ( $node ) {
              var _listener = handler.listener;
              
              jQuery
                ? jQuery( $node ).off( _event_name, _listener )
                
                : ( $node.removeEventListener || $node.detachEvent ).call( $node, _event_name, _listener )
              ;
            }
          }
          
          if ( operation % 2 == 0 && $node ) { // add or update_add, or fetch_add or fetch_update_add
            value = extend( {}, value );
            
            value.count = 0;
            
            handler = handlers[ id ] = {
              listener: listener,
              value   : value
            };
            
            jQuery
              ? jQuery( $node ).on( _event_name, listener )
              
              : ( $node.addEventListener || $node._attachEvent ).call( $node, _event_name, listener )
            ;
          }
          
          next( null, last && value );
          
          function listener( event ) {
            // Hack output value for generator
            value.count++;
            value.event = event.type;
            
            options.prevent_default && event.preventDefault();
            
            output.__emit_add( [ extend( {}, value, { $event: event } ) ] );
          } // listener()
        } )
        
        .set( [], { key: key, name: options.name } )
      ;
    } ) // $on()
    
    /* -------------------------------------------------------------------------------------------
        @pipelet $window( options )
        
        @short Singleton for the global Window
        
        @description:
          This is a set with the single value:
          
            ```javascript
              { id: 1, $node: window }
            ```
          
          This is a singleton, stateful pipelet.
        
        @parameters:
          - options (Object): optional set options.
        
        @example:
          - Listen to window resize events to get an add-only dataflow of window sizes
            - this is the actual code for pipelet @@window_size():
            
            ```javascript
            rs
              .$window()
              
              .$on( 'resize', { last: true } )
              
              .map( window_size, { key: [ 'id' ] } )
            ;
            
            function window_size( _ ) {
              return {
                id    : _.count,
                width : window.innerWidth,
                height: window.innerHeight
              }
            }
            ```
    */
    .Singleton( '$window', function( source, options ) {
      return source
        .namespace()
        
        .set( [ { id: 1, $node: window } ], options )
      ;
    } ) // $window()
    
    /* -------------------------------------------------------------------------------------------
        @pipelet window_size( options )
        
        @short Provide a dataflow of window size change events
        
        @description:
          This is a singleton, synchronous, stateful, lazy, adds-only pipelet. When fetched, it
          will emit its last value. Source events are ignored and it never subscribes to any
          source events.
        
        @parameters:
          - options (Object): optional pipelet options.
        
        @emits:
          - id     (Integer): starts at 0, incremented on each change
          - width  (Integer): last value of window.innerWidth
          - height (Integer): last value of window.innerHeight
        
        @example:
          - Throttle high-frequency window resize events using animation_frame():
          
            ```javascript
            rs
              .window_size()
              .throttle( rs.animation_frame() )
              .map( function( _ ) { return _.last } )
              .trace( 'window_size' )
              .greedy()
            ;
            ```
    */
    .Singleton( 'window_size', function( source, options ) {
      return source
        
        .$window()
        
        .$on( 'resize', { last: true } )
        
        .map( window_size, { key: [ 'id' ] } )
      ;
      
      function window_size( _ ) {
        return {
          id    : _.count,
          width : window.innerWidth,
          height: window.innerHeight
        }
      }
    } ) // window_size()
  ;
} ); // on_event.js
