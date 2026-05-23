-- @description Random automation generator for selected track
-- @author ChrisMotan
-- @version 1.0
-- @about
--   Generates random automation points on Volume, Pan and/or Width
--   envelopes within the time selection.
--   No ReaImGui required.
-- ============================================================
--  Licence : CC BY-NC-SA 4.0
--  © 2026 ZoundZikProd
--  Free to use and modify.
--  Non-commercial redistribution only.
--  Any modified version must be shared under the same license.
--  https://creativecommons.org/licenses/by-nc-sa/4.0/
-- ============================================================

math.randomseed(os.time())

-- ==========================================
-- FONCTION DE GÉNÉRATION
-- ==========================================
local function generate_random(params)
    
    local start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    
    if start_time == end_time then
        reaper.ShowMessageBox("Définis une time selection !", "Erreur", 0)
        return false
    end
    
    local track = reaper.GetSelectedTrack(0,0)
    if not track then
        reaper.ShowMessageBox("Sélectionne une piste !", "Erreur", 0)
        return false
    end
    
    reaper.Undo_BeginBlock()
    
    -- Calcul de l'espacement
    local total_time = end_time - start_time
    local spacing = params.spacing
    
    if params.use_spacing == 0 then
        if params.num_points > 1 then
            spacing = total_time / (params.num_points - 1)
        else
            spacing = total_time
        end
    end
    
    -- Récupération des enveloppes
    local pan_env = params.pan_on and reaper.GetTrackEnvelopeByName(track, "Pan") or nil
    local vol_env = params.vol_on and reaper.GetTrackEnvelopeByName(track, "Volume") or nil
    local width_env = params.width_on and reaper.GetTrackEnvelopeByName(track, "Width") or nil
    
    -- PAN
    if pan_env then
        reaper.DeleteEnvelopePointRange(pan_env, start_time, end_time)
        local time = start_time
        for i = 1, params.num_points do
            local pan_val = (math.random() * 2 - 1) * params.pan_amp
            reaper.InsertEnvelopePoint(pan_env, time, pan_val, 0, 0, false, true)
            time = time + spacing
        end
        reaper.Envelope_SortPoints(pan_env)
    end
    
    -- WIDTH
    if width_env then
        reaper.DeleteEnvelopePointRange(width_env, start_time, end_time)
        local time = start_time
        for i = 1, params.num_points do
            local width_val = (math.random() * 2 - 1) * params.width_amp
            reaper.InsertEnvelopePoint(width_env, time, width_val, 0, 0, false, true)
            time = time + spacing
        end
        reaper.Envelope_SortPoints(width_env)
    end
    
    -- VOLUME
    if vol_env then
        reaper.DeleteEnvelopePointRange(vol_env, start_time, end_time)
        local scaling_mode = reaper.GetEnvelopeScalingMode(vol_env)
        local time = start_time
        for i = 1, params.num_points do
            local random_db = params.vol_min_db + (math.random() * (params.vol_max_db - params.vol_min_db))
            local scaled_value = reaper.ScaleToEnvelopeMode(scaling_mode, random_db)
            reaper.InsertEnvelopePoint(vol_env, time, scaled_value, 0, 0, false, true)
            time = time + spacing
        end
        reaper.Envelope_SortPoints(vol_env)
    end
    
    reaper.Undo_EndBlock("Generate Random Automation", -1)
    reaper.UpdateArrange()
    return true
end

-- ==========================================
-- INTERFACE SIMPLE QUI RESTE OUVERTE
-- ==========================================
local params = {
    pan_on = true,
    vol_on = true,
    width_on = true,
    num_points = 16,
    use_spacing = 0,  -- 0 = auto, 1 = manuel
    spacing = 0.25,
    pan_amp = 1.0,      -- (déjà divisé, 1.0 = 100%)
    vol_min_db = 0,
    vol_max_db = 6,
    width_amp = 1.0
}

local function show_dialog()
    
    local retval, retvals_cfg = reaper.GetUserInputs(
        "Random Automation Generator (Fenêtre persistante)",
        10,
        "Pan (y/n):,Volume (y/n):,Width (y/n):,Nb points:,Espacement (0=auto 1=man):,Espacement (sec):,Pan %:,Vol min (dB):,Vol max (dB):,Width %:",
        string.format("%s,%s,%s,%d,%d,%.2f,%d,%.0f,%.0f,%d",
            params.pan_on and "y" or "n",
            params.vol_on and "y" or "n",
            params.width_on and "y" or "n",
            params.num_points,
            params.use_spacing,
            params.spacing,
            params.pan_amp * 100,
            params.vol_min_db,
            params.vol_max_db,
            params.width_amp * 100
        )
    )
    
    if retval then
        -- L'utilisateur a cliqué sur OK
        local pan_str, vol_str, width_str,
              num_str, use_spacing_str, spacing_str,
              pan_amp_str, vol_min_str, vol_max_str, width_amp_str =
              retvals_cfg:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
        
        if pan_str then
            -- Mise à jour des paramètres
            params.pan_on = pan_str:lower() == "y"
            params.vol_on = vol_str:lower() == "y"
            params.width_on = width_str:lower() == "y"
            params.num_points = tonumber(num_str) or params.num_points
            params.use_spacing = tonumber(use_spacing_str) or params.use_spacing
            params.spacing = tonumber(spacing_str) or params.spacing
            params.pan_amp = (tonumber(pan_amp_str) or 100) / 100
            params.vol_min_db = tonumber(vol_min_str) or params.vol_min_db
            params.vol_max_db = tonumber(vol_max_str) or params.vol_max_db
            params.width_amp = (tonumber(width_amp_str) or 100) / 100
            
            -- Vérification
            if params.vol_min_db >= params.vol_max_db then
                reaper.ShowMessageBox(
                    "Le volume max ("..params.vol_max_db.." dB) doit être supérieur au volume min ("..params.vol_min_db.." dB) !",
                    "Erreur", 0)
            else
                -- Génération
                generate_random(params)
            end
        end
        
        -- Rappeler la fonction pour que la fenêtre reste ouverte
        reaper.defer(show_dialog)
    else
        -- L'utilisateur a cliqué sur Cancel (ou fermé la fenêtre)
        -- Ne rien faire, le script se termine
    end
end

-- ==========================================
-- DÉMARRAGE
-- ==========================================
reaper.defer(show_dialog)
