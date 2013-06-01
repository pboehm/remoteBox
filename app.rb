require 'sinatra/base'
require 'pp'
require 'dropbox_sdk'

require_relative 'config'


class Entry < Struct.new(:name, :link, :modified, :is_directory)
  def is_dir_numeric
    is_directory ? 0 : 1
  end
end


class RemoteBox < Sinatra::Base

  set :root, File.dirname(__FILE__)
  set :raise_errors, false
  set :show_exceptions, false

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


  error do
    e = env['sinatra.error']
    error e.class.name, e.message
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

    entry = db_client.metadata(path)

    if entry['is_dir']
      @breadcrumbs = build_up_breadcrumbs(entry['path'])
      @entries = get_entries_from_result(entry['contents'])

      erb :list

    else
      url = db_client.media(entry['path'])["url"]
      redirect(url)
    end
  end


  get '/search' do
    db_client = @@DB_CLIENT

    query = params[:query]
    return error "No Query specified", "" unless query

    entries = db_client.search("/", query)

    @title = "Suchergebnisse: '#{ h query }'"
    @entries = get_entries_from_result(entries).reject {|e| e.is_directory }

    erb :list
  end


  def build_up_breadcrumbs(path)

    breadcrumbs = []

    parts = path.split(/\//).select { |e| e != "" }

    while not parts.empty?
      en = Entry.new(parts.last, build_entry_url(parts.join('/')))
      breadcrumbs.insert(0, en)

      parts.pop
    end

    breadcrumbs
  end


  def get_entries_from_result(result_list)

    entries = []

    result_list.each do |child|
      cp = child['path']
      cn = File.basename(cp)

      entry = Entry.new(cn,
                        build_entry_url(cp),
                        DateTime.parse(child['modified']),
                        child['is_dir'])

      entry.name += "/" if entry.is_directory

      entries << entry
    end

    entries.sort! { |first, second| second.modified <=> first.modified }

    # directories should be on top of files
    entries.sort! { |fir, sec| fir.is_dir_numeric <=> sec.is_dir_numeric }

    entries
  end


  def error(title, message)
    @title = title
    @message = message
    erb :error
  end


  def build_entry_url(path)
      "/?path=#{h path}"
  end


  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end



