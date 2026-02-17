class UserPreferencesController < ApplicationController
  before_action :set_user_preference

  def show
  end

  def edit
  end

  def update
    parsed_params = user_preference_params
    # schedule_availability comes as a JSON string from the hidden input
    if params[:user_preference][:schedule_availability].is_a?(String)
      begin
        parsed_params = parsed_params.to_h
        parsed_params["schedule_availability"] = JSON.parse(params[:user_preference][:schedule_availability])
      rescue JSON::ParserError
        parsed_params["schedule_availability"] = {}
      end
    end

    if @user_preference.update(parsed_params)
      redirect_to user_preference_path, notice: "Preferences updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_preference
    @user_preference = current_user.user_preference || current_user.create_user_preference
  end

  def user_preference_params
    params.require(:user_preference).permit(
      :preferred_gender, :min_age, :max_age, :max_distance,
      :preferred_education, :preferred_zodiac_sign, :preferred_mbti,
      :budget_level, :relationship_goal, :alcohol, :smoking, :fitness,
      :timezone,
      preferred_venue_types: [], schedule_availability: {}
    )
  end
end
