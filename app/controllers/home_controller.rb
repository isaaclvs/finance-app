class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    redirect_to new_user_session_path unless user_signed_in?
  end
end
