namespace :rabbitmq do
  desc "Stops sneakers, deletes queues/exchanges declared by sneakers,"\
       "exports worker class names, starts sneakers"
  task :reset_rabbitmq, [:pid] => [:environment] do |t, args|
    sh "rake rabbitmq:stop_sneakers[#{args.pid}]"

    connect_command =
      "/usr/local/bin/rabbitmqadmin "\
      "#{Rails.application.secrets.rabbitmq['cli_args']}"

    queue_names = `#{connect_command} list queues name`
    begin
      queue_names = queue_names.gsub("|", "").split("\n")[3...-1].uniq
      queue_names.map(&:strip!)
      queue_names.delete("")
      queue_names.each do |name|
        puts "Deleting queue #{name}"
        `#{connect_command} delete queue name=#{name}`
      end
    rescue NoMethodError
      puts "No queues present!"
    end
    puts
    exchange_names = `#{connect_command} list exchanges name`
    exchange_names = exchange_names.gsub("|", "").split("\n")[3...-1].uniq
    exchange_names.map(&:strip!)
    exchange_names.delete("")
    exchange_names.reject! { |name| name.start_with?("amq.") }

    exchange_names.each do |name|
      puts "Deleting exchange #{name}"
      `#{connect_command} delete exchange name=#{name}`
    end
    puts
    connection_names = `#{connect_command} list connections name`
    begin
      connection_names = connection_names.gsub("|", "").split("\n")[3...-1].uniq
      connection_names.map(&:strip!)
      connection_names.delete("")
      connection_names.each do |name|
        puts "Closing connection #{name}"
        `#{connect_command} close connection name='#{name}'`
      end
    rescue NoMethodError
      puts "No connections present!"
    end

    sh "rake rabbitmq:start_sneakers"
  end
end
