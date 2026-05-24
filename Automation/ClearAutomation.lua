-- @description Clear automation points on selected track
-- @author ChrisMotan
-- @version 1.0
-- @about
--   Deletes envelope points (Volume, Pan, Width) from the selected track.
--   Supports 5 modes: Between, Left, Right, Outside, Whole.
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
-- CLEAR AUTOMATION - ReaImGui UI
-- ==========================================

local ctx = reaper.ImGui_CreateContext('Clear Automation')
local ACCENT   = 0xFF6A38FF  -- orange vif
local ACCENT2  = 0xFF3890FF  -- bleu
local BG_DARK  = 0xFF111318FF
local BG_MED   = 0xFF1C2030FF
local BG_PANEL = 0xFF232A3AFF
local BG_HOVER = 0xFF2D3650FF
local TEXT     = 0xFFE8EAF0FF
local TEXT_DIM = 0xFF8892AAFF
local GREEN    = 0xFF4CAF50FF
local RED      = 0xFF2020F0FF  -- ABGR

-- Taille de la fenêtre
local WIN_W, WIN_H = 380, 540

-- État de l'UI
local mode_sel   = 1          -- 1=Between, 2=Left, 3=Right, 4=Outside, 5=Whole
local env_pan    = true
local env_vol    = true
local env_wid    = true
local status_msg = nil
local status_ok  = true
local anim_time  = 0

local MODE_LABELS = {
  {icon="⟷", label="Between",  desc="Dans la sélection"},
  {icon="◁",  label="Left",     desc="À gauche de la sélection"},
  {icon="▷",  label="Right",    desc="À droite de la sélection"},
  {icon="⊡",  label="Outside",  desc="En dehors de la sélection"},
  {icon="⬛", label="Whole",    desc="Toute la piste"},
}

-- ── helpers ImGui ──────────────────────────────────────────────
local function push_style()
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(),        BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),          BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(),   BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),    ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),           BG_PANEL)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),    BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),     ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Header(),           BG_PANEL)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderHovered(),    BG_HOVER)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_HeaderActive(),     ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_CheckMark(),        ACCENT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(),             TEXT)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBg(),          BG_DARK)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive(),    BG_MED)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Separator(),        BG_HOVER)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 10)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FrameRounding(),  6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding(),   8, 6)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(),    8, 8)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(),  16, 16)
end

local function pop_style()
  reaper.ImGui_PopStyleColor(ctx, 15)
  reaper.ImGui_PopStyleVar(ctx, 5)
end

-- Ligne de séparation stylée avec label
local function section_header(label)
  local draw = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y = reaper.ImGui_GetCursorScreenPos(ctx)
  local avail = reaper.ImGui_GetContentRegionAvail(ctx)
  -- trait gauche
  reaper.ImGui_DrawList_AddLine(draw, x, y+7, x+6, y+7, ACCENT, 2)
  -- texte
  reaper.ImGui_SetCursorScreenPos(ctx, x+12, y)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), ACCENT)
  reaper.ImGui_Text(ctx, label)
  reaper.ImGui_PopStyleColor(ctx, 1)
  -- trait droit
  local tw, _ = reaper.ImGui_CalcTextSize(ctx, label)
  local lx = x + 18 + tw
  reaper.ImGui_DrawList_AddLine(draw, lx, y+7, x+avail, y+7, BG_HOVER, 1)
  reaper.ImGui_Spacing(ctx)
end

-- Bouton de mode (radio stylé en carte)
local function mode_card(i, data)
  local selected = (mode_sel == i)
  local draw = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y = reaper.ImGui_GetCursorScreenPos(ctx)
  local avail = reaper.ImGui_GetContentRegionAvail(ctx)
  local h = 40

  -- Fond de la carte
  local bg   = selected and BG_HOVER or BG_PANEL
  local bord  = selected and ACCENT   or BG_HOVER
  reaper.ImGui_DrawList_AddRectFilled(draw, x, y, x+avail, y+h, bg, 6)
  reaper.ImGui_DrawList_AddRect(draw,      x, y, x+avail, y+h, bord, 6, nil, selected and 1.5 or 0.8)

  -- Barre accent gauche si sélectionné
  if selected then
    reaper.ImGui_DrawList_AddRectFilled(draw, x, y+4, x+3, y+h-4, ACCENT, 2)
  end

  -- Clic invisible sur toute la carte
  reaper.ImGui_SetCursorScreenPos(ctx, x, y)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),        0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(), 0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),  0x00000000)
  if reaper.ImGui_Button(ctx, '##mode'..i, avail, h) then
    mode_sel = i
  end
  reaper.ImGui_PopStyleColor(ctx, 3)

  -- Icône + texte par-dessus
  local icon_col = selected and ACCENT or TEXT_DIM
  reaper.ImGui_DrawList_AddText(draw, x+12, y+10, icon_col, data.icon)
  reaper.ImGui_DrawList_AddText(draw, x+32, y+6,  selected and TEXT or TEXT_DIM, data.label)
  reaper.ImGui_DrawList_AddText(draw, x+32, y+22, TEXT_DIM, data.desc)

  reaper.ImGui_SetCursorScreenPos(ctx, x, y+h+4)
end

-- Checkbox stylée
local function env_checkbox(label, val)
  local draw = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y = reaper.ImGui_GetCursorScreenPos(ctx)
  local sz = 18
  local bg = val and ACCENT or BG_MED
  reaper.ImGui_DrawList_AddRectFilled(draw, x, y+1, x+sz, y+sz+1, bg, 4)
  if val then
    reaper.ImGui_DrawList_AddText(draw, x+3, y+2, 0xFFFFFFFF, "✓")
  end
  reaper.ImGui_SetCursorScreenPos(ctx, x, y)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBg(),        0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgHovered(), 0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_FrameBgActive(),  0x00000000)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_CheckMark(),      0x00000000)
  local _, new = reaper.ImGui_Checkbox(ctx, label, val)
  reaper.ImGui_PopStyleColor(ctx, 4)
  return new
end

-- Bouton principal large
local function action_button(label, w, h, col)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Button(),        col)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonHovered(),
    (col == ACCENT) and 0xFF8A5AFF or 0xFF5030D0FF)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_ButtonActive(),  0xFF3A20A0FF)
  local clicked = reaper.ImGui_Button(ctx, label, w, h)
  reaper.ImGui_PopStyleColor(ctx, 3)
  return clicked
end

-- ── logique principale ────────────────────────────────────────
local function run_clear()
  -- Vérifications
  local s, e = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if s == e then
    status_msg = " Faites d'abord une sélection temporelle !"
    status_ok  = false ; return
  end
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then
    status_msg = "⚠  Sélectionnez une piste !"
    status_ok  = false ; return
  end
  if not env_pan and not env_vol and not env_wid then
    status_msg = " Cochez au moins une enveloppe !"
    status_ok  = false ; return
  end

  reaper.Undo_BeginBlock()
  local _, end_view = reaper.GetSet_ArrangeView2(0, false, 0, 0, 0)
  local session_end = math.max(end_view, reaper.GetProjectLength(0) + 100)

  local env_names = {}
  if env_vol then table.insert(env_names, "Volume") end
  if env_pan then table.insert(env_names, "Pan")    end
  if env_wid then table.insert(env_names, "Width")  end

  local count = 0
  for _, name in ipairs(env_names) do
    local env = reaper.GetTrackEnvelopeByName(track, name)
    if env then
      if     mode_sel == 1 then reaper.DeleteEnvelopePointRange(env, s, e)
      elseif mode_sel == 2 then reaper.DeleteEnvelopePointRange(env, 0, s)
      elseif mode_sel == 3 then reaper.DeleteEnvelopePointRange(env, e, session_end)
      elseif mode_sel == 4 then
        if s > 0            then reaper.DeleteEnvelopePointRange(env, 0, s)            end
        if e < session_end  then reaper.DeleteEnvelopePointRange(env, e, session_end)  end
      elseif mode_sel == 5 then reaper.DeleteEnvelopePointRange(env, 0, session_end)
      end
      reaper.Envelope_SortPoints(env)
      count = count + 1
    end
  end

  reaper.Undo_EndBlock("Clear automation", -1)
  reaper.UpdateArrange()

  local names_str = table.concat(env_names, ", ")
  if count > 0 then
    status_msg = "✅  "..count.." enveloppe(s) nettoyée(s)  —  "..
                 MODE_LABELS[mode_sel].label.."  ["..names_str.."]"
    status_ok  = true
  else
    status_msg = "ℹ  Aucune enveloppe trouvée sur la piste."
    status_ok  = false
  end
end

-- ── boucle de rendu ──────────────────────────────────────────
local function loop()
  push_style()

  reaper.ImGui_SetNextWindowSize(ctx, WIN_W, WIN_H, reaper.ImGui_Cond_Once())
  reaper.ImGui_SetNextWindowPos(ctx, 200, 200, reaper.ImGui_Cond_Once())

  local vis, open = reaper.ImGui_Begin(ctx, ' ⬡  CLEAR AUTOMATION', true,
    reaper.ImGui_WindowFlags_NoResize())

  if vis then
    -- ── Titre décoratif ──
    local draw = reaper.ImGui_GetWindowDrawList(ctx)
    local wx, wy = reaper.ImGui_GetWindowPos(ctx)
    reaper.ImGui_DrawList_AddRectFilled(draw, wx, wy+20, wx+WIN_W, wy+52,
      BG_MED, 0)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), ACCENT)
    reaper.ImGui_SetCursorPosY(ctx, 28)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_Text(ctx, "Clear Automation")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), TEXT_DIM)
    reaper.ImGui_Text(ctx, "Supprime les points d'enveloppe de la piste sélectionnée")
    reaper.ImGui_PopStyleColor(ctx, 1)
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Section MODE ──
    section_header("MODE D'EFFACEMENT")
    for i, data in ipairs(MODE_LABELS) do
      mode_card(i, data)
    end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Section ENVELOPPES ──
    section_header("ENVELOPPES")
    reaper.ImGui_SetCursorPosX(ctx, 16)

    reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_ItemSpacing(), 20, 0)
    env_vol = env_checkbox("  Volume", env_vol)
    reaper.ImGui_SameLine(ctx)
    env_pan = env_checkbox("  Pan",    env_pan)
    reaper.ImGui_SameLine(ctx)
    env_wid = env_checkbox("  Width",  env_wid)
    reaper.ImGui_PopStyleVar(ctx, 1)

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- ── Bouton CLEAR ──
    local avail = reaper.ImGui_GetContentRegionAvail(ctx)
    reaper.ImGui_SetCursorPosX(ctx, 16)
    if action_button("  ⬡  CLEAR", avail, 36, ACCENT) then
      run_clear()
    end

    -- ── Barre de statut ──
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

  if open then
    reaper.defer(loop)
  end
end

-- ── démarrage ────────────────────────────────────────────────
reaper.defer(loop)
