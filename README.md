# Classic

A forked version of Classic by rxi, this is a tiny class module for Lua, that has support for getters and setters. Attempts to stay simple and provide decent performance by avoiding unnecessary over-abstraction.


## Usage

The [module](classic.lua) should be dropped in to an existing project and
required by it:

```lua
local Object = require "classic"
```

The module returns the object base class which can be extended to create any
additional classes.


### Creating a new class
```lua
local Point = Object:extend()

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end
```

### Creating a new object
```lua
local p = Point(10, 20)
```

### Extending an existing class
```lua
local Rect = Point:extend()

function Rect:new(x, y, width, height)
  Rect.super.new(self, x, y)
  self.width = width or 0
  self.height = height or 0
end
```

### Checking an object's type
```lua
local p = Point(10, 20)
print(p:is(Object)) -- true
print(p:is(Point)) -- true
print(p:is(Rect)) -- false 
```

### Using mixins
```lua
local PairPrinter = Object:extend()

function PairPrinter:printPairs()
  for k, v in pairs(self) do
    print(k, v)
  end
end


local Point = Object:extend()
Point:implement(PairPrinter)

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end


local p = Point()
p:printPairs()
```

### Creating a metamethod
```lua
function Point:__tostring()
  return self.x .. ", " .. self.y
end
```

### Using static variables
```lua
local Point = Object:extend()
Point.scale = 2

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:getScaled()
  return self.x * Point.scale, self.y * Point.scale
end
```

### Using private variables
```lua
--All instances come with a uuid inherently. This is used to
--access a locally scoped table that contains all private variables.

--ex.
--{ [abc-123] = { x = 1, y = 2 },
--  [def-456] = { x = 3, y = 6} }

--The table is only accessible in the places you "require" it, so
--it can be local to each Class, but not in main, for example. The
--uuid is NOT private, but is useless without the table, so as long
--as you're handling scope correctly there's no need to worry about
--someone using the uuid to access the table.

--../bin/instances.lua
local instances = {}

return instances

--Point file
local Object  = require("Object")
local private = require("bin.instances")

local Point = Object:extend()

function Point:new(x, y)
  private[self.uuid] = private[self.uuid] or {}
 
  private[self.uuid].x = x or 0
  private[self.uuid].y = y or 0
end

function Point:getMagnitude()
  return math.sqrt(private[self.uuid].x * private[self.uuid].x + private[self.uuid].y * private[self.uuid].y)
end

return Point
--Rect file
local Point   = require("Point")
local private = require("bin.instances")

local Rect = Point:extend()

function Rect:new(x, y, width, height)
  private[self.uuid] = private[self.uuid] or {}

  private[self.uuid].w = width or 0
  private[self.uuid].h = height or 0

  Rect.super.new(self, x, y)
end

function Rect:__tostring()
  return "width: " .. private[self.uuid].w .. "; height: " .. private[self.uuid].h .. "; x: " .. private[self.uuid].x .. "; y: " .. private[self.uuid].y 
end

return Rect

--main
local Point = require("Point")
local Rect  = require("Rect")

p = Point(4, 5)
print(p.x) --4

r = Rect(1, 2, 3, 4)
print(r) --width: 3; height: 4; x: 1; y: 2
print(r.x) --1
print(r:getMagnitude()) --2.23606797749979
```

### Creating/Using a getter
```lua
function Point:new(x, y)
  private[self] = {
    x = x or 0,
    y = y or 0
  }
end

function Point:get_x()
  --Note the usage of a private variable. __index only attempts to
  --retrieve a value if one with the name doesn't exist; in
  --otherwords if you have a regular value and a getter that
  --point to the same value, the getter function will not
  --fire.
  return math.floor(private[self].x + .5)
end

function Point:printPrivateX()
  print(private[self].x)
end

p = Point(5.6, 4.1)

print(p.x)        --6
p:printPrivateX() --6

p.x = 3 --now that a value exists, __index won't fire, and subsequently the getter won't fire.

print(p.x)        --3
p:printPrivateX() --6
```

### Creating/Using a setter
```lua
function Point:set_x(amount)
  if amount < 0 then error("x can not be negative!") else self.meta.x = amount end
end

p = Point(8, 3)

p.x = 5  -- 5
p.x = -4 -- Error!
```

## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.