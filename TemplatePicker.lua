-- ============================================================
--  Licence : CC BY-NC-SA 4.0
--  © 2026 ZoundZikProd
--  Free to use and modify.
--  Non-commercial redistribution only.
--  Any modified version must be shared under the same license.
--  https://creativecommons.org/licenses/by-nc-sa/4.0/
-- ============================================================


-- ==========================================
-- TEMPLATE PICKER - ReaImGui UI
-- ==========================================

-- ⚙️  CONFIGURATION — modifie ce chemin selon ton système :
--   Windows : "C:\\Users\\TON_NOM\\AppData\\Roaming\\REAPER\\ProjectTemplates\\"
--   macOS   : os.getenv("HOME") .. "/Library/Application Support/REAPER/ProjectTemplates/"
--   Linux   : os.getenv("HOME") .. "/.config/REAPER/ProjectTemplates/"
--
-- Astuce : tu peux aussi utiliser la détection automatique ci-dessous
--   en commentant la ligne manuelle et en décommentant les lignes auto.

-- ── Détection automatique du chemin REAPER ──
local function get_default_template_path()
  local sep = package.config:sub(1,1)  -- "/" sur Mac/Linux, "\" sur Windows
  if sep == "\\" then
    -- Windows
    local appdata = os.getenv("APPDATA") or (os.getenv("USERPROFILE") .. "\\AppData\\Roaming")
    return appdata .. "\\REAPER\\ProjectTemplates\\"
  else
    -- macOS / Linux
    local home = os.getenv("HOME") or ""
    if reaper.GetOS():find("OSX") or reaper.GetOS():find("macOS") then
      return home .. "/Library/Application Support/REAPER/ProjectTemplates/"
    else
      return home .. "/.config/REAPER/ProjectTemplates/"
    end
  end
end

-- Chemin manuel (décommente et adapte si la détection auto ne fonctionne pas) :
-- local TEMPLATE_PATH = "C:\\Users\\TON_NOM\\AppData\\Roaming\\REAPER\\ProjectTemplates\\"

-- Chemin automatique (actif par défaut) :
local TEMPLATE_PATH = get_default_template_path()

local ctx = reaper.ImGui_CreateContext('Template Picker')

-- ── Palette ──────────────────────────────────────────────────
local ACCENT    = 0xFF6A38FF
local BG_DARK   = 0xFF111318FF
local BG_MED    = 0xFF1C2030FF
local BG_PANEL  = 0xFF232A3AFF
local BG_HOVER  = 0xFF2D3650FF
local BG_SEL    = 0xFF3A2860FF
local TEXT      = 0xFFE8EAF0FF
local TEXT_DIM  = 0xFF8892AAFF
local GREEN     = 0xFF4CAF50FF

local WIN_W, WIN_H = 400, 500

-- ── État ─────────────────────────────────────────────────────
local templates    = {}
local selected_idx = nil
local status_msg   = nil
local status_ok    = true
local search_buf   = ""

-- ── Scan du dossier ──────────────────────────────────────────
local function scan_templates()
  templates = {}
  local i = 0
  repeat
    local file = reaper.EnumerateFiles(TEMPLATE_PATH, i)
    if file then
      local ext = file:match("%.([^%.]+)$")
      if ext and ext:upper() == "RPT" or ext and ext:upper() == "RTP" or
         ext and ext:upper() == "RPP" then
        table.insert(templates, file)
      end
    end
    i = i + 1
  until not file
  table.sort(templates, function(a, b) return a:lower() < b:lower() end)
end

scan_templates()

-- ── Styles ───────────────────────────────────────────────────
local function push_style()
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(),        BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),          BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),   BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),    ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),           BG_PANEL)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),    BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),     ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),           BG_SEL)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(),    BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),     ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),             TEXT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBg(),          BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),    BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),        BG_HOVER)
 
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 10)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),  6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(),   8, 6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(),    8, 6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(),  16, 16)
end

local function pop_style()
  reaper.ImGui_PopStyleColor(ctx, 14)
  reaper.ImGui_PopStyleVar(ctx, 5)
end

local function section_header(label)
  local draw = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y = reaper.ImGui_GetCursorScreenPos(ctx)
  local avail = reaper.ImGui_GetContentRegionAvail(ctx)
  reaper.ImGui_DrawList_AddLine(draw, x, y+7, x+6, y+7, ACCENT, 2)
  reaper.ImGui_SetCursorScreenPos(ctx, x+12, y)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), ACCENT)
  reaper.ImGui_Text(ctx, label)
  reaper.ImGui_PopStyleColor(ctx, 1)
  local tw, _ = reaper.ImGui_CalcTextSize(ctx, label)
  reaper.ImGui_DrawList_AddLine(draw, x+18+tw, y+7, x+avail, y+7, BG_HOVER, 1)
  reaper.ImGui_Spacing(ctx)
end

local function action_button(label, w, h, col)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),        col)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),  0xFF8A5AFF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),   0xFF3A20A0FF)
  local clicked = reaper.ImGui_Button(ctx, label, w, h)
  reaper.ImGui_PopStyleColor(ctx, 3)
  return clicked
end

-- ── Action d'ouverture ───────────────────────────────────────
local function open_template()
  if not selected_idx then
    status_msg = "⚠  Sélectionne un template d'abord !"
    status_ok  = false
    return
  end
  local file = TEMPLATE_PATH .. templates[selected_idx]
  reaper.Main_openProject(file)
  status_msg = "✅  Template chargé : " .. templates[selected_idx]
  status_ok  = true
end

-- ── Boucle de rendu ──────────────────────────────────────────
local function loop()
  push_style()

  reaper.ImGui_SetNextWindowSize(ctx, WIN_W, WIN_H, reaper.ImGui_Cond_Once())
  reaper.ImGui_SetNextWindowPos(ctx, 200, 200, reaper.ImGui_Cond_Once())

  local vis, open = reaper.ImGui_Begin(ctx, ' ⬡  PROJECT TEMPLATES', true,
    reaper.ImGui_WindowFlags_NoResize())

  if vis then
    local draw = reaper.ImGui_GetWindowDrawList(ctx)
    local wx, wy = reaper.ImGui_GetWindowPos(ctx)

    -- ── Header ──
    reaper.ImGui_DrawList_AddRectFilled(draw, wx, wy+20, wx+WIN_W, wy+52, BG_MED, 0)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), ACCENT)
    reaper.ImGui_SetCursorPosY(ctx, 28)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_Text(ctx, "Project Templates")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
    reaper.ImGui_Text(ctx, "Sélectionne et charge un template REAPER")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Barre de recherche ──
    section_header("RECHERCHE")
    reaper.ImGui_SetNextItemWidth(ctx, -1)
    local changed, new_search = reaper.ImGui_InputTextWithHint(ctx, "##search", "🔍  Filtrer les templates...", search_buf)
    if changed then search_buf = new_search end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Liste des templates ──
    local filter = search_buf:lower()
    local filtered = {}
    for i, name in ipairs(templates) do
      if filter == "" or name:lower():find(filter, 1, true) then
        table.insert(filtered, {idx=i, name=name})
      end
    end

    -- Compteur
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_Text(ctx, #filtered .. " template(s)")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_Spacing(ctx)

    -- Zone scrollable
    local list_h = WIN_H - 260
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ChildBg(), BG_MED)
    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ChildRounding(), 8)
    reaper.ImGui_BeginChild(ctx, "##templates", -1, list_h, 1)

    if #filtered == 0 then
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_SetCursorPosX(ctx, 20)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
      reaper.ImGui_Text(ctx, "Aucun template trouvé.")
      reaper.ImGui_PopStyleColor(ctx, 1)
    else
      for _, entry in ipairs(filtered) do
        local is_sel = (selected_idx == entry.idx)
        local cx, cy = reaper.ImGui_GetCursorScreenPos(ctx)
        local avail  = reaper.ImGui_GetContentRegionAvail(ctx)

        -- Fond de la ligne
        if is_sel then
          reaper.ImGui_DrawList_AddRectFilled(draw, cx, cy, cx+avail, cy+34, BG_SEL, 4)
          reaper.ImGui_DrawList_AddRectFilled(draw, cx, cy+4, cx+3, cy+30, ACCENT, 2)
        end

        -- Icône + nom (sans extension)
        local display = entry.name:match("^(.+)%.[^%.]+$") or entry.name
        local icon    = is_sel and "▶  " or "   "
        local txt_col = is_sel and TEXT or TEXT_DIM

        reaper.ImGui_DrawList_AddText(draw, cx+12, cy+9, txt_col, icon .. display)

        -- Zone de clic invisible
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),        0x00000000)
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(), is_sel and BG_SEL or 0x15FFFFFF22)
        reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),  BG_HOVER)
        local clicked = reaper.ImGui_Selectable(ctx, "##sel"..entry.idx, is_sel, nil, 0, 34)
        reaper.ImGui_PopStyleColor(ctx, 3)

        if clicked then selected_idx = entry.idx end

        -- Double-clic = ouvrir directement
        if reaper.ImGui_IsItemHovered(ctx) and reaper.ImGui_IsMouseDoubleClicked(ctx, 0) then
          selected_idx = entry.idx
          open_template()
        end
      end
    end

    reaper.ImGui_EndChild(ctx)
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_PopStyleVar(ctx, 1)

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Bouton OUVRIR ──
    local avail = reaper.ImGui_GetContentRegionAvail(ctx)
    local btn_col = selected_idx and ACCENT or BG_HOVER
    reaper.ImGui_SetCursorPosX(ctx, 16)
    if action_button("  ⬡  OUVRIR LE TEMPLATE", avail, 36, btn_col) then
      open_template()
    end

    -- ── Statut ──
    if status_msg then
      reaper.ImGui_Spacing(ctx)
      local col = status_ok and GREEN or 0xFF4466FFFF
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), col)
      reaper.ImGui_SetCursorPosX(ctx, 16)
      reaper.ImGui_TextWrapped(ctx, status_msg)
      reaper.ImGui_PopStyleColor(ctx, 1)
    end

    reaper.ImGui_End(ctx)
  end

  pop_style()
  if open then reaper.defer(loop) end
end

reaper.defer(loop)