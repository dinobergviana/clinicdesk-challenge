FactoryBot.define do
  factory :task do
    title { "Sample task" }
    description { "Some description" }
    status { "pending" }
    due_date { Date.today + 3.days }
  end
end
