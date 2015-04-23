class Pdf < ActiveRecord::Base
  mount_uploader :file, FileUploader
end
