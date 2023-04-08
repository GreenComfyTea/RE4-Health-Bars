local this = {};

local utils;
local config;
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

local outline_styles = {"Inside", "Center", "Outside"};
local directions = {"Left to Right", "Right to Left", "Top to Bottom", "Bottom to Top"};

function this.draw(bar_name, bar)
	if bar == nil then
		return false;
	end

	if bar_name == nil then
		bar_name = "";
	end

	local bar_changed = false;
	local changed = false;
	local index = 1;

	if imgui.tree_node(bar_name) then
		changed, bar.visibility = imgui.checkbox("Visible" , bar.visibility);
		bar_changed = bar_changed or changed;

		if imgui.tree_node("Settings") then
			local fill_direction_index = utils.table.find_index(directions, bar.settings.fill_direction);
			changed, fill_direction_index = imgui.combo("Fill Type", fill_direction_index, directions);

			bar_changed = bar_changed or changed;

			if changed then
				bar.settings.fill_direction = directions[fill_direction_index];
			end

			imgui.tree_pop();
		end

		if imgui.tree_node("Offset") then
			changed, bar.offset.x = imgui.drag_float("X",
				bar.offset.x, 0.1, -screen.width, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.offset.y = imgui.drag_float("Y",
				bar.offset.y, 0.1, -screen.height, screen.height, "%.1f");
			bar_changed = bar_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node("Size") then
			changed, bar.size.width = imgui.drag_float("Width",
				bar.size.width, 0.1, 0, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.size.height = imgui.drag_float("Height",
				bar.size.height, 0.1, 0, screen.height, "%.1f");
			bar_changed = bar_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node("Outline") then
			changed, bar.outline.visibility = imgui.checkbox("Visible"
				, bar.outline.visibility);
			bar_changed = bar_changed or changed;

			changed, bar.outline.thickness = imgui.drag_float("Thickness",
				bar.outline.thickness, 0.1, 0, screen.width, "%.1f");
			bar_changed = bar_changed or changed;

			changed, bar.outline.offset = imgui.drag_float("Offset",
				bar.outline.offset, 0.1, -screen.height, screen.height, "%.1f");
			bar_changed = bar_changed or changed;


			changed, index = imgui.combo("Style",
				utils.table.find_index(outline_styles, bar.outline.style),
				outline_styles);
			bar_changed = bar_changed or changed;

			if changed then
				bar.outline.style = outline_styles[index];
			end

			imgui.tree_pop();
		end

		if imgui.tree_node("Colors") then
			if imgui.tree_node("Foreground") then
				changed, bar.colors.foreground = imgui.color_picker_argb("", bar.colors.foreground,
					customization_menu.color_picker_flags);
				bar_changed = bar_changed or changed;

				imgui.tree_pop();
			end

			if imgui.tree_node("Background") then
				changed, bar.colors.background = imgui.color_picker_argb("", bar.colors.background,
					customization_menu.color_picker_flags);
				bar_changed = bar_changed or changed;

				imgui.tree_pop();
			end

			if imgui.tree_node("Outline") then
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
	screen = require("Health_Bars.screen");
	customization_menu = require("Health_Bars.customization_menu");
end

return this;
