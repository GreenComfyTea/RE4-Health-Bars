local this = {};

local utils;

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

this.current_config = nil;
this.config_file_name = "Health Bars/config.json";

this.default_config = {};

function this.init()
	this.default_config = {
		enabled = true,

		settings = {
			use_d2d_if_available = true,
			hide_if_dead = true,
			hide_if_no_ray_to_player = true,
			opacity_falloff = true,
			max_distance = 30
		},

		world_offset = {
			x = 0,
			y = 1.85,
			z = 0
		},

		health_value_label = {
			visibility = true,

			settings = {
				right_alignment_shift = 11
			},

			include = {
				current_value = true,
				max_value = true
			},

			text_format = "%s", -- current_health/max_health

			offset = {
				x = -15,
				y = 0
			},
			
			color = 0xB9F7B9B9,

			shadow = {
				visibility = true,
				offset = {
					x = 1,
					y = 1
				},
				color = 0xFF000000
			}
		},

		health_bar = {
			visibility = true,

			settings = {
				fill_direction = "Left to Right"
			},

			offset = {
				x = -75,
				y = 0
			},

			size = {
				width = 150,
				height = 8
			},

			outline = {
				visibility = true,
				thickness = 1.5,
				offset = 0,
				style = "Center"
			},

			colors = {
				foreground = 0xB9A1FFBA,
				background = 0xB9000000,
				outline = 0xC0918E89
			}
		}
	};
end

function this.load()
	local loaded_config = json.load_file(this.config_file_name);
	if loaded_config ~= nil then
		log.info("[Health Bars] config.json loaded successfully");
		this.current_config = utils.table_merge(this.default_config, loaded_config);
	else
		log.error("[Health Bars] Failed to load config.json");
		this.current_config = utils.table_deep_copy(this.default_config);
	end
end

function this.save()
	-- save current config to disk, replacing any existing file
	local success = json.dump_file(this.config_file_name, this.current_config);
	if success then
		log.info("[Health Bars] config.json saved successfully");
	else
		log.error("[Health Bars] Failed to save config.json");
	end
end

function this.init_module()
	utils = require("Health_Bars.utils");

	this.init();
	this.load();
	this.current_config.version = "1.0";
end

return this;
