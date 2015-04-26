class ProcessPdfMessagesWorker
  include Sneakers::Worker
  from_queue "pdfs_process",
              timeout_job_after: 480, # 8 minutes
              arguments: { :"x-dead-letter-exchange" =>
                             "pdfs_process-retry" }


  def work(msg)
    logger.info("Received 'pdfs_process' message: #{msg}")
    work = JSON.parse(msg)
    # One PDF per message
    # work =  [count, "<html>"]
    renderer   = RenderPdf.new
    file_name  = renderer.call(work[0], work[1])
    publish(file_name, to_queue: "pdfs_out")

    logger.info("Finished rendering PDF #{work[0]}!'")
    ack!
  end
end
