namespace :rabbitmq do
  desc "Caches queue's content, stops sneakers, deletes queues/exchanges declared by sneakers,"\
       "exports worker class names, starts sneakers, requeues all messages in main queues"
  task :reset_requeue, [:pid] => [:environment] do |t, args|
    # connection/setup
    connect_command =
      "/usr/local/bin/rabbitmqadmin "\
      "#{Rails.application.secrets.rabbitmq['cli_args']}"
    amqp_uri        = Rails.application.secrets.rabbitmq["amqp_url"]
    vhost           = Rails.application.secrets.rabbitmq["vhost"]
    url             = URI.encode("#{amqp_uri}/#{vhost}")

    # get and sanitize queue names
    begin
      queue_names     = `#{connect_command} list queues name`
      queue_names     = queue_names.gsub("|", "").split("\n")[3...-1].uniq
      queue_names.map(&:strip!)
      queue_names.delete("")
    rescue NoMethodError
      puts "No queues present!"
    end

    # queue_content format: { queue_name => ["msg1", "msg2", ...], }
    content = Hash.new

    # establish bunny connection and get content of queues
    connection       = Bunny.new(url)
    connection.start
    consumer         = connection.create_channel
    queue_names.each do |name|
      content[name] = []
      while true
        info, properties, payload =
          consumer.basic_get(name, manual_ack: true)
        content[name] << payload if payload
        break unless info
      end
    end
    connection.close

    # remove empty queues and duplicate messages
    queue_content = content.delete_if { |k, v| v == [] }
    queue_content.each_pair { |k, v| v.uniq! }

    sh "rake rabbitmq:stop_sneakers[#{args.pid}]"

    # delete queues, exchanges and connections
    queue_names.each do |name|
      puts "Deleting queue #{name}"
      `#{connect_command} delete queue name=#{name}`
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

    if queue_content.any?
      # make new connection for publishing
      connection = Bunny.new(url)
      connection.start
      publisher  = connection.create_channel

      puts
      puts "re-enqueueing messages"
      main_queue_names = queue_names.each do |q|
        q.gsub!("-error", "")
        q.gsub!("-retry", "")
      end.uniq!
      main_queue_names.each do |main_queue|
        queue_content.each_key do |queue|
          if queue.start_with?(main_queue)
            queue_content[queue].each do |msg|
              publisher.tx_select
              puts "re-enqueueing #{msg} into #{main_queue}"
              publisher.basic_publish(msg, "sneakers", main_queue)
              publisher.tx_commit
            end
          end
        end
      end
      connection.close
    end
  end
end
