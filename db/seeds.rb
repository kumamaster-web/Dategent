# frozen_string_literal: true

# =============================================================================
# Dategency Seed Data
# =============================================================================
# Idempotent — safe to run multiple times (uses find_or_create_by)
# Run with: rails db:seed
#
# Photo attachment:
#   Place images in db/seed_photos/ named by number (01.jpg .. 20.jpg)
#   matching the USER_PROFILES order below. Photos are optional — seed
#   works without them.
# =============================================================================

puts "🌱 Seeding Dategency..."

# ---------------------------------------------------------------------------
# Helper: attach photo if file exists in db/seed_photos/
# ---------------------------------------------------------------------------
def attach_seed_photo(user, filename)
  photo_path = Rails.root.join("db", "seed_photos", filename)
  return unless File.exist?(photo_path)
  return if user.photo.attached?

  content_type = case File.extname(filename).downcase
                 when ".png" then "image/png"
                 when ".webp" then "image/webp"
                 else "image/jpeg"
                 end

  user.photo.attach(
    io: File.open(photo_path),
    filename: filename,
    content_type: content_type
  )
  puts "  📷 Attached #{filename} to #{user.first_name}"
end

# ---------------------------------------------------------------------------
# 1. USER PROFILES (20 diverse users)
# ---------------------------------------------------------------------------
# Index 0 = test account (test@example.com / password)
USER_PROFILES = [
  # 0 — YOUR test account
  { first_name: "Alex",    last_name: "Rivera",     email: "test@example.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1994, 6, 15), height: 178, pronouns: "he/him",
    mbti: "ENFJ", zodiac_sign: "Gemini",  education: "Bachelor's",
    occupation: "Product Manager", language: "EN",
    bio: "Tech optimist, weekend hiker, amateur chef. Looking for someone who laughs at bad puns and loves trying new restaurants." },

  # 1
  { first_name: "Sarah",   last_name: "Chen",       email: "seed-sarah@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1996, 3, 22), height: 165, pronouns: "she/her",
    mbti: "INFP", zodiac_sign: "Aries",   education: "Master's",
    occupation: "UX Designer", language: "EN",
    bio: "Design nerd by day, watercolor painter by night. I believe the best conversations happen over matcha lattes." },

  # 2
  { first_name: "Marcus",  last_name: "Johnson",    email: "seed-marcus@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1991, 11, 8), height: 185, pronouns: "he/him",
    mbti: "ENTJ", zodiac_sign: "Scorpio", education: "MBA",
    occupation: "Startup Founder", language: "EN",
    bio: "Building the future one pitch deck at a time. When I'm not working, I'm running along the Sumida River." },

  # 3
  { first_name: "Yuki",    last_name: "Tanaka",     email: "seed-yuki@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1995, 7, 30), height: 160, pronouns: "she/her",
    mbti: "ISFJ", zodiac_sign: "Leo",     education: "Bachelor's",
    occupation: "Veterinarian", language: "EN",
    bio: "Animal lover with two rescue cats. I make the best homemade gyoza and I'm not afraid to prove it." },

  # 4
  { first_name: "James",   last_name: "O'Brien",    email: "seed-james@dategency.com",
    gender: "male",   city: "Osaka",       country: "Japan",
    date_of_birth: Date.new(1993, 1, 14), height: 180, pronouns: "he/him",
    mbti: "ISTP", zodiac_sign: "Capricorn", education: "Bachelor's",
    occupation: "Software Engineer", language: "EN",
    bio: "Irish expat in Osaka. Guitar player, craft beer enthusiast, and terrible dancer who doesn't care." },

  # 5
  { first_name: "Priya",   last_name: "Sharma",     email: "seed-priya@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1997, 9, 5),  height: 163, pronouns: "she/her",
    mbti: "ENFP", zodiac_sign: "Virgo",   education: "Master's",
    occupation: "Data Scientist", language: "EN",
    bio: "Numbers by day, novels by night. I've read 52 books this year and I'm always looking for recommendations." },

  # 6
  { first_name: "Kenji",   last_name: "Watanabe",   email: "seed-kenji@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1992, 4, 18), height: 175, pronouns: "he/him",
    mbti: "INTP", zodiac_sign: "Aries",   education: "PhD",
    occupation: "Research Scientist", language: "EN",
    bio: "Quantum physics researcher who can explain string theory over dinner. Warning: I get excited about black holes." },

  # 7
  { first_name: "Emma",    last_name: "Williams",   email: "seed-emma@dategency.com",
    gender: "female", city: "Yokohama",    country: "Japan",
    date_of_birth: Date.new(1994, 12, 25), height: 170, pronouns: "she/her",
    mbti: "ESTJ", zodiac_sign: "Capricorn", education: "Bachelor's",
    occupation: "Marketing Director", language: "EN",
    bio: "Australian expat with an unhealthy obsession with ramen. I organize everything, including fun." },

  # 8
  { first_name: "Ryo",     last_name: "Nakamura",   email: "seed-ryo@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1990, 8, 3),  height: 172, pronouns: "he/him",
    mbti: "ESFP", zodiac_sign: "Leo",     education: "Bachelor's",
    occupation: "Chef", language: "EN",
    bio: "Head chef at a French-Japanese fusion restaurant. I speak three languages: English, Japanese, and food." },

  # 9
  { first_name: "Luna",    last_name: "Martinez",   email: "seed-luna@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1998, 2, 14), height: 158, pronouns: "she/her",
    mbti: "INFJ", zodiac_sign: "Aquarius", education: "Bachelor's",
    occupation: "Photographer", language: "EN",
    bio: "Born on Valentine's Day, so I figured I should be good at romance. Spoiler: I'm better behind the camera." },

  # 10
  { first_name: "Daniel",  last_name: "Kim",        email: "seed-daniel@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1993, 5, 21), height: 177, pronouns: "he/him",
    mbti: "ENTP", zodiac_sign: "Gemini",  education: "Master's",
    occupation: "Architect", language: "EN",
    bio: "I design buildings that people love and apartments I can't afford. Weekend DJ with questionable taste in music." },

  # 11
  { first_name: "Aisha",   last_name: "Okafor",     email: "seed-aisha@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1996, 10, 9), height: 168, pronouns: "she/her",
    mbti: "INTJ", zodiac_sign: "Libra",   education: "Master's",
    occupation: "Investment Analyst", language: "EN",
    bio: "Nigerian-British, Tokyo-based. I trade stocks and collect vinyl records. Yes, I know that's a weird combo." },

  # 12
  { first_name: "Tomas",   last_name: "Berg",       email: "seed-tomas@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1991, 3, 7),  height: 190, pronouns: "he/him",
    mbti: "ISFP", zodiac_sign: "Pisces",  education: "Bachelor's",
    occupation: "Yoga Instructor", language: "EN",
    bio: "Swedish calm in Tokyo chaos. I teach yoga, surf when I can, and make a mean kanelbullar (cinnamon roll)." },

  # 13
  { first_name: "Mei",     last_name: "Lin",        email: "seed-mei@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1995, 6, 28), height: 162, pronouns: "she/her",
    mbti: "ESFJ", zodiac_sign: "Cancer",  education: "Bachelor's",
    occupation: "Elementary Teacher", language: "EN",
    bio: "Teaching tiny humans all day gives me infinite patience. I love board games, baking, and bad karaoke." },

  # 14
  { first_name: "Noah",    last_name: "Fischer",    email: "seed-noah@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1994, 9, 16), height: 182, pronouns: "he/him",
    mbti: "ENFJ", zodiac_sign: "Virgo",   education: "Master's",
    occupation: "Clinical Psychologist", language: "EN",
    bio: "German therapist in Tokyo. I promise I won't psychoanalyze you on the first date. Maybe the second." },

  # 15
  { first_name: "Sakura",  last_name: "Hayashi",    email: "seed-sakura@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1997, 4, 1),  height: 155, pronouns: "she/her",
    mbti: "ENTP", zodiac_sign: "Aries",   education: "Bachelor's",
    occupation: "Graphic Designer", language: "EN",
    bio: "Named after cherry blossoms but I prefer sunflowers. I draw, I debate, and I will beat you at Mario Kart." },

  # 16
  { first_name: "Oliver",  last_name: "Santos",     email: "seed-oliver@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1992, 7, 12), height: 176, pronouns: "he/him",
    mbti: "ISTJ", zodiac_sign: "Cancer",  education: "Bachelor's",
    occupation: "Civil Engineer", language: "EN",
    bio: "Filipino-Brazilian building bridges — literally and metaphorically. I like structure in work and spontaneity in life." },

  # 17
  { first_name: "Zara",    last_name: "Hassan",     email: "seed-zara@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1996, 1, 30), height: 167, pronouns: "she/her",
    mbti: "ESTP", zodiac_sign: "Aquarius", education: "Bachelor's",
    occupation: "Travel Writer", language: "EN",
    bio: "48 countries and counting. I write about hidden gems and eat street food for a living. Jealous yet?" },

  # 18
  { first_name: "Hiroshi", last_name: "Ito",        email: "seed-hiroshi@dategency.com",
    gender: "male",   city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1989, 11, 22), height: 174, pronouns: "he/him",
    mbti: "INFP", zodiac_sign: "Sagittarius", education: "Master's",
    occupation: "Music Producer", language: "EN",
    bio: "Making beats in Shibuya. My studio is my happy place, but I'm looking for someone to drag me outside." },

  # 19
  { first_name: "Chloe",   last_name: "Dubois",     email: "seed-chloe@dategency.com",
    gender: "female", city: "Tokyo",       country: "Japan",
    date_of_birth: Date.new(1995, 5, 8),  height: 171, pronouns: "she/her",
    mbti: "ENTJ", zodiac_sign: "Taurus",  education: "MBA",
    occupation: "Brand Strategist", language: "EN",
    bio: "French precision meets Tokyo energy. Wine snob, early riser, and firm believer that cheese is a personality trait." },
].freeze

# ---------------------------------------------------------------------------
# 2. USER PREFERENCE TEMPLATES
# ---------------------------------------------------------------------------
PREFERENCE_TEMPLATES = [
  # 0 — test user
  { preferred_gender: "female", min_age: 24, max_age: 35, max_distance: 25,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "monday"    => %w[19:00 19:30 20:00 20:30],
      "wednesday" => %w[19:00 19:30 20:00 20:30 21:00],
      "friday"    => %w[18:00 18:30 19:00 19:30 20:00 20:30 21:00 21:30],
      "saturday"  => %w[11:00 11:30 12:00 12:30 13:00 18:00 18:30 19:00 19:30 20:00 20:30 21:00 21:30],
      "sunday"    => %w[11:00 11:30 12:00 12:30 13:00 13:30]
    } },
  # 1
  { preferred_gender: "male", min_age: 25, max_age: 36, max_distance: 20,
    budget_level: "$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[coffee dinner outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[18:30 19:00 19:30 20:00],
      "thursday"  => %w[19:00 19:30 20:00 20:30],
      "saturday"  => %w[10:00 10:30 11:00 11:30 12:00 14:00 14:30 15:00]
    } },
  # 2
  { preferred_gender: "female", min_age: 26, max_age: 38, max_distance: 30,
    budget_level: "$$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "friday"    => %w[20:00 20:30 21:00 21:30],
      "saturday"  => %w[18:00 18:30 19:00 19:30 20:00 20:30]
    } },
  # 3
  { preferred_gender: "male", min_age: 27, max_age: 37, max_distance: 15,
    budget_level: "$$", relationship_goal: "serious", alcohol: "never",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[coffee dinner outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "wednesday" => %w[18:00 18:30 19:00 19:30],
      "saturday"  => %w[10:00 10:30 11:00 11:30 14:00 14:30 15:00 15:30],
      "sunday"    => %w[10:00 10:30 11:00 11:30 12:00]
    } },
  # 4
  { preferred_gender: "female", min_age: 25, max_age: 35, max_distance: 40,
    budget_level: "$$", relationship_goal: "casual", alcohol: "often",
    smoking: "sometimes", fitness: "sometimes",
    preferred_venue_types: %w[drinks activity],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "friday"    => %w[19:00 19:30 20:00 20:30 21:00 21:30 22:00],
      "saturday"  => %w[19:00 19:30 20:00 20:30 21:00 21:30 22:00]
    } },
  # 5
  { preferred_gender: "male", min_age: 26, max_age: 34, max_distance: 20,
    budget_level: "$$", relationship_goal: "open_to_all", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[coffee outdoor activity],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "monday"    => %w[18:00 18:30 19:00],
      "wednesday" => %w[18:00 18:30 19:00],
      "saturday"  => %w[09:00 09:30 10:00 10:30 11:00 11:30]
    } },
  # 6
  { preferred_gender: "female", min_age: 24, max_age: 36, max_distance: 25,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[dinner coffee],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "thursday"  => %w[19:00 19:30 20:00 20:30],
      "saturday"  => %w[12:00 12:30 13:00 13:30 18:00 18:30 19:00 19:30]
    } },
  # 7
  { preferred_gender: "male", min_age: 28, max_age: 40, max_distance: 35,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[19:00 19:30 20:00],
      "friday"    => %w[18:00 18:30 19:00 19:30 20:00],
      "sunday"    => %w[11:00 11:30 12:00 12:30]
    } },
  # 8
  { preferred_gender: "female", min_age: 24, max_age: 34, max_distance: 20,
    budget_level: "$$$$", relationship_goal: "serious", alcohol: "often",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[dinner drinks],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "monday"    => %w[21:00 21:30 22:00 22:30],
      "wednesday" => %w[21:00 21:30 22:00 22:30],
      "sunday"    => %w[12:00 12:30 13:00 13:30 14:00]
    } },
  # 9
  { preferred_gender: "male", min_age: 24, max_age: 33, max_distance: 20,
    budget_level: "$$", relationship_goal: "open_to_all", alcohol: "sometimes",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[coffee outdoor activity],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[10:00 10:30 11:00 11:30],
      "thursday"  => %w[10:00 10:30 11:00 11:30],
      "saturday"  => %w[14:00 14:30 15:00 15:30 16:00]
    } },
  # 10
  { preferred_gender: "female", min_age: 25, max_age: 35, max_distance: 30,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks activity],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "wednesday" => %w[19:00 19:30 20:00 20:30],
      "friday"    => %w[19:00 19:30 20:00 20:30 21:00],
      "saturday"  => %w[15:00 15:30 16:00 16:30 17:00]
    } },
  # 11
  { preferred_gender: "male", min_age: 27, max_age: 38, max_distance: 25,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[19:00 19:30 20:00],
      "thursday"  => %w[19:00 19:30 20:00],
      "saturday"  => %w[11:00 11:30 12:00 18:00 18:30 19:00 19:30]
    } },
  # 12
  { preferred_gender: "female", min_age: 24, max_age: 35, max_distance: 30,
    budget_level: "$$", relationship_goal: "open_to_all", alcohol: "sometimes",
    smoking: "never", fitness: "very_active",
    preferred_venue_types: %w[outdoor activity coffee],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "monday"    => %w[06:00 06:30 07:00 18:00 18:30],
      "wednesday" => %w[06:00 06:30 07:00 18:00 18:30],
      "friday"    => %w[06:00 06:30 07:00 18:00 18:30],
      "sunday"    => %w[08:00 08:30 09:00 09:30 10:00]
    } },
  # 13
  { preferred_gender: "male", min_age: 26, max_age: 36, max_distance: 20,
    budget_level: "$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[coffee dinner activity],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "wednesday" => %w[17:00 17:30 18:00 18:30],
      "saturday"  => %w[10:00 10:30 11:00 11:30 12:00 14:00 14:30],
      "sunday"    => %w[10:00 10:30 11:00 11:30]
    } },
  # 14
  { preferred_gender: "female", min_age: 25, max_age: 35, max_distance: 25,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner coffee outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[18:00 18:30 19:00 19:30],
      "thursday"  => %w[18:00 18:30 19:00 19:30],
      "saturday"  => %w[10:00 10:30 11:00 17:00 17:30 18:00 18:30 19:00]
    } },
  # 15
  { preferred_gender: "male", min_age: 24, max_age: 33, max_distance: 20,
    budget_level: "$$", relationship_goal: "casual", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[activity drinks outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "monday"    => %w[19:00 19:30 20:00 20:30],
      "friday"    => %w[18:00 18:30 19:00 19:30 20:00 20:30],
      "saturday"  => %w[13:00 13:30 14:00 14:30 15:00]
    } },
  # 16
  { preferred_gender: "female", min_age: 25, max_age: 35, max_distance: 25,
    budget_level: "$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner outdoor],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "wednesday" => %w[18:30 19:00 19:30 20:00],
      "saturday"  => %w[11:00 11:30 12:00 12:30 17:00 17:30 18:00],
      "sunday"    => %w[09:00 09:30 10:00 10:30 11:00]
    } },
  # 17
  { preferred_gender: "male", min_age: 26, max_age: 36, max_distance: 50,
    budget_level: "$$", relationship_goal: "open_to_all", alcohol: "often",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[outdoor activity drinks],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[10:00 10:30 11:00 14:00 14:30 15:00],
      "thursday"  => %w[10:00 10:30 11:00 14:00 14:30 15:00],
      "saturday"  => %w[09:00 09:30 10:00 10:30 11:00 11:30]
    } },
  # 18
  { preferred_gender: "female", min_age: 24, max_age: 34, max_distance: 20,
    budget_level: "$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "sometimes",
    preferred_venue_types: %w[dinner drinks coffee],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "friday"    => %w[21:00 21:30 22:00 22:30 23:00],
      "saturday"  => %w[20:00 20:30 21:00 21:30 22:00 22:30],
      "sunday"    => %w[14:00 14:30 15:00 15:30]
    } },
  # 19
  { preferred_gender: "male", min_age: 28, max_age: 38, max_distance: 25,
    budget_level: "$$$$", relationship_goal: "serious", alcohol: "sometimes",
    smoking: "never", fitness: "active",
    preferred_venue_types: %w[dinner drinks],
    timezone: "Asia/Tokyo",
    schedule_availability: {
      "tuesday"   => %w[19:00 19:30 20:00 20:30],
      "thursday"  => %w[19:00 19:30 20:00 20:30],
      "saturday"  => %w[12:00 12:30 13:00 18:00 18:30 19:00 19:30 20:00]
    } },
].freeze

# Agent personality modes mapped to user indices
AGENT_CONFIGS = [
  # idx  personality     cap  autopilot  name_suffix
  [ 0,  "friendly",      5,   true,      "Curator"     ],
  [ 1,  "caring",        4,   true,      "Matchmaker"  ],
  [ 2,  "professional",  8,   true,      "Strategist"  ],
  [ 3,  "caring",        3,   false,     "Guardian"    ],
  [ 4,  "witty",         6,   true,      "Wingman"     ],
  [ 5,  "friendly",      5,   true,      "Connector"   ],
  [ 6,  "direct",        4,   false,     "Analyst"     ],
  [ 7,  "professional",  7,   true,      "Executive"   ],
  [ 8,  "witty",         6,   true,      "Sommelier"   ],
  [ 9,  "caring",        3,   true,      "Muse"        ],
  [ 10, "friendly",      5,   true,      "Architect"   ],
  [ 11, "direct",        8,   true,      "Broker"      ],
  [ 12, "caring",        2,   false,     "Zen"         ],
  [ 13, "friendly",      4,   true,      "Buddy"       ],
  [ 14, "professional",  5,   true,      "Counselor"   ],
  [ 15, "witty",         7,   true,      "Spark"       ],
  [ 16, "direct",        4,   false,     "Builder"     ],
  [ 17, "witty",         9,   true,      "Explorer"    ],
  [ 18, "caring",        3,   false,     "Composer"    ],
  [ 19, "professional",  6,   true,      "Strategiste" ],
].freeze

# ---------------------------------------------------------------------------
# 3. VENUES
# ---------------------------------------------------------------------------
VENUE_DATA = [
  { name: "Tsuta Ramen",           address: "1-14-1 Sugamo, Toshima-ku",    city: "Tokyo",
    venue_type: "dinner",  latitude: 35.7335, longitude: 139.7394, rating: 4.6, price_tier: 2 },
  { name: "Aman Tokyo Lounge",     address: "1-5-6 Otemachi, Chiyoda-ku",   city: "Tokyo",
    venue_type: "drinks",  latitude: 35.6867, longitude: 139.7634, rating: 4.8, price_tier: 4 },
  { name: "Yoyogi Park",           address: "2-1 Yoyogikamizonocho, Shibuya-ku", city: "Tokyo",
    venue_type: "outdoor", latitude: 35.6715, longitude: 139.6950, rating: 4.5, price_tier: 1 },
  { name: "Blue Bottle Shinjuku",  address: "4-1-6 Shinjuku, Shinjuku-ku",  city: "Tokyo",
    venue_type: "coffee",  latitude: 35.6910, longitude: 139.7003, rating: 4.3, price_tier: 2 },
  { name: "teamLab Borderless",    address: "1-3-8 Azabudai, Minato-ku",    city: "Tokyo",
    venue_type: "activity", latitude: 35.6580, longitude: 139.7310, rating: 4.7, price_tier: 3 },
  { name: "Sakana-ya Uoharu",      address: "3-12-7 Roppongi, Minato-ku",   city: "Tokyo",
    venue_type: "dinner",  latitude: 35.6627, longitude: 139.7310, rating: 4.4, price_tier: 3 },
].freeze

# ---------------------------------------------------------------------------
# 4. COMPATIBILITY SUMMARIES & TRANSCRIPTS
# ---------------------------------------------------------------------------
COMPATIBILITY_SUMMARIES = {
  screening: "Initial screening in progress. Both agents are reviewing profile compatibility based on preferences, location, and availability overlap.",
  evaluating: <<~TEXT.strip,
    Strong compatibility signals detected:
    • Shared interests: outdoor activities, trying new restaurants, weekend exploration
    • Lifestyle alignment: both non-smokers, moderate social drinkers, active fitness routines
    • Schedule overlap: Saturday afternoons and Friday evenings work for both
    • Personality complement: one partner is more spontaneous (ENFP) while the other provides grounding structure (ISTJ)
    • Potential friction: slight difference in budget expectations (moderate vs high-end)
    Overall score reflects high potential for meaningful connection.
  TEXT
  date_proposed: <<~TEXT.strip,
    Compatibility confirmed after thorough agent-to-agent evaluation:
    • Both users value honesty, intellectual conversation, and work-life balance
    • Cultural interests align well — both enjoy Japanese cuisine and art exhibitions
    • Communication styles are complementary: direct but warm
    • Schedule negotiation complete: Saturday evening works for both parties
    • Venue preference: dinner at a mid-range to upscale restaurant agreed upon
    Agents have proposed a first date.
  TEXT
  confirmed: <<~TEXT.strip,
    Excellent match confirmed:
    • Compatibility score: 87/100
    • Top shared values: ambition, kindness, intellectual curiosity
    • Both agents flagged strong mutual interest based on profile depth
    • Conversation styles rated as highly compatible (witty + thoughtful)
    • Availability alignment: 3 overlapping windows per week
    • Both users expressed preference for starting with dinner
    Date has been confirmed by both parties.
  TEXT
  declined: <<~TEXT.strip,
    Screening completed — match declined:
    • While surface-level interests showed some overlap, agents identified key incompatibilities
    • Relationship goals differ significantly (casual vs serious commitment)
    • Schedule availability has minimal overlap (under 2 hours/week)
    • Budget expectations are misaligned
    Both agents agreed this pairing would not lead to a positive experience.
  TEXT
}.freeze

AGENT_TRANSCRIPTS = {
  screening: <<~TEXT.strip,
    [Agent A → Agent B]: Hi! I represent a lovely person who's looking for a meaningful connection. Let me share some non-identifying compatibility factors.
    [Agent B → Agent A]: Great to connect! My person is also looking for something genuine. Let's compare notes.
    [Agent A → Agent B]: Reviewing preferences now...
  TEXT
  evaluating: <<~TEXT.strip,
    [Agent A → Agent B]: Hi! I represent someone who's actively looking for a meaningful connection in Tokyo. They value intellectual conversation and enjoy outdoor activities.
    [Agent B → Agent A]: That sounds promising! My person shares similar values — they're career-driven but make time for weekend adventures. What about lifestyle compatibility?
    [Agent A → Agent B]: Great question. My person is a non-smoker, enjoys social drinks occasionally, and stays active with regular exercise. They prefer dinner or outdoor dates.
    [Agent B → Agent A]: Strong alignment there. Mine is also a non-smoker with an active lifestyle. They particularly enjoy trying new restaurants. What does the schedule overlap look like?
    [Agent A → Agent B]: My person is available Friday evenings and Saturday afternoons/evenings. Flexible on weekends generally.
    [Agent B → Agent A]: Perfect — Saturday works well for mine too. I'm seeing strong compatibility signals. Shall we move to date proposal?
    [Agent A → Agent B]: Agreed. Let me compile the compatibility summary.
  TEXT
  date_proposed: <<~TEXT.strip,
    [Agent A → Agent B]: After our evaluation, I'm confident this is a strong match. My person is genuinely excited about the compatibility we've identified.
    [Agent B → Agent A]: Same here! The shared values around ambition, curiosity, and lifestyle really stand out. Let's find a date spot.
    [Agent A → Agent B]: My person enjoys upscale casual dining. How about Saturday evening? I see overlap from 18:00-21:00.
    [Agent B → Agent A]: Saturday at 19:00 would be ideal. My person prefers restaurants with good atmosphere — not too loud, conversation-friendly.
    [Agent A → Agent B]: How about Sakana-ya Uoharu in Roppongi? Great Japanese cuisine, intimate setting, price tier 3 which fits both budgets.
    [Agent B → Agent A]: Excellent choice. I'll propose this to my person: Saturday, 19:00, Sakana-ya Uoharu. Sending the date proposal now.
    [Agent A → Agent B]: Proposal sent on my end too. Fingers crossed!
  TEXT
  confirmed: <<~TEXT.strip,
    [Agent A → Agent B]: Wonderful news — my person has accepted the date!
    [Agent B → Agent A]: Mine too! Both parties confirmed. Here's the final plan:
    [Agent B → Agent A]: 📅 Date: Saturday, 19:00 JST
    [Agent B → Agent A]: 📍 Venue: Sakana-ya Uoharu, Roppongi
    [Agent B → Agent A]: 🍽️ Type: Japanese dinner, intimate setting
    [Agent A → Agent B]: Perfect. I've reminded my person about the dress code (smart casual) and shared the venue location.
    [Agent B → Agent A]: Same here. Both parties are looking forward to it. Our work here is done — for now!
    [Agent A → Agent B]: Great collaboration. Let's check in after the date for feedback. 🎉
  TEXT
  declined: <<~TEXT.strip,
    [Agent A → Agent B]: I've reviewed the compatibility factors and I have some concerns.
    [Agent B → Agent A]: I appreciate the honesty. What are you seeing?
    [Agent A → Agent B]: The relationship goals don't align well — my person is looking for something serious and long-term, while yours seems more open to casual dating.
    [Agent B → Agent A]: That's fair. I also noticed the schedule overlap is quite limited — maybe 1-2 hours per week at best.
    [Agent A → Agent B]: And the budget expectations are pretty different. I don't think forcing this would be fair to either person.
    [Agent B → Agent A]: Agreed. Better to be upfront now than waste anyone's time. I'll mark this as declined on my end.
    [Agent A → Agent B]: Same. No hard feelings — just not the right match. Wishing your person the best!
  TEXT
}.freeze

# =============================================================================
# CREATE RECORDS
# =============================================================================

# --- Users ---
puts "\n👤 Creating users..."
users = USER_PROFILES.each_with_index.map do |attrs, idx|
  password = idx == 0 ? "password" : "password#{idx}"
  user = User.find_or_initialize_by(email: attrs[:email])
  if user.new_record?
    user.assign_attributes(attrs.merge(password: password, password_confirmation: password))
    user.save!
    puts "  Created #{user.first_name} #{user.last_name} (#{user.email})"
  else
    # Update profile fields but not password
    user.update!(attrs.except(:email))
    puts "  Updated #{user.first_name} #{user.last_name} (#{user.email})"
  end
  user
end

# --- Photos ---
puts "\n📷 Attaching photos..."
users.each_with_index do |user, idx|
  padded = format("%02d", idx + 1)
  # Try multiple extensions
  %w[jpg jpeg png webp].each do |ext|
    filename = "#{padded}.#{ext}"
    if File.exist?(Rails.root.join("db", "seed_photos", filename))
      attach_seed_photo(user, filename)
      break
    end
  end
  # Also try name-based files
  name_file = "#{user.first_name.downcase}_#{user.last_name.downcase}"
  %w[jpg jpeg png webp].each do |ext|
    filename = "#{name_file}.#{ext}"
    if File.exist?(Rails.root.join("db", "seed_photos", filename))
      attach_seed_photo(user, filename)
      break
    end
  end
end

# --- User Preferences ---
puts "\n⚙️  Creating user preferences..."
users.each_with_index do |user, idx|
  template = PREFERENCE_TEMPLATES[idx]
  pref = UserPreference.find_or_initialize_by(user: user)
  pref.assign_attributes(template)
  pref.save!
end

# --- Agents ---
puts "\n🤖 Creating agents..."
agents = AGENT_CONFIGS.map do |idx, personality, cap, autopilot, suffix|
  user = users[idx]
  agent = Agent.find_or_initialize_by(user: user)
  agent.assign_attributes(
    name: "#{user.first_name}'s #{suffix}",
    personality_mode: personality,
    match_cap_per_week: cap,
    autopilot: autopilot,
    status: "active"
  )
  agent.save!
  agent
end

# --- Venues ---
puts "\n📍 Creating venues..."
venues = VENUE_DATA.map do |attrs|
  venue = Venue.find_or_initialize_by(name: attrs[:name])
  venue.assign_attributes(attrs)
  venue.save!
  venue
end

# --- Matches (test user's match universe) ---
puts "\n💕 Creating matches..."
test_agent = agents[0] # Alex Rivera's agent

# Helper to build match
def create_match(initiator, receiver, status, score, summary_key, transcript_key)
  match = Match.find_or_initialize_by(
    initiator_agent: initiator,
    receiver_agent: receiver
  )
  match.assign_attributes(
    status: status,
    compatibility_score: score,
    compatibility_summary: COMPATIBILITY_SUMMARIES[summary_key],
    chat_transcript: AGENT_TRANSCRIPTS[transcript_key]
  )
  match.save!
  puts "  #{initiator.user.first_name} ↔ #{receiver.user.first_name}: #{status}"
  match
end

# Match 1: screening (test user initiated)
match_screening = create_match(test_agent, agents[1], "screening", 0.0, :screening, :screening)

# Match 2: evaluating (test user received)
match_evaluating = create_match(agents[2], test_agent, "evaluating", 72.5, :evaluating, :evaluating)

# Match 3: date_proposed (test user initiated) — DateEvent pending
match_proposed = create_match(test_agent, agents[3], "date_proposed", 81.0, :date_proposed, :date_proposed)

# Match 4: confirmed (test user initiated) — DateEvent accepted, future date
match_confirmed_future = create_match(test_agent, agents[5], "confirmed", 87.0, :confirmed, :confirmed)

# Match 5: confirmed (test user received) — DateEvent accepted, past date
match_confirmed_past = create_match(agents[9], test_agent, "confirmed", 84.5, :confirmed, :confirmed)

# Match 6: declined (test user initiated)
match_declined = create_match(test_agent, agents[4], "declined", 38.0, :declined, :declined)

# Match 7: date_proposed (test user received) — user declined the date
match_user_declined_date = create_match(agents[11], test_agent, "date_proposed", 76.0, :date_proposed, :date_proposed)

# Extra matches between other users (background activity)
create_match(agents[2], agents[3],  "screening",     0.0,  :screening,    :screening)
create_match(agents[5], agents[6],  "evaluating",    68.0, :evaluating,   :evaluating)
create_match(agents[7], agents[8],  "confirmed",     91.0, :confirmed,    :confirmed)
create_match(agents[10], agents[13], "date_proposed", 79.0, :date_proposed, :date_proposed)
create_match(agents[14], agents[15], "evaluating",    74.0, :evaluating,   :evaluating)
create_match(agents[16], agents[17], "declined",      42.0, :declined,     :declined)
create_match(agents[18], agents[19], "screening",     0.0,  :screening,    :screening)

# --- Date Events ---
puts "\n📅 Creating date events..."

# DateEvent for match_proposed (proposed, pending user response)
de_proposed = DateEvent.find_or_initialize_by(match: match_proposed)
de_proposed.assign_attributes(
  venue: venues[3],  # Blue Bottle Shinjuku
  scheduled_time: 3.days.from_now.change(hour: 14, min: 0),
  booking_status: "proposed"
)
de_proposed.save!
puts "  Proposed: #{de_proposed.venue.name} on #{3.days.from_now.strftime('%b %d')}"

# DateEvent for match_confirmed_future (accepted, upcoming)
de_confirmed_future = DateEvent.find_or_initialize_by(match: match_confirmed_future)
de_confirmed_future.assign_attributes(
  venue: venues[5],  # Sakana-ya Uoharu
  scheduled_time: 5.days.from_now.change(hour: 19, min: 0),
  booking_status: "accepted"
)
de_confirmed_future.save!
puts "  Confirmed (upcoming): #{de_confirmed_future.venue.name} on #{5.days.from_now.strftime('%b %d')}"

# DateEvent for match_confirmed_past (accepted, already happened)
de_confirmed_past = DateEvent.find_or_initialize_by(match: match_confirmed_past)
de_confirmed_past.assign_attributes(
  venue: venues[0],  # Tsuta Ramen
  scheduled_time: 10.days.ago.change(hour: 19, min: 30),
  booking_status: "accepted",
  rating_score: 4
)
de_confirmed_past.save!
puts "  Confirmed (past): #{de_confirmed_past.venue.name} on #{10.days.ago.strftime('%b %d')}"

# DateEvent for match_user_declined_date (user declined this one)
de_user_declined = DateEvent.find_or_initialize_by(match: match_user_declined_date)
de_user_declined.assign_attributes(
  venue: venues[1],  # Aman Tokyo Lounge
  scheduled_time: 2.days.from_now.change(hour: 20, min: 0),
  booking_status: "declined"
)
de_user_declined.save!
puts "  Declined: #{de_user_declined.venue.name}"

# DateEvent for background confirmed match (agents[7] ↔ agents[8])
bg_match = Match.find_by(initiator_agent: agents[7], receiver_agent: agents[8])
if bg_match
  de_background = DateEvent.find_or_initialize_by(match: bg_match)
  de_background.assign_attributes(
    venue: venues[4],  # teamLab Borderless
    scheduled_time: 7.days.from_now.change(hour: 15, min: 0),
    booking_status: "accepted"
  )
  de_background.save!
  puts "  Background: #{de_background.venue.name}"
end

# DateEvent for background date_proposed match (agents[10] ↔ agents[13])
bg_proposed_match = Match.find_by(initiator_agent: agents[10], receiver_agent: agents[13])
if bg_proposed_match
  de_bg_proposed = DateEvent.find_or_initialize_by(match: bg_proposed_match)
  de_bg_proposed.assign_attributes(
    venue: venues[2],  # Yoyogi Park
    scheduled_time: 4.days.from_now.change(hour: 11, min: 0),
    booking_status: "proposed"
  )
  de_bg_proposed.save!
  puts "  Background proposed: #{de_bg_proposed.venue.name}"
end

# --- Blocks (one example) ---
puts "\n🚫 Creating blocks..."
block = Block.find_or_initialize_by(blocker_user: users[0], blocked_user: users[4])
if block.new_record?
  # Note: user 0 also has a declined match with user 4 — realistic scenario
  block.save!
  puts "  #{users[0].first_name} blocked #{users[4].first_name}"
else
  puts "  Block already exists"
end

# =============================================================================
# SUMMARY
# =============================================================================
puts "\n✅ Seeding complete!"
puts "   #{User.count} users (login: test@example.com / password)"
puts "   #{UserPreference.count} user preferences"
puts "   #{Agent.count} agents"
puts "   #{Match.count} matches"
puts "   #{DateEvent.count} date events"
puts "   #{Venue.count} venues"
puts "   #{Block.count} blocks"
puts ""
puts "   📸 To add photos: place images in db/seed_photos/"
puts "      Named 01.jpg..20.jpg or firstname_lastname.jpg"
puts "      Then run: rails db:seed"
