# Trundle

Trundle is a physics puzzle and platform game for iPhone and iPad, originally
created by Mobile Bros. Guide a small gear character through shadow landscapes by
tilting the device to move and tapping to jump.

This release combines the original editions into one universal app, **Trundle ∞**.
All three packs and ten released levels are included. Artwork, level XML
variants, and gameplay sizing adapt to iPhone or iPad at runtime. The game plays
in landscape and preserves the original level proportions on newer screens.

## Build and run

You need macOS and Xcode with an iOS SDK and simulator runtime installed.
The project has been verified with Xcode 26.2. The app's deployment target is
**iOS 15.6**.

1. Open `Trundle.xcodeproj` in Xcode.
2. Select the shared **Trundle ∞** scheme and an iPhone or iPad simulator.
3. Build and run.

On a simulator, drag the on-screen joystick to move and tap to jump.
The dependencies are vendored in this repository; no package installation or
submodules are required.

To build for the simulator from the command line without signing credentials:

```sh
xcodebuild -project Trundle.xcodeproj -scheme 'Trundle ∞' \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/trundle-build CODE_SIGNING_ALLOWED=NO build
```

## Tests

The individual regressions require Python 3 and Xcode's command-line tools.
Run simulator regressions against an already booted simulator using its UUID:

```sh
sh Tests/run-static-floor.sh
python3 Tests/run-room-physics.py <simulator-UUID> --universal
python3 Tests/run-room-physics.py <simulator-UUID> --level-actions
python3 Tests/run-room-physics.py <simulator-UUID> --gameplay-rendering
python3 Tests/run-room-physics.py <simulator-UUID> --spotlight-rendering
```

The simulator suite has been exercised on Apple Silicon.

## Project layout

- `Base Source/`: application lifecycle, scenes, menus, and saved game state.
- `Game Source/`: gameplay, objects, effects, and shared device settings.
- `Game Resources/`: level XML, artwork, sound effects, music, and audio projects.
- `Support/`: XML loaders, controls, actions, and the SpaceManager physics wrapper.
- `External Source/`: vendored cocos2d, Chipmunk, CocosDenshion, and Kazmath.
- `Tests/`: native and simulator regressions.

## Maintenance notes

This is a modernized legacy Objective-C game using cocos2d 2.1.0 and OpenGL ES.
The engine still emits deprecation warnings. Automated checks do not verify
physical-device tilt input, audible sound, or every playable room.

The old purchases, leaderboard/networking integration, and iSimulate binary have
been removed. All released content is available locally.

## Licenses

- Original code, level/menu XML, and documentation: [MIT](LICENSE-MIT.txt).
- Original images and audio: [CC BY 4.0](LICENSE-CC-BY-4.0.txt), attributed to
  **Mobile Bros. — Trundle**.
- Vendored components: their respective licenses, listed in
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

See [LICENSE.md](LICENSE.md) for the scope of each license.
