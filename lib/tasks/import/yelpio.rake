namespace :import do
  desc 'Send the data to PredictionIO'
  task yelpio: :environment do
    client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY2' ], ENV['PIO_EVENT_SERVER_URL'])
    
    # Send the actions to predictionIO
    Review.find_each do |review|
      begin
        # Only send reviews that have a valid user and business.
        if review.user && review.business
         tags = review.business.categories.map(&:downcase)
         restaurant = tags.include?"restaurants"
         food = tags.include?"food"
         if restaurant || food  
	  client.create_event(
	    'rate',
	    'user',
            review.user.id, {
		'targetEntityType' => 'item',
		'targetEntityId' => review.business.id,
		'eventTime' => review.created_at,
		'properties' => {'rating' => review.stars}
	    }
	  )
          puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories} with res = #{restaurant} and food = #{food} PredictionIO."
        end
       end
      rescue => e
        puts "Error! Review #{review.id} failed. #{e.message}"
      end
    end
  end
end
