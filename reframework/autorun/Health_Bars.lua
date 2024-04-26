
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
local ValueType = ValueType;
local package = package;

local time = require("Health_Bars.time");
local drawing = require("Health_Bars.drawing");
local utils = require("Health_Bars.utils");
local config = require("Health_Bars.config");
local error_handler = require("Health_Bars.error_handler");
local language = require("Health_Bars.language");
local screen = require("Health_Bars.screen");
local singletons = require("Health_Bars.singletons");

local label_customization = require("Health_Bars.label_customization");
local bar_customization = require("Health_Bars.bar_customization");
local customization_menu = require("Health_Bars.customization_menu");

local gui_handler = require("Health_Bars.gui_handler");
local player_handler = require("Health_Bars.player_handler");
local enemy_handler = require("Health_Bars.enemy_handler");

------------------------INIT MODULES-------------------------
-- #region
time.init_module();
drawing.init_module();
utils.init_module();
language.init_module();
config.init_module();
error_handler.init_module();
screen.init_module();
singletons.init_module();

label_customization.init_module();
bar_customization.init_module();
customization_menu.init_module();

gui_handler.init_module();
player_handler.init_module();
enemy_handler.init_module();

log.info("[Health Bars] Loaded.");
-- #endregion
------------------------INIT MODULES-------------------------

----------------------------LOOP-----------------------------
-- #region
re.on_pre_application_entry("UpdateBehavior", function()
	if not config.current_config.enabled then
		return;
	end

	time.update_script_time();
	singletons.update();
	screen.update_window_size();

	gui_handler.update();
	player_handler.update();
	enemy_handler.update_all_periodics();
end);

local function main_loop()
	if not config.current_config.enabled then
		return;
	end

	enemy_handler.update_all_positions();
	enemy_handler.draw_enemies();
end

-- #endregion
----------------------------LOOP-----------------------------

--------------------------RE_IMGUI---------------------------
-- #region
re.on_draw_ui(function()
	local changed = false;
	local cached_config = config.current_config;

	if imgui.button("Health Bars v" .. config.current_config.version) then
		customization_menu.is_opened = not customization_menu.is_opened;
	end

	imgui.same_line();

	changed, cached_config.enabled = imgui.checkbox("Enabled##HEALTH_BARS", cached_config.enabled);
	if changed then
		config.save();
	end
end);

re.on_frame(function()
	if not reframework:is_drawing_ui() then
		customization_menu.is_opened = false;
	end

	if customization_menu.is_opened then
		pcall(customization_menu.draw);
	end
end);
-- #endregion
--------------------------RE_IMGUI---------------------------

----------------------------D2D------------------------------
-- #region
if d2d ~= nil then
	d2d.register(function()
		drawing.init_font();
	end, function() 
		if config.current_config.settings.use_d2d_if_available then
			main_loop();
		end
	end);
end

re.on_frame(function()
	if d2d == nil or not config.current_config.settings.use_d2d_if_available then
		main_loop();
	end
end);
-- #endregion
----------------------------D2D------------------------------
