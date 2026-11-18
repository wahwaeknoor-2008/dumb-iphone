# OFFGRID — Dumb iPhone

OFFGRID is an iOS app that helps make an iPhone less distracting by letting you choose the apps and websites you want to keep available, then shield everything else during focused modes.

## Current MVP

- SwiftUI dashboard with Open, Dumb, and Work modes.
- Individual Screen Time authorization using Apple's FamilyControls framework.
- Allow-list selection with Apple's FamilyActivityPicker, including apps, websites, and categories.
- An in-app essentials checklist to help prepare a starter keep list (Phone, Messages, Maps, Calendar, Camera, Photos, Wallet, Music, Mail, Notes, Passwords, Authenticator, Banking, Transit, School/Work, and Reminders).
- ManagedSettings shields all other app and website categories while Dumb or Work mode is active, except the user's selected items.
- Saves the selected activity and last mode locally on the device.

## Requirements

- macOS with Xcode 15 or later recommended.
- iOS 16.0 or later.
- An Apple ID signed into Xcode for device testing.
- Family Controls capability and the required Apple entitlement for real device shielding.

## Open in Xcode

1. Clone or download this repository.
2. Open `OFFGRID.xcodeproj`.
3. Select the OFFGRID target, then **Signing & Capabilities**.
4. Select your development Team and make the Bundle Identifier unique to your Apple Developer account.
5. Confirm the **Family Controls** capability is available and enabled. The project includes `OFFGRID/OFFGRID.entitlements`; Apple approval may be required for the entitlement, especially for distribution.
6. Select your iPhone as the run destination and press Run.

## Important iOS limitations

OFFGRID is not a replacement Home Screen or a system-wide launcher. iOS does not let an ordinary third-party app remove other apps from the Home Screen or prevent every possible route to them. This MVP uses Apple's Screen Time APIs to keep selected apps and websites available and shield the rest while a restrictive OFFGRID mode is active. Add essentials such as Phone, Messages, Maps, and Settings to the keep list before activating.

The Open mode removes OFFGRID's shields. Dumb and Work currently use the same keep list. The person can switch back to Open mode inside OFFGRID. The suggested essentials checklist is a guide only; actual app allow-list entries must be selected in Apple's picker on the physical device. The iOS Simulator may show categories but no individual apps. Later iterations can add separate lists, schedules, onboarding, and more detailed usage reporting.

## Project layout

```
OFFGRID/
├── OFFGRID.xcodeproj/
└── OFFGRID/
    ├── OFFGRIDApp.swift
    ├── ContentView.swift
    ├── AppSelectionSheet.swift
    ├── FocusManager.swift
    ├── FocusMode.swift
    └── OFFGRID.entitlements
```

## Privacy

The selected app and website tokens are stored locally using UserDefaults. OFFGRID does not send selection data to a server.
