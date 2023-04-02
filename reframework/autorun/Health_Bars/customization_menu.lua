local this = {};

local utils;
local config;
local label_customization;
local bar_customization;

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

this.status = "OK";

this.font = nil;
this.font_range = {0x1, 0xFFFF, 0};
this.is_opened = false;

this.window_position = Vector2f.new(480, 200);
this.window_pivot = Vector2f.new(0, 0);
this.window_size = Vector2f.new(450, 450);
this.window_flags = 0x10120;
this.color_picker_flags = 327680;
this.decimal_input_flags = 33;

this.config_changed = false;;

function this.init()
end

function this.draw()
	local cached_config = config.current_config;

	imgui.set_next_window_pos(this.window_position, 1 << 3, this.window_pivot);
	imgui.set_next_window_size(this.window_size, 1 << 3);

	this.is_opened = imgui.begin_window(
		"Health Bars v" .. config.current_config.version, this.is_opened, this.window_flags);

	if not this.is_opened then
		imgui.end_window();
		return;
	end

	imgui.text("Status: " .. tostring(this.status));

	local changed = false;
	local config_changed = false;

	local index = 1;

	changed, cached_config.enabled = imgui.checkbox("Enabled", cached_config.enabled);
	config_changed = config_changed or changed;

	if imgui.tree_node("Settings") then
		changed, cached_config.settings.use_d2d_if_available = imgui.checkbox("Use Direct2D Renderer if Available",
			cached_config.settings.use_d2d_if_available);
		config_changed = config_changed or changed;

		changed, cached_config.settings.hide_if_dead = imgui.checkbox("Hide if Dead",
			cached_config.settings.hide_if_dead);
		config_changed = config_changed or changed;

		changed, cached_config.settings.hide_if_no_ray_to_player = imgui.checkbox("Hide if No Ray to Player",
			cached_config.settings.hide_if_no_ray_to_player);
		config_changed = config_changed or changed;

		changed, cached_config.settings.opacity_falloff = imgui.checkbox("Opacity Falloff",
			cached_config.settings.opacity_falloff);
		config_changed = config_changed or changed;

		changed, cached_config.settings.max_distance = imgui.drag_float("Max Distance",
			cached_config.settings.max_distance, 1, 0, 10000, "%.0f");
		config_changed = config_changed or changed;

		imgui.tree_pop();
	end

	if imgui.tree_node("World Offset") then
		changed, cached_config.world_offset.x = imgui.drag_float("X",
			cached_config.world_offset.x, 0.01, -10, 10, "%.2f");

		config_changed = config_changed or changed;

		changed, cached_config.world_offset.y = imgui.drag_float("Y",
			cached_config.world_offset.y, 0.01, -10, 10, "%.2f");

		config_changed = config_changed or changed;

		changed, cached_config.world_offset.z = imgui.drag_float("Z",
				cached_config.world_offset.z, 0.01, -10, 10, "%.2f");

		config_changed = config_changed or changed;

		imgui.tree_pop();
	end
	changed = label_customization.draw("Health Value Label", cached_config.health_value_label);
	changed = bar_customization.draw("Health Bar", cached_config.health_bar);
	config_changed = config_changed or changed;
	
	imgui.end_window();

	if config_changed then
		config.save();
	end
end

function this.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	label_customization = require("Health_Bars.label_customization");
	bar_customization = require("Health_Bars.bar_customization");

	this.init();
end

return this;