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
local os = os;

this.status = "OK";

this.font = nil;
this.font_range = {0x1, 0xFFFF, 0};
this.is_opened = false;

this.window_position = Vector2f.new(480, 200);
this.window_pivot = Vector2f.new(0, 0);
this.window_size = Vector2f.new(550, 450);
this.window_flags = 0x10120;
this.color_picker_flags = 327680;
this.decimal_input_flags = 33;

this.config_changed = false;

this.fonts = {	"Arial", "Arial Black", "Bahnschrift", "Calibri", "Cambria", "Cambria Math", "Candara",
				"Comic Sans MS", "Consolas", "Constantia", "Corbel", "Courier New", "Ebrima",
				"Franklin Gothic Medium", "Gabriola", "Gadugi", "Georgia", "HoloLens MDL2 Assets", "Impact",
				"Ink Free", "Javanese Text", "Leelawadee UI", "Lucida Console", "Lucida Sans Unicode",
				"Malgun Gothic", "Marlett", "Microsoft Himalaya", "Microsoft JhengHei", "Microsoft New Tai Lue",
				"Microsoft PhagsPa", "Microsoft Sans Serif", "Microsoft Tai Le", "Microsoft YaHei",
				"Microsoft Yi Baiti", "MingLiU-ExtB", "Mongolian Baiti", "MS Gothic", "MV Boli", "Myanmar Text",
				"Nirmala UI", "Palatino Linotype", "Segoe MDL2 Assets", "Segoe Print", "Segoe Script", "Segoe UI",
				"Segoe UI Historic", "Segoe UI Emoji", "Segoe UI Symbol", "SimSun", "Sitka", "Sylfaen", "Symbol",
				"Tahoma", "Times New Roman", "Trebuchet MS", "Verdana", "Webdings", "Wingdings", "Yu Gothic"
};

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

	if imgui.button("Reset Config") then
		config.reset();
	end

	imgui.same_line();
	imgui.text("Status: " .. tostring(this.status));

	local changed = false;
	local config_changed = false;

	local index = 1;

	changed, cached_config.enabled = imgui.checkbox("Enabled", cached_config.enabled);
	config_changed = config_changed or changed;

	if imgui.tree_node("Font") then
		imgui.text("Any changes to the font require script reload!");

		changed, index = imgui.combo("Family",
			utils.table.find_index(this.fonts, cached_config.font.family), this.fonts);
		config_changed = config_changed or changed;

		if changed then
			cached_config.font.family = this.fonts[index];
		end

		changed, cached_config.font.size = imgui.slider_int("Size",
			cached_config.font.size, 1, 100);
		config_changed = config_changed or changed;

		changed, cached_config.font.bold = imgui.checkbox("Bold",
			cached_config.font.bold);
		config_changed = config_changed or changed;

		changed, cached_config.font.italic = imgui.checkbox("Italic",
			cached_config.font.italic);
		config_changed = config_changed or changed;

		imgui.tree_pop();

	end

	if imgui.tree_node("Settings") then
		changed, cached_config.settings.use_d2d_if_available = imgui.checkbox("Use Direct2D Renderer if Available",
			cached_config.settings.use_d2d_if_available);
		config_changed = config_changed or changed;

		changed, cached_config.settings.add_enemy_height_to_world_offset = imgui.checkbox("Add Enemy Height to World Offset",
			cached_config.settings.add_enemy_height_to_world_offset);
		config_changed = config_changed or changed;

		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.render_during_cutscenes = imgui.checkbox("Render during Cutscenes",
			cached_config.settings.render_during_cutscenes);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_hud_is_off = imgui.checkbox("Render when HUD is Disabled by Game",
			cached_config.settings.render_when_hud_is_off);
		config_changed = config_changed or changed;
		
		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()


		changed, cached_config.settings.render_aim_target_enemy = imgui.checkbox("Render Aim Target Enemy",
			cached_config.settings.render_aim_target_enemy);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_damaged_enemies = imgui.checkbox("Render Damaged Enemies",
			cached_config.settings.render_damaged_enemies);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_everyone_else = imgui.checkbox("Render Everyone Else",
			cached_config.settings.render_everyone_else);
		config_changed = config_changed or changed;
		
		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()
		
		changed, cached_config.settings.render_when_normal = imgui.checkbox("Render when Normal",
			cached_config.settings.render_when_normal);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_aiming = imgui.checkbox("Render when Aiming",
			cached_config.settings.render_when_aiming);
		config_changed = config_changed or changed;

		changed, cached_config.settings.render_when_using_scope = imgui.checkbox("Render when using Scope",
			cached_config.settings.render_when_using_scope);
		config_changed = config_changed or changed;

		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.hide_if_dead = imgui.checkbox("Hide if Dead",
			cached_config.settings.hide_if_dead);
		config_changed = config_changed or changed;

		changed, cached_config.settings.hide_if_full_health = imgui.checkbox("Hide if Full Health",
			cached_config.settings.hide_if_full_health);
		config_changed = config_changed or changed;

		changed, cached_config.settings.hide_if_no_ray_to_player = imgui.checkbox("Hide if No Ray to Player",
			cached_config.settings.hide_if_no_ray_to_player);
		config_changed = config_changed or changed;

		changed, cached_config.settings.hide_if_no_update_function_is_being_called = imgui.checkbox("Hide if No Update Function is Being Called",
			cached_config.settings.hide_if_no_update_function_is_being_called);
		config_changed = config_changed or changed;

		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.opacity_falloff = imgui.checkbox("Opacity Falloff",
			cached_config.settings.opacity_falloff);
		config_changed = config_changed or changed;

		changed, cached_config.settings.max_distance = imgui.drag_float("Max Distance",
			cached_config.settings.max_distance, 1, 0, 10000, "%.0f");
		config_changed = config_changed or changed;

		changed, cached_config.settings.scope_opacity_falloff = imgui.checkbox("Opacity Falloff (Scope)",
			cached_config.settings.scope_opacity_falloff);
		config_changed = config_changed or changed;

		changed, cached_config.settings.scope_max_distance = imgui.drag_float("Max Distance (Scope)",
			cached_config.settings.scope_max_distance, 1, 0, 10000, "%.0f");
		config_changed = config_changed or changed;

		imgui.end_rect(5);
		imgui.new_line();
		imgui.begin_rect()

		changed, cached_config.settings.apply_time_duration_on_aiming = imgui.checkbox("Apply Time Duration on Aiming",
			cached_config.settings.apply_time_duration_on_aiming);
		config_changed = config_changed or changed;

		changed, cached_config.settings.apply_time_duration_on_aim_target = imgui.checkbox("Apply Time Duration on Aim Target",
			cached_config.settings.apply_time_duration_on_aim_target);
		config_changed = config_changed or changed;

		changed, cached_config.settings.apply_time_duration_on_using_scope = imgui.checkbox("Apply Time Duration on using Scope",
			cached_config.settings.apply_time_duration_on_using_scope);
		config_changed = config_changed or changed;

		changed, cached_config.settings.apply_time_duration_on_damage_dealt = imgui.checkbox("Apply Time Duration on Damage Dealt",
			cached_config.settings.apply_time_duration_on_damage_dealt);
		config_changed = config_changed or changed;

		changed, cached_config.settings.reset_time_duration_on_aim_target_for_everyone = imgui.checkbox("Reset Time Duration on Aim Target for Everyone",
			cached_config.settings.reset_time_duration_on_aim_target_for_everyone);
		config_changed = config_changed or changed;

		changed, cached_config.settings.reset_time_duration_on_damage_dealt_for_everyone = imgui.checkbox("Reset Time Duration on Damage Dealt for Everyone",
			cached_config.settings.reset_time_duration_on_damage_dealt_for_everyone);
		config_changed = config_changed or changed;

		changed, cached_config.settings.time_duration = imgui.drag_float("Time Duration (sec)",
			cached_config.settings.time_duration, 0.1, 0, 1000, "%.1f");

		imgui.end_rect(5);
		imgui.new_line();
		
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
	config_changed = config_changed or changed;
	
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