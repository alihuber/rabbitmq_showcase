listen 3000, tcp_nopush: false

if ENV["RAILS_ENV"] == "development"
  worker_processes 1
else
  worker_processes 3
end


timeout 30
preload_app true

after_fork do |server, worker|
  require "bunny"

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  Thread.new do
    begin
      $rabbitmq_connection = Bunny.new(host: "192.168.0.12",
                                      vhost: "test",
                                      user: "ubuntu",
                                      password: "ubuntu",
                                      automatically_recover: false)
      $rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      $rabbitmq_channel = $rabbitmq_connection.create_channel
      $default_queue    = $rabbitmq_channel.queue("default")
      $default_queue.subscribe(block: true) do |delivery_info, properties, body|
        SmokeTestReceiver.new(delivery_info, properties, body)
      end
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
    ensure
      $rabbitmq_connection.create_channel.queue_delete($default_queue)
    end
  end
end
