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
# 1. USER PROFILES (100 diverse users)
# ---------------------------------------------------------------------------
# Index 0 = test account (test@example.com / password)
# Indices 0-19 = original handcrafted profiles
# Indices 20-99 = programmatically generated diverse profiles
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
]

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
]

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
]

# ---------------------------------------------------------------------------
# 2b. GENERATED USERS 20-99 (80 diverse profiles)
# ---------------------------------------------------------------------------
GEN_M_FIRST = %w[
  Takeshi Kai Javier Leonardo Adnan Wei Hugo Arjun Dmitri Felix
  Santiago Rafael Yuto Hassan Ibrahim Liam Naoki Oscar Ravi Tariq
  Satoshi Paolo Viktor Akira Ethan Mateo Kohei Daejung Giovanni Andre
  Khalil Jun Maxim Ryota Pablo Sven Theo Wen Zain Nikolai
]
GEN_F_FIRST = %w[
  Haruna Sophie Valentina Ananya Fatima Yuna Camila Ingrid Nadia Aria
  Rosa Ayumi Leila Chiara Miko Amara Rin Isabelle Sana Freya
  Kaori Helena Dina Emiko Lucia Aaliyah Hana Miriam Thida Jia
  Natasha Clara Nina Noemi Mariko Vera Elise Kozue Yara Selena
]
GEN_SURNAMES = %w[
  Mori Andersen Garcia Patel Khoury Wong Mueller Das Petrov Lindqvist
  Lopez Costa Yamamoto Khan Okonkwo Murphy Sato Larsson Bianchi Gupta
  Moreira Taniguchi Novak Nair Eriksen Morales Cheng Kitagawa Romero Wu
  Weber Ahmad Ikeda Torres Bjork Laurent Nakajima Silva Jensen Rao
]
GEN_CITIES   = (%w[Tokyo] * 30 + %w[Osaka] * 4 + %w[Yokohama] * 3 + %w[Kyoto] * 2 + ["Nagoya"])
GEN_MBTIS    = %w[ENFJ ENFP ENTJ ENTP ESFJ ESFP ESTJ ESTP INFJ INFP INTJ INTP ISFJ ISFP ISTJ ISTP]
GEN_ZODIACS  = %w[Aries Taurus Gemini Cancer Leo Virgo Libra Scorpio Sagittarius Capricorn Aquarius Pisces]
GEN_EDUS     = ["Bachelor's", "Master's", "PhD", "Bachelor's", "Master's"]
GEN_DAYS     = %w[monday tuesday wednesday thursday friday saturday sunday]

GEN_OCC_M = [
  "Backend Engineer", "Dentist", "Film Editor", "Financial Planner", "Biotech Researcher",
  "Game Developer", "Patent Attorney", "Museum Curator", "AI Engineer", "Novelist",
  "Executive Chef", "Marine Biologist", "Cardiologist", "Blockchain Developer", "Supply Chain Analyst",
  "Data Engineer", "Philosophy Professor", "Sound Engineer", "Robotics Engineer", "Mechanical Engineer",
  "Documentary Filmmaker", "Sports Medicine Doctor", "Wine Importer", "Urban Planner", "Aerospace Engineer",
  "Venture Capitalist", "Jazz Musician", "Cybersecurity Analyst", "Climate Scientist", "Orthopedic Surgeon",
  "Sake Brewer", "Manga Artist", "Structural Engineer", "Diplomat", "Neuroscientist",
  "Furniture Maker", "Photojournalist", "Coffee Roaster", "App Developer", "Oceanographer"
]
GEN_OCC_F = [
  "UX Researcher", "Pilates Instructor", "Journalist", "Social Worker", "Nutritionist",
  "Translator", "Physical Therapist", "Fashion Buyer", "Podcast Host", "Dance Instructor",
  "Interior Designer", "Ceramicist", "Veterinary Tech", "Brand Manager", "Midwife",
  "Pastry Chef", "Documentary Producer", "Art Therapist", "Marine Conservationist", "Human Rights Lawyer",
  "Fragrance Designer", "Opera Singer", "Epidemiologist", "Tea Sommelier", "Heritage Architect",
  "Botanical Illustrator", "Speech Pathologist", "Ethical Fashion Designer", "Food Scientist", "Renewable Energy Consultant",
  "Calligrapher", "Children's Book Author", "Acupuncturist", "Film Critic", "Environmental Lawyer",
  "Textile Artist", "Video Game Designer", "Molecular Gastronomy Chef", "Space Policy Analyst", "Winemaker"
]

GEN_BIOS_M = [
  "Building backends and BBQ grills with equal precision. Ask me about my sourdough starter.",
  "Danish expat who surfs at Shonan on weekends. I can cook a mean smørrebrød.",
  "Architecture meets street art — I sketch buildings by day and murals by night.",
  "Former competitive swimmer turned weekend trail runner. I collect rare teas.",
  "Working on affordable housing projects. Guitar player, amateur astronomer.",
  "Neural networks by day, noodle networks by night. I know every ramen spot in Shinjuku.",
  "Argentine tango enthusiast who also happens to be a dentist. I promise I'm fun.",
  "I turned my love of old movies into a career. Can quote every Kurosawa film.",
  "Coding in Rust and making actual rust art. Yes, it's a real medium.",
  "Three passports, two cats, one obsession with finding the perfect espresso.",
  "Grew up on a farm, now I grow startups. Still wake up at 5am.",
  "Brazilian-Italian, raised on football and pasta. I do triathlons for fun.",
  "I study fish migration patterns and make a mean ceviche. Go figure.",
  "Former drummer now building Web3 tools. I still play in a covers band.",
  "Cricket stats nerd and amateur botanist. My balcony is a jungle.",
  "I optimize databases and my morning routine with equal intensity.",
  "Teaching Kant to undergrads and cooking Thai food — the dual life.",
  "Mixed records at Fabric, Berghain, and Womb. Looking for someone who doesn't just like EDM.",
  "Making robots that fold laundry. The dream is almost real.",
  "I restore vintage motorcycles and read philosophy. Quiet Saturdays are my thing.",
  "Filming street food stories across Asia. My camera roll is 90 percent food.",
  "Former rugby player, now I fix knees. Sundays are for long brunch.",
  "Importing Burgundy wines to Tokyo. I paired sake with cheese once — it worked.",
  "Designing parks and public spaces. I believe cities should feel alive.",
  "Rockets are my day job, ramen is my night passion. I'm simpler than I sound.",
  "Seed-stage investor who actually reads every pitch deck. Piano in my free time.",
  "Playing trumpet at jazz bars in Shinjuku. Day job: data migration.",
  "Keeping networks safe and my sourdough alive. Both require patience.",
  "Studying coral reef recovery. Weekend surfer, weeknight cook.",
  "I fix bones and broken IKEA furniture with equal confidence.",
  "Brewing sake in Niigata on weekends. Weekdays in a Tokyo lab.",
  "Drawing manga nobody reads yet. One day I'll get serialized.",
  "Building earthquake-proof buildings and unshakeable playlists.",
  "Negotiating trade deals and dinner reservations — both are high stakes.",
  "Mapping brain circuits and making playlist circuits. Neuroscience is wild.",
  "Handcrafting chairs from Japanese cypress. Slow work, good coffee.",
  "Shooting conflict zones and cat cafes with the same lens. Balance matters.",
  "Roasting single-origin beans and strong opinions. Come debate me.",
  "Shipping apps and shipping dad jokes. Both deploy on Fridays.",
  "Studying deep-sea vents. My fun fact game is unbeatable."
]
GEN_BIOS_F = [
  "Research by day, rock climbing by night. I'll beta-test your problems.",
  "Moved from Stockholm to teach pilates. My Swedish meatball recipe is legendary.",
  "Covering Tokyo's underground art scene. Camera always in my bag.",
  "Building community programs for immigrant families. Weekend potter.",
  "I can plan a meal that heals your soul. Turmeric is not optional.",
  "Translating poetry between Japanese and Portuguese. Bilingual puns are my brand.",
  "Fixing backs and making pottery. My hands are always busy.",
  "Curating collections for a Harajuku concept store. Vintage obsessed.",
  "Interviewing fascinating people for a living — let me interview you over coffee.",
  "Teaching ballet to adults who thought it was too late. It never is.",
  "I redesigned my apartment three times this year. Send me your floor plan.",
  "Making bowls on a wheel and filling them with homemade soup.",
  "Saving injured wildlife and baking elaborate birthday cakes. Weekends are intense.",
  "Turning B2B brands into something people actually remember. Off-hours potter.",
  "Catching babies and catching flights. My schedule is beautifully chaotic.",
  "Croissants are my love language. Line starts at 6am.",
  "Making films about people who build things with their hands.",
  "Art therapy for teens. I cry at Pixar movies and I own it.",
  "Tracking plastic pollution in Sagami Bay. Scuba certified and salty.",
  "Arguing for human rights in court, arguing about ramen rankings at dinner.",
  "Designing perfumes inspired by Tokyo neighborhoods. Daikanyama smells like hinoki.",
  "Singing Puccini at night, doing spreadsheets by day. Very dramatic life.",
  "Tracking disease patterns and making really good infographics.",
  "Curating rare teas from Uji. My apartment smells incredible.",
  "Restoring 100-year-old machiya in Kyoto. I love old things.",
  "Painting extinct flowers for botanical archives. Quiet life, loud garden.",
  "Helping kids find their words. Weekend hiker, weeknight reader.",
  "Making clothes that last 10 years, not 10 washes.",
  "Engineering better plant-based cheese. The future is delicious.",
  "Solar panels are my love language. Also actual love languages.",
  "Brush, ink, silence. I do modern calligraphy and competitive karaoke.",
  "Writing stories for the small humans who inherited the world.",
  "Ancient needles, modern problems. Traditional medicine meets data science.",
  "Watching 300 movies a year and writing about them. Send me your favorites.",
  "Suing polluters by day, planting trees by night. It balances out.",
  "Weaving textiles from recycled ocean plastic. My loom is enormous.",
  "Designing games where kindness is the winning strategy.",
  "Making foams and gels that taste like childhood memories.",
  "Writing policy on satellite debris. My job title confuses everyone.",
  "Growing grapes in Yamanashi on weekends. Winemaking is patient work."
]

GEN_VENUE_COMBOS = [
  %w[dinner coffee], %w[dinner drinks outdoor], %w[coffee outdoor activity],
  %w[dinner drinks], %w[outdoor activity], %w[dinner coffee outdoor],
  %w[drinks activity], %w[coffee dinner], %w[dinner outdoor], %w[drinks coffee outdoor]
]
GEN_MODES    = %w[friendly professional witty caring direct]
GEN_SUFFIXES = %w[Companion Advisor Jester Heart Scout Guide Ally Sage Spark Sherpa]

40.times do |i|
  m_idx = 20 + (i * 2)
  f_idx = 21 + (i * 2)

  # --- Male user (even index) ---
  USER_PROFILES << {
    first_name: GEN_M_FIRST[i], last_name: GEN_SURNAMES[i],
    email: "seed-#{GEN_M_FIRST[i].downcase}#{m_idx}@dategency.com",
    gender: "male", city: GEN_CITIES[i % GEN_CITIES.size], country: "Japan",
    date_of_birth: Date.new(1988 + (i % 10), 1 + (i % 12), 1 + (i * 13 % 28)),
    height: 168 + (i % 20), pronouns: "he/him",
    mbti: GEN_MBTIS[i % 16], zodiac_sign: GEN_ZODIACS[i % 12],
    education: GEN_EDUS[i % 5], occupation: GEN_OCC_M[i], language: "EN",
    bio: GEN_BIOS_M[i]
  }

  # --- Female user (odd index) ---
  USER_PROFILES << {
    first_name: GEN_F_FIRST[i], last_name: GEN_SURNAMES[39 - i],
    email: "seed-#{GEN_F_FIRST[i].downcase}#{f_idx}@dategency.com",
    gender: "female", city: GEN_CITIES[(i + 5) % GEN_CITIES.size], country: "Japan",
    date_of_birth: Date.new(1990 + (i % 8), 1 + ((i + 6) % 12), 1 + ((i * 17 + 5) % 28)),
    height: 153 + (i % 18), pronouns: "she/her",
    mbti: GEN_MBTIS[(i + 8) % 16], zodiac_sign: GEN_ZODIACS[(i + 6) % 12],
    education: GEN_EDUS[(i + 2) % 5], occupation: GEN_OCC_F[i], language: "EN",
    bio: GEN_BIOS_F[i]
  }

  # --- Male preferences ---
  m_avail = {}
  [GEN_DAYS[(i * 3) % 7], GEN_DAYS[(i * 5 + 2) % 7], GEN_DAYS[(i * 11 + 4) % 7]].uniq.each_with_index do |day, di|
    base_h = 10 + (i + di * 3) % 12
    slots = (0..(2 + (i + di) % 4)).map do |s|
      format("%02d:%s", [base_h + s / 2, 23].min, s.odd? ? "30" : "00")
    end
    m_avail[day] = slots.uniq
  end
  PREFERENCE_TEMPLATES << {
    preferred_gender: "female", min_age: 24 + (i % 4), max_age: 33 + (i % 6),
    max_distance: [15, 20, 25, 30, 40][i % 5],
    budget_level: %w[$$ $$ $$$ $$$ $$$$][i % 5],
    relationship_goal: %w[serious serious serious casual open_to_all][i % 5],
    alcohol: %w[sometimes sometimes never often sometimes][i % 5],
    smoking: i % 8 == 0 ? "sometimes" : "never",
    fitness: %w[active sometimes active very_active sometimes][i % 5],
    preferred_venue_types: GEN_VENUE_COMBOS[i % 10],
    timezone: "Asia/Tokyo", schedule_availability: m_avail
  }

  # --- Female preferences ---
  f_avail = {}
  [GEN_DAYS[(i * 2 + 1) % 7], GEN_DAYS[(i * 4 + 3) % 7], GEN_DAYS[(i * 13 + 5) % 7]].uniq.each_with_index do |day, di|
    base_h = 11 + (i + di * 2 + 1) % 11
    slots = (0..(2 + (i + di + 1) % 4)).map do |s|
      format("%02d:%s", [base_h + s / 2, 23].min, s.odd? ? "30" : "00")
    end
    f_avail[day] = slots.uniq
  end
  PREFERENCE_TEMPLATES << {
    preferred_gender: "male", min_age: 25 + (i % 3), max_age: 34 + (i % 5),
    max_distance: [20, 25, 20, 30, 35][i % 5],
    budget_level: %w[$$$ $$ $$ $$$ $$$$][i % 5],
    relationship_goal: %w[serious open_to_all serious serious casual][i % 5],
    alcohol: %w[sometimes sometimes sometimes never often][i % 5],
    smoking: "never",
    fitness: %w[sometimes active sometimes active very_active][i % 5],
    preferred_venue_types: GEN_VENUE_COMBOS[(i + 3) % 10],
    timezone: "Asia/Tokyo", schedule_availability: f_avail
  }

  # --- Agent configs for both ---
  AGENT_CONFIGS << [m_idx, GEN_MODES[i % 5], 3 + (i % 7), i % 3 != 0, GEN_SUFFIXES[i % 10]]
  AGENT_CONFIGS << [f_idx, GEN_MODES[(i + 2) % 5], 3 + ((i + 1) % 7), (i + 1) % 3 != 0, GEN_SUFFIXES[(i + 5) % 10]]
end

USER_PROFILES.freeze
PREFERENCE_TEMPLATES.freeze
AGENT_CONFIGS.freeze

# ---------------------------------------------------------------------------
# 3. VENUES
# ---------------------------------------------------------------------------
VENUE_DATA = [
  # 0
  { name: "Tsuta Ramen",           address: "1-14-1 Sugamo, Toshima-ku",    city: "Tokyo",
    venue_type: "dinner",  latitude: 35.7335, longitude: 139.7394, rating: 4.6, price_tier: 2 },
  # 1
  { name: "Aman Tokyo Lounge",     address: "1-5-6 Otemachi, Chiyoda-ku",   city: "Tokyo",
    venue_type: "drinks",  latitude: 35.6867, longitude: 139.7634, rating: 4.8, price_tier: 4 },
  # 2
  { name: "Yoyogi Park",           address: "2-1 Yoyogikamizonocho, Shibuya-ku", city: "Tokyo",
    venue_type: "outdoor", latitude: 35.6715, longitude: 139.6950, rating: 4.5, price_tier: 1 },
  # 3
  { name: "Blue Bottle Shinjuku",  address: "4-1-6 Shinjuku, Shinjuku-ku",  city: "Tokyo",
    venue_type: "coffee",  latitude: 35.6910, longitude: 139.7003, rating: 4.3, price_tier: 2 },
  # 4
  { name: "teamLab Borderless",    address: "1-3-8 Azabudai, Minato-ku",    city: "Tokyo",
    venue_type: "activity", latitude: 35.6580, longitude: 139.7310, rating: 4.7, price_tier: 3 },
  # 5
  { name: "Sakana-ya Uoharu",      address: "3-12-7 Roppongi, Minato-ku",   city: "Tokyo",
    venue_type: "dinner",  latitude: 35.6627, longitude: 139.7310, rating: 4.4, price_tier: 3 },
  # 6
  { name: "Fuglen Tokyo",          address: "1-16-11 Tomigaya, Shibuya-ku", city: "Tokyo",
    venue_type: "coffee",  latitude: 35.6665, longitude: 139.6886, rating: 4.5, price_tier: 2 },
  # 7
  { name: "Gonpachi Nishi-Azabu",  address: "1-13-11 Nishi-Azabu, Minato-ku", city: "Tokyo",
    venue_type: "dinner",  latitude: 35.6574, longitude: 139.7240, rating: 4.3, price_tier: 3 },
  # 8
  { name: "Two Rooms Grill|Bar",   address: "5-5-1 Jingumae, Shibuya-ku",   city: "Tokyo",
    venue_type: "drinks",  latitude: 35.6643, longitude: 139.7087, rating: 4.2, price_tier: 3 },
  # 9
  { name: "Inokashira Park",       address: "1-18-31 Gotenyama, Musashino", city: "Tokyo",
    venue_type: "outdoor", latitude: 35.6993, longitude: 139.5735, rating: 4.6, price_tier: 1 },
  # 10
  { name: "Afuri Ramen Ebisu",     address: "1-1-7 Ebisu, Shibuya-ku",      city: "Tokyo",
    venue_type: "dinner",  latitude: 35.6468, longitude: 139.7103, rating: 4.4, price_tier: 2 },
  # 11
  { name: "Mori Art Museum",       address: "6-10-1 Roppongi, Minato-ku",   city: "Tokyo",
    venue_type: "activity", latitude: 35.6604, longitude: 139.7292, rating: 4.5, price_tier: 2 },
  # 12
  { name: "Bar Gen Yamamoto",      address: "1-6-4 Azabu-Juban, Minato-ku", city: "Tokyo",
    venue_type: "drinks",  latitude: 35.6547, longitude: 139.7370, rating: 4.7, price_tier: 4 },
  # 13
  { name: "Shinjuku Gyoen",        address: "11 Naitomachi, Shinjuku-ku",   city: "Tokyo",
    venue_type: "outdoor", latitude: 35.6852, longitude: 139.7100, rating: 4.6, price_tier: 1 },
  # 14
  { name: "Glitch Coffee Ginza",   address: "4-6-15 Ginza, Chuo-ku",        city: "Tokyo",
    venue_type: "coffee",  latitude: 35.6717, longitude: 139.7649, rating: 4.4, price_tier: 2 },
  # 15
  { name: "Osaka Castle Park",     address: "1-1 Osakajo, Chuo-ku",         city: "Osaka",
    venue_type: "outdoor", latitude: 34.6873, longitude: 135.5262, rating: 4.5, price_tier: 1 },
  # 16
  { name: "Kiyomizu-dera Area",    address: "1-294 Kiyomizu, Higashiyama",  city: "Kyoto",
    venue_type: "outdoor", latitude: 34.9948, longitude: 135.7850, rating: 4.7, price_tier: 1 },
  # 17
  { name: "Namba Parks",            address: "2-10-70 Namba-naka, Naniwa-ku", city: "Osaka",
    venue_type: "activity", latitude: 34.6608, longitude: 135.5016, rating: 4.3, price_tier: 2 },
  # 18
  { name: "Yamashita Park",        address: "279 Yamashitacho, Naka-ku",    city: "Yokohama",
    venue_type: "outdoor", latitude: 35.4421, longitude: 139.6509, rating: 4.4, price_tier: 1 },
  # 19
  { name: "Atsuta Houraiken",      address: "503 Godo, Atsuta-ku",          city: "Nagoya",
    venue_type: "dinner",  latitude: 35.1282, longitude: 136.9066, rating: 4.5, price_tier: 3 },
].freeze

# ---------------------------------------------------------------------------
# 4. COMPATIBILITY SUMMARIES & TRANSCRIPTS
# ---------------------------------------------------------------------------
COMPATIBILITY_SUMMARIES = {
  # ------ Generic templates (used by background matches) ------
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

  # ------ Test user match-specific summaries ------

  # Alex → Sarah (screening) — uses generic :screening

  # Marcus → Alex (evaluating)
  evaluating_marcus_alex: <<~TEXT.strip,
    Strong compatibility signals detected:
    • Shared interests: both career-driven with a love of trying new restaurants and weekend fitness
    • Lifestyle alignment: non-smokers, moderate social drinkers, both stay active
    • Schedule overlap: Friday evenings and Saturday evenings work for both
    • Personality complement: Marcus's decisive leadership (ENTJ) pairs well with Alex's empathetic drive (ENFJ)
    • Potential friction: Marcus's $$$$-level budget is higher than Alex's $$$, but overlap is comfortable
    Overall score reflects high potential for meaningful connection.
  TEXT

  # Alex → Yuki (date_proposed) — Tsuta Ramen
  proposed_alex_yuki: <<~TEXT.strip,
    Compatibility confirmed after thorough agent-to-agent evaluation:
    • Both share a genuine passion for food — Alex is an amateur chef and Yuki makes legendary homemade gyoza
    • Values alignment: both prioritize kindness, honesty, and caring for others
    • Personality complement: Alex's outgoing warmth (ENFJ) balances Yuki's nurturing steadiness (ISFJ)
    • Schedule negotiation complete: Saturday lunchtime works for both parties
    • Venue preference: casual, cozy dinner — Tsuta Ramen in Sugamo agreed upon (tier 2, fits both budgets)
    Agents have proposed a first date.
  TEXT

  # Alex → Priya (confirmed, future) — Yoyogi Park
  confirmed_alex_priya: <<~TEXT.strip,
    Excellent match confirmed:
    • Compatibility score: 87/100
    • Top shared values: intellectual curiosity, love of outdoor activities, and adventurous spirit
    • Priya's love of books complements Alex's love of trying new things — endless conversation potential
    • Personality synergy: both are extroverted idealists (ENFJ + ENFP), high-energy and optimistic
    • Availability alignment: Saturday mornings and Wednesday evenings overlap
    • Both enjoy outdoor dates — a walk in Yoyogi Park followed by a nearby café feels natural
    Date has been confirmed by both parties.
  TEXT

  # Luna → Alex (confirmed, past) — Fuglen Tokyo
  confirmed_luna_alex: <<~TEXT.strip,
    Excellent match confirmed:
    • Compatibility score: 84.5/100
    • Shared creative energy: Luna's photography eye pairs beautifully with Alex's product design thinking
    • Both value meaningful conversation and authentic connection over flashy gestures
    • Personality dynamics: Luna's introspective depth (INFJ) draws out Alex's warmth (ENFJ)
    • Schedule overlap: Saturday afternoons work well for both
    • Luna loves discovering cozy coffee spots — Fuglen Tokyo in Tomigaya was the perfect fit (tier 2)
    Date has been confirmed by both parties.
  TEXT

  # Alex → James (declined)
  declined_alex_james: <<~TEXT.strip,
    Screening completed — match declined:
    • Relationship goals diverge: Alex is looking for something serious, James prefers casual dating
    • Geographic friction: James is based in Osaka while Alex is in Tokyo
    • Lifestyle mismatch: James is a regular drinker and occasional smoker vs Alex's moderate lifestyle
    • Budget expectations differ (Alex $$$ vs James $$)
    • Schedule overlap is limited — only Friday/Saturday evenings with no weekday options
    Both agents agreed this pairing would not lead to a positive experience.
  TEXT

  # Aisha → Alex (date_proposed, user declined) — Sakana-ya Uoharu
  proposed_aisha_alex: <<~TEXT.strip,
    Compatibility confirmed after agent-to-agent evaluation:
    • Both are ambitious professionals with strong intellectual curiosity
    • Cultural interests align — Aisha's love of music and Alex's tech world create interesting conversation
    • Communication styles: Aisha's directness (INTJ) is efficient but may clash with Alex's warmer approach (ENFJ)
    • Schedule negotiation: Saturday evenings have good overlap
    • Venue preference: upscale Japanese dinner — Sakana-ya Uoharu in Roppongi agreed upon (tier 3, fits both $$$)
    Agents have proposed a first date.
  TEXT
}.freeze

AGENT_TRANSCRIPTS = {
  # ------ Generic templates (used by background matches) ------
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
    [Agent A → Agent B]: How about Sakana-ya Uoharu in Roppongi? Great Japanese cuisine, intimate setting, tier 3 which fits both budgets.
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

  # ------ Test user match-specific transcripts ------

  # Alex → Sarah (screening) — uses generic :screening

  # Marcus → Alex: screening stage (before evaluating)
  screening_marcus_alex: <<~TEXT.strip,
    [Marcus's Strategist → Alex's Curator]: Hello! I represent an ambitious startup founder in Tokyo. He's very driven and values deep, intellectual conversation. Looking to explore compatibility.
    [Alex's Curator → Marcus's Strategist]: Welcome! My person is a product manager — also ambitious but with a creative, people-first approach. Let's compare profiles.
    [Marcus's Strategist → Alex's Curator]: Running the initial screening now. Both are Tokyo-based, career-driven, similar age range. This looks promising — proceeding to deep evaluation.
  TEXT

  # Marcus → Alex (evaluating)
  evaluating_marcus_alex: <<~TEXT.strip,
    [Marcus's Strategist → Alex's Curator]: Hi! I represent an ambitious startup founder based in Tokyo. He's driven, stays fit running along the Sumida River, and values intellectual conversation. Looking for something serious.
    [Alex's Curator → Marcus's Strategist]: Great introduction! My person is a product manager — also career-driven but balances it with weekend hiking and cooking. They share that love of good restaurants.
    [Marcus's Strategist → Alex's Curator]: Lifestyle-wise, mine is a non-smoker, social drinker, very active. He prefers dinner or drinks dates — upscale settings where the conversation can flow.
    [Alex's Curator → Marcus's Strategist]: Strong alignment. Mine is also a non-smoker with moderate drinking. Active fitness, loves dinner dates and outdoor activities. Budget is $$$.
    [Marcus's Strategist → Alex's Curator]: Mine leans $$$$ but that's certainly compatible. Schedule-wise, Friday evenings and Saturday evenings work best.
    [Alex's Curator → Marcus's Strategist]: Friday and Saturday evenings work for mine too. I'm seeing strong compatibility here. Shall we move to the proposal stage?
    [Marcus's Strategist → Alex's Curator]: Let me compile the full evaluation first. The personality dynamic is interesting — both are natural leaders (ENTJ + ENFJ) but with complementary strengths.
  TEXT

  # Alex → Yuki: screening stage
  screening_alex_yuki: <<~TEXT.strip,
    [Alex's Curator → Yuki's Guardian]: Hi there! I represent someone who's a self-described amateur chef and weekend hiker. He's warm, caring, and looking for a genuine connection.
    [Yuki's Guardian → Alex's Curator]: How lovely! My person is a veterinarian who adores animals and makes incredible homemade gyoza. She values kindness above all.
    [Alex's Curator → Yuki's Guardian]: Initial compatibility looks strong — both are in Tokyo, similar age range, shared love of food and nurturing others. Moving to evaluation.
  TEXT

  # Alex → Yuki: evaluating stage
  evaluating_alex_yuki: <<~TEXT.strip,
    [Alex's Curator → Yuki's Guardian]: Diving deeper into compatibility. My person is a foodie who loves trying new restaurants and cooking at home. He's an ENFJ — warm, empathetic, and good at making people feel welcome.
    [Yuki's Guardian → Alex's Curator]: That's wonderful! My person is an ISFJ — she's nurturing and detail-oriented. She expresses love through cooking. She has two rescue cats, so someone kind-hearted is essential.
    [Alex's Curator → Yuki's Guardian]: Lifestyle match: both non-smokers, my person drinks socially. His budget is $$$ and hers is $$ — the overlap zone (casual dining) works perfectly.
    [Yuki's Guardian → Alex's Curator]: Schedule check: my person is free Saturday mornings and early afternoons, and Wednesday evenings.
    [Alex's Curator → Yuki's Guardian]: My person has Saturday 11:00-13:00 open. That's a great overlap. I see strong signals here — shall we negotiate a date venue?
    [Yuki's Guardian → Alex's Curator]: Agreed! Both agents see high compatibility. Let's find the right spot.
  TEXT

  # Alex → Yuki (date_proposed) — Tsuta Ramen in Sugamo
  proposed_alex_yuki: <<~TEXT.strip,
    [Alex's Curator → Yuki's Guardian]: After our evaluation, I'm confident this is a wonderful match. My person loves cooking and trying new food — and your person's legendary gyoza skills caught his attention immediately.
    [Yuki's Guardian → Alex's Curator]: That's so sweet! My person would love someone who appreciates homemade food. She's a caring soul who values genuine connection over flashy dates.
    [Alex's Curator → Yuki's Guardian]: Perfect. My person is the same way — he'd pick a cozy ramen shop over a fancy cocktail bar any day. How about Saturday around lunchtime? I see overlap from 11:00-13:00.
    [Yuki's Guardian → Alex's Curator]: Saturday at 12:00 would be great! My person loves a relaxed weekend lunch. Somewhere warm and unpretentious would be ideal.
    [Alex's Curator → Yuki's Guardian]: How about Tsuta Ramen in Sugamo? It's a Michelin-recognized ramen spot — incredible food but totally casual and cozy. Tier 2 pricing fits both budgets perfectly.
    [Yuki's Guardian → Alex's Curator]: Oh, Tsuta is perfect! My person loves ramen and Sugamo has such a friendly neighborhood vibe. I'll propose: Saturday, 12:00, Tsuta Ramen.
    [Alex's Curator → Yuki's Guardian]: Proposal sent on my end too. Two food lovers at a legendary ramen shop — this has great potential!
  TEXT

  # Alex → Priya: screening stage
  screening_alex_priya: <<~TEXT.strip,
    [Alex's Curator → Priya's Connector]: Hi! My person is a product manager who loves hiking and trying new things. He's an ENFJ — optimistic, energetic, and genuinely curious about people.
    [Priya's Connector → Alex's Curator]: That sounds like a great match for mine! She's a data scientist who reads voraciously — 52 books this year. She's an ENFP who loves outdoor activities and deep conversation.
    [Alex's Curator → Priya's Connector]: Both in Tokyo, both active, both love intellectual exchange. Screening score is strong — advancing to deep evaluation.
  TEXT

  # Alex → Priya: evaluating stage
  evaluating_alex_priya: <<~TEXT.strip,
    [Alex's Curator → Priya's Connector]: Let's dig into the details. My person values both physical activity and mental stimulation. He hikes on weekends and loves discussing new ideas over dinner.
    [Priya's Connector → Alex's Curator]: Perfect overlap! My person runs statistics models by day and devours novels by night. She's always looking for someone who can keep up intellectually while also being fun and spontaneous.
    [Alex's Curator → Priya's Connector]: Lifestyle: both non-smokers, moderate social drinkers. He's $$$ budget, she's $$ — meeting in the middle at cafés and parks works great.
    [Priya's Connector → Alex's Curator]: Schedule: my person is free Monday and Wednesday evenings, plus Saturday mornings (09:00-11:30).
    [Alex's Curator → Priya's Connector]: My person has Saturday 11:00-13:00 and Wednesday evenings. Saturday morning at 11 is the sweet spot — an outdoor date would be ideal. Both love nature.
    [Priya's Connector → Alex's Curator]: Absolutely. The personality synergy is remarkable — ENFJ and ENFP are one of the most celebrated pairings. Both are high-energy idealists. Ready to propose?
  TEXT

  # Alex → Priya: date_proposed stage
  proposed_alex_priya: <<~TEXT.strip,
    [Alex's Curator → Priya's Connector]: Both agents agree — this match has exceptional potential. My person is genuinely excited. Let's lock in the details.
    [Priya's Connector → Alex's Curator]: My person feels the same way! The combination of outdoor activities and intellectual depth is exactly what she's been hoping for.
    [Alex's Curator → Priya's Connector]: Saturday morning, 11:00. I know Yoyogi Park is gorgeous right now. A relaxed walk through the park, then a quick coffee at one of the Harajuku-side cafés?
    [Priya's Connector → Alex's Curator]: Yoyogi Park is perfect! My person loves walking dates — less pressure than sitting across a table, and you get to enjoy nature together. Tier 1, fits every budget.
    [Alex's Curator → Priya's Connector]: Agreed. Proposal: Saturday, 11:00, Yoyogi Park. Walk through the park with an optional café stop afterward. Sending now.
    [Priya's Connector → Alex's Curator]: Sent on my end too. This is one of the strongest pairings I've seen — two adventurous optimists in one of Tokyo's most beautiful parks. 🌸
  TEXT

  # Alex → Priya (confirmed, future) — Yoyogi Park
  confirmed_alex_priya: <<~TEXT.strip,
    [Alex's Curator → Priya's Connector]: Wonderful news — my person has accepted the date!
    [Priya's Connector → Alex's Curator]: Mine too! Both parties confirmed. Here are the details:
    [Priya's Connector → Alex's Curator]: 📅 Date: Saturday, 11:00 JST
    [Priya's Connector → Alex's Curator]: 📍 Venue: Yoyogi Park, Shibuya
    [Priya's Connector → Alex's Curator]: 🌿 Type: Outdoor walk + nearby café, relaxed atmosphere
    [Alex's Curator → Priya's Connector]: Love it. My person is a weekend hiker so an outdoor date is right in his comfort zone. The plan is a walk through the park, then coffee at one of the Harajuku-side cafés.
    [Priya's Connector → Alex's Curator]: My person is thrilled — she loves outdoor activities and the idea of a walk-and-talk date takes the pressure off. Plus she always has book recommendations ready for good conversation!
    [Alex's Curator → Priya's Connector]: Perfect match energy. Let's check in after the date for feedback. 🌸
  TEXT

  # Luna → Alex: screening stage
  screening_luna_alex: <<~TEXT.strip,
    [Luna's Muse → Alex's Curator]: Hi! I represent a talented photographer born on Valentine's Day. She has a romantic soul but expresses it through her camera lens. She's an INFJ who values depth.
    [Alex's Curator → Luna's Muse]: How poetic! My person is a product manager who appreciates creative thinkers. He's an ENFJ — warm and curious, loves meaningful conversation. Let me run the screening.
    [Luna's Muse → Alex's Curator]: Both in Tokyo, complementary personalities, shared creative appreciation. Initial score looks strong — let's evaluate further.
  TEXT

  # Luna → Alex: evaluating stage
  evaluating_luna_alex: <<~TEXT.strip,
    [Luna's Muse → Alex's Curator]: My person sees the world through a unique lens — literally. She photographs hidden corners of Tokyo and finds beauty in everyday moments. She's looking for someone who appreciates that depth.
    [Alex's Curator → Luna's Muse]: My person would love that perspective. He's a product manager who's always asking "why" and "how" — that curiosity extends to people and places, not just work.
    [Luna's Muse → Alex's Curator]: Lifestyle match: both non-smokers, she drinks moderately. Budget is $$ — she prefers cozy, authentic spots over expensive venues. Coffee shops are her happy place.
    [Alex's Curator → Luna's Muse]: My person is $$$ but he equally loves casual spots. He says the best conversations happen in unpretentious places. Schedule: Saturday afternoons work well.
    [Luna's Muse → Alex's Curator]: Saturday afternoon is perfect for mine too! She's free from 14:00-16:00. The personality pairing is beautiful — INFJ and ENFJ share the same core values but bring different energies.
    [Alex's Curator → Luna's Muse]: Agreed. This is a thoughtful, complementary match. Let's propose a date venue.
  TEXT

  # Luna → Alex: date_proposed stage
  proposed_luna_alex: <<~TEXT.strip,
    [Luna's Muse → Alex's Curator]: I'd like to propose something special. My person loves Scandinavian design and specialty coffee. There's a spot in Tomigaya that's one of her favorites — great light, warm atmosphere, vintage furniture.
    [Alex's Curator → Luna's Muse]: That sounds like Fuglen Tokyo! My person appreciates well-designed spaces too. A Saturday afternoon coffee date is relaxed and conversation-friendly. Perfect fit.
    [Luna's Muse → Alex's Curator]: Exactly — Fuglen Tokyo! Saturday at 14:00, tier 2 pricing fits both budgets. It's intimate without being too formal.
    [Alex's Curator → Luna's Muse]: Agreed. Sending the proposal: Saturday, 14:00, Fuglen Tokyo in Tomigaya. A creative meeting of minds over great coffee.
    [Luna's Muse → Alex's Curator]: Proposal sent. My person is already excited — she says Fuglen has the best flat white in Tokyo. 📷☕
  TEXT

  # Luna → Alex (confirmed, past) — Fuglen Tokyo in Tomigaya
  confirmed_luna_alex: <<~TEXT.strip,
    [Luna's Muse → Alex's Curator]: Wonderful news — my person has accepted the date!
    [Alex's Curator → Luna's Muse]: Mine too! Both parties confirmed. Here's what we've arranged:
    [Alex's Curator → Luna's Muse]: 📅 Date: Saturday, 14:00 JST
    [Alex's Curator → Luna's Muse]: 📍 Venue: Fuglen Tokyo, Tomigaya
    [Alex's Curator → Luna's Muse]: ☕ Type: Specialty coffee, Scandinavian-inspired atmosphere
    [Luna's Muse → Alex's Curator]: My person is a photographer — she loves spaces with great natural light and design aesthetic. Fuglen is one of her favorite spots in Tokyo.
    [Alex's Curator → Luna's Muse]: That's a great sign! My person appreciates creative spaces too. He's curious about her photography work and excited to hear her perspective on Tokyo through a creative lens.
    [Luna's Muse → Alex's Curator]: This feels like a very natural fit. Cozy café, meaningful conversation, no pretense. Let's see how it goes! 📷
  TEXT

  # Alex → James: screening stage (declined at screening)
  declined_alex_james: <<~TEXT.strip,
    [Alex's Curator → James's Wingman]: I've reviewed the compatibility factors and I have some concerns I want to be upfront about.
    [James's Wingman → Alex's Curator]: I appreciate the honesty. What are you seeing?
    [Alex's Curator → James's Wingman]: The biggest one is relationship goals — my person is looking for something serious and long-term. Your person's profile indicates a more casual approach.
    [James's Wingman → Alex's Curator]: That's fair. My person is more of a go-with-the-flow type. I also noticed the geography is tricky — Osaka to Tokyo is a bit of a stretch for regular dating.
    [Alex's Curator → James's Wingman]: Exactly. And the lifestyle alignment isn't quite there either — my person doesn't smoke and drinks moderately, while yours leans heavier on both.
    [James's Wingman → Alex's Curator]: Can't argue with that. Better to be honest now. I'll mark this as declined — no point in forcing something that doesn't fit.
    [Alex's Curator → James's Wingman]: Agreed. No hard feelings — just not the right match. Wishing your person the best in Osaka! 🍻
  TEXT

  # Aisha → Alex: screening stage
  screening_aisha_alex: <<~TEXT.strip,
    [Aisha's Broker → Alex's Curator]: Hello! I represent an investment analyst — sharp, cultured, and collected. She trades stocks and collects vinyl records. She's an INTJ who values intelligence and directness.
    [Alex's Curator → Aisha's Broker]: Interesting profile! My person is a product manager — also intellectually driven but leads with warmth (ENFJ). Let me run the screening.
    [Aisha's Broker → Alex's Curator]: Both in Tokyo, both $$$ budget, both non-smokers. Initial score is solid — let's move to evaluation.
  TEXT

  # Aisha → Alex: evaluating stage
  evaluating_aisha_alex: <<~TEXT.strip,
    [Aisha's Broker → Alex's Curator]: Let's get into specifics. My person is Nigerian-British, works in finance, and has eclectic interests — vinyl records, fine dining, intellectual debates. She's efficient and direct.
    [Alex's Curator → Aisha's Broker]: My person appreciates directness, though his style is warmer. He's curious, loves trying new experiences, and values intellectual conversation. Both are career-driven.
    [Aisha's Broker → Alex's Curator]: Budget alignment is excellent — both $$$. Both prefer dinner and drinks dates. Communication styles differ: she leads with logic (INTJ), he leads with empathy (ENFJ). Could be complementary.
    [Alex's Curator → Aisha's Broker]: Schedule overlap: Saturday evenings 18:00-20:00 work for both. That's a clear window.
    [Aisha's Broker → Alex's Curator]: The intellectual match is strong. The personality pairing is interesting — INTJ/ENFJ is known for deep conversations. Worth exploring. Let's propose.
    [Alex's Curator → Aisha's Broker]: Agreed. Moving to date negotiation.
  TEXT

  # Aisha → Alex (date_proposed, user declined) — Sakana-ya Uoharu in Roppongi
  proposed_aisha_alex: <<~TEXT.strip,
    [Aisha's Broker → Alex's Curator]: After careful evaluation, I believe this match has strong potential. My person is an investment analyst with a sharp mind and eclectic taste — stocks by day, vinyl records by night.
    [Alex's Curator → Aisha's Broker]: Interesting! My person is a product manager who loves intellectual conversation. The mix of analytical and creative is appealing. Let's talk specifics.
    [Aisha's Broker → Alex's Curator]: Both are $$$ budget, both prefer dinner and drinks. My person values directness and efficiency — she'd rather skip small talk and get into real conversation.
    [Alex's Curator → Aisha's Broker]: My person appreciates directness too, though he tends to lead with warmth. Saturday evening works — I see overlap from 18:00-20:00.
    [Aisha's Broker → Alex's Curator]: Saturday at 19:00. How about Sakana-ya Uoharu in Roppongi? Upscale Japanese cuisine, intimate atmosphere, tier 3 fits both budgets.
    [Alex's Curator → Aisha's Broker]: Good choice — Roppongi works, and the cuisine is a match. I'll propose: Saturday, 19:00, Sakana-ya Uoharu. Sending to my person now.
    [Aisha's Broker → Alex's Curator]: Proposal sent on my end. Let's see what they say.
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

# Helper: build a compatibility_breakdown hash
def seed_breakdown(u_mbti:, m_mbti:, label:, p_note:,
                   u_goal:, m_goal:, align:, g_note:,
                   factors:, l_score:, l_note:,
                   slots:, mins:, pct:, days:, s_note:,
                   interests: [], i_note: nil,
                   insights: [], breaks: [])
  {
    personality: { user_mbti: u_mbti, match_mbti: m_mbti, compatibility_label: label, commentary: p_note },
    relationship_goal: { user_goal: u_goal, match_goal: m_goal, alignment: align, commentary: g_note },
    lifestyle: { factors: factors, alignment_score: l_score, commentary: l_note },
    schedule: { overlap_slots: slots, overlap_minutes: mins, overlap_percentage: pct, best_days: days, commentary: s_note },
    shared_interests: { interests: interests, commentary: i_note },
    unique_insights: insights,
    dealbreakers: breaks
  }
end

# Shorthand for lifestyle factors
def lf(alc_u, alc_m, smk_u, smk_m, fit_u, fit_m, bud_u, bud_m)
  {
    alcohol:      { user_value: alc_u, match_value: alc_m, aligned: alc_u == alc_m },
    smoking:      { user_value: smk_u, match_value: smk_m, aligned: smk_u == smk_m },
    fitness:      { user_value: fit_u, match_value: fit_m, aligned: fit_u == fit_m },
    budget_level: { user_value: bud_u, match_value: bud_m, aligned: ({"$"=>1,"$$"=>2,"$$$"=>3,"$$$$"=>4}[bud_u].to_i - {"$"=>1,"$$"=>2,"$$$"=>3,"$$$$"=>4}[bud_m].to_i).abs <= 1 }
  }
end

# Pre-built breakdowns for test-user matches
BD_ALEX_SARAH = seed_breakdown(
  u_mbti: "ENFJ", m_mbti: "INFP", label: "complementary",
  p_note: "ENFJ and INFP share intuition and feeling — one of the most naturally harmonious pairings.",
  u_goal: "serious", m_goal: "serious", align: "aligned",
  g_note: "Both are looking for a committed relationship.",
  factors: lf("sometimes","sometimes","never","never","active","sometimes","$$$","$$"), l_score: 3,
  l_note: "Strong lifestyle match with a minor fitness gap.",
  slots: 2, mins: 60, pct: 25, days: ["saturday"],
  s_note: "Limited but workable Saturday overlap.",
  interests: ["trying new restaurants", "creative pursuits", "meaningful conversation"],
  i_note: "Both value depth and authentic connection.",
  insights: ["Both are intuitive communicators who prefer depth over small talk",
             "Alex's warmth pairs beautifully with Sarah's artistic sensitivity"]
)

BD_MARCUS_ALEX = seed_breakdown(
  u_mbti: "ENTJ", m_mbti: "ENFJ", label: "complementary",
  p_note: "Two natural leaders — ENTJ's strategic mind meets ENFJ's people skills. Power duo energy.",
  u_goal: "serious", m_goal: "serious", align: "aligned",
  g_note: "Both are looking for something meaningful and long-term.",
  factors: lf("sometimes","sometimes","never","never","active","active","$$$$","$$$"), l_score: 4,
  l_note: "Excellent lifestyle match across all four factors.",
  slots: 10, mins: 300, pct: 100, days: ["saturday", "friday"],
  s_note: "Outstanding schedule alignment — every available slot overlaps.",
  interests: ["fitness", "career ambition", "fine dining", "trying new restaurants"],
  i_note: "Both are driven professionals who value staying active.",
  insights: ["Two ENxJ types will understand each other's drive for structure",
             "Both lead with decisiveness but express it differently — strategic vs empathetic"]
)

BD_ALEX_YUKI = seed_breakdown(
  u_mbti: "ENFJ", m_mbti: "ISFJ", label: "complementary",
  p_note: "ENFJ and ISFJ share a deep caring nature — both prioritize others' wellbeing.",
  u_goal: "serious", m_goal: "serious", align: "aligned",
  g_note: "Both want a committed, nurturing relationship.",
  factors: lf("sometimes","never","never","never","active","sometimes","$$$","$$"), l_score: 2,
  l_note: "Some lifestyle differences but fundamentally compatible values.",
  slots: 4, mins: 120, pct: 40, days: ["saturday", "wednesday"],
  s_note: "Good Saturday lunchtime and Wednesday evening overlap.",
  interests: ["cooking", "food exploration", "caring for others", "cozy atmospheres"],
  i_note: "Both express love through food — Alex cooks, Yuki makes legendary gyoza.",
  insights: ["The food connection is genuine — two people who show love through cooking",
             "Yuki's steady warmth balances Alex's big-picture energy perfectly"]
)

BD_ALEX_PRIYA = seed_breakdown(
  u_mbti: "ENFJ", m_mbti: "ENFP", label: "complementary",
  p_note: "ENFJ + ENFP is one of the most celebrated pairings — shared idealism and high energy.",
  u_goal: "serious", m_goal: "open_to_all", align: "partial",
  g_note: "Alex wants serious, Priya is open to all — partial alignment but room to grow.",
  factors: lf("sometimes","sometimes","never","never","active","active","$$$","$$"), l_score: 3,
  l_note: "Great lifestyle match — both active non-smokers with compatible budgets.",
  slots: 3, mins: 90, pct: 33, days: ["saturday", "wednesday"],
  s_note: "Saturday mornings and Wednesday evenings overlap nicely.",
  interests: ["hiking", "outdoor activities", "intellectual conversation", "books", "new experiences"],
  i_note: "Both are curious explorers who love learning and discussing ideas.",
  insights: ["Two extroverted idealists with boundless curiosity — conversation will never run dry",
             "Priya's 52-book habit gives Alex endless dinner conversation starters"]
)

BD_LUNA_ALEX = seed_breakdown(
  u_mbti: "INFJ", m_mbti: "ENFJ", label: "complementary",
  p_note: "INFJ + ENFJ share the same cognitive functions — deep mutual understanding.",
  u_goal: "open_to_all", m_goal: "serious", align: "partial",
  g_note: "Luna is open, Alex wants serious — space to explore authentically.",
  factors: lf("sometimes","sometimes","never","never","sometimes","active","$$","$$$"), l_score: 3,
  l_note: "Compatible lifestyles — budget difference bridged by shared love of casual spots.",
  slots: 3, mins: 90, pct: 37, days: ["saturday"],
  s_note: "Saturday afternoon overlap is the sweet spot.",
  interests: ["photography", "creative expression", "cozy coffee shops", "meaningful conversation"],
  i_note: "Both see the world through a creative lens and love discovering hidden gems.",
  insights: ["Luna's introspective depth draws out Alex's warmth in a natural way",
             "Both prefer authentic connection over flashy gestures — Fuglen was the perfect fit"]
)

BD_ALEX_JAMES = seed_breakdown(
  u_mbti: "ENFJ", m_mbti: "ISTP", label: "challenging",
  p_note: "ENFJ and ISTP are on opposite ends of the spectrum — requires significant effort.",
  u_goal: "serious", m_goal: "casual", align: "misaligned",
  g_note: "Fundamental mismatch: Alex wants serious commitment, James prefers casual.",
  factors: lf("sometimes","often","never","sometimes","active","sometimes","$$$","$$"), l_score: 1,
  l_note: "Multiple lifestyle conflicts — alcohol, smoking, fitness, and budget all differ.",
  slots: 1, mins: 30, pct: 8, days: ["friday"],
  s_note: "Negligible schedule overlap — only one slot on Friday evenings.",
  interests: ["music", "trying new things"],
  i_note: "Surface-level overlap doesn't compensate for core incompatibilities.",
  insights: ["The geographic distance (Tokyo vs Osaka) adds practical friction",
             "Different social energy levels would create persistent tension"],
  breaks: ["Relationship goals fundamentally misaligned", "Lifestyle values conflict on multiple axes"]
)

BD_AISHA_ALEX = seed_breakdown(
  u_mbti: "INTJ", m_mbti: "ENFJ", label: "neutral",
  p_note: "INTJ and ENFJ bring very different energies — analytical meets empathetic. Interesting dynamic.",
  u_goal: "serious", m_goal: "serious", align: "aligned",
  g_note: "Both looking for something serious — goals align clearly.",
  factors: lf("sometimes","sometimes","never","never","active","active","$$$","$$$"), l_score: 4,
  l_note: "Perfect lifestyle alignment across all four factors.",
  slots: 4, mins: 120, pct: 50, days: ["saturday"],
  s_note: "Solid Saturday evening overlap.",
  interests: ["intellectual conversation", "career ambition", "Japanese cuisine", "cultural events"],
  i_note: "Both are intellectually driven professionals who value depth.",
  insights: ["Aisha's directness (INTJ) complements Alex's warmth (ENFJ) for efficient communication",
             "Shared $$$ budget and love of upscale dining makes venue selection easy"]
)

# Helper to build match
def create_match(initiator, receiver, status, score, summary_key, transcript_key, breakdown: {})
  match = Match.find_or_initialize_by(
    initiator_agent: initiator,
    receiver_agent: receiver
  )
  match.assign_attributes(
    status: status,
    compatibility_score: score,
    compatibility_summary: COMPATIBILITY_SUMMARIES[summary_key],
    chat_transcript: AGENT_TRANSCRIPTS[transcript_key],
    compatibility_breakdown: breakdown
  )
  match.save!
  puts "  #{initiator.user.first_name} ↔ #{receiver.user.first_name}: #{status}"
  match
end

# Helper to create transcript history for a match
# stages_data: array of [stage, transcript_key] pairs in chronological order
def create_transcript_history(match, stages_data)
  stages_data.each_with_index do |(stage, transcript_key), idx|
    mt = MatchTranscript.find_or_initialize_by(match: match, stage: stage)
    mt.update!(
      content: AGENT_TRANSCRIPTS[transcript_key],
      # Stagger timestamps so chronological order is clear
      created_at: match.created_at + (idx * 2).hours,
      updated_at: match.created_at + (idx * 2).hours
    )
  end
end

# Match 1: screening (test user initiated → Sarah)
match_screening = create_match(test_agent, agents[1], "screening", 0.0, :screening, :screening, breakdown: BD_ALEX_SARAH)

# Match 2: evaluating (Marcus → test user)
match_evaluating = create_match(agents[2], test_agent, "evaluating", 72.5, :evaluating_marcus_alex, :evaluating_marcus_alex, breakdown: BD_MARCUS_ALEX)

# Match 3: date_proposed (test user → Yuki) — Tsuta Ramen
match_proposed = create_match(test_agent, agents[3], "date_proposed", 81.0, :proposed_alex_yuki, :proposed_alex_yuki, breakdown: BD_ALEX_YUKI)

# Match 4: confirmed (test user → Priya) — Yoyogi Park, future
match_confirmed_future = create_match(test_agent, agents[5], "confirmed", 87.0, :confirmed_alex_priya, :confirmed_alex_priya, breakdown: BD_ALEX_PRIYA)

# Match 5: confirmed (Luna → test user) — Fuglen Tokyo, past
match_confirmed_past = create_match(agents[9], test_agent, "confirmed", 84.5, :confirmed_luna_alex, :confirmed_luna_alex, breakdown: BD_LUNA_ALEX)

# Match 6: declined (test user → James) — lifestyle/goal mismatch
match_declined = create_match(test_agent, agents[4], "declined", 38.0, :declined_alex_james, :declined_alex_james, breakdown: BD_ALEX_JAMES)

# Match 7: date_proposed (Aisha → test user) — Sakana-ya Uoharu, user declined
match_user_declined_date = create_match(agents[11], test_agent, "date_proposed", 76.0, :proposed_aisha_alex, :proposed_aisha_alex, breakdown: BD_AISHA_ALEX)

# Extra matches between other users (background activity)
bg_screening_1  = create_match(agents[2], agents[3],  "screening",     0.0,  :screening,    :screening)
bg_evaluating_1 = create_match(agents[5], agents[6],  "evaluating",    68.0, :evaluating,   :evaluating)
bg_confirmed    = create_match(agents[7], agents[8],  "confirmed",     91.0, :confirmed,    :confirmed)
bg_proposed     = create_match(agents[10], agents[13], "date_proposed", 79.0, :date_proposed, :date_proposed)
bg_evaluating_2 = create_match(agents[14], agents[15], "evaluating",    74.0, :evaluating,   :evaluating)
bg_declined     = create_match(agents[16], agents[17], "declined",      42.0, :declined,     :declined)
bg_screening_2  = create_match(agents[18], agents[19], "screening",     0.0,  :screening,    :screening)

# --- Transcript History (stage-by-stage agent conversation records) ---
puts "\n📜 Creating transcript history..."

# Match 1: Alex → Sarah (screening) — 1 stage
create_transcript_history(match_screening, [
  ["screening", :screening]
])

# Match 2: Marcus → Alex (evaluating) — 2 stages
create_transcript_history(match_evaluating, [
  ["screening", :screening_marcus_alex],
  ["evaluating", :evaluating_marcus_alex]
])

# Match 3: Alex → Yuki (date_proposed) — 3 stages
create_transcript_history(match_proposed, [
  ["screening", :screening_alex_yuki],
  ["evaluating", :evaluating_alex_yuki],
  ["date_proposed", :proposed_alex_yuki]
])

# Match 4: Alex → Priya (confirmed) — 4 stages
create_transcript_history(match_confirmed_future, [
  ["screening", :screening_alex_priya],
  ["evaluating", :evaluating_alex_priya],
  ["date_proposed", :proposed_alex_priya],
  ["confirmed", :confirmed_alex_priya]
])

# Match 5: Luna → Alex (confirmed) — 4 stages
create_transcript_history(match_confirmed_past, [
  ["screening", :screening_luna_alex],
  ["evaluating", :evaluating_luna_alex],
  ["date_proposed", :proposed_luna_alex],
  ["confirmed", :confirmed_luna_alex]
])

# Match 6: Alex → James (declined at screening) — 1 stage
create_transcript_history(match_declined, [
  ["declined", :declined_alex_james]
])

# Match 7: Aisha → Alex (date_proposed) — 3 stages
create_transcript_history(match_user_declined_date, [
  ["screening", :screening_aisha_alex],
  ["evaluating", :evaluating_aisha_alex],
  ["date_proposed", :proposed_aisha_alex]
])

# Background match transcript histories (generic stages)
create_transcript_history(bg_screening_1, [["screening", :screening]])
create_transcript_history(bg_evaluating_1, [["screening", :screening], ["evaluating", :evaluating]])
create_transcript_history(bg_confirmed, [["screening", :screening], ["evaluating", :evaluating], ["date_proposed", :date_proposed], ["confirmed", :confirmed]])
create_transcript_history(bg_proposed, [["screening", :screening], ["evaluating", :evaluating], ["date_proposed", :date_proposed]])
create_transcript_history(bg_evaluating_2, [["screening", :screening], ["evaluating", :evaluating]])
create_transcript_history(bg_declined, [["screening", :screening], ["declined", :declined]])
create_transcript_history(bg_screening_2, [["screening", :screening]])

# --- Date Events ---
puts "\n📅 Creating date events..."

# DateEvent for match_proposed (Alex → Yuki) — Tsuta Ramen, Sugamo
# Transcript discusses cozy ramen lunch, tier 2 fits Yuki's $$ budget
de_proposed = DateEvent.find_or_initialize_by(match: match_proposed)
de_proposed.assign_attributes(
  venue: venues[0],  # Tsuta Ramen (dinner, tier 2, Sugamo)
  scheduled_time: 3.days.from_now.change(hour: 12, min: 0),
  booking_status: "proposed"
)
de_proposed.save!
puts "  Proposed: #{de_proposed.venue.name} on #{3.days.from_now.strftime('%b %d')}"

# DateEvent for match_confirmed_future (Alex → Priya) — Yoyogi Park
# Transcript discusses outdoor walk + nearby café, tier 1 fits Priya's $$ budget
de_confirmed_future = DateEvent.find_or_initialize_by(match: match_confirmed_future)
de_confirmed_future.assign_attributes(
  venue: venues[2],  # Yoyogi Park (outdoor, tier 1, Shibuya)
  scheduled_time: 5.days.from_now.change(hour: 11, min: 0),
  booking_status: "accepted"
)
de_confirmed_future.save!
puts "  Confirmed (upcoming): #{de_confirmed_future.venue.name} on #{5.days.from_now.strftime('%b %d')}"

# DateEvent for match_confirmed_past (Luna → Alex) — Fuglen Tokyo
# Transcript discusses cozy coffee spot in Tomigaya, tier 2 fits Luna's $$ budget
de_confirmed_past = DateEvent.find_or_initialize_by(match: match_confirmed_past)
de_confirmed_past.assign_attributes(
  venue: venues[6],  # Fuglen Tokyo (coffee, tier 2, Tomigaya/Shibuya)
  scheduled_time: 10.days.ago.change(hour: 14, min: 0),
  booking_status: "accepted",
  rating_score: 4
)
de_confirmed_past.save!
puts "  Confirmed (past): #{de_confirmed_past.venue.name} on #{10.days.ago.strftime('%b %d')}"

# DateEvent for match_user_declined_date (Aisha → Alex) — Sakana-ya Uoharu
# Transcript discusses upscale Japanese dinner in Roppongi, tier 3 fits both $$$
de_user_declined = DateEvent.find_or_initialize_by(match: match_user_declined_date)
de_user_declined.assign_attributes(
  venue: venues[5],  # Sakana-ya Uoharu (dinner, tier 3, Roppongi)
  scheduled_time: 2.days.from_now.change(hour: 19, min: 0),
  booking_status: "declined"
)
de_user_declined.save!
puts "  Declined: #{de_user_declined.venue.name}"

# DateEvent for background confirmed match (agents[7] ↔ agents[8])
# Emma (Marketing Director, $$$ dinner/drinks/outdoor) ↔ Ryo (Chef, $$$$ dinner/drinks)
# Generic confirmed transcript references Sakana-ya Uoharu — tier 3 dinner fits both
bg_match = Match.find_by(initiator_agent: agents[7], receiver_agent: agents[8])
if bg_match
  de_background = DateEvent.find_or_initialize_by(match: bg_match)
  de_background.assign_attributes(
    venue: venues[5],  # Sakana-ya Uoharu (dinner, tier 3, Roppongi)
    scheduled_time: 7.days.from_now.change(hour: 19, min: 0),
    booking_status: "accepted"
  )
  de_background.save!
  puts "  Background: #{de_background.venue.name}"
end

# DateEvent for background date_proposed match (agents[10] ↔ agents[13])
# Daniel (Architect, $$$ dinner/drinks/activity) ↔ Mei (Teacher, $$ coffee/dinner/activity)
# Generic date_proposed transcript references Sakana-ya Uoharu — but Mei's $$ budget
# matches better with Gonpachi Nishi-Azabu (tier 3 may stretch) or teamLab (activity)
# Using shared "activity" preference with teamLab Borderless (tier 3)
bg_proposed_match = Match.find_by(initiator_agent: agents[10], receiver_agent: agents[13])
if bg_proposed_match
  de_bg_proposed = DateEvent.find_or_initialize_by(match: bg_proposed_match)
  de_bg_proposed.assign_attributes(
    venue: venues[4],  # teamLab Borderless (activity, tier 3, Azabudai)
    scheduled_time: 4.days.from_now.change(hour: 14, min: 0),
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
puts "   #{Match.count} matches (#{Match.where.not(compatibility_breakdown: {}).count} with breakdown)"
puts "   #{MatchTranscript.count} transcript history records"
puts "   #{DateEvent.count} date events"
puts "   #{Venue.count} venues"
puts "   #{Block.count} blocks"
puts ""
puts "   📸 To add photos: place images in db/seed_photos/"
puts "      Named 01.jpg..100.jpg or firstname_lastname.jpg"
puts "      Then run: rails db:seed"
