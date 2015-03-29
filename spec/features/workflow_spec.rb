require "spec_helper"

RSpec.feature "Workflow Tests" do

  let!(:workflow_message_1) { create :workflow_message }
  let!(:workflow_message_2) { create :workflow_message }

  scenario "workflow messages index shows saved workflow messages" do
    visit workflow_path
    expect(page).to have_text workflow_message_1.message
    expect(page).to have_text workflow_message_2.message
  end

  scenario "clicking button deletes all workflow messages" do
    visit workflow_path
    click_button "delete_workflow_messages"
    expect(page).not_to have_text workflow_message_1.message
    expect(page).not_to have_text workflow_message_2.message
    expect(WorkflowMessage.all.size).to eq 0
  end
end
