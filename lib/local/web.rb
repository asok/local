require 'erb'
require 'json'
require 'sinatra/base'

require_relative './backend'

module Local
  class Web < Sinatra::Base
    enable :sessions

    set :root, File.expand_path(File.dirname(__FILE__) + "/../..")
    set :views, "#{root}/public"

    def json
      @json ||= JSON.parse(request.body.read, symbolize_names: true)
    end

    def symbolize_keys(h)
      Hash[h.map{ |k, v| [k.intern, v] }]
    end

    get '/' do
      erb :index
    end

    get '/translations' do
      content_type :json

      Local.backend.all.to_json
    end

    post '/translations' do
      content_type :json

      Local.backend.store_translations(json[:locale],
                                       {json[:key] => json[:value]},
                                       escape: false).to_json
    end
  end
end

if defined?(::ActionDispatch::Request::Session) &&
   !::ActionDispatch::Request::Session.respond_to?(:each)
  # mperham/sidekiq#2460
  # Rack apps can't reuse the Rails session store without
  # this monkeypatch
  class ActionDispatch::Request::Session
    def each(&block)
      hash = self.to_hash
      hash.each(&block)
    end
  end
end
