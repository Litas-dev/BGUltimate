# BG Ultimate (WoW Classic 1.14)

A lightweight PvP utility addon that combines **cinematic battleground countdown sounds** with a **modern Battleground control panel** and quick-access UI button.
---
![BG Panel](panel.png)
---

## 🔥 Features

### 🎧 Cinematic Battleground Countdown

* Plays a **10 → 0 voice countdown** before match start
* Triggers automatically from in-game BG system messages
* Plays **intro (horn/drums)** right after countdown ends
* Designed for PvP immersion and awareness

---

### 🎮 Battleground Control Panel

* Clean, modern UI (non-Blizzard default style)
* Open/close via on-screen button
* ESC key supported (closes panel like native UI)
* Buttons for:

  * Warsong Gulch
  * Arathi Basin
  * Alterac Valley

Each button executes server command instantly.

---

### 🧭 Quick Access Button

* Always visible **bottom-right UI button**
* Styled like action button (fits UI, not intrusive)
* Hover tooltip + subtle pulse animation
* Plays Blizzard-style UI sounds on open/close

---

### 🔊 Native UI Sound Integration

* Uses built-in Blizzard sounds:

  * Open window → `IG_MAINMENU_OPEN`
  * Close window → `IG_MAINMENU_CLOSE`
* Makes addon feel like part of the game

---

## 📁 Installation

1. Download or clone this addon
2. Place folder in:

```
World of Warcraft/_classic_/Interface/AddOns/
```

3. Ensure structure:

```
BGUltimate/
 ├── BGUltimate.lua
 ├── BGUltimate.toc
 └── sounds/
      ├── 10.ogg
      └── intro.ogg
```

4. Restart game or type:

```
/reload
```

---

## ⚙️ Requirements

* WoW Classic client **1.14**
* Sound files must be:

  * `.ogg` format
  * correctly named:

    * `10.ogg`
    * `intro.ogg`

---

## ⚠️ Notes

* Battleground commands (e.g. `.go warsong`) are **server-specific**
* If you see:

  ```
  There is no such command
  ```

  → update commands to match your server

---

## 🎯 How It Works

1. Game announces: **"30 seconds until battle begins"**
2. Addon waits → syncs timing
3. At ~10 seconds:

   * plays countdown audio
4. At match start:

   * plays intro sound

---

## 🚀 Future Ideas

* PvP alert system (enemy nearby, outnumbered, etc.)
* Dynamic voice lines
* Queue tracking / BG status UI
* Icons and animations per battleground
* Smart PvP assistant layer

---

## 🧠 Design Philosophy

* Minimal UI clutter
* Fast interaction (1 click → action)
* Immersion through sound
* Feels like **native WoW system**, not a mod

---

## 📜 License

Personal project. Modify and extend freely.

---

## 💬 Author Notes

Built for PvP efficiency and immersion.
Designed to replace manual commands with fast UI and cinematic feedback.

---
