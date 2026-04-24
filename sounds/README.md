# BG Ultimate – Sound System

This document describes the **sound assets used in the addon**, where they come from, and how they are triggered in-game.

---

## 🔊 Overview

The addon uses a **two-stage cinematic audio system**:

1. **Countdown (10 → 0)**
2. **Intro / Battle Start (horn / drums)**

These sounds are played automatically during battleground preparation to improve awareness and immersion.

---

## 📁 Sound Files

Located in:

```text
Interface/AddOns/BGUltimate/sounds/
```

Required files:

```text
10.ogg     → countdown voice (10 to 0)
intro.ogg  → battle intro (horn, drums, etc.)
```

---

## 🎧 Sound Roles

### 1. `10.ogg` — Countdown

* Plays at ~10 seconds before battleground starts
* Contains full voice countdown (10 → 0)
* Must be a **single continuous file** (not split per number)

**Purpose:**

* Timing awareness
* PvP readiness
* Replaces default silent countdown

---

### 2. `intro.ogg` — Battle Start

* Plays immediately after countdown ends
* Typically includes:

  * War horn
  * Drums
  * Cinematic effects

**Purpose:**

* Signals match start
* Adds intensity and immersion

---

## ⚙️ How Sounds Are Triggered

1. Game sends message:

   ```
   "30 seconds until battle begins"
   ```

2. Addon logic:

   * Waits ~19 seconds
   * At ~11 seconds remaining:

     * ▶ plays `10.ogg`

3. After countdown finishes:

   * ▶ plays `intro.ogg`

---

## 🔁 Playback Channel

All sounds use:

```lua
PlaySoundFile(path, "Master")
```

This ensures:

* Always audible (not muted by SFX settings)
* Independent of in-game sound categories

---

## 🎯 Supported Formats

* `.ogg` (recommended)
* Stereo or mono
* 44.1kHz preferred

---

## ⚠️ Common Issues

### ❌ No sound plays

Check:

* File names are exact:

  * `10.ogg`
  * `intro.ogg`
* Files are in correct folder
* Path matches:

  ```
  Interface\\AddOns\\BGUltimate\\sounds\\
  ```

---

### ❌ Wrong timing

Adjust in code:

```lua
COUNTDOWN_DELAY = 19
COUNTDOWN_LENGTH = 10
```

* If countdown starts too early/late → tweak delay
* If intro feels off → adjust length

---

## 🌐 Where to Get Sounds

You can source audio from:

* **Free sound libraries**

  * Pixabay (sound effects)
  * Freesound.org
* **Game-style audio packs**
* Custom recordings

Search examples:

* "battle horn sound"
* "drum war intro"
* "countdown voice 10 to 0"

---

## ⚖️ Licensing Note

Make sure sounds are:

* Free to use
* Or properly licensed

Avoid copyrighted material unless permitted.

---

## 🚀 Customization Ideas

You can easily expand:

* Replace countdown with:

  * Mortal Kombat voice
  * Arena announcer
* Add:

  * “FIGHT!” after intro
  * Class-specific alerts
  * Kill streak sounds

---

## 🧠 Design Goal

The sound system is designed to:

* Replace passive UI with **active feedback**
* Improve **reaction timing**
* Create a **cinematic PvP experience**

---

## 💬 Summary

* `10.ogg` → timing awareness
* `intro.ogg` → emotional impact

Together:
👉 they transform BG start into a **clear, high-signal moment**

---
