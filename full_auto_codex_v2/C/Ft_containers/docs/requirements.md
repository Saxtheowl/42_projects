# ft_containers — Récapitulatif API (C++98)

> Références croisées : cplusplus.com (version 2003-2010), spécification C++03.  
> Les `get_allocator()` sont explicitement exclus par le sujet.

## ft::vector
- **Types** : `value_type`, `allocator_type`, `pointer`, `reference`, `const_reference`, `size_type`, `difference_type`, `iterator`, `const_iterator`, `reverse_iterator`, `const_reverse_iterator`.
- **Coplien** : constructeur par défaut, fill, range, copy, destructeur, `operator=`.
- **Itérateurs** : `begin/end`, `rbegin/rend`.
- **Capacité** : `size`, `max_size`, `resize`, `capacity`, `empty`, `reserve`.
- **Accès éléments** : `operator[]`, `at`, `front`, `back`.
- **Modificateurs** : `assign` (range + fill), `push_back`, `pop_back`, `insert` (single, fill, range), `erase` (single, range), `swap`, `clear`.
- **Non-membres** : `operator==/!=/<=>` (==, !=, <, <=, >, >=) vs std::vector ; `swap(vector&, vector&)`.

## ft::list
- **Types** : similaires au vector (bidirectional iterators).
- **Constructeurs** : défaut, fill, range, copie, destructeur, `operator=`.
- **Itérateurs** : `begin/end`, `rbegin/rend`.
- **Capacité** : `empty`, `size`, `max_size`.
- **Accès** : `front`, `back`.
- **Modificateurs** : `assign`, `push_front/back`, `pop_front/back`, `insert`, `erase`, `swap`, `resize`, `clear`.
- **Opérations spécifiques** : `splice` (entière, single, range), `remove`, `remove_if`, `unique`, `merge`, `sort`, `reverse`.
- **Non-membres** : opérateurs relationnels & `swap`.

## ft::map (clé ordonnée)
- **Types** : `key_type`, `mapped_type`, `value_type`, `key_compare`, `value_compare`, `allocator_type`, `iterator` (bidirectional), `const_iterator`, etc.
- **Constructeurs** : défaut, range, copie, destructeur, `operator=`.
- **Itérateurs** : `begin/end`, `rbegin/rend`.
- **Capacité** : `empty`, `size`, `max_size`.
- **Accès** : `operator[]`.
- **Modificateurs** : `insert` (pair, position hint, range), `erase` (by key, iterator, range), `swap`, `clear`.
- **Observateurs** : `key_comp`, `value_comp`.
- **Opérations** : `find`, `count`, `lower_bound`, `upper_bound`, `equal_range`.
- **Non-membres** : opérateurs relationnels, `swap`.

## ft::stack (adaptateur)
- **Types** : `value_type`, `container_type`, `size_type`.
- **Constructeurs** : explicite à partir du conteneur sous-jacent (par défaut `vector<T>` ou `deque` maison).
- **Capacité** : `empty`, `size`.
- **Accès élément** : `top`.
- **Modificateurs** : `push`, `pop`.
- **Non-membres** : opérateurs relationnels (`==`, `!=`, `<`, `<=`, `>`, `>=`).

## ft::queue (adaptateur FIFO)
- **Types** : analogues à `stack`.
- **Constructeurs** : idem (conteneur sous-jacent par défaut `list` ou `deque` maison).
- **Capacité** : `empty`, `size`.
- **Accès** : `front`, `back`.
- **Modificateurs** : `push`, `pop`.
- **Non-membres** : même jeu d'opérateurs relationnels.

## Utilitaires communs à préparer
- `iterator_traits`, `reverse_iterator`, `random_access_iterator`, `bidirectional_iterator`.
- Méta-programmation : `enable_if`, `is_integral`.
- Algorithmes : `lexicographical_compare`, `equal`.
- Structures : arbre RB pour `map`, conteneur linéaire bas niveau pour `list`.

## Tests attendus
- `main.cpp` pouvant être compilé en mode `std` ou `ft` (macro).  
- Comparaison des API, itérateurs, exceptions (`at`, `map::at` non requis).  
- Tests de performance basiques (mesure temps insertion 42k éléments).
