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

function Object:tostring()
	return getmetatable(self).__type
end

function Object:implement(...)
	for _, class in pairs({...}) do for k, v in pairs(class) do
		if type(v) == "function" and self[k] == nil then self[k] = v end
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

Object.__type = "object"

return Object