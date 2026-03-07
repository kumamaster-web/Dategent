class MatchesController < ApplicationController
  before_action :set_match, only: [:show]

  def index
    @matches = current_user_matches
      .order(Arel.sql(<<~SQL), updated_at: :desc)
        CASE status
          WHEN 'confirmed'     THEN 1
          WHEN 'date_proposed' THEN 2
          WHEN 'evaluating'    THEN 3
          WHEN 'screening'     THEN 4
          WHEN 'declined'      THEN 5
          ELSE 6
        END
      SQL
    @matches = @matches.where(status: params[:status]) if params[:status].present?
  end

  def show
    @date_events = @match.date_events.includes(:venue).order(created_at: :desc)
    @transcripts = @match.transcript_history
    @reviewee = @match.receiver_agent.user
    @review = Review.new
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
    ).includes(initiator_agent: { user: { photo_attachment: :blob } }, receiver_agent: { user: { photo_attachment: :blob } })
  end
end
