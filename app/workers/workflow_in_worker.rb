class WorkflowInWorker
  include Sneakers::Worker
  from_queue "workflow_in",
              handler: Sneakers::Handlers::Maxretry,
              arguments: { :"x-dead-letter-exchange" =>
                             "workflow_in-retry" }


  def work(msg)
    logger.info("Received 'workflow_in' message: #{msg}")
    # fail and sleep for random amount of seconds
    # to simulate error-prone work and make use of retry-queue
    random = Random.new.rand(1..10)
    if random == 5
      logger.info("Rejected message: #{msg}, enqueued in retry-queue")
      return reject!
    end
    sleep random
    publish("Done heavy #{msg} work for #{random.to_s} secs",
             to_queue: "workflow_out")
    logger.info("Published to 'workflow_out'")
    ack!
  end
end
