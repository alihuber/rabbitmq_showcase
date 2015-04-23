class UploadPdfWorker
  include Sneakers::Worker
  from_queue "pdfs_out",
              timeout_job_after: 480, # 8 minutes
              prefetch: 4,
              threads: 4,
              arguments: { :"x-dead-letter-exchange" =>
                             "pdfs_out-retry" }


  def work(file_name)
    logger.info("Received 'pdfs_out' message: #{file_name}")

    pdf = Pdf.new
    File.open(file_name) do |f|
      pdf.file = f
      pdf.save!
    end

    logger.info("Uploaded PDF-File #{file_name}!")
    ack!
  end
end
