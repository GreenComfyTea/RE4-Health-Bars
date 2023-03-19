local singletons = {};

local customization_menu;

local sdk = sdk;
local tostring = tostring;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local require = require;
local pcall = pcall;
local table = table;
local string = string;
local Vector3f = Vector3f;
local d2d = d2d;
local math = math;
local json = json;
local log = log;
local fs = fs;
local next = next;
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local assert = assert;
local select = select;
local coroutine = coroutine;
local utf8 = utf8;
local re = re;
local imgui = imgui;
local draw = draw;
local Vector2f = Vector2f;
local reframework = reframework;

local character_manager_name = "chainsaw.CharacterManager";
local scene_manager_name = "via.SceneManager";

singletons.character_manager = nil;
singletons.scene_manager = nil;

function singletons.init()
	singletons.init_character_manager();
	singletons.init_scene_manager();
end

function singletons.init_character_manager()
	if singletons.character_manager ~= nil then
		return;
	end

	singletons.character_manager = sdk.get_managed_singleton(character_manager_name);
	if singletons.character_manager == nil then
		customization_menu.status = "No Character Manager";
	end

	return singletons.character_manager;
end

function singletons.init_scene_manager()
	if singletons.scene_manager ~= nil then
		return;
	end

	singletons.scene_manager = sdk.get_native_singleton(scene_manager_name);
	if singletons.scene_manager == nil then
		customization_menu.status = "No Scene Manager";
	end

	return singletons.scene_manager;
end

function singletons.init_module()
	customization_menu = require("Health_Bars.customization_menu");

	singletons.init();
end

return singletons;
