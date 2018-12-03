# Toubkal

**Fully reactive programming for nodejs and the browser**

*Liberating your Creativity by improving your Productivity and runtime Performances*

*1942 Continuous Integration Tests*

[![Travis CI Build Status](https://travis-ci.org/ReactiveSets/toubkal.png?branch=master)](https://travis-ci.org/ReactiveSets/toubkal)
[![npm version](https://badge.fury.io/js/toubkal.svg)](https://badge.fury.io/js/toubkal)

[![Join the chat at https://gitter.im/ReactiveSets/toubkal](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ReactiveSets/toubkal?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The current version allows rapid development of non-trivial, complex,
all-reactive applications. We are using it in production applications
developped for and with our clients.

## Teaser
Displaying a reactive ```<table>``` which DOM container is ```#sales_table```, ordered by date,
for the years 2013 & 2014, from a source ```sales``` dataflow coming from a ```socket.io``` server,
pulling the minimum amount of data from the server and updating the table as soon as some
data is available from the server
(complete working code including http server is available at
[examples/teaser](https://github.com/ReactiveSets/toubkal/tree/master/examples/teaser)):

#### client.js

```javascript
rs.socket_io_server()
  .flow  ( 'sales' )
  .filter( [ { year: 2013 }, { year: 2014 } ] )
  .order ( [ { id: 'date' } ] )
  .table ( $( '#sales_table' ), sales_columns )
;
```

#### How does this work?

```sales_table``` is updated reactively in realtime whenever sales are updated on the server.

```rs.socket_io_server()``` connects the client to Toubkal socket.io server.

```flow( 'sales' )``` declares that the ```sales``` dataflow is needed from the server.

```[ { year: 2013 }, { year: 2014 } ]``` is a filter *query*, it controls how much sales data will be
pulled from the server therefore reducing both bandwidth usage and latency.

Latency is further reduced by displaying the table as soon as the first sales come
from the server, improving user experience.

This query can be a dataflow, updated by DOM controls and automatically pulling the
minimum amount of data from the server.

```[ { id: 'date' } ]``` is an *organizer*, it can also be a dataflow dynamically
updated by DOM controls, or any other application source.

The ```sales_columns``` dataflow controls table's columns. When updated, columns
are reactively added or removed in realtime without any addtitional programing required.
```sales_columns``` can be defined in the client or also come from the socket.io server
using the following declarative code:

```javascript
var sales_columns = rs
  .socket_io_server()
  .flow( 'sales_columns' )
;
```
The above code automatically shares the same socket.io connection with the previous code,
reducing resource usage on both clients and servers while only pulling from the server
the additional ```sales_columns``` dataflow.

Table updates are optimized to add and remove the minimum set of rows and columns,
improving client responsiveness, battery life and user experience.

#### What does this mean?

The Toubkal program above is expressed in one third the words required
to express the problem in plain english replacing thousands of lines of
complex and error-prone code.

Toubkal programs have no *loops*, and no *ifs*, dramatically reducing
the likelyhood of bugs and hence greatly improving productivity.
Under the hood, Toubkal provides all the optimized and comprehensively
tested *loops* and *ifs* you need.

These same declarative techniques are applied on the server side
delivering a full stack scallable and secure framework with highest
performances featuring a reactive database and fine-grained authorization
design patterns.

The bottom line is that Toubkal allows you to write with less code higher
performance fully reactive applications, liberating your creativity.

## Installation

From npm, latest release:
```bash
# npm install toubkal
```

## Documentation

This readme provides a short introduction to Toubkal.

Full reference documentation including internals and the Toubkal
protocol is available at
[https://toubkal.reactane.com/](https://toubkal.reactane.com/).

This documentation site is a Toubkal reactive application. It updates
automatically after each commit is pulled on our developpement server.

Documentation is extracted from code using the following Toubkal
server pipelets:
- **[acorn()](https://toubkal.reactane.com/#pipelet_acorn)**: parse javascript using the acorn library
- **[parse_documentation()](https://toubkal.reactane.com/#pipelet_parse_documentation)**: emit documentation items from parsed comments
- **[documentation_markdown()](https://toubkal.reactane.com/#pipelet_documentation_markdown)**: format documentation items into markdown
- **[markdown()](https://toubkal.reactane.com/#pipelet_markdown)**: markdown to html converter using "remarkable" and "highlight.js"
- **[documentation_manuals()](https://toubkal.reactane.com/#pipelet_documentation_manuals)**: Toubkal documentation manuals metadata (not content)

To work on the documentation on a local machine, run the documatation site:
```bash
  node site/server.js > site.out
```

Then point a web browser at [localhost on port 8082](http://localhost:8082/).

## Automated Tests, Continuous Integration

We have curently developped 1942 continuous integration tests for the Toubkal
core and library pipelets that run after every commit on Travis CI under
node version 8.12.0 LTS.

In the event that a test does not pass our top priority is to fix the test
before anything else. We usualy fix broken tests within hours.

These tests also pass on Windows under [Cygwin](https://www.cygwin.com/)
which although not officially supported by node, works with some caveats.

In any case, one should expect Toubkal applications to run equally well
on Windows and Linux.

We also do manual testing on the following web browsers:
- Chrome (latest),
- Firefox (latest),
- Safai (latest),
- IE 11.

### Running tests locally
```bash
# npm install -g coffee-script
# npm install -g mocha
# git clone https://github.com/ReactiveSets/toubkal.git
# cd toubkal
# npm install
# ./run_tests.sh
Full test results are in test.out
-> passed 1942 of 1942 tests
#
# less -R test.out # for tests detailed traces
```

### Running core tests in a browser:
```bash
# node test/server/http.js
```

Then browse http://localhost:8080/test/manual/

### Running browser examples:
```bash
# node examples/server.js
```

Then browse http://localhost:8081/

## Development Stage
Toubkal is already quite reliable thanks to its comprehensive test suite
and is currently used to deliver complex, all-reactive, enterprise
progressive web applications for clients.

The architecture of Toubkal is now stable, with main components (pipelets,
plugs, queries, transactions, and more) well defined and implemented.

Although the API may still change from time to time, we have entered a
more mature phase where the high level API is now quite stable, while
lower-level API changes much less often.

## Our team
Toubkal is developped by a dedicated small team of experienced and
passionate full-stack developers for the web and other technologies.

We are now fully funded and profitable by delivering Toubkal
applications for our clients at [Reactane](https://www.reactane.com/).

We have been developping Toubkal since December 2012 and cannot
imagine ever going back to programming the old way.

If you are an experienced JavaScript programmer, understand the power
of all-reactive programming and would like to join our team, please
contact us.

## Introduction
Toubkal is a high-productivity, high-performances, scalable, all-reactive
web application library aiming at improving your productivity for the
development of complex applications, reducing servers' environmental
footprint, and increasing mobile clients battery life by making an
optimal use of server, network and client resources.

### Why yet-another JavaScript application library?
The short answer is because we are not satisfied with the productivity,
performances, and authorization models, of existing frameworks and
libraries.

Internet servers are consuming an increasily significant share of
worldwide electricity production, contributing to climate change and
threatening Internet growth as the availability of cheap fosil fuels
decreases due to population growth and per capita consumption growth.

The power of Internet server is now mostly increasing through the
addition of CPU cores, meaning that the key to efficient usage of server
resources must shift from raw-single-thread performence to high
concurrency and parallelism performance. This in turn requires new
programming patterns to keep, or increase programmers' productivity.

Also, one must realize that the bulk of the vast majorty of today's
applications is about controling the motion of data throughout the
network. Such data is no-longer limited to strictly public or strictly
private informtation, requiring complex authorization schemes. This calls
for new programing patterns that allows to greatly simplify the
management of user authorizations well beyond all-or-nothing
authentication.

#### What do you mean by performances?
Our first priority is high-performances, because we believe that
performance is the key to better user experience, lowest operational
costs, and lower environemental footprint.

We are fighting simultaneously against:
- **CPU cycles** that consume energy to run and cool-down servers,
slow-down mobile clients, and **drain mobile batteries** faster
than anyone desires;
- **Latency** decreasing the responsiveness of applications and
user experiences;
- **Bandwidth** usage that consume energy, and increase latency over
lower-bandwidth networks.

We also want to keep **good performances at scale**. Most libraries
either do-not-scale or scale with lower per-server performances further
increasing costs while increasing environemental footprints.

Toubkal addresses all of these issues thanks to its unique
**Publish / Subscribe** all-reactive dataflow model that works accross
web browsers and nodejs servers, as well as just-in-time code generators
and other unique optimizations.

Most importantly Toubkal provides a programing model that can be
further optimized while maintaining user-code compatibility.

#### What's the big deal about authorizations?

Writing a complex application is hard-enough, add to this any significantly-complex
authorization scheme and the whole thing breaks apart, slows-down to a crawl, clutters
the code with plenty of unspotted security holes throughout every part of the
application, and every now and then exposes end-users' data to unauthorized users.

Most companies try to get away with it by sweeping each leak under the carpet and
promissing end-users that this will never happen again, or better yet, that this never
happened. Internally, this usually ends-up with more meetings and paperwork, less
things done for a system that although marginally improved, will at best remain unproven.

Because it is so hard, most frameworks take a this-is-not-our-problem approach to
authorizations by stating that you should use third-party libraries or plugins to deal
with it, all of which have shortcomming and usually will not fit the complexity of any
real-world application let alone provide acceptable performances at scale.

Toubkal provides a simple yet efficient dataflow authorization model and system
architecture that delivers **Reactive UI updates on authorization changes** at scale.

Now, you might consider that you don't need this, that end-users can refresh their page
on authorization changes. But the reality is that we can do this because we provide a
model that works in all cases, without requiring you to write a single additional line of
code, so that you can sleep at night knowing that end-user data cannot be exposed by some
piece of code that forgot to test a role in a corner-case.

#### How does Toubkal improve your productivity?

By allowing you to describe **what** you need in a declarative style, instead of
**how** this could ever be accomplished.

Figuring-out **how** this should a) work securely, b) scale and c) have best performances
as stated above, is hard, really hard. So hard that today the only way to achieve this is
throwing millions of dollars at the problem, and/or struggling with bugs, bottlenecks
and hard-to-work-around architecture limitations.

The most important concept you need to know to understand Toubkal programs is about
**Toubkal Pipelets** and how to combine them to create programs that react to data
change events:

```javascript
rs.upstream_pipelet  ( parameter, ... )
  .a_pipelet         ( parameter, ... )
  .downstream_pipelet( parameter, ... )
;
```

A pipelet is a **factory function** which instances:
- Maintain a **dataset** state, in memory, mass storage, the DOM, or virtually (stateless)
- **Subscribe to** data change events from **upstream** pipelets
- **React** to upstream events to update their dataset
- **Emit** change events to **downstream** pipelets
- Have **no side effects** on other pipelets upstream or downstream
- Are **piped** to upstream and downstream pipelets using the **'.' operator**
- May be connected to additional pipelets using parameters
- Can be **composed** with other pipelets to provide new pipelets

A Toubkal program is a JavaScript program where one can mix imperative-style programming
with Toubkal declarative-style programming.

Toubkal's **Publish / Subscribe** reactive model allows to solve the **how** so that you
don't have to deal with it.

To make it easier, the API describes **what** you want in **plain JavaScript** without
requiring a graphical UI to glue hard-coded and hard-to-comprehend xml or json "nodes"
and "links" together as many other dataflow libraries require.

Toubkal reactive dataflow model provides higher level abstractions handling under the
hood both subscribe dataflows and information push dataflows that allow to move the
least amount of information possible between clients and servers reactively.

### Toubkal Publish / Subscribe Dataflow Model

The following describes implementation details implemented at Toubkal's low level.
Application Architects do not need do program anything for this to happen as it is
entirely hidden by Toubkal pipelets. Understanding of the underlying model helps understand
why Toubkal is so efficient and how it scales.

Most dataflow libraries usually implement one of two models:
- push: all data is pushed downstream as it happens, allowing realtime updates
- pull: data is pulled upstream when needed, allowing lazy programming, pulling only what
is required, when required

For web applications' communications between servers and clients these two models are
usually not acceptable for these reasons:

- The pull method is not reactive, introducing average latency of the polling period.
Worse it and can consume large amounts of bandwidth if the polling period is too small.
It can nonetheless be used efficiently on the client side along with
requestAnimationFrame() to prevent over-updating the DOM between refreshes.
- The push method pushes all data regardless of what the downstream many need. This can
result in the transmission of large amounts of unused data, usually introducing
unacceptable latency and bandwidth charges.

Toubkal implements a **Publish / Subscribe** model where downstream pipelets subscribe to
the subset of data they are interested in and subsequently receive all updates in a push
fashion only for that subset. This allows Toubkal to move less data between clients and
servers while remaining realtime with lower latency.

Toubkal stateless pipelets use a lazy model where they will not subscribe to anything
from upstream unless initial data is fetched by a downstream stateful pipelet. This again
allows to transmit only what is really used by the application at any given time.

A subscription is done using a query dataflow that represents a kind of filter on the
upstream dataflow. Because the query is itself a dataflow, the subcription can change
over time.

When tens of thousands of downstream pipelets subscribe to a single pipelet using
different queries, Toubkal provides a query tree that routes data events very efficiently
in O( 1 ) time (i.e. that does not depend on the number of connected clients) therefore
providing a more scalable solution within a single server. Sending actual data to n
clients out of N connected clients is O( n ) so actual performances depends on the
application (i.e. whether n << N or not).

A network of Toubkal servers can be arranged in a tree-like fashion to provide
unlimited size query trees, e.g. to dispatch data to millions of simultaneous clients.
Each server subscribes to its upstream server the subset of data it dispatches to
downstream servers and clients. This allows efficient and low-latency routing thanks
in part to the high performances of each individual server query tree.

#### Data Events, Operations, Stateless Sets and Pipelets

Internally, Toubkal dataflows represent the evolution of data sets over time where
each event modifies a set. These dataflows are therefore reactive sets change flows.

Each event carries an opperation name such as *add* or *remove* and an array of values
to add to, or remove from, a set.

**Stateless** pipelets process values which are not materialized either in memory or
other storage, their state is vitual.

Stateless pipelets process data events independently of all other events and values in
the set allowing faster operations and lower memory footprints.

Stateless pipelets can therefore process events out of order, much like Internet Protocol
packets can be routed through various paths within the Internet and may arrive at their
destinations in any order.

#### Stateful Pipelets

A **Stateful** pipelet maintains the state of a set either in memory, in mass storage,
or any other API that provides a storage behavior.

User Interface pipelets are stateful as these present the state of a set through the DOM.

Much like the TCP protocol in the Internet which is responsible for end-to-end
communications consistency, Stateful pipelets may receive data events in any order and
are responsible for maintaining an application-consistent state.

Stateful pipelets are implemented thanks to the stateful set() pipelet that is typically
used as a base pipelet for stateful pipelets.

Also, much like the TCP protocol, stateful pipelets are found at the edges of a
Toubkal network of stateless pipelets.

#### Horizontal Distribution

Allowing out-of-order data events is a key feature of Reactive Sets which greatly eases
horizontal distribution of workloads and charding, because no synchronization is needed
between chards that may be processed in parallel either over a number of threads,
processes, or servers in a true share-nothing architecture.

#### Incremental Processing

Incremental sets processing allows to split large sets into optimal chunks of data
rendering data to end-users' interface with low-latency, improving end-user experience.
Data events update sets in real-time, on both clients and servers.

Incremental aggregates allow to deliver realtime OLAP cubes suitable for realtime data
analysis and reporting over virtually unlimited size datasets.

#### Loops, Just-In-Time Code Generation

Toubkal data events contain arrays of values which are typically processed in loops. In a
traditional programming environement, one typically writes code that processes values in
loops. With Toubkal, architects do not write loops because these are absracted away as sets
processed by pipelets.

This greatly simplifies programming while removing the likelihood for common programming
errors.

Highest performances are provided thanks to Just-In-Time code generators delivering
performances only available to compiled languages such as C or C++. Unrolling nested
loops provide maximum performance while in turn allowing JavaScript JIT compilers to
generate code that may be executed optimally in microprocessors' pipelines.

#### Toubkal Low-Level Pipelet Programming

At the lower level, Toubkal **Pipelets** use a JavaScript functional programming model
eliminating the typical callback hell of asynchronous request-response programming
models.

Error and log dataflows originating on clients can easily be routed to servers to allow
proactive debugging of errors while in production, and effective service quality
monitoring.

Transactions allow to group related operations over time and allow synhronization
of concurrent dataflows.

Developping stateless pipelets is straightforward, requiring to write a simple and
simple transform function very much akin pure functional programming. Stateless Pipelets
API takes care of everything else, managing add, remove, fetch functions as well as
transactions.

Developping stateful pipelets requires to implement add and remove functions, a fetch
function to return initial state, and properly handle transactions and out-of-order
operations.

### Service Architecture

With Toubkal, services are typically composed of three different services:

- A stateful network of persistent database and external services pipelets
- A stateless network of event dispatchers, acting as a marshalled multicasting network
for dataflows
- A stateful network of client widgets delivering applications to end-users

For small applications with few simultaneous users the first two typically reside in a
single server, while complex applications with large number of active users will be
running on different servers. Because pipelets share no state they can easily be
distributed.

A company could run multiple services through a single network of stateless event
dispatchers, acting as web service aggregator.

The different nodes of a Toubkal network communicate using the Toubkal protocol that
provides the Publish / Subscribe service over a reliable transport (such as Sockets,
WebSockets, ...) but not necessarily guarantying the order of packets. So Toubkal could
also work over a protocol that would only guaranty the delivery of packets.

The Toubkal protocol therefore provides a higher level alternative to existing web
services protocols such as SOAP and REST, allowing to build efficiently complex real-time
applications with no additional code and less documentation since only application
dataflows need to be documented.

### Realtime Data Portability, Business Opportunities

A network of services sharing the same event dispatcher network enables to effectively
separate **Toubkal Data Providers** from **Toubkal Application Providers** increasing
business opportunities arising from the portability of reactive dataflows updated in
real-time and as authorized by end-users and data-licenses.

Within a Toubkal network, end-users no longer need to duplicate their personal data
endlessly and updates are propagated to all applications in realtime putting an end
to today's world of out-of-date data between services.

People will now expose their data, using a variety of services to view, edit, and publish
their data to other people.

Using only stateless pipelets, this architecture will reach internet-scale very
efficiently, delivering a Marshalled publish / subscribe multicasting data exchange
for services to share data among many service providers, while representing a business
opportunity for **Toubkal Network Providers** much like today's CDNs but for marshalled
dynamic real-time content solving caching issues thanks to the immutability of data
events.

To participate in this network, service providers only need to publish dataflows and/or
subscribe to third-party dataflows.

End-users may use these services to backup their own data either on owned servers or
using third-party Toubkal Data Providers.

End-Users control access to their own data through Toubkal Authorization dataflows
providing additional business opportunities for **Toubkal Authorization Management Providers**
helping end-users manage authorizations for all their data accross all their Toubkal
Applications.

Monetization of dataflows and applications can be controlled through Toubkal reactive
authorizations by **Toubkal Monetization Providers**.

Disruptive new business opportunities arrising from **Toubkal Realtime Data Portability**
will prove stronger than the current closed, data-within-application model, resulting in
more data and more services available to more users and businesses.

### Ecosystem

Toubkal backend runs on **Node.js** providing a scalable database, web
server, validation, and authorizations.

On the frontend, Toubkal provides reactive controlers and views driven
by reactive dataflows.

Toubkal can optionally be coupled with any other framework but we
recommend using reactive libraries such as **AngularJS**, **Ember**,
**Bacon.js**, **React**, which model is closer to Toubkal.

For responsive layouts, we recommand **Bootstrap** that we use it for our
reactive Carousel and Photo Albums.

For DOM manipulation one can use any library, or none at all, as Toubkal
core has no dependencies.

Toubkal can either be used to gradually improve existing applications on
the back-end or front-end, or as a full-stack framework.

### Integrated reactive database and model

Toubkal features a reactive database model with joins, aggregates, filters
and transactions with eventual consistency allowing both normalized and
denormalized schemes.

A reactive MySQL driver for Toubkal is available at
[https://github.com/ReactiveSets/toubkal_mysql](https://github.com/ReactiveSets/toubkal_mysql).

## Roadmap and Release Notes

Current work in progress is for version 0.4

### Version 1.0 - Finalize core, packaging, and framework

#### Main Goals

- Core
  - Develop additional tests, goal is at least 3000 continuous integration tests
  - Implement as many ToDo as possible
  - Super-state and versioning
    - define attribute _v for versions, allowing to manage complete anti-state and super-state
    - super-state will contain versions of an object added after a first version is already in the state
      - allow complete desorder between multiple adds and revmove on the same object defined by its id
  - Versionned persistance
    - Dataflows Meta Data for key, and query indexes definition
    - Operations log
    - Query cache

- Packaging
  - toubkal package manager
  - split this repository into toubkal (core), toubkal_server, toubkal_client, toubkal_socket_io, toubkal_bootstrap, ...
  - automatic pipelet patching

- Framework
  - Social login client pipelet
  - Notifications
  - PWA
  - Client SPA navigation / routing pipelet
  - Navigation pipelets
  - Internationalization
  - Session Strorage Dataflow
  - Refactor Web Server API to better integreate with Express
    - Bug with routing algorythm for / route
    - Fix updates
  - Finalize server-side rendering
    - using html_parse() to insert elements into a DOM tree
    - using html_serialize() to rebuild modified html to server
    - using $query_selector() to select into htmlparse2 tree
    - using $to_dom() to modify htmlparse2 tree (not implemented)

### Version 0.4.0 - Transactional Operations / Complex Expressions / DOM Handling / Documentation

Work In Progress.

We are almost done with this major release which we currently use in production
applications for clients.

#### Main goals remaining

- Complete Safe Complex Query expressions
  - Complex query to SQL query
  - Implement stateful features as operators, options, or special attributes
    - limit value
    - order_by expressions [,descending]
    - group_by dimensions, measures
    - pick

- Error routing, eventual consistency
  - pipelet to push / pop sender, route errors to sender
  - eventual consistency with pipelet next()
    - on error, update rejected value with new next value

- Rewrite and complete lib/server/file.js pipelets
  - fs_watch()
  - fs_lstat()
  - fs_read_file()
  - fs_read_link()
  - fs_read_directory()
  - fs_write_file()
  - fs_append_file()
  - fs_chmod()
  - fs_chown()
  - fs_mkdir()
  - fs_rmdir()
  - fs_mkdirp()
  - fs_link()
  - fs_symlink()
  - fs_unlink()
  - fs_rename()
  - configuration() write
  - watch() and watch_directories() should be composed from redesigned
  pipelets.

#### Work in progress

- 1942 Continuous Integration tests
  - Exceeded goal which was at least 1750 continuous integration tests

- Error routing, eventual consistency
  - Rollback transactions to recover from errors
    - Using revert(), reverting add into remove, remove into add, and swapping update operations

- Complex authorizations and validation
  - using adds(), removes() and updates() to differentiate between Create,
  Delete and Update operations and apply authorization rules accordingly.
  - use pipelet fetch() to check authorizations.
  - using not_exists() to test appropriate existance on adds, removes and updates.

- Toubkal site, featuring documentation and examples
  - Documatation available as a single page

#### Completed Work (versions 0.3.x, x > 0)

- Pipelets alter() amd map() now allow assynchronous cancelable transforms
  using functions cancelable_map() and cancelable_limiter(). This form
  also allows filter() and flat_map() behavior.
  
  If transform has more than 2 parameters it is consided stateful.

- Safe Complex Query expressions
  - Query and Query_Tree methods
    - Query..generate(): Generate filter code from complex queries
    - Query..and(): AND complex queries
    - Query.least_restrictive_keys(): optionally try to determine which
    AND-expression describes the largest set. Optimized for expressions
    with one compararison operator in '<', '<=', '==', '>=', '>'. 
    - Query..differences(): Allow comparison of complex queries using
    value_equals().
    - Query_Tree..add(): Add complex query terms into query tree
    - Query_Tree..remove(): Remove complex query terms from query tree
    - Query_Tree..route(): Route operations with complex queries
  
  - Sanitized for safe execution on server even when crafted by untrusted clients
  
  - For execution by upstream servers to reduce bandwidth, cpu usage and latency
  
  - JSON Objects and Arrays for any JSON transport
  
  - Side-effect free
  
  - Any depth Abstract Syntax Tree, may be limited to prevent Denial of Service attacks
  
  - Consistent and rich semantic
    - Nested Object and Array expressions
    
    - Regular expressions
    
    - All progressive operators, allowing to express the follozing:
      ```18 <= age <= 25```
      ```sales / ( 0 != count ) > 1000```
  
  - Operators
    - Control flow       : ```&& || ! failed reset```
    - Literals           : ```$ $$```
    - Deep inspection    : ```. _ __```
    - Grouping           : ```[]```
    - Comparison         : ```== != > >= < <=```
    - Ranges             : ```<< <=< <=<= <<=```
    - Search in Array    : ```in```
    - Search in set      : ```in_set```
    - Arithmetic         : ```+ - * / %```
    - Regular expressions: ```RegExp match match_index group split```
    - Array / String     : ```length```
    - Object valueOf     : ```value```
    - Date               : ```Date year month day hours minutes seconds milliseconds time```
    - Custom operators   : defined using JavaScript functions but used as JSON Strings and Arrays to prevent code-injection
  
  - Example: Expression to get active users whom last logged-in between 2005 included and 2013 not included:

```javascript
    {
        flow   : 'user'
      , active : [ '==', true, '||', '==', 1 ]
      , profile: {
            last_logged_in: [ '$', 2005, '<=', [ 'year' ], '<', 2013 ]
        }
    }
```

- Redesign of Plug.._fetch() && ..update_upstream_query():
  - Synchronize update_upstream_query() and fetch() to guaranty data consistency
  - Fetch receivers can now receive removes, updates and operations options, allows complementary sets
  - Allow query transforms on all plugs
  - Filters fetch_unfiltered() if defined
  - Filters through _transform() if defined
  - Cancel ongoing fetches when pipelet disconnects (still needs to revert previously fetched values)
  - Abort cancelled fetches upstream for which fetched values will be ignored
  - Union support for adding and removing sources while fetching
  - Union fetch signals terminated sources downstream allowing to listen to these source while other sources terminate
  - All plugs now have a source, enables plugs pipelines for fetch() && update_upstream_query()
  - Implemented in Plug base class of all inputs and outputs
  - Replaces all implementations of fetch on inputs and outputs
  - Forward compatible with fetch() API, the API may be deprecated once migration to new API is complete

- Allow automatic synchronization of all inputs of a pipelet, as long as one
  uses method Pipelet.._add_input() to add additional inputs. This relies on
  sharing input transactions between all inputs, and other modifications to
  make this work properly on controllets. Implemented in filter() and
  $to_dom().

- Reinstate update as a first-class operation, making it easier to handle updates

- Documentation extraction format from source code comments:
  - Using pipelets:
    - acorn()
    - documentation_manuals()
    - parse_documentation()
    - documentation_markdown()
    - markdown()
  
  - highly targeted towards Toubkal dataflow programming
  
  - augmented github-flavored markdown
  
  - output as dataflow, suitable for transformations to github-flavored markdown, plain html, and more
  
  - Input format:
    - inside any comments
    - line-oriented
    - indentation-sensitive
    - can contain github-flavored markdown
    - The "@" character is interpreted as meta-data for this format, can be escaped using the "\\" character. 

  - @tag: indicates a documentation sub-section, first tag in a comment indicates start of documented item:
    - if tag is followed by a column ":", the sub-section is multiline, otherwise it is contained on a single line
    - if an unknown tag is found, a warning is emitted
    - plurals indicate a list of items described in paragraphs starting with a hyphen "-"

    - list of top-level tags:
    
      Tag           | Description
      --------------|---------------------------------
      @term         | a term
      @namespace    | namespace, e.g. "rs"
      @flow         | a dataflow name
      @pipelet      | pipelet signature
      @function     | function signature
      @class        | a class constructor signature
      @method       | instance method signature
      @class_method | class method signature

    - documentation items attributes:
    
      Attribute     | Desciption
      --------------|--------------------------------------------------------
      @is_a         | parent class name or list of
      @short        | a short description on one line
      @description  | a long description
      @parameters   | list of pipelet, function, method parameters
      @returns      | function or method returned value
      @throws       | list of conditions that throw errors
      @examples     | list of usage examples
      @source       | expected source values' attributes
      @emits        | emitted output values' attributes
      @todo         | suggestion for future version
      @coverage     | indicates automatic tests coverage
      @manual       | a documentation manual name this belongs-to
      @section      | a section name within a manual
      @api          | indicates API maturity: experimental, alpha, beta, stable, deprecated
  
  - @@keyword: indicates a link to another section of the documentation:
    - e.g. This is @@stateless, @@synchronous, @@lazy pipelet.
    - If keyword is a plural and no entry is found for it, attempt to locate it's singular form
    - If it cannot be located, a warning is emitted

  - many pipelets, functions and methods are already following this documentation format

- Transactional design patterns and pipelets
  - fetch(): Fetches the current state of a store dataflow based on source events
  - fetch_as(): Set attribute with fetched values from store by fetch_query
  - fetch_first(): Set attribute with first fectched value from store
  - update_fetched(): Update fetched values in a transaction
  - fetched_differences(): Emits differences (A - B) between two fetched sets A then B
  - emit_operations(): Emits remove, update, and add operations in a transaction

- Hot server-code reloading:
  - on required module file update
  - migrating state reliably
  - simple to implement:
    - programmer describes disconnections from dataflows
  - in a transaction allowing optimization of updated data using optimize()
  - implemented in examples/teaser/data.js

- Live page reload to ease developpement, implemented in examples.

- Namespaces:
  - allow local scoping of singletons, multitons, outputs

- Pipelet._add_input() greatly simplifies adding additional inputs to pipelets.

- Single page applications routing:
  - using url_parse() and url_pattern()

- DOM handling pipelets:
  - $query_selector()
  - $to_dom()
  - $on()
  - $window()
  - window_size()
  - $add_class()
  - $has_class()
  - $has_not_class()

- Improve programming patterns using pipelet methods:
  - Compose()
  - Singleton()
  - Multiton()
  - through()
  - set_output()
  - output()
  - remove_source_with()
  - remove_destination_with()

- Pipelets manipulating operations:
  - store(): Store operations history
  - creates(): Discard remove and update operations.
  - deletes(): Only forward remove operations
  - updates(): Only forward update operations
  - adds(): filter add operations, useful when these have a strict Create semantic
  - removes(): filter remove operations, useful when these have a strict Delete semantic
  - revert(): transforms adds into removes, removes into adds, swap remove and add into updates
  - query_updates(): Emit query updates from pipelet

- Additional functional stateless pipelets:
  - map(): allows to emit zero or 1 value for each source value
  - flat_map(): allows to emit zero to n values for each source value
  - pick()
  - filter_pick()

- Additional functional stateful pipelets:
  - group(): emit grouped values into content attribute

- Caches (stateful lazy pipelets):
  - cache(): Stateful and lazy pipelet
  - database_cache(): Cache for an entire database from schema

- Server pipelets:
  - require_pipeline(): Load, and auto-unload, a module exporting a Toubkal pipeline
  - path_relative(): Alter path using node path.relative()
  - path_join(): Prepend base directories to relative ```"path"```, resolve ```"~"``` to home directory
  - Based on the piexif library, handling JPEG EXIF:
    - piexif_parse(): Parses content EXIF using the piexifjs library
    - piexif_insert(): Inserts EXIF into content, using the piexif library
  - json_hide(): Hide attribute values in downstream pipelets using JSON.stringify()

New Pipelets or method              | Short Description
------------------------------------|--------------------------------------------------------------
fs_stat()                           | Gets file or directory stat information
child_process_exec                  | Executes a command in a child process
rename_properties                   | Renames properties
store()                             | Store operations history
json_hide()                         | Hide attribute values in downstream pipelets using JSON.stringify()
debug()                             | Conditional trace()
source_map_support_min()            | Provides minified asset for browser source map support
remove_destination_with()           | Disconnect pipelet's first destination when source disconnects
remove_source_with()                | Disconnect pipelet's input when source disconnects
path_relative()                     | Alter path using node path.relative()
path_join()                         | Prepend base directories to relative ```"path"```, resolve ```"~"``` to home directory
require_pipeline()                  | Load, and auto-unload, a module exporting a Toubkal pipeline
socket_io_synchronizing()           | Emits start of synchronization events, collects synchronized events
socket_io_state_changes()           | Pipelet socket_io_server() connections' state changes
fetched_differences()               | Emits differences (A - B) between two fetched sets A then B
emit_operations()                   | Emits remove, update, and add operations in a transaction
modules_files()                     | Singleton dataflow of toubkal modules' files from toubkal/lib/modules.json
piexif_insert()                     | Inserts EXIF into content, using the piexif library
piexif_parse()                      | Parses content EXIF using the piexif library
markdown()                          | Markdown to html converter using "remarkable" and "highlight.js"
documentation_manuals()             | Toubkal documentation manuals metadata (not content)
documentation_markdown()            | Format documentation items into markdown
parse_documentation()               | Emit documentation items from parsed "comments" attribute
acorn()                             | Parse javascript "content" attribute using the acorn library
process_variables()                 | Gets command line arguments, environment variables, and more
database_cache()                    | Cache for an entire database from schema
cache()                             | Stateful and lazy pipelet
query_updates()                     | Emit query updates from pipelet
filter_pick()                       | Select source dataflow from matching parent dataflow values
delivers()                          | Specifies which upstream dataflows can be subscribed-to
$has_not_class()                    | Emits source values which have a $node attriute without css_class set
$has_class()                        | Emits source values which have a $node attriute with    css_class set
$add_class()                        | Add css_class to $node attribute
window_size()                       | Provide a dataflow of window size change events
$window()                           | Singleton for the global Window
$on()                               | Listen and emits DOM events registered using addEventListener()
throttle_last()                     | Emit last received source value before throttle events, without throttle events
throttle()                          | Emit last received source value before throttle events
update_fetched()                    | Update fetched values in a transaction
fetch()                             | Fetches the current state of a store dataflow based on source events
fetch_as()                          | Set attribute with fetched values from store
fetch_first()                       | Set attribute with first fectched value from store
pick()                              | Forwards only specified attributes
has_none()                          | Has one value if source has none, has no value if source has one
log_namespace()                     | Helps debug namespace issues
namespace()                         | Get namespace of current pipelet
set_namespace()                     | Set namespace of current pipelet
create_namespace()                  | Create child namespace of current pipelet or namespace
$query_selector()                   | Emits a node if query selector found, used as a parameter to $to_dom()
output()                            | Retrieves a global reference for an output pipelet set by set_output()
set_output()                        | Sets a global reference for an ouput pipelet
revert()                            | Revert operations, adds to removes, removes to adds, updates are swapped
animation_frames_polyfill()         | animation_frames() polyfilled
url_pattern()                       | Parses url for patterns such as /users/:id
Multiton()                          | Creates multiton pipelets out of composition
Singleton()                         | Creates singleton pipelets out of composition
Compose()                           | Add boolean options single and singleton
$to_dom()                           | Updates DOM from dataflow for a DOM node, using render function, creating container child
through()                           | Getting dataflow through another pipelet (implemented a Pipelet method)
not_exists()                        | Existence validation for dataflow adds (no-exists), removes and updates (exists)
fetch_flow_key()                    | Fetch dataflow key from flows metadata
creates()                           | Discard remove and update operations.
deletes()                           | Only forward remove operations
updates()                           | Only forward update operations
adds()                              | Selects "add" operations only, operations that create objects
removes()                           | Selects "remove" operations only, operations that remove objects
group()                             | Group input values by function into content attribute
map()                               | Maps input values to function returning a single value or falsy
flat_map()                          | Maps input values to function returning an Array of output values

### Version 0.3.0 - Authentication && Authorizations, Persistance - November 12th 2015

Allows to build complex streaming applications with Social Authentication and MySQL persistance.

Pipelet API has been significantly refactored and getting close to version 1.0 API.

- 1486 continuous integration tests

- Reactive Authentication with Passport:
  - passport_profiles(): authenticated user profiles dataflow
  - Provider credentials from configuration file
  - Strategies initialization
  - Strategies routes from initialized strategies
  - Integration with socket_io_clients()
  - Express session support:
    - Providing a session_store() dataflow
    - Providing a Express_Session_Store(), an Express session store
    - Getting users form session_store() with passport_user_sessions()
    - In serve() to allow to set session when serving static assets
    - In socket_io_clients() to retrieve session id
  - Multi-provider Sign-in Widget example from initialized strategies
  - Reactive Authorizations example from session id and session_store()

- Web Storage API:
  - local_storage( flow ) pipelet
  - multiton (one singleton per dataflow )
  - supports both localStorage and sessionStorage via storage option
  - listens to other pages "storage" events to update in realtime dataflow

- MySQL read/write dataflows pipelets:
  - mysql(): provides read/write dataflows for MySQL table, uses lower-level pipelets:
    - mysql_connections(): manages MySQL connections
    
    - mysql_read(): statelessly read MySQL table:
      - Builds SELECT .. WHERE from downstream query
    
    - mysql_write(): statelessly writes (DELETE and INSERT) to MySQL table
    
    - configuration(): to retrieve MySQL user credentials, removing credentials from code

- react(): Facebook React client-side pipelet

- beat(): a pipelet to emit events at time intervals
- once(): a pipelet to emit a single event after a timeout
- next(): a pipelet to maintain auto-incremented attributes on trigger

- Operations Optimizer:
  - waits for transactions to complete to emit operations
  - on transaction completion, emits optimized operations, i.e. the minimum set of adds, removes and updates

- join() pipelet:
  - Adding exhaustive tests suites (517 tests total)
  - Finalize outer joins (left, right, full) with transactions handling
  - Implement dynamic filters on inner and right join to reduce data pull
  - Optmizations: stateless output
  - Refactoring and documentation

- Examples:
  - Examples server to serve assets and data for client examples, using configuration files for datasets
  - Teaser using socket_io_server(), flow(), filter(), order(), trace(), and table()
  - Reactive user table with react()
  - Chat using socket_io_server() and form()

- Refactor / stabilize pipelet API

- Error handling using 'error' dataflow
  - Error values have the following attributes:
    - flow (String): the string 'error'
    - code (String): the error code
    - message (String): an optional error message
    - operation (String): 'add' or 'remove', the operation that caused the error
    - error_flow (String): the flow for which the error occurred
    - sender (String): an identification of the sender of the operation to allow
      routing back to sender. Sender's valued comes from operations option 'sender'
    - values (Array of Objects): the values for which the error occurred
  
  - Allows downstream pipelets to handle errors by reverting failed operations:
    - a failed add is reverted by remove
    - a failed remove is reverted by add
    - errors can be routed back to sender using filters for the flow and sender attributes

  - Error dataflow is handled specifically by some core pipelets:
    - set_flow() does not alter the flow attribute when set to 'error'
    - unique() forwards incomming errors to underlying set
  
- Refactor modules, packaging:
  - use undefine() to load modules from any situation, node, browser, AMD loaders
  - split into meaningful subdirectories to eventually split the project into subprojects

- Concurrent Transactions Synchronization with branch tags

- Refactor pipelet class model:
  - Ease the definition of multiple, semantically distinct, inputs and outputs without definining pipelets
  - Define Plug base class for:
    - Inputs (Pipelet.Input)
    - Outputs (Pipelet.Output)
  - Pipelet.Input class:
    - Receives data events from upstream to be processed by pipelet
    - Provides upstream transactions management
    - Provides methods for connectivity to source outputs
    - Fetches upstream data as requested by pipelet
    - Determines lazyness
    - Emits upstream query updates
  - Pipelet.Output class:
    - Provides methods for connectivity to destination inputs
    - Fetches 
    - Fetches and filters pipelet's state
    - Emits data events to downstream inputs using query trees
    - Emits transaction events
    - Manages output transactions
    - Updates query tree from downstream query updates
    - Propagates query updates to pipelet
    
  - Pipelet modified class:
    - Manages state
    - Defaults remains stateless (i.e. uses altered upstream state)
  
  - RS.Options object defined methods for manipulating operations' options:
    - forward(): returns an options Objects with options that must be forwarded
    - has_more(): returns truly if there is an incomplete transaction

New Pipelets                        | Short Description
------------------------------------|--------------------------------------------------------------------------------------
passport_profiles()                 | Manages Passport authenticated user profiles
passport_strategies_configuration() | Watch configuration file for passport strategies
passport_strategies()               | Initialize Passport strategies
passport_strategies_routes()        | Updates strategies routes from initialized strategies
express_route()                     | Reactive express routes middleware
session_store()                     | A session store implemented as a bidirectional dataflow
passport_user_sessions()            | Get Passport authenticated users from session_store() and session id
content_order()                     | Orders the array of values contained in a content attribute
content_sort()                      | Sorts the array of values contained in a content attribute
content_transform()                 | Modifies content attribute using a transform()
content_route()                     | Add a route and express middleware handler for a content
values_to_attribute()               | Embed input values under a content attribute of a single output value.
beat()                              | Emit events at time intervals
once()                              | Emit an event on timeout
local_storage()                     | Implements Web Storage API
next()                              | A pipelet to maintain auto-incremented attributes on trigger
mysql()                             | In toubkal_mysql repository, provides read/write dataflows to/from MySQL tables
optimize()                          | On complete, remove unnecessary adds, removes, updates, emit updates when possible
html_serialize()                    | Serialize DOM tree generated by html_parse()
html_parse()                        | Parse html content to htmlparser2 DOM tree
react_table()                       | Reactive table rows and columns implemented using react()
react()                             | Transform a full set to a DOM widget using a Facebook React render function
http_listen()                       | Listen to http servers, allows to get the 'listening' event (used by socket.io 0.9 for its garbage collector)
virtual_http_servers()              | Allows to run many frameworks and socket.io servers virtual hosts
serve_http_servers()                | Bind http event handlers to HTTP_Router()
greedy()                            | A non-lazy stateless pipelet
make_base_directories()             | Create base directories for a dataset of file paths

Other Classes && methods  | Short Description
--------------------------|---------------------------------------------------------------------------------------------------------
Express_Session_Store()   | An Express session store using a bidirectional dataflow as the underlying store
value_equals()            | Allows comparison of any types of values, including deeply nested objects and arrays
undefine()                | Universal module loader for node and the browser, exported as own npm module
Lap_Timer                 | Helps calculate time difference between events, used by loggers
Console_Logger            | Logger to console.log() with timestamps and lap lines 
Client assets             | Sets to ease assembly of minified files for clients
HTTP_Router               | Efficiently route HTTP requests using base URLs
Lazy_Logger               | Logger controlled by queries using '<=' operator
Query_Error               | Custom Error class for Queries
Query.Evaluation_Context  | Evaluation context for complex query expressions
Query.evaluate()          | Query class method to evaluate complex query expressions
Query.Operator()          | Adds a Query expression operator
Query.fail                | Failure value for Query expressions
Plug                      | Base class for Input and Output plugs
Pipelet.Input             | Pipelet default Input plug
Pipelet.Output            | Base Output plug
Controllet.Input          | Input plug for controllets
Controllet.Output         | Output plug for controllets
Union.Input               | Input plug for Union (allows many sources)
Union.Output              | Output plug for Union
Set.Output                | Output plug for Set
IO_Transactions           | Base class for Input_Transactions and Output_Transactions
Input_Transactions        | Concurrent Transactions Synchronization at Inputs
Output_Transactions       | Concurrent Transactions Synchronization at Outputs
IO_Transaction            | Base class for Input_Transaction and Output_Transaction
Input_Transaction         | Manage an input transaction
Output_Transaction        | Manage an output transaction

### Version 0.2.0 - Publish / Subscribe Dataflow Model - March 31 2014:

- Finalize Publish / Subscribe reactive dataflow model using optimized Query Tree Router and lazy connection of stateless pipelets
- Filter support for static and dynamic queries
- Transactions
- Automate UI tests on Travis
- 309 continuous integration tests
- Controllets which control upstream query trees using downstream queries
- Improve Pipelet API and naming conventions
- Virtual Hosts w/ optimized routing
- Touch Events on bootstrap pipelets

New Pipelets              | Short Description
--------------------------|------------------------------------------------
watch_directories()       | Updated when entries in directories are updated
url_events()              | Browser url changes
animation_frames()        | Request Animation Frame events
encapsulate()             | Hide a graph of pipelets behind one pipelet
require_resolve()         | Resolve node module files absolute path
timestamp()               | Add timestamp attribute
events_metadata()         | Add events metadata attributes
auto_increment()          | Add auto-increment attribute
set_flow()                | Add flow attribute
to_uri()                  | Transforms a relative file name into a DOM uri
thumbnails()              | Image thumbnails using ImageMagick
load_images()             | Load images in the DOM one at a time
bootstrap_carousel()      | Bootstrap responsive images carousel 
bootstrap_photos_matrix() | Bootstrap responsive photo matrix
bootstrap_photo_album()   | Bootstrap responsive photo album
json_stringify()          | JSON Stringifies content attribute
json_parse()              | JSON parse content attribute
attribute_to_value()      | Replace value with the value of an attribute
value_to_attribute()      | Sets value as an attribute and add other default attributes

### Version 0.1.0 - April 8th 2013:

#### Features:

- Push reactive dataflow model with lazy evaluation of stateless pipelets
- Core Database engine with order / aggregates / join / union, and more
- Automated tests
- Dataflows between clients and server using socket.io
- DOM Tables w/ realtime updates
- DOM Controls as dataflows: Drop-Down / Radio / Checkboxes
- DOM Forms with client-side and server-side validation
- Realtime Minification using Uglify w/ source maps
- HTTP(s) servers
- File watch w/ realtime updates
- JSON Configuration Files w/ realtime updates

Core Pipelets             | Short Description
--------------------------|------------------------------------------------
set()                     | Base stateful pipelet
unique()                  | Set of unique values, discarding duplicates
filter()                  | Filters a dataflow
order()                   | Order a set
ordered()                 | Follow an ordered set (typically derived)
aggregate()               | Aggregates measures along dimensions (GROUP BY)
join()                    | Joins two dataflows
watch()                   | Dataflow updated on file content changes
dispatch()                | Dispatches dataflows to a dataflow of branches
parse_JSON()              | JSON dataflow to parsed JSON dataflow

Server Pipelets           | Short Description
--------------------------|------------------------------------------------
uglify()                  | Minifies a dataflow of files into a bundle, using [Uglify JS 2](https://github.com/mishoo/UglifyJS2)
http_servers()            | A dataflow of http servers
serve()                   | Serve a dataflow of resources contents to http (or other) servers
socket_io_clients()       | A dataflow server for socket.io clients
socket_io_server()        | A dataflow client for socket.io server
send_mail()               | Send emails from email dataflow
configuration()           | Dataflow of application configuration parameters

DOM Pipelets              | Short Description
--------------------------|------------------------------------------------
table()                   | DOM table bound to incoming dataflows
form()                    | DOM Form using fields dataflow, emiting submited forms
form_validate()           | Client and server form validation
checkbox()                | DOM input checkbox
checkbox_group()          | DOM input chexbox group
radio()                   | DOM radio button
drop_down()               | DOM drop-down menu

EC2 Pipelets              | Short Description
--------------------------|------------------------------------------------
ec2_regions()             | Set of AWS EC2 regions, starts ec2 clients

## Licence

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
