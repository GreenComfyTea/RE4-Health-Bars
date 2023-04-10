local this = {};

local config;
local singletons;
local utils;

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

this.width = 1920;
this.height = 1080;

local scene_view;
local scene_view_type = sdk.find_type_definition("via.SceneView");
local get_size_method = scene_view_type:get_method("get_Size");

local size_type = get_size_method:get_return_type();
local width_field = size_type:get_field("w");
local height_field = size_type:get_field("h");

function this.update_window_size()
	local width;
	local height;

	if d2d ~= nil and config.current_config.settings.use_d2d_if_available then
		local success, d2d_width, d2d_height = pcall(d2d.surface_size);
		if success then
			width = d2d_width;
			height = d2d_height;
		else
			width, height = this.get_game_window_size();
		end
	else
		width, height = this.get_game_window_size();
	end

	if width ~= nil then
		this.width = width;
	end

	if height ~= nil then
		this.height = height;
	end
end

function this.get_game_window_size()
	if scene_view == nil then
		if singletons.scene_manager == nil then
			return;
		end

		scene_view = sdk.call_native_func(singletons.scene_manager, sdk.find_type_definition("via.SceneManager"), "get_MainView");

		if scene_view == nil then
			return;
		end
	end

	local size = get_size_method:call(scene_view);
	if size == nil then
		return;
	end

	local screen_width = width_field:get_data(size);
	if screen_width == nil then
		return;
	end

	local screen_height = height_field:get_data(size);
	if screen_height == nil then
		return;
	end

	return screen_width, screen_height;
end

function this.init_module()
	config = require("Health_Bars.config");
	singletons = require("Health_Bars.singletons");
	utils = require("Health_Bars.utils");
end

return this;
