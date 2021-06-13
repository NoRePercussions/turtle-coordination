rednet.open("right")
pos = {}
l0 = vector.new(gps.locate())
if not turtle.forward() then error("couldnt move") end
l1 = vector.new(gps.locate())
if not turtle.back() then error("couldnt move") end
heading = l1-l0
facing = ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
id = rednet.lookup("position")

--optimize
--double moves

--[[i=0
while true do
	if not fs.exists("log"..i..".txt") then
		file=fs.open("log"..i..".txt", "w")
		break
	end
	i=i+1
end
print("log #"..i)]]

function main ()
	facing = getfacing()
	x0,y0,z0 = gps.locate()
	while true do
		target = {y=y0}
		x,y,z = gps.locate
		pos = {x=x,y=y,z=z}
		target.x = math.random(-10,10) + x0
		target.z = math.random(-10,10) + z0
		log("new target!")
		repeat
			log("target is ("..target.x..", "..target.y..", "..target.z..")")
			log("pos is ("..pos.x..", "..pos.y..", "..pos.z..")")
			domove(target)
		until target.x==pos.x and target.z==pos.z
	end
end

function moveto (target)
	x,y,z = gps.locate
	pos = {x=x,y=y,z=z}
	repeat
		log("target is ("..target.x..", "..target.y..", "..target.z..")")
		log("pos is ("..pos.x..", "..pos.y..", "..pos.z..")")
		domove(target)
	until target.x==pos.x and target.z==pos.z
end

function domove (target)
	rednet.send(id, "request", "position")
	_, positions = rednet.receive("position")

	f = findbestmove(pos, facing, target, positions)

	log("f "..f)
	log("facing "..facing)
	for i=1, (f - facing)%4 do
		turtle.turnRight()
	end
	facing = f
	dx = (f - 2) * (f % 2)
	dz = (f - 3) * ((f + 1) % 2)

	if turtle.forward() then
		pos.x = pos.x + dx
		pos.z = pos.z + dz
	end

	rednet.send(id, pos, "position")
end

function findbestmove (pos, facing, target, positions)
	minscore = 1000000
	minf = 0
	for f=1,4 do
		dx = (f - 2) * (f % 2)
		dz = (f - 3) * ((f + 1) % 2)

		score = 0

		for tid,turtle in pairs(positions) do
			--log("distance for "..tid)
			if tid == os.getComputerID() then break end
			if turtle.y ~= pos.y then break end

			temp = math.abs(turtle.x - dx - pos.x)
			temp = temp + math.abs(turtle.z - dz - pos.z)
			if temp < 10 then
				score = score + 1/(temp * temp)
			end
		end

		if f == facing then score = score - .1 end
		if (f+2)%4 == facing then score = score + .1 end

		progress = math.abs(pos.x - target.x) - math.abs(pos.x + dx - target.x)
		progress = progress + math.abs(pos.z - target.z) - math.abs(pos.z + dz - target.z)
		score = score - progress

		if score < minscore or minf == 0 then
			minscore = score
			minf = f
		end

		if score == minscore and math.random() > .5 then
			minf = f
		end
		log("score "..f.." = "..score.."  progress = "..progress)
	end
	log(minf)
	return minf
end

function initialize ()
	l0 = vector.new(gps.locate())
	print(l0)
	if not turtle.forward() then error("couldnt move") end
	l1 = vector.new(gps.locate())
	if not turtle.back() then error("couldnt move") end
	heading = l1-l0
	h = ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
	log("heading is "..h)
	return h
end

function log (x)
	print(x)
	--file.writeLine(x)
	--file.flush()
end
