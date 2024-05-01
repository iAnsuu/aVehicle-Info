script_name('aVehicle-Info')
script_author("iAnsu") -- Nishikinov
script_version("1.0")
local sampev = require 'lib.samp.events'
local keys = require 'lib.vkeys'

local activation = true
local stringDialog = " "
local vehInfo = {
	vehid = 0,
	motor = "?",
	pneu = "?",
	gas = "?"
}

function isKeyCheckAvailable()
	return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end

function convertStringToVars()
	--[[local pattern = "(%w+)%s+%((%d+)/%d+%)"
	-- Iterar sobre as correspondências na string e atualizar vehInfo
	for name, value1 in string.gmatch(stringDialog, pattern) do
		local inicio, fim = string.find("Combust", name, 1, true)
		print(inicio, fim)
		if name == "Motor" then
			vehInfo.motor = tonumber(value1) == 0 and "Nao" or "Sim"
		elseif name == "Pneus" then
			vehInfo.pneu = value1
		elseif inicio or fim then
			vehInfo.gas = value1
		end
	end]]
	vehInfo.motor = tonumber(string.match(stringDialog, "Motor %((%d+)/%d+%)")) == 0 and "Nao" or "Sim"
	vehInfo.pneu = tonumber(string.match(stringDialog, "Pneus %((%d+)/%d+%)"))
	vehInfo.gas = tonumber(string.match(stringDialog, "Combustível %((%d+)/%d+%)"))
end

function main()
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage("{FFA500}[Moon]{ffffff} Script {FFA500}"..thisScript().name.."{ffffff} foi carregado. by Ansu",0x33FFA500)
	sampRegisterChatCommand("vehinfo", function()
		activation = not activation
		local textMSG = "veh-info on"
		if not activation then
			textMSG = "veh-info off"
		end
		printStringNow(textMSG, 500)
	end)
	font = renderCreateFont("Corbel", 12, 5)

	while true do
		wait(0)

		if isKeyCheckAvailable() then
			if isKeyJustPressed(keys.VK_END) then
				activation = not activation
				local textMSG = "on vehicles"
				if not activation then
					textMSG = "off vehicles"
				end
				printStringNow(textMSG, 500)
			end
		end

		if activation then
			local mycar = false
			if isCharInAnyCar(PLAYER_PED) then
				mycar = getCarCharIsUsing(PLAYER_PED)
			end

			for _, handle in ipairs(getAllVehicles()) do
				if handle ~= mycar and doesVehicleExist(handle) and isCarOnScreen(handle) then
					vehName = getGxtText(getNameOfVehicleModel(getCarModel(handle)))
					myX, myY, myZ = getCharCoordinates(PLAYER_PED)
					X, Y, Z = getCarCoordinates(handle)
					result, point = processLineOfSight(myX, myY, myZ, X, Y, Z, true, false, false, true, false, false, false, false)
					if not result then
						distance = getDistanceBetweenCoords3d(X, Y, Z, myX, myY, myZ)
						X, Y = convert3DCoordsToScreen(X, Y, Z + 1)
						if distance < 10.0 then
							renderFontDrawText(font, string.format("%s [%.3f]",vehName, distance), X - 10, Y, -1)
						end
						if distance <= 2.5 then
							if isKeyJustPressed(keys.VK_B) then
								sampSendChat("/vp")
								wait(250)
								stringDialog = sampGetDialogText()
								sampCloseCurrentDialogWithButton(0)
								convertStringToVars()
							end
							renderFontDrawText(font,"{FFA500}Vida: {FFFFFF}["..getCarHealth(handle).."]",X-10,Y+15,-1)
							renderFontDrawText(font,"{FFA500}Motor: {FFFFFF}["..vehInfo.motor.."]",X-10,Y + 30, -1)
							renderFontDrawText(font, "{FFA500}Pneu: {FFFFFF}["..vehInfo.pneu.."]", X - 10, Y + 45, -1)
							renderFontDrawText(font, "{FFA500}Gas: {FFFFFF}["..vehInfo.gas.."]", X - 10, Y + 60, -1)
						end
					end
				end
			end
		end
	end
end


function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
	if(dialogId == 23) then
		stringDialog = sampGetDialogText()
		convertStringToVars()
	end
end