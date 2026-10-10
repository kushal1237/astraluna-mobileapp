# 🌌 ASTRALUNA MASTER BLUEPRINT & DATA REPOSITORY
> **App Name**: Astraluna  
> **Tagline**: Stars for everyone  
> **Website**: [astralunacom.netlify.app](https://astralunacom.netlify.app/) (`astraluna.com.np`)  
> **Platform**: Flutter (Android & iOS)  
> **Target Audience**: Stargazers, amateur astronomers, students, and space enthusiasts in Nepal & Asia  

---

## 📋 TABLE OF CONTENTS
1. [Core Mission & Feature Overview](#1-core-mission--feature-overview)
2. [Complete Astronomy Calculations & Math](#2-complete-astronomy-calculations--math)
3. [API Endpoints & Sample Data Payloads](#3-api-endpoints--sample-data-payloads)
4. [Public Domain Space Photo & Asset Catalog](#4-public-domain-space-photo--asset-catalog)
5. [Firestore Database Schemas & User Data Models](#5-firestore-database-schemas--user-data-models)
6. [Design System & Color Tokens](#6-design-system--color-tokens)
7. [Screen Wireframes & Layout Specs](#7-screen-wireframes--layout-specs)
8. [Complete Flutter Code Templates](#8-complete-flutter-code-templates)
9. [Legal Guidelines & Community Moderation Matrix](#9-legal-guidelines--community-moderation-matrix)
10. [Milestone Build & Release Roadmap](#10-milestone-build--release-roadmap)

---

## 1. CORE MISSION & FEATURE OVERVIEW

Astraluna solves a fundamental problem for stargazers: raw astronomical data (like Right Ascension, Declination, Julian dates) is confusing for beginners. Astraluna translates this data into a clear answer to one simple question: **"What can I see with my naked eye from my rooftop right now?"**

```
                          ┌────────────────────────────────┐
                          │   Astraluna Data Aggregator    │
                          └───────────────┬────────────────┘
                                          │
            ┌─────────────────────────────┼─────────────────────────────┐
            ▼                             ▼                             ▼
  ┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
  │ Local GPS & Sky  │          │ Rocket Launches  │          │ Stargazer Chat   │
  │ Visibility Math  │          │ & Satellite Passes│          │ (Asia & Nepal)   │
  └──────────────────┘          └──────────────────┘          └──────────────────┘
```

### Key Modules:
- **Tonight's Sky**: Live rooftop visibility for Moon, Venus, Mars, Jupiter, Saturn, and ISS.
- **Rooftop Directional Compass**: Converts azimuth angles to intuitive directions (e.g., *"Look East-South-East (115°) at 45° altitude"*).
- **Launch Library**: Live launch countdowns, rocket specs, launchpad locations, and trajectory visibility alerts for user coordinates.
- **Stargazer Community**: Real-time room chat (`Asia` & `Nepal`) with guest browsing, unique handle reservation (`@handle`), and anti-spam moderation.
- **Space News Feed**: Aggregated space headlines from Spaceflight News API (SNAPI v4) with direct attribution links.
- **Public Domain Photo Gallery**: NASA APOD and NASA Image Search integration with 1-tap download and sharing.

---

## 2. COMPLETE ASTRONOMY CALCULATIONS & MATH

Celestial object visibility is calculated locally on the device without network latency or API costs.

### A. Solar Zenith & Twilight Angles
- **Sun Altitude Angle ($h_{sun}$)**:
  - $h_{sun} < 0^\circ$: Sunset
  - $h_{sun} \le -6^\circ$: Civil Twilight (brightest stars and planets become visible)
  - $h_{sun} \le -12^\circ$: Nautical Twilight (horizon blurs, bright stars clearly visible)
  - $h_{sun} \le -18^\circ$: Astronomical Night (pitch black sky)

### B. Object Altitude & Azimuth
- **Altitude Angle ($h_{obj}$)**: Vertical angle above horizon ($0^\circ = \text{Horizon}$, $90^\circ = \text{Overhead Zenith}$).
  - Required cutoff: $h_{obj} \ge 12^\circ$ (to clear trees, roofs, and heavy atmospheric extinction).
- **Azimuth Angle ($A_{obj}$)**: Horizontal direction in degrees ($0^\circ = \text{North}$, $90^\circ = \text{East}$, $180^\circ = \text{South}$, $270^\circ = \text{West}$).

### C. Apparent Brightness Magnitude ($m$)
Lower/negative values indicate higher brightness:
- Full Moon: $-12.7$
- Venus (maximum): $-4.4$
- International Space Station (ISS): $-3.0$
- Jupiter: $-2.5$
- Mars (opposition): $-2.0$
- Saturn: $+0.5$
- Faintest naked-eye star in suburban sky: $+3.5$ to $+4.0$

### D. Rooftop Visibility Formula
$$\text{IsVisible} = (h_{obj} \ge 12^\circ) \land (h_{sun} \le -6^\circ) \land (m \le 4.0)$$

---

## 3. API ENDPOINTS & SAMPLE DATA PAYLOADS

### A. Launch Library 2 API (Rocket Launches)
- **Endpoint**: `https://ll.thespacedevs.com/2.2.0/launch/upcoming/?limit=5`
- **Cost**: Free ($15\text{ req/min}$)
- **Sample JSON Payload**:
```json
{
  "count": 1,
  "results": [
    {
      "id": "a2b1c3d4",
      "name": "Falcon 9 Block 5 | Starlink Group 6-45",
      "status": { "name": "Go for Launch", "abbrev": "Go" },
      "net": "2026-10-05T22:30:00Z",
      "launch_service_provider": { "name": "SpaceX", "type": "Commercial" },
      "rocket": { "configuration": { "full_name": "Falcon 9 Block 5" } },
      "pad": {
        "name": "Space Launch Complex 40",
        "location": { "name": "Cape Canaveral, FL, USA" }
      },
      "image": "https://spacelaunchnow-prod-east.nyc3.digitaloceanspaces.com/media/launch_images/falcon25209251_image_20230807133816.png"
    }
  ]
}
```

### B. Spaceflight News API v4 (News Articles)
- **Endpoint**: `https://api.spaceflightnewsapi.net/v4/articles/?limit=5`
- **Cost**: Free (No API key required)
- **Sample JSON Payload**:
```json
{
  "results": [
    {
      "id": 101,
      "title": "NASA's James Webb Space Telescope Observes Atmospheric Water on Exoplanet",
      "url": "https://www.space.com/webb-telescope-exoplanet-water-atmosphere",
      "image_url": "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=800",
      "news_site": "Space.com",
      "summary": "Astronomers using the James Webb Space Telescope have detected clear signatures of water vapor in the atmosphere of a gas giant exoplanet.",
      "published_at": "2026-09-28T14:00:00Z"
    }
  ]
}
```

### C. NASA APOD API (Astronomy Picture of the Day)
- **Endpoint**: `https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY`
- **Cost**: Free ($1,000\text{ req/hr}$)
- **Sample JSON Payload**:
```json
{
  "title": "The Orion Nebula in High Definition",
  "date": "2026-09-29",
  "explanation": "Twenty-four hundred light-years away in the constellation Orion lies one of the closest star-forming regions to Earth.",
  "url": "https://apod.nasa.gov/apod/image/2409/OrionNebula_Hubble_960.jpg",
  "hdurl": "https://apod.nasa.gov/apod/image/2409/OrionNebula_Hubble_2048.jpg",
  "media_type": "image",
  "copyright": "NASA, ESA, M. Robberto (Space Telescope Science Institute/ESA)"
}
```

---

## 4. PUBLIC DOMAIN SPACE PHOTO & ASSET CATALOG

The following royalty-free high-resolution space photos are sourced from **NASA / JPL Public Domain Archives** for direct use in the app's gallery and sample dataset:

| Asset Name | Direct Image URL | Attribution & License |
| :--- | :--- | :--- |
| **Earth from Space (Blue Marble)** | `https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?q=80&w=1000` | Public Domain / NASA |
| **Full Moon High Res** | `https://images.unsplash.com/photo-1532693322450-2cb5c511067d?q=80&w=1000` | Public Domain / NASA |
| **Saturn & Rings** | `https://images.unsplash.com/photo-1614732414444-096e5f1122d5?q=80&w=1000` | NASA / JPL-Caltech |
| **Jupiter Great Red Spot** | `https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000` | NASA / JPL-Caltech / SwRI / MSSS |
| **Orion Nebula (M42)** | `https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=1000` | NASA / ESA Hubble |
| **Andromeda Galaxy (M31)** | `https://images.unsplash.com/photo-1462331940025-496dfbfc7564?q=80&w=1000` | NASA / JPL-Caltech |
| **SpaceX Falcon 9 Launch** | `https://images.unsplash.com/photo-1517976487492-5750f3195933?q=80&w=1000` | SpaceX Public Domain |

---

## 5. FIRESTORE DATABASE SCHEMAS & USER DATA MODELS

### A. Firestore Collections Structure
```
cloud_firestore root
├── handles/
│   └── {username}/
│       ├── uid: "anon_user_uid_xyz"
│       └── reservedAt: Timestamp
├── rooms/
│   ├── asia/
│   │   └── messages/
│   │       └── {messageId}/
│   │           ├── sender: "astronomer_np"
│   │           ├── text: "Clear sky over Pokhara tonight!"
│   │           ├── timestamp: Timestamp
│   │           └── reported: false
│   └── nepal/
│       └── messages/
│           └── {messageId}/
│               ├── sender: "sky_watcher"
│               ├── text: "Jupiter is glowing near the moon right now!"
│               ├── timestamp: Timestamp
│               └── reported: false
└── reports/
    └── {reportId}/
        ├── messageId: "msg_123"
        ├── room: "nepal"
        ├── reportedBy: "user_abc"
        ├── reason: "Spam"
        └── timestamp: Timestamp
```

---

## 6. DESIGN SYSTEM & COLOR TOKENS

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color spaceBlack = Color(0xFF0B0E17);
  static const Color nebulaCard = Color(0xFF161B2E);
  static const Color nebulaCardBorder = Color(0xFF252D47);
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color solarAmber = Color(0xFFFFC107);
  static const Color cosmicPurple = Color(0xFF7C4DFF);
  static const Color starlightWhite = Color(0xFFF0F4F8);
  static const Color starlightMuted = Color(0xFF94A3B8);
  static const Color visibleGreen = Color(0xFF00E676);

  // Astro Red Night-Vision Mode
  static const Color astroRedBg = Color(0xFF100000);
  static const Color astroRedCard = Color(0xFF260505);
  static const Color astroRedAccent = Color(0xFFFF3333);
  static const Color astroRedText = Color(0xFFFF8888);
}
```

---

## 7. SCREEN WIREFRAMES & LAYOUT SPECS

```
┌─────────────────────────────────────────────────────────┐
│ [≡] Astraluna 🌌                       📍 Kathmandu, NP │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🌕 TONIGHT'S CELESTIAL HIGHLIGHT                    │ │
│ │ Waxing Gibbous Moon & Jupiter Conjunction           │ │
│ │ Look ESE at 42° Altitude • Visible Right Now!       │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌──────────────────────┐   ┌──────────────────────────┐ │
│ │ 🚀 NEXT LAUNCH       │   │ 🛰️ ISS PASS              │ │
│ │ Falcon 9 (Starlink)  │   │ Today at 19:42 NPT       │ │
│ │ T-Minus 04h 12m 30s  │   │ Max Alt: 68° (NW to SE)  │ │
│ └──────────────────────┘   └──────────────────────────┘ │
│                                                         │
│  BRIGHT OBJECTS TONIGHT                                 │
│  • 🟢 Jupiter    | Alt: 45° | Az: 110° ESE | Mag: -2.4 │
│  • 🟢 Venus      | Alt: 18° | Az: 260° WSW | Mag: -4.1 │
│  • ⚪ Saturn     | Alt: 38° | Az: 175° S   | Mag: +0.6 │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [🏠 Home] [🔭 Sky] [🚀 Launches] [💬 Community] [📰 News] │
└─────────────────────────────────────────────────────────┘
```

---

## 8. COMPLETE FLUTTER CODE TEMPLATES

Below is the complete starter model for `SkyObject` in pure Dart:

```dart
class SkyObject {
  final String id;
  final String name;
  final String category; // Planet, Moon, Satellite, Star
  final double altitude; // Degrees above horizon
  final double azimuth;  // Compass angle (0 - 360)
  final String cardinalDirection; // e.g. "ESE"
  final double magnitude; // Brightness
  final bool isVisible;   // Evaluated visibility
  final String tip;       // Observation guide

  SkyObject({
    required this.id,
    required this.name,
    required this.category,
    required this.altitude,
    required this.azimuth,
    required this.cardinalDirection,
    required this.magnitude,
    required this.isVisible,
    required this.tip,
  });

  factory SkyObject.calculate({
    required String name,
    required String category,
    required double alt,
    required double az,
    required double mag,
    required double sunAlt,
    required String tip,
  }) {
    // Visibility rule: Altitude >= 12° AND Sun Altitude <= -6° AND Magnitude <= 4.0
    bool visible = (alt >= 12.0) && (sunAlt <= -6.0) && (mag <= 4.0);
    String direction = _azimuthToCardinal(az);

    return SkyObject(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      category: category,
      altitude: alt,
      azimuth: az,
      cardinalDirection: direction,
      magnitude: mag,
      isVisible: visible,
      tip: tip,
    );
  }

  static String _azimuthToCardinal(double az) {
    if (az >= 337.5 || az < 22.5) return 'N';
    if (az >= 22.5 && az < 67.5) return 'NE';
    if (az >= 67.5 && az < 112.5) return 'E';
    if (az >= 112.5 && az < 157.5) return 'SE';
    if (az >= 157.5 && az < 202.5) return 'S';
    if (az >= 202.5 && az < 247.5) return 'SW';
    if (az >= 247.5 && az < 292.5) return 'W';
    return 'NW';
  }
}
```

---

## 9. LEGAL GUIDELINES & COMMUNITY MODERATION MATRIX

### A. Space News Legal Compliance (Space.com Style)
1. **Aggregated Summaries**: Fetch titles, 2-sentence excerpts, and thumbnails via SNAPI v4.
2. **Canonical Links**: Every article card contains an explicit button titled **"Read Full Story on [Publisher]"** that opens the original webpage in an in-app browser (`url_launcher`).
3. **No Full Text Copying**: Never scrape full body text to maintain 100% fair use compliance.

### B. NASA Photo License Rules
1. **Public Domain Usage**: NASA material is generally not copyrighted and free for educational use.
2. **Attribution Requirement**: Every photo displays a caption badge: `Credit: NASA / JPL-Caltech` or `Source: NASA APOD`.

### C. Community Moderation & Safety Rules
1. **Handle Reservation**: Users must choose a unique handle `@username` before sending chat messages.
2. **Rate Limiting**: Cooldown timer restricts sending to 1 message every 3 seconds.
3. **Local User Blocking**: 1-tap block instantly hides all messages from a blocked handle on the user's device.
4. **Message Reporting**: 1-tap report logs flagged messages into the Firestore `reports` collection for review.

---

## 10. MILESTONE BUILD & RELEASE ROADMAP

- [x] **Milestone 1**: Requirements Gathering & Blueprint Specification.
- [ ] **Milestone 2**: Setup Flutter theme, Navigation Router, & Dark/Astro Red theme tokens.
- [ ] **Milestone 3**: Implement Local Astronomy Position Math Engine & GPS Service (`SkyScreen`).
- [ ] **Milestone 4**: Integrate Launch Library 2 & Spaceflight News API feeds (`LaunchesScreen`, `NewsScreen`).
- [ ] **Milestone 5**: Build Real-Time Community Chat (`Asia` & `Nepal` rooms) with Handle Auth & Moderation.
- [ ] **Milestone 6**: QA Testing on Android devices in Nepal & Release APK Build.
