# ZoundZikProd — REAPER Scripts (Lua)

A collection of Lua scripts for REAPER developed for music composition and audio/video post-production.

License: CC BY-NC-SA 4.0 — Free, modifiable, non-commercial.
https://creativecommons.org/licenses/by-nc-sa/4.0/

---

## Requirements

- REAPER (any recent version)
- ReaImGui — required for scripts with a graphical interface
  Install via: ReaPack > Browse packages > ReaImGui
  https://forum.cockos.com/showthread.php?t=250419

---

## Scripts

### 1. ClearAutomation.lua — Clear automation points

Deletes envelope points (Volume, Pan, Width) from the selected track,
with precise control over which area to clear.

Modes:
- Between : inside the time selection
- Left    : to the left of the selection
- Right   : to the right of the selection
- Outside : everything outside the selection
- Whole   : the entire track

How to use:
1. Select a track in REAPER
2. Make a time selection (drag on the timeline)
3. Run the script
4. Choose the mode and envelopes to clear
5. Click CLEAR

---

### 2. ExtendItems.lua — Extend item edge to a target position

Moves the left or right edge of selected items to a precise position
(timeline zero, timecode, or bar number).

Target positions:
- Timeline Zero : moves the edge to 0:00
- Timecode      : enter minutes / seconds / centiseconds manually
- Bar number    : enter a bar number

How to use:
1. Select one or more items on the timeline
2. Run the script
3. Choose which edge to extend (left or right)
4. Choose the target position
5. Click EXTEND

Note: a built-in Undo/Redo button lets you undo directly from the script.

---

### 3. RandomAutomation.lua — Random automation generator

Generates random automation points on Volume, Pan and/or Width envelopes
within the time selection.

Configurable parameters:
- Enable/disable Pan, Volume, Width
- Number of points to generate
- Auto or manual spacing (in seconds)
- Pan amplitude (%)
- Volume min/max values (dB)
- Width amplitude (%)

How to use:
1. Select a track
2. Make a time selection
3. Run the script
4. Set the parameters in the dialog
5. Click OK to generate (the window stays open to run again)

Note: this script uses the native REAPER dialog, ReaImGui is not required.

---

### 4. TemplatePicker.lua — Project template picker

Displays a window to browse and quickly load a REAPER project template,
with a search bar.

How to use:
1. Run the script
2. Use the search bar to filter
3. Click a template to select it
4. Click OPEN (or double-click the name)

Path configuration:
The script auto-detects your REAPER ProjectTemplates folder based on your OS.
If it does not work, edit the TEMPLATE_PATH variable at the top of the file:

  Windows : "C:\\Users\\YOUR_NAME\\AppData\\Roaming\\REAPER\\ProjectTemplates\\"
  macOS   : os.getenv("HOME") .. "/Library/Application Support/REAPER/ProjectTemplates/"

---

### 5. MixMasterCheatSheet.lua — Mix and Mastering cheat sheet

Displays a reference interface with recommended EQ, compression and reverb
settings for each instrument, by genre.

Genres covered: Rock, Hip-Hop, Jazz, Electronic, and more.
Instruments: Drums (Kick, Snare, Hi-Hats, Overhead, Toms), Bass, Guitars, Vocals, Keys.

How to use:
1. Run the script
2. Select the musical genre
3. Browse by instrument to see EQ / Compressor / Reverb suggestions

Note: this is a reference tool, not absolute rules. Trust your ears.

---

### 6. CourtMetrageManager.lua — Short film project manager

Interface to navigate a short film project folder structure and directly
open the corresponding .rpp files.

Expected folder structure:
```
SHORT_FILMS/
  MY_FILM_C1/        (project folder, suffix _CX)
    MY_FILM_Zik/     (music folder, suffix _Zik)
      scene01A/      (scene folder)
        scene01A.rpp (REAPER project)
```

Path configuration:
Edit the court_metrage_path variable at the top of the file:

  Windows : "D:\\MY_PROJECTS\\SHORT_FILMS"
  macOS   : "/Users/your_name/Projects/Short_Films"

---

## Installation

1. Download the .lua file(s) you want
2. Copy them to your REAPER Scripts folder:
   - Windows : %APPDATA%\REAPER\Scripts\
   - macOS   : ~/Library/Application Support/REAPER/Scripts/
   - Linux   : ~/.config/REAPER/Scripts/
3. In REAPER: Actions > Show action list > Load > select the script
4. Assign a keyboard shortcut or toolbar button if you want

---

## License

These scripts are distributed under the Creative Commons BY-NC-SA 4.0 license.

- Free to use
- Modification allowed
- Sharing allowed
- Commercial use not allowed
- Selling the scripts (original or modified) is not allowed
- Any modified version must be shared under the same license

Full text: https://creativecommons.org/licenses/by-nc-sa/4.0/

---

## Credits

Developed by ZoundZikProd with the help of Claude (Anthropic).
