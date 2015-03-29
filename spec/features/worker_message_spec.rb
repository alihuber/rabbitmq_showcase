require "spec_helper"

RSpec.feature "Worker Tests" do

  let!(:worker_message_1) { create :worker_message }
  let!(:worker_message_2) { create :worker_message }

  scenario "worker messages index shows saved worker messages" do
    visit worker_path
    expect(page).to have_text worker_message_1.message
    expect(page).to have_text worker_message_1.work_time
    expect(page).to have_text worker_message_2.message
    expect(page).to have_text worker_message_2.work_time
  end

  scenario "clicking button deletes all worker messages" do
    visit worker_path
    click_button "delete_worker_messages"
    expect(page).not_to have_text worker_message_1.message
    expect(page).not_to have_text worker_message_2.message
    expect(WorkerMessage.all.size).to eq 0
  end
end
