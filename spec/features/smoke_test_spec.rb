require "spec_helper"

RSpec.feature "Smoke Tests" do

  let(:smoke_test_1) { create :smoke_test }
  let(:smoke_test_1) { create :smoke_test }

  scenario "show existent smoke tests" do
    visit root_path
    expect(page).to have_text smoke_test_1.message
    expect(page).to have_text smoke_test_2.message
  end
end
