class Api::V1::BusinessesController < Api::V1::BaseController
  before_action :authenticate
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
    
    resources = resource_class.where(query_params)
                              .order(sql_cmd)
                              .page(page_params[:page])
                              .per(page_params[:page_size])

    instance_variable_set(plural_resource_name, resources)
    respond_with instance_variable_get(plural_resource_name)
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
      params.permit(:page, :page_size, :sort, :order)
    end
end
