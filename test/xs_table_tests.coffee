# ----------------------------------------------------------------------------------------------
# parse an HTML table to a Javascript object
# ------------------------------------------

from_HTML_to_object = ( o ) ->

# ----------------------------------------------------------------------------------------------
# xs table unit test suite
# ------------------------

# include modules
XS = if require? then ( require '../src/xs.js' ).XS else this.XS

if require?
  require '../src/code.js'
  require '../src/connection.js'
  require '../src/filter.js'
  require '../src/ordered_set.js'
  require '../src/aggregator.js'
  require '../src/table.js'

chai = require 'chai' if require?
chai?.should()

Set         = XS.Set
Table       = XS.Table
Ordered_Set = XS.Ordered_Set

columns   = new Set [ { id: "id", label: "ID" }, { id: "title", label: "Title" }, { id: "author", label: "Author" } ], { name: "Columns Set" }
organizer = new Set [ { id: "title" } ], { name: "Organizer: by title ascending" }

books = new Ordered_Set [
  { id: 1, title: "A Tale of Two Cities"             , author: "Charles Dickens" , sales:       200, year: 1859, language: "English" }
  { id: 2, title: "The Lord of the Rings"            , author: "J. R. R. Tolkien", sales:       150, year: 1955, language: "English" }
  { id: 3, title: "Charlie and the Chocolate Factory", author: "Roald Dahl"      , sales:        13            , language: "English" }
  { id: 4, title: "The Da Vinci Code"                , author: "Dan Brown"       , sales:        80, year: 2003, language: "English" }
], organizer, { name: "Books" }

books.table document.getElementById( "demo" ), columns, organizer, {caption: "List of the best-selling books (source: wikipedia)" }

books.add [
  { id:  5, title: "Angels and Demons"                       , author: "Dan Brown"              , sales:        39, year: 2000, language: "English" }
  { id:  6, title: "The Girl with the Dragon Tattoo"         , author: "Stieg Larsson"          , sales:        30, year: 2005, language: "Swedish" }
  { id:  7, title: "The McGuffey Readers"                    , author: "William Holmes McGuffey", sales:       125, year: 1853, language: "English" }
  { id:  8, title: "The Hobbit"                              , author: "J. R. R. Tolkien"       , sales:       100, year: 1937, language: "English" }
  { id:  9, title: "The Hunger Games"                        , author: "Suzanne Collins"        , sales:        23, year: 2008, language: "English" }
  { id: 10, title: "Harry Potter and the Prisoner of Azkaban", author: "J.K. Rowling"           , sales: undefined, year: 1999, language: "English" }
  { id: 11, title: "The Dukan Diet"                          , author: "Pierre Dukan"           , sales:        10, year: 2000, language: "French"  }
  { id: 12, title: "Breaking Dawn"                           , author: "Stephenie Meyer"        , sales: undefined, year: 2008, language: "English" }
  { id: 13, title: "Lolita"                                  , author: "Vladimir Nabokov"       , sales:        50, year: 1955, language: "English" }
  { id: 14, title: "And Then There Were None"                , author: "Agatha Christie"        , sales:       100, year: undefined, language: "English" }
  { id: 15, title: "Steps to Christ"                         , author: "Ellen G. White"         , sales:        60, year: null, language: "English" }
]

columns.add [ { id: "year" , label: "Year", align: "center" }, { id: "language", label: "Language" } ]
columns.remove [ { id: "id", label: "ID" } ]
columns.update [
  [ { id: "language", label: "Language" }, { id: "sales", label: "Sales by millions of copies" } ]
]


books.remove [
  { id:  1, title: "A Tale of Two Cities", author: "Charles Dickens"        , year: 1859 }
  { id: 13, title: "Lolita"              , author: "Vladimir Nabokov"       , year: 1955 }
  { id:  7, title: "The McGuffey Readers", author: "William Holmes McGuffey", year: 1853 }
]

books.update [
  [
    { id:  2, title: "The Lord of the Rings"                            , author: "J. R. R. Tolkien"         , year: 1955 }
    { id:  2, title: "The Lord of the Rings: The Fellowship of the Ring", author: "John Ronald Reuel Tolkien", year: 1955 }
  ]
  [
    { id: 10, title: "Harry Potter and the Prisoner of Azkaban", author: "J.K. Rowling"  , year: 1999 }
    { id: 10, title: "Harry Potter and the Prisoner of Azkaban", author: "Joanne Rowling", year: 1999 }
  ]
]

