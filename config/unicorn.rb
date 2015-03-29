listen 3000, tcp_nopush: false

if ENV["RAILS_ENV"] == "development"
  worker_processes 1
else
  worker_processes 1
end

CONN_SETTINGS = {
  host: "192.168.0.12",
  vhost: "test",
  user: "ubuntu",
  password: "ubuntu",
  autmatically_recover: false
}


timeout 30
preload_app true


after_fork do |server, worker|
  require "bunny"
  class TopicConsumer < Bunny::Consumer
    def cancelled?
      @cancelled
    end

    def handle_cancellation(_)
      @cancelled = true
    end
  end

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

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
      default_queue.subscribe(block: false) do |delivery_info, properties, body|
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
      debug_queue      = rabbitmq_channel.queue("debug", exclusive: true)
      debug_consumer   = TopicConsumer.new(rabbitmq_channel, debug_queue)
      debug_queue.bind(topic, routing_key: "debug.*")
      debug_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      debug_queue.subscribe_with(debug_consumer, block: false)
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
      info_queue       = rabbitmq_channel.queue("info", exclusive: true)
      info_consumer    = TopicConsumer.new(rabbitmq_channel, info_queue)
      info_queue.bind(topic, routing_key: "*.info")
      info_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      info_queue.subscribe_with(info_consumer, block: false)
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
      logger_queue     = rabbitmq_channel.queue("logger", exclusive: true)
      logger_consumer  = TopicConsumer.new(rabbitmq_channel, logger_queue)
      logger_queue.bind(topic, routing_key: "logger.#")
      logger_consumer.on_delivery() do |delivery_info, properties, body|
        TopicReceiver.new(delivery_info.routing_key, body)
      end
      logger_queue.subscribe_with(logger_consumer, block: false)
    rescue Bunny::PreconditionFailed => e
      puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
    ensure
      rabbitmq_connection.create_channel.queue_delete(logger_queue)
    end
  end
end
