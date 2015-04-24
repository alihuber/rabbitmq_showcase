class PdfController < ApplicationController

  def index
    @pdfs = Pdf.all
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

  def ajax_progress
    @pdfs = Pdf.all

    render partial: "working_queue"
  end

  private

  def process_params(params)
    input = params.keys[0].to_i
    input.between?(1, 20) ? i = input : i = 10
    publish_work(i)
  end

  def publish_work(n)
    n.times do |i|
      source = File.read("#{Rails.root.to_s}/in.html")
      html   = source.gsub("substitute_me", "#{i.to_s}")
      Sneakers::Publisher.new.publish([i, html].to_json,
                                      to_queue: "pdfs_in",
                                      persistence: true)
    end
  end
end
