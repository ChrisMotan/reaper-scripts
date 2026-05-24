-- @description Short film project manager
-- @author ChrisMotan
-- @version 1.0
-- @about
--   Navigate a short film project folder structure and open .rpp files directly.
--   Edit the court_metrage_path variable at the top of the script.
--   Requires ReaImGui.
-- ============================================================
--  Licence : CC BY-NC-SA 4.0
--  © 2026 ZoundZikProd
--  Free to use and modify.
--  Non-commercial redistribution only.
--  Any modified version must be shared under the same license.
--  https://creativecommons.org/licenses/by-nc-sa/4.0/
-- ============================================================

-- Gestionnaire de projets Court-Métrage
-- Niveau 1 : dossiers *_CX  (ex: MON_FILM_C1, MON_FILM_C2)
-- Niveau 2 : dossier unique *_Zik  (ex: MON_FILM_Zik)
-- Niveau 3 : dossiers sceneXXA[V]  →  fichiers .rpp / .txt

-- ⚙️  CONFIGURATION — modifie ce chemin pour pointer vers ton dossier de projets :
--   Windows : "D:\\MES_PROJETS\\COURT_METRAGE"
--   macOS   : "/Users/ton_nom/Projets/Court_Metrage"
--   Linux   : "/home/ton_nom/Projets/Court_Metrage"
--
-- Structure attendue :
--   COURT_METRAGE/
--     PROJET_NOM_C1/         ← dossier de projet (suffixe _CX)
--       NOM_Zik/             ← dossier musique (suffixe _Zik)
--         scene01A/          ← dossier de scène
--           scene01A.rpp     ← projet REAPER
--
local court_metrage_path = "D:\\MES_PROJETS\\COURT_METRAGE"  -- ← À MODIFIER

-- ─────────────────────────────────────────────
--  Utilitaires filesystem
-- ─────────────────────────────────────────────

local function list_subdirs(path)
  local dirs = {}
  local h = io.popen('dir "' .. path .. '" /b /ad 2>nul')
  if not h then return dirs end
  for name in h:lines() do dirs[#dirs + 1] = name end
  h:close()
  return dirs
end

local function list_files(path)
  local files = {}
  local h = io.popen('dir "' .. path .. '" /b /a-d 2>nul')
  if not h then return files end
  for name in h:lines() do files[#files + 1] = name end
  h:close()
  return files
end

-- ─────────────────────────────────────────────
--  Trouve les dossiers *_CX au niveau racine
-- ─────────────────────────────────────────────

local function get_cx_projects(root)
  local list = {}
  for _, name in ipairs(list_subdirs(root)) do
    if name:match("_C%d+$") then
      list[#list + 1] = { name = name, path = root .. "\\" .. name }
    end
  end
  return list
end

-- ─────────────────────────────────────────────
--  Trouve le dossier unique *_Zik
-- ─────────────────────────────────────────────

local function get_zik_folder(cx_path)
  for _, name in ipairs(list_subdirs(cx_path)) do
    if name:match("_[Zz][Ii][Kk]$") then
      return { name = name, path = cx_path .. "\\" .. name }
    end
  end
  return nil
end

-- ─────────────────────────────────────────────
--  Parse un nom de dossier scène
--  Ex: scene03BV  →  num="03", ver="B", validated=true
-- ─────────────────────────────────────────────

local function parse_scene_dirname(dirname)
  local num2, rest = dirname:match("^[Ss]cene(%d+)([A-Za-z]+)$")
  if num2 and rest then
    rest = rest:upper()
    if rest:sub(-1) == "V" and #rest > 1 then
      return num2, rest:sub(1, -2), true
    else
      return num2, rest, false
    end
  end
  return nil, nil, nil
end

-- ─────────────────────────────────────────────
--  FullMix : scan du dossier scène validée
--  Retourne une liste de tous les .wav trouvés
--  avec leur label (FullMix / Instrus / nom brut)
-- ─────────────────────────────────────────────

local function find_fullmix_wavs(scene_path)
  local results = {}
  for _, dirname in ipairs(list_subdirs(scene_path)) do
    if dirname:match("[Ff]ull[Mm]ix") then
      local fullmix_path = scene_path .. "\\" .. dirname
      for _, fname in ipairs(list_files(fullmix_path)) do
        if fname:lower():match("%.wav$") then
          -- Détermine le label du bouton
          local label
          local fname_upper = fname:upper()
          if fname_upper:match("INSTRU") then
            label = " Instrus"
          else
            label = " FullMix"
          end
          results[#results + 1] = {
            path  = fullmix_path .. "\\" .. fname,
            name  = fname,
            label = label,
          }
        end
      end
    end
  end
  return results
end

-- ─────────────────────────────────────────────
--  Scanne et groupe les scènes par numéro
-- ─────────────────────────────────────────────

local function get_scene_groups(zik_path)
  local raw = {}

  for _, dirname in ipairs(list_subdirs(zik_path)) do
    local num, ver, validated = parse_scene_dirname(dirname)
    if num then
      local scene_path = zik_path .. "\\" .. dirname
      local rpp_file, txt_file = nil, nil
      for _, fname in ipairs(list_files(scene_path)) do
        if fname:match("%.rpp$") then rpp_file = fname end
        if fname:match("%.txt$") then txt_file = fname end
      end
      if rpp_file then
        raw[#raw + 1] = {
          num        = tonumber(num),
          num_str    = num,
          ver        = ver,
          validated  = validated,
          filepath   = scene_path .. "\\" .. rpp_file,
          txtpath    = txt_file and (scene_path .. "\\" .. txt_file) or nil,
          rpp_name   = rpp_file,
          scene_path = scene_path,
        }
      end
    end
  end

  -- Tri : numéro puis version
  table.sort(raw, function(a, b)
    if a.num ~= b.num then return a.num < b.num end
    return a.ver < b.ver
  end)

  -- Groupement par numéro
  local groups = {}
  local idx_by_num = {}
  for _, entry in ipairs(raw) do
    local key = entry.num
    if not idx_by_num[key] then
      groups[#groups + 1] = {
        num      = entry.num,
        num_str  = entry.num_str,
        versions = {},
      }
      idx_by_num[key] = #groups
    end
    local g = groups[idx_by_num[key]]
    g.versions[#g.versions + 1] = {
      ver        = entry.ver,
      validated  = entry.validated,
      filepath   = entry.filepath,
      txtpath    = entry.txtpath,
      rpp_name   = entry.rpp_name,
      scene_path = entry.scene_path,
    }
  end

  return groups
end

-- ─────────────────────────────────────────────
--  Reaper helpers
-- ─────────────────────────────────────────────

local function open_in_tab(filepath)
  local i = 0
  while true do
    local proj, projpath = reaper.EnumProjects(i)
    if not proj then break end
    if projpath:lower() == filepath:lower() then
      reaper.SelectProjectInstance(proj)
      return
    end
    i = i + 1
  end
  reaper.Main_OnCommand(40859, 0)
  reaper.Main_openProject(filepath)
end

local function open_txt(txtpath)
  os.execute('start "" "' .. txtpath .. '"')
end

local function is_open(filepath)
  local i = 0
  while true do
    local proj, projpath = reaper.EnumProjects(i)
    if not proj then break end
    if projpath:lower() == filepath:lower() then return true end
    i = i + 1
  end
  return false
end

local function open_wav_in_new_tab(wav_path)
  reaper.Main_OnCommand(40859, 0)
  reaper.InsertTrackAtIndex(0, true)
  local track = reaper.GetTrack(0, 0)
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "FullMix — Mastering", true)
  reaper.InsertMedia(wav_path, 0)
end

-- ─────────────────────────────────────────────
--  Point d'entrée
-- ─────────────────────────────────────────────

local cx_projects = get_cx_projects(court_metrage_path)

if #cx_projects == 0 then
  reaper.ShowMessageBox(
    "Aucun dossier *_CX trouvé dans :\n" .. court_metrage_path,
    "Aucun projet", 0
  )
  return
end

-- ─────────────────────────────────────────────
--  UI
-- ─────────────────────────────────────────────

local function show_ui(cx_projects)
  local ctx = reaper.ImGui_CreateContext("Gestionnaire Court-Métrage")

  local screen      = "choose_cx"
  local cx_selected = 1
  local current_cx  = nil
  local current_zik = nil
  local groups      = {}
  local checked     = {}
  local open        = true
  local error_msg   = nil

  -- Couleurs
  local COL_VALIDATED = 0x00FF88FF
  local COL_OPEN      = 0xFFFF00FF
  local COL_HEADER    = 0xAAFFAAFF
  local COL_GROUP     = 0xFFFFFFFF
  local COL_FULLMIX   = 0xFF8800FF
  local COL_INSTRUS   = 0xFF44CCFF

  -- ── Chargement projet + scan FullMix en cache ─────────────────────────
  local function load_project(cx)
    current_cx = cx
    local zik  = get_zik_folder(cx.path)
    if not zik then
      error_msg   = "Aucun dossier *_Zik trouvé dans :\n" .. cx.path
      current_zik, groups, checked = nil, {}, {}
      return false
    end
    current_zik = zik
    groups      = get_scene_groups(zik.path)
    checked     = {}
    for gi, g in ipairs(groups) do
      checked[gi] = {}
      for vi, v in ipairs(g.versions) do
        checked[gi][vi] = false
        -- Scan FullMix UNE SEULE FOIS au chargement, résultat mis en cache
        if v.validated and v.scene_path then
          v.fullmix_wavs = find_fullmix_wavs(v.scene_path)
        else
          v.fullmix_wavs = {}
        end
      end
    end
    error_msg = nil
    if #groups == 0 then
      error_msg = "Aucune scène trouvée dans :\n" .. zik.path
      return false
    end
    return true
  end

  reaper.defer(function()
    local function loop()
      if not open then return end

      -- ── Écran 1 : Choix du projet CX ──────────────────────────────────
      if screen == "choose_cx" then
        reaper.ImGui_SetNextWindowSize(ctx, 400, 280, reaper.ImGui_Cond_Always())
        local vis, _open = reaper.ImGui_Begin(ctx, "Choisir un projet", true,
                             reaper.ImGui_WindowFlags_NoResize())
        open = _open

        if vis then
          reaper.ImGui_Text(ctx, "Projets Court-Métrage disponibles :")
          reaper.ImGui_Spacing(ctx)

          for i, cx in ipairs(cx_projects) do
            if reaper.ImGui_Selectable(ctx, cx.name, cx_selected == i) then
              cx_selected = i
            end
          end

          reaper.ImGui_Spacing(ctx)
          reaper.ImGui_Separator(ctx)
          reaper.ImGui_Spacing(ctx)

          if error_msg then
            reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), 0xFF4444FF)
            reaper.ImGui_Text(ctx, error_msg)
            reaper.ImGui_PopStyleColor(ctx)
            reaper.ImGui_Spacing(ctx)
          end

          if reaper.ImGui_Button(ctx, "Ouvrir ce projet", -1, 0) then
            if load_project(cx_projects[cx_selected]) then
              screen    = "scenes"
              error_msg = nil
            end
          end

          reaper.ImGui_End(ctx)
        end

      -- ── Écran 2 : Sélection des scènes (arbre groupé) ─────────────────
      elseif screen == "scenes" then
        reaper.ImGui_SetNextWindowSize(ctx, 680, 560, reaper.ImGui_Cond_Always())
        local vis, _open = reaper.ImGui_Begin(ctx, "Scènes — " .. current_cx.name, true,
                             reaper.ImGui_WindowFlags_NoResize())
        open = _open

        if vis then
          -- En-tête
          reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_HEADER)
          reaper.ImGui_Text(ctx, "Projet  : " .. current_cx.name)
          reaper.ImGui_Text(ctx, "Dossier : " .. current_zik.name)
          reaper.ImGui_PopStyleColor(ctx)

          -- Légende
          reaper.ImGui_Spacing(ctx)
          reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_VALIDATED)
          reaper.ImGui_Text(ctx, "✔ = validée")
          reaper.ImGui_PopStyleColor(ctx)
          reaper.ImGui_SameLine(ctx)
          reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_OPEN)
          reaper.ImGui_Text(ctx, "  ● = ouverte")
          reaper.ImGui_PopStyleColor(ctx)
          reaper.ImGui_SameLine(ctx)
          reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_FULLMIX)
          reaper.ImGui_Text(ctx, "  ◈ FullMix")
          reaper.ImGui_PopStyleColor(ctx)
          reaper.ImGui_SameLine(ctx)
          reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_INSTRUS)
          reaper.ImGui_Text(ctx, "  ◈ Instrus")
          reaper.ImGui_PopStyleColor(ctx)

          reaper.ImGui_Separator(ctx)
          reaper.ImGui_Spacing(ctx)

          for gi, g in ipairs(groups) do
            local node_label = "Scene " .. g.num_str
            if #g.versions > 1 then
              node_label = node_label .. "  (" .. #g.versions .. " versions)"
            end

            reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_GROUP)
            local node_open = reaper.ImGui_TreeNode(ctx,
              node_label .. "##grp" .. gi,
              reaper.ImGui_TreeNodeFlags_DefaultOpen()
            )
            reaper.ImGui_PopStyleColor(ctx)

            if node_open then
              for vi, v in ipairs(g.versions) do
                local already_open = is_open(v.filepath)

                reaper.ImGui_Indent(ctx, 12)

                if already_open then
                  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_OPEN)
                elseif v.validated then
                  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_VALIDATED)
                end

                local ver_label = "ver. " .. v.ver .. "  —  " .. v.rpp_name
                if v.validated then ver_label = ver_label .. "  ✔" end

                local rv, val = reaper.ImGui_Checkbox(
                  ctx, ver_label .. "##chk" .. gi .. "_" .. vi, checked[gi][vi]
                )
                if rv then checked[gi][vi] = val end

                if already_open or v.validated then
                  reaper.ImGui_PopStyleColor(ctx)
                end

                if already_open then
                  reaper.ImGui_SameLine(ctx)
                  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), COL_OPEN)
                  reaper.ImGui_Text(ctx, "● ouvert")
                  reaper.ImGui_PopStyleColor(ctx)
                end

                if v.txtpath then
                  reaper.ImGui_SameLine(ctx)
                  if reaper.ImGui_Button(ctx, "TXT##txt" .. gi .. "_" .. vi, 30, 0) then
                    open_txt(v.txtpath)
                  end
                  if reaper.ImGui_IsItemHovered(ctx) then
                    reaper.ImGui_BeginTooltip(ctx)
                    reaper.ImGui_Text(ctx, "Ouvrir : " .. v.txtpath)
                    reaper.ImGui_EndTooltip(ctx)
                  end
                end

                -- ── Boutons FullMix/Instrus (un par .wav trouvé) ───────
                for wi, wav in ipairs(v.fullmix_wavs) do
                  reaper.ImGui_SameLine(ctx)
                  local col = wav.label:match("Instrus") and COL_INSTRUS or COL_FULLMIX
                  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), col)
                  local btn_id = wav.label .. "##fm" .. gi .. "_" .. vi .. "_" .. wi
                  if reaper.ImGui_Button(ctx, btn_id, wav.label:match("Instrus") and 75 or 80, 0) then
                    local answer = reaper.ShowMessageBox(
                      "Ouvrir dans un nouvel onglet pour le mastering ?\n\n" .. wav.name,
                      "FullMix — Mastering", 4
                    )
                    if answer == 6 then
                      open_wav_in_new_tab(wav.path)
                    end
                  end
                  reaper.ImGui_PopStyleColor(ctx)
                  if reaper.ImGui_IsItemHovered(ctx) then
                    reaper.ImGui_BeginTooltip(ctx)
                    reaper.ImGui_Text(ctx, wav.path)
                    reaper.ImGui_EndTooltip(ctx)
                  end
                end

                reaper.ImGui_Unindent(ctx, 12)
              end

              reaper.ImGui_TreePop(ctx)
            end
          end

          reaper.ImGui_Spacing(ctx)
          reaper.ImGui_Separator(ctx)
          reaper.ImGui_Spacing(ctx)

          if reaper.ImGui_Button(ctx, "Ouvrir la sélection", -1, 0) then
            local count = 0
            for gi, g in ipairs(groups) do
              for vi, v in ipairs(g.versions) do
                if checked[gi][vi] then
                  open_in_tab(v.filepath)
                  count = count + 1
                end
              end
            end
            if count == 0 then
              reaper.ShowMessageBox("Aucune scène sélectionnée.", "Info", 0)
            else
              for gi = 1, #groups do
                for vi = 1, #groups[gi].versions do
                  checked[gi][vi] = false
                end
              end
            end
          end

          reaper.ImGui_Spacing(ctx)

          if reaper.ImGui_Button(ctx, "◀  Changer de projet", -1, 0) then
            screen  = "choose_cx"
            groups  = {}
            checked = {}
          end

          reaper.ImGui_End(ctx)
        end
      end

      if open then
        reaper.defer(loop)
      else
        if reaper.ImGui_DestroyContext then
          reaper.ImGui_DestroyContext(ctx)
        end
      end
    end
    loop()
  end)
end

show_ui(cx_projects)
