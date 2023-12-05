class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_url, alert: 'Record not found!'
  end

  def current_user_password
    @current_user_password ||= current_user.user_passwords.find_by(password: @password)
  end

  helper_method :current_user_password
end
