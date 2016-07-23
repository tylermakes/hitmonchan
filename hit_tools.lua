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