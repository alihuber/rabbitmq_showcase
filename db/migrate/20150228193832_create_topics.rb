class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :message
      t.string :routing_key

      t.timestamps null: false
    end
  end
end
