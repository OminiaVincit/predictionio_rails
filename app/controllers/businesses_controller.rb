class BusinessesController < ApplicationController
  before_action :authenticate_user!
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
    
    # Get the image link (for display)
    @bs_img_link = 'home/yelpio-all.png'
    
    # Get business list by categorize
    if business_params[:categorize]
      catego = business_params[:categorize].downcase
      if catego == "restaurant" || catego == "food"
      	resources = Business.where("LOWER(categories) LIKE ? OR LOWER(categories) LIKE ?","%restaurant%", "%food%")
      	@bs_img_link = "home/" + catego + ".jpg"
      else
      	resources = Business.where("LOWER(categories) LIKE ?","%#{catego.downcase}%")
      	if catego == "shopping" || catego == "hotel" || catego == "entertainment" || catego == "beauty" || catego == "education"
      		@bs_img_link = "home/" + catego + ".jpg"
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
    @entertainment_businesses =  Business.where("LOWER(categories) LIKE ?","%entertainment%").order('stars DESC').order('reviews_count DESC').limit(4)
    @education_businesses =  Business.where("LOWER(categories) LIKE ?","%education%").order('stars DESC').order('reviews_count DESC').limit(4)
    @hotel_businesses =  Business.where("LOWER(categories) LIKE ?","%hotel%").order('stars DESC').order('reviews_count DESC').limit(4)
    @beauty_businesses =  Business.where("LOWER(categories) LIKE ?","%beauty%").order('stars DESC').order('reviews_count DESC').limit(4)
            
    @random_items = Business.all.order('RANDOM()').limit(12)
  end
  
  def login
  end
  
  def show
  	@users = User.order('reviews_count DESC').limit(10)
  	@business = Business.where(yelp_business_id: params[:id]).first
  	if !@business
  		render :file => 'public/404.html', :status => :not_found, :layout => false
  	elsif
  		@reviews = Review.where(yelp_business_id: params[:id]).order('updated_at DESC')
  		catego = @business.categories[0]
  		#@related_items = Business.where("LOWER(categories) LIKE ?","%#{catego.downcase}%").order('RANDOM()').limit(6)
  		@related_items = Business.all.order('RANDOM()').limit(12)
  	end
  end
  
  private

    # Permit format for update
    def business_params
      params.permit(:categorize)
    end
end
