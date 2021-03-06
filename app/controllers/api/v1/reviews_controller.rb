class Api::V1::ReviewsController < Api::V1::BaseController
  #before_action :authenticate
  #before_action :authenticate_manual (for ref)
  #before_action :validate_rpm
  respond_to :json
  
  # Override
  def index
    plural_resource_name = "@#{resource_name.pluralize}"    
    sql_cmd = ""
    # Get type of sorting and order
    sort = page_params[:sort]
    order = page_params[:order]
    
    if (sort=="id" || sort=="business_id" || sort == "yelp_user_id" || sort == "yelp_business_id" || sort =="user_id" || sort == "created_at" || sort == "updated_at" || sort == "stars") then
      sql_cmd = sql_cmd + sort
    else
      sql_cmd = "id"
    end
    if (order=="ASC") then
      sql_cmd = sql_cmd + " ASC"
    else
      sql_cmd = sql_cmd + " DESC"
    end 
    
    resources = resource_class.where(query_params)
                              .order(sql_cmd)
                              .page(page_params[:page])
                              .per(page_params[:page_size])
    render :json => resources
    #instance_variable_set(plural_resource_name, resources)
    #respond_with instance_variable_get(plural_resource_name)
  end
  
  def show
    @review = Review.where(id: params[:id]).first
    render :json => @review
  end

  def create
   yelp_business_id = resource_params[:yelp_business_id]
   yelp_user_id = resource_params[:yelp_user_id]
   stars = resource_params[:stars].to_f
   content = resource_params[:content]
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
    if save_flag == true && send_review(@review)
       #retrain data
#       if sent == true
#         port = ""
#         catego = page_params[:categorize].downcase
#         if catego == "restaurant" || catego == "restaurants" || catego == "food" || catego == "foods"
#           port = " --port 8800"
#           engine_dir = "cd " + ENV['ENGINE_DIR_YELP']
#         elsif
#           engine_dir = "cd " + ENV['ENGINE_DIR']
#         end
#         cmd1 = engine_dir + " && $PIO_HOME/bin/pio train"
#         system( cmd1 )
#         cmd2 = engine_dir + " && $PIO_HOME/bin/pio deploy" + port + " &"
#         system( cmd2 )
         # Wait more 5s
 #        sleep(10)
 #      end
       render :json => @review
    else
       render :json => {}
       #render json: get_resource.errors, status: :unprocessable_entity
    end
  end
  # Update /api/v1/1
  def update
    
  end
  
  def new
  	
  end
  
  private

    # Permit format for update
    def review_params
      params.require(:review).permit(:yelp_business_id, :yelp_user_id, :content, :stars)
    end
    
    def query_params
      # Requie auth here: ex params.require(:auth)
      params.permit(:id, :business_id, :user_id, :yelp_business_id, :yelp_user_id)
    end
    
    def page_params
      params.permit(:page, :page_size, :sort, :order, :categorize)
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
