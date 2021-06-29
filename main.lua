local inspect = require("lib.inspect.main")

local Object = {}

local function getLowestMetatable(tbl)
	local lowest = getmetatable(tbl)

	if lowest then
		while true do
			local lower = getmetatable(lowest)
			if lower then lowest = lower else break end
		end
	end

	return lowest
end

function Object:new()
end

function Object:super(...)
	local mt, ins
	
	mt  = getmetatable(self)
	ins = setmetatable(self, getmetatable(mt))
	ins:new(...)
	setmetatable(self, mt)
end

function Object:extend()
	local new = {}

	for k, v in pairs(self) do
		if k:match("^__") then new[k] = v end
	end

	return setmetatable(new, self)
end

function Object:__call(...)
	local ins = setmetatable({}, self)
	ins:new(...)
	return ins
end

function Object:__index(k)
	local mt, lowest, retval, get

	mt = getmetatable(self)

	if k:match("^_[^_]") then
		lowest = getLowestMetatable(self)
		retval = lowest._access and rawget(self, k) or nil
	else
		get = mt[(k:match("^get_") and "" or "get_") .. k]
		if get then
			lowest         = getLowestMetatable(self)
			lowest._access = true
			retval         = get(self)
			lowest._access = false
		end

		get = mt[k]
		if get then
			retval = function(...)
				local lowest   = getLowestMetatable(self)
				lowest._access = true
				local retval   = get(...)
				lowest._access = false
				return retval
			end
		end
	end

	return retval
end

function Object:__newindex(k, v)
	local has_access, lowest, setter
	
	lowest     = getLowestMetatable(self)
	has_access = lowest._access

	mt = getmetatable(self)

	if k:match("^_[^_]") then
		assert(has_access, "You cannot set a private variable outside of an internal scope.")
		rawset(self, k, v)
	else
		setter = mt[(k:match("^set_") and "" or "set_") .. k]
		if setter then
			local lowest   = getLowestMetatable(self)
			lowest._access = true
			setter(self, v)
			lowest._access = false
		else
			rawset(self, k, v)
		end
	end
end

function Object:__tostring()
	return self:tostring()
end

function Object:implement()
end

function Object:is()
end

--Object.__type = "object"

--
--function Object:__index(key)
--	local retval, get, mt
--	print("__index", key)
--	mt = getmetatable(self)
--
--	if key:match("^_[^_]") then
--		local lowest   = lowestMT(self)
--		print(inspect(mt), key)
--		print("Access?", lowest._access)
--		retval = lowest._access and mt[key] or nil
--		print("Fired?")
--	else
--		get = mt["get_" .. key]
--		if get then
--			local lowest   = lowestMT(self)
--			lowest._access = true
--			retval         = get(self)
--			lowest._access = false
--		end
--
--		get = mt[key]
--		if get then
--			retval = function(...)
--				local lowest   = lowestMT(self)
--				lowest._access = true
--				local retval   = get(...)
--				lowest._access = false
--				return retval
--			end
--		end
--	end
--
--	return retval or nil
--end
--
--function Object:__newindex(key, value)
--	local mt, setter
--	
--	mt = getmetatable(self)
--
--	if key:match("^_[^_]") then
--		rawset(mt._access and mt or self, key, value)
--	else
--		setter = mt["set_" .. key]
--		if setter then setter(mt, value) else rawset(self, key, value) end
--	end
--end
--
--function Object:implement(...)
--	for _, cls in pairs({...}) do for k, v in pairs(cls) do
--		if self[k] == nil and type(v) == "function" then self[k] = v end
--    end end
--end
--
--function Object:is(T)
--	local mt = getmetatable(self)
--	
--	while mt do
--		if mt == T then return true end
--		mt = getmetatable(mt)
--	end
--	
--	return false
--end
--
--function Object:tostring()
--	assert(self.__type, "Missing  metavalue '__type'.")
--
--	return self.__type .. ": " .. inspect(self)
--end
--
----This fires, but doesn't trigger __index, so mt._access is never enabled. That's
----why we have tostring be different
--function Object:__tostring()
--	return self:tostring()
--end
--
----Object.__type = "Object"
--
--function Object:__call(...)
--	local mt, instance
--	
--	mt = getmetatable(self)
--	
--	for k, v in pairs(self) do mt[k] = v end
--	
--	instance = setmetatable({}, mt)
--	instance:new(...)
--	return instance
--end

return Object