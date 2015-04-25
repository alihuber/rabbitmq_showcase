class RenderPdfWorker
  include Sneakers::Worker
  from_queue "pdfs_in",
              timeout_job_after: 480, # 8 minutes
              arguments: { :"x-dead-letter-exchange" =>
                             "pdfs_in-retry" }


  def work(msg)
    logger.info("Received 'pdfs_in' message: #{msg}")
    # work =  [count, "<html>"]
    work = JSON.parse(msg)

    renderer   = RenderPdf.new
    file_name  = renderer.call(work[0], work[1])
    publish(file_name, to_queue: "pdfs_out")
    logger.info("Published file #{file_name} to 'pdfs_out'")

    logger.info("Finished rendering PDF!'")
    ack!
  end
end
