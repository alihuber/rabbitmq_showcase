workers     Integer(ENV["WEB_CONCURRENCY"] || 3)
threads     1, Integer(ENV["MAX_THREADS"] || 16)
environment ENV["RACK_ENV"] || "development"
port        ENV['PORT'] || 3000
rackup      DefaultRackup

preload_app!

require "bunny"
class TopicConsumer < Bunny::Consumer
  def cancelled?
    @cancelled
  end

  def handle_cancellation(_)
    @cancelled = true
  end
end

CONN_SETTINGS = {
  host: "192.168.0.11",
  vhost: "test",
  user: "ubuntu",
  password: "ubuntu",
  autmatically_recover: false
}


on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  # Setup for smoke test
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      default_queue    = rabbitmq_channel.queue("default")
      default_queue.subscribe do |delivery_info, properties, body|
        SmokeTestReceiver.new(delivery_info, properties, body)
      end
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(default_queue)
    end
  end

  # Setup for topic #1
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      topic            = rabbitmq_channel.topic("log")
      debug_queue      = rabbitmq_channel.queue("debug")
      debug_consumer   = TopicConsumer.new(rabbitmq_channel, debug_queue)
      debug_queue.bind(topic, routing_key: "debug.*")
      debug_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      debug_queue.subscribe_with(debug_consumer)
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(debug_queue)
    end
  end

  # Setup for topic #2
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      topic            = rabbitmq_channel.topic("log")
      info_queue       = rabbitmq_channel.queue("info")
      info_consumer    = TopicConsumer.new(rabbitmq_channel, info_queue)
      info_queue.bind(topic, routing_key: "*.info")
      info_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      info_queue.subscribe_with(info_consumer)
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(info_queue)
    end
  end

  # Setup for topic #3
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      topic            = rabbitmq_channel.topic("log")
      logger_queue     = rabbitmq_channel.queue("logger")
      logger_consumer  = TopicConsumer.new(rabbitmq_channel, logger_queue)
      logger_queue.bind(topic, routing_key: "logger.#")
      logger_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      logger_queue.subscribe_with(logger_consumer)
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(logger_queue)
    end
  end

  # Setup for worker consumer #1
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      worker_queue_1   = rabbitmq_channel.queue("task_queue", durable: true)
      rabbitmq_channel.prefetch(1)
      worker_queue_1.subscribe(manual_ack: true) do |info, prop, body|
        # simulate work with data from 'type' property (number string)
        sleep prop.type.to_i
        WorkerReceiver.new(info, prop, body)
        rabbitmq_channel.ack(info.delivery_tag)
      end
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(worker_queue_1)
    end
  end

  # Setup for worker consumer #2
  Thread.new do
    begin
      rabbitmq_connection = Bunny.new(CONN_SETTINGS)
      rabbitmq_connection.start
    rescue Bunny::TCPConnectionFailed => e
      puts "Connection failed"
    end
    begin
      rabbitmq_channel = rabbitmq_connection.create_channel
      worker_queue_2   = rabbitmq_channel.queue("task_queue", durable: true)
      rabbitmq_channel.prefetch(1)
      worker_queue_2.subscribe(manual_ack: true) do |info, prop, body|
        # simulate work with data from 'type' property (number string)
        sleep prop.type.to_i
        WorkerReceiver.new(info, prop, body)
        rabbitmq_channel.ack(info.delivery_tag)
      end
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code},
      message: #{e.channel_close.reply_text}".squish
    ensure
      rabbitmq_connection.create_channel.queue_delete(worker_queue_2)
    end
  end
end
