# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  # Unlike the behavior in languages like Java or C++, private methods in Ruby can be called from derived class.
  private
  # Confirms a logged-in user.
  def logged_in_user
    unless user_signed_in?
      store_location
      flash[:alert] = "ログインしてください"
      redirect_to new_user_session_path
    end
  end
end
