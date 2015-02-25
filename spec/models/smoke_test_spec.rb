require 'rails_helper'

RSpec.describe SmokeTest, type: :model do
  it "has a factory" do
    expect(build :smoke_test).to be_valid
  end
end
