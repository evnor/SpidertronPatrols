-- Misc inputs
data:extend{
  {
    type = "custom-input",
    name = "sp-replace-previous-waypoint",
    key_sequence = "SHIFT + mouse-button-1",
    consuming = "none",
    order = "a"
  },
  {
    type = "custom-input",
    name = "sp-delete-all-waypoints",
    key_sequence = "CONTROL + mouse-button-2",
    consuming = "none",
    order = "b"
  },
  {
    type = "custom-input",
    name = "sp-confirm-gui",
    key_sequence = "",
    linked_game_control = "confirm-gui"
  }
}

-- Allows getting movement control events to detect when to turn on 'manual' mode
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
