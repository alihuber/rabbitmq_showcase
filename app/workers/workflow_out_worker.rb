require_relative "../../lib/sneakers_maxretry_handler.rb"

class WorkflowOutWorker
  include Sneakers::Worker
  from_queue "workflow_out",
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
                                "workflow_out-retry" },
              handler: Sneakers::Handlers::Maxretry


  def work(msg)
    logger.info("Received workflow_out message: #{msg}")
    WorkflowMessage.create(message: msg)
    logger.info("Finished 'workflow_out'")
    ack!
  end
end
