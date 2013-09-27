class MainController < ApplicationController
  def index
  end

  def login_failure
    error_message = params[:message]

    flash[:error] = "Logging in with #{params[:strategy].humanize} failed due
      to #{error_message.humanize}."

    redirect_to '/'
  end
end
