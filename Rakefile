# frozen_string_literal: true

task default: %w[run_consumer]

task :run_consumer do
  ruby 'consumer/consumer.rb'
end

task :create_table do
  ruby 'db/create_table.rb'
end

task :delete_table do
  ruby 'db/delete_table.rb'
end
