require "bundler/setup"
require "yaml"
require "faye"
faye = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)

class Authmoo

def incoming(message, request, callback)
  if message["channel"] != "/^\/meta\//"

  if message["data"] != nil && message["data"]["password"] != 'magic'

    return message['error'] = "warning"


  end
  callback.call(message)

  end
end

  def outgoing(message,callback)

    if message["data"] != nil && message['data']["password"] != nil
      message['data']["password"] = ''
    end
     callback.call(message)
   end


end

  Faye::WebSocket.load_adapter('thin')
 faye.add_extension(Authmoo.new)

run faye
