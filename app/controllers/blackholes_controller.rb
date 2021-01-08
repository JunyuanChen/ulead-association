class BlackholesController < ApplicationController
  before_action :ensure_developer!

  # GET /routes/blackholes
  def index
    @blackholes = Blackhole.all.paginate page: params[:page]
  end

  # GET /routes/blackholes/syslog
  def syslog
    log_file = Rails.root.join 'log', 'production.log'
    remove_color = "sed -e 's/\\x1b\\[[0-9;:]*[a-zA-Z]//g'"
    if params[:grep].present?
      grep = "grep -E '#{params[:grep].tr("'", '')}' -C #{params[:context].to_i}"
      cmd = "tail -n 10000 #{log_file} | #{remove_color} | #{grep}"
    else
      cmd = "tail -n 1000 #{log_file} | #{remove_color}"
    end

    Rails.logger.warn "SHELL CMD: #{cmd}"
    @log = `#{cmd}`
  end

  # GET /routes/blackholes/systop
  def systop
    @top = `top -b -n 1`
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
