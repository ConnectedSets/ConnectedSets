
###
    all_tests.coffee
    
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

# -------------------------------------------------------------------------------
# require modules tests
# ---------------------

# utils
require './javascript'
require './escape'
require './clone'
require './value_equals'
require './object_diff'
require './lazy_logger'
require './query'
require './event_emitter'
require './transactions'
require './extend'
require './subclass'
require './code'
require './picker'

# core
require './RS'
require './pipelet'
require './set'
require './store'
require './unique'
require './filter'
require './order'
require './aggregate'
require './join'

require './json'
require './transforms'
require './require'
require './file'
require './html_parse'
require './html_serialize'
require './url'
require './to_uri'
require './query_selector'

require './mailer'
require './server'
require './patch'

try
  require.resolve 'zombie'
  require './ui'

