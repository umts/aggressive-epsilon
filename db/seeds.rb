require 'factory_girl_rails'

exit if Rails.env.test?
service = Service.find_by url: 'localhost'
unless service
  service = FactoryGirl.create :service, name: 'dev stuff', url: 'localhost'
  item_type = FactoryGirl.create :item_type, name: 'TEST_CREATE_RENTAL_TYPE', creator: service
  item = FactoryGirl.create :item, name: 'TEST_CREATE_RENTAL_ITEM', reservable: true, item_type: item_type
end

puts "Your api_key is: " + service.api_key
