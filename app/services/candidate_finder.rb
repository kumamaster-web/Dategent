# frozen_string_literal: true

# SQL hard-filter for candidate discovery. Eliminates users who don't
# pass basic preference filters BEFORE any LLM calls happen.
#
# Filters applied (in order):
# 1. Exclude self
# 2. Only users with active agents
# 3. Gender preference
# 4. Age range
# 5. Blocked users (both directions)
# 6. Already matched users
# 7. Weekly match cap enforcement
class CandidateFinder
  def initialize(user)
    @user = user
    @pref = user.user_preference
    @agent = user.agent
  end

  # Returns ActiveRecord::Relation of candidate Users
  def call
    candidates = base_scope
    candidates = filter_gender(candidates)
    candidates = filter_age(candidates)
    candidates = filter_blocked(candidates)
    candidates = filter_already_matched(candidates)
    candidates = filter_weekly_cap(candidates)
    candidates
  end

  private

  def base_scope
    User.where.not(id: @user.id)
        .joins(:agent)
        .where(agents: { status: "active" })
        .includes(:user_preference, :agent)
  end

  def filter_gender(scope)
    return scope if @pref&.preferred_gender.blank?

    scope.where(gender: @pref.preferred_gender)
  end

  def filter_age(scope)
    return scope if @pref&.min_age.blank? && @pref&.max_age.blank?

    today = Time.current.to_date
    conditions = scope

    if @pref.max_age.present?
      min_dob = today - @pref.max_age.years
      conditions = conditions.where("date_of_birth >= ?", min_dob)
    end

    if @pref.min_age.present?
      max_dob = today - @pref.min_age.years
      conditions = conditions.where("date_of_birth <= ?", max_dob)
    end

    conditions
  end

  def filter_blocked(scope)
    blocked_ids = Block.where(blocker_user: @user)
                       .or(Block.where(blocked_user: @user))
                       .pluck(:blocker_user_id, :blocked_user_id)
                       .flatten.uniq

    return scope if blocked_ids.empty?

    scope.where.not(id: blocked_ids)
  end

  def filter_already_matched(scope)
    return scope unless @agent

    existing_match_user_ids = Match
      .where("initiator_agent_id = :aid OR receiver_agent_id = :aid", aid: @agent.id)
      .joins("INNER JOIN agents AS init_agents ON init_agents.id = matches.initiator_agent_id")
      .joins("INNER JOIN agents AS recv_agents ON recv_agents.id = matches.receiver_agent_id")
      .pluck("init_agents.user_id", "recv_agents.user_id")
      .flatten.uniq

    return scope if existing_match_user_ids.empty?

    scope.where.not(id: existing_match_user_ids)
  end

  def filter_weekly_cap(scope)
    return scope unless @agent

    week_start = Time.current.beginning_of_week
    matches_this_week = Match
      .where("initiator_agent_id = ? OR receiver_agent_id = ?", @agent.id, @agent.id)
      .where(created_at: week_start..)
      .count

    remaining_cap = @agent.match_cap_per_week - matches_this_week
    return scope.none if remaining_cap <= 0

    scope.limit(remaining_cap)
  end
end
