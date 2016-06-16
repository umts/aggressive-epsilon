require 'factory_girl_rails'

exit if Rails.env.test?
service = Service.find_by url: 'localhost'
unless service
  service = FactoryGirl.create :service, name: 'dev stuff', url: 'localhost'

  test_type = FactoryGirl.create :item_type, name: 'TEST_ITEM_TYPE', creator: service
  10.times { FactoryGirl.create :item, reservable: true, item_type: test_type }
  four_seater = FactoryGirl.create :item_type, name: '4 Seat', creator: service
  10.times { FactoryGirl.create :item, reservable: true, item_type: four_seater }
  six_seater = FactoryGirl.create :item_type, name: '6 Seat', creator: service
  10.times { FactoryGirl.create :item, reservable: true, item_type: six_seater }

  # now we're going to need a lot of items to test with
end

puts "Your api_key is: " + service.api_key
