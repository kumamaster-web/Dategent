class DashboardController < ApplicationController
  def show
    @agent = current_user.agent
    @matches = current_user_matches.order(updated_at: :desc).limit(10)
    @proposed_matches = current_user_matches.where(status: "date_proposed").order(updated_at: :desc)
    @confirmed_matches = current_user_matches.where(status: "confirmed").order(updated_at: :desc)
    @declined_matches = current_user_matches.where(status: "declined").order(updated_at: :desc)

    # Upcoming dates: accepted or proposed, scheduled in the future (or no time set yet)
    @upcoming_dates = current_user_date_events
      .where(booking_status: %w[proposed accepted])
      .where("scheduled_time >= ? OR scheduled_time IS NULL", Time.current)
      .order(Arel.sql("scheduled_time IS NULL, scheduled_time ASC"))
      .limit(5)

    # If no future dates, show recently accepted dates (past 30 days) so
    # users who just accepted a date can still see it on the dashboard
    if @upcoming_dates.empty?
      @upcoming_dates = current_user_date_events
        .where(booking_status: "accepted")
        .where("scheduled_time >= ? OR scheduled_time IS NULL", 30.days.ago)
        .order(scheduled_time: :desc)
        .limit(5)
    end

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
    ).includes(initiator_agent: { user: { photo_attachment: :blob } }, receiver_agent: { user: { photo_attachment: :blob } })
  end

  def current_user_date_events
    return DateEvent.none unless current_user.agent

    DateEvent.joins(:match).where(
      "matches.initiator_agent_id = ? OR matches.receiver_agent_id = ?",
      current_user.agent.id, current_user.agent.id
    ).includes(match: { initiator_agent: { user: { photo_attachment: :blob } }, receiver_agent: { user: { photo_attachment: :blob } } }, venue: [])
  end
end
