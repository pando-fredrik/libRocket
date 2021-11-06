print("Loaded rotor3d")
local radius = 6.5

local coordinateSystem = {}

local imgs = { 
         { 
           ["vector"] = Vector3D.Create(-radius, 0, 0),
           ["src"] = "posters/1.jpg", 
           ["mname"] = "The Broken",
           ["details"] = "Gina McVey is a radiologist who is enjoying dinner one evening with her family and her boyfriend Stefan when a mirror shatters for no apparent reason. After a few moments, no one thinks much of it, but the next day Gina is leaving work and she sees something even more troubling—a woman who looks just like her, driving a car identical to her own." }, 
         { ["vector"] = Vector3D.Create( 0, 0, radius),
            ["src"] = "posters/2.jpg", 
            ["mname"] = "The Dark Knight",
            ["details"] = "A Gotham City mob bank is robbed by a group of thugs wearing clown masks. While doing the job, they double cross and kill each other one by one. The remaining thug reveals himself to be the Joker and leaves with the money. District attorney Harvey Dent leads a campaign against the organized crime in the city, to the applause of its citizens. Through Gordon, he requests to collaborate with Batman, and lends Gordon a petitioned search warrant for five banks with suspected mob ties. Wayne Enterprises cancels its deals with Chinese accountant Lau as CEO Lucius Fox questions Lau’s legality. Bruce Wayne intrudes on Dent’s date with Rachel Dawes and offers to support the DA through a fundraiser." }, 
         {  ["vector"] = Vector3D.Create( radius, 0, 0),
            ["src"] = "posters/3.jpg", 
            ["mname"] = "Man of Steel",
            ["details"] = "The planet Krypton faces imminent destruction due to its unstable core, the result of depleting Krypton's natural resources. Krypton's military commander, General Zod, and his followers initiate a coup d'état and depose the ruling council. Scientist Jor-El and his wife Lara briefly celebrate the birth of their son, Kal-El, the first naturally born Kryptonian child in centuries. Aware of the cause for their civilization's ruin, Jor-El infuses Kal-El cells with a genetic codex of the entire Kryptonian race, and puts Kal-El on a spacecraft to Earth. Zod kills Jor-El but fails to retrieve the codex. He and his followers are exiled to the Phantom Zone for treason. After Krypton explodes, they are indirectly freed and become the sole survivors of Krypton, aside from Kal-El." },
         {  ["vector"] = Vector3D.Create( 0, 0, -radius),
            ["src"] = "posters/4.jpg", 
            ["mname"] = "The Silence of The Lambs",
            ["details"] = "Clarice Starling is pulled from her training at the FBI Academy at Quantico, Virginia by Jack Crawford of the Bureau's Behavioral Science Unit. He assigns her to interview Hannibal Lecter, a former psychiatrist and incarcerated cannibalistic serial killer, whose insight might prove useful in the pursuit of a serial killer nicknamed \"Buffalo Bill\", who skins his female victims' corpses." },
         {  ["vector"] = Vector3D.Create( 0, -radius, 0),
            ["src"] = "posters/5.jpg", 
            ["mname"] = "The Grey",
            ["details"] = "John Ottway works in Alaska, killing wolves that threaten an oil drilling team. On his last day on the job, he shoots one. That evening, Ottway writes a letter \"without purpose\" to his wife, Ana (Anne Openshaw), explaining his plans to commit suicide. He hears a distant wolf howl and doesn't follow through." }, 
         {  ["vector"] = Vector3D.Create( 0, radius, 0),
            ["src"] = "posters/6.jpg", 
            ["mname"] = "Maleficent",
            ["details"] = "A beautiful, pure-hearted young woman, Maleficent has an idyllic life growing up in a peaceable forest kingdom, until one day when an invading army threatens the harmony of the land. Maleficent rises to be the land's fiercest protector, but she ultimately suffers a ruthless betrayal - an act that begins to turn her pure heart to stone. Bent on revenge, Maleficent faces a battle with the invading king's successor and, as a result, places a curse upon his newborn infant Aurora." },
--[[         { ["src"] = "posters/7.jpg", 
            ["mname"] = "Shutter Island",
            ["details"] = "nada" },
         { ["src"] = "posters/8.jpg", 
            ["mname"] = "Shutter Island",
            ["details"] = "nada" } ]]--
}

-- "width: 350px; height: 525px; top: 127px; left: 67px; 



SetupNavigation = function (thisPage) 
    local fpsbutton = NavigableElement.Create(thisPage:ResolveElement("fpsbutton"))

    fpsbutton:SetOnFocus( function (self)
        local el = self._element
        el.style["background-color"] = "rgb(255, 20, 150)"
    end)

    fpsbutton:SetOnLostFocus( function (self)
        local el = self._element
        el.style["background-color"] = "rgb(150, 150, 150)"
    end)

    fpsbutton:SetKeyHandler( function (key)
     
    end)

    NavigableElement.SetDefaultElement(fpsbutton) 
end


ToRadian = function ( degree )
	return math.floor((degree * (math.pi/180))*1000)/1000
end

ToDegree = function (radian) 
    return math.floor((radian * (180 / math.pi))*1000)/1000
end

local CameraQ = Quaternion.CreateFromEuler(0,0,0)

local countdown = 0

math.randomseed( os.time() )

local oneDegree = ToRadian(1)
local rndTarget = nil
local mostShallow = nil

RandomizeTargetPoints = function () 
    rndTarget = mostShallow
    local unitTurn = 90
    local targetX = ((math.floor(math.random() * 3) + 1 + 2) * unitTurn)
    local targetY = ((math.floor(math.random() * 3) + 1 + 2) * unitTurn) 
    local targetZ = ((math.floor(math.random() * 3) + 1 + 2) * unitTurn) 
    print("Creating new vector")
    CameraQ = CameraQ:Mult(Quaternion.CreateFromEuler(ToRadian(targetX),ToRadian(targetY),ToRadian(targetZ)))
end

local cX = 0
local cY = 20
local cZ = -10

local cTargetX = 0
local cTargetY = -0.1
local cTargetZ = -10

local acceptKey = true

local vortexMode = false
local time = 0
local rndz = 0
local oldQ = CameraQ:Clone()
local transistionTime = 0.0
local transistionSpeed = 0.03

Proximity = function (value, otherValue, tolerance) 
   if value < (otherValue - tolerance) then
        return tolerance
    elseif value > (otherValue + tolerance) then
        return -tolerance
    end 
    return 0
end

RotateStack = function () 
	local stepUnit = 5/10
    local xDone = false
    local yDone = false
    local zDone = false


    cX = cX + Proximity(cX, cTargetX, stepUnit)
    cY = cY + Proximity(cY, cTargetY, stepUnit)
    cZ = cZ + Proximity(cZ, cTargetZ, stepUnit)

    local cameraVector = Vector3D.Create(cX, cY, cZ)

    local degree = 9 -- (9 * (math.pi/180))

	--RandomizeTargetPoints()

    local shallowZ = 1000

    if vortexMode then 
        time = time + 2
    else 
        time = 0
    end
    for i=1, #imgs do
        local vector = coordinateSystem[i];
 
        if transistionTime < 1.0 then
            transistionTime = transistionTime + transistionSpeed
        end
        if transistionTime > 1.0 then
            if rndz > 0 then
                rndz = rndz - 1
                oldQ = CameraQ:Clone()
                RandomizeTargetPoints()                    
                transistionTime = 0.0
            else
                transistionTime = 1.0
            end
        end

        local tQ = oldQ:Slerp(CameraQ, transistionTime)
        local vector2D = tQ:RotateVector(vector):Project(cameraVector):Rotate(ToRadian(time%360)):Translate(1280/2,720/2)
        
        local currentCover = thisPage:ResolveElement("cover" .. i)

        if shallowZ >= vector2D.depth then
            shallowZ = vector2D.depth
            mostShallow = currentCover
        end

        if vector2D.depth >= 0 and vector2D.depth <= 12.5 then
            if transistionTime >= 1.0 then
                currentCover.style["border-width"] = "0px"
                currentCover.style["margin"] = "2px"
            end
            currentCover.style["display"] = "block"
            currentCover.style["top"] = ((vector2D.y + (vector2D.depth * 10))-(450/2)) .. "px"
            currentCover.style["left"] = ((vector2D.x + (vector2D.depth * 10))-(350/2)) .. "px"
            currentCover.style["width"] = math.max((400 - (vector2D.depth*30)), 25) .. "px"
            currentCover.style["height"] = math.max((400 - (vector2D.depth*30)) * 1.5, 25*1.5) .. "px"
            currentCover.style["z-index"] = tostring(100 - math.floor(vector2D.depth*10))
        else
            currentCover.style["display"] = "none"
        end
    end
    if (mostShallow ~= nil and transistionTime >= 1.0) then
        thisPage:ResolveElement("mtitle").inner_rml = "This one will suite you better!"
        rndTarget = nil
        acceptKey = true
        mostShallow.style["border-width"] = "2px"
        mostShallow.style["margin"] = "0px"
        thisPage:ResolveElement("mtitle").inner_rml = mostShallow:GetAttribute("mname")
        thisPage:ResolveElement("details").inner_rml = mostShallow:GetAttribute("details")
        thisPage:ResolveElement("synWrapper").style["display"] = "block"
    end
end
PageLoadedCallback = function (document)    
    -- Instance the document wrapper for the given document
    thisPage = Utils.Create(document)

    local holder = thisPage:ResolveElement("rotorscope")

    if holder then
        for i = 1, #imgs do
            local img = document:CreateElement("img");
            
            coordinateSystem[i] = imgs[i].vector

            img:SetAttribute("id", "cover"..i)
        
            img:SetAttribute("src", imgs[i].src)
            img:SetAttribute("mname", imgs[i].mname) 
            img:SetAttribute("details", imgs[i].details) 
            img.style["display"] = "none"
            img.style["border-color"] = "rgb(255, 20, 150);"
            print("Created cover " .. i);
            holder:AppendChild(img)
            print("Has holder")
        end
    end
    -- Setup page navigation using the NavigableElement stack
    SetupNavigation(thisPage)

    -- Install the document specific keyhandler
    thisPage:SetKeyHandler(function (key, state)
    	local unitTurn = 90.0
        local navTime = 0.02
        -- Only evaluate if the key is pressed down
        if acceptKey and state == "down" or state == "repeat" then
            transistionSpeed = navTime
       -- print(q:ToString())
        --local q = qx:Mult(qy):Mult(qz)
            --print(q:ToString())
            --print(qz:ToString())

            thisPage:ResolveElement("synWrapper").style["display"] = "none"

            -- Process the key event using the NavigableElement stack
            acceptKey = false

            if key == "right" then
                transistionTime = 0.0 
                oldQ = CameraQ:Clone()
                local newQ = Quaternion.Create(ToRadian(unitTurn), Vector3D.Create(0, 1,0))
                CameraQ = newQ:Mult(CameraQ)
           	elseif key == "left" then
                transistionTime = 0.0 

                oldQ = CameraQ:Clone()
               local newQ = Quaternion.Create(ToRadian(unitTurn), Vector3D.Create(0, -1,0))
               CameraQ = newQ:Mult(CameraQ)

           	elseif key == "up" then
                transistionTime = 0.0 
                oldQ = CameraQ:Clone()
                local newQ = Quaternion.Create(ToRadian(unitTurn), Vector3D.Create(-1, 0,0))
                CameraQ = newQ:Mult(CameraQ)
           	elseif key == "down" then
                transistionTime = 0.0 
                oldQ = CameraQ:Clone()
                local newQ = Quaternion.Create(ToRadian(unitTurn), Vector3D.Create(1, 0,0))
                 CameraQ = newQ:Mult(CameraQ)
            elseif key == "ok" then
                cTargetZ = -18
                cTargetX = -1
                transistionTime = 1.0
           	elseif key == "4" then
                transistionTime = 0.0 
                transistionSpeed = 0.005
                oldQ = CameraQ:Clone()
                RandomizeTargetPoints()
                thisPage:ResolveElement("mtitle").inner_rml = "Hmm... Looking for a suitable movie"
                rndz = math.floor(math.random(3,10))
                rndTarget = mostShallow
            elseif key == "1" then
                thisPage:ResolveElement("mtitle").inner_rml = "Vortex mode!"
                vortexMode = true
            elseif key == "2" then
                thisPage:ResolveElement("mtitle").inner_rml = "Browse mode!"
                vortexMode = false
           	elseif key == "back" then
                transistionSpeed = 0.005
                transistionTime = 0.0 
                thisPage:ResolveElement("mtitle").inner_rml = "Resetting orientation!"     
                oldQ = CameraQ:Clone()
                CameraQ = Quaternion.CreateFromEuler(ToRadian(0),ToRadian(0),ToRadian(0))
           	else
	            NavigableElement.ProcessKey(key)
           	end
        end
    end)

    -- Active document keyhandler
    thisPage:ActivateKeyHandler()
    
--    RandomizeTargetPoints()
    local zenTimer = sys.new_timer(33,"animator") -- Aim for 30 fps   
    animator = function ()                                                        
        zenTimer:stop();                                                                      
        RotateStack()                                                                                                     
        zenTimer = sys.new_timer(30, "animator")        
    end    
end

OnPageLoaded = function (document)
    local status, err = pcall(PageLoadedCallback,document)
    if status ~= true then
        print("Error: " .. err)
        print(debug.traceback())
    end
end