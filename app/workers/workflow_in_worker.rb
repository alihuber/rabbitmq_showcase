require_relative "../../lib/sneakers_maxretry_handler.rb"

class WorkflowInWorker
  include Sneakers::Worker
  from_queue "workflow_in",
              durable: true,
              ack: true,
              threads: 4,
              prefetch: 4,
              timeout_job_after: 60,
              exchange: "sneakers",
              heartbeat_interval: 2000,
              retry_timeout: 30000,
              retry_max_times: 3,
              :arguments => { :"x-dead-letter-exchange" =>
                                "workflow_in-retry" },
              handler: Sneakers::Handlers::Maxretry


  def work(msg)
    logger.info("Received workflow_in message: #{msg}")
    # fail randomly and sleep for amount of seconds
    # to simulate error-prone work
    random = Random.new.rand(1..10)
    if random == 5
      logger.info("Rejected message: #{msg}, enqueued in retry-queue")
      return reject!
    end
    sleep random
    publish("Done heavy #{msg} work for #{random.to_s} secs",
            to_queue: "workflow_out")
    logger.info("Published to 'workflow_out'")
    return ack!
  end
end
