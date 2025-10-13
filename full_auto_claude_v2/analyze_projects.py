#!/usr/bin/env python3
"""
Script pour analyser les PDF et générer progress.md avec les projets regroupés.
"""

import os
import re
from collections import defaultdict
from datetime import datetime

ORGANIZED_SUBJECTS = "/home/roro/work/projects/All-42-subject/organized_subjects"
OUTPUT_FILE = "/home/roro/work/projects/All-42-subject/full_auto_claude_v2/progress.md"

def extract_project_name(pdf_name):
    """
    Extrait le nom du projet à partir du nom du PDF.
    Gère les modules, rush, training, etc.
    """
    # Retirer l'extension
    name = pdf_name.replace('.pdf', '')

    # Patterns pour détecter les modules/jours/rush
    patterns = [
        # Modules numérotés (Module_00, Module_01, etc.)
        (r'^(.+?)[-_]Module[-_]\d+', r'\1'),
        # Jours numérotés (D00, D01, Day_00, etc.)
        (r'^(D\d+)[-_](.+)', r'\2'),
        (r'^(.+?)[-_]Day[-_]\d+', r'\1'),
        (r'^(.+?)[-_]d\d+', r'\1'),
        (r'^(.+?)[-_]j\d+', r'\1'),
        # Rush
        (r'^(.+?)[-_]Rush[-_]\d+', r'\1'),
        # Training avec numéros
        (r'^(.+?)[-_]Training[-_]\d+', r'\1'),
        (r'^Training[-_](.+?)[-_]\d+', r'\1'),
        # Formation avec numéros
        (r'^(.+?)[-_]Formation[-_]', r'\1'),
        (r'^Formation[-_](.+)', r'\1'),
        # Libft avec versions
        (r'^(Libft)[-_]\d+', r'\1'),
        # ft_ssl avec variantes
        (r'^(ft_ssl).*', r'\1'),
        # cub3D avec versions
        (r'^(cub3D)\d+', r'\1'),
        # Web avec numéros
        (r'^(Web)\d+', r'\1'),
        # Rush avec numéros
        (r'^(Rush)\d+', r'\1'),
        # KFS avec numéros
        (r'^(KFS)[-_]\d+', r'\1'),
        # cmprssd prefix
        (r'^cmprssd[-_](.+)', r'\1'),
    ]

    for pattern, replacement in patterns:
        match = re.match(pattern, name, re.IGNORECASE)
        if match:
            result = re.sub(pattern, replacement, name, flags=re.IGNORECASE)
            # Nettoyer les underscores/tirets en fin
            result = re.sub(r'[-_]+$', '', result)
            return result

    # Si aucun pattern ne correspond, retourner le nom complet
    return name

def group_pdfs_by_project():
    """
    Parcourt tous les PDF et les regroupe par projet.
    Retourne un dict: {categorie: {projet: [liste de PDFs]}}
    """
    projects = defaultdict(lambda: defaultdict(list))

    for category in sorted(os.listdir(ORGANIZED_SUBJECTS)):
        category_path = os.path.join(ORGANIZED_SUBJECTS, category)
        if not os.path.isdir(category_path):
            continue

        pdfs = [f for f in os.listdir(category_path) if f.endswith('.pdf')]

        for pdf in sorted(pdfs):
            project_name = extract_project_name(pdf)
            projects[category][project_name].append(pdf)

    return projects

def generate_progress_md(projects):
    """
    Génère le fichier progress.md avec le format requis.
    """
    today = datetime.now().strftime('%Y-%m-%d')

    lines = []
    lines.append("# Suivi des projets 42\n")
    lines.append("Format: YYYY-MM-DD | Categorie/NomProjet | STATUT | Commentaire\n")
    lines.append("Statuts possibles: NOT_STARTED, IN_PROGRESS, DONE, FAILED\n")
    lines.append("\n")
    lines.append("| Date | Projet | Statut | Commentaire |\n")
    lines.append("|------|--------|--------|-------------|\n")

    for category in sorted(projects.keys()):
        for project_name in sorted(projects[category].keys()):
            pdfs = projects[category][project_name]
            pdf_count = len(pdfs)

            comment = f"{pdf_count} PDF"
            if pdf_count > 1:
                comment += "s"

            # Déterminer si c'est un projet avec modules
            if any(re.search(r'Module|Rush|Day|D\d+', pdf) for pdf in pdfs):
                comment += " (modules/days)"

            lines.append(f"| {today} | {category}/{project_name} | NOT_STARTED | {comment} |\n")

    with open(OUTPUT_FILE, 'w') as f:
        f.writelines(lines)

    # Afficher statistiques
    total_projects = sum(len(projects[cat]) for cat in projects)
    total_pdfs = sum(len(pdfs) for cat in projects for pdfs in projects[cat].values())

    print(f"✅ Généré {OUTPUT_FILE}")
    print(f"📊 Statistiques:")
    print(f"   - {len(projects)} catégories")
    print(f"   - {total_projects} projets identifiés")
    print(f"   - {total_pdfs} PDF au total")
    print(f"\n📝 Quelques exemples de regroupement:")

    # Afficher quelques exemples
    count = 0
    for category in sorted(projects.keys()):
        for project_name in sorted(projects[category].keys()):
            pdfs = projects[category][project_name]
            if len(pdfs) > 1 and count < 5:
                print(f"\n   {category}/{project_name}:")
                for pdf in pdfs[:3]:
                    print(f"      - {pdf}")
                if len(pdfs) > 3:
                    print(f"      ... et {len(pdfs)-3} autres")
                count += 1

if __name__ == "__main__":
    print("🔍 Analyse des PDF et regroupement par projet...\n")
    projects = group_pdfs_by_project()
    generate_progress_md(projects)
