class RenderPdfWorker
  include Sneakers::Worker
  from_queue "pdfs_in",
              timeout_job_after: 480, # 8 minutes
              arguments: { :"x-dead-letter-exchange" =>
                             "pdfs_in-retry" }


  def work(msg)
    logger.info("Received 'pdfs_in' message: #{msg}")
    work = JSON.parse(msg)
    work.each do |data|
      Sneakers::Publisher.new.publish(data.to_json,
                                      to_queue: "pdfs_process",
                                      persistence: true)
      logger.info("Published file #{data[0]} to 'pdfs_process'")
    end
    ack!
  end
end
