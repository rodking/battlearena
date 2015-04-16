local socket = require "socket"
local proto = require "proto"

local fd = assert(socket.login {
	host = "127.0.0.1",
	port = 8001,
	server = "sample",
	user = "hello",
	pass = "password",
})


fd:connect("127.0.0.1", 8888)

local function request(fd, type, obj, cb)
	local data, tag = proto.request(type, obj)
	local function callback(ok, msg)
		if ok then
			return cb(proto.response(tag, msg))
		else
			print("error:", msg)
		end
	end
	fd:request(data, callback)
end

local function dispatch(fd)
	local cb, ok, blob = fd:dispatch(1)
	if cb then
		cb(ok, blob)
	end
end

request(fd, "join", { room = 1 } , function(obj)
	obj.secret = fd.secret
	local udp = socket.udp(obj)
	udp:send "Hello"
end)

for i=1,20 do
	dispatch(fd)
end
