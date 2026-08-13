local function IncluderFunc(fileName)
	if (fileName:find("sv_")) then
		include(fileName)
	elseif (fileName:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	else
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		include(fileName)
	end
end

--прошу обратить внимание что файлы внутри папок загружаются первыми
local function LoadFromDir(directory)
	local files, folders = file.Find(directory .. "/*", "LUA")

	for _, v in ipairs(folders) do
		LoadFromDir(directory .. "/" .. v)
	end

	for _, v in ipairs(files) do
		IncluderFunc(directory .. "/" .. v)
	end
end

LoadFromDir("jsurvival/gamemode/libraries")

function JS_Loader()
	local directory = "jsurvival/gamemode/js"
	local files, folders = file.Find(directory .. "/*", "LUA")

	for _, v in ipairs(files) do
		IncluderFunc(directory .. "/" .. v)
	end

	for _, v in ipairs(folders) do
		LoadFromDir(directory .. "/" .. v)
	end
end

JS_Loader()