local Device(vendor_id, product_id, is_keyboard, is_pointing_device) = {
  identifiers: {
    is_keyboard: is_keyboard,
    is_pointing_device: is_pointing_device,
    product_id: product_id,
    vendor_id: vendor_id,
  },
  ignore: false,
  disable_built_in_keyboard_if_exists: false,
  manipulate_caps_lock_led: false,
  fn_function_keys: [],
  simple_modifications: [],
};

local devices = [
  Device(1204, 4621, true, false) + { manipulate_caps_lock_led: true },  // Majestouch Convertible 2
  Device(2652, 34050, true, false),
  Device(1133, 50489, true, false),  // Logitech GPW
  Device(1133, 50489, false, true),  // Logitech GPW
  Device(1452, 272, true, true) + { manipulate_caps_lock_led: true },  // NIZ 84 BT5.0
];

local device_NIZ = {
  description: 'NIZ 84 BT5.0',
  vendor_id: 1452,
  product_id: 272,
};

local condition_device_unless_NIZ = {
  type: 'device_unless',
  identifiers: [device_NIZ],
};

local rule_swap_command_and_option = {
  local ChangeTo(from, to) = {
    type: 'basic',
    description: '%s to %s' % [from, to],
    conditions: [condition_device_unless_NIZ],
    from: {
      key_code: from,
      modifiers: {
        optional: ['any'],
      },
    },
    to: [
      {
        key_code: to,
      },
    ],
  },
  description: 'Swap Command and Option',
  manipulators: [
    ChangeTo('left_command', 'left_option'),
    ChangeTo('left_option', 'left_command'),
    ChangeTo('right_command', 'right_option'),
    ChangeTo('right_option', 'right_command'),
  ],
};

local rule_ensure_input_source_rime = {
  description: 'Ensure input source [Rime]',
  manipulators: [
    {
      type: 'basic',
      parameters: {
        'basic.to_if_held_down_threshold_milliseconds': 1500,
      },
      from: {
        key_code: 'left_control',
      },
      to: [
        {
          key_code: 'left_control',
        },
      ],
      to_if_held_down: [
        {
          select_input_source: {
            input_source_id: 'Rime',
          },
        },
      ],
    },
  ],
};

local rule_vim = {
  local ChangeToWithControl(from, to, from_lable=from, to_lable=to) = {
    type: 'basic',
    description: 'control + %s to %s' % [from_lable, to_lable],
    from: {
      key_code: from,
      modifiers: {
        mandatory: [
          'control',
        ],
      },
    },
    to: [
      {
        key_code: to,
      },
    ],
  },
  description: 'Vim',
  manipulators: [
    ChangeToWithControl('open_bracket', 'escape', from_lable='[', to_lable='Esc'),
    ChangeToWithControl('m', 'return_or_enter', to_lable='Enter'),
    ChangeToWithControl('j', 'down_arrow', to_lable='Down'),
    ChangeToWithControl('k', 'up_arrow', to_lable='Up'),
  ],
};

local profile = {
  name: 'MuXiu1997',
  parameters: {
    delay_milliseconds_before_open_device: 1000,
  },
  selected: false,
  simple_modifications: [],
  virtual_hid_keyboard: {
    country_code: 0,
    indicate_sticky_modifier_keys_state: true,
    mouse_key_xy_scale: 100,
  },
  devices: devices,
  complex_modifications: {
    parameters: {
      'basic.simultaneous_threshold_milliseconds': 50,
      'basic.to_delayed_action_delay_milliseconds': 500,
      'basic.to_if_alone_timeout_milliseconds': 1000,
      'basic.to_if_held_down_threshold_milliseconds': 500,
      'mouse_motion_to_scroll.speed': 100,
    },
    rules: [
      rule_swap_command_and_option,
      rule_ensure_input_source_rime,
      rule_vim,
    ],
  },
};

local global = {
  check_for_updates_on_startup: true,
  show_in_menu_bar: true,
  show_profile_name_in_menu_bar: false,
};


{
  global: global,
  profiles: [profile],
}
