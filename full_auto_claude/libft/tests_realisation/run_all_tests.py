#!/usr/bin/env python3
"""
Script de test automatisé pour libft
Ce script compile et teste toutes les fonctions de la bibliothèque libft
"""

import subprocess
import os
import sys
from pathlib import Path

# Couleurs pour l'affichage
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_header(text):
    """Affiche un en-tête coloré"""
    print(f"\n{BLUE}{'=' * 60}{RESET}")
    print(f"{BLUE}{text:^60}{RESET}")
    print(f"{BLUE}{'=' * 60}{RESET}\n")

def print_success(text):
    """Affiche un message de succès"""
    print(f"{GREEN}✅ {text}{RESET}")

def print_error(text):
    """Affiche un message d'erreur"""
    print(f"{RED}❌ {text}{RESET}")

def print_info(text):
    """Affiche un message d'information"""
    print(f"{YELLOW}ℹ️  {text}{RESET}")

def check_libft_exists():
    """Vérifie que le fichier libft.a existe"""
    if not os.path.exists('../libft.a'):
        print_error("libft.a n'existe pas. Compilez d'abord avec 'make'")
        return False
    return True

def compile_test_program(test_file, output_name):
    """Compile un programme de test"""
    cmd = [
        'cc', '-Wall', '-Wextra', '-Werror',
        test_file, '-L..', '-lft', '-o', output_name
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Erreur de compilation: {e.stderr}")
        return False

def run_test_program(program_name):
    """Exécute un programme de test"""
    try:
        result = subprocess.run([f'./{program_name}'],
                              capture_output=True, text=True, check=True)
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def test_compilation():
    """Teste la compilation de la bibliothèque"""
    print_header("Test de compilation")

    os.chdir('..')

    # Clean d'abord
    print_info("Nettoyage des fichiers précédents...")
    subprocess.run(['make', 'fclean'], capture_output=True)

    # Compilation normale
    print_info("Compilation de libft.a...")
    result = subprocess.run(['make'], capture_output=True, text=True)
    if result.returncode == 0:
        print_success("Compilation réussie (partie obligatoire)")
    else:
        print_error("Échec de la compilation")
        print(result.stderr)
        return False

    # Compilation avec bonus
    print_info("Compilation avec bonus...")
    result = subprocess.run(['make', 'bonus'], capture_output=True, text=True)
    if result.returncode == 0:
        print_success("Compilation réussie (avec bonus)")
    else:
        print_error("Échec de la compilation bonus")
        print(result.stderr)
        return False

    os.chdir('tests_realisation')
    return True

def test_basic_functions():
    """Teste les fonctions de base avec un programme C simple"""
    print_header("Test des fonctions de base")

    # Créer un petit programme de test
    test_program = """
#include "../libft.h"
#include <stdio.h>
#include <string.h>

int main(void)
{
    int passed = 0;
    int total = 0;

    // Test ft_strlen
    total++;
    if (ft_strlen("Hello") == 5)
    {
        printf("✅ ft_strlen: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_strlen: FAIL\\n");

    // Test ft_isalpha
    total++;
    if (ft_isalpha('a') && ft_isalpha('Z') && !ft_isalpha('1'))
    {
        printf("✅ ft_isalpha: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_isalpha: FAIL\\n");

    // Test ft_isdigit
    total++;
    if (ft_isdigit('5') && !ft_isdigit('a'))
    {
        printf("✅ ft_isdigit: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_isdigit: FAIL\\n");

    // Test ft_toupper
    total++;
    if (ft_toupper('a') == 'A' && ft_toupper('Z') == 'Z')
    {
        printf("✅ ft_toupper: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_toupper: FAIL\\n");

    // Test ft_tolower
    total++;
    if (ft_tolower('A') == 'a' && ft_tolower('z') == 'z')
    {
        printf("✅ ft_tolower: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_tolower: FAIL\\n");

    // Test ft_strdup
    total++;
    char *dup = ft_strdup("test");
    if (dup && strcmp(dup, "test") == 0)
    {
        printf("✅ ft_strdup: OK\\n");
        passed++;
        free(dup);
    }
    else
        printf("❌ ft_strdup: FAIL\\n");

    // Test ft_atoi
    total++;
    if (ft_atoi("42") == 42 && ft_atoi("-123") == -123)
    {
        printf("✅ ft_atoi: OK\\n");
        passed++;
    }
    else
        printf("❌ ft_atoi: FAIL\\n");

    // Test ft_split
    total++;
    char **result = ft_split("Hello,World,Test", ',');
    if (result && strcmp(result[0], "Hello") == 0 &&
        strcmp(result[1], "World") == 0 && strcmp(result[2], "Test") == 0)
    {
        printf("✅ ft_split: OK\\n");
        passed++;
        for (int i = 0; result[i]; i++)
            free(result[i]);
        free(result);
    }
    else
        printf("❌ ft_split: FAIL\\n");

    printf("\\n=== Résultats: %d/%d tests réussis ===\\n", passed, total);
    return (passed == total) ? 0 : 1;
}
"""

    # Écrire le programme de test
    with open('basic_test.c', 'w') as f:
        f.write(test_program)

    # Compiler
    if not compile_test_program('basic_test.c', 'basic_test'):
        return False

    # Exécuter
    success, output = run_test_program('basic_test')
    print(output)

    # Nettoyer
    os.remove('basic_test.c')
    if os.path.exists('basic_test'):
        os.remove('basic_test')

    return success

def main():
    """Fonction principale"""
    print_header("Tests Automatisés - Libft")

    passed_tests = 0
    total_tests = 2

    # Test 1: Compilation
    if test_compilation():
        passed_tests += 1

    # Test 2: Fonctions de base
    if check_libft_exists():
        if test_basic_functions():
            passed_tests += 1

    # Résumé final
    print_header("Résumé des Tests")
    print(f"Tests réussis: {passed_tests}/{total_tests}")

    if passed_tests == total_tests:
        print_success("Tous les tests sont passés! 🎉")
        return 0
    else:
        print_error(f"{total_tests - passed_tests} test(s) échoué(s)")
        return 1

if __name__ == "__main__":
    sys.exit(main())
