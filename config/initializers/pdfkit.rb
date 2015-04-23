PDFKit.configure do |config|
  config.wkhtmltopdf   = "/usr/local/bin/wkhtmltopdf"

  config.default_options = {
    page_size:               "A4",
    margin_top:              "4mm",
    margin_right:            "4mm",
    margin_bottom:           "40mm",
    margin_left:             "4mm",
    print_media_type:        true,
    encoding:                "UTF-8"
  }
end
