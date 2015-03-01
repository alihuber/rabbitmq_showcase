FactoryGirl.define do
  factory :topic, class: Topic do
    sequence :message do |n|
      "message foo_#{n}"
    end

    trait :debug_info_message do
      routing_key "debug.info"
    end

    trait :debug_warning_message do
      routing_key "debug.warning"
    end

    trait :logger_info_message do
      routing_key "logger.info"
    end
  end
end
