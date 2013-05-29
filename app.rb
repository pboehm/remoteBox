require 'sinatra/base'
require 'pp'
require 'dropbox_sdk'

require_relative 'config'

Entry = Struct.new(:name, :link, :modified, :is_directory)

class RemoteBox < Sinatra::Base

  set :root, File.dirname(__FILE__)

  use Rack::Auth::Basic, "remoteBox: Login required" do |username, password|
    username == AUTH_USERNAME && password == AUTH_PASSWORD
  end

  def initialize
    super

    unless APP_KEY && APP_SECRET && ACCESS_TOKEN && APP_SECRET &&
            AUTH_USERNAME && AUTH_PASSWORD
      raise ArgumentError,
        "You have to provide all documented settings as ENV-variables"
    end

    @@DB_CLIENT = setup_db_client
  end

  before do
    @PAGE_TITLE = PAGE_TITLE
  end

  def setup_db_client
    session = DropboxSession.new(APP_KEY, APP_SECRET)
    session.set_access_token(ACCESS_TOKEN, ACCESS_SECRET);

    DropboxClient.new(session, ACCESS_TYPE)
  end


  get '/' do
    db_client = @@DB_CLIENT

    # Call DropboxClient.metadata
    path = params[:path] || '/'
    begin
      entry = db_client.metadata(path)
    rescue DropboxAuthError => e
      return error "Dropbox auth error", "<p>#{h e}</p>"
    rescue DropboxError => e
      if e.http_response.code == '404'
        return error "Path not found: #{h path}", ""
      else
        return error "Dropbox API error", "<pre>#{h e.http_response}</pre>"
      end
    end

    if entry['is_dir']
      render_folder(db_client, entry)
    else
      render_file(db_client, entry)
    end
  end


  def render_folder(db_client, entry)

    @breadcrumbs = []
    @entries     = []

    parts = entry['path'].split(/\//).select { |e| e != "" }

    while not parts.empty?
      en = Entry.new(parts.last, build_entry_url(parts.join('/')))
      @breadcrumbs.insert(0, en)

      parts.pop
    end

    entry['contents'].each do |child|
      cp = child['path']
      cn = File.basename(cp)

      entry = Entry.new(cn, build_entry_url(cp),
                        DateTime.parse(child['modified']),
                        child['is_dir'])

      entry.name += "/" if entry.is_directory

      @entries << entry
    end

    @entries.sort! { |first, second| second.modified <=> first.modified }

    erb :list
  end


  def error(title, message)
    @title = title
    @message = message
    erb :error
  end


  def build_entry_url(path)
      "/?path=#{h path}"
  end


  def render_file(db_client, entry)
    url = db_client.media(entry['path'])["url"]
    redirect(url)
  end


  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end



