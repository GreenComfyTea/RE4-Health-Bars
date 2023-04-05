local this = {};

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
local os = os;

local character_manager_name = "chainsaw.CharacterManager";
local scene_manager_name = "via.SceneManager";
local gui_manager_name = "chainsaw.GuiManager";

this.character_manager = nil;
this.scene_manager = nil;
this.gui_manager = nil;

function this.init()
	this.init_character_manager();
	this.init_scene_manager();
	this.init_gui_manager();
end

function this.init_character_manager()
	if this.character_manager ~= nil then
		return;
	end

	this.character_manager = sdk.get_managed_singleton(character_manager_name);
	if this.character_manager == nil then
		customization_menu.status = "No Character Manager";
	end

	return this.character_manager;
end

function this.init_scene_manager()
	if this.scene_manager ~= nil then
		return;
	end

	this.scene_manager = sdk.get_native_singleton(scene_manager_name);
	if this.scene_manager == nil then
		customization_menu.status = "No Scene Manager";
	end

	return this.scene_manager;
end

function this.init_gui_manager()
	if this.gui_manager ~= nil then
		return;
	end

	this.gui_manager = sdk.get_managed_singleton(gui_manager_name);
	if this.gui_manager == nil then
		customization_menu.status = "No GUI Manager";
	end

	return this.gui_manager;
end

function this.init_module()
	customization_menu = require("Health_Bars.customization_menu");

	this.init();
end

return this;
