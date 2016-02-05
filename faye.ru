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






class Currentusers



def connected_users
  @connected_users ||= {}
end


def incoming(message,request,callback)


if message["channel"] == "/meta/connect" && message['ext'] != nil

connected_users[message["ext"]["username"]] = "online"
faye_client.publish('/currentliveusers', :command => connected_users.keys, :password => "magic")


end




 if message["channel"] == "/meta/disconnect"
  connected_users.delete(message["ext"]["username"])
  faye_client.publish('/currentliveusers', :command => connected_users.keys, :password => "magic")

 end


if message["channel"] == '/meta/subscribe' && message['subscription'] == "/currentliveusers"
  faye_client.publish('/currentliveusers', :command => connected_users.keys, :password => "magic")
end


 callback.call(message)

end




def faye_client
  @faye_client ||= Faye::Client.new('https://drakenfaye.herokuapp.com/faye')
  # @faye_client ||= Faye::Client.new('http://localhost:9292/faye')

end

end





  Faye::WebSocket.load_adapter('thin')
 faye.add_extension(Authmoo.new)
 faye.add_extension(Currentusers.new)


run faye
