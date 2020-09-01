require "util"

function contains(array, element, remove)
  for i, value in pairs(array) do
    if value == element then
      if remove then table.remove(array, i) end
      return true
    end
  end
  return false
end

function contains_key(array, element, remove)
  for key, _ in pairs(array) do
    if key == element then
      if remove then table.remove(array, key) end
      return true
    end
  end
  return false
end

local on_spidertron_given_new_destination = script.generate_event_name()
remote.add_interface("SpidertronWaypoints", {get_event_ids = function() return {on_spidertron_given_new_destination = on_spidertron_given_new_destination} end})


function get_waypoint_info(spidertron)
  local waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  if not waypoint_info then
    global.spidertron_waypoints[spidertron.unit_number] = {spidertron = spidertron, positions = {}, render_ids = {}}  -- Entity, list of positions, list of render ids
    waypoint_info = global.spidertron_waypoints[spidertron.unit_number]
  end
  return waypoint_info
end

function clear_spidertron_waypoints(spidertron, unit_number)
  -- Called on Shift-Click or whenever the current autopilot_destination is removed or when the spidertron is removed.
  local waypoint_info
  if spidertron then
    waypoint_info = get_waypoint_info(spidertron)
  else
    waypoint_info = global.spidertron_waypoints[unit_number]
    if not waypoint_info then return end
  end
  if not unit_number then unit_number = spidertron.unit_number end
  log("Clearing spidertron waypoints for unit number " .. unit_number)
  for i, render_id in pairs(waypoint_info.render_ids) do
    rendering.destroy(render_id)
  end
  if spidertron then spidertron.autopilot_destination = nil end
  global.spidertron_waypoints[unit_number] = nil
end

script.on_event("clear-spidertron-waypoints",
  function(event)
    local player = game.get_player(event.player_index)
    if player.cursor_stack.valid_for_read and player.cursor_stack.type == "spidertron-remote" then
      local remote = player.cursor_stack
      local spidertron = remote.connected_entity
      if spidertron then
        clear_spidertron_waypoints(spidertron)
      end
    end
  end
)
--script.on_event(player)

function update_text(spidertron)
  -- Updates numbered text on ground for given spidertron
  local waypoint_info = get_waypoint_info(spidertron)
  -- Re-render all waypoints
  for i, position in pairs(waypoint_info.positions) do
    local render_id = waypoint_info.render_ids[i]
    if render_id and rendering.is_valid(render_id) then
        if rendering.get_text(render_id) ~= i then
          -- Only update text
          rendering.set_text(render_id, i)
        end
    else
      -- We need to create the text
      waypoint_info.render_ids[i] = rendering.draw_text{text = tostring(i), surface = spidertron.surface, target = {position.x, position.y - 1.2}, color = spidertron.color, scale = 4, alignment = "center", time_to_live = 99999999}
    end
  end
end

require 'patrol'
script.on_event(defines.events.on_player_used_spider_remote,
  function(event)
    local player = game.get_player(event.player_index)
    local spidertron = event.vehicle
    local position = event.position
    local waypoint_info = get_waypoint_info(spidertron)
    local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]

    if not event.success then return end
    local reg_id = script.register_on_entity_destroyed(spidertron)
    global.registered_spidertrons[reg_id] = spidertron.unit_number

    if not player.is_shortcut_toggled("waypoints-patrol-mode") then
      if on_patrol or not player.is_shortcut_toggled("waypoints-waypoint-mode") then
        -- Clear all waypoints if we were previously patrolling or waypoints are off
        clear_spidertron_waypoints(nil, spidertron.unit_number)  -- Prevents it from overwriting autopilot_destination
        waypoint_info = get_waypoint_info(spidertron)
        global.spidertron_on_patrol[spidertron.unit_number] = nil
      end
      if #waypoint_info.positions > 0 or util.distance(spidertron.position, spidertron.autopilot_destination) > 5 then
        -- The spidertron has to be a suitable distance away, but only if this is the first (i.e. next) waypoint
        log("Player used remote on position " .. util.positiontostr(position))
        table.insert(waypoint_info.positions, position)
        --table.insert(waypoint_info.render_ids, false)  -- Will be handled by update_text
        spidertron.autopilot_destination = waypoint_info.positions[1]
        if #waypoint_info.positions == 1 then
          -- The spidertron was not already walking towards a waypoint
          script.raise_event(on_spidertron_given_new_destination, {player_index = 1, vehicle = spidertron, position = waypoint_info.positions[1], success = true})
        end
        update_text(spidertron)
      end

    else
      on_player_used_patrol_remote(player, spidertron, position)
    end
  end
)


function on_spidertron_reached_destination(spidertron, patrol_start)
  local waypoint_info = get_waypoint_info(spidertron)
  local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]
  log("Spidertron reached destination at " .. util.positiontostr(waypoint_info.positions[1]))
  local removed_position
  if not patrol_start then
    removed_position = table.remove(waypoint_info.positions, 1)
  end

  if #waypoint_info.positions > 0 then
    if util.distance(spidertron.position, waypoint_info.positions[1]) > 5 then  -- Remove all lines like this in 1.1
      spidertron.autopilot_destination = waypoint_info.positions[1]
      -- The spidertron is now walking towards a new waypoint
      script.raise_event(on_spidertron_given_new_destination, {player_index = 1, vehicle = spidertron, position = waypoint_info.positions[1], success = true})
    end
  end

  if on_patrol and not patrol_start then
    -- Add reached position to the back of the queue
    table.insert(waypoint_info.positions, removed_position)
  elseif not on_patrol then
    local render_id = table.remove(waypoint_info.render_ids, 1)
    rendering.destroy(render_id)
  end
  update_text(spidertron)
end


script.on_nth_tick(10,
  function(event)
    for _, waypoint_info in pairs(global.spidertron_waypoints) do
      local spidertron = waypoint_info.spidertron
      local waypoint_queue = waypoint_info.positions
      if spidertron and spidertron.valid then
        local on_patrol = global.spidertron_on_patrol[spidertron.unit_number]
        if #waypoint_queue > 0 then
          -- Check if we have arrived
          if util.distance(spidertron.position, waypoint_queue[1]) < 2 then
            -- The spidertron has reached its destination
            on_spidertron_reached_destination(spidertron)

          -- Check if we need to clear the queue because something has cancelled the current autopilot_destination
          -- Note that queue is only cleared when not within 2 tiles of destination
          elseif on_patrol ~= "setup" and not spidertron.autopilot_destination then
            clear_spidertron_waypoints(spidertron)
          end
        end
      end
    end
  end
)

script.on_event(defines.events.on_entity_destroyed,
  function(event)
    local unit_number = event.unit_number
    local reg_id = event.registration_number
    log("Entity destroyed with unit number " .. unit_number)
    if contains_key(global.registered_spidertrons, reg_id, true) then
      log("Clearing spidertron waypoints")
      clear_spidertron_waypoints(nil, unit_number)
      global.spidertron_on_patrol[unit_number] = nil
    end
  end
)


local function setup()
    global.spidertron_waypoints = {}
    global.spidertron_on_patrol = {}
    global.registered_spidertrons = {}
    global.stored_remotes = {}
  end

local function config_changed_setup(changed_data)
  -- Only run when this mod was present in the previous save as well. Otherwise, on_init will run.
  local mod_changes = changed_data.mod_changes
  local old_version
  if mod_changes and mod_changes["SpidertronWaypoints"] and mod_changes["SpidertronWaypoints"]["old_version"] then
    old_version = mod_changes["SpidertronWaypoints"]["old_version"]
  else
    return
  end

  log("Coming from old version: " .. old_version)
  old_version = util.split(old_version, ".")
  for i=1,#old_version do
    old_version[i] = tonumber(old_version[i])
  end

  if old_version[1] == 1 then
    if old_version[2] < 1 then
      -- Run in >=1.1
      global.spidertron_on_patrol = {}
    end
    if old_version[2] < 2 then
      log("Running pre 1.2 migration")
      -- Run in >=1.2
      global.registered_spidertrons = {}
      -- Clean up 1.1 bug
      rendering.clear("SpidertronWaypoints")
    end
    if old_version[2] < 4 then
      --Run in >=1.3.0
      global.stored_remotes = {}
    end
  end
end

script.on_init(setup)
script.on_configuration_changed(config_changed_setup)
