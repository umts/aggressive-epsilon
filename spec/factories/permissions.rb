FactoryGirl.define do
  factory :permission do
    read false
    write false
    item_type
    app
  end
end