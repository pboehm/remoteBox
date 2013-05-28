require 'sinatra/base'
require 'pp'
require 'dropbox_sdk'

require_relative 'config'

Entry = Struct.new(:name, :link)

class RemoteBox < Sinatra::Base

  set :root, File.dirname(__FILE__)

  def initialize
    super

    @@DB_CLIENT = setup_db_client
  end


  def setup_db_client
    unless APP_KEY && APP_SECRET && ACCESS_TOKEN && APP_SECRET
      raise AttributeError,
        "You have to provide APP_KEY, APP_SECRET, ACCESS_TOKEN, ACCESS_SECRET"
    end

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
      session.delete(:authorized_db_session)  # An auth error means the db_session is probably bad
      return html_page "Dropbox auth error", "<p>#{h e}</p>"
    rescue DropboxError => e
      if e.http_response.code == '404'
        return html_page "Path not found: #{h path}", ""
      else
        return html_page "Dropbox API error", "<pre>#{h e.http_response}</pre>"
      end
    end

    if entry['is_dir']
      render_folder(db_client, entry)
    else
      render_file(db_client, entry)
    end
  end


  def render_folder(db_client, entry)

    @directories = []
    @files = []

    entry['contents'].each do |child|

      cp = child['path']
      cn = File.basename(cp)
      link = "/?path=#{h cp}"

      entry = Entry.new(cn, link)

      if (child['is_dir'])
        @directories << entry
      else
        @files << entry
      end
    end

    erb :list
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



