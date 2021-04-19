-- Mode selection
local direct_control = {
  type = "custom-input",
  name = "waypoints-go-to-direct-mode",
  key_sequence = "SHIFT + F",
  order = "ca"
}
local waypoint_control = {
  type = "custom-input",
  name = "waypoints-go-to-waypoint-mode",
  key_sequence = "SHIFT + C",
  order = "cb"
}
local patrol_control = {
  type = "custom-input",
  name = "waypoints-go-to-patrol-mode",
  key_sequence = "SHIFT + X",
  order = "cc"
}
data:extend{direct_control, waypoint_control, patrol_control}


-- Mode scrolling
local scroll_forwards = {
  type = "custom-input",
  name = "waypoints-mode-scroll-forwards",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-forwards"
}
local scroll_backwards = {
  type = "custom-input",
  name = "waypoints-mode-scroll-backwards",
  key_sequence = "",
  linked_game_control = "cycle-blueprint-backwards"
}
local scroll_forwards_key = {
  type = "custom-input",
  name = "waypoints-mode-scroll-forwards-key",
  key_sequence = "KP_MINUS",
  order="ba"
}
local scroll_backwards_key = {
  type = "custom-input",
  name = "waypoints-mode-scroll-backwards-key",
  key_sequence = "KP_PLUS",
  order="bb"
}
data:extend{scroll_forwards, scroll_backwards, scroll_forwards_key, scroll_backwards_key}


-- Misc inputs
local clear_waypoints_key = {
  type = "custom-input",
  name = "clear-spidertron-waypoints",
  key_sequence = "SHIFT + mouse-button-1",
  consuming = "none",
  order = "aa"
}
local disconnect_remote_key = {
  type = "custom-input",
  name = "waypoints-disconnect-remote",
  key_sequence = "SHIFT + mouse-button-2",
  consuming = "none",
  order = "ab"
}
local complete_patrol_key = {
  type = "custom-input",
  name = "waypoints-complete-patrol",
  key_sequence = "ALT + mouse-button-1",
  consuming = "none",
  order = "ac"
}
local change_wait_time_key = {
  type = "custom-input",
  name = "waypoints-change-wait-conditions",
  key_sequence = "Y",
  consuming = "none",
  order = "ad"
}
local change_default_wait_time_key = {
  type = "custom-input",
  name = "waypoints-change-default-wait-conditions",
  key_sequence = "SHIFT + Y",
  consuming = "none",
  order = "ae"
}
local confirm_gui_key = {
  type = "custom-input",
  name = "waypoints-gui-confirm",
  key_sequence = "",
  linked_game_control = "confirm-gui"
}
data:extend{clear_waypoints_key, disconnect_remote_key, complete_patrol_key, change_wait_time_key, change_default_wait_time_key, confirm_gui_key}

-- Allows getting movement control events to detect when to cancel a spidertron's waypoints
data:extend{
  {
    type = "custom-input",
    name = "move-right-custom",
    key_sequence = "",
    linked_game_control = "move-right"
  },
  {
    type = "custom-input",
    name = "move-left-custom",
    key_sequence = "",
    linked_game_control = "move-left"
  },
  {
    type = "custom-input",
    name = "move-up-custom",
    key_sequence = "",
    linked_game_control = "move-up"
  },
  {
    type = "custom-input",
    name = "move-down-custom",
    key_sequence = "",
    linked_game_control = "move-down"
  }
}