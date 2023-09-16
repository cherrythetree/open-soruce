--[[
	This consists of all related functions used for interpolation.
]]

-- Services
local RunService = game:GetService("RunService")

-- Module
local Interpolation = {}

--[[
	Linear or Lerp is a function that takes a [start], a [goal],
	and the [alpha].
	
	Returns a linearly interpolated value between [start]
	and [goal] based off the alpha.
	
	```lua
	print(Interpolation.Linear(0, 1, 0.5)) --> 0.5
	print(Interpolation.Linear(-1, 1, 0.5)) --> 0
	```
]]
function Interpolation.Linear<T>(start: T, goal: any, alpha: any): T
	return start + (goal - start) * alpha
end

Interpolation.Lerp = Interpolation.Linear

--[[
	Clock is a function that takes a [stepping_mode],
	a [tween_time], and the [start_callback].
	[start_callback] is repeatedly fired per frame
	until the time reaches that of the [tween_time].

	```lua
	local connection = Interpolation.Clock(
		"Heartbeat", --> The RunService event we're using 
		1, --> How many seconds before it ends
		function(alpha, delta_step, delta_time)
			instance.Position = Vector3.zero:Lerp(Vector3.yAxis, alpha)
		end, --> Fires per Heartbeat
		function()
			print("Done!")
		end, --> Optional, fires when 1 second has passed
		function()
			return false
		end --> Optional, ends the event if this returns true
	) --> Returns a RBXScriptConnection
	
	warn(connection.Connected)
	```
]]
function Interpolation.Clock(
	stepping_mode: "PostSimulation" | "PreSimulation" | "PreRender" | "PreAnimation" | "Heartbeat" | "RenderStepped" | "Stepped",
	tween_time: number,
	start_callback: (alpha: number, delta_step: number, delta_time: number) -> (),
	finish_callback: (() -> ())?,
	condition_callback: (() -> boolean)?
): RBXScriptConnection
	local start = time()
	local connection: RBXScriptConnection
	
	connection = RunService[stepping_mode]:Connect(function(delta_step)
		local delta_time = time() - start
		local alpha = delta_time/tween_time
		
		if delta_time < tween_time and not (condition_callback and condition_callback()) then
			task.spawn(start_callback, alpha, delta_step, delta_time)
		else
			connection:Disconnect()
			
			if alpha >= 1 then
				task.spawn(start_callback, 1, delta_step, tween_time)
			end
			
			if finish_callback then
				task.spawn(finish_callback)
			end
		end
	end)

	return connection
end

--[[
	QuadraticCurve is a function that takes 3 points
	and an [alpha].
	
	Returns a value between the three points based off the alpha.
	
	```lua
	print(Interpolation.QuadraticCurve(0, 1, 0, 0.75)) --> 0.375
	```
]]
function Interpolation.QuadraticCurve<T>(p0: T, p1: any, p2: any, alpha: any): T
	return (1 - alpha) ^ 2 * p0 + 2 * (1 - alpha) * alpha * p1 + alpha ^ 2 * p2
end

--[[
	CubicCurve is a function that takes 4 points and an [alpha].
	
	Returns a value between the four points based off the alpha.
	
	```lua
	print(Interpolation.CubicCurve(0, 1, 1, 0, 0.75)) --> 0.5625
	```
]]
function Interpolation.CubicCurve<T>(p0: T, p1: any, p2: any, p3: any, alpha: any): T
	return (1 - alpha) ^ 3 * p0 + 3 * (1 - alpha) ^ 2 * alpha * p1 + 3 * (1 - alpha) * alpha ^ 2 * p2 + alpha ^ 3 * p3
end

return table.freeze(Interpolation)
