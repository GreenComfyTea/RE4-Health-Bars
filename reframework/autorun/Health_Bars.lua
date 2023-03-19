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

local drawing = require("Health_Bars.drawing");
local utils = require("Health_Bars.utils");
local config = require("Health_Bars.config");
local screen = require("Health_Bars.screen");
local singletons = require("Health_Bars.singletons");

local bar_customization = require("Health_Bars.bar_customization");
local customization_menu = require("Health_Bars.customization_menu");

local enemy_handler = require("Health_Bars.enemy_handler");

------------------------INIT MODULES-------------------------
-- #region
drawing.init_module();
utils.init_module();
config.init_module();
screen.init_module();
singletons.init_module();

bar_customization.init_module();
customization_menu.init_module();

enemy_handler.init_module();

log.info("[Health Bars] Loaded.");
-- #endregion
------------------------INIT MODULES-------------------------

----------------------------LOOP-----------------------------
-- #region

local function main_loop()
	local cached_config = config.current_config;

	if not cached_config.enabled then
		return;
	end
	
	customization_menu.status = "OK";

	singletons.init();
	screen.update_window_size();
	enemy_handler.update_player_position();

	enemy_handler.update_enemies();
	enemy_handler.draw_enemies();
end

-- #endregion
----------------------------LOOP-----------------------------

--------------------------RE_IMGUI---------------------------
-- #region
re.on_draw_ui(function()
	if imgui.button("Health Bars v" .. config.current_config.version) then
		customization_menu.is_opened = not customization_menu.is_opened;
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