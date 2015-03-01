require "spec_helper"

RSpec.feature "Topic Tests" do

  let!(:debug_info)    { create :topic, :debug_info_message }
  let!(:debug_warning) { create :topic, :debug_warning_message }
  let!(:logger_info)   { create :topic, :logger_info_message }

  scenario "topic index shows saved smoke tests" do
    visit topic_path
    expect(page).to have_text debug_info.message
    expect(page).to have_text debug_warning.message
    expect(page).to have_text logger_info.message
  end

  scenario "clicking button deletes all smoke tests" do
    visit topic_path
    click_button "delete_topics"
    expect(page).not_to have_text debug_info.message
    expect(page).not_to have_text debug_warning.message
    expect(page).not_to have_text logger_info.message
    expect(Topic.all.size).to eq 0
  end
end
