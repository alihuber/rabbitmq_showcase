class AddFileToPdfs < ActiveRecord::Migration
  def change
    add_column :pdfs, :file, :string
  end
end
