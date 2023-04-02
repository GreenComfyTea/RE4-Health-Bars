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

local update_last_valid_position_method = enemy_base_context_type_def:get_method("updateLastValidPosition");

local hit_point_type_def = get_hit_point_method:get_return_type();
local get_default_hit_point_method = hit_point_type_def:get_method("get_DefaultHitPoint");
local get_current_hit_point_method = hit_point_type_def:get_method("get_CurrentHitPoint");
local get_is_live_method = hit_point_type_def:get_method("get_IsLive");

local player_base_context_type_def = sdk.find_type_definition("chainsaw.PlayerBaseContext");
local get_player_position_method = player_base_context_type_def:get_method("get_Position");

function this.new(enemy_context)
	local enemy = {};
	enemy.enemy_context = enemy_context;

	enemy.health = 0;
	enemy.max_health = 100;
	enemy.is_live = false;
	enemy.has_ray_to_player = false;
	enemy.position = Vector3f.new(0, 0, 0);
	enemy.distance = 0;

	this.update_health(enemy);

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

function this.get_enemy_null(enemy_context, create_if_not_found)
	if create_if_not_found == nil then
		create_if_not_found = true;
	end

	--xy = tostring(create_if_not_found);

	local enemy = this.enemy_list[enemy_context];
	if enemy == nil and create_if_not_found then
		enemy = this.new(enemy_context);
	end
	
	return enemy;
end

function this.update_health(enemy)
	if enemy == nil then
		customization_menu.status = "No Enemy";
		return;
	end

	local hit_point = get_hit_point_method:call(enemy.enemy_context);

	if hit_point == nil then
		customization_menu.status = "No Enemy Hit Point";
		return;
	end

	local default_hit_point = get_default_hit_point_method:call(hit_point);
	local current_hit_point = get_current_hit_point_method:call(hit_point);
	local is_live = get_is_live_method:call(hit_point);

	if default_hit_point == nil then
		customization_menu.status = "No Enemy Default Hit Point";
	else
		enemy.max_health = default_hit_point;
	end

	if current_hit_point == nil then
		customization_menu.status = "No Enemy Current Hit Point";
	else
		enemy.health = current_hit_point;
	end

	if enemy.max_health == 0 then
		enemy.health_percentage = 0;
	else
		enemy.health_percentage = enemy.health / enemy.max_health;
	end

	if is_live == nil then
		customization_menu.status = "No Enemy IsLive";
	else
		enemy.is_live = is_live;
	end
end

function this.update_has_ray_to_player(enemy)
	if enemy == nil then
		customization_menu.status = "No Enemy";
		return;
	end

	local has_ray_to_player = get_has_ray_to_player_method:call(enemy.enemy_context);

	if has_ray_to_player == nil then
		customization_menu.status = "No Enemy HasRayToPlayer";
		return;
	end

	enemy.has_ray_to_player = has_ray_to_player;
end

function this.update_position(enemy)
	if enemy == nil then
		customization_menu.status = "No Enemy";
		return;
	end

	local position = get_position_method:call(enemy.enemy_context);

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

		local health_value_text = "";

		local health_value_label = cached_config.health_value_label;
		local health_value_include = health_value_label.include;
		local right_alignment_shift = health_value_label.settings.right_alignment_shift;

		if health_value_include.current_value then
			health_value_text = tostring(enemy.health);

			if health_value_include.max_value then
				health_value_text = string.format("%s/%s", health_value_text, tostring(enemy.max_health));
			end
		elseif health_value_include.max_value then
			health_value_text = tostring(enemy.max_health);
		end

		if right_alignment_shift ~= 0 then
			local right_aligment_format = string.format("%%%ds", right_alignment_shift);
			health_value_text = string.format(right_aligment_format, health_value_text);
		end
		
		drawing.draw_bar(cached_config.health_bar, position_on_screen, opacity_scale, enemy.health_percentage);
		drawing.draw_label(health_value_label, position_on_screen, opacity_scale, health_value_text);
		
		::continue::
	end

	--drawing.draw_bar(cached_config.health_bar, {x = 150, y = 50}, 1, 0.5);
end

local enemies = {};

function this.on_can_valid_position_save(enemy_context)
	if enemy_context == nil then
		customization_menu.status = "No Enemy Context";
		return;
	end

	local enemy = this.get_enemy(enemy_context);

	--enemies[enemy_context] = "On Can Valid Position Save";

	--xy = utils.table_tostring(enemies);

	this.update_position(enemy);
	this.update_has_ray_to_player(enemy);
end

function this.on_notify_hit_damage(damage_info, enemy_context)
	if enemy_context == nil then
		customization_menu.status = "No Damage Info";
		--return;
	end
	
	if enemy_context == nil then
		customization_menu.status = "No Enemy Context";
		return;
	end

	local enemy = this.get_enemy(enemy_context);

	this.update_health(enemy);

	xy = enemy.health;
end

function this.on_notify_dead(damage_info, enemy_context)
	if enemy_context == nil then
		customization_menu.status = "No Damage Info";
		--return;
	end
	
	if enemy_context == nil then
		customization_menu.status = "No Enemy Context";
		--return;
	end

	local enemy = this.get_enemy(enemy_context);
	enemy.is_live = false;
end

local enemy_base_context_type_def = sdk.find_type_definition("chainsaw.EnemyBaseContext");
local can_valid_position_save_method = enemy_base_context_type_def:get_method("canValidPositionSave");

sdk.hook(can_valid_position_save_method, function(args)
	local enemy_context = sdk.to_managed_object(args[2]);
	this.on_can_valid_position_save(enemy_context);
end, function(retval)
	return retval;
end);

local enemy_manager = sdk.find_type_definition("chainsaw.EnemyManager");
local notify_hit_damage_method = enemy_manager:get_method("notifyHitDamage");
local notify_dead_method = enemy_manager:get_method("notifyDead");

sdk.hook(notify_hit_damage_method, function(args)
	local damage_info = sdk.to_managed_object(args[3]);
	local enemy_context = sdk.to_managed_object(args[4]);

	this.on_notify_hit_damage(damage_info, enemy_context);
end, function(retval)
	return retval;
end);

sdk.hook(notify_dead_method, function(args)
	local damage_info = sdk.to_managed_object(args[3]);
	local enemy_context = sdk.to_managed_object(args[4]);
	
	this.on_notify_dead(damage_info, enemy_context);
end, function(retval)
	return retval;
end);

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