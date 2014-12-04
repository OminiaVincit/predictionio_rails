class Api::V1::BusinessesController < Api::V1::BaseController
  #before_action :authenticate
  #before_action :authenticate_manual (for ref)
  #before_action :validate_rpm
  respond_to :json
  
  # Override
  def index
    plural_resource_name = "@#{resource_name.pluralize}"    
    sql_cmd = ""
    # Get type of sorting and order
    sort = sort_params[:sort]
    order = sort_params[:order]
    
    if (sort=="id" || sort=="name" || sort =="stars" || sort == "created_at" || sort == "updated_at") then
      sql_cmd = sql_cmd + sort
    elsif
      sql_cmd = "id"
    end
    if (order=="ASC") then
      sql_cmd = sql_cmd + " ASC"
    elsif
      sql_cmd = sql_cmd + " DESC"
    end 
    
    if page_params[:categorize]
      resources = resource_class.where("LOWER(categories) LIKE ?","%#{page_params[:categorize].downcase}%")
    else
      resources = resource_class.all
    end
    
    longi = location_params[:longitude]
    lati = location_params[:latitude]
    locate = location_params[:location]
    radius = location_params[:radius]

    if longi && lati then
      resources = resources.near([lati, longi], radius || 10, :order => 'distance')
    elsif locate then
      resources = resources.near(locate, radius || 10, :order => 'distance')
    else
      resources = resources.where(query_params)
    end
    
    resources = resources.order(sql_cmd)
                         .page(page_params[:page])
                         .per(page_params[:page_size])
    
    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
  end
  
  def show
    @business = Business.where(id: params[:id]).first
    render :json => @business
  end
  private

    # Permit format for update
    def business_params
      params.require(:business).permit(:name, :yelp_business_id, :full_address, :city, :state, :stars)
    end
    
    def query_params
      # Requie auth here: ex params.require(:auth)
      params.permit(:id, :yelp_business_id)
    end
    
    def page_params
      params.permit(:page, :page_size, :categorize)
    end

   def sort_params
     params.permit(:sort, :order)
   end

   def location_params
     params.permit(:location, :radius, :longitude, :latitude)
   end
end
