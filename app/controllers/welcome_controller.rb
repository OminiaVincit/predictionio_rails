class WelcomeController < ApplicationController
  def index
    @users = User.order('reviews_count DESC').limit(10)

    radius = 500
    low_lat = 32
    high_lat = 36
    low_long = -114
    high_long = -110
    lati = low_lat + rand() * (high_lat - low_lat)
    longi = low_long + rand() * (high_long - low_long)
    #lati = 33.611202
    #longi = -112.240062
    
    # Get the deploy url
    deploy_url = ENV['PIO_DEPLOY_URL_BUSINESS']
    
    
    # Get the image link (for display)
    @bs_img_link = 'home/yelpio-all.png'
    @catego = "business"
    # Get business list by categorize
    if business_params[:categorize]
      @catego = business_params[:categorize].downcase
      if @catego == "restaurant" || @catego == "food"
      	resources = Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%restaurant%", "%food%")
      	@bs_img_link = "home/" + @catego + ".jpg"
      	deploy_url = ENV['PIO_DEPLOY_URL_RESTAURANT']
      else
      	if @catego == "shopping" || @catego == "hotel" || @catego == "entertainment" || @catego == "beauty" || @catego == "education"
      		@bs_img_link = "home/" + @catego + ".jpg"
      		deploy_url = ENV['PIO_DEPLOY_URL_' + @catego.upcase]
      		if @catego == "entertainment"
      			resources = Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%entertainment%","%film%", "%music%")
      		elsif @catego == "education"
      			resources = @education_businesses =  Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%education%","%university%","%universities%","%college%","%school%")
      		else
      			resources = Business.where("LOWER(categories) LIKE ?","%#{@catego.downcase}%")
      		end
      	else
      		@catego = "business"
      		resources = Business.all
      	end
      end
    else
      resources = Business.all
    end
    
    # Random latitude & longitude inside Arizona State
    @businesses = resources.near([lati, longi], radius || 50, :order => 'distance').limit(6)  
    
    # Get the top star businesses
    @all_businesses = Business.order('stars DESC').order('reviews_count DESC').limit(4)
    @restaurant_businesses = Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%restaurant%", "%food%").order('stars DESC').order('reviews_count DESC').limit(4)
    @shopping_businesses =  Business.where("LOWER(categories) LIKE ?","%shopping%").order('stars DESC').order('reviews_count DESC').limit(4)
    @entertainment_businesses =  Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%entertainment%","%film%", "%music%").order('stars DESC').order('reviews_count DESC').limit(4)
    @education_businesses =  Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%education%","%university%","%universities%","%college%","%school%").order('stars DESC').order('reviews_count DESC').limit(4)
    @hotel_businesses =  Business.where("LOWER(categories) LIKE ?","%hotel%").order('stars DESC').order('reviews_count DESC').limit(4)
    @beauty_businesses =  Business.where("LOWER(categories) LIKE ?","%beauty%").order('stars DESC').order('reviews_count DESC').limit(4)
            
    # If user login, then get the recommended results
    @recommendations = []
    
    if user_signed_in? && Review.where(user_id: current_user.id).first
		# Get the recommendation results
		# Create new PredictionIO client.
      	client = PredictionIO::EngineClient.new(deploy_url)

    	# Query PredictionIO for 6 recommendations!
      	object = client.send_query('user'=> current_user.id, 'num' => 6)

    	# Loop though item recommendations returned from PredictionIO.
      	object['productScores'].each do |item|
      		# Initialize empty recommendation hash.
        	recommendation = {}

      		# Each item hash has only one key value pair so the first key is the item ID (in our case the business ID).
        	business_id = item.values.first

      		# Find the business.
        	business = Business.where(id: business_id).first
        	recommendation[:business] = business

      		# The value of the hash is the predicted preference score.
        	score = item.values.second
        	recommendation[:score] = score

      		# Add to the array of recommendations.
        	@recommendations << recommendation
        end
    end
    # Get more items if not enough
    limit = 6
    if @recommendations.size < limit
    	add_items = limit - @recommendations.size
    	@random_items = resources.order('RANDOM()').limit(add_items)
    	@random_items.each do |random_item|
    		recommendation = {}
    		recommendation[:business] = random_item
    		recommendation[:score] = 0
    		@recommendations << recommendation
    	end
    end
    rescue => e
    	@random_items = resources.order('RANDOM()').limit(6)
    	@random_items.each do |random_item|
    		recommendation = {}
    		recommendation[:business] = random_item
    		recommendation[:score] = 0
    		@recommendations << recommendation
    	end
        puts "Error! Prediction IO server send query failed. #{e.message}"
        
  end
  
  def login
  end
  
  def show
  	@users = User.order('reviews_count DESC').limit(10)
  	@business = Business.where(yelp_business_id: params[:id]).first
  	
  	if !@business
  		render :file => 'public/404.html', :status => :not_found, :layout => false
  	elsif
  		# Get the map info
  		#@hash = Gmaps4rails.build_markers(@business) do |business, marker|
      	#	marker.lat business.latitude
      	#	marker.lng business.longitude
      	#	marker.infowindow business.name
      	#	marker.json({title: business.yelp_real_id})
    	#end
    
  		@reviews = Review.where(yelp_business_id: params[:id]).order('created_at DESC')
  															  .page(page_params[:page])
                         									  .per(page_params[:page_size])
        page_size = 25
        @number_page = (@business.reviews_count + page_size - 1) / page_size
        
        if page_params[:page]
        	@current_page = page_params[:page].to_i
        	if (@current_page < 0) || (@current_page > @number_page)
        		@current_page = 1
        	end
        else
        	@current_page  = 1
        end
  		catego1 = @business.categories[0]
  		catego2 = catego1
  		catego3 = catego1
  		catego4 = catego1
  		if @business.categories.size > 0
  			catego1 = @business.categories[0]
  		end
		
		if @business.categories.size > 1
  			catego2 = @business.categories[1]
  		else
  			catego2 = catego1
  		end
  		
		if @business.categories.size > 2
  			catego3 = @business.categories[2]
  		else
  			catego3 = catego2
  		end
  		
  		if @business.categories.size > 3
  			catego4 = @business.categories[3]
  		else
  			catego4 = catego3
  		end
  		
  		@related_items = Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%#{catego1.downcase}%", "%#{catego2.downcase}%", "%#{catego3.downcase}%", "%#{catego4.downcase}%").order('RANDOM()').limit(7)
  		if @related_items.size < 7
  			@related_items = Business.all.order('RANDOM()').limit(12)
  		end
  	end
  end
  
  def test
  	render :file => 'public/404.html', :status => :not_found, :layout => false
  end
  
  private

    # Permit format for update
    def business_params
      params.permit(:categorize)
    end
    
    def page_params
      params.permit(:page, :page_size)
    end
end
