# ShooterX Redesign — Flutter Files

## What's in this folder

Drop-in Flutter/Dart replacements for every screen, matching the new prototype design exactly.

---

## File Structure

```
lib_redesign/
├── flutter_flow/
│   └── flutter_flow_theme.dart        ← Updated colours (dark mode)
├── components/
│   └── sx_shared_widgets.dart         ← All reusable components
├── pages/
│   ├── onboarding/
│   │   └── onboarding_widget.dart     ← Splash + welcome + auth sheet
│   ├── home_page/
│   │   └── home_page_widget.dart
│   ├── activity/
│   │   └── activity_widget.dart
│   ├── clubs/
│   │   └── clubs_widget.dart
│   ├── community/
│   │   └── community_widget.dart
│   ├── training/
│   │   └── training_widget.dart
│   ├── session_summary/
│   │   └── session_summary_widget.dart
│   ├── club_profile/
│   │   └── club_profile_widget.dart   ← Feed / Events / Members / About tabs
│   ├── record_shoot/                  ← NEW
│   │   └── record_shoot_widget.dart
│   ├── scan_target/                   ← NEW
│   │   └── scan_target_widget.dart
│   ├── find_range/                    ← NEW
│   │   └── find_range_widget.dart
│   ├── leaderboard/                   ← NEW
│   │   └── leaderboard_widget.dart
│   ├── notifications/                 ← NEW
│   │   └── notifications_widget.dart
│   └── all_sessions/                  ← NEW
│       └── all_sessions_widget.dart
└── NAV_ADDITIONS.dart                 ← Routes + imports to add to nav.dart
```

---

## How to apply

### Step 1 — Copy files
Copy each file from `lib_redesign/` into the matching path under `lib/` in your project.
The folder structure mirrors your existing project exactly.

### Step 2 — Update theme
Replace `lib/flutter_flow/flutter_flow_theme.dart` with the new version.
**Key changes in DarkModeTheme:**
- `primary`: `#3DD162` (was `#00A224`)
- `primaryBackground`: `#0D0D0D` (was `#111111`)
- `secondaryBackground`: `#1C1C1E` (was `#1B1B1B`)
- `alternate`: `#272729` (was `#000000`)

### Step 3 — Add shared components
Copy `lib_redesign/components/sx_shared_widgets.dart` into `lib/components/`.

### Step 4 — Add new pages
For each new page folder (`record_shoot`, `scan_target`, `find_range`,
`leaderboard`, `notifications`, `all_sessions`), create the matching folder
under `lib/pages/` and copy the widget file in.

### Step 5 — Register new routes
Open `lib/flutter_flow/nav/nav.dart` and:
1. Add the 6 import statements from `NAV_ADDITIONS.dart`
2. Add the 6 FFRoute entries into the `routes: [...]` list

### Step 6 — Update index.dart
Add the 6 export lines from `NAV_ADDITIONS.dart` to `lib/index.dart`.

### Step 7 — Run
```bash
flutter pub get
flutter run
```

---

## Notes

- All Supabase queries have `// TODO:` comments where real data should be wired in.
  The widgets use static sample data so they compile and run immediately.
- `FindRangeWidget` uses a `CustomPaint` map placeholder. In production swap for
  `flutter_map` + `latlong2` (add to `pubspec.yaml`).
- `ScanTargetWidget` uses a simulated scan. In production wire in `camera` or
  `image_picker` for real target analysis.
- The `_SXLogoSVG` in `onboarding_widget.dart` draws an approximate logo via
  `CustomPaint`. Swap with `flutter_svg` + your actual `assets/images/` SVG for
  pixel-perfect fidelity.
- All navigation uses `context.pushNamed()` / `context.goNamed()` via go_router,
  consistent with your existing codebase.
