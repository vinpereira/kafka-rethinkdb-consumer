# frozen_string_literal: true

require 'rethinkdb'

# Import Driver
include RethinkDB::Shortcuts

# Open a connection
r.connect(host: 'localhost', port: 28_015).repl

# Delete table
r.db('test').table_drop('turbina').run
