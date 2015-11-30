require 'faye'
faye = Faye::RackAdapter.new(:mount => '/fayenormal', :timeout => 45)
Faye::WebSocket.load_adapter('thin')


run faye
