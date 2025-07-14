class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if user_signed_in?
      redirect_to transactions_path
    else
      redirect_to new_user_session_path
    end
  end
end
