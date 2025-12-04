# Project Blueprint: FastClean

## 1. Overview

This document outlines the development of a Flutter application designed to help users free up storage space by intelligently identifying and deleting unnecessary photos. The core functionality relies on a local, on-device AI to analyze photos, ensuring user privacy and fast performance.

## 2. Core Features

- **On-Device Photo Analysis:** Scans and analyzes user photos locally using a scoring system based on criteria like blurriness, darkness, low resolution, duplicates, and similarity.
- **Intelligent Selection:** Recommends a selection of photos for deletion based on their calculated scores.
- **User-Controlled Deletion:** Allows users to review suggested photos, keep the ones they want, and delete the rest.
- **Privacy-First:** All analysis happens on the device. No photos are uploaded to the cloud.
- **Permissions:** Handles requesting necessary photo gallery access permissions on both iOS and Android.

## 3. Current Art Direction: "Living Aurora"

This section outlines a sophisticated and dynamic visual identity inspired by the ethereal beauty of the aurora borealis. The goal is a premium, fluid, and captivating user experience that feels alive. This is a full-scale implementation across the entire application.

### Theming & Style
- **Color Palette & Hierarchy:** The core of the theme is a moving, animated gradient with a clear color hierarchy.
    - **Background:** A deep, near-black charcoal (`#1A1A1A`) to serve as the night sky.
    - **Aurora Gradient:** A fluid blend with **Ethereal Green** (`#00FFA3`) as the dominant, central color. It will gently shift towards **Deep Cyan** (`#00D4FF`) and may contain subtle, rare hints of **Mystic Magenta** (`#FF00E5`). The animation will make these colors flow and merge in a perpetual, slow dance.
- **Animation:** The key principle is slow, hypnotic motion. UI elements will not just "glow," but will have their colors shift and dance. This will be achieved using a unified set of custom painters and animated widgets.
- **Typography:** The **Inter** font is retained for its excellent clarity against the dynamic background.

### UI & Layout Enhancements
- **New `EmptyState` Layout:** The layout of the main screen will be reconfigured. The `SavedSpaceIndicator` (space saved this month) will now be positioned **above** the `AuroraCircularIndicator`.
- **`AuroraCircularIndicator`:** The animated ring of light will be updated to feature the new green-dominant gradient.
- **`AuroraLinearProgressIndicator`:** A new, reusable animated progress bar will be created and used in the `SavedSpaceIndicator`.
- **`AuroraBorder`:** A new widget will provide an animated "Aurora" border for `PhotoCard`s and `ActionButton`s.
- **`SortingIndicatorBar`:** Will be fully redesigned to use a horizontal, flowing Aurora animation.
- **`FullScreenImageView`:** The loading indicators and decorative gradients will adopt the Aurora theme.

### Implementation Plan

1.  **Update `blueprint.md`:** Finalize the "Living Aurora" plan, including the layout change and color hierarchy.
2.  **Create `lib/aurora_widgets.dart`:** Centralize the Aurora animation logic. This file will contain:
    *   `AuroraPainter` for linear animated gradients.
    *   `AuroraBorder` widget for wrapping other widgets.
    *   `AuroraLinearProgressIndicator` for progress bars.
3.  **Refactor `AuroraCircularIndicator`:** Update its gradient to be green-dominant.
4.  **Refactor `SavedSpaceIndicator`:** Replace its `LinearProgressIndicator` with the new `AuroraLinearProgressIndicator`.
5.  **Refactor `main.dart`:**
    *   Implement the new `EmptyState` layout (`SavedSpaceIndicator` above `AuroraCircularIndicator`).
    *   Replace static button styles with the new `AuroraBorder` on `ActionButton`.
    *   Apply `AuroraBorder` to selected `PhotoCard`s.
    *   Remove all remaining "Néon" theme code.
6.  **Refactor `sorting_indicator_bar.dart`:** Replace its existing animation with a new one based on the `AuroraPainter`.
7.  **Refactor `full_screen_image_view.dart`:** Replace loading indicators and gradients with Aurora-themed versions.
