class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  def index
    @matches = current_user_matches
      .order(updated_at: :desc)
    @matches = @matches.where(status: params[:status]) if params[:status].present?
  end

  def show
    @date_events = @match.date_events.includes(:venue).order(created_at: :desc)
  end

  private

  def set_match
    @match = current_user_matches.find(params[:id])
  end

  def current_user_matches
    return Match.none unless current_user.agent

    Match.where(
      "initiator_agent_id = ? OR receiver_agent_id = ?",
      current_user.agent.id, current_user.agent.id
    ).includes(initiator_agent: :user, receiver_agent: :user)
  end
end
