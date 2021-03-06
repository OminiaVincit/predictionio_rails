namespace :import do
  desc 'Send the data to PredictionIO'
  task predictionio: :environment do
    client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY'], ENV['PIO_EVENT_SERVER_URL'])

    # Send the actions to predictionIO
    Review.find_each do |review|
      begin
        # Only send reviews that have a valid user and business.
        if review.user && review.business
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
          puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} PredictionIO."
        end
      rescue => e
        puts "Error! Review #{review.id} failed. #{e.message}"
      end
    end
  end
end
