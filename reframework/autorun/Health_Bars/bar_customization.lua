local this = {};

local utils;
local config;
local language;
local screen;
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

local outline_styles = {};
local displayed_outline_styles = {};

local directions = {};
local displayed_directions = {};

function this.init()
	local cached_default_language = language.default_language.customization_menu;
	local cached_current_language = language.current_language.customization_menu;

	outline_styles = {
		cached_default_language.inside,
		cached_default_language.center,
		cached_default_language.outside
	};

	displayed_outline_styles = {
		cached_current_language.inside,
		cached_current_language.center,
		cached_current_language.outside
	};

	directions = {
		cached_default_language.left_to_right,
		cached_default_language.right_to_left,
		cached_default_language.top_to_bottom,
		cached_default_language.bottom_to_top
	};

	displayed_directions = {
		cached_current_language.left_to_right,
		cached_current_language.right_to_left,
		cached_current_language.top_to_bottom,
		cached_current_language.bottom_to_top
	};
end

function this.draw(bar_name, bar)
	local cached_language = language.current_language.customization_menu;

	local bar_changed = false;
	local changed = false;
	local index = 1;

	if imgui.tree_node(bar_name) then
		changed, bar.visibility = imgui.checkbox(cached_language.visible, bar.visibility);
		bar_changed = bar_changed or changed;

		if imgui.tree_node(cached_language.settings) then
			local fill_direction_index = utils.table.find_index(directions, bar.settings.fill_direction);
			changed, fill_direction_index = imgui.combo(cached_language.fill_type, fill_direction_index, displayed_directions);

			bar_changed = bar_changed or changed;

			if changed then
				bar.settings.fill_direction = directions[fill_direction_index];
			end

			imgui.tree_pop();
		end

		if imgui.tree_node(cached_language.offset) then
			changed, bar.offset.x = imgui.drag_float(cached_language.x,
				bar.offset.x, 0.1, -screen.width, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.offset.y = imgui.drag_float(cached_language.y,
				bar.offset.y, 0.1, -screen.height, screen.height, "%.1f");
			bar_changed = bar_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node(cached_language.size) then
			changed, bar.size.width = imgui.drag_float(cached_language.width,
				bar.size.width, 0.1, 0, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.size.height = imgui.drag_float(cached_language.height,
				bar.size.height, 0.1, 0, screen.height, "%.1f");
			bar_changed = bar_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node(cached_language.outline) then
			changed, bar.outline.visibility = imgui.checkbox(cached_language.visible
				, bar.outline.visibility);
			bar_changed = bar_changed or changed;

			changed, bar.outline.thickness = imgui.drag_float(cached_language.thickness,
				bar.outline.thickness, 0.1, 0, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.outline.offset = imgui.drag_float(cached_language.offset,
				bar.outline.offset, 0.1, -screen.height, screen.height, "%.1f");
			bar_changed = bar_changed or changed;


			changed, index = imgui.combo(cached_language.style,
				utils.table.find_index(outline_styles, bar.outline.style),
				displayed_outline_styles);
			bar_changed = bar_changed or changed;

			if changed then
				bar.outline.style = outline_styles[index];
			end

			imgui.tree_pop();
		end

		if imgui.tree_node(cached_language.colors) then
			if imgui.tree_node(cached_language.foreground) then
				changed, bar.colors.foreground = imgui.color_picker_argb("", bar.colors.foreground,
					customization_menu.color_picker_flags);
				bar_changed = bar_changed or changed;

				imgui.tree_pop();
			end

			if imgui.tree_node(cached_language.background) then
				changed, bar.colors.background = imgui.color_picker_argb("", bar.colors.background,
					customization_menu.color_picker_flags);
				bar_changed = bar_changed or changed;

				imgui.tree_pop();
			end

			if imgui.tree_node(cached_language.outline) then
				changed, bar.colors.outline = imgui.color_picker_argb("", bar.colors.outline,
					customization_menu.color_picker_flags);
				bar_changed = bar_changed or changed;

				imgui.tree_pop();
			end

			imgui.tree_pop();
		end

		bar_changed = bar_changed or changed;

		imgui.tree_pop();
	end

	return bar_changed;
end

function this.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	language = require("Health_Bars.language");
	screen = require("Health_Bars.screen");
	customization_menu = require("Health_Bars.customization_menu");
end

return this;
