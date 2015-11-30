require "bundler/setup"
require "yaml"
require "faye"
faye = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
Faye::WebSocket.load_adapter('thin')


run faye
