class ReviewsController < Api::V1::BaseController
	def index
		if pages_param[:categorize]
       		catego = pages_param[:categorize].downcase
    	elsif
       		catego = ""
    	end
    	
    	yelp_business_id = pages_param[:yelp_business_id]
   		yelp_user_id = pages_param[:yelp_user_id]
   		stars = pages_param[:stars].to_f
   		content = pages_param[:content]
   		save_flag = false
      
   		if yelp_business_id && yelp_user_id && stars
     		#  User and business must exist in database
     		@user = User.where(yelp_user_id: yelp_user_id).first
     		@business = Business.where(yelp_business_id: yelp_business_id).first
     		# Update reviews count and average star
     		if @user && @business 
      			@review = Review.new
      			@review.user = @user
      			@review.business = @business
      			@review.yelp_business_id = @business.yelp_business_id
      			@review.yelp_user_id = @user.yelp_user_id
      			@review.stars = stars
      			@review.content = content
      			set_resource(@review)
      			
      			if get_resource.save
        			if @user.average_stars
          				avg = @user.average_stars
          				nrv = @user.reviews_count
          				@user.average_stars = (avg*nrv+stars)/(nrv+1) 
        			else
          				@user.average_stars = stars
        			end
        			@user.save 
        			save_flag = true
      			end
     		end
    	end
    	
    	if save_flag == true && send_review(@review) == true
      		redirect_to '/welcome/index?categorize='+catego
    	else
			redirect_to '#'
    	end    
	end
    
    def create
    	
    	yelp_business_id = review_params[:yelp_business_id]
   		yelp_user_id = review_params[:yelp_user_id]
   		stars = review_params[:stars].to_f
   		content = review_params[:content]
   		save_flag = false
      
   		if yelp_business_id && yelp_user_id && stars
     		#  User and business must exist in database
     		@user = User.where(yelp_user_id: yelp_user_id).first
     		@business = Business.where(yelp_business_id: yelp_business_id).first
     		# Update reviews count and average star
     		if @user && @business 
      			@review = Review.new
      			@review.user = @user
      			@review.business = @business
      			@review.yelp_business_id = @business.yelp_business_id
      			@review.yelp_user_id = @user.yelp_user_id
      			@review.stars = stars
      			@review.content = content
      			set_resource(@review)
      			
      			if get_resource.save
        			if @user.average_stars
          				avg = @user.average_stars
          				nrv = @user.reviews_count
          				@user.average_stars = (avg*nrv+stars)/(nrv+1) 
        			else
          				@user.average_stars = stars
        			end
        			@user.save 
        			save_flag = true
      			end
     		end
    	end
    	
    	if save_flag == true && send_review(@review) == true
      		redirect_to '/welcome/' + yelp_business_id
    	else
			redirect_to '/welcome/'
    	end  
    end
  private
    def pages_param
      params.permit(:yelp_business_id, :yelp_user_id, :categorize, :stars, :content)
    end
    
    def review_params
      params.require(:review).permit(:yelp_business_id, :yelp_user_id, :stars, :content)
    end
    
    def send_review(review)
      sent = false
      
      # Only send reviews that have a valid user and business
      if review.user && review.business
      	
      	business_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_BUSINESS'], ENV['PIO_EVENT_SERVER_URL'])
      	restaurant_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_RESTAURANT' ], ENV['PIO_EVENT_SERVER_URL'])
      	education_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_EDUCATION' ], ENV['PIO_EVENT_SERVER_URL'])
      	entertainment_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_ENTERTAINMENT' ], ENV['PIO_EVENT_SERVER_URL'])
      	shopping_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_SHOPPING' ], ENV['PIO_EVENT_SERVER_URL'])
      	hotel_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_HOTEL' ], ENV['PIO_EVENT_SERVER_URL'])
      	beauty_client = PredictionIO::EventClient.new(ENV['PIO_APP_KEY_BEAUTY' ], ENV['PIO_EVENT_SERVER_URL'])
      	
        business_client.create_event(
	  		'rate',
	  		'user',
	  		review.user.id, {
	    		'targetEntityType' => 'item',
	    		'targetEntityId'   => review.business.id,
	    		'eventTime'        => review.created_at,
        		'properties'       => {'rating' => review.stars} 
	  		}
		)
        
        tags = review.business.categories.map(&:downcase)
        restaurant = (tags.include?"restaurant") || (tags.include?"food") || (tags.include?"restaurants") || (tags.include?"foods")
        education = (tags.include?"education") || (tags.include?"school") || (tags.include?"schools") || (tags.include?"university") || (tags.include?"universities") || (tags.include?"college") || (tags.include?"colleges")
        entertainment = (tags.include?"entertainment") || (tags.include?"film") || (tags.include?"films") || (tags.include?"music")
        shopping = (tags.include?"shopping")
        hotel    = (tags.include?"hotel") || (tags.include?"hotels")
        beauty   = (tags.include?"beauty") || (tags.include?"beauties")

        if restaurant == true
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

        if education == true
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

        if entertainment == true
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

        if shopping == true
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

        if hotel == true
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

        if beauty == true
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
        sent = true
      end
      sent
      rescue => e
        sent = false
        puts "Error! Review send to Prediction IO failed. #{e.message}"
        sent
   end
   
end
