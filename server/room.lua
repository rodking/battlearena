local skynet = require "skynet"
local snax = require "snax"

local max_number = 4
local roomid
local gate
local users = {}

function accept.update(data)
	local session = string.unpack("<L", data)
	print("========>", session, data)
	for s,v in pairs(users) do
		if s~=session then
			-- forward to others in room
			gate.post.post(s, data)
		end
	end
end

function response.join(agent, secret)
	local n = 0
	for _ in pairs(users) do
		n = n + 1
	end
	if n >= max_number then
		return false	-- max number of room
	end
	agent = snax.bind(agent, "agent")
	local user = {
		agent = agent,
		key = secret,
		session = gate.req.register(skynet.self(), secret),
	}
	users[user.session] = user
	return user.session
end

function response.leave(session)
	users[session] = nil
end

function response.query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

function init(id, udpserver)
	roomid = id
	gate = snax.bind(udpserver, "udpserver")
end

function exit()
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
end

