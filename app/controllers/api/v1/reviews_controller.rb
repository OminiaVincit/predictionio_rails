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
    elsif
      sql_cmd = "id"
    end
    if (order=="ASC") then
      sql_cmd = sql_cmd + " ASC"
    elsif
      sql_cmd = sql_cmd + " DESC"
    end 
    
    resources = resource_class.where(query_params)
                              .order(sql_cmd)
                              .page(page_params[:page])
                              .per(page_params[:page_size])

    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
  end
  
  def show
    @review = Review.where(id: params[:id]).first
    render :json => @review
  end

  def create
   yelp_business_id = resource_params[:yelp_business_id]
   yelp_user_id = resource_params[:yelp_user_id]
   stars = resource_params[:stars]
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
     if save_flag == true
       render :json => @review
     else
       render :json => {}
       #render json: get_resource.errors, status: :unprocessable_entity
     end
   end 
  end
  # Update /api/v1/1
  def update
    
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
      params.permit(:page, :page_size, :sort, :order)
    end
end
