require "fileutils"

class RenderPdf

  def call(id, html)
    pdf_renderer = PDFKit.new(html,
                              "footer-html" =>
                                "#{Rails.root.to_s}/footer.html")
    File.open file_name(id), "wb" do |file|
      file.write pdf_renderer.to_pdf
    end
    file_name(id)
  end

  private
  def file_name(id)
    path = "#{Rails.root}/tmp/pdf/"
    FileUtils.mkdir_p(path)
    "#{path}/#{id}.pdf"
  end
end
