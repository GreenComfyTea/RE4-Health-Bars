local this = {};

local utils;
local singletons;
local config;
local customization_menu;
local enemy_handler;
local time;

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

this.player = {};
this.player.position = Vector3f.new(0, 0, 0);
this.player.is_aiming = false;
this.player.is_using_scope = false;
this.player.aim_target_body = nil;

local character_manager_type_def = sdk.find_type_definition("chainsaw.CharacterManager");
local get_player_context_method = character_manager_type_def:get_method("getPlayerContextRef");

local player_base_context_type_def = sdk.find_type_definition("chainsaw.PlayerBaseContext");
local get_player_position_method = player_base_context_type_def:get_method("get_Position");
local get_is_holding_method = player_base_context_type_def:get_method("get_IsHolding");
local get_aim_target_enemy_method = player_base_context_type_def:get_method("get_AimTargetEnemy");
local get_camera_controller_method = player_base_context_type_def:get_method("get_CameraController");

local main_camera_controller_type_def = get_camera_controller_method:get_return_type();
local get_is_scope_camera_method = main_camera_controller_type_def:get_method("get_IsScopeCamera");

local gui_manager_type_def = sdk.find_type_definition("chainsaw.GuiManager");
local get_is_playing_event_method = gui_manager_type_def:get_method("get_IsPlayingEvent");
local get_is_hud_off_method = gui_manager_type_def:get_method("get_IsHudOff");

function this.update_position(player_context)
	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	local position = get_player_position_method:call(player_context);
	if position == nil then
		customization_menu.status = "No Player Position";
		return;
	end

	this.player.position = position;
end

function this.update_is_aiming(player_context)
	local cached_config = config.current_config.settings;

	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	local is_aiming = get_is_holding_method:call(player_context);
	if is_aiming == nil then
		customization_menu.status = "No Player IsAiming";
		return;
	end

	this.player.is_aiming = is_aiming;

	if is_aiming and cached_config.apply_time_duration_on_aiming then
		for enemy_context, enemy in pairs(enemy_handler.enemy_list) do
			enemy_handler.update_last_reset_time(enemy);
		end
	end
end

function this.update_aim_target(player_context)
	local cached_config = config.current_config.settings;

	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	local aim_target_body = get_aim_target_enemy_method:call(player_context);
	this.player.aim_target_body = aim_target_body;

	if aim_target_body == nil then
		return;
	end

	local enemy = enemy_handler.enemy_body_list[aim_target_body];
	if enemy == nil then
		customization_menu.status = "No Aim Target Enemy";
		return;
	end

	if cached_config.reset_time_duration_on_aim_target_for_everyone then
		for enemy_context, enemy in pairs(enemy_handler.enemy_list) do
			if time.total_elapsed_script_seconds - enemy.last_reset_time < cached_config.time_duration then
				enemy_handler.update_last_reset_time(enemy);
			end
		end
	end
	
	if cached_config.apply_time_duration_on_aim_target then
		enemy_handler.update_last_reset_time(enemy);
	end
end

function this.update_is_using_scope(player_context)
	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	local camera_controller = get_camera_controller_method:call(player_context);
	if camera_controller == nil then
		customization_menu.status = "No Player Camera Controller";
		return;
	end

	local is_scope_camera = get_is_scope_camera_method:call(camera_controller);
	if is_scope_camera == nil then
		customization_menu.status = "No Player IsScopeCamera";
		return;
	end

	this.player.is_using_scope = is_scope_camera;

	if is_scope_camera and config.current_config.settings.apply_time_duration_on_using_scope then
		for enemy_context, enemy in pairs(enemy_handler.enemy_list) do
			enemy_handler.update_last_reset_time(enemy);
		end
	end
end

function this.update()
    if singletons.character_manager == nil then
		customization_menu.status = "No Character Manager";
        return;
    end

	local player_context = get_player_context_method:call(singletons.character_manager);
	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	this.update_position(player_context);
	this.update_is_aiming(player_context);
	this.update_aim_target(player_context);
	this.update_is_using_scope(player_context);
end

function this.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	singletons = require("Health_Bars.singletons");
	customization_menu = require("Health_Bars.customization_menu");
	enemy_handler = require("Health_Bars.enemy_handler");
	time = require("Health_Bars.time");
end

return this;