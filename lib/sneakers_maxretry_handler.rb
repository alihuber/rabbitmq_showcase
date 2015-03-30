module Sneakers
  module Handlers
    class Maxretry
      def initialize(channel, queue, opts)
        @worker_queue_name = queue.name
        Sneakers.logger.debug do
          "#{log_prefix} creating handler, opts=#{opts}"
        end

        @channel = channel
        @opts    = opts

        # Construct names, defaulting where suitable
        retry_name   = "#{@worker_queue_name}-retry"
        error_name   = "#{@worker_queue_name}-error"
        requeue_name = "#{@worker_queue_name}-retry-requeue"

        # Create the exchanges
        @retry_exchange, @error_exchange, @requeue_exchange =
          [retry_name, error_name, requeue_name].map do |name|
            Sneakers.logger.debug { "#{log_prefix} creating exchange=#{name}" }
            @channel.exchange(name, type: "topic", durable: opts[:durable])
          end

        # Create the queues and bindings
        Sneakers.logger.debug do
          "#{log_prefix} creating queue=#{retry_name}"\
          " x-dead-letter-exchange=#{requeue_name}"
        end
        @retry_queue =
          @channel.queue(retry_name, :durable => opts[:durable],
                         :arguments => {
                           :'x-dead-letter-exchange' => requeue_name,
                           :'x-message-ttl' => @opts[:retry_timeout]
                         })
        @retry_queue.bind(@retry_exchange, routing_key: "#")

        Sneakers.logger.debug do
          "#{log_prefix} creating queue=#{error_name}"
        end
        @error_queue = @channel.queue(error_name, durable: opts[:durable])
        @error_queue.bind(@error_exchange, routing_key: "#")

        # Finally, bind the worker queue to our requeue exchange
        queue.bind(@requeue_exchange, routing_key: "#")
        @max_retries = @opts[:retry_max_times]
      end

      def acknowledge(hdr, props, msg)
        @channel.acknowledge(hdr.delivery_tag, false)
      end

      def reject(hdr, props, msg, requeue = false)
        if requeue
          # This was explicitly rejected specifying it be requeued so we do not
          # want it to pass through our retry logic
          @channel.reject(hdr.delivery_tag, requeue)
        else
          handle_retry(hdr, props, msg, :reject)
        end
      end


      def error(hdr, props, msg, err)
        handle_retry(hdr, props, msg, err)
      end

      def timeout(hdr, props, msg)
        handle_retry(hdr, props, msg, :timeout)
      end

      def noop(hdr, props, msg)
      end

      private
      def handle_retry(hdr, props, msg, reason)
        # +1 for the current attempt
        num_attempts = failure_count(props[:headers]) + 1
        if num_attempts <= @max_retries
          # We call reject which will route the message to the
          # x-dead-letter-exchange (ie. retry exchange) on the queue
          Sneakers.logger.info do
            "#{log_prefix} msg=retrying, count=#{num_attempts},"\
            " headers=#{props[:headers]}"
          end
          @channel.reject(hdr.delivery_tag, false)
        else
          # Retried more than the max times
          # Publish the original message with the routing_key to error exchange
          Sneakers.logger.info do
            "#{log_prefix} msg=failing, retry_count=#{num_attempts},"\
            " reason=#{reason}"
          end
          data = {
            error: reason,
            num_attempts: num_attempts,
            failed_at: Time.now.iso8601,
            payload: Base64.encode64(msg.to_s)
          }.tap do |hash|
            if reason.is_a?(Exception)
              hash[:error_class] = reason.class
              hash[:error_message] = "#{reason}"
              if reason.backtrace
                hash[:backtrace] = reason.backtrace.take(10).join(", ")
              end
            end
          end.to_json
          @error_exchange.publish(data, routing_key: hdr.routing_key)
          @channel.acknowledge(hdr.delivery_tag, false)
        end
      end

      def failure_count(headers)
        if headers.nil? || headers["x-death"].nil?
          0
        else
          headers["x-death"].select do |x_death|
            x_death["queue"] == @worker_queue_name
          end.count
        end
      end

      def log_prefix
        "Maxretry handler [queue=#{@worker_queue_name}]"
      end
    end
  end
end
