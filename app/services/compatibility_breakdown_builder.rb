# frozen_string_literal: true

# Computes deterministic compatibility facts between two users across 5 categories:
#   personality, relationship_goal, lifestyle, schedule, shared_interests
#
# Facts are later enriched with LLM commentary in ScreeningJob.
# The resulting hash is stored as jsonb in Match#compatibility_breakdown.
#
# Usage:
#   breakdown = CompatibilityBreakdownBuilder.new(user_a, user_b).call
class CompatibilityBreakdownBuilder
  # Simplified MBTI compatibility tiers based on cognitive function stacks.
  # Keys are sorted 2-element arrays of MBTI types → compatibility label.
  # Pairs not listed default to "neutral".
  MBTI_COMPATIBILITY = {
    # Complementary — shared dominant/auxiliary cognitive functions, natural synergy
    complementary: %w[
      ENFJ-INFP ENFP-INFJ ENTJ-INTP ENTP-INTJ
      ESFJ-ISFP ESFP-ISFJ ESTJ-ISTP ESTP-ISTJ
      ENFJ-ENFP ENTJ-ENTP ESFJ-ESFP ESTJ-ESTP
    ],
    # Similar — same temperament group, easy rapport
    similar: %w[
      ENFJ-ENFJ ENFP-ENFP ENTJ-ENTJ ENTP-ENTP
      ESFJ-ESFJ ESFP-ESFP ESTJ-ESTJ ESTP-ESTP
      INFJ-INFJ INFP-INFP INTJ-INTJ INTP-INTP
      ISFJ-ISFJ ISFP-ISFP ISTJ-ISTJ ISTP-ISTP
      INFJ-INFP INTJ-INTP ISFJ-ISFP ISTJ-ISTP
    ],
    # Challenging — opposite on most axes, requires effort
    challenging: %w[
      ENFJ-ISTP ENFP-ISTJ ENTJ-ISFP ENTP-ISFJ
      ESFJ-INTP ESFP-INTJ ESTJ-INFP ESTP-INFJ
    ]
  }.freeze

  # Build the lookup hash once at load time: { "ENFJ-INFP" => "complementary", ... }
  MBTI_PAIR_LOOKUP = MBTI_COMPATIBILITY.each_with_object({}) do |(label, pairs), hash|
    pairs.each { |pair| hash[pair] = label.to_s }
  end.freeze

  LIFESTYLE_FACTORS = %i[alcohol smoking fitness budget_level].freeze

  def initialize(user_a, user_b)
    @user_a = user_a
    @user_b = user_b
    @pref_a = user_a.user_preference
    @pref_b = user_b.user_preference
  end

  def call
    {
      personality: personality_breakdown,
      relationship_goal: relationship_goal_breakdown,
      lifestyle: lifestyle_breakdown,
      schedule: schedule_breakdown,
      shared_interests: { interests: [], commentary: nil },
      unique_insights: [],
      dealbreakers: []
    }
  end

  private

  # ── Personality (MBTI) ──────────────────────────────────────────────

  def personality_breakdown
    mbti_a = @user_a.mbti
    mbti_b = @user_b.mbti

    {
      user_mbti: mbti_a,
      match_mbti: mbti_b,
      compatibility_label: mbti_compatibility_label(mbti_a, mbti_b),
      commentary: nil # populated by LLM
    }
  end

  def mbti_compatibility_label(type_a, type_b)
    return "unknown" if type_a.blank? || type_b.blank?

    pair_key = [type_a, type_b].sort.join("-")
    MBTI_PAIR_LOOKUP[pair_key] || "neutral"
  end

  # ── Relationship Goal ───────────────────────────────────────────────

  def relationship_goal_breakdown
    goal_a = @pref_a&.relationship_goal
    goal_b = @pref_b&.relationship_goal

    {
      user_goal: goal_a,
      match_goal: goal_b,
      alignment: goal_alignment(goal_a, goal_b),
      commentary: nil
    }
  end

  def goal_alignment(goal_a, goal_b)
    return "unknown" if goal_a.blank? || goal_b.blank?
    return "aligned" if goal_a == goal_b
    return "aligned" if [goal_a, goal_b].all? { |g| g == "open_to_all" }
    return "partial" if [goal_a, goal_b].any? { |g| g == "open_to_all" }

    "misaligned"
  end

  # ── Lifestyle ───────────────────────────────────────────────────────

  def lifestyle_breakdown
    factors = {}
    aligned_count = 0

    LIFESTYLE_FACTORS.each do |factor|
      val_a = @pref_a&.send(factor)
      val_b = @pref_b&.send(factor)

      is_aligned = factor_aligned?(factor, val_a, val_b)
      aligned_count += 1 if is_aligned

      factors[factor] = {
        user_value: val_a,
        match_value: val_b,
        aligned: is_aligned
      }
    end

    {
      factors: factors,
      alignment_score: aligned_count, # 0-4, displayed as dots out of 4
      commentary: nil
    }
  end

  def factor_aligned?(factor, val_a, val_b)
    return true if val_a.blank? || val_b.blank? # missing = no conflict

    if factor == :budget_level
      budget_distance(val_a, val_b) <= 1 # adjacent tiers are aligned
    else
      val_a == val_b
    end
  end

  def budget_distance(a, b)
    tiers = { "$" => 1, "$$" => 2, "$$$" => 3, "$$$$" => 4 }
    (tiers[a].to_i - tiers[b].to_i).abs
  end

  # ── Schedule ────────────────────────────────────────────────────────

  def schedule_breakdown
    overlap_service = ScheduleOverlapService.new(@user_a, @user_b)
    overlaps = overlap_service.call
    total_slots = overlaps.values.sum(&:size)
    total_minutes = total_slots * 30

    # Compute overlap percentage relative to the smaller schedule
    smaller_schedule_slots = [
      (@pref_a&.schedule_availability || {}).values.sum { |s| Array(s).size },
      (@pref_b&.schedule_availability || {}).values.sum { |s| Array(s).size }
    ].min

    overlap_percentage = if smaller_schedule_slots > 0
                           ((total_slots.to_f / smaller_schedule_slots) * 100).round
                         else
                           0
                         end

    best_days = overlaps.sort_by { |_, slots| -slots.size }
                        .first(3)
                        .map(&:first)

    {
      overlap_slots: total_slots,
      overlap_minutes: total_minutes,
      overlap_percentage: [overlap_percentage, 100].min,
      best_days: best_days,
      commentary: nil
    }
  end
end
