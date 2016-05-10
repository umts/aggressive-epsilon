require 'factory_girl_rails'

exit if Rails.env.test?
service = Service.find_by url: 'localhost'
unless service
  service = FactoryGirl.create :service, name: 'dev stuff', url: 'localhost'
  item_type = FactoryGirl.create :item_type, name: 'TEST_ITEM_TYPE', creator: service
  # now we're going to need a lot of items to test with
  FactoryGirl.create :item, reservable: true, item_type: item_type until Item.count > 40
end

puts "Your api_key is: " + service.api_key
