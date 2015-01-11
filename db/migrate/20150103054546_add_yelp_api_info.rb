require 'yelp'

class AddYelpApiInfo < ActiveRecord::Migration
  def up
  	add_column :businesses, :yelp_url, :string, :default => "#"
  	add_column :businesses, :yelp_mobile_url, :string, :default => "#"
  	add_column :businesses, :yelp_image_url, :string, :default => "#"
  	add_column :businesses, :yelp_real_id, :string
  	
  	client = Yelp::Client.new({ consumer_key: ENV['YELP_API_CONSUMER_KEY'],
  							consumer_secret: ENV['YELP_API_CONSUMER_SECRET'],
  							token: ENV['YELP_API_TOKEN'],
  							token_secret: ENV['YELP_API_TOKEN_SECRET']})
   
  	Business.find_each do |business|
        params = { term: business.name, limit: 10 } 
    	locale = {city: business.city, state: business.state}
    	coordinates = { latitude: business.latitude, longitude: business.longitude }                     
  		response = client.search_by_coordinates(coordinates, params, locale)
  		
  		if response.total > 0
  			num = response.total
			puts "There're #{num} responses for #{business.id}"
  			i = 0
  			while i < num
  				if response.businesses[i].respond_to?(:name)
  					if response.businesses[i].name == business.name
  						break
  					end
  				end
  				i = i + 1
  			end
  			
  			if i < num
  			    if response.businesses[i].respond_to?(:url)
  					business.yelp_url = response.businesses[i].url
  				end
  				
  				if response.businesses[i].respond_to?(:mobile_url)
  					business.yelp_mobile_url = response.businesses[i].mobile_url
  				end
  				
      			if response.businesses[i].respond_to?(:image_url)
  					business.yelp_image_url = response.businesses[i].image_url
  				end
      			if response.businesses[i].respond_to?(:id)
  					business.yelp_real_id = response.businesses[i].id
  				end
      			business.save
  				puts "Updating #{business.yelp_real_id}, #{business.yelp_url}, #{business.yelp_mobile_url}, #{business.yelp_image_url} for #{business.id}."
  			end
  		end
    end
  end
  
  def down
  	#remove_column :businesses, :yelp_url
  	#remove_column :businesses, :yelp_mobile_url
  	#remove_column :businesses, :yelp_image_url
  	#remove_column :businesses, :yelp_real_id
  end
end
