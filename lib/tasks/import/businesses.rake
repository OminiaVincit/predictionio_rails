# The data file you downloaded.
BUSINESS_DATA_FILE = Rails.root.join('data/yelp_training_set_business.json')

namespace :import do
  desc 'Import businesses from Yelp data!'
  task businesses: :environment do
    # Loop through each line of the data file.
    File.open(BUSINESS_DATA_FILE, 'r').each_line do |line|

      # Decode JSON.
      object = ActiveSupport::JSON.decode(line)

      # Create a new business..
      business = Business.new

      # Assign values.
      business.name = object['name']
      business.yelp_business_id = object['business_id']
      business.full_address = object['full_address']
      business.city = object['city']
      business.state = object['state']
      business.stars = object['stars']

      # Save the business.
      business.save

      # Display progress in the console.
      puts "Imported business #{business.id} with name #{business.name}."
    end
 end
 # Supply for adding categories, longitude, latitude data
 task categories: :environment do
   # Loop through each line of the data file
   File.open(BUSINESS_DATA_FILE,'r').each_line do |line|
     # Decode JSON
     object = ActiveSupport::JSON.decode(line)

     # Find existed business
     business = Business.where(yelp_business_id: object['business_id']).first
     if business
       business.longitude = object['longitude']
       business.latitude  = object['latitude']
       business.categories     = object['categories']
       
       # Save the business
       business.save
       # Display progress in the console
       puts "Imported categories, longitude, latitude for #{business.id} with categories #{business.categories} longitude #{business.longitude} latitude #{business.latitude}"
     end   
   end
 end
end
