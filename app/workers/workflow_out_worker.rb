class WorkflowOutWorker
  include Sneakers::Worker
  from_queue "workflow_out",
              handler: Sneakers::Handlers::Maxretry,
              arguments: { :"x-dead-letter-exchange" =>
                             "workflow_out-retry" }


  def work(msg)
    logger.info("Received 'workflow_out' message: #{msg}")
    WorkflowMessage.create(message: msg)
    logger.info("Finished 'workflow_out'")
    ack!
  end
end
