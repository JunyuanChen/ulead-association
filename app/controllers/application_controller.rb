class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :this_user, :signed_in?

  def this_user
    return nil unless session[:user_id].present?

    User.where(id: session[:user_id]).first
  end

  def this_user!
    this_user || User.new(permission: :unapproved)
  end

  def signed_in?
    this_user.present?
  end

  def ensure_signed_in!
    return if signed_in?

    flash[:info] = 'You need to sign in to continue.'
    redirect_to sign_in_path
  end

  User.permissions.drop(1).each do |permission|
    define_method "ensure_#{permission[0]}!" do
      return if this_user&.permission? permission[1]

      no_permission
    end
  end

  def no_permission
    flash[:danger] = 'You do not have sufficient permission to access this page.'
    redirect_back fallback_location: '/'
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
