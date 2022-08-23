// region Devices
interface Device {
  identifiers: {
    readonly vendor_id: number
    readonly product_id: number
    readonly is_keyboard: boolean
    readonly is_pointing_device: boolean
  }
  ignore: boolean
  disable_built_in_keyboard_if_exists: boolean
  manipulate_caps_lock_led: boolean
  fn_function_keys: []
  simple_modifications: []
}

function defineDevice(
  vendor_id: number,
  product_id: number,
  is_keyboard: boolean,
  is_pointing_device: boolean,
  callback: (device: Device) => void = () => {
  },
): Device {
  const device: Device = {
    identifiers: {
      vendor_id,
      product_id,
      is_keyboard,
      is_pointing_device,
    },
    ignore: false,
    disable_built_in_keyboard_if_exists: false,
    manipulate_caps_lock_led: false,
    fn_function_keys: [],
    simple_modifications: [],
  }
  callback(device)
  return device
}

const deviceAppleInternalTrackpad = defineDevice(
  1452,
  835,
  false,
  true,
  (d) => d.ignore = true,
)

const deviceAppleInternalKeyboard = defineDevice(
  1452,
  835,
  true,
  false,
)

const deviceAppleMagicTrackpad = defineDevice(
  76,
  613,
  false,
  true,
  (d) => d.ignore = true,
)

const deviceAppleMagicTrackpadUSB = defineDevice(
  1452,
  613,
  false,
  true,
  (d) => d.ignore = true,
)

const deviceMajestouchConvertible2 = defineDevice(
  1204,
  4621,
  true,
  false,
  (d) => d.manipulate_caps_lock_led = true,
)

const deviceLogitechGPWKeyboard = defineDevice(
  1133,
  50489,
  true,
  false,
)

const deviceLogitechGPWPoint = defineDevice(
  1133,
  50489,
  false,
  true,
)

const deviceNIZ84BT5_0 = defineDevice(
  1452,
  272,
  true,
  true,
  (d) => d.manipulate_caps_lock_led = true,
)

const deviceNIZ84USBKeyboard = defineDevice(
  1155,
  20777,
  true,
  false,
  (d) => d.manipulate_caps_lock_led = true,
)

const deviceNIZ84USBKeyboardAndPoint = defineDevice(
  1155,
  20777,
  true,
  true,
  (d) => d.manipulate_caps_lock_led = true,
)

const devices = [
  deviceAppleInternalTrackpad,
  deviceAppleInternalKeyboard,
  deviceAppleMagicTrackpad,
  deviceAppleMagicTrackpadUSB,
  deviceMajestouchConvertible2,
  deviceLogitechGPWKeyboard,
  deviceLogitechGPWPoint,
  deviceNIZ84BT5_0,
  deviceNIZ84USBKeyboard,
  deviceNIZ84USBKeyboardAndPoint,
]
// endregion Devices

// region Rules
const ruleSwapFnAndControl = {
  description: 'Swap Fn and Control',
  manipulators: [
    {
      type: 'basic',
      description: `fn to control`,
      conditions: [{
        type: 'device_if',
        identifiers: [
          deviceAppleInternalKeyboard,
        ].map((d) => d.identifiers),
      }],
      from: {
        apple_vendor_top_case_key_code: 'keyboard_fn',
        modifiers: {
          optional: ['any'],
        },
      },
      to: [
        {
          key_code: 'left_control',
        },
      ],
    },
    {
      type: 'basic',
      description: `control to fn`,
      conditions: [{
        type: 'device_if',
        identifiers: [
          deviceAppleInternalKeyboard,
        ].map((d) => d.identifiers),
      }],
      from: {
        key_code: 'left_control',
        modifiers: {
          optional: ['any'],
        },
      },
      to: [
        {
          apple_vendor_top_case_key_code: 'keyboard_fn',
        },
      ],
    },
  ]
}

const ruleSwapCommandAndOption = (() => {
  function $changeTo(from: string, to: string) {
    return {
      type: 'basic',
      description: `${from} to ${to}`,
      conditions: [{
        type: 'device_unless',
        identifiers: [
          deviceAppleInternalKeyboard,
          deviceNIZ84BT5_0,
          deviceNIZ84USBKeyboard,
          deviceNIZ84USBKeyboardAndPoint,
        ].map((d) => d.identifiers),
      }],
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
    }
  }

  return {
    description: 'Swap Command and Option',
    manipulators: [
      $changeTo('left_command', 'left_option'),
      $changeTo('left_option', 'left_command'),
      $changeTo('right_command', 'right_option'),
      $changeTo('right_option', 'right_command'),
    ],
  }
})()

const ruleEnsureInputSourceRime = {
  description: 'Ensure input source [Rime]',
  manipulators: [
    {
      type: 'basic',
      parameters: {
        'basic.to_if_held_down_threshold_milliseconds': 750,
      },
      from: {
        key_code: 'left_shift',
      },
      to: [
        {
          key_code: 'left_shift',
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
}

const ruleVim = (() => {
  function $changeToWithControl(from: string, to: string) {
    return {
      type: 'basic',
      description: `control + ${from} to ${to}`,
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
    }
  }

  return {
    description: 'Vim',
    manipulators: [
      $changeToWithControl('open_bracket', 'escape'),
      $changeToWithControl('m', 'return_or_enter'),
      $changeToWithControl('j', 'down_arrow'),
      $changeToWithControl('k', 'up_arrow'),
    ],
  }
})()

const rules = [
  ruleSwapFnAndControl,
  ruleSwapCommandAndOption,
  ruleEnsureInputSourceRime,
  ruleVim,
]
// endregion Rules

const global = {
  check_for_updates_on_startup: true,
  show_in_menu_bar: true,
  show_profile_name_in_menu_bar: false,
}

const profile = {
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
  devices,
  complex_modifications: {
    parameters: {
      'basic.simultaneous_threshold_milliseconds': 50,
      'basic.to_delayed_action_delay_milliseconds': 500,
      'basic.to_if_alone_timeout_milliseconds': 1000,
      'basic.to_if_held_down_threshold_milliseconds': 500,
      'mouse_motion_to_scroll.speed': 100,
    },
    rules,
  },
}

console.log(JSON.stringify(
  {
    global,
    profiles: [profile],
  },
  null,
  4,
))
