# ANEDU 2.0 – Assets Registry & Mapping Specification

This document maps all asset paths, filenames, and animation states. The Flutter application loads these assets dynamically by resolving file paths matching the `lesson.id` or `mittuState` inside database models.

---

## 1. Directory Structure

```yaml
assets/
├── images/
│   └── situations/
│       ├── basics_1.png         # Meeting Mittu / General intro
│       ├── greetings_1.png      # Apartment elevator greeting
│       ├── introductions_1.png  # Self-introduction card
│       ├── travel_1.png         # Auto rickshaw ride
│       ├── restaurant_1.png     # Coffee & Dosa ordering
│       ├── shopping_1.png       # Paying via UPI at supermarket
│       ├── college_1.png        # Attendance & classroom scene
│       ├── workplace_1.png      # Colleague chat at cafeteria
│       └── emergency_1.png      # Calling for medical/police help
└── animations/
    └── mittu/
        ├── idle.json            # Breathing, blinking idle loop
        ├── wave.json            # Welcome splash / home mascot
        ├── walk.json            # Progress markers on journey map
        ├── think.json           # Word match & builder step helper
        ├── success.json         # Correct quiz / match confetti celebration
        └── fail.json            # Incorrect quiz choice / sad state
```

---

## 2. Programmatic Asset Mapper

To link these assets dynamically to code without hardcoding, the app utilizes an Asset registry resolver.

### Model Integration (`lib/models/lesson.dart`)
Add an `illustrationPath` getter resolving automatically from the lesson identifier:

```dart
String get illustrationPath => 'assets/images/situations/${id}.png';
```

### Mascot State Resolver (`lib/core/widgets/mittu_widget.dart`)
Resolve Lottie animation file paths matching the character mood:

```dart
String getLottiePath(MittuMood mood) {
  switch (mood) {
    case MittuMood.waving:
      return 'assets/animations/mittu/wave.json';
    case MittuMood.happy:
      return 'assets/animations/mittu/success.json';
    case MittuMood.sad:
      return 'assets/animations/mittu/fail.json';
    case MittuMood.reading:
      return 'assets/animations/mittu/think.json';
    case MittuMood.neutral:
    default:
      return 'assets/animations/mittu/idle.json';
  }
}
```

---

## 3. Production Asset Specifications

### A. Situational Illustrations (`assets/images/situations/`)
*   **Format**: Transparent PNG or Vector SVG.
*   **Dimensions**: 800 x 600 px (scaled dynamically with `BoxFit.contain`).
*   **Visual Style**: Premium hand-drawn cartoon aesthetic matching Headspace (soft pastel palettes, clean shapes, round borders).

### B. Mittu Mascot Animations (`assets/animations/mittu/`)
*   **Format**: Lottie (JSON) animations.
*   **Performance**: Frame rate locked at **60fps** to ensure lag-free rendering on low-tier mobile processors.
*   **Interactivity**: Loops for `idle` and `think` states; single-shot triggers for `success` and `fail`.
