-- @description Mix and mastering cheat sheet by instrument and genre
-- @author ChrisMotan
-- @version 1.0
-- @about
--   Reference interface with recommended EQ, compression and reverb settings
--   for each instrument, organized by musical genre.
--   Requires ReaImGui.
-- ============================================================
--  Licence : CC BY-NC-SA 4.0
--  © 2026 ZoundZikProd
--  Free to use and modify.
--  Non-commercial redistribution only.
--  Any modified version must be shared under the same license.
--  https://creativecommons.org/licenses/by-nc-sa/4.0/
-- ============================================================

-- ══════════════════════════════════════════════════════════════════════
--  ZoundZikProd — Pense-Bête Mix & Master
--  Plug-ins : LA2A Gray · 1176 Rev A · SSL 4000E · Tranche Console
--             ReaEQ · Ozone 11 EQ · Raum · Lexicon 224
--             Fairchild 670 / CompDiode 609 (mastering)
-- ══════════════════════════════════════════════════════════════════════

local DATA = {}

-- ══════════════ ROCK ══════════════
DATA["Rock"] = {
  instruments = {
    { name = "DRUMS", subs = {
      { name = "Kick", eq = {
          "SSL 4000E / ReaEQ",
          "HPF : ~30 Hz (coupe sub inutile)",
          "Cut : ~300-400 Hz  (-3 à -6 dB, enlève le carton)",
          "Boost : ~60-80 Hz  (+3 dB, corps/punch)",
          "Boost : ~3-5 kHz   (+2 dB, attaque/clic)",
          "LPF optionnel : ~10 kHz",
        }, comp = {
          "1176 Rev A — Attack : 20-40 ms | Release : Auto ou 100 ms",
          "Ratio : 4:1 | GR : 4-8 dB",
          "LA2A en série léger en option (limiting doux 2-3 dB)",
        }, rev = {
          "Room très courte ou dry (decay < 0.5s)",
        }, notes = {
          "Parallel compression (NY) très efficace sur kick rock",
        }},
      { name = "Snare", eq = {
          "HPF : ~100 Hz",
          "Cut : ~200-250 Hz  (-3 dB, enlève la boîte)",
          "Boost : ~150-200 Hz (+2 dB, corps si nécessaire)",
          "Boost : ~2-3 kHz   (+3 dB, claquant)",
          "Boost : ~8-10 kHz  (+2 dB, air/brillance)",
        }, comp = {
          "1176 Rev A — Attack : 5-15 ms | Release : 40-80 ms",
          "Ratio : 4:1 à 8:1 | GR : 6-10 dB",
        }, rev = {
          "Raum Room ou Hall court, decay 0.8-1.2s",
          "Pre-delay : 10-20 ms",
        }, notes = { "Gate avant compresseur recommandé" }},
      { name = "Hi-Hats", eq = {
          "HPF : ~300-400 Hz",
          "Boost léger : ~8-12 kHz (+1-2 dB, air)",
          "Cut : ~1-2 kHz si harshness",
        }, comp = { "Léger ou aucun — SSL 4000E : Ratio 2:1, GR < 3 dB" },
          rev = { "Très court ou aucun" },
          notes = { "De-esser possible sur Overhead si sibilance" }},
      { name = "Overhead / Room", eq = {
          "HPF : ~80-100 Hz",
          "Boost : ~10-12 kHz (+2 dB, air cymbales)",
          "Cut : ~400-600 Hz  (-3 dB, clarté)",
        }, comp = { "LA2A Gray — GR léger 2-4 dB, glue naturelle" },
          rev = { "Souvent aucune — la room naturelle suffit" },
          notes = { "Phantom center pour cohérence stéréo" }},
      { name = "Toms", eq = {
          "HPF : ~80 Hz (selon fondamentale)",
          "Boost : fondamentale tom (+3 dB, corps)",
          "Cut : ~200-400 Hz  (-3 dB, carton)",
          "Boost : ~3-5 kHz   (+2 dB, attaque)",
        }, comp = { "1176 ou SSL : Attack 10-30 ms | Release 100-200 ms | Ratio 4:1 | GR 4-8 dB" },
          rev = { "Raum Room court, decay 0.4-0.8s" },
          notes = { "Gate souvent nécessaire" }},
    }},
    { name = "BASSE", ask_synth = true, subs = {
      { name = "Basse électrique", eq = {
          "Tranche Console / SSL 4000E",
          "HPF : ~40 Hz",
          "Boost : ~60-80 Hz   (+2 dB, sub/poids)",
          "Boost : ~100-120 Hz (+2 dB, corps)",
          "Cut : ~200-300 Hz   (-3 dB, boue)",
          "Boost : ~700-900 Hz (+1-2 dB, présence médium)",
          "Boost : ~2-3 kHz    (+2 dB, définition/grunge)",
        }, comp = {
          "LA2A Gray (program-dependent) : GR 6-10 dB — très musical",
          "OU 1176 Rev A : Ratio 4:1, Attack 20-40 ms, Release 200-400 ms",
        }, rev = { "Aucune sur la basse rock" },
          notes = { "Sidechainage kick→basse recommandé" }},
      { name = "Basse Synthé", is_synth = true, eq = {
          "HPF : ~30 Hz",
          "Boost : ~50-80 Hz   (sub, avec spectrum analyzer)",
          "Cut : ~200-400 Hz selon timbre synth",
          "Boost/Cut : ~1-2 kHz selon besoin de présence",
        }, comp = {
          "1176 Rev A : Ratio 8:1, Attack 10-20 ms, Release auto",
          "Limiting léger en sortie pour sub control",
        }, rev = { "Aucune ou très court pre-delay sans queue" },
          notes = { "Attention clash fréquentiel avec kick" }},
    }},
    { name = "GUITARES", subs = {
      { name = "Guitare élec. rythmique", eq = {
          "HPF : ~80-100 Hz",
          "Cut : ~200-300 Hz  (-3 à -6 dB, boue)",
          "Boost : ~2-4 kHz   (+2-3 dB, présence/mordant)",
          "Cut : ~1 kHz léger si nasal",
        }, comp = { "SSL 4000E : Ratio 2:1 à 4:1, Attack 10-30 ms, GR 2-4 dB" },
          rev = { "Raum Room court (decay 0.3-0.6s), mix 10-15%" },
          notes = { "Double tracking ou hard-pan L/R souvent utilisé" }},
      { name = "Guitare élec. lead / solo", eq = {
          "HPF : ~120 Hz",
          "Boost : ~1-2 kHz (+3 dB, présence dans le mix)",
          "Boost : ~5-8 kHz  (+2 dB, brillance/air)",
        }, comp = { "1176 Rev A : Ratio 4:1 à 8:1, Attack 5-10 ms, Release 100-200 ms, GR 4-8 dB" },
          rev = {
            "Lexicon 224 : Plate/Hall, decay 1.2-2.0s",
            "Pre-delay 20-30 ms, mix 20-30%",
          }, notes = { "Délai quarter-note souvent sur la lead" }},
      { name = "Guitare acoustique", eq = {
          "HPF : ~100-150 Hz",
          "Cut : ~200-250 Hz  (-3 dB, boomyness)",
          "Boost : ~3-5 kHz   (+2 dB, attaque/picking)",
          "Boost : ~10-12 kHz (+2 dB, air/brillance)",
        }, comp = { "LA2A Gray : GR 3-5 dB doux et naturel" },
          rev = { "Raum Room, decay 0.6-1.0s, pre-delay 15 ms" },
          notes = { "Stéréo MS ou XY selon enregistrement" }},
    }},
    { name = "VOIX", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~100-150 Hz",
          "Cut : ~200-300 Hz  (-2 à -4 dB)",
          "Boost : ~2-3 kHz   (+2-3 dB, intelligibilité)",
          "Boost : ~10-12 kHz (+2 dB, air/présence)",
          "De-esser : ~6-8 kHz si sibilance",
        }, comp = {
          "LA2A Gray en premier (glue) GR 4-6 dB",
          "1176 Rev A en série : Ratio 4:1, Attack 2-5 ms, GR 2-4 dB",
        }, rev = {
          "Lexicon 224 : Plate decay 1.5-2.5s, pre-delay 25-35 ms",
          "Raum Hall en parallèle possible",
        }, notes = {
          "Automation du volume avant compression",
          "Délai slap (80-120 ms) pour épaisseur",
        }},
      { name = "Backing vocals", eq = {
          "HPF : ~200 Hz",
          "Boost : ~3-5 kHz léger",
        }, comp = { "SSL 4000E Ratio 4:1, GR 4-6 dB" },
          rev = { "Plus de reverb que lead (recul dans mix)" },
          notes = { "Pan L/R pour l'espace" }},
    }},
  },
}

-- ══════════════ POP ══════════════
DATA["Pop"] = {
  instruments = {
    { name = "DRUMS", subs = {
      { name = "Kick", eq = {
          "SSL 4000E / ReaEQ",
          "HPF : ~40 Hz",
          "Boost : ~50-80 Hz  (+3 dB, sub-punch)",
          "Cut : ~350-400 Hz  (-4 dB, carton)",
          "Boost : ~3-5 kHz   (+3 dB, clic/attaque)",
          "Boost : ~8-10 kHz  (+1 dB, présence)",
        }, comp = { "1176 Rev A : Ratio 4:1, Attack 30-50 ms, Release 200 ms, GR 4-6 dB" },
          rev = { "Très court ou dry" },
          notes = { "Kick souvent sampleé en pop moderne" }},
      { name = "Snare", eq = {
          "HPF : ~120 Hz",
          "Boost : ~200 Hz    (+2 dB, corps)",
          "Cut : ~400-600 Hz  (-3 dB)",
          "Boost : ~5 kHz     (+3 dB, snap pop)",
          "Boost : ~12 kHz    (+2 dB, air)",
        }, comp = { "1176 Rev A : Ratio 8:1, Attack 5-10 ms, Release 50-80 ms, GR 6-8 dB" },
          rev = {
            "Lexicon 224 ou Raum : Plate/Room 0.8-1.5s",
            "Pre-delay 10-15 ms",
          }, notes = { "Reverb gated parfois utilisée (style 80s pop)" }},
      { name = "Drum Bus", eq = {
          "SSL 4000E en bus drums",
          "Boost : ~60 Hz     (+2 dB, corps global)",
          "Cut : ~300-500 Hz  (-2 dB, clarté)",
          "Boost : ~10 kHz    (+2 dB, air)",
        }, comp = { "SSL Bus style : Ratio 2:1 à 4:1, Attack 3-10 ms, Release auto, GR 2-4 dB" },
          rev = { "Bus room ambiance commune" },
          notes = { "Parallel compression sur drum bus très courant en pop" }},
    }},
    { name = "BASSE", ask_synth = true, subs = {
      { name = "Basse électrique", eq = {
          "HPF : ~40 Hz",
          "Boost : ~80-100 Hz (+2-3 dB)",
          "Cut : ~200-250 Hz  (-3 dB)",
          "Boost : ~500-700 Hz (+1-2 dB, warmth pop)",
          "Boost : ~2-3 kHz   (+2 dB, définition)",
        }, comp = { "LA2A Gray : GR 6-8 dB, très transparent" },
          rev = { "Aucune" },
          notes = { "Sidechain kick→basse fréquent en pop moderne" }},
      { name = "Basse Synthé", is_synth = true, eq = {
          "HPF : ~30 Hz (sub control)",
          "Boost : ~60-80 Hz  (sub rondeur)",
          "Cut : ~200-400 Hz  (densité)",
          "Boost/cut selon harmoniques du synth",
        }, comp = { "1176 Rev A Ratio 8:1 ou Limiting doux", "Multiband possible (Ozone 11)" },
          rev = { "Aucune" }, notes = {}},
    }},
    { name = "SYNTHS", ask_multi = true, subs = {
      { name = "Synth Pad / Atmosphère", eq = {
          "HPF : ~150-300 Hz  (laisser place basse)",
          "Cut : ~300-500 Hz si densité",
          "Boost : ~5-8 kHz   (+2 dB, shimmer/air)",
        }, comp = { "LA2A Gray très léger, GR 2-3 dB" },
          rev = { "Raum Hall long decay 2-4s", "Lexicon 224 Hall, mix 30-50%" },
          notes = { "Stéréo large, attention mono-compatibility" }},
      { name = "Synth Lead", eq = {
          "HPF : ~200 Hz",
          "Boost : ~1-3 kHz   (+3 dB, cut-through)",
          "Boost : ~8-10 kHz  (+2 dB, brillance)",
        }, comp = { "1176 Rev A : Ratio 4:1, Attack 5-10 ms, GR 4-6 dB" },
          rev = { "Lexicon 224 Plate court, decay 0.8-1.5s", "Pre-delay 20-30 ms" },
          notes = {}},
      { name = "Synth Pluck / Arpeggios", eq = {
          "HPF : ~200-300 Hz",
          "Boost : ~3-5 kHz   (attaque pluck)",
          "Couper sévèrement les graves",
        }, comp = { "SSL 4000E léger Ratio 2:1" },
          rev = { "Raum Room ou Plate court, decay 0.5-1.0s", "Délai en plus pour rythme" },
          notes = { "Automation volume/filtre souvent préférable au compresseur" }},
    }},
    { name = "VOIX", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~100-150 Hz",
          "Cut : ~200-300 Hz  (-2 dB, corps excessif)",
          "Boost : ~2-3 kHz   (+3 dB, intelligibilité pop)",
          "Boost : ~8-12 kHz  (+2-3 dB, air brillance pop)",
          "De-esser : ~7-9 kHz",
        }, comp = {
          "LA2A Gray : GR 4-6 dB",
          "1176 Rev A en série : GR 2-4 dB (peak control)",
        }, rev = {
          "Lexicon 224 Plate, decay 1.8-2.5s, pre-delay 25-30 ms",
          "Raum Hall en send parallèle, mix 15-25%",
        }, notes = {
          "Pitch correction standard en pop (Melodyne/Autotune)",
          "Double track en harmonie fréquent",
        }},
      { name = "Backing vocals", eq = { "HPF : ~250 Hz", "Boost : ~5 kHz léger" },
          comp = { "SSL Ratio 4:1, GR 4-6 dB" },
          rev = { "Plus profond que lead, decay 2-3s" },
          notes = { "Pan L/R, automations de volume" }},
    }},
    { name = "GUITARES", subs = {
      { name = "Guitare acoustique", eq = {
          "HPF : ~120 Hz",
          "Cut : ~200-250 Hz  (-3 dB)",
          "Boost : ~3-5 kHz   (+2 dB, picking)",
          "Boost : ~10-12 kHz (+2 dB, air)",
        }, comp = { "LA2A Gray GR 3-5 dB, naturel" },
          rev = { "Raum Room 0.6-1.2s, pre-delay 15 ms" }, notes = {}},
    }},
  },
}

-- ══════════════ ELECTRO POP ══════════════
DATA["Electro Pop"] = {
  instruments = {
    { name = "DRUMS / DRUM MACHINES", subs = {
      { name = "Kick électronique", eq = {
          "ReaEQ / Ozone 11 EQ",
          "HPF : ~30 Hz",
          "Boost sub : ~50-60 Hz  (+4-6 dB, PUNCH)",
          "Cut mid : ~200-400 Hz  (-6 dB, plastique)",
          "Boost click : ~3-5 kHz (+4 dB, transient)",
        }, comp = { "1176 Rev A : Ratio 8:1 à All-Buttons, Attack 1-5 ms, GR 6-10 dB" },
          rev = { "Dry ou sub-room très court (< 100 ms)" },
          notes = { "Saturation/distorsion légère pour harmoniques" }},
      { name = "Snare / Clap élec.", eq = {
          "HPF : ~200 Hz",
          "Boost : ~1-2 kHz  (+3 dB, corps électro)",
          "Boost : ~8-10 kHz (+4 dB, claque)",
        }, comp = { "1176 Ratio 8:1 : Attack 1-3 ms, Release 40-60 ms, GR 6-10 dB" },
          rev = { "Raum Plate ou Lexicon 224, decay 0.5-1.0s", "Reverb gated optionnelle" },
          notes = { "Layering de plusieurs claps/snares courant" }},
      { name = "Hi-Hats / Percus machines", eq = {
          "HPF très haut : ~500-800 Hz",
          "Boost : ~10-14 kHz (+3 dB, air métal)",
        }, comp = { "Aucun ou léger transient shaping" },
          rev = { "Court / dry pour groove serré" }, notes = {}},
    }},
    { name = "BASSE SYNTH", ask_synth = true, subs = {
      { name = "Basse synthé principale", eq = {
          "HPF : ~30 Hz",
          "Boost sub : ~50-80 Hz  (selon note fondamentale)",
          "Cut : ~150-300 Hz si conflit avec kick",
          "Boost : ~700 Hz-1 kHz  (mordant/filter resonance)",
          "Boost : ~2-3 kHz       (définition)",
        }, comp = { "1176 Rev A : Ratio 8:1, Attack 5-10 ms, très compressé", "Limiting doux en sortie (clips sub)" },
          rev = { "Aucune" },
          notes = { "Sidechain kick→basse omniprésent en electro pop", "Sub-bass séparée par LPF ~200 Hz pour contrôle" }},
      { name = "Basse Synthé variante", is_synth = true, eq = {
          "HPF : ~30 Hz",
          "Ajuster selon timbre du synthétiseur",
        }, comp = { "1176 Rev A Ratio 8:1" },
          rev = { "Aucune" }, notes = {}},
    }},
    { name = "SYNTHS", ask_multi = true, subs = {
      { name = "Synth Lead", eq = {
          "HPF : ~200-300 Hz",
          "Boost : ~2-4 kHz  (+3-4 dB, présence)",
          "Boost : ~10 kHz   (brillance synthé)",
        }, comp = { "1176 : Ratio 4:1, Attack 2-5 ms, GR 4-8 dB, caractère compressé assumé" },
          rev = { "Raum Hall/Room, decay 1.0-2.0s", "Délai synchronisé tempo (1/8 ou 1/4)" },
          notes = {}},
      { name = "Pad atmosphérique", eq = {
          "HPF : ~200 Hz",
          "Boost : ~5-8 kHz  (shimmer)",
          "Cut graves/médiums chargés",
        }, comp = { "LA2A léger ou aucun" },
          rev = { "Lexicon 224 Hall long, decay 3-6s, mix 40-60%" },
          notes = { "Stéréo imager (Ozone) pour largeur max" }},
      { name = "Plucks / Arpeggios", eq = {
          "HPF : ~300 Hz, LPF : ~12 kHz",
          "Boost : ~3-5 kHz (attaque pluck)",
        }, comp = { "Léger SSL 2:1" },
          rev = { "Raum Room, decay 0.3-0.8s", "Délai rythm. ping-pong" },
          notes = {}},
    }},
    { name = "VOIX", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~100 Hz",
          "Cut : ~200-300 Hz  (-3 dB)",
          "Boost : ~3 kHz     (+4 dB, présence electro)",
          "Boost : ~10-14 kHz (+3 dB, air brillant)",
          "De-esser : ~7-9 kHz",
        }, comp = { "LA2A Gray GR 4-6 dB", "1176 en série GR 2-4 dB" },
          rev = { "Lexicon 224 Plate, decay 1.5-2.5s", "Raum Hall en parallèle" },
          notes = {
            "Autotune hardtuned parfois esthétique volontaire",
            "Délai répétition stereo très courant",
          }},
    }},
  },
}

-- ══════════════ EDM ══════════════
DATA["EDM"] = {
  instruments = {
    { name = "DRUMS / MACHINES", subs = {
      { name = "Kick EDM", eq = {
          "Ozone 11 EQ / ReaEQ",
          "HPF : ~30 Hz",
          "SUB-BOOST : ~50-70 Hz     (+6 dB, impact physique)",
          "Cut sévère : ~200-500 Hz  (-8 à -12 dB, click + sub only)",
          "Boost clic : ~3-5 kHz     (+5-6 dB, transient)",
          "Boost présence : ~8-10 kHz (+3 dB)",
        }, comp = {
          "1176 All-buttons ou Ratio 20:1",
          "Attack 0.5-2 ms, Release 20-50 ms, GR 8-12 dB",
          "Clipping léger en sortie — courant en EDM",
        }, rev = { "Aucune — sec, percutant, impactant" },
          notes = {
            "Sub sidechain omniprésent",
            "Kick et sub-bass : même fondamentale (accord)",
          }},
      { name = "Snare / Clap", eq = {
          "HPF : ~300 Hz",
          "Boost : ~1 kHz     (+3 dB, corps)",
          "Boost : ~8-12 kHz  (+5 dB, snap bright)",
        }, comp = { "1176 Ratio 8:1 à 20:1 : Attack 1 ms, Release 20-40 ms, GR 8-12 dB" },
          rev = { "Raum ou Lexicon : Reverb gated / Plate court", "Build-ups : reverb longue en automation" },
          notes = { "Reverb cutoff à la transition = effet drop" }},
      { name = "Hi-Hats", eq = { "HPF : ~800 Hz-1 kHz", "Boost : ~12-16 kHz (air)" },
          comp = { "Transient shaping plutôt que comp" },
          rev = { "Dry pour groove, reverb automation breakdown" }, notes = {}},
    }},
    { name = "BASSE / BASS SYNTH", ask_synth = true, subs = {
      { name = "Sub Bass", eq = {
          "HPF : ~30 Hz (strict)",
          "Boost : ~50-70 Hz  (selon note)",
          "LPF : ~150-200 Hz  (pure sub)",
          "Spectrum analyser indispensable",
        }, comp = { "Limiting pur (Ozone) ou 1176 Ratio 20:1", "Niveau constant — sub dans le red = disaster" },
          rev = { "AUCUNE" },
          notes = { "Monitorer en mono impératif pour sub", "Note accordée avec le kick" }},
      { name = "Mid-Bass / Growl Bass", is_synth = true, eq = {
          "HPF : ~80-100 Hz   (sub séparé)",
          "Boost : ~150-500 Hz (corps growl/wobble)",
          "Boost : ~1-3 kHz   (harmoniques agressives)",
        }, comp = { "1176 agressif : Ratio 8:1 à 20:1, Attack 1-3 ms, Release 50-100 ms" },
          rev = { "Aucune ou sub-room très court" },
          notes = { "Sidechain kick omniprésent", "Distorsion/waveshaping partie du son" }},
    }},
    { name = "SYNTHS", ask_multi = true, subs = {
      { name = "Supersaw / Pluck Lead", eq = {
          "HPF : ~200-300 Hz",
          "Boost : ~2-4 kHz  (présence scie)",
          "Cut : ~400-800 Hz si nasal",
        }, comp = { "1176 : Ratio 4:1, Attack 2-5 ms, GR 4-8 dB" },
          rev = { "Raum Hall, decay 2-4s", "Délai stereo ping-pong synchronisé" },
          notes = { "Unison/détuning : attention mono-compatibility" }},
      { name = "Pad / Atmosphere", eq = {
          "HPF : ~300 Hz",
          "Boost : ~6-10 kHz (shimmer)",
        }, comp = { "Léger ou aucun" },
          rev = { "Lexicon 224 Hall long, decay 4-8s" }, notes = {}},
    }},
    { name = "VOIX (si présente)", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~120 Hz",
          "Cut : ~250-300 Hz  (-4 dB)",
          "Boost : ~3-4 kHz   (+4-5 dB, présence aggressive EDM)",
          "Boost : ~12-14 kHz (+3 dB, air)",
          "De-esser fort : ~7-9 kHz",
        }, comp = { "LA2A Gray GR 6-8 dB + 1176 en série GR 4-6 dB" },
          rev = { "Lexicon 224 Plate, decay 2-3s", "Délai dubby / ping-pong rythm." },
          notes = { "Reverb tail en automation avant drop" }},
    }},
  },
}

-- ══════════════ ACOUSTIQUE VOIX/GUITARES ══════════════
DATA["Acoustique Voix/Guit."] = {
  instruments = {
    { name = "VOIX 1 (principale)", subs = {
      { name = "Voix 1", eq = {
          "Tranche Console / SSL 4000E",
          "HPF : ~100-120 Hz",
          "Cut : ~200-250 Hz  (-2-3 dB, congestion)",
          "Boost : ~2-3 kHz   (+2 dB, intelligibilité)",
          "Boost : ~8-10 kHz  (+2 dB, air naturel)",
          "De-esser : ~6-7 kHz (plus doux que pop)",
        }, comp = {
          "LA2A Gray : GR 4-6 dB — très naturel, program-dep.",
          "Ratio effectif ~2:1 du LA2A parfait pour acoustique",
        }, rev = { "Raum Room naturel, decay 0.6-1.2s", "Lexicon 224 Small Hall, mix 12-20%", "Pre-delay : 15-20 ms" },
          notes = { "Moins d'EQ que les autres styles — respirer naturellement" }},
    }},
    { name = "VOIX 2 (harmonie)", subs = {
      { name = "Voix 2", eq = {
          "HPF : ~150 Hz (laisser V1 occuper les graves)",
          "Boost : ~2-3 kHz léger",
          "Boost : ~8 kHz léger",
        }, comp = { "LA2A Gray GR 4-6 dB" },
          rev = { "Même reverb que V1 (send partagé), mix légèrement plus" },
          notes = { "Pan légère L ou R (10-20°)", "Niveau légèrement sous V1" }},
    }},
    { name = "GUITARE 1 (rythmique)", subs = {
      { name = "Guitare acoustique 1", eq = {
          "HPF : ~100-120 Hz",
          "Cut : ~200-250 Hz  (-3 dB, boomy)",
          "Boost : ~3-4 kHz   (+2 dB, picking/présence)",
          "Boost : ~10-12 kHz (+2 dB, air brillant)",
        }, comp = { "LA2A Gray GR 3-5 dB — doux, naturel", "Attack slow pour ne pas écraser transient corde" },
          rev = { "Raum Room, decay 0.5-0.8s, pre-delay 10-15 ms" },
          notes = { "Pan légère gauche (-15 à -20°)" }},
    }},
    { name = "GUITARE 2 (lead/arpèges)", subs = {
      { name = "Guitare acoustique 2", eq = {
          "HPF : ~150 Hz",
          "Cut : ~250-300 Hz  (-2 dB)",
          "Boost : ~4-5 kHz   (+2-3 dB, articulation lead)",
          "Boost : ~10-12 kHz (+2 dB, air)",
        }, comp = { "LA2A Gray GR 3-5 dB" },
          rev = { "Lexicon 224 Small Hall, decay 0.8-1.2s", "Un peu plus de reverb que G1" },
          notes = { "Pan opposée à G1 (+15 à +20° droite)" }},
    }},
  },
}

-- ══════════════ REGGAE ══════════════
DATA["Reggae"] = {
  instruments = {
    { name = "DRUMS", subs = {
      { name = "Kick (One Drop — sur le 3)", eq = {
          "SSL 4000E / Tranche Console",
          "HPF : ~50 Hz",
          "Boost : ~80-100 Hz (+3 dB, corps lourd)",
          "Cut : ~300-400 Hz  (-3 dB)",
          "Boost : ~2-3 kHz   (+2 dB, attaque)",
        }, comp = { "LA2A Gray : GR 6-8 dB, très naturel" },
          rev = { "Room court (0.3-0.5s) ou dry" },
          notes = { "One Drop : Kick sur le 3, snare absente ou légère" }},
      { name = "Snare", eq = {
          "HPF : ~150 Hz",
          "Boost : ~250 Hz    (+3 dB, corps chaud reggae)",
          "Cut : ~1-2 kHz     (-2 dB, moins agressif)",
          "Boost : ~5-6 kHz   (+2 dB, crack)",
        }, comp = { "LA2A Gray : GR 4-6 dB" },
          rev = { "Raum Room chaud, decay 0.5-1.0s", "Reverb plate + delay sur snare = signature reggae" },
          notes = { "Rim shot courant en reggae" }},
    }},
    { name = "BASSE (fondation du genre)", subs = {
      { name = "Basse reggae", eq = {
          "HPF : ~40 Hz",
          "Boost : ~80-100 Hz (+4 dB, sub profond — signature reggae)",
          "Boost : ~100-150 Hz (+2 dB, corps warm)",
          "Cut : ~300-400 Hz  (-3 dB)",
          "Boost : ~700-900 Hz (+2 dB, présence mélodique)",
          "Cut : ~2-4 kHz     (moins de mordant que rock)",
        }, comp = { "LA2A Gray : GR 6-10 dB — très program-dependent = parfait pour reggae" },
          rev = { "Aucune — clarté rythmique" },
          notes = {
            "La basse EST le lead en reggae",
            "EQ chaud et profond, grosse présence sub",
          }},
    }},
    { name = "GUITARE (Skank/Offbeat)", subs = {
      { name = "Guitare élec. (Skank)", eq = {
          "HPF : ~200-300 Hz  (pas de graves sur le skank)",
          "LPF : ~6-8 kHz",
          "Boost : ~1-3 kHz   (+3 dB, morsure du skank)",
        }, comp = { "SSL 4000E Ratio 4:1, Attack 10-20 ms, GR 4-6 dB" },
          rev = { "Spring reverb typique reggae (Raum ou Lexicon 224), decay 0.4-0.8s" },
          notes = { "Pan souvent off-center L ou R", "Attaque sur le contretemps (offbeat)" }},
    }},
    { name = "PIANO / CLAVIERS", subs = {
      { name = "Piano/Rhodes (offbeat)", eq = {
          "HPF : ~150-200 Hz",
          "Boost : ~1-2 kHz   (+2 dB, warmth clavier reggae)",
          "Boost : ~5 kHz léger (présence)",
        }, comp = { "LA2A Gray : GR 3-5 dB, naturel" },
          rev = { "Lexicon 224 Small Hall ou Spring, decay 0.6-1.2s" },
          notes = { "Même jeu offbeat que la guitare skank" }},
    }},
    { name = "VOIX", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~100-150 Hz",
          "Cut : ~200-250 Hz  (-2-3 dB)",
          "Boost : ~2-3 kHz   (+2-3 dB)",
          "Boost : ~8-10 kHz  (+2 dB, air)",
        }, comp = { "LA2A Gray GR 5-8 dB — warm et naturel" },
          rev = {
            "Lexicon 224 Hall, decay 1.5-3.0s",
            "Délai en écho reggae (quarter-note ou dotted 8th)",
            "Dub echo : feedback loop long = signature dub",
          }, notes = { "Délai automatisé (long en pré-chorus, court en couplet)" }},
    }},
  },
}

-- ══════════════ FUNK ══════════════
DATA["Funk"] = {
  instruments = {
    { name = "DRUMS", subs = {
      { name = "Kick (tight, groove serré)", eq = {
          "SSL 4000E",
          "HPF : ~50 Hz",
          "Boost : ~60-80 Hz  (+3 dB, punch)",
          "Cut : ~300-400 Hz  (-4 dB)",
          "Boost : ~2-4 kHz   (+3 dB, attaque slap)",
        }, comp = { "1176 Rev A : Ratio 4:1, Attack 10-20 ms, Release 100-150 ms, GR 4-8 dB" },
          rev = { "Court Room ou dry — le funk aime le tight" },
          notes = { "Kick verrouillé avec la basse (lock)" }},
      { name = "Snare (backbeat 2 et 4)", eq = {
          "HPF : ~120 Hz",
          "Boost : ~200 Hz    (+2 dB, corps)",
          "Cut : ~400-600 Hz  (-3 dB)",
          "Boost : ~3-5 kHz   (+4 dB, CLAQUE funk)",
          "Boost : ~8-10 kHz  (+2 dB, air)",
        }, comp = { "1176 : Ratio 8:1, Attack 5-10 ms, Release 50-80 ms, GR 6-10 dB" },
          rev = { "Raum Plate très court, decay 0.4-0.7s" }, notes = {}},
      { name = "Hi-Hats (groove 16ths)", eq = {
          "HPF : ~400 Hz", "Boost : ~8-10 kHz (+2 dB)",
        }, comp = { "Léger ou aucun" }, rev = { "Dry ou très léger" },
          notes = { "Open/closed hi-hat = groove essentiel du funk" }},
    }},
    { name = "BASSE (instrument roi du funk)", subs = {
      { name = "Basse funk (slap/fingerstyle)", eq = {
          "Tranche Console / SSL 4000E",
          "HPF : ~40 Hz",
          "Boost : ~80-100 Hz (+3 dB, corps)",
          "Cut : ~200-300 Hz  (-3 dB)",
          "Boost : ~700 Hz-1 kHz (+3 dB, mordant mélodique)",
          "Boost : ~2-3 kHz   (+4 dB, SLAP — transient clic)",
          "Boost : ~5-6 kHz   (+2 dB, harmoniques corde)",
        }, comp = {
          "1176 Rev A principal : Ratio 4:1, Attack 10-20 ms, Release 150-250 ms, GR 6-10 dB",
          "LA2A en série optionnel pour glue",
        }, rev = { "Aucune — définition du groove" },
          notes = { "La basse EST le groove en funk", "Slapbass : transient très présent ~2-4 kHz" }},
    }},
    { name = "GUITARE FUNK (Wah/Staccato)", subs = {
      { name = "Guitare rythmique funk", eq = {
          "HPF : ~150-200 Hz",
          "Boost : ~1-3 kHz   (+3 dB, mordant funk)",
          "LPF : ~10 kHz",
        }, comp = { "SSL 4000E Ratio 4:1, Attack 5-10 ms, GR 4-8 dB" },
          rev = { "Raum Room court, decay 0.3-0.5s" },
          notes = { "Wah-wah : filtre passe-bande qui sweep", "Jeu staccato percussif" }},
    }},
    { name = "CUIVRES", subs = {
      { name = "Section cuivres (Trompette/Sax/Trombone)", eq = {
          "HPF : ~200-300 Hz",
          "Boost : ~1-3 kHz   (+3 dB, honk brass)",
          "Boost : ~5-8 kHz   (+2 dB, air/brillance)",
          "Cut : ~400-600 Hz si nasal",
        }, comp = { "1176 ou SSL : Ratio 4:1, Attack 5-15 ms, GR 4-6 dB" },
          rev = { "Raum Room ou Hall court, decay 0.5-1.0s" },
          notes = { "Cuivres en harmonie 3 parties standard" }},
    }},
    { name = "CLAVIERS / ORGUE", subs = {
      { name = "Rhodes / Clav", eq = {
          "HPF : ~100 Hz",
          "Boost : ~1-2 kHz   (+2 dB, mordant Rhodes)",
          "Boost : ~5 kHz     (+1 dB, présence)",
        }, comp = { "LA2A Gray GR 3-5 dB" },
          rev = { "Lexicon 224 Small Hall, decay 0.8-1.5s" }, notes = {}},
      { name = "Orgue Hammond", eq = {
          "HPF : ~80-100 Hz",
          "Cut : ~200-400 Hz  (-3 dB si dense)",
          "Boost : ~1-3 kHz   (+3 dB, growl Hammond)",
        }, comp = { "1176 ou SSL Ratio 4:1, GR 4-8 dB" },
          rev = { "Leslie cabinet (propre) + Raum léger" }, notes = {}},
    }},
    { name = "VOIX", subs = {
      { name = "Voix principale", eq = {
          "HPF : ~100-150 Hz",
          "Cut : ~200-250 Hz  (-2-3 dB)",
          "Boost : ~2-4 kHz   (+3 dB, présence funk)",
          "Boost : ~8-10 kHz  (+2 dB, air)",
        }, comp = { "LA2A Gray GR 5-8 dB", "1176 en série GR 2-4 dB" },
          rev = { "Lexicon 224 Plate court, decay 1.0-1.8s" },
          notes = { "Voix funk : energy, call-and-response", "Screams/ad-libs : automations de reverb" }},
    }},
  },
}

-- ══════════════ ORCHESTRAL ══════════════
DATA["Orchestral"] = {
  instruments = {
    { name = "BOIS", subs = {
      { name = "Piccolo", eq = {
          "HPF : ~600 Hz (aigu extrême)",
          "Boost : ~2-4 kHz  (+2 dB, brillance)",
          "Boost : ~8-12 kHz (+2 dB, air)",
          "Attention aux fréquences perçantes > 5 kHz",
        }, comp = { "LA2A Gray très léger GR 1-3 dB ou aucun" },
          rev = { "Lexicon 224 Hall long, decay 2-4s, mix 30-50%" },
          notes = { "Placement virtuel haut dans le spectre stéréo" }},
      { name = "Flûte traversière", eq = {
          "HPF : ~250-300 Hz",
          "Boost : ~2-4 kHz  (+2 dB)",
          "Boost : ~8-10 kHz (+2 dB, air flûte)",
        }, comp = { "LA2A Gray GR 1-3 dB — très discret" },
          rev = { "Lexicon 224 Hall, decay 2-3s, mix 25-40%" },
          notes = { "Pan léger gauche (tradition orchestrale)" }},
      { name = "Hautbois", eq = {
          "HPF : ~200 Hz",
          "Cut : ~400-600 Hz  (-3 dB, nasal contrôlé)",
          "Boost : ~1-2 kHz   (+2 dB, caractère oboe)",
          "Cut : ~3-5 kHz si harsh",
        }, comp = { "LA2A Gray GR 1-3 dB" },
          rev = { "Lexicon 224 Hall, decay 2-3s" },
          notes = { "Pan légèrement gauche" }},
      { name = "Clarinette", eq = {
          "HPF : ~150 Hz",
          "Boost : ~500 Hz-1 kHz (+2 dB, warmth chalumeau)",
          "Boost : ~3-4 kHz      (+2 dB, registre aigu)",
          "Cut : ~200-250 Hz     (-2 dB si boomy)",
        }, comp = { "Très léger ou aucun" },
          rev = { "Lexicon 224 Hall, decay 2-3s, mix 25-35%" },
          notes = { "Registre chalumeau vs clairon = EQ différent" }},
      { name = "Basson", eq = {
          "HPF : ~60-80 Hz",
          "Boost : ~100-200 Hz (+2-3 dB, corps profond)",
          "Boost : ~1-2 kHz    (+2 dB, mordant anche)",
          "Cut : ~300-500 Hz si boueux",
        }, comp = { "LA2A Gray GR 2-4 dB" },
          rev = { "Lexicon 224 Hall, decay 2-3s, mix 20-30%" },
          notes = { "Pan légèrement droite" }},
    }},
    { name = "CUIVRES", subs = {
      { name = "Cors (French Horns)", eq = {
          "HPF : ~100 Hz",
          "Boost : ~200-300 Hz (+2 dB, corps chaud cor)",
          "Cut : ~400-600 Hz   (-2 dB)",
          "Boost : ~1-2 kHz    (+2 dB, présence)",
        }, comp = { "LA2A Gray GR 2-4 dB" },
          rev = { "Lexicon 224 Hall long, decay 3-5s, mix 30-50%" },
          notes = { "Pan droite (tradition orchestrale)" }},
      { name = "Trompettes", eq = {
          "HPF : ~200 Hz",
          "Boost : ~1-3 kHz    (+3 dB, brillance trompette)",
          "Boost : ~5-8 kHz    (+2 dB, air)",
          "Cut : ~400-600 Hz si creux agressif",
        }, comp = { "1176 Rev A léger : Ratio 2:1, GR 2-4 dB" },
          rev = { "Lexicon 224 Hall, decay 2-4s" },
          notes = { "Pan légèrement droite" }},
      { name = "Trombones", eq = {
          "HPF : ~80-100 Hz",
          "Boost : ~150-250 Hz (+3 dB, corps trombone)",
          "Boost : ~1-2 kHz    (+2 dB, mordant)",
          "Cut : ~300-500 Hz si nasal",
        }, comp = { "LA2A Gray GR 2-4 dB" },
          rev = { "Lexicon 224 Hall, decay 2-4s, mix 30-45%" },
          notes = { "Pan centre/droite" }},
      { name = "Tuba", eq = {
          "HPF : ~40-50 Hz",
          "Boost : ~80-100 Hz  (+3 dB, fondamentale sub-grave)",
          "Boost : ~200-300 Hz (+2 dB, corps)",
          "Boost : ~1 kHz      (+2 dB, présence)",
        }, comp = { "LA2A Gray GR 2-4 dB" },
          rev = { "Lexicon 224 Hall long, decay 2-4s, mix 25-35%" },
          notes = { "Pan centre ou légèrement droite" }},
    }},
    { name = "PERCUSSIONS ORCH.", subs = {
      { name = "Timbales", eq = {
          "HPF : ~50-60 Hz",
          "Boost : ~80-150 Hz selon accord (+3 dB, résonance)",
          "Boost : ~1-2 kHz (+2 dB, attaque baguette)",
          "Cut : ~300-500 Hz si boomeux",
        }, comp = { "1176 léger : Ratio 4:1, Attack 20 ms, GR 2-4 dB" },
          rev = { "Lexicon 224 Hall, decay 2-4s" },
          notes = { "Pan arrière centre-droite (position scénique)" }},
      { name = "Grosse Caisse orch.", eq = {
          "HPF : ~40 Hz",
          "Boost : ~80-100 Hz (+4 dB, impact)",
          "Boost : ~2-3 kHz   (+2 dB, attaque)",
        }, comp = { "Léger ou aucun — impact naturel" },
          rev = { "Hall long, decay 3-5s" }, notes = {}},
      { name = "Cymbales orchestrales", eq = {
          "HPF : ~500 Hz",
          "Boost : ~5-10 kHz  (+2-3 dB, shimmer)",
          "Boost : ~12-16 kHz (+2 dB, air)",
        }, comp = { "Aucun — dynamique naturelle" },
          rev = { "Hall très long, decay 4-8s" }, notes = {}},
      { name = "Harpe", eq = {
          "HPF : ~60-80 Hz",
          "Boost : ~200-300 Hz (+2 dB, corps chaud harpe)",
          "Boost : ~3-5 kHz   (+2 dB, clair/picking)",
          "Boost : ~10 kHz    (+2 dB, air)",
        }, comp = { "LA2A Gray très léger GR 1-3 dB" },
          rev = { "Lexicon 224 Hall, decay 2-3s, mix 25-35%" },
          notes = { "Pan gauche (devant scène — tradition)" }},
    }},
    { name = "CORDES", subs = {
      { name = "Violons 1ers (mélodie)", eq = {
          "HPF : ~150-200 Hz",
          "Boost : ~2-4 kHz   (+2-3 dB, chant violon)",
          "Boost : ~8-10 kHz  (+2 dB, air brillance)",
          "Cut : ~300-500 Hz si nasal",
        }, comp = { "LA2A Gray sur bus cordes : GR 2-4 dB doux" },
          rev = { "Lexicon 224 Hall long, decay 3-5s, mix 35-50%" },
          notes = { "Pan gauche (tradition orchestrale)" }},
      { name = "Violons 2ds (harmonie)", eq = {
          "HPF : ~150-200 Hz",
          "Boost : ~1-3 kHz   (+2 dB)",
        }, comp = { "Bus cordes (partagé avec V1)" },
          rev = { "Hall, légèrement moins que V1" },
          notes = { "Pan légèrement gauche-centre" }},
      { name = "Altos", eq = {
          "HPF : ~100-150 Hz",
          "Boost : ~200-400 Hz (+2-3 dB, timbre chaleureux alto)",
          "Boost : ~1-2 kHz    (+2 dB, présence)",
          "Cut : ~500-800 Hz si nasal",
        }, comp = { "Bus cordes GR 2-4 dB" },
          rev = { "Hall, decay 3-4s, mix 30-45%" },
          notes = { "Pan centre ou légèrement droite" }},
      { name = "Violoncelles", eq = {
          "HPF : ~60-80 Hz",
          "Boost : ~100-200 Hz (+3 dB, corps chaud cello)",
          "Boost : ~500-700 Hz (+2 dB, chant cello)",
          "Boost : ~2 kHz      (+2 dB, présence arc)",
          "Cut : ~300 Hz si boomy",
        }, comp = { "LA2A Gray sur bus cordes GR 2-4 dB" },
          rev = { "Hall, decay 3-5s, mix 30-45%" },
          notes = { "Pan droite (en face des violons)" }},
      { name = "Contrebasses", eq = {
          "HPF : ~40-50 Hz",
          "Boost : ~60-80 Hz   (+3 dB, sub orchestral)",
          "Boost : ~100-200 Hz (+2 dB, corps)",
          "Boost : ~500-700 Hz (+2 dB, présence archet)",
          "Cut : ~300 Hz si boomy",
        }, comp = { "LA2A Gray Bus cordes GR 3-5 dB" },
          rev = { "Hall très long, decay 3-6s, mix 30-40%" },
          notes = { "Pan droite-extrême ou centre selon effectif" }},
    }},
  },
}

-- ══════════════ MASTERING ══════════════
local MASTERING = {
 
  ["Film/TV (EBU R128)"] = {
    target   = "-23 LUFS intégré (référence EBU R128)",
    tp       = "-3 dBTP (safe film — EBU recommande -1 dBTP)",
    lra      = "LRA libre pour musique | ≤ 20 LU pour dialogue",
    perso    = "Ton réglage perso : -23 LUFS | Peaks MAX -8 dBFS",
    chain = {
      "① Volume Reaper : RMS entrée -12 à -18 dB | Crêtes max -6 dBFS",
      "② Ozone 11 EQ : Équilibre tonal final (HPF ~30 Hz, shelf HF +1-2 dB)",
      "③ Fairchild 670 : Glue finale très douce, GR 1-3 dB",
      "   OU CompDiode 609 : Caractère vintage, GR 2-4 dB",
      "④ Ozone Limiter (brickwall) : Ceiling -8 dBFS, True Peak -3 dBTP",
      "⑤ Mesure : LUFS intégré avec analyseur EBU R128",
    },
    notes = {
      "Exporter WAV 24-bit / 48 kHz pour livraison film/TV",
      "Plage dynamique plus large qu'en streaming — respecter la dynamique",
      "-23 LUFS = référence EBU (–24 LUFS aussi accepté UK)",
      "Vérifier avec plugin LUFS meter (Youlean ou Reaper intégré)",
    },
  },
 
  ["Streaming (Platforms)"] = {
    target   = "-14 LUFS intégré (Spotify / Apple Music cible normalisée)",
    tp       = "-1 dBTP",
    lra      = "LRA libre selon style musical",
    perso    = "",
    chain = {
      "① Ozone 11 EQ : Contrôle tonal (basse, médiums, hauts)",
      "② Fairchild 670 ou CompDiode 609 : Bus master coloration douce GR 1-3 dB",
      "③ Ozone Imager : Vérification mono-compatibility",
      "④ Ozone Limiter : Ceiling -1 dBFS, Lookahead 2-5 ms",
      "⑤ Mesure LUFS : -14 LUFS intégré",
    },
    notes = {
      "-14 LUFS = cible Spotify normalisée",
      "Au-delà de -8 LUFS : Spotify réduit le volume automatiquement",
      "Préférer -12 à -14 LUFS pour bon équilibre dynamique/volume",
      "WAV 24-bit 44.1 kHz pour delivery standard",
      "EDM peut viser -6 à -8 LUFS avec limiting agressif assumé",
    },
  },
 
  -- ── ELECTRO POP ──────────────────────────────────────────────────────
  ["Electro Pop"] = {
    target   = "-10 à -12 LUFS intégré (son compétitif streaming)",
    tp       = "-1 dBTP",
    lra      = "LRA 6-10 LU",
    perso    = "",
    chain = {
      "① Volume Reaper (gain staging) :",
      "   RMS bus master : -6 à -10 dB avant chaîne",
      "   Crêtes max entrée : -3 dBFS — laisser de la headroom",
      "",
      "② Ozone 11 EQ :",
      "   HPF : ~30 Hz — filtre Butterworth 12 dB/oct",
      "   Bas (80-120 Hz)     : +1 à +2 dB  | Q=1.0 — chaleur kick/basse",
      "   Low-mid (250-350 Hz): -1 à -2 dB  | Q=1.2 — nettoie la boue",
      "   Présence (3-5 kHz)  : +1 dB        | Q=0.8 — intelligibilité voix",
      "   Air (12-16 kHz)     : +1.5 à +2 dB | Shelf  — éclat electro pop",
      "   Mode Analog + Mid/Side : boost Air sur Side uniquement",
      "",
      "③ CompDiode 609 :",
      "   Ratio     : 2:1 ou 4:1 — rester léger sur le mastering",
      "   Threshold : -8 à -12 dB — viser 2-4 dB GR max",
      "   Attack    : 30-50 ms — laisser passer le transitoire",
      "   Release   : Auto ou 150-200 ms — suivre le tempo",
      "   GR cible  : 2 à 4 dB max (au-delà = trop agressif)",
      "   Makeup gain : +2 à +4 dB selon compression",
      "",
      "④ ReaLimit (limiteur final) :",
      "   Ceiling   : -1.0 dBTP — activer mode True Peak",
      "   Input gain : monter jusqu'à -10 à -12 LUFS intégré",
      "   GR limiteur : 2-3 dB max — au-delà = pompage",
    },
    notes = {
      "Ordre chaîne : Volume → EQ Ozone → Comp 609 → ReaLimit",
      "Mesurer les LUFS avec le LUFS meter d'Ozone 11 ou Youlean",
      "dBTP = True Peak (tient compte des inter-sample peaks)",
      "WAV 24-bit 44.1 kHz pour export final",
      "Comparer bypass vs processed à volume égal pour juger",
    },
  },
 
  -- ── ORCHESTRAL FANTASY ────────────────────────────────────────────────
  ["Orchestral Fantasy"] = {
    target   = "-14 à -18 LUFS intégré (préserve la dynamique naturelle)",
    tp       = "-1 dBTP",
    lra      = "LRA 12-20 LU (dynamique large conservée)",
    perso    = "",
    chain = {
      "① Volume Reaper (gain staging) :",
      "   RMS bus master : -12 à -18 dB — plus bas qu'en electro",
      "   Crêtes max entrée : -6 dBFS — les tutti peuvent être violents",
      "",
      "② Ozone 11 EQ :",
      "   HPF : ~40 Hz — filtre Butterworth 12 dB/oct",
      "   Contrebasses/Timbales (60-100 Hz)  : +0.5 à +1.5 dB | Q=0.8 — fondation épique",
      "   Low-mid boue (200-400 Hz)           : -1 à -2 dB     | Q=1.5 — cordes moins étouffées",
      "   Corps cordes/cuivres (800 Hz-1 kHz) : ±0.5 dB        | Q=1.0 — très léger, à l'oreille",
      "   Présence voix/chœurs (2-4 kHz)     : +0.5 à +1 dB   | Q=1.0 — intelligibilité chœurs",
      "   Air naturel (10-14 kHz)             : +1 à +1.5 dB   | Shelf  — cymbales, ambiance",
      "   Mode Mid/Side : boost aigus sur Side, Mid intact (chœurs centrés)",
      "",
      "③ CompDiode 609 (très discret) :",
      "   Ratio     : 1.5:1 ou 2:1 — encore plus doux qu'en electro",
      "   Threshold : -6 à -10 dB — viser 1-2 dB GR max",
      "   Attack    : 50-80 ms — laisser passer les transitoires orchestraux",
      "   Release   : 200-300 ms — respiration naturelle",
      "   GR cible  : 1 à 2 dB MAX — option bypass sur passages doux",
      "",
      "④ ReaLimit (limiteur final) :",
      "   Ceiling   : -1.0 dBTP — activer mode True Peak",
      "   Input gain : ajuster selon contexte (voir tableau dosage ci-dessous)",
      "   GR limiteur : 1-2 dB max — respecter la dynamique",
    },
    notes = {
      "Ordre chaîne : Volume → EQ Ozone → Comp 609 → ReaLimit",
      "DOSAGE selon contexte :",
      "  Orchestral pur     : GR 1 dB   | LUFS -16 à -18 | Air +1 dB",
      "  Orchestral + Choeurs: GR 1-2 dB | LUFS -14 à -16 | Présence +1 dB",
      "  Fantasy / Trailer  : GR 2-3 dB | LUFS -12 à -14 | Graves +1.5 dB",
      "Ne pas viser -10/-12 LUFS comme en electro — écrase la dynamique",
      "Bypasser le 609 sur pianissimo : compresseur même léger tue la magie",
      "WAV 24-bit 48 kHz recommandé (standard sync/image)",
    },
  },
 
  -- ── CLUB / DANCE (EDM LOUD) ───────────────────────────────────────────
  ["Club/Dance (EDM loud)"] = {
    target   = "-6 à -9 LUFS intégré",
    tp       = "-0.3 dBTP",
    lra      = "LRA 4-8 LU",
    perso    = "",
    chain = {
      "① Volume Reaper (gain staging) :",
      "   RMS bus master : -6 à -10 dB avant chaîne",
      "   Crêtes max entrée : -3 dBFS — laisser de la headroom",
      "",
      "② Ozone 11 EQ :",
      "   HPF : ~30 Hz — filtre 12 dB/oct",
      "   Bas (80-120 Hz)     : +1 à +2 dB  | Q=1.0 — chaleur kick/basse",
      "   Low-mid (250-350 Hz): -1 à -2 dB  | Q=1.2 — nettoie la boue",
      "   Présence (3-5 kHz)  : +1 dB        | Q=0.8 — intelligibilité voix",
      "   Air (12-16 kHz)     : +1.5 à +2 dB | Shelf — éclat EDM",
      "   Mode Analog + Mid/Side : boost Air sur Side uniquement",
      "",
      "③ CompDiode 609 :",
      "   Ratio     : 2:1 ou 4:1 — rester léger sur le mastering",
      "   Threshold : -8 à -12 dB — viser 2-4 dB GR max",
      "   Attack    : 30-50 ms — laisser passer le transitoire",
      "   Release   : Auto ou 150-200 ms — suivre le tempo",
      "   GR cible  : 2 à 4 dB max (au-delà = trop agressif)",
      "   Makeup gain : +2 à +4 dB selon compression",
      "",
      "④ ReaLimit (limiteur final) :",
      "   Ceiling   : -0.3 dBTP — plus agressif que le streaming",
      "   Input gain : monter jusqu'à -6 à -9 LUFS intégré",
      "   GR limiteur : 3-6 dB admis — loud mastering intentionnel",
    },
    notes = {
      "Ordre chaîne : Volume → EQ Ozone → Comp 609 → ReaLimit",
      "WAV 24-bit 44.1 kHz ou 48 kHz pour livraison club",
      "Loud mastering intentionnel — son compétitif pour la scène",
      "Vérifier mono-compatibility : systèmes club = sub mono",
      "Aucun null/cancellation admis en mono sur le sub",
      "Comparer à un track de référence EDM club à même volume",
    },
  },
 
}

-- ══════════════ UI ══════════════
local function show_ui()
  local ctx = reaper.ImGui_CreateContext("ZoundZikProd Mix/Master")

  local screen     = "welcome"
  local mode_sel   = nil
  local style_sel  = nil
  local dest_sel   = nil
  local synth_tog  = {}
  local open       = true

  local STYLES = {
    "Rock","Pop","Electro Pop","EDM",
    "Acoustique Voix/Guit.","Reggae","Funk","Orchestral"
  }
  local DESTS = {
    "Film/TV (EBU R128)",
    "Streaming (Platforms)",
    "Club/Dance (EDM loud)",
  }

  -- Couleurs
  local CA = 0xE94560FF  -- accent rouge
  local CG = 0xF5A623FF  -- gold
  local CV = 0x00D48AFF  -- vert
  local CW = 0xFFFFFFFF  -- blanc
  local CY = 0xFFD700FF  -- jaune
  local CB = 0x4FC3F7FF  -- bleu clair (notes)
  local CZ = 0xAAAAAFFF  -- gris

  local function tc(col, txt)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), col)
    reaper.ImGui_Text(ctx, txt)
    reaper.ImGui_PopStyleColor(ctx)
  end
  local function sep()
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), CA)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_PopStyleColor(ctx)
  end

  -- Rendu d'une sous-section instrument
  local function render_sub(sub, key)
    reaper.ImGui_Indent(ctx, 10)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), CA)
    local so = reaper.ImGui_TreeNode(ctx, "◆ " .. sub.name .. "##" .. key,
      reaper.ImGui_TreeNodeFlags_DefaultOpen())
    reaper.ImGui_PopStyleColor(ctx)

    if so then
      reaper.ImGui_Indent(ctx, 14)
      if sub.eq and #sub.eq > 0 then
        tc(CY, "[ EQ ]")
        for _, l in ipairs(sub.eq) do tc(CW, "  " .. l) end
        reaper.ImGui_Spacing(ctx)
      end
      if sub.comp and #sub.comp > 0 then
        tc(CV, "[ Compresseur ]")
        for _, l in ipairs(sub.comp) do tc(CW, "  " .. l) end
        reaper.ImGui_Spacing(ctx)
      end
      if sub.rev and #sub.rev > 0 then
        tc(CB, "[ Reverb ]")
        for _, l in ipairs(sub.rev) do tc(CW, "  " .. l) end
        reaper.ImGui_Spacing(ctx)
      end
      if sub.notes and #sub.notes > 0 then
        tc(CZ, "[ Notes ]")
        for _, l in ipairs(sub.notes) do tc(CZ, "  ✦ " .. l) end
      end
      reaper.ImGui_Unindent(ctx, 14)
      reaper.ImGui_TreePop(ctx)
    end
    reaper.ImGui_Unindent(ctx, 10)
    reaper.ImGui_Spacing(ctx)
  end

  -- Rendu d'un instrument
  local function render_instr(instr, gi)
    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), CG)
    local io = reaper.ImGui_TreeNode(ctx, "▶  " .. instr.name .. "##gi" .. gi,
      reaper.ImGui_TreeNodeFlags_DefaultOpen())
    reaper.ImGui_PopStyleColor(ctx)

    if io then
      if instr.ask_synth then
        if synth_tog[gi] == nil then synth_tog[gi] = false end
        reaper.ImGui_Indent(ctx, 8)
        tc(CZ, "Type de basse :")
        reaper.ImGui_SameLine(ctx)
        local rv, v = reaper.ImGui_Checkbox(ctx, "Basse Synthé##st" .. gi, synth_tog[gi])
        if rv then synth_tog[gi] = v end
        reaper.ImGui_Unindent(ctx, 8)
        reaper.ImGui_Spacing(ctx)
      end

      for vi, sub in ipairs(instr.subs) do
        local show = true
        if instr.ask_synth then
          local is_s = sub.is_synth == true
          if synth_tog[gi] and not is_s then show = false end
          if not synth_tog[gi] and is_s then show = false end
        end
        if show then
          render_sub(sub, "g" .. gi .. "v" .. vi)
        end
      end
      reaper.ImGui_TreePop(ctx)
    end
    sep()
    reaper.ImGui_Spacing(ctx)
  end

  -- Rendu mastering
  local function render_master(dest)
    local m = MASTERING[dest]
    if not m then return end
    tc(CA, "◉ Cible LUFS : " .. m.target)
    tc(CG, "◉ True Peak  : " .. m.tp)
    tc(CV, "◉ LRA        : " .. m.lra)
    if m.perso ~= "" then
      reaper.ImGui_Spacing(ctx)
      tc(CV, "⚑ " .. m.perso)
    end
    reaper.ImGui_Spacing(ctx)
    sep()
    reaper.ImGui_Spacing(ctx)

    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), CG)
    local co = reaper.ImGui_TreeNode(ctx, "▶ Chaîne plug-ins mastering##mchain",
      reaper.ImGui_TreeNodeFlags_DefaultOpen())
    reaper.ImGui_PopStyleColor(ctx)
    if co then
      reaper.ImGui_Indent(ctx, 16)
      for _, l in ipairs(m.chain) do tc(CW, l) end
      reaper.ImGui_Unindent(ctx, 16)
      reaper.ImGui_TreePop(ctx)
    end
    reaper.ImGui_Spacing(ctx)

    reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_Text(), CB)
    local no = reaper.ImGui_TreeNode(ctx, "▶ Notes importantes##mnotes",
      reaper.ImGui_TreeNodeFlags_DefaultOpen())
    reaper.ImGui_PopStyleColor(ctx)
    if no then
      reaper.ImGui_Indent(ctx, 16)
      for _, l in ipairs(m.notes) do tc(CB, "  ✦ " .. l) end
      reaper.ImGui_Unindent(ctx, 16)
      reaper.ImGui_TreePop(ctx)
    end
  end

  -- ══ BOUCLE ══
  reaper.defer(function()
    local function loop()
      if not open then return end

      -- ─── ÉCRAN WELCOME ───
      if screen == "welcome" then
        reaper.ImGui_SetNextWindowSize(ctx, 420, 520, reaper.ImGui_Cond_Always())
        local vis, op = reaper.ImGui_Begin(ctx,
          "ZoundZikProd — Mix & Master", true,
          reaper.ImGui_WindowFlags_NoResize())
        open = op
        if vis then
          tc(CA, "╔══════════════════════════════╗")
          tc(CA, "║  PENSE-BÊTE  MIX / MASTER    ║")
          tc(CA, "╚══════════════════════════════╝")
          tc(CZ, "ZoundZikProd  |  Reaper ImGui")
          reaper.ImGui_Spacing(ctx)
          sep()
          reaper.ImGui_Spacing(ctx)

          tc(CG, "① POUR QUOI FAIRE ?")
          reaper.ImGui_Spacing(ctx)
          if reaper.ImGui_RadioButton(ctx, "Mixage##m1", mode_sel == "Mixage") then
            mode_sel = "Mixage" end
          reaper.ImGui_SameLine(ctx)
          if reaper.ImGui_RadioButton(ctx, "Mastering##m2", mode_sel == "Mastering") then
            mode_sel = "Mastering" end

          reaper.ImGui_Spacing(ctx)
          sep()
          reaper.ImGui_Spacing(ctx)

          tc(CG, "② STYLE MUSICAL ?")
          reaper.ImGui_Spacing(ctx)
          for _, s in ipairs(STYLES) do
            if reaper.ImGui_RadioButton(ctx, s .. "##s", style_sel == s) then
              style_sel = s ; synth_tog = {}
            end
          end

          if mode_sel == "Mastering" then
            reaper.ImGui_Spacing(ctx)
            sep()
            reaper.ImGui_Spacing(ctx)
            tc(CG, "③ DESTINATION ?")
            reaper.ImGui_Spacing(ctx)
            for _, d in ipairs(DESTS) do
              if reaper.ImGui_RadioButton(ctx, d .. "##d", dest_sel == d) then
                dest_sel = d
              end
            end
          end

          reaper.ImGui_Spacing(ctx)
          sep()
          reaper.ImGui_Spacing(ctx)

          local ok = mode_sel ~= nil and style_sel ~= nil
          if mode_sel == "Mastering" then ok = ok and dest_sel ~= nil end

          if ok then
            tc(CV, "▶ Prêt !")
            reaper.ImGui_Spacing(ctx)
            if reaper.ImGui_Button(ctx, "Charger le pense-bête  →", -1, 0) then
              screen = "main"
            end
          else
            tc(CZ, "(Complétez les sélections ci-dessus)")
          end

          reaper.ImGui_End(ctx)
        end

      -- ─── ÉCRAN PRINCIPAL ───
      elseif screen == "main" then
        local ttl = "  " .. mode_sel .. " — " .. style_sel
        if dest_sel then ttl = ttl .. " ▸ " .. dest_sel end
        reaper.ImGui_SetNextWindowSize(ctx, 620, 720, reaper.ImGui_Cond_Always())
        local vis, op = reaper.ImGui_Begin(ctx, ttl, true,
          reaper.ImGui_WindowFlags_NoResize())
        open = op

        if vis then
          tc(CA, "◈ Mode  : " .. mode_sel)
          tc(CG, "◈ Style : " .. style_sel)
          if dest_sel then tc(CV, "◈ Dest. : " .. dest_sel) end
          reaper.ImGui_Spacing(ctx)
          sep()
          reaper.ImGui_Spacing(ctx)

         reaper.ImGui_BeginChild(ctx, "##sc", 0, 635, 0)

          if mode_sel == "Mixage" then
            local proj = DATA[style_sel]
            if proj then
              for gi, instr in ipairs(proj.instruments) do
                render_instr(instr, gi)
              end
            else
              tc(CA, "Style non trouvé.")
            end

          elseif mode_sel == "Mastering" then
            render_master(dest_sel)
          end

          reaper.ImGui_EndChild(ctx)

          reaper.ImGui_Spacing(ctx)
          if reaper.ImGui_Button(ctx, "◀  Changer les réglages", -1, 0) then
            screen = "welcome"
          end

          reaper.ImGui_End(ctx)
        end
      end

      if open then reaper.defer(loop)
      else
        if reaper.ImGui_DestroyContext then
          reaper.ImGui_DestroyContext(ctx)
        end
      end
    end
    loop()
  end)
end

show_ui()
