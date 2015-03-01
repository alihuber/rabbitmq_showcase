require "spec_helper"

RSpec.describe Topic, type: :model do
  it "has a factory" do
    expect(build :topic).to be_valid
  end
end
