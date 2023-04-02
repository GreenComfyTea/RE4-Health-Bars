local label_customization = {};

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

local include_names = {
	current_value = "Current Value",
	max_value = "Max Value"
};

function label_customization.draw(label_name, label)
	local label_changed = false;
	local changed = false;

	if imgui.tree_node(label_name) then
		changed, label.visibility = imgui.checkbox("Visible", label.visibility);
		label_changed = label_changed or changed;

		if imgui.tree_node("Settings") then
			changed, label.settings.right_alignment_shift =imgui.slider_int("Right Alignment Shift", label.settings.right_alignment_shift, 0, 32);
			label_changed = label_changed or changed;

			imgui.tree_pop();
		end

		if label.include ~= nil then
			if imgui.tree_node("Include") then
				for include_name, include in pairs(label.include) do
					changed, label.include[include_name] = imgui.checkbox(include_names[include_name], include);
					label_changed = label_changed or changed;
				end

				imgui.tree_pop();
			end
		end
		
		-- add text format

		if imgui.tree_node("Offset") then
			changed, label.offset.x = imgui.drag_float("X", label.offset.x, 0.1, -screen.width, screen.width, "%.1f");
			label_changed = label_changed or changed;

			changed, label.offset.y = imgui.drag_float("Y", label.offset.y, 0.1, -screen.height, screen.height, "%.1f");
			label_changed = label_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node("Color") then
			changed, label.color = imgui.color_picker_argb("", label.color, customization_menu.color_picker_flags);
			label_changed = label_changed or changed;

			imgui.tree_pop();
		end

		if imgui.tree_node("Shadow") then
			changed, label.shadow.visibility = imgui.checkbox("Visible", label.shadow.visibility);
			label_changed = label_changed or changed;

			if imgui.tree_node("Offset") then
				changed, label.shadow.offset.x = imgui.drag_float("X",
					label.shadow.offset.x, 0.1, -screen.width, screen.width, "%.1f");
				label_changed = label_changed or changed;

				changed, label.shadow.offset.y = imgui.drag_float("Y",
					label.shadow.offset.y, 0.1, -screen.height, screen.height, "%.1f");
				label_changed = label_changed or changed;

				imgui.tree_pop();
			end

			if imgui.tree_node("Color") then
				changed, label.shadow.color = imgui.color_picker_argb("", label.shadow.color, customization_menu.color_picker_flags);
				label_changed = label_changed or changed;

				imgui.tree_pop();
			end

			imgui.tree_pop();
		end

		imgui.tree_pop();
	end

	return label_changed;
end

function label_customization.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	screen = require("Health_Bars.screen");
	customization_menu = require("Health_Bars.customization_menu");
end

return label_customization;