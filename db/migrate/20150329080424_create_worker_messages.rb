class CreateWorkerMessages < ActiveRecord::Migration
  def change
    create_table :worker_messages do |t|
      t.string :message
      t.string :work_time

      t.timestamps null: false
    end
  end
end
