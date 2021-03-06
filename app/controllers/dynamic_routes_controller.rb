class DynamicRoutesController < ApplicationController
  before_action :ensure_developer!, except: :display

  # GET /routes
  def index
    @routes = DynamicRoute.all.paginate page: params[:page]
  end

  # POST /routes
  def create
    @route = DynamicRoute.new params.require(:route).permit(:path, :article_id)
    if @route.save
      flash[:success] = "Created the route for /#{@route.path}."
    else
      flash[:danger] = "Cannot create the route: #{@route.errors.full_messages.first}."
    end
    redirect_back fallback_location: dynamic_routes_path
  end

  # DELETE /routes/:id
  def destroy
    @route = DynamicRoutes.where(id: params[:id]).first
    if @route
      flash[:secondary] = "Deleted the route for /#{@route.destroy.path}."
    else
      flash[:warning] = "No such route #{params[:id]}."
    end
    redirect_back fallback_location: dynamic_routes_path
  end

  # GET /(*path)
  def display
    @route = DynamicRoute.where(path: params[:path]).first
    blackhole_or_not_found(params[:path]) && return unless @route.present?

    @article = @route.article
    fresh_when @article
  end

  private

  def set_route
    @route = DynamicRoute.find params[:id]
  end

  def blackhole_or_not_found(path)
    if Blackhole.where(path: path).any?
      headers = request.headers.select { |k, _v| k.starts_with? 'HTTP' }
      Rails.logger.warn 'BLACKHOLED REQUEST'
      Rails.logger.warn "  #{request.remote_ip} via #{request.ip}"
      Rails.logger.warn "  #{request.method} #{request.url}"
      Rails.logger.warn "  Params: #{params.to_unsafe_h.inspect}"
      Rails.logger.warn '  Headers:'
      headers.each do |k, v|
        Rails.logger.warn "    #{k}: #{v}"
      end
      redirect_to 'https://speed.hetzner.de/10GB.bin', status: 301
    else
      not_found
    end
  end
end
