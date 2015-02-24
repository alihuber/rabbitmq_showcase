class CreateSmokeTests < ActiveRecord::Migration
  def change
    create_table :smoke_tests do |t|
      t.string :message

      t.timestamps null: false
    end
  end
end
