#!/bin/zsh
set -u
set -o pipefail

ROOT="${0:A:h}"
brightness_status=0

# Native macOS trackpad preferences.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
killall cfprefsd 2>/dev/null || true

"$ROOT/Brightness/Install.command" || brightness_status=$?

echo
echo "Installation summary"
echo "Trackpad preferences: installed"
echo "Safe brightness overlay: $([[ $brightness_status -eq 0 ]] && echo installed || echo failed)"
echo "Power and sleep settings: unchanged"

exit $brightness_status
