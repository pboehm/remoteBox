# This File holds some config variables which should be set via ENV variable
# with the corresponding name
PAGE_TITLE = ENV.fetch("PAGE_TITLE") { "remoteBox" }

ACCESS_TYPE = :app_folder

APP_KEY    = ENV["APP_KEY"]
APP_SECRET = ENV["APP_SECRET"]

ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
ACCESS_SECRET = ENV["ACCESS_SECRET"]

# These settings will be used for Digest Auth
AUTH_USERNAME = ENV["AUTH_USERNAME"]
AUTH_PASSWORD = ENV["AUTH_PASSWORD"]
