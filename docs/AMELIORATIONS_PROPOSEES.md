# Améliorations proposées pour ManyFaces

Document de propositions d’évolutions pour l’application ManyFaces (fiches personnages / PNJ INS/MV).

---

## 1. Fonctionnalités manquantes

### 1.1 Import de personnage (JSON)
- **Constat** : `StorageService.importCharacterFromFile()` existe mais n’est jamais appelé depuis l’interface. Le package `file_picker` est dans les dépendances mais pas utilisé pour l’import.
- **Proposition** : Ajouter sur l’écran d’accueil un bouton ou une entrée de menu **« Importer un personnage (JSON) »** qui ouvre le sélecteur de fichier, appelle `StorageService.importCharacterFromFile(path)`, puis ajoute le personnage au provider et ouvre la fiche détail (ou affiche une erreur si le fichier est invalide).
- **Bénéfice** : Sauvegardes JSON réellement réutilisables, restauration après changement d’appareil ou de réinstallation.

### 1.2 Recherche / filtre des personnages sauvegardés
- **Proposition** : Sur l’écran d’accueil, au-dessus de la liste des personnages, ajouter un champ de recherche (par nom, type, supérieur) et éventuellement un filtre « Tous / Joueurs / PNJ ».
- **Bénéfice** : Utilisation plus confortable dès qu’il y a beaucoup de fiches.

### 1.3 Dupliquer une fiche
- **Proposition** : Dans le menu (⋮) de la fiche détail, ajouter **« Dupliquer la fiche »** : créer une copie du personnage avec un nouvel `id` et un nom du type « Copie de [Nom] », puis l’enregistrer et l’ouvrir.
- **Bénéfice** : Création rapide de variantes (ex. même archétype, autre nom / stats).

---

## 2. Expérience utilisateur (UX)

### 2.1 Cohérence des intitulés
- **Constat** : L’app bar de l’accueil affiche « Grimoire des Héros » alors que l’app s’appelle ManyFaces et le FAB « Forger un Héros ».
- **Proposition** : Soit harmoniser (ex. « ManyFaces » partout, ou « Grimoire des Héros » partout), soit garder « ManyFaces » dans À propos / titre technique et « Grimoire des Héros » comme sous-titre ou nom d’écran d’accueil, de façon explicite.

### 2.2 Retour après création / édition
- **Proposition** : Après « Forger le personnage » ou création d’un PNJ, s’assurer que le bouton retour depuis la fiche détail ramène bien à l’écran d’accueil (ou à la liste des personnages) de façon prévisible. Vérifier aussi le comportement sur Android (bouton retour système).

### 2.3 Confirmation avant suppression
- **Constat** : Une boîte de dialogue de confirmation existe déjà pour la suppression.
- **Proposition** : Optionnel : ajouter une case « Ne plus demander » (sauvegardée en préférences) pour les utilisateurs qui suppriment souvent.

### 2.4 Indication de fiche non sauvegardée
- **Proposition** : Si l’utilisateur modifie la fiche (nom, stats, etc.) sans appuyer sur « Sauvegarder », afficher un indicateur (ex. point ou astérisque dans l’app bar) et, à la sortie (retour / fermeture), proposer « Sauvegarder avant de quitter ? / Abandonner / Annuler ».

---

## 3. Qualité du code et maintenabilité

### 3.1 Correction d’affichage (liste des personnages)
- **Constat** : Dans `home_screen.dart`, le titre de la carte des personnages sauvegardés utilise `'Personnages Sauvegardés (\${characters.length})'`. À cause du `\`, la chaîne n’est pas interpolée et affiche littéralement « ${characters.length} ».
- **Proposition** : Remplacer par `'Personnages Sauvegardés (${characters.length})'` (sans backslash devant `$`) pour afficher le nombre réel.

### 3.2 Routes nommées
- **Constat** : Navigation avec `MaterialPageRoute(builder: (_) => ...)` et widgets en dur.
- **Proposition** : Introduire des routes nommées (ex. `'/character/:id'`, `'/create'`, `'/npc'`) et `Navigator.pushNamed` / `onGenerateRoute`. Facilite les deep links et la maintenance.

### 3.3 Tests
- **Proposition** : Ajouter des tests unitaires pour :
  - `Character.fromJson` / `toJson` (et import/export JSON),
  - `SheetPdfService.buildFichePdf` / `SheetOdtService.buildFicheOdt` (pas d’exception, PDF/ODT non vides),
  - `StorageService` (sauvegarde / chargement / suppression) avec préférences simulées.
- **Proposition** : Quelques tests widget pour l’écran d’accueil (liste vide, liste avec un personnage, boutons principaux).

### 3.4 Internationalisation (i18n)
- **Proposition** : Si une traduction (ex. anglais) est envisagée, poser dès maintenant la structure : `flutter_localizations`, `AppLocalizations`, et remplacer les chaînes en dur par des clés (ex. `context.l10n.personnagesSauvegardes`). Sinon, documenter que l’app est en français uniquement pour l’instant.

---

## 4. Performance et données

### 4.1 Chargement des personnages
- **Constat** : Les personnages sont chargés depuis SharedPreferences au démarrage du `CharacterProvider`.
- **Proposition** : Conserver ce modèle ; si la liste devient très grande (centaines de fiches), envisager une pagination ou un chargement différé de la liste (ex. afficher les 50 premiers, « Charger la suite »).

### 4.2 Export / partage
- **Proposition** : Lors d’un export PDF/ODT/JSON, afficher brièvement un indicateur de chargement (ex. `CircularProgressIndicator` dans un SnackBar ou overlay) pour les gros personnages, afin d’éviter l’impression que l’app ne répond pas.

---

## 5. Accessibilité et ergonomie

### 5.1 Labels pour lecteurs d’écran
- **Proposition** : S’assurer que les boutons et champs importants ont des `Semantics` / `tooltip` / `label` cohérents (ex. « Sauvegarder la fiche », « Exporter en PDF », « Importer un personnage ») pour les utilisateurs de TalkBack / VoiceOver.

### 5.2 Contraste et thème sombre
- **Constat** : Un thème sombre existe déjà.
- **Proposition** : Vérifier le contraste des textes (or / bronze sur fond sombre) par rapport aux recommandations WCAG si l’app vise un large public.

### 5.3 Tailles de police
- **Proposition** : Respecter les réglages « grande police » du système (MediaQuery.textScalerOf(context)) pour les textes principaux, afin d’améliorer la lisibilité.

---

## 6. Fonctionnalités métier (INS/MV)

### 6.1 Rappel des règles de jets
- **Proposition** : Dans l’écran du lanceur de dés ou en aide contextuelle, rappeler brièvement la règle INS/MV (ex. « Seuil = Carac × nombre de dés », interprétation 111 / 666) pour les joueurs qui découvrent le système.

### 6.2 Historique des jets
- **Proposition** : Optionnel : garder en mémoire les 5 ou 10 derniers jets (résultat + type de jet) et les afficher sous le lanceur, pour revoir rapidement les résultats sans refaire un jet.

### 6.3 Favoris / tags
- **Proposition** : Permettre de marquer certains personnages comme « Favoris » ou de leur attribuer des tags (ex. « Campagne X », « One-shot ») et de filtrer la liste par tag.

---

## 7. Priorisation suggérée

| Priorité | Amélioration | Effort estimé |
|----------|--------------|----------------|
| Haute    | Import JSON (bouton + file_picker) | Faible |
| Haute    | Correction affichage nombre personnages (${characters.length}) | Très faible |
| Moyenne  | Dupliquer une fiche | Faible |
| Moyenne  | Indication « fiche non sauvegardée » + confirmation sortie | Moyen |
| Moyenne  | Recherche / filtre liste personnages | Moyen |
| Basse   | Routes nommées | Moyen |
| Basse   | Tests unitaires (JSON, storage, PDF) | Moyen |
| Basse   | Historique des jets, rappel règles | Variable |

---

*Document généré pour le projet ManyFaces – à adapter selon tes priorités et le temps disponible.*
