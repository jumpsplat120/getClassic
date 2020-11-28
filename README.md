# Classic

A forked version of Classic by rxi, this is a tiny class module for Lua, that has support for getters and setters. Attempts to stay simple and provide decent performance by avoiding unnecessary over-abstraction.


## Usage

The [module](classic.lua) should be dropped in to an existing project and
required by it:

```lua
Object = require "classic"
```

The module returns the object base class which can be extended to create any
additional classes.


### Creating a new class
```lua
Point = Object:extend()

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
Rect = Point:extend()

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
PairPrinter = Object:extend()

function PairPrinter:printPairs()
  for k, v in pairs(self) do
    print(k, v)
  end
end


Point = Object:extend()
Point:implement(PairPrinter)

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end


local p = Point()
p:printPairs()
```

### Using static variables
```lua
Point = Object:extend()
Point.scale = 2

function Point:new(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:getScaled()
  return self.x * Point.scale, self.y * Point.scale
end
```

### Creating a metamethod
```lua
function Point:__tostring()
  return self.x .. ", " .. self.y
end
```

### Creating/Using a getter
```lua
function Point:get_x()
  --Note the usage of rawget. If you access the value of a variable within the getter 
  --function of itself, you will end up with a recursive loop.
  return math.floor(rawget(self, "x") + .5)
end

p = Point(5.6, 4.1)

print(p.x) --6
```

### Creating/Using a setter
```lua
function Point:set_x(amount)
  --Note the usage of rawset. If you assign the value of a variable within the setter 
  --function of itself, you will end up with a recursive loop.
  if amount < 0 then error("x can not be negative!") else rawset(self, "x", amount) end
end

p = Point(8, 3)

p.x = 5  -- 5
p.x = -4 -- Error!
```

## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

