class DashboardController < ApplicationController
  def show
    @agent = current_user.agent
    @matches = current_user_matches.order(updated_at: :desc).limit(10)
    @upcoming_dates = current_user_date_events
      .where(booking_status: %w[proposed accepted])
      .where("scheduled_time >= ?", Time.current)
      .order(scheduled_time: :asc)
      .limit(5)
    @recent_confirmed = current_user_date_events
      .where(booking_status: "accepted")
      .order(scheduled_time: :desc)
      .limit(3)
  end

  private

  def current_user_matches
    return Match.none unless current_user.agent

    Match.where(
      "initiator_agent_id = ? OR receiver_agent_id = ?",
      current_user.agent.id, current_user.agent.id
    ).includes(initiator_agent: :user, receiver_agent: :user)
  end

  def current_user_date_events
    return DateEvent.none unless current_user.agent

    DateEvent.joins(:match).where(
      "matches.initiator_agent_id = ? OR matches.receiver_agent_id = ?",
      current_user.agent.id, current_user.agent.id
    ).includes(match: { initiator_agent: :user, receiver_agent: :user }, venue: [])
  end
end
