--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

local Object = {}

Object.__index = Object

function Object:extend()
	local mt = {}
	
	for k, v in pairs(self) do if k:find("__") then mt[k] = v end end
	
	mt.__index = function(self, key)
		local raw, retval, getter

		if key:match("^_") then
			retval = mt._access and mt[key] or nil
		else
			raw    = rawget(mt, "get_" .. key)
			getter = raw and getter(self) or mt[key]
			retval = function(...)
				mt._access = true
				local retval = getter(...)
				mt._access = false
				return retval
			end
		end

		return retval
	end
	
	mt.__newindex = function(self, key, value)
		if key:match("^_") then
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

function Object:__tostring()
	return "Object"
end

function Object:__call(...)
	local instance = setmetatable({}, self)
	instance:new(...)
	return instance
end

return Object