# frozen_string_literal: true

require 'rethinkdb'

# Import Driver
include RethinkDB::Shortcuts

# Open a connection
r.connect(host: 'localhost', port: 28_015).repl

# Delete a table/document
r.db('test').table_drop('turbina').run

# Create a table/document
r.db('test').table_create('turbina').run

# Realtime feeds
puts 'Real-time feeds'
cursor = r.table('turbina').changes.run
cursor.each { |document| p document }
