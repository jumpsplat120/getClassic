local Object = {}

Object.__index = Object

function Object:extend()
	local mt = {}
	
	for k, v in pairs(self) do if k:find("__") then mt[k] = v end end
	
	mt.__index = function(self, key)
		local raw, retval, getter

		if key:match("^_[^_]") then
			retval = mt._access and mt[key] or nil
		else
			raw    = rawget(mt, "get_" .. key)
			getter = raw or mt[key]
			retval = function(...)
				mt._access = true
				local args = {...}
				if raw then table.insert(args, 1, self) end
				local retval = getter(unpack(args))
				mt._access = false
				return retval
			end
		end

		return retval
	end
	
	mt.__newindex = function(self, key, value)
		if key:match("^_[^_]") then
			rawset(mt._access and mt or self, key, value)
		else
			local setter = rawget(mt, "set_" .. key)
			if setter then setter(self, value) else rawset(self, key, value) end
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

	return self.__type-- .. ": " .. inspect(self)
end

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