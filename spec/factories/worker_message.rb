FactoryGirl.define do
  factory :worker_message, class: WorkerMessage do
    sequence :message do |n|
      "message foo_#{n}"
    end
    work_time Random.new.rand(1..10).to_s
  end
end
