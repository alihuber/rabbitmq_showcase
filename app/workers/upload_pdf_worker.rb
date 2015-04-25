class UploadPdfWorker
  include Sneakers::Worker
  from_queue "pdfs_out",
              timeout_job_after: 480, # 8 minutes
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
    log_time
    ack!
  end

  def log_time
    # 5
    # Time.now.to_s
    log_file_name = "#{Rails.root.to_s}/time.txt"
    log_file      = IO.readlines(log_file_name)
    count         = log_file[0]
    start_time    = Time.parse(log_file[1])
    if Pdf.count == count.to_i
      FileUtils.rm(log_file_name)
      end_time   = Time.now
      log_string = "Time for #{count}PDFs:"\
      " #{(end_time - start_time)} seconds"

      File.open "#{Rails.root.to_s}/time.txt", "w+" do |file|
        file.write log_string
      end
    end
  end
end
