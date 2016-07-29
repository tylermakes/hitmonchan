require("class")

HitTools = class(function(c, width, height, composer)
	c.width = width
	c.height = height
	c.composer = composer
end)

function HitTools:randomColor()
	return math.random()
end

function HitTools:printObject(obj, maxDepth, indentor, indentation, depth)
	if (depth == nil) then
		depth = 1
	end
	if (indentation == nil) then
		indentation = "="
	end
	if (indentor == nil) then
		indentor = "="
	end

	if (depth > maxDepth) then
		print(indentation, "MAX DEPTH EXCEEDED")
		return
	end
	
	if (type(obj) == "string") then
		print(indentation, obj)
		return
	end
	
	if (type(obj) == "number") then
		print(indentation, obj)
		return
	end
	
	if (type(obj) == "boolean") then
		print(indentation, obj)
		return
	end

	for k,v in pairs(obj) do
		print(indentation, k)
		self:printObject(v, maxDepth, indentor, indentation..indentor, depth + 1)
	end

end

function HitTools:makeEventDispatcher(obj)
	obj.events = {}

	function obj:addEventListener(type, object)
		if (not self.events[type]) then
			self.events[type] = {}
		end
		self.events[type][#self.events[type] + 1] = object
	end

	function obj:dispatchEvent(data)
		if (self.events[data.name]) then
			for i=1, #self.events[data.name] do
				self.events[data.name][i][data.name](self.events[data.name][i], data)
			end
		end
	end
end