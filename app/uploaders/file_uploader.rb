# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "#{Rails.root}/public/uploads/"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
end
