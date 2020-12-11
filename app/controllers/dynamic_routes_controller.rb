class DynamicRoutesController < ApplicationController
  before_action :ensure_developer!, except: :display
  before_action :set_route, only: %i[update destroy]

  # GET /routes
  def index
    @routes = DynamicRoute.all.paginate page: params[:page]
  end

  # POST /routes
  def create
    @route = DynamicRoute.new params.permit(:path, :article_id)
    if @route.save
      flash[:success] = "Created the route for /#{@route.path}."
    else
      flash[:danger] = "Cannot create the route: #{@route.errors.full_messages.first}."
    end
    redirect_back fallback_location: dynamic_routes_path
  end

  # DELETE /routes/:id
  def destroy
    flash[:secondary] = "Deleted the route for /#{@route.destroy.path}."
    redirect_back fallback_location: dynamic_routes_path
  end

  # GET /(*path)
  def display
    @route = DynamicRoute.where(path: params[:path]).first
    not_found unless @route.present?

    @article = @route.article
    fresh_when @article
  end

  private

  def set_route
    @route = DynamicRoute.find params[:id]
  end
end
