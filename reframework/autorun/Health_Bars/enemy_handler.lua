local this = {};

local utils;
local singletons;
local config;
local drawing;
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

this.enemy_list = {};
this.player_position = Vector3f.new(0, 0, 0);

local character_manager_type_def = sdk.find_type_definition("chainsaw.CharacterManager");
local get_enemy_context_list_method = character_manager_type_def:get_method("get_EnemyContextList");
local get_player_context_method = character_manager_type_def:get_method("getPlayerContextRef");

local enemy_context_list_type_def = get_enemy_context_list_method:get_return_type();
local enemy_context_list_get_count_method = enemy_context_list_type_def:get_method("get_Count");
local enemy_context_list_get_item_method = enemy_context_list_type_def:get_method("get_Item");

local enemy_base_context_type_def = sdk.find_type_definition("chainsaw.EnemyBaseContext");
local get_position_method = enemy_base_context_type_def:get_method("get_Position");
local get_has_ray_to_player_method = enemy_base_context_type_def:get_method("get_HasRayToPlayer");
local get_hit_point_method = enemy_base_context_type_def:get_method("get_HitPoint");

local hit_point_type_def = get_hit_point_method:get_return_type();
local get_default_hit_point_method = hit_point_type_def:get_method("get_DefaultHitPoint");
local get_current_hit_point_method = hit_point_type_def:get_method("get_CurrentHitPoint");
local get_is_live_method = hit_point_type_def:get_method("get_IsLive");

local player_base_context_type_def = sdk.find_type_definition("chainsaw.PlayerBaseContext");
local get_player_position_method = player_base_context_type_def:get_method("get_Position");

function this.new(enemy_context, health, max_health, is_live, has_ray_to_player, position)
	local enemy = {};
	enemy.enemy_context = enemy_context;

	enemy.distance = 0;

	health = health or 0;
	max_health = max_health or 1;
	if is_live == nil then is_live = false; end
	if has_ray_to_player == nil then has_ray_to_player = false; end
	position = position or Vector3f.new(0, 0, 0);

	this.set_health(enemy, health, max_health, is_live);
	this.set_has_ray_to_player(enemy, has_ray_to_player);
	this.set_position(enemy, position);

	this.enemy_list[enemy_context] = enemy;

	return enemy;
end

function this.get_enemy(enemy_context)
	local enemy = this.enemy_list[enemy_context];
	if enemy == nil then
		enemy = this.new(enemy_context);
	end
	
	return enemy;
end

function this.set_health(enemy, health, max_health, is_live)
	if enemy == nil then
		return;
	end

	if health == nil then
		customization_menu.status = "No Enemy Health";
		return;
	end

	enemy.health = health;

	if max_health == nil then
		customization_menu.status = "No Enemy MaxHealth";
		return;
	end

	enemy.max_health = max_health;

	if max_health == 0 then
		enemy.health_percentage = 0;
	else
		enemy.health_percentage = health / max_health;
	end

	if is_live == nil then
		customization_menu.status = "No Enemy IsLive";
		return;
	end

	enemy.is_live = is_live;
end

function this.set_has_ray_to_player(enemy, has_ray_to_player)
	if enemy == nil then
		return;
	end

	if has_ray_to_player == nil then
		customization_menu.status = "No Enemy HasRayToPlayer";
		return;
	end

	enemy.has_ray_to_player = has_ray_to_player;
end

function this.set_position(enemy, position)
	if enemy == nil then
		return;
	end

	if position == nil then
		customization_menu.status = "No Enemy Position";
		return;
	end

	enemy.position = position;

	if this.player_position == nil then
		return;
	end

	enemy.distance = (this.player_position - position):length();
end

function this.update_enemies()
	if singletons.character_manager == nil then
		customization_menu.status = "No Character Manager";
		return;
	end

	local enemy_context_list = get_enemy_context_list_method:call(singletons.character_manager);
	if enemy_context_list == nil then
		customization_menu.status = "No Enemy Context List";
		return;
	end

	local count = enemy_context_list_get_count_method:call(enemy_context_list);
	if count == nil then
		customization_menu.status = "No Enemy Context List Count";
		return;
	end

	this.enemy_list = {};

	for i = 0, count - 1 do
		local enemy_context = enemy_context_list_get_item_method:call(enemy_context_list, i);
		if enemy_context == nil then
			customization_menu.status = "No Enemy Context";
			goto continue;
		end

		local enemy = this.get_enemy(enemy_context);

		local position = get_position_method:call(enemy_context);
		local has_ray_to_player = get_has_ray_to_player_method:call(enemy_context);

		local default_hit_point;
		local current_hit_point;
		local is_live;

		local hit_point = get_hit_point_method:call(enemy_context);

		if hit_point ~= nil then
			default_hit_point = get_default_hit_point_method:call(hit_point);
			current_hit_point = get_current_hit_point_method:call(hit_point);
			is_live = get_is_live_method:call(hit_point);
		end

		this.set_position(enemy, position);
		this.set_has_ray_to_player(enemy, has_ray_to_player);
		this.set_health(enemy, current_hit_point, default_hit_point, is_live);

		::continue::
	end
end

function this.draw_enemies()
	local cached_config = config.current_config;

	for enemy_context, enemy in pairs(this.enemy_list) do
		if cached_config.settings.max_distance == 0 then
			break;
		end

		if  cached_config.settings.hide_if_dead and not enemy.is_live then
			goto continue;
		end

		if cached_config.settings.hide_if_no_ray_to_player and not enemy.has_ray_to_player then
			goto continue;
		end

		if enemy.distance > cached_config.settings.max_distance then
			goto continue;
		end

		local world_offset = Vector3f.new(cached_config.world_offset.x, cached_config.world_offset.y, cached_config.world_offset.z);

		local position_on_screen = draw.world_to_screen(enemy.position + world_offset);
		if position_on_screen == nil then
			goto continue;
		end

		local opacity_scale = 1;
		if cached_config.settings.opacity_falloff then
			opacity_scale = 1 - (enemy.distance / cached_config.settings.max_distance);
		end

		drawing.draw_bar(cached_config.health_bar, position_on_screen, opacity_scale, enemy.health_percentage);
		::continue::
	end
end

function this.update_player_position()
    if singletons.character_manager == nil then
		customization_menu.status = "No Character Manager";
        return;
    end

	local player_context = get_player_context_method:call(singletons.character_manager);
	if player_context == nil then
		customization_menu.status = "No Player Context";
		return;
	end

	local position = get_player_position_method:call(player_context);
	if position == nil then
		customization_menu.status = "No Player Position";
		return;
	end

   this.player_position = position;
end

function this.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	singletons = require("Health_Bars.singletons");
	drawing = require("Health_Bars.drawing");
	customization_menu = require("Health_Bars.customization_menu");
end

return this;