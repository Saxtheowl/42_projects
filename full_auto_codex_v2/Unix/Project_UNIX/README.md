# Project UNIX (polymorphic virus)

## Avertissement
Projet sensible impliquant le développement d’un virus polymorphe. Toute manipulation doit être réalisée en environnement contrôlé (VM isolée, sans réseau) conformément aux règles de sécurité.

## Synthèse préliminaire
- Objectif : implémenter un virus capable de modifier sa signature (polymorphisme) pour échapper aux détections.
- Composants attendus : loader, décodeur, payload, mécanismes de mutation.
- Technologies pressenties : C/ASM, injection dans binaires ELF sous Linux.

## État actuel
- Dossier initialisé ; en attente de lecture du PDF pour définir les exigences précises (vecteurs d’infection, contraintes). 

## Prochaines étapes
- Lecture `Sujet_Project_UNIX.pdf` + note dans DESIGN.
- Définition architecture et protocoles d’infection.
- Mise en place infrastructure de build/test en sandbox.

> Note : aucune implémentation ne doit être déployée hors environnement d’expérimentation.
