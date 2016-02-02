require 'bundler'
ENV['RACK_ENV'] = 'test'
Bundler.require(:default, 'test')
Bundler.require(:default, 'development')

require 'rack/test'
require 'rspec'

require_relative "../lib/local"

module RSpecMixin
  include Rack::Test::Methods

  def app
    Local::Web
  end

  def get_json(path, data = {})
    get path, data, "Content-Type" => "application/json"
  end

  def post_json(path, data)
    post path, data.to_json, "Content-Type" => "application/json"
  end

  def put_json(path, data)
    put path, data.to_json, "Content-Type" => "application/json"
  end

  def delete_json(path)
    delete path, {}, "Content-Type" => "application/json"
  end
end

RSpec.configure do |c|
  c.include RSpecMixin

  c.before(:suite) do
    Local.backend = Local::Simple::Backend.new
  end

  c.before(:each) do
    Local.backend.instance_variable_set(:@translations, nil)
  end
end
