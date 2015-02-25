FactoryGirl.define do
  factory :smoke_test, class: SmokeTest do
    sequence :message do |n|
      "message foo_#{n}"
    end
  end
end
