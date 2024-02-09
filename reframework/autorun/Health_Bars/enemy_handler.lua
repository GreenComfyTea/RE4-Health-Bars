local this = {};

local utils;
local singletons;
local config;
local drawing;
local customization_menu;
local player_handler;
local gui_handler;
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

this.enemy_list = {};
this.enemy_body_list = {};

this.vital_states = {
	Fine = 0,
	Caution = 1,
	Danger = 2,
	Poison = 3,
	Dead = 4
}

local update_time_limit = 1;

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
local get_body_game_object_method = enemy_base_context_type_def:get_method("get_BodyGameObject");
local release_method = enemy_base_context_type_def:get_method("release");
local get_is_combat_ready_method = enemy_base_context_type_def:get_method("get_IsCombatReady");
local get_is_lively_method = enemy_base_context_type_def:get_method("get_IsLively");
local get_body_updater_method = enemy_base_context_type_def:get_method("get_BodyUpdater");
local get_body_scale_method = enemy_base_context_type_def:get_method("get_BodyScale");

-- Ramon Salazar
local ch1_f6_z0_type_def = sdk.find_type_definition("chainsaw.Ch1f6z0Context");
local ch1_f6_z0_get_is_combat_ready_method = ch1_f6_z0_type_def:get_method("get_IsCombatReady");

local character_body_body_updater_type_def = get_body_updater_method:get_return_type();
local get_character_controller_method = character_body_body_updater_type_def:get_method("get_CharacterController");

local character_controller_type_def = get_character_controller_method:get_return_type();
local get_height_method = character_controller_type_def:get_method("get_Height");

local hit_point_type_def = get_hit_point_method:get_return_type();
local get_default_hit_point_method = hit_point_type_def:get_method("get_DefaultHitPoint");
local get_current_hit_point_method = hit_point_type_def:get_method("get_CurrentHitPoint");
local get_is_live_method = hit_point_type_def:get_method("get_IsLive");

local player_base_context_type_def = sdk.find_type_definition("chainsaw.PlayerBaseContext");
local get_player_position_method = player_base_context_type_def:get_method("get_Position");

local enemy_manager = sdk.find_type_definition("chainsaw.EnemyManager");
local notify_hit_damage_method = enemy_manager:get_method("notifyHitDamage");
local notify_dead_method = enemy_manager:get_method("notifyDead");

function this.get_vital_state_name(index)
	for state_name, state_index in pairs(this.vital_states) do
		if state_index == index then
			return state_name;
		end
	end

	return "None";
end

function this.new(enemy_context)
	local enemy = {};
	enemy.enemy_context = enemy_context;

	enemy.health = 0;
	enemy.max_health = 100;
	enemy.is_live = false;

	enemy.has_ray_to_player = false;

	enemy.position = Vector3f.new(0, 0, 0);
	enemy.distance = 0;
	enemy.height = 0;

	enemy.last_reset_time = 0;
	enemy.last_update_time = 0;

	enemy.body = nil;

	this.update_health(enemy);
	this.update_height(enemy);
	this.update_body_game_object(enemy);

	this.enemy_list[enemy_context] = enemy;

	return enemy;
end

function this.get_enemy(enemy_context)
	local enemy = this.enemy_list[enemy_context];
	if enemy == nil then
		enemy = this.new(enemy_context);
	end

	enemy.last_update_time = time.total_elapsed_script_seconds;
	
	return enemy;
end

function this.get_enemy_null(enemy_context, create_if_not_found)
	if create_if_not_found == nil then
		create_if_not_found = true;
	end

	local enemy = this.enemy_list[enemy_context];
	if enemy == nil and create_if_not_found then
		enemy = this.new(enemy_context);
	end
	
	return enemy;
end

function this.update_health(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.update_health] No Enemy";
		return;
	end

	local hit_point = get_hit_point_method:call(enemy.enemy_context);

	if hit_point == nil then
		customization_menu.status = "[enemy.update_health] No Enemy Hit Point";
		return;
	end

	local default_hit_point = get_default_hit_point_method:call(hit_point);
	local current_hit_point = get_current_hit_point_method:call(hit_point);
	local is_live = get_is_live_method:call(hit_point);

	if default_hit_point == nil then
		customization_menu.status = "[enemy.update_health] No Enemy Default Hit Point";
	else
		enemy.max_health = default_hit_point;
	end

	if current_hit_point == nil then
		customization_menu.status = "[enemy.update_health] No Enemy Current Hit Point";
	else
		enemy.health = current_hit_point;
	end

	if enemy.max_health == 0 then
		enemy.health_percentage = 0;
	else
		enemy.health_percentage = enemy.health / enemy.max_health;
	end

	if is_live == nil then
		customization_menu.status = "[enemy.update_health] No Enemy IsLive";
	else
		enemy.is_live = is_live;
	end
end

function this.update_has_ray_to_player(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.has_ray_to_player] No Enemy";
		return;
	end

	local has_ray_to_player = get_has_ray_to_player_method:call(enemy.enemy_context);

	if has_ray_to_player == nil then
		customization_menu.status = "[enemy.has_ray_to_player] No Enemy HasRayToPlayer";
		return;
	end

	enemy.has_ray_to_player = has_ray_to_player;
end

function this.update_last_reset_time(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.update_last_reset_time] No Enemy";
		return;
	end
	
	enemy.last_reset_time = time.total_elapsed_script_seconds;
end

function this.update_all_positions()
	for enemy_context, enemy in pairs(this.enemy_list) do
		this.update_position(enemy);
	end
end

function this.update_all_periodics()
	for enemy_context, enemy in pairs(this.enemy_list) do
		if config.current_config.settings.hide_if_no_update_function_is_being_called and time.total_elapsed_script_seconds - enemy.last_update_time > update_time_limit then
			this.enemy_list[enemy_context] = nil;
			goto continue;
		end

		this.update_has_ray_to_player(enemy);
		this.update_height(enemy);

		::continue::
	end
end

function this.update_position(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.update_position] No Enemy";
		return;
	end
	
	local position = get_position_method:call(enemy.enemy_context);

	if position == nil then
		customization_menu.status = "[enemy.update_position] No Enemy Position";
		return;
	end

	enemy.position = position;

	if player_handler.player.position == nil then
		customization_menu.status = "[enemy.update_position] No Player Position";
		return;
	end

	enemy.distance = (player_handler.player.position - position):length();
end

function this.update_body_game_object(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.update_body_game_object] No Enemy";
		return;
	end

	local body = get_body_game_object_method:call(enemy.enemy_context);
	if body == nil then
		customization_menu.status = "[enemy.update_body_game_object] No Enemy Body Game Object";
		return;
	end

	enemy.body = body;

	this.enemy_body_list[body] = enemy;
end

function this.update_height(enemy)
	if enemy == nil then
		customization_menu.status = "[enemy.update_height] No Enemy";
		return;
	end

	local body_updater = get_body_updater_method:call(enemy.enemy_context);
	if body_updater == nil then
		customization_menu.status = "[enemy.update_height] No Body Updater";
		return;
	end

	local character_controller = get_character_controller_method:call(body_updater);
	if character_controller == nil then
		customization_menu.status = "[enemy.update_height] No Character Controller";
		return;
	end

	local height = get_height_method:call(character_controller);
	if height == nil then
		customization_menu.status = "[enemy.update_height] No Height";
		return;
	end

	local body_scale = get_body_scale_method:call(enemy.enemy_context);
	if body_scale == nil then
		customization_menu.status = "[enemy.update_height] No Body Scale";
		enemy.height = height;
		return;
	end

	enemy.body_scale = body_scale;
	enemy.height = height * body_scale;
end

function this.draw_enemies()
	local cached_config = config.current_config;

	if gui_handler.game.current_active_input_level > 0 then
		return;
	end

	if not cached_config.settings.render_during_cutscenes and gui_handler.game.is_cutscene_playing then
		return;
	end

	if not cached_config.settings.render_when_hud_is_off and gui_handler.game.is_hud_off then
		return;
	end

	if not player_handler.player.is_aiming then
		if not cached_config.settings.render_when_normal then
			return;
		end
	elseif not player_handler.player.is_using_scope then
		if not cached_config.settings.render_when_aiming then
			return;
		end
	else
		if not cached_config.settings.render_when_using_scope then
			return;
		end
	end

	local max_distance = 0;
	if player_handler.player.is_using_scope then
		max_distance = cached_config.settings.scope_max_distance;
	else
		max_distance = cached_config.settings.max_distance;
	end

	for enemy_context, enemy in pairs(this.enemy_list) do
		if max_distance ~= 0 and enemy.distance > max_distance then
			goto continue;
		end

		local is_time_duration_on = false;

		if cached_config.settings.apply_time_duration_on_aiming
		or cached_config.settings.apply_time_duration_on_aim_target
		or cached_config.settings.apply_time_duration_on_using_scope
		or cached_config.settings.apply_time_duration_on_damage_dealt then
			if cached_config.settings.time_duration ~= 0 then
				if time.total_elapsed_script_seconds - enemy.last_reset_time > cached_config.settings.time_duration then
					goto continue;
				else
					is_time_duration_on = true;
				end
			end
		end

		if not cached_config.settings.render_aim_target_enemy and enemy.body == player_handler.player.aim_target_body and not is_time_duration_on then
			goto continue;
		end

		if not cached_config.settings.render_damaged_enemies and enemy.health ~= enemy.max_health and not is_time_duration_on then
			if enemy.body == player_handler.player.aim_target_body then
				if not cached_config.settings.render_aim_target_enemy then
					goto continue;
				end
			else
				goto continue;
			end
		end

		if not cached_config.settings.render_everyone_else and enemy.body ~= player_handler.player.aim_target_body and enemy.health == enemy.max_health and not is_time_duration_on then
			goto continue;
		end

		if cached_config.settings.hide_if_dead and not enemy.is_live then
			goto continue;
		end

		if cached_config.settings.hide_if_full_health and enemy.health == enemy.max_health then
			goto continue;
		end

		if cached_config.settings.hide_if_no_ray_to_player and not enemy.has_ray_to_player then
			goto continue;
		end

		local height_add = 0;
		if cached_config.settings.add_enemy_height_to_world_offset then
			height_add = enemy.height;
		end

		local world_offset = Vector3f.new(cached_config.world_offset.x, cached_config.world_offset.y + height_add, cached_config.world_offset.z);

		local position_on_screen = draw.world_to_screen(enemy.position + world_offset);
		if position_on_screen == nil then
			goto continue;
		end

		local opacity_scale = 1;
		if player_handler.player.is_using_scope then
			if cached_config.settings.scope_opacity_falloff and max_distance ~= 0 then
				opacity_scale = 1 - (enemy.distance / max_distance);
			end
		else
			if cached_config.settings.opacity_falloff and max_distance ~= 0 then
				opacity_scale = 1 - (enemy.distance / max_distance);
			end
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
end

function this.on_enemy_update(enemy_context)
	if enemy_context == nil then
		customization_menu.status = "[enemy.on_get_is_lively] No Enemy Context";
		return;
	end

	local enemy = this.get_enemy(enemy_context);
end

function this.on_notify_hit_damage(damage_info, enemy_context)
	local cached_config = config.current_config.settings;

	if damage_info == nil then
		customization_menu.status = "[enemy.on_notify_hit_damage] No Damage Info";
		--return;
	end
	
	if enemy_context == nil then
		customization_menu.status = "[enemy.on_notify_hit_damage] No Enemy Context";
		return;
	end

	local enemy = this.get_enemy(enemy_context);

	this.update_health(enemy);

	if cached_config.reset_time_duration_on_damage_dealt_for_everyone then
		for enemy_context, enemy in pairs(this.enemy_list) do
			if time.total_elapsed_script_seconds - enemy.last_reset_time < cached_config.time_duration then
				this.update_last_reset_time(enemy);
			end
		end
	end
	
	if cached_config.apply_time_duration_on_damage_dealt then
		this.update_last_reset_time(enemy);
	end
end

function this.on_notify_dead(damage_info, enemy_context)
	if damage_info == nil then
		customization_menu.status = "[enemy.on_notify_dead] No Damage Info";
		--return;
	end
	
	if enemy_context == nil then
		customization_menu.status = "[enemy.on_notify_dead] No Enemy Context";
		return;
	end

	local enemy = this.get_enemy(enemy_context);

	this.update_health(enemy);
	enemy.is_live = false;
end

function this.on_release(enemy_context)
	if enemy_context == nil then
		customization_menu.status = "[enemy.on_release] No Enemy Context";
		return;
	end

	this.enemy_list[enemy_context] = nil;
end

function this.init_module()
	utils = require("Health_Bars.utils");
	config = require("Health_Bars.config");
	singletons = require("Health_Bars.singletons");
	drawing = require("Health_Bars.drawing");
	customization_menu = require("Health_Bars.customization_menu");
	player_handler = require("Health_Bars.player_handler");
	gui_handler = require("Health_Bars.gui_handler");
	time = require("Health_Bars.time");

	sdk.hook(ch1_f6_z0_get_is_combat_ready_method, function(args)
		local enemy_context = sdk.to_managed_object(args[2]);
		this.on_enemy_update(enemy_context);
	end, function(retval)
		return retval;
	end);

	sdk.hook(get_is_lively_method, function(args)
		local enemy_context = sdk.to_managed_object(args[2]);
		this.on_enemy_update(enemy_context);
	end, function(retval)
		return retval;
	end);
	
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

	sdk.hook(release_method, function(args)
		local enemy_context = sdk.to_managed_object(args[2]);
		
		this.on_release(enemy_context);
	end, function(retval)
		return retval;
	end);
end

return this;