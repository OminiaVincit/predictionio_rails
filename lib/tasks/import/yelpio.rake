namespace :import do
  desc 'Send the data to PredictionIO'
  task yelpio: :environment do
    restaurant_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_RESTAURANT' ], ENV['PIO_EVENT_SERVER_URL'])
    education_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_EDUCATION' ], ENV['PIO_EVENT_SERVER_URL'])
    entertainment_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_ENTERTAINMENT' ], ENV['PIO_EVENT_SERVER_URL'])
    shopping_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_SHOPPING' ], ENV['PIO_EVENT_SERVER_URL'])
    hotel_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_HOTEL' ], ENV['PIO_EVENT_SERVER_URL'])
    beauty_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_BEAUTY' ], ENV['PIO_EVENT_SERVER_URL'])

    # Send the actions to predictionIO
    Review.find_each do |review|
      begin
        # Only send reviews that have a valid user and business.
        if review.user && review.business
          tags = review.business.categories.map(&:downcase)
          restaurant = (tags.include?"restaurant") || (tags.include?"food") || (tags.include?"restaurants") || (tags.include?"foods")
          education = (tags.include?"education") || (tags.include?"school") || (tags.include?"schools") || (tags.include?"university") || (tags.include?"universities") || (tags.include?"college") || (tags.include?"colleges")
          entertainment = (tags.include?"entertainment") || (tags.include?"film") || (tags.include?"films") || (tags.include?"music")
          shopping = (tags.include?"shopping")
          hotel    = (tags.include?"hotel") || (tags.include?"hotels")
          beauty   = (tags.include?"beauty") || (tags.include?"beauties")

          if restaurant
	         restaurant_client.create_event(
	          'rate',
            'user',
            review.user.id, {
		          'targetEntityType' => 'item',
		          'targetEntityId' => review.business.id,
		          'eventTime' => review.created_at,
		          'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

          if education
           education_client.create_event(
            'rate',
            'user',
            review.user.id, {
              'targetEntityType' => 'item',
              'targetEntityId' => review.business.id,
              'eventTime' => review.created_at,
              'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

          if entertainment
           entertainment_client.create_event(
            'rate',
            'user',
            review.user.id, {
              'targetEntityType' => 'item',
              'targetEntityId' => review.business.id,
              'eventTime' => review.created_at,
              'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

          if shopping
           shopping_client.create_event(
            'rate',
            'user',
            review.user.id, {
              'targetEntityType' => 'item',
              'targetEntityId' => review.business.id,
              'eventTime' => review.created_at,
              'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

          if hotel
           hotel_client.create_event(
            'rate',
            'user',
            review.user.id, {
              'targetEntityType' => 'item',
              'targetEntityId' => review.business.id,
              'eventTime' => review.created_at,
              'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

          if beauty
           beauty_client.create_event(
            'rate',
            'user',
            review.user.id, {
              'targetEntityType' => 'item',
              'targetEntityId' => review.business.id,
              'eventTime' => review.created_at,
              'properties' => {'rating' => review.stars}
            }
           )
            puts "Sent review #{review.id} from user #{review.user.id} of business #{review.business.id} in categories #{review.business.categories}."
          end

       end
      rescue => e
        puts "Error! Review #{review.id} failed. #{e.message}"
      end
    end
  end
end
