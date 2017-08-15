# frozen_string_literal: true

require 'rethinkdb'

# Import Driver
include RethinkDB::Shortcuts

# Open a connection
r.connect(host: 'localhost', port: 28_015).repl

# # Create a table/document
r.db('test').table_create('turbina').run
