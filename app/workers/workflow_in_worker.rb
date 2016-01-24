class WorkflowInWorker
  include Sneakers::Worker
  from_queue "workflow_in",
              handler: Sneakers::Handlers::Maxretry,
              timeout_job_after: 60,
              arguments: { :"x-dead-letter-exchange" =>
                             "workflow_in-retry" }


  def work(msg)
    msg = ActiveSupport::JSON.decode(msg)
    logger.info("Received 'workflow_in' message: #{msg}")
    begin
      if msg == "ack"
        logger.info("Received 'ack' message, updating...")
        publisher = Sneakers::Publisher.new
        publisher.publish("first_read", to_queue: "workflow_out",
                                                  persistence: true)
        ActiveRecord::Base.connection_pool.with_connection do
          SmokeTest.all.reverse.each do |st|
            logger.info("Updating record with id #{st.id}:")
            st.update_attribute("message", Faker::Company.ein)
            logger.info("Updated record with id #{st.id}.\n")
          end
        end

        publisher.publish("second_read", to_queue: "workflow_out",
                                                   persistence: true)
        if publisher.instance_variable_get("@bunny")
          publisher.instance_variable_get("@bunny").close
        end
        return ack!
      else
        logger.info("Received '#{msg}' message, error forever")
        return reject!
      end
    rescue Exception => ex
      logger.info("Exception:")
      logger.info(ex.message)
      logger.info(ex.backtrace)
      return reject!
    end
  end
end
