class WorkflowOutWorker
  include Sneakers::Worker
  from_queue "workflow_out",
              handler: Sneakers::Handlers::Maxretry,
              arguments: { :"x-dead-letter-exchange" =>
                             "workflow_out-retry" }


  def work(msg)
    logger.info("Received 'workflow_out' message: #{msg}")
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        1000.times do
          st = SmokeTest.order("RANDOM()").first
          id_plus = st.id.to_i + 1
        end
      end
      logger.info("Finished 'workflow_out'")
      ack!
    rescue Exception => ex
      logger.info("Exception:")
      logger.info(ex.message)
      logger.info(ex.backtrace)
      return reject!
    end
  end
end
