# ZoundZikProd — Scripts REAPER (Lua)

Une collection de scripts Lua pour REAPER, developpes pour la composition musicale
et la post-production audio/video.

Licence : CC BY-NC-SA 4.0 — Gratuit, modifiable, non commercial.
https://creativecommons.org/licenses/by-nc-sa/4.0/

---

## Prerequis

- REAPER (toute version recente)
- ReaImGui — extension requise pour les scripts avec interface graphique
  Installer via : ReaPack > Browse packages > ReaImGui
  https://forum.cockos.com/showthread.php?t=250419

---

## Les scripts

### 1. ClearAutomation.lua — Effacer des points d'automation

Supprime les points d'enveloppe (Volume, Pan, Width) de la piste selectionnee,
avec un controle precis de la zone a effacer.

Modes disponibles :
- Between : dans la selection temporelle
- Left    : a gauche de la selection
- Right   : a droite de la selection
- Outside : tout ce qui est en dehors de la selection
- Whole   : toute la piste

Comment l'utiliser :
1. Selectionnez une piste dans REAPER
2. Faites une selection temporelle (glisser sur la timeline)
3. Lancez le script
4. Choisissez le mode et les enveloppes a effacer
5. Cliquez sur CLEAR

---

### 2. ExtendItems.lua — Etendre le bord d'un item vers une position cible

Deplace le bord gauche ou droit des items selectionnes vers une position precise
(debut de timeline, timecode ou numero de mesure).

Positions cibles :
- Timeline Zero    : positionne le bord a 0:00
- Timecode         : entrez manuellement minutes / secondes / centièmes
- Numero de mesure : entrez un numero de mesure

Comment l'utiliser :
1. Selectionnez un ou plusieurs items sur la timeline
2. Lancez le script
3. Choisissez le bord a etendre (gauche ou droit)
4. Choisissez la position cible
5. Cliquez sur ETENDRE

Note : un bouton Undo/Redo integre permet d'annuler directement depuis le script.

---

### 3. RandomAutomation.lua — Generateur d'automation aleatoire

Genere des points d'automation aleatoires sur les enveloppes Volume, Pan et/ou
Width dans la selection temporelle.

Parametres configurables :
- Activer/desactiver Pan, Volume, Width
- Nombre de points a generer
- Espacement automatique ou manuel (en secondes)
- Amplitude du Pan (en %)
- Valeurs min/max du Volume (en dB)
- Amplitude du Width (en %)

Comment l'utiliser :
1. Selectionnez une piste
2. Faites une selection temporelle
3. Lancez le script
4. Configurez les parametres dans la fenetre
5. Cliquez OK pour generer (la fenetre reste ouverte pour relancer)

Note : ce script utilise l'interface native REAPER, ReaImGui n'est pas requis.

---

### 4. TemplatePicker.lua — Selecteur de templates de projet

Affiche une fenetre pour parcourir et charger rapidement un template de projet
REAPER, avec barre de recherche.

Comment l'utiliser :
1. Lancez le script
2. Utilisez la barre de recherche pour filtrer
3. Cliquez sur un template pour le selectionner
4. Cliquez OUVRIR (ou double-cliquez sur le nom)

Configuration du chemin :
Le script detecte automatiquement le dossier ProjectTemplates de REAPER selon
votre OS. Si ca ne fonctionne pas, modifiez la variable TEMPLATE_PATH en haut
du fichier :

  Windows : "C:\\Users\\VOTRE_NOM\\AppData\\Roaming\\REAPER\\ProjectTemplates\\"
  macOS   : os.getenv("HOME") .. "/Library/Application Support/REAPER/ProjectTemplates/"

---

### 5. MixMasterCheatSheet.lua — Pense-bete Mix et Mastering

Affiche une interface de reference avec les reglages EQ, compression et reverb
recommandes pour chaque instrument, selon le genre musical.

Genres couverts : Rock, Hip-Hop, Jazz, Electronique, et plus.
Instruments : Drums (Kick, Snare, Hi-Hats, Overhead, Toms), Basse, Guitares,
              Voix, Claviers.

Comment l'utiliser :
1. Lancez le script
2. Selectionnez le genre musical
3. Naviguez par instrument pour voir les suggestions EQ / Compresseur / Reverb

Note : c'est un outil de reference, pas des regles absolues. Faites confiance
a vos oreilles.

---

### 6. CourtMetrageManager.lua — Gestionnaire de projets court-metrage

Interface pour naviguer dans une arborescence de projets court-metrage et ouvrir
directement les fichiers .rpp correspondants.

Structure de dossiers attendue :
```
COURT_METRAGE/
  MON_FILM_C1/          (dossier projet, suffixe _CX)
    MON_FILM_Zik/       (dossier musique, suffixe _Zik)
      scene01A/         (dossier de scene)
        scene01A.rpp    (projet REAPER)
```

Configuration du chemin :
Modifiez la variable court_metrage_path en haut du fichier :

  Windows : "D:\\MES_PROJETS\\COURT_METRAGE"
  macOS   : "/Users/votre_nom/Projets/Court_Metrage"

---

## Installation

1. Telechargez le(s) fichier(s) .lua souhaite(s)
2. Copiez-les dans le dossier Scripts de REAPER :
   - Windows : %APPDATA%\REAPER\Scripts\
   - macOS   : ~/Library/Application Support/REAPER/Scripts/
   - Linux   : ~/.config/REAPER/Scripts/
3. Dans REAPER : Actions > Show action list > Load > selectionnez le script
4. Assignez un raccourci clavier ou un bouton de toolbar si vous voulez

---

## Licence

Ces scripts sont distribues sous licence Creative Commons BY-NC-SA 4.0.

- Utilisation gratuite
- Modification autorisee
- Partage autorise
- Usage commercial interdit
- Revente interdite (scripts originaux ou modifies)
- Toute version modifiee doit utiliser la meme licence

Texte complet : https://creativecommons.org/licenses/by-nc-sa/4.0/

---

## Credits

Developpe par ZoundZikProd avec l'aide de Claude (Anthropic).
