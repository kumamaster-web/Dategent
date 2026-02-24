# frozen_string_literal: true

# =============================================================================
# Dategency Pipeline — Dry-run QA & live testing tasks
# =============================================================================
# These tasks exercise every service in the agent-to-agent pipeline using
# seeded data, WITHOUT calling the LLM. Use them to verify that
# data wiring, SQL filters, and schedule/venue logic all work before
# spending API tokens.
#
# Usage:
#   rails pipeline:help          — Show all available tasks with descriptions
#
#   --- Dry-run (no API key needed) ---
#   rails pipeline:candidates    — CandidateFinder for every active agent
#   rails pipeline:overlaps      — ScheduleOverlapService for all candidate pairs
#   rails pipeline:venues        — VenueFinderService for all candidate pairs
#   rails pipeline:context       — AgentContextBuilder system_prompt + profile
#   rails pipeline:all           — run all 4 dry-run checks in sequence
#
#   --- Live testing (requires Gemini API key + Sidekiq/Redis in prod) ---
#   rails pipeline:run           — Enqueue MatchmakerJob for test@example.com
#
#   --- Reset & cleanup ---
#   rails pipeline:reset         — Reset test user matches to screening (keep pairs)
#   rails pipeline:nuke          — Delete all test user matches entirely
#   rails pipeline:tabula_rasa   — Full wipe: drop ALL matches, transcripts, date events, then re-seed
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
      ScreeningJob.perform_now(test_user.id, candidate.id)
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

  # ===========================================================================
  # Reset & Cleanup Tasks
  # ===========================================================================

  desc "Reset test user matches to screening stage (keeps match pairs, blanks everything else)"
  task reset: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Reset Test User Matches → Screening"
    puts "#{'=' * 70}"

    user = User.find_by(email: "test@example.com")
    abort "❌ Test user not found. Run rails db:seed first." unless user
    agent = user.agent
    abort "❌ Test user has no agent." unless agent

    matches = Match.where("initiator_agent_id = ? OR receiver_agent_id = ?", agent.id, agent.id)
    count = matches.count

    if count.zero?
      puts "ℹ️  No matches found for #{user.first_name}. Nothing to reset."
      puts "   Run 'rails pipeline:run' to create new matches."
      exit
    end

    match_ids = matches.pluck(:id)

    # Delete dependent records
    date_events_deleted = DateEvent.where(match_id: match_ids).delete_all
    transcripts_deleted = MatchTranscript.where(match_id: match_ids).delete_all

    # Reset matches to screening with blank fields
    matches.update_all(
      status: "screening",
      compatibility_score: nil,
      compatibility_summary: nil,
      chat_transcript: nil,
      updated_at: Time.current
    )

    puts "\n  ✅ #{count} matches → status: screening"
    puts "  🗑️  #{transcripts_deleted} transcript history records deleted"
    puts "  🗑️  #{date_events_deleted} date events deleted"

    matches.includes(:initiator_agent => :user, :receiver_agent => :user).each do |m|
      names = "#{m.initiator_agent.user.first_name} ↔ #{m.receiver_agent.user.first_name}"
      puts "     #{names}: screening (score: nil)"
    end

    puts "\n  Next: rails pipeline:run"
  end

  desc "Delete all test user matches entirely (for fresh CandidateFinder run)"
  task nuke: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Nuke Test User Matches"
    puts "#{'=' * 70}"

    user = User.find_by(email: "test@example.com")
    abort "❌ Test user not found. Run rails db:seed first." unless user
    agent = user.agent
    abort "❌ Test user has no agent." unless agent

    matches = Match.where("initiator_agent_id = ? OR receiver_agent_id = ?", agent.id, agent.id)
    count = matches.count

    if count.zero?
      puts "ℹ️  No matches found for #{user.first_name}. Nothing to nuke."
      exit
    end

    match_ids = matches.pluck(:id)

    puts "\n  💣 Nuking #{count} matches for #{user.first_name} (#{user.email})..."

    date_events_deleted = DateEvent.where(match_id: match_ids).delete_all
    transcripts_deleted = MatchTranscript.where(match_id: match_ids).delete_all
    matches_deleted = matches.delete_all

    puts "  🗑️  #{matches_deleted} matches deleted"
    puts "  🗑️  #{transcripts_deleted} transcript history records deleted"
    puts "  🗑️  #{date_events_deleted} date events deleted"
    puts "\n  CandidateFinder will now discover all eligible users again."
    puts "  Next: rails pipeline:run"
  end

  desc "Tabula rasa: wipe ALL matches, transcripts, date events for all users, then re-seed"
  task tabula_rasa: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Tabula Rasa — Full Wipe & Re-Seed"
    puts "#{'=' * 70}"

    puts "\n  ⚠️  This will delete ALL match data for ALL users."
    puts "     (Users, preferences, agents, and venues are preserved.)"
    print "  Continue? [y/N] "
    input = $stdin.gets&.strip&.downcase
    unless input == "y"
      puts "  Aborted."
      exit
    end

    puts "\n  Wiping..."
    de = DateEvent.delete_all
    mt = MatchTranscript.delete_all
    m  = Match.delete_all

    puts "  🗑️  #{m} matches deleted"
    puts "  🗑️  #{mt} transcript history records deleted"
    puts "  🗑️  #{de} date events deleted"

    puts "\n  Re-seeding..."
    Rake::Task["db:seed"].invoke

    puts "\n  ✅ Tabula rasa complete."
    puts ""
    puts "  Current state:"
    puts "    Users:        #{User.count}"
    puts "    Agents:       #{Agent.count}"
    puts "    Preferences:  #{UserPreference.count}"
    puts "    Venues:       #{Venue.count}"
    puts "    Matches:      #{Match.count}"
    puts "    Transcripts:  #{MatchTranscript.count}"
    puts "    Date Events:  #{DateEvent.count}"
    puts ""
    puts "  Next: rails pipeline:all (dry-run) or rails pipeline:run (live)"
  end

  # ===========================================================================
  # Help
  # ===========================================================================

  # ===========================================================================
  # Diagnostics
  # ===========================================================================

  desc "Diagnose environment readiness for live pipeline run"
  task diagnose: :environment do
    puts "\n#{'=' * 70}"
    puts "PIPELINE: Diagnostic Check"
    puts "#{'=' * 70}"

    # 1. Database counts
    puts "\n📦 DATABASE"
    puts "  Users:            #{User.count}"
    puts "  Agents:           #{Agent.count} (active: #{Agent.where(status: 'active').count})"
    puts "  Preferences:      #{UserPreference.count}"
    puts "  Venues:           #{Venue.count}"
    puts "  Matches:          #{Match.count}"
    puts "  DateEvents:       #{DateEvent.count}"
    puts "  MatchTranscripts: #{MatchTranscript.count}"
    puts "  Blocks:           #{Block.count}"

    # 2. Test user
    puts "\n👤 TEST USER"
    user = User.find_by(email: "test@example.com")
    if user
      puts "  Name:    #{user.first_name} #{user.last_name}"
      puts "  Email:   #{user.email}"
      puts "  Agent:   #{user.agent ? "#{user.agent.name} (#{user.agent.personality_mode})" : '❌ MISSING'}"
      puts "  Prefs:   #{user.user_preference ? '✅' : '❌ MISSING'}"
      if user.agent
        existing = Match.where("initiator_agent_id = ? OR receiver_agent_id = ?", user.agent.id, user.agent.id)
        status_counts = existing.group(:status).count.map { |s, c| "#{s}: #{c}" }.join(", ")
        puts "  Matches: #{existing.count} (#{status_counts.presence || 'none'})"
      end
    else
      puts "  ❌ NOT FOUND — run 'rails db:seed'"
    end

    # 3. Candidate preview
    if user&.agent
      puts "\n🎯 CANDIDATE FINDER"
      begin
        candidates = CandidateFinder.new(user).call
        puts "  Candidates found: #{candidates.count}"
        candidates.limit(5).each do |c|
          puts "    → #{c.first_name} #{c.last_name} (#{c.city}, #{c.gender}, age #{c.age})"
        end
        if candidates.count.zero?
          puts "  ⚠️  No candidates! Check:"
          puts "     - Are there agents with autopilot: true and status: active?"
          puts "     - Gender preferences aligned?"
          puts "     - Existing matches blocking candidates? Try 'rails pipeline:nuke'"
        end
      rescue => e
        puts "  ❌ ERROR: #{e.message}"
      end
    end

    # 4. RubyLLM / Gemini
    puts "\n🤖 LLM CONFIGURATION"
    if defined?(RubyLLM)
      puts "  RubyLLM:         ✅ loaded (v#{RubyLLM::VERSION rescue 'unknown'})"
      gemini_key = ENV["GEMINI_API_KEY"].present?
      puts "  GEMINI_API_KEY:  #{gemini_key ? '✅ set' : '❌ NOT SET'}"
      puts "  Default model:   #{RubyLLM.config.default_model}"

      if gemini_key
        puts "  Testing connection..."
        begin
          chat = Chat.create!
          chat.with_instructions("Reply with exactly one word: DIAGNOSTIC_OK")
          response = chat.ask("ping")
          if response.content.to_s.include?("DIAGNOSTIC_OK")
            puts "  Connection:      ✅ Gemini responding"
          else
            puts "  Connection:      ⚠️  Responded but unexpected: #{response.content.to_s.truncate(80)}"
          end
          chat.destroy
        rescue => e
          puts "  Connection:      ❌ #{e.class}: #{e.message.truncate(120)}"
        end
      else
        puts "  Connection:      ⏭️  Skipped (no API key)"
      end
    else
      puts "  RubyLLM:         ❌ not loaded"
    end

    # 5. Redis / Sidekiq
    puts "\n📡 REDIS / SIDEKIQ"
    redis_url = ENV["REDIS_URL"]
    if redis_url.present?
      masked = redis_url.gsub(/:[^:@]+@/, ':***@')
      puts "  REDIS_URL:       #{masked}"
      begin
        require "sidekiq/api"
        stats = Sidekiq::Stats.new
        puts "  Sidekiq queues:  #{stats.queues.map { |q, c| "#{q}: #{c}" }.join(', ').presence || 'empty'}"
        puts "  Processed:       #{stats.processed}"
        puts "  Failed:          #{stats.failed}"
        puts "  Enqueued:        #{stats.enqueued}"

        ps = Sidekiq::ProcessSet.new
        puts "  Workers online:  #{ps.size > 0 ? "✅ #{ps.size} running" : '❌ 0 — start worker dyno'}"
      rescue => e
        puts "  Sidekiq stats:   ❌ #{e.message.truncate(100)}"
      end
    else
      puts "  REDIS_URL:       ⚪ not set (using :async adapter in dev)"
    end

    # 6. Queue adapter
    puts "\n⚙️  ACTIVE JOB"
    puts "  Queue adapter:   #{Rails.application.config.active_job.queue_adapter}"
    puts "  Environment:     #{Rails.env}"

    # 7. Services
    puts "\n🔧 SERVICES"
    %w[CandidateFinder ScheduleOverlapService VenueFinderService AgentContextBuilder].each do |svc|
      puts "  #{svc}: #{Object.const_defined?(svc) ? '✅' : '❌ not found'}"
    end

    # 8. Jobs
    puts "\n📋 JOBS"
    %w[MatchmakerJob ScreeningJob NegotiationJob].each do |job|
      puts "  #{job}: #{Object.const_defined?(job) ? '✅' : '❌ not found'}"
    end

    puts "\n#{'=' * 70}"
    puts "If all checks pass, run:"
    puts "  rails pipeline:nuke    # clear existing matches"
    puts "  rails pipeline:run     # start live matching"
    puts "#{'=' * 70}"
  end

  desc "Show all pipeline tasks with descriptions"
  task help: :environment do
    puts <<~HELP

      #{'=' * 70}
      DATEGENCY PIPELINE TASKS
      #{'=' * 70}

      ── Dry-Run (no API key, no Sidekiq) ──────────────────────────────────

        rails pipeline:candidates   Show candidate lists per active agent
        rails pipeline:overlaps     Check schedule overlaps for candidate pairs
        rails pipeline:venues       Find matching venues for candidate pairs
        rails pipeline:context      Display system prompts & profile context
        rails pipeline:all          Run all 4 dry-run checks in sequence

      ── Live Testing (requires Gemini API key) ────────────────────────────

        rails pipeline:diagnose     Full environment diagnostic check
                                    DB, test user, Gemini connection, Redis, Sidekiq

        rails pipeline:run          Screen first candidate for test@example.com
                                    Uses ScreeningJob.perform_now (synchronous)
                                    If score >= 60, enqueues NegotiationJob

      ── Reset & Cleanup ───────────────────────────────────────────────────

        rails pipeline:reset        Reset test user matches → screening stage
                                    Keeps match pairs, blanks scores/transcripts
                                    Deletes date events & transcript history
                                    Use when: re-testing screening + negotiation

        rails pipeline:nuke         Delete ALL test user matches entirely
                                    CandidateFinder will rediscover users
                                    Use when: re-testing from candidate discovery

        rails pipeline:tabula_rasa  Full wipe of ALL matches (all users)
                                    Deletes matches, transcripts, date events
                                    Then re-runs db:seed for fresh data
                                    Use when: starting completely over

      ── Typical Workflows ─────────────────────────────────────────────────

        First time / fresh start:
          rails db:seed
          rails pipeline:all          # verify data wiring
          rails pipeline:run          # live LLM test

        Re-test screening on same pairs:
          rails pipeline:reset
          rails pipeline:run

        Re-test from candidate discovery:
          rails pipeline:nuke
          rails pipeline:run

        Total reset (all users):
          rails pipeline:tabula_rasa
          rails pipeline:run

      #{'=' * 70}
    HELP
  end
end
