# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :ensure_beta_user, only: %i[beta validate_beta_user]
  skip_before_action :authenticate_user!

  def index
    @has_activities = current_user&.activities&.exists?
  end

  def explore
    @rooms = Room.primary_with_could_use.page params[:page]
  end

  def beta
    redirect_to home_path if session[:is_beta_user]
  end

  def validate_beta_user
    if InviteCode.find_by_code(params[:beta_code])
      session[:is_beta_user] = true
      flash[:success] = 'Welcome! Thanks for helping beta test Jam Rails!'

      if session[:redirect_to]
        redirect_url = session.delete(:redirect_to)
        redirect_to redirect_url
      else
        redirect_to home_path
      end
    else
      session[:is_beta_user] = false
      flash[:danger] = 'Invalid invite code.'
      redirect_to root_path
    end
  end
end
