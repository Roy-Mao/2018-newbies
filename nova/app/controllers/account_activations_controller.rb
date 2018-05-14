class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # Use !user.activated? here to ensure illegal access would not be grangted.
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "アカウントの有効化に成功しました"
      redirect_to dashboard_path
    else
      flash[:alert] = "無効なリンクです"
      redirect_to login_url
    end
  end

  private

  def token_time_valid
    created_time = @user.created_at.to_i
    return true if created_time < 5.minutes.ago
    return false
  end

end
