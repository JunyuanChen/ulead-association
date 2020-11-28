class UsersController < ApplicationController
  before_action :ensure_signed_in!, except: %i[index new create show sign_in do_sign_in do_sign_out]
  before_action :ensure_admin!, only: %i[update_permission destroy]
  before_action :set_user, except: %i[index new create sign_in do_sign_in do_sign_out]
  before_action :ensure_admin_or_owner!, only: %i[edit update_password]

  def index
    @users = User.all.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:info] = 'You have successfully signed up. An admin will review and approve your account.'
      redirect_to '/'
    else
      flash[:danger] = 'The information you provided contains errors.'
      render :new
    end
  end

  def show
    @articles = @user.articles.ordered.viewable_by(this_user).paginate page: params[:page]
  end

  def edit; end

  def update_password
    if @user.authenticate(params[:old_password]) || this_user.permission?(:admin)
      if @user.update password: params[:password],
                      password_confirmation: params[:password_confirmation]
        flash[:success] = 'Updated your password.'
        redirect_to '/'
      else
        flash[:danger] = 'Encountered errors when trying to update your password.'
        render :edit
      end
    else
      flash[:danger] = 'Incorrect password provided.'
      render :edit
    end
  end

  def update_permission
    if @user.permission?(this_user.permission) || !this_user.permission?(params[:permission])
      flash[:danger] = 'You do not have sufficient permission yourself.'
      render :edit
    else
      @user.update_permission!(params[:permission])
      flash[:success] = "Updated permission for #{@user.username} to #{@user.permission}."
      redirect_to @user
    end
  rescue ActiveRecord::StatementInvalid => e
    flash[:danger] = "Failed to update permission for #{@user.username}.\nGot #{e}."
    render :edit
  end

  def destroy
    if @user.permission? this_user.permission
      flash[:danger] = "You do not have sufficient permission to destroy user #{@user.username}"
      redirect_back fallback_location: @user
    else
      flash[:secondary] = "Destroyed user #{@user.destroy.username}."
      redirect_to users_path
    end
  end

  def sign_in
    redirect_to '/' if signed_in?
  end

  def do_sign_in
    @user = User.where(username: params[:username]).first
    if !@user&.authenticate(params[:password])
      flash[:danger] = 'Incorrect username or password.'
      render :sign_in
    elsif @user.unapproved?
      flash[:warning] = 'Please wait until your account is approved.'
      render :sign_in
    else
      reset_session
      session[:user_id] = @user.id
      flash[:success] = "Signed in as #{@user.username}."
      redirect_to '/'
    end
  end

  def do_sign_out
    if signed_in?
      reset_session
      flash[:success] = 'Successfully signed out.'
    else
      Rails.logger.warn "do_sign_out called for guest user (#{request.remote_ip})."
      flash[:warning] = 'You are not currently signed in.'
    end
    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def set_user
    @user = User.find params[:id]
  end

  def ensure_admin_or_owner!
    return if this_user == @user || this_user.permission?(:admin)

    no_permission
  end
end
