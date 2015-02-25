require "spec_helper"

RSpec.feature "Smoke Tests" do

  let!(:smoke_test_1) { create :smoke_test }
  let!(:smoke_test_2) { create :smoke_test }

  scenario "smoke test index shows saved smoke tests" do
    visit root_path
    expect(page).to have_text smoke_test_1.message
    expect(page).to have_text smoke_test_2.message
  end

  scenario "clicking button deletes all smoke tests" do
    visit root_path
    click_button "delete_smoke_tests"
    expect(page).not_to have_text smoke_test_1.message
    expect(page).not_to have_text smoke_test_2.message
    expect(SmokeTest.all.size).to eq 0
  end
end
