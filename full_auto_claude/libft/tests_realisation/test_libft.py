#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Système de tests automatisés pour Libft
Ce script teste toutes les fonctions de la bibliothèque libft
"""

import subprocess
import os
import sys
from typing import Tuple

# Couleurs pour l'affichage
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

class LibftTester:
    def __init__(self, libft_path="../"):
        self.libft_path = libft_path
        self.tests_passed = 0
        self.tests_failed = 0
        self.temp_dir = "./temp_test"

    def setup(self):
        """Prépare l'environnement de test"""
        print(f"{BLUE}=== Configuration de l'environnement de test ==={RESET}")

        # Créer le répertoire temporaire
        os.makedirs(self.temp_dir, exist_ok=True)

        # Compiler la bibliothèque
        print(f"{YELLOW}Compilation de libft...{RESET}")
        result = subprocess.run(
            ["make", "-C", self.libft_path],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print(f"{RED}Erreur lors de la compilation:{RESET}")
            print(result.stderr)
            return False

        # Compiler avec bonus
        print(f"{YELLOW}Compilation des bonus...{RESET}")
        result = subprocess.run(
            ["make", "bonus", "-C", self.libft_path],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print(f"{RED}Erreur lors de la compilation bonus:{RESET}")
            print(result.stderr)
            return False

        print(f"{GREEN}Compilation réussie!{RESET}\n")
        return True

    def compile_test(self, test_name: str, source_code: str) -> bool:
        """Compile un programme de test"""
        source_file = f"{self.temp_dir}/{test_name}.c"
        output_file = f"{self.temp_dir}/{test_name}"

        # Écrire le code source
        with open(source_file, 'w') as f:
            f.write(source_code)

        # Compiler
        result = subprocess.run(
            ["cc", "-Wall", "-Wextra", "-Werror", source_file,
             "-L", self.libft_path, "-lft", "-o", output_file,
             "-I", self.libft_path],
            capture_output=True,
            text=True
        )

        return result.returncode == 0

    def run_test(self, test_name: str, description: str, source_code: str,
                 expected_output: str = None, should_compile: bool = True) -> bool:
        """Exécute un test"""
        print(f"{YELLOW}Test:{RESET} {description}...", end=" ")

        # Compiler le test
        if not self.compile_test(test_name, source_code):
            if not should_compile:
                print(f"{GREEN}OK (échec de compilation attendu){RESET}")
                self.tests_passed += 1
                return True
            else:
                print(f"{RED}ÉCHEC (compilation){RESET}")
                self.tests_failed += 1
                return False

        # Exécuter le test
        result = subprocess.run(
            [f"{self.temp_dir}/{test_name}"],
            capture_output=True,
            text=True,
            timeout=5
        )

        # Vérifier la sortie si fournie
        if expected_output is not None:
            if result.stdout.strip() == expected_output.strip():
                print(f"{GREEN}OK{RESET}")
                self.tests_passed += 1
                return True
            else:
                print(f"{RED}ÉCHEC{RESET}")
                print(f"  Attendu: {expected_output}")
                print(f"  Obtenu:  {result.stdout.strip()}")
                self.tests_failed += 1
                return False
        else:
            # Si pas de sortie attendue, vérifier juste que ça s'exécute
            if result.returncode == 0:
                print(f"{GREEN}OK{RESET}")
                self.tests_passed += 1
                return True
            else:
                print(f"{RED}ÉCHEC{RESET}")
                self.tests_failed += 1
                return False

    def test_part1_mem(self):
        """Tests des fonctions mémoire (Part 1)"""
        print(f"\n{BLUE}=== Tests Part 1: Fonctions Mémoire ==={RESET}")

        # Test ft_memset
        self.run_test("test_memset", "ft_memset",
            """
            #include <string.h>
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                char buffer[10];
                ft_memset(buffer, 'A', 5);
                buffer[5] = '\\0';
                printf("%s", buffer);
                return 0;
            }
            """,
            "AAAAA"
        )

        # Test ft_bzero
        self.run_test("test_bzero", "ft_bzero",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                char buffer[5] = "test";
                ft_bzero(buffer, 5);
                int all_zero = 1;
                for (int i = 0; i < 5; i++)
                    if (buffer[i] != 0) all_zero = 0;
                printf("%d", all_zero);
                return 0;
            }
            """,
            "1"
        )

        # Test ft_memcpy
        self.run_test("test_memcpy", "ft_memcpy",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                char src[] = "Hello";
                char dst[10];
                ft_memcpy(dst, src, 6);
                printf("%s", dst);
                return 0;
            }
            """,
            "Hello"
        )

        # Test ft_memcmp
        self.run_test("test_memcmp", "ft_memcmp",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                char s1[] = "Hello";
                char s2[] = "Hello";
                char s3[] = "World";
                printf("%d %d", ft_memcmp(s1, s2, 5) == 0, ft_memcmp(s1, s3, 5) != 0);
                return 0;
            }
            """,
            "1 1"
        )

    def test_part1_str(self):
        """Tests des fonctions string (Part 1)"""
        print(f"\n{BLUE}=== Tests Part 1: Fonctions String ==={RESET}")

        # Test ft_strlen
        self.run_test("test_strlen", "ft_strlen",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%zu", ft_strlen("Hello World"));
                return 0;
            }
            """,
            "11"
        )

        # Test ft_strchr
        self.run_test("test_strchr", "ft_strchr",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                char *str = "Hello World";
                char *result = ft_strchr(str, 'W');
                printf("%s", result);
                return 0;
            }
            """,
            "World"
        )

        # Test ft_strdup
        self.run_test("test_strdup", "ft_strdup",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char *dup = ft_strdup("Test");
                printf("%s", dup);
                free(dup);
                return 0;
            }
            """,
            "Test"
        )

        # Test ft_strncmp
        self.run_test("test_strncmp", "ft_strncmp",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%d", ft_strncmp("Hello", "Hello", 5) == 0);
                return 0;
            }
            """,
            "1"
        )

    def test_part1_char(self):
        """Tests des fonctions caractères (Part 1)"""
        print(f"\n{BLUE}=== Tests Part 1: Fonctions Caractères ==={RESET}")

        # Test ft_isalpha
        self.run_test("test_isalpha", "ft_isalpha",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%d %d", ft_isalpha('a') != 0, ft_isalpha('1') == 0);
                return 0;
            }
            """,
            "1 1"
        )

        # Test ft_isdigit
        self.run_test("test_isdigit", "ft_isdigit",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%d %d", ft_isdigit('5') != 0, ft_isdigit('a') == 0);
                return 0;
            }
            """,
            "1 1"
        )

        # Test ft_toupper
        self.run_test("test_toupper", "ft_toupper",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%c", ft_toupper('a'));
                return 0;
            }
            """,
            "A"
        )

        # Test ft_tolower
        self.run_test("test_tolower", "ft_tolower",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%c", ft_tolower('Z'));
                return 0;
            }
            """,
            "z"
        )

        # Test ft_atoi
        self.run_test("test_atoi", "ft_atoi",
            """
            #include <stdio.h>
            #include "libft.h"
            int main(void) {
                printf("%d %d %d", ft_atoi("42"), ft_atoi("-42"), ft_atoi("   123"));
                return 0;
            }
            """,
            "42 -42 123"
        )

    def test_part2(self):
        """Tests des fonctions additionnelles (Part 2)"""
        print(f"\n{BLUE}=== Tests Part 2: Fonctions Additionnelles ==={RESET}")

        # Test ft_substr
        self.run_test("test_substr", "ft_substr",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char *sub = ft_substr("Hello World", 6, 5);
                printf("%s", sub);
                free(sub);
                return 0;
            }
            """,
            "World"
        )

        # Test ft_strjoin
        self.run_test("test_strjoin", "ft_strjoin",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char *joined = ft_strjoin("Hello ", "World");
                printf("%s", joined);
                free(joined);
                return 0;
            }
            """,
            "Hello World"
        )

        # Test ft_strtrim
        self.run_test("test_strtrim", "ft_strtrim",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char *trimmed = ft_strtrim("  Hello  ", " ");
                printf("%s", trimmed);
                free(trimmed);
                return 0;
            }
            """,
            "Hello"
        )

        # Test ft_split
        self.run_test("test_split", "ft_split",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char **split = ft_split("Hello,World,42", ',');
                printf("%s %s %s", split[0], split[1], split[2]);
                for (int i = 0; split[i]; i++) free(split[i]);
                free(split);
                return 0;
            }
            """,
            "Hello World 42"
        )

        # Test ft_itoa
        self.run_test("test_itoa", "ft_itoa",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                char *num1 = ft_itoa(42);
                char *num2 = ft_itoa(-42);
                char *num3 = ft_itoa(0);
                printf("%s %s %s", num1, num2, num3);
                free(num1); free(num2); free(num3);
                return 0;
            }
            """,
            "42 -42 0"
        )

    def test_bonus(self):
        """Tests des fonctions bonus (listes chaînées)"""
        print(f"\n{BLUE}=== Tests Bonus: Listes Chaînées ==={RESET}")

        # Test ft_lstnew
        self.run_test("test_lstnew", "ft_lstnew",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                int *content = malloc(sizeof(int));
                *content = 42;
                t_list *node = ft_lstnew(content);
                printf("%d", *(int*)node->content);
                free(content);
                free(node);
                return 0;
            }
            """,
            "42"
        )

        # Test ft_lstadd_front
        self.run_test("test_lstadd_front", "ft_lstadd_front",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                int *v1 = malloc(sizeof(int)); *v1 = 1;
                int *v2 = malloc(sizeof(int)); *v2 = 2;
                t_list *list = ft_lstnew(v1);
                t_list *new = ft_lstnew(v2);
                ft_lstadd_front(&list, new);
                printf("%d", *(int*)list->content);
                free(v1); free(v2); free(list->next); free(list);
                return 0;
            }
            """,
            "2"
        )

        # Test ft_lstsize
        self.run_test("test_lstsize", "ft_lstsize",
            """
            #include <stdio.h>
            #include <stdlib.h>
            #include "libft.h"
            int main(void) {
                int *v1 = malloc(sizeof(int)); *v1 = 1;
                int *v2 = malloc(sizeof(int)); *v2 = 2;
                int *v3 = malloc(sizeof(int)); *v3 = 3;
                t_list *n1 = ft_lstnew(v1);
                t_list *n2 = ft_lstnew(v2);
                t_list *n3 = ft_lstnew(v3);
                n1->next = n2;
                n2->next = n3;
                printf("%d", ft_lstsize(n1));
                free(v1); free(v2); free(v3);
                free(n1); free(n2); free(n3);
                return 0;
            }
            """,
            "3"
        )

    def cleanup(self):
        """Nettoie l'environnement de test"""
        print(f"\n{BLUE}=== Nettoyage ==={RESET}")
        subprocess.run(["rm", "-rf", self.temp_dir], capture_output=True)
        print(f"{GREEN}Nettoyage terminé{RESET}")

    def print_summary(self):
        """Affiche le résumé des tests"""
        total = self.tests_passed + self.tests_failed
        print(f"\n{BLUE}{'='*50}{RESET}")
        print(f"{BLUE}=== RÉSUMÉ DES TESTS ==={RESET}")
        print(f"{BLUE}{'='*50}{RESET}")
        print(f"Total de tests exécutés: {total}")
        print(f"{GREEN}Tests réussis: {self.tests_passed}{RESET}")
        if self.tests_failed > 0:
            print(f"{RED}Tests échoués: {self.tests_failed}{RESET}")
        else:
            print(f"{GREEN}Aucun test échoué!{RESET}")

        success_rate = (self.tests_passed / total * 100) if total > 0 else 0
        print(f"\nTaux de réussite: {success_rate:.1f}%")
        print(f"{BLUE}{'='*50}{RESET}\n")

    def run_all_tests(self):
        """Exécute tous les tests"""
        if not self.setup():
            print(f"{RED}Impossible de configurer l'environnement de test{RESET}")
            return False

        self.test_part1_mem()
        self.test_part1_str()
        self.test_part1_char()
        self.test_part2()
        self.test_bonus()

        self.cleanup()
        self.print_summary()

        return self.tests_failed == 0

if __name__ == "__main__":
    tester = LibftTester()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)
