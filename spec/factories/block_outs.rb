FactoryBot.define do
  factory :block_out do
    association :user, strategy: :build
    start_at { 1.day.from_now }
    end_at { 1.day.from_now + 1.hour }

    factory :block_out_with_occurrences do
      transient do
        max_occurrence_count { 3 }
      end

      rrule { "FREQ=WEEKLY;COUNT=#{max_occurrence_count};INTERVAL=1;WKST=MO" }

      after(:build) do |block_out, _evaluator|
        Services::ExpandRecurringBlockOut.call(block_out)
      end
    end
  end
end
