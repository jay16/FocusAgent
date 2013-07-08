  puts "=> Booting #{ActiveSupport::Inflector.demodulize(server)}"
  puts "=> Rails #{Rails.version} application starting in #{Rails.env} on http://#{options[:Host]}:#{options[:Port]}"
  puts "=> Call with -d to detach" unless options[:daemonize]
