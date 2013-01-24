// client.js
//  test http client, uses server.js defined http server

var l8 = require( "l8/lib/l8.js" );

// Let's pretend I am a client, not a server
try{
  l8.clientize();
}catch( e ){
  l8.server = false;
  l8.client = true;
}

var XS = require( "../lib/xs.js" ).XS;
require( "../lib/fork.js" );
require( "../lib/proxy.js" );
var xs = XS.xs;

// The Dude subscribe to the daily mirror
//var daily_mirror_for_the_dude = XS.void.proxy( "daily_mirror_for_the_dude" );

function trace( tracer, model, operation, objects ){
  var buf = [ "[" ];
  for( var item in objects ){
    buf.push( "{" );
    item = objects[ item ];
    for( var property in item ){
      buf.push( "" + property + ":" + item[ property ] );
    }
    buf.push( "}");
  }
  buf = buf.join( ", " );
  l8.trace( "" + tracer, model, operation, buf );
}

//daily_mirror_for_the_dude.tracer( { log: trace } );

var server_url = "http://localhost:" + (process.env.PORT || 8080);
var subscriber = xs.subscribe(
  "daily_mirror",
  { url: server_url, all: true, filter: null }
);
subscriber.tracer( { log: trace } );

XS.l8.task( function(){
  var next_id = 1;
  this.repeat( function(){
    XS.l8.trace( "new article by subscriber, " + next_id );
    subscriber.propose_add( [ { id: next_id, text: "article oops " + next_id } ] );
    next_id++;
    this.sleep( 10 * 1000 );
  });
});

// subscriber.file( "daily_mirror_backup" )

l8.countdown( 100 );
