# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  # Unlike the behavior in languages like Java or C++, private methods in Ruby can be called from derived class.
  private
  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:alert] = "ログインしてください"
      redirect_to login_url
    end
  end
end
