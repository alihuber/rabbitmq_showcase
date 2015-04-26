class PdfController < ApplicationController

  def index
    @pdfs = Pdf.order(:created_at).page(params[:page])
  end

  def work
    process_params(params)
    redirect_to pdf_path
  end

  def delete
    Pdf.destroy_all
    path = "#{Rails.root}/tmp/pdf/"
    FileUtils.rm_rf(path)
    redirect_to pdf_path
  end

  private

  def process_params(params)
    input = params.keys[0].to_i
    input.between?(1, 400) ? i = input : i = 10
    publish_work(i)
  end

  def publish_work(n)
    log_string = "#{n.to_s}\n#{Time.now.to_s}"
    source = File.read("#{Rails.root.to_s}/in.html")
    File.open "#{Rails.root.to_s}/time.txt", "wb" do |file|
      file.write log_string
    end
    # All PDFs at once
    # [[i, <html>], [i, <html>]...]
    work_array = []
    n.times do |i|
      html = source.gsub("substitute_me", "#{i.to_s}")
      work_array << [i, html]
    end
    Sneakers::Publisher.new.publish(work_array.to_json,
                                    to_queue: "pdfs_in",
                                    persistence: true)
    # One PDF per message
    # n.times do |i|
    #   html   = source.gsub("substitute_me", "#{i.to_s}")
    #   Sneakers::Publisher.new.publish([i, html].to_json,
    #                                   to_queue: "pdfs_in",
    #                                   persistence: true)
    # end
    #
  end
end
