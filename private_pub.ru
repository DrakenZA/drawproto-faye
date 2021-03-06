# Run with: rackup private_pub.ru -s thin -E production --host 0.0.0.0
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "production")
run PrivatePub.faye_app
