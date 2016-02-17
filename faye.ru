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
  def faye_client
    # @faye_client ||= Faye::Client.new('https://drakenfaye.herokuapp.com/faye')
    @faye_client ||= Faye::Client.new('http://localhost:9292/faye')

  end


def connected_users
  @connected_users ||= {}
end
def connected_users_ids
  @connected_users_ids ||= {}
end


def incoming(message,callback)


if message["channel"] == "/meta/connect" && message['ext'] != nil

connected_users[message["ext"]["username"]] = message['clientId']
connected_users_ids[message["ext"]["username"]] = message['ext']['roomid']

faye_client.publish('/currentliveusers_'+message['ext']['roomid'], :command => connected_users.keys & connected_users_ids.select{|key,value| value == message['ext']['roomid']}.keys, :password => "magic")


end




 # if message["channel"] == "/meta/disconnect"
 #  connected_users.delete(message["ext"]["username"])
 #  faye_client.publish('/currentliveusers', :command => connected_users.keys, :password => "magic")
 #
 # end


if message["channel"] == '/meta/subscribe' && message['subscription'] == "/currentliveusers_"+message['ext']['roomid']
  faye_client.publish('/currentliveusers_'+message['ext']['roomid'], :command => connected_users.keys & connected_users_ids.select{|key,value| value == message['ext']['roomid']}.keys, :password => "magic")
end


 callback.call(message)







end






end





  Faye::WebSocket.load_adapter('thin')
  currentuserobject = Currentusers.new
 faye.add_extension(Authmoo.new)
 faye.add_extension(currentuserobject)

 faye.on(:disconnect) do |client_id|

   roomid = currentuserobject.connected_users_ids[currentuserobject.connected_users.key(client_id)] if currentuserobject.connected_users_ids != nil
 currentuserobject.connected_users.delete(currentuserobject.connected_users.key(client_id))
 currentuserobject.connected_users_ids.delete(currentuserobject.connected_users.key(client_id))

if roomid != nil
 currentuserobject.faye_client.publish('/currentliveusers_'+roomid, :command => currentuserobject.connected_users.keys & currentuserobject.connected_users_ids.select{|key,value| value == roomid}.keys, :password => "magic")
end



 end


run faye
