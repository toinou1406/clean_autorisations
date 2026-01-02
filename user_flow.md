# Scénarios de première utilisation sur Android

Voici une description étape par étape du parcours de l'utilisateur lors de sa première utilisation de l'application sur Android, en tenant compte de tous les scénarios de permission possibles.

### Scénario 1 : L'utilisateur accorde l'autorisation complète du premier coup

1.  **Écran de bienvenue et de permission** : L'utilisateur ouvre l'application pour la première fois et voit l'écran de permission. Cet écran explique pourquoi l'application a besoin d'un accès aux photos et présente un bouton "Autoriser l'accès".
2.  **Demande d'autorisation** : L'utilisateur appuie sur "Autoriser l'accès". La boîte de dialogue de permission standard d'Android apparaît.
3.  **Accès complet accordé** : L'utilisateur sélectionne "Autoriser l'accès à toutes les photos".
4.  **Écran d'accueil** : L'application navigue vers l'écran d'accueil. En arrière-plan, l'analyse des photos démarre automatiquement.
5.  **Analyse prête** : L'utilisateur peut appuyer sur le bouton "Analyser les photos" pour voir les résultats de l'analyse et commencer à nettoyer ses photos.

### Scénario 2 : L'utilisateur accorde une autorisation limitée

1.  **Écran de bienvenue et de permission** : Identique au scénario 1.
2.  **Demande d'autorisation** : Identique au scénario 1.
3.  **Accès limité accordé** : L'utilisateur sélectionne "Sélectionner des photos" et choisit quelques photos.
4.  **Message d'avertissement** : L'écran de permission affiche maintenant un message d'avertissement expliquant que l'application a besoin d'un accès complet pour fonctionner correctement. Un bouton "Ouvrir les paramètres" est affiché.
5.  **Paramètres de l'application** : Si l'utilisateur appuie sur "Ouvrir les paramètres", il est redirigé vers la page des paramètres de l'application sur son appareil Android, où il peut modifier manuellement l'autorisation de "Photos sélectionnées" à "Toutes les photos".
6.  **Retour à l'application** : Lorsque l'utilisateur revient à l'application, celle-ci vérifie à nouveau l'état de l'autorisation. Si l'accès complet est maintenant accordé, l'application naviguera vers l'écran d'accueil.

### Scénario 3 : L'utilisateur refuse l'autorisation

1.  **Écran de bienvenue et de permission** : Identique au scénario 1.
2.  **Demande d'autorisation** : Identique au scénario 1.
3.  **Autorisation refusée** : L'utilisateur sélectionne "Ne pas autoriser".
4.  **Message d'avertissement** : L'écran de permission affiche maintenant un message d'avertissement expliquant que l'application ne peut pas fonctionner sans l'accès aux photos. Un bouton "Ouvrir les paramètres" est affiché.
5.  **Paramètres de l'application** : Si l'utilisateur appuie sur "Ouvrir les paramètres", il est redirigé vers les paramètres de l'application pour accorder manuellement l'accès aux photos.
6.  **Retour à l'application** : Lorsque l'utilisateur revient, l'application vérifie à nouveau l'autorisation et, si elle est accordée, passe à l'écran d'accueil.

### Scénario 4 : L'utilisateur refuse l'autorisation et sélectionne "Ne plus demander"

1.  **Écran de bienvenue et de permission** : Identique au scénario 1.
2.  **Demande d'autorisation** : Identique au scénario 1.
3.  **Autorisation refusée de manière permanente** : L'utilisateur sélectionne "Ne pas autoriser" et a précédemment sélectionné "Ne plus demander".
4.  **Message d'avertissement** : L'écran de permission affiche un message d'avertissement et un bouton "Ouvrir les paramètres". Le bouton "Autoriser l'accès" est désactivé.
5.  **Paramètres de l'application** : La seule option pour l'utilisateur est d'aller dans les paramètres de l'application et d'accorder manuellement l'autorisation.
