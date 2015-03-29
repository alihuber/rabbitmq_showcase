class CreateWorkflowMessages < ActiveRecord::Migration
  def change
    create_table :workflow_messages do |t|
      t.string :message

      t.timestamps null: false
    end
  end
end
