class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :this_user, :signed_in?

  # Get the user that is signed in for this session,
  # or nil if there is none
  def this_user
    return nil unless session[:user_id].present?

    @this_user || @this_user = User.where(id: session[:user_id]).first
  end

  # Same as `this_user', but returns an user with
  # permission `:unapproved' if `this_user' is nil
  def this_user!
    this_user || User.new(permission: :unapproved)
  end

  # Check if signed in
  def signed_in?
    this_user.present?
  end

  # If not signed in, redirect to sign in path.
  def ensure_signed_in!
    return if signed_in?

    flash[:info] = 'You need to sign in to continue.'
    redirect_to sign_in_path
  end

  # For each user permission except the first (`:unapproved'),
  # define a method ensure_<permission> that calls `no_permission'
  # unless the user has permission equal to or above <permission>
  User.permissions.drop(1).each do |permission|
    define_method "ensure_#{permission[0]}!" do
      return if this_user&.permission? permission[1]

      no_permission
    end
  end

  # Give an error and redirect back. If cannot redirect back, redirect to home page.
  # NOTE If used in a controller, call `return' immediately afterward
  def no_permission
    flash[:danger] = 'You do not have sufficient permission to access this page.'
    redirect_back fallback_location: '/'
  end

  # Let Rails give a 404 error
  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
