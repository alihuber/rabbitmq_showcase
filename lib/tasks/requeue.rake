require "bunny"

namespace :rabbitmq do
  desc "Requeues messages of given queue from error to incoming"
  task :requeue, [:queue] => [:environment] do |t, args|

    amqp_uri         = Rails.application.secrets.rabbitmq["amqp_url"]
    vhost            = Rails.application.secrets.rabbitmq["vhost"]
    url              = URI.encode("#{amqp_uri}/#{vhost}")

    connection       = Bunny.new(url)
    queue_name       = args.queue
    error_queue_name = "#{queue_name}-error"

    connection.start

    publisher = connection.create_channel
    consumer  = connection.create_channel

    while true
      info, properties, payload =
        consumer.basic_get(error_queue_name, manual_ack: true)

      unless info
        connection.close
        break
      end

      publisher.tx_select
      puts "re-enqueueing #{payload} into #{queue_name}"
      publisher.basic_publish(payload, "sneakers", queue_name)
      publisher.tx_commit
      consumer.basic_ack(info.delivery_tag.tag)
    end
  end
end
