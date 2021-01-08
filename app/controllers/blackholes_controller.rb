class BlackholesController < ApplicationController
  before_action :ensure_developer!

  # GET /routes/blackholes
  def index
    @blackholes = Blackhole.all.paginate page: params[:page]
  end

  # GET /routes/blackholes/syslog
  def syslog
    @log = `tail -n 1000 #{Rails.root.join('log', 'production.log')} | sed -e 's/\\x1b\\[[0-9;:]*[a-zA-Z]//g'`
  end

  # POST /routes/blackholes
  def create
    @blackhole = Blackhole.new params.require(:blackhole).permit(:path)
    if @blackhole.save
      flash[:success] = "Created blackhole at /#{@blackhole.path}."
    else
      flash[:danger] = "Failed to create the blackhole: #{@blackhole.errors.full_messages.first}."
    end
    redirect_back fallback_location: blackholes_path
  end

  # DELETE /routes/blackholes/:id
  def destroy
    @blackhole = Blackhole.where(id: params[:id]).first
    if @blackhole
      flash[:secondary] = "Destroyed blackhole at /#{@blackhole.destroy.path}."
    else
      flash[:warning] = "No such blackhole #{params[:id]}."
    end
    redirect_back fallback_location: blackholes_path
  end
end
