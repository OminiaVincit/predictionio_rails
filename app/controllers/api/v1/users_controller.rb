# app/controllers/api/v1/events_controller.rb
class Api::V1::UsersController < Api::V1::BaseController
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
    
    if (sort=="id" || sort=="name" || sort =="average_stars" || sort == "created_at" || sort == "updated_at" || sort == "reviews_count") then
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
  
  # Override
  def show
    # Find the correct user.
    @user = User.where(id: params[:id]).first
    # Return the predicted result
    if @user && page_params[:method] == "predict"
      # Defautl for number of results
      num = 10
      if page_params[:num] 
        num = page_params[:num].to_i
      end
      # Create new PredictionIO client.
      client = PredictionIO::EngineClient.new(ENV['PIO_DEPLOY_URL'])

      # Query PredictionIO for 5 recommendations!
      object = client.send_query('uid' => @user.id, 'n' => num)

      # Initialize empty recommendations array.
      @recommendations = []

      # Loop though item recommendations returned from PredictionIO.
      object['items'].each do |item|
        # Initialize empty recommendation hash.
        recommendation = {}

        # Each item hash has only one key value pair so the first key is the item ID (in our case the business ID).
        business_id = item.keys.first

        # Find the business.
        business = Business.where(id: business_id).first
        recommendation[:business] = business

        # The value of the hash is the predicted preference score.
        score = item.values.first
        recommendation[:score] = score

        # Add to the array of recommendations.
        @recommendations << recommendation
        end
        render :json =>  @recommendations
    elsif
      render :json =>  @user
    end
  end
  
  # POST /api/{plural_resource_name}
  def create 
    yelp_user_id = resource_params[:yelp_user_id]
    user_name    = resource_params[:name]
    save_flag    = false

    if yelp_user_id && user_name && user_name.delete(' ').length > 0 && (!User.where(yelp_user_id: yelp_user_id).first)
      @user = User.new
      @user.yelp_user_id = yelp_user_id
      @user.name         = user_name
      set_resource(@user)
      if get_resource.save
        save_flag = true       
      end   
    end
   
    if save_flag == true
      render :json => @user
    else
      render :json => {}
      #render json: get_resource.errors, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT (update) /api/1
  def update
    user_id = resource_params[:yelp_user_id]
    if user_id
      @user = User.where(yelp_user_id: user_id).first
    end
    user_name = resource_params[:name].delete(' ')
    len = 0
    if user_name
      len = user_name.length
    end
    if len > 0 && @user && get_resource.update(resource_params)
      render :json => @user
    else
      render :json => {}
      #render json: get_resource.errors, status: :unprocessable_entity
    end
    
  end
  
  private

    # Permit format for update, create
    def user_params
      params.require(:user).permit(:name, :yelp_user_id)
    end

    # Permit query GET like http://localhost:3000/api/users.json?yelp_user_id=Ndj0VsWFoIJQJV6p3zswzg
    # or
    #   http://localhost:3000/api/users.json?id=31919
    
    def query_params
      # Requie auth here: ex params.require(:auth)
      params.permit(:id,:yelp_user_id)
    end
    
    def page_params
      params.permit(:page, :page_size, :num, :sort, :order, :method)
    end
end
