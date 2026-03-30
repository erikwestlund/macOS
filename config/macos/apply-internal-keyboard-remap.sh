#!/bin/sh

/usr/bin/hidutil property \
  --matching '{"Product":"Apple Internal Keyboard / Trackpad","Built-In":true}' \
  --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771328}]}'
