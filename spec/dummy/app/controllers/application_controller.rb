# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = AdminUser.order(:id).first ||
      AdminUser.create!(email: "dummy@rails.fi", name: "Dummy Admin")
  end

  def authenticate_admin_user!
    head :unauthorized unless current_user
  end
end
