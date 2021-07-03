--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--
local Object  = {}

local function uuid()
    local template ="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

Object.__index = Object

function Object:extend()
	local cls = {}
	
	for k, v in pairs(self) do
		if k:find("__") then cls[k] = v end
	end
	
	cls.__index = function(self, key)
		local getter = cls["get_" .. key]
		if getter then return getter(self) else return cls[key] end
	end
	
	cls.__newindex = function(self, key, value)
		local setter = cls["set_" .. key]
		if setter then setter(self, value) else rawset(self, key, value) end
	end
	
	cls.super = self
	setmetatable(cls, self)
	return cls
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
	return getmetatable(self).__type
end

function Object:__call(...)
	local ins = setmetatable({ uuid = uuid() }, self)
	ins:new(...)
	return ins
end

--Object.__type = "object"

return Object