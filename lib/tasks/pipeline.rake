# frozen_string_literal: true

# =============================================================================
# Dategency Pipeline — Dry-run QA tasks
# =============================================================================
# These tasks exercise every service in the agent-to-agent pipeline using
# seeded data, WITHOUT calling the LLM. Use them to verify that
# data wiring, SQL filters, and schedule/venue logic all work before
# spending API tokens.
#
# Usage:
#   rails pipeline:candidates   — CandidateFinder for every active agent
#   rails pipeline:overlaps     — ScheduleOverlapService for all candidate pairs
#   rails pipeline:venues       — VenueFinderService for all candidate pairs
#   rails pipeline:context      — AgentContextBuilder system_prompt + profile
#   rails pipeline:all          — run all of the above in sequence
# =============================================================================

namespace :pipeline do
  desc "Show candidate lists for every user with an active agent"
  task candidates: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Candidate Finder"
    puts "#{'=' * 70}"

    users = User.joins(:agent).where(agents: { status: "active" }).includes(:user_preference, :agent)
    total_pairs = 0

    users.each do |user|
      all_candidates = CandidateFinder.new(user).call.to_a
      count = all_candidates.size
      total_pairs += count

      puts "\n#{user.first_name} #{user.last_name} (#{user.gender}, age #{user.age}) → #{count} candidates"
      if count > 0
        all_candidates.first(5).each do |c|
          puts "  • #{c.first_name} #{c.last_name} (#{c.gender}, age #{c.age}, #{c.city})"
        end
        puts "  ... and #{count - 5} more" if count > 5
      else
        pref = user.user_preference
        puts "  ⚠ No candidates found (prefers: #{pref&.preferred_gender || 'any'}, age #{pref&.min_age}-#{pref&.max_age})"
      end
    end

    puts "\n#{'─' * 70}"
    puts "Total candidate pairs: #{total_pairs}"
    puts "#{'─' * 70}"
  end

  desc "Show schedule overlaps for candidate pairs"
  task overlaps: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Schedule Overlaps"
    puts "#{'=' * 70}"

    users = User.joins(:agent).where(agents: { status: "active" }).includes(:user_preference, :agent)
    pairs_checked = 0
    sufficient = 0

    users.each do |user|
      candidates = CandidateFinder.new(user).call.limit(3)  # limit to top 3 per user for readability
      candidates.each do |candidate|
        pairs_checked += 1
        overlap = ScheduleOverlapService.new(user, candidate)
        overlapping = overlap.call
        minutes = overlap.total_overlap_minutes
        ok = overlap.sufficient_overlap?

        status = ok ? "✅" : "⚠️"
        sufficient += 1 if ok

        puts "\n#{status} #{user.first_name} ↔ #{candidate.first_name}: #{minutes} min/week"
        overlapping.each do |day, slots|
          puts "   #{day.capitalize}: #{slots.join(', ')}"
        end
        puts "   (no overlap)" if overlapping.empty?
      end
    end

    puts "\n#{'─' * 70}"
    puts "Pairs checked: #{pairs_checked} | Sufficient overlap: #{sufficient} (#{pairs_checked > 0 ? (sufficient * 100 / pairs_checked) : 0}%)"
    puts "#{'─' * 70}"
  end

  desc "Show venue matches for candidate pairs"
  task venues: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Venue Finder"
    puts "#{'=' * 70}"

    users = User.joins(:agent).where(agents: { status: "active" }).includes(:user_preference, :agent)
    pairs_checked = 0
    with_venues = 0

    users.each do |user|
      candidates = CandidateFinder.new(user).call.limit(3)
      candidates.each do |candidate|
        pairs_checked += 1
        venues = VenueFinderService.new(user, candidate).call
        count = venues.count

        with_venues += 1 if count > 0
        status = count > 0 ? "✅" : "⚠️"

        puts "\n#{status} #{user.first_name} ↔ #{candidate.first_name}: #{count} venues"
        venues.each do |v|
          puts "   • #{v.name} (#{v.venue_type}, tier #{v.price_tier}, ★#{v.rating})"
        end
        if count == 0
          pref_a = user.user_preference
          pref_b = candidate.user_preference
          puts "   Budget: #{pref_a&.budget_level} vs #{pref_b&.budget_level}"
          puts "   Venue types: #{pref_a&.preferred_venue_types&.join(', ')} vs #{pref_b&.preferred_venue_types&.join(', ')}"
        end
      end
    end

    puts "\n#{'─' * 70}"
    puts "Pairs checked: #{pairs_checked} | With venues: #{with_venues} (#{pairs_checked > 0 ? (with_venues * 100 / pairs_checked) : 0}%)"
    puts "#{'─' * 70}"
  end

  desc "Show agent context (system prompt + profile) for all active agents"
  task context: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Agent Context Builder"
    puts "#{'=' * 70}"

    users = User.joins(:agent).where(agents: { status: "active" }).includes(:user_preference, :agent)

    users.each do |user|
      builder = AgentContextBuilder.new(user)

      puts "\n#{'─' * 70}"
      puts "AGENT: #{user.agent.name} (#{user.agent.personality_mode}) for #{user.first_name}"
      puts "#{'─' * 70}"
      puts "\n[System Prompt]"
      puts builder.system_prompt
      puts "\n[Profile Context]"
      puts builder.profile_context
      puts "\n[Preference Context]"
      puts builder.preference_context
      puts "\n[Schedule Context]"
      puts builder.schedule_context
    end
  end

  desc "Run all pipeline dry-run checks"
  task all: :environment do
    Rake::Task["pipeline:candidates"].invoke
    Rake::Task["pipeline:overlaps"].invoke
    Rake::Task["pipeline:venues"].invoke
    Rake::Task["pipeline:context"].invoke

    puts "\n#{'=' * 70}"
    puts "ALL PIPELINE CHECKS COMPLETE"
    puts "#{'=' * 70}"
    puts "  Users: #{User.count}"
    puts "  Agents: #{Agent.count} (active: #{Agent.where(status: 'active').count})"
    puts "  Preferences: #{UserPreference.count}"
    puts "  Venues: #{Venue.count}"
    puts "  Matches: #{Match.count}"
    puts "  Date Events: #{DateEvent.count}"
    puts ""
    puts "  Next step: rails pipeline:run (live LLM — requires GEMINI_API_KEY)"
  end

  desc "Run a LIVE pipeline cycle for the test user (requires LLM API key)"
  task run: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Live Run (test user)"
    puts "#{'=' * 70}"

    test_user = User.find_by(email: "test@example.com")
    unless test_user&.agent
      puts "❌ Test user or agent not found. Run rails db:seed first."
      exit 1
    end

    puts "User: #{test_user.full_name}"
    puts "Agent: #{test_user.agent.name} (#{test_user.agent.personality_mode})"
    puts ""

    # Find candidates
    candidates = CandidateFinder.new(test_user).call
    puts "Found #{candidates.count} candidates"

    if candidates.count == 0
      puts "⚠ No candidates to screen. Check preferences or seed data."
      exit 0
    end

    # Pick first candidate and run screening
    candidate = candidates.first
    puts "\nScreening: #{test_user.first_name} ↔ #{candidate.first_name}..."

    begin
      ScreeningJob.perform_now(test_user.agent.id, candidate.agent.id)
      match = Match.find_by(
        initiator_agent: test_user.agent,
        receiver_agent: candidate.agent
      )
      if match
        puts "  Status: #{match.status}"
        puts "  Score: #{match.compatibility_score}"
        puts "  Summary: #{match.compatibility_summary&.truncate(200)}"
      end
    rescue => e
      puts "  ❌ Screening failed: #{e.message}"
      puts "  #{e.backtrace.first(3).join("\n  ")}"
    end
  end
end
