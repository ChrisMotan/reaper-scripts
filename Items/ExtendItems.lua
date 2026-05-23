-- @description Extend item edge to a target position
-- @author ChrisMotan
-- @version 1.0
-- @about
--   Moves the left or right edge of selected items to a precise position:
--   timeline zero, timecode, or bar number.
--   Requires ReaImGui.
-- ============================================================
--  Licence : CC BY-NC-SA 4.0
--  © 2026 ZoundZikProd
--  Free to use and modify.
--  Non-commercial redistribution only.
--  Any modified version must be shared under the same license.
--  https://creativecommons.org/licenses/by-nc-sa/4.0/
-- ============================================================

-- ==========================================
-- EXTEND ITEMS - ReaImGui UI
-- ==========================================

local ctx = reaper.ImGui_CreateContext('Extend Items')

-- ── Palette ──────────────────────────────────────────────────
local ACCENT   = 0xFF6A38FF
local BG_DARK  = 0xFF111318FF
local BG_MED   = 0xFF1C2030FF
local BG_PANEL = 0xFF232A3AFF
local BG_HOVER = 0xFF2D3650FF
local TEXT     = 0xFFE8EAF0FF
local TEXT_DIM = 0xFF8892AAFF
local GREEN    = 0xFF4CAF50FF
local RED      = 0xFF4444CCFF

local WIN_W, WIN_H = 480, 560

-- ── État ─────────────────────────────────────────────────────
local status_msg = nil
local status_ok  = true
local edge_mode  = 0   -- 0=gauche, 1=droit
local dest_mode  = 0   -- 0=zero, 1=timecode, 2=mesures

local input_min  = {"0"}
local input_sec  = {"0"}
local input_cs   = {"0"}   -- centièmes
local input_bar  = {"1"}

-- ── Styles ───────────────────────────────────────────────────
local function push_style()
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(),        BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),          BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),   BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),           BG_PANEL)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),    BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),     ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),             TEXT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBg(),          BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),    BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),        BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),           BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(),    ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),     ACCENT)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 10)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),   6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(),    8, 6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(),     8, 8)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(),   16, 16)
end

local function pop_style()
  reaper.ImGui_PopStyleColor(ctx, 13)
  reaper.ImGui_PopStyleVar(ctx, 5)
end

local function section_header(label)
  local draw  = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y  = reaper.ImGui_GetCursorScreenPos(ctx)
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

local function colored_button(label, w, h, col_bg, col_hov, col_act)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),        col_bg)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),  col_hov)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),   col_act)
  local clicked = reaper.ImGui_Button(ctx, label, w, h)
  reaper.ImGui_PopStyleColor(ctx, 3)
  return clicked
end

local function radio(label, current, value)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), current == value and TEXT or TEXT_DIM)
  local clicked = reaper.ImGui_RadioButton(ctx, label, current == value)
  reaper.ImGui_PopStyleColor(ctx, 1)
  if clicked then return value end
  return current
end

-- ── Sélecteur bord ───────────────────────────────────────────
local function edge_selector()
  local avail = reaper.ImGui_GetContentRegionAvail(ctx)
  local btn_w = (avail - 8) / 2

  local col_l = edge_mode == 0 and ACCENT or BG_PANEL
  local hov_l = edge_mode == 0 and 0xFF8A5AFF or BG_HOVER
  local col_r = edge_mode == 1 and ACCENT or BG_PANEL
  local hov_r = edge_mode == 1 and 0xFF8A5AFF or BG_HOVER

  if colored_button("  ◀  Bord Gauche", btn_w, 32, col_l, hov_l, 0xFF3A20A0FF) then
    edge_mode = 0
  end
  reaper.ImGui_SameLine(ctx)
  if colored_button("  Bord Droit  ▶", btn_w, 32, col_r, hov_r, 0xFF3A20A0FF) then
    edge_mode = 1
  end
end

-- ── Barre Undo / Redo ─────────────────────────────────────────
local function undo_redo_bar()
  local avail = reaper.ImGui_GetContentRegionAvail(ctx)
  local btn_w = (avail - 8) / 2

  local undo_lbl = reaper.Undo_CanUndo2(0) or ""
  local redo_lbl = reaper.Undo_CanRedo2(0) or ""
  local can_undo = undo_lbl ~= ""
  local can_redo = redo_lbl ~= ""

  -- Undo
  local u_bg  = can_undo and BG_PANEL or BG_MED
  local u_hov = can_undo and BG_HOVER or BG_MED
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), can_undo and TEXT or TEXT_DIM)
  local u_label = can_undo and ("↩  " .. undo_lbl) or "↩  Rien à annuler"
  if colored_button(u_label, btn_w, 28, u_bg, u_hov, ACCENT) and can_undo then
    reaper.Undo_DoUndo2(0)
    status_msg = "↩  Annulé : " .. undo_lbl
    status_ok  = true
  end
  reaper.ImGui_PopStyleColor(ctx, 1)

  reaper.ImGui_SameLine(ctx)

  -- Redo
  local r_bg  = can_redo and BG_PANEL or BG_MED
  local r_hov = can_redo and BG_HOVER or BG_MED
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), can_redo and TEXT or TEXT_DIM)
  local r_label = can_redo and ("↪  " .. redo_lbl) or "↪  Rien à rétablir"
  if colored_button(r_label, btn_w, 28, r_bg, r_hov, ACCENT) and can_redo then
    reaper.Undo_DoRedo2(0)
    status_msg = "↪  Rétabli : " .. redo_lbl
    status_ok  = true
  end
  reaper.ImGui_PopStyleColor(ctx, 1)
end

-- ── Résolution position cible ─────────────────────────────────
local function resolve_target_pos()
  if dest_mode == 0 then
    return 0.0
  elseif dest_mode == 1 then
    -- Timecode : min + sec + centièmes
    local m  = tonumber(input_min[1]) or 0
    local s  = tonumber(input_sec[1]) or 0
    local cs = tonumber(input_cs[1])  or 0
    return m * 60 + s + cs / 100
  elseif dest_mode == 2 then
    local bar = math.max(1, math.floor(tonumber(input_bar[1]) or 1))
    local pos, _ = reaper.TimeMap_GetMeasureInfo(0, bar - 1)
    return pos
  end
  return 0.0
end

-- ── Action principale ─────────────────────────────────────────
local function extend_items()
  local count = reaper.CountSelectedMediaItems(0)
  if count == 0 then
    status_msg = "⚠  Sélectionne au moins un item !"
    status_ok  = false
    return
  end

  local target = resolve_target_pos()

  reaper.Undo_BeginBlock()

  for i = 0, count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    reaper.SetMediaItemInfo_Value(item, "B_LOOPSRC", 0)
  end

  local cursor_pos = reaper.GetCursorPosition()
  reaper.SetEditCurPos(target, false, false)

  if edge_mode == 0 then
    reaper.Main_OnCommand(41305, 0)  -- Trim left edge to edit cursor
  else
    reaper.Main_OnCommand(41311, 0)  -- Trim right edge to edit cursor
  end

  reaper.SetEditCurPos(cursor_pos, false, false)
  reaper.Undo_EndBlock("Extend items edge to position", -1)
  reaper.UpdateArrange()

  local edge_label = edge_mode == 0 and "gauche" or "droit"
  local dest_labels = {
    [0] = "0 (début timeline)",
    [1] = string.format("%sm %ss %scs", input_min[1], input_sec[1], input_cs[1]),
    [2] = "mesure " .. input_bar[1],
  }
  status_msg = string.format("✅  %d item(s) — bord %s → %s",
    count, edge_label, dest_labels[dest_mode])
  status_ok  = true
end

-- ── Boucle de rendu ──────────────────────────────────────────
local function loop()
  push_style()

  reaper.ImGui_SetNextWindowSize(ctx, WIN_W, WIN_H, reaper.ImGui_Cond_Once())
  reaper.ImGui_SetNextWindowPos(ctx, 200, 200, reaper.ImGui_Cond_Once())

  local vis, open = reaper.ImGui_Begin(ctx, ' ⬡  EXTEND ITEMS', true,
    reaper.ImGui_WindowFlags_NoResize())

  if vis then
    local draw = reaper.ImGui_GetWindowDrawList(ctx)
    local wx, wy = reaper.ImGui_GetWindowPos(ctx)

    -- ── Header ──
    reaper.ImGui_DrawList_AddRectFilled(draw, wx, wy+20, wx+WIN_W, wy+52, BG_MED, 0)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), ACCENT)
    reaper.ImGui_SetCursorPosY(ctx, 28)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_Text(ctx, "Extend Items")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
    reaper.ImGui_Text(ctx, "Étend le bord gauche ou droit des items vers une position cible")
    reaper.ImGui_PopStyleColor(ctx, 1)

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Bord ──
    section_header("BORD À ÉTENDRE")
    reaper.ImGui_SetCursorPosX(ctx, 16)
    edge_selector()

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Destination ──
    section_header("POSITION CIBLE")

    -- Mode 0 : Timeline Zero
    dest_mode = radio(" Timeline Zero (position 0)", dest_mode, 0)

    reaper.ImGui_Spacing(ctx)

    -- Mode 1 : Timecode
    dest_mode = radio(" Timecode", dest_mode, 1)
    if dest_mode == 1 then
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_SetCursorPosX(ctx, 32)

      -- Min
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
      reaper.ImGui_Text(ctx, "Min")
      reaper.ImGui_PopStyleColor(ctx, 1)
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_SetNextItemWidth(ctx, 52)
      local ch_m, val_m = reaper.ImGui_InputText(ctx, "##min", input_min[1])
      if ch_m then input_min[1] = val_m end

      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
      reaper.ImGui_Text(ctx, "Sec")
      reaper.ImGui_PopStyleColor(ctx, 1)
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_SetNextItemWidth(ctx, 52)
      local ch_s, val_s = reaper.ImGui_InputText(ctx, "##sec", input_sec[1])
      if ch_s then input_sec[1] = val_s end

      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
      reaper.ImGui_Text(ctx, "Cs")
      reaper.ImGui_PopStyleColor(ctx, 1)
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_SetNextItemWidth(ctx, 52)
      local ch_c, val_c = reaper.ImGui_InputText(ctx, "##cs", input_cs[1])
      if ch_c then input_cs[1] = val_c end

      reaper.ImGui_Spacing(ctx)
    end

    -- Mode 2 : Mesures
    dest_mode = radio(" Numéro de mesure", dest_mode, 2)
    if dest_mode == 2 then
      reaper.ImGui_Spacing(ctx)
      reaper.ImGui_SetCursorPosX(ctx, 32)
      reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
      reaper.ImGui_Text(ctx, "Mesure n°")
      reaper.ImGui_PopStyleColor(ctx, 1)
      reaper.ImGui_SameLine(ctx)
      reaper.ImGui_SetNextItemWidth(ctx, 80)
      local ch_b, val_b = reaper.ImGui_InputText(ctx, "##bar", input_bar[1])
      if ch_b then input_bar[1] = val_b end
      reaper.ImGui_Spacing(ctx)
    end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Compteur ──
    local sel_count = reaper.CountSelectedMediaItems(0)
    local btn_col   = sel_count > 0 and ACCENT or BG_HOVER
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
    reaper.ImGui_Text(ctx, sel_count .. " item(s) sélectionné(s)")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_Spacing(ctx)

    -- ── Bouton action ──
    local edge_label = edge_mode == 0 and "◀  BORD GAUCHE" or "BORD DROIT  ▶"
    local avail = reaper.ImGui_GetContentRegionAvail(ctx)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    if colored_button("  ⬡  ÉTENDRE — " .. edge_label, avail, 36,
                      btn_col, 0xFF8A5AFF, 0xFF3A20A0FF) then
      extend_items()
    end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Undo / Redo ──
    section_header("HISTORIQUE")
    reaper.ImGui_SetCursorPosX(ctx, 16)
    undo_redo_bar()

    -- ── Statut ──
    if status_msg then
      reaper.ImGui_Spacing(ctx)
      local col = status_ok and GREEN or RED
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
