local inspect = require("lib.inspect.main")
local Object = {}

Object.__index = Object

function Object:extend()
	local mt = {}
	
	for k, v in pairs(self) do if k:find("__") then mt[k] = v end end
	
	mt.__index = function(self, key)
		local retval, get

		if key:match("^_[^_]") then
			retval = mt._access and mt[key] or nil
		else
			get = mt["get_" .. key]
			
			if get then
				mt._access = true
				retval     = get(self)
				mt._access = false
			else
				get = mt[key]
				
				retval = function(...)
					mt._access   = true
					local retval = get(...)
					mt._access   = false
					return retval
				end
			end
		end

		return retval
	end
	
	mt.__newindex = function(self, key, value)
		if key:match("^_[^_]") then
			rawset(mt._access and mt or self, key, value)
		else
			local setter = mt["set_" .. key]
			if setter then setter(mt, value) else rawset(self, key, value) end
		end
	end
	
	mt.super = self
	setmetatable(mt, self)
	return mt
end

function Object:implement(...)
	for _, cls in pairs({...}) do for k, v in pairs(cls) do
		if self[k] == nil and type(v) == "function" then self[k] = v end
    end end
end

function Object:is(T)
	local mt = getmetatable(self)
	
	while mt do
		if mt == T then return true end
		mt = getmetatable(mt)
	end
	
	return false
end

function Object:tostring()
	assert(self.__type, "Missing  metavalue '__type'.")

	return self.__type .. ": " .. inspect(self)
end

--This fires, but doesn't trigger __index, so mt._access is never enabled. That's
--why we have tostring be different
function Object:__tostring()
	return self:tostring()
end

Object.__type = "Object"

function Object:__call(...)
	local instance = setmetatable({}, self)
	instance:new(...)
	return instance
end

-- monkeypatch
otype = type

type = function(obj)
	local retval

	if otype(obj) == "table" then
		local mt = getmetatable(obj) or {}
		retval   = mt.__type or "table"
	else
		retval = otype(obj)
	end

	return retval
end

return Object