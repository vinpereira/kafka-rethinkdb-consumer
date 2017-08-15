# frozen_string_literal: true

require 'logger'
require 'kafka'
require 'rethinkdb'

logger = Logger.new(STDOUT)

# Import RethinkDB Driver
include RethinkDB::Shortcuts

logger.info 'Connecting to RethinkDB...'

# Open a connection to RethinkDB
r.connect(host: 'rethinkdb', port: 28_015).repl

logger.info 'Connecting to Kafka...'

# Kafka connection
kafka = Kafka.new(
  seed_brokers: ['159.203.96.192:9092'],
  client_id: Random.rand(100_000).to_s,
  socket_timeout: 20,
  connect_timeout: 30,
  # logger: logger
)
logger.info 'Connected to brokers'

# Create consumer
consumer = kafka.consumer(group_id: Random.rand(100_000).to_s)
logger.info 'Consumer created'

topic = 'turbina_oi_processinstance'

# Subscribe consumer to 'turbina_oi_processinstance' topic
consumer.subscribe(topic,
                   start_from_beginning: false,
                   max_bytes_per_partition: 5 * 1024 * 1024)
logger.info 'Topic subscribed'

# If shit happens, stop consumer
Signal.trap('SIGINT') do
  puts 'Stopping consumer...'
  consumer.stop
end

logger.info 'Consuming message...'
# Consume each message, saving it to an ES index
consumer.each_message do |message|
  # Get message content and parse it to Ruby's Hash
  body = JSON.parse(message.value)

  # Get processInstanceId
  proc_inst_id = body['processInstance']['id']

  # Get processInstance data
  proc_inst = body['processInstance']

  # Extract relevant data from message
  relevant_data = {}
  relevant_data[:id] = proc_inst_id
  relevant_data[:process] = proc_inst['processDefinitionName'] unless proc_inst['processDefinitionName'].nil?
  relevant_data[:start_user] = proc_inst['startUser'] unless proc_inst['startUser'].nil?
  relevant_data[:start_time] = proc_inst['startTime'] unless proc_inst['startTime'].nil?
  relevant_data[:end_time] = proc_inst['endTime'] unless proc_inst['endTime'].nil?
  relevant_data[:duration] = proc_inst['duration'] unless proc_inst['duration'].nil?
  relevant_data[:delete_reason] = proc_inst['deleteReason'] unless proc_inst['deleteReason'].nil?

  if body['mutationType'] == 'ADD'
    puts 'ADD Event'

    # Insert data into RethinkDB
    r.table('turbina').insert(relevant_data).run
  elsif body['mutationType'] == 'UPDATE'
    puts 'UPDATE Event'

    response = r.table('turbina').get(proc_inst_id)

    if response.nil?
      # Insert data into RethinkDB
      r.table('turbina').insert(relevant_data).run
    else
      relevant_data.delete(:id)

      # Update data on RethinkDB
      r.table('turbina').get(proc_inst_id).update(relevant_data).run
    end
  else
    puts 'Another Event'
    puts body
    puts
  end
end
