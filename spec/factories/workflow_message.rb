FactoryGirl.define do
  factory :workflow_message, class: WorkflowMessage do
    sequence :message do |n|
      "message bar_#{n}"
    end
  end
end
