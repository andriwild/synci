require "json"

PACKAGE_NAME = "ch.synci.app"
APP_IDENTIFIER = "ch.synci.app"
COPYRIGHT_HOLDER = "Andri Wild"

FLUTTER_DIR = File.expand_path("..", __dir__)
RELEASE_CONFIG = "config/prod.json"

# Same Apple team and Play account as Klikkr; Admin key, cloud signing needs it
API_KEY_ID = "7AHDF9BDTX"
API_ISSUER_ID = "86b9f2f1-9ef7-4ee0-87bd-b8518e42260b"
API_KEY_PATH = ENV["APP_STORE_CONNECT_API_KEY_PATH"] ||
  File.expand_path("~/.fastlane/AuthKey_#{API_KEY_ID}.p8")
PLAY_JSON_KEY_PATH = ENV["GOOGLE_PLAY_JSON_KEY_FILE"] ||
  File.expand_path("~/.fastlane/klikkr-play.json")

PLAY_TRACKS = %w[production beta alpha internal].freeze

def app_store_connect_key
  app_store_connect_api_key(
    key_id: API_KEY_ID,
    issuer_id: API_ISSUER_ID,
    key_filepath: API_KEY_PATH,
    duration: 1200,
    in_house: false,
  )
end

def play_store_max_version_code
  codes = PLAY_TRACKS.flat_map do |track|
    google_play_track_version_codes(
      package_name: PACKAGE_NAME,
      track: track,
      json_key: PLAY_JSON_KEY_PATH,
    )
  rescue StandardError => e
    FastlaneCore::UI.message("Track '#{track}' empty: #{e.message}")
    []
  end
  ([0] + codes.compact.map(&:to_i)).max
end

def testflight_max_build_number(api_key)
  latest_testflight_build_number(
    app_identifier: APP_IDENTIFIER,
    api_key: api_key,
    initial_build_number: 0,
  ).to_i
rescue StandardError => e
  FastlaneCore::UI.message("TestFlight: #{e.message}")
  0
end

# One build number line for both stores
def next_build_number
  android_max = play_store_max_version_code
  ios_max = testflight_max_build_number(app_store_connect_key)
  next_num = [android_max, ios_max].max + 1
  FastlaneCore::UI.success(
    "Build numbers — Play: #{android_max}, TestFlight: #{ios_max} → next: #{next_num}",
  )
  next_num
end

REQUIRED_CONFIG_KEYS = %w[BACKEND_URL AUTH0_DOMAIN AUTH0_CLIENT_ID AUTH0_AUDIENCE].freeze

def verify_release_config
  path = File.join(FLUTTER_DIR, RELEASE_CONFIG)
  FastlaneCore::UI.user_error!("#{RELEASE_CONFIG} not found") unless File.exist?(path)
  config = JSON.parse(File.read(path))
  missing = REQUIRED_CONFIG_KEYS.select { |key| config[key].to_s.strip.empty? }
  unless missing.empty?
    FastlaneCore::UI.user_error!("Empty keys in #{RELEASE_CONFIG}: #{missing.join(', ')}")
  end
  FastlaneCore::UI.success("#{RELEASE_CONFIG} verified.")
end

def flutter_release_build(*args, build_number:)
  verify_release_config
  Dir.chdir(FLUTTER_DIR) do
    sh("flutter", "clean")
    sh("flutter", "pub", "get")
    sh("flutter", "build", *args, "--release",
       "--build-number=#{build_number}",
       "--dart-define-from-file=#{RELEASE_CONFIG}")
  end
end

# "1.0.0" from "version: 1.0.0+1" in pubspec.yaml
def pubspec_version_name
  line = File.readlines(File.join(FLUTTER_DIR, "pubspec.yaml"))
    .find { |l| l.start_with?("version:") }
  FastlaneCore::UI.user_error!("No version: line in pubspec.yaml") if line.nil?
  line.split(":", 2)[1].strip.split("+").first
end
