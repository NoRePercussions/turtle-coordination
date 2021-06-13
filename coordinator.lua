rednet.open("right")
rednet.host("position", "main")

function coordinator ()
	positions = {}
	while true do
		s, m = waitForNewPosition()
		if updatePosition(positions, s, m) then
			print("sending positions")
			rednet.send(s, positions, "position")
			print("positions sent")
		end
	end
end

function waitForNewPosition ()
	sender, message = rednet.receive("position")
	print("message from "..sender)
	return sender, message
end

function updatePosition (positions, sender, message)
	if type(message)=="table" then
		positions[sender] = message
		print("pos of "..s.." is ("..message.x..", "..message.z..")")
		return false
	elseif message=="remove" then
		positions[sender] = nil
		return false
	elseif message=="request" then
		return true
	end
end
