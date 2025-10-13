from __future__ import annotations

import argparse
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence

from googletrans import Translator  # type: ignore
from PyPDF2 import PdfReader  # type: ignore


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_ROOT = (SCRIPT_DIR.parent / "organized_subjects").resolve()
ROOT: Path = DEFAULT_ROOT
TRANSLATION_CACHE: dict[str, str] = {}
STOPWORDS = {
    "the",
    "and",
    "for",
    "with",
    "that",
    "from",
    "this",
    "your",
    "you",
    "are",
    "into",
    "have",
    "will",
    "should",
    "project",
    "program",
    "application",
    "tool",
    "software",
    "student",
    "make",
    "must",
    "can",
    "been",
    "being",
    "over",
    "about",
    "when",
    "while",
    "what",
    "where",
    "which",
    "between",
    "each",
    "such",
    "their",
    "those",
    "these",
    "into",
    "using",
    "through",
    "within",
    "under",
    "shall",
    "able",
    "also",
    "else",
    "once",
    "upon",
    "every",
    "first",
    "second",
    "third",
    "several",
    "again",
    "faire",
    "afin",
    "plus",
    "ainsi",
    "sous",
    "entre",
    "dont",
    "dans",
    "pour",
    "avec",
    "sans",
    "chez",
    "hors",
    "vers",
    "versus",
    "mais",
    "alors",
    "donc",
    "ainsi",
    "tout",
    "tous",
    "toutes",
    "comme",
    "quelque",
    "quelques",
    "leurs",
    "leurs",
    "leurs",
    "leur",
    "nous",
    "vous",
    "ils",
    "elles",
    "est",
    "sont",
    "sera",
    "seront",
    "été",
    "être",
    "aura",
    "auront",
    "avoir",
    "faut",
    "falloir",
    "permet",
    "permettre",
    "doit",
    "doivent",
    "devra",
    "devront",
    "déjà",
    "nouveau",
    "nouvelle",
    "autres",
    "autre",
    "tels",
    "telles",
    "cela",
    "celle",
    "celle-ci",
    "celui",
    "celui-ci",
    "une",
    "des",
    "les",
    "les",
    "aux",
    "par",
    "pour",
    "sur",
}
MAX_PAGES_PER_PDF = 3


@dataclass
class SectionSpec:
    label: str
    keywords: Sequence[str]
    fallback_en: str
    fallback_fr: str


SECTION_SPECS: List[SectionSpec] = [
    SectionSpec(
        "Contexte / objectif général",
        (
            "goal",
            "objective",
            "purpose",
            "context",
            "aim",
            "overview",
            "contexte",
            "objectif",
            "but",
            "présentation",
        ),
        "This subject introduces the overall objective of the project.",
        "Le sujet présente les objectifs généraux du projet.",
    ),
    SectionSpec(
        "Langage / environnement utilisé",
        (
            "language",
            "environment",
            "library",
            "framework",
            "C",
            "C++",
            "C#",
            "python",
            "java",
            "javascript",
            "typescript",
            "shell",
            "bash",
            "sql",
            "php",
            "swift",
            "kotlin",
            "ruby",
            "rust",
            "go",
            "scala",
            "haskell",
            "node",
            "docker",
            "kubernetes",
            "langage",
            "technologie",
            "environnement",
            "framework",
        ),
        "The programming language or environment is detailed in the first pages of the subject.",
        "Le sujet précise le langage ou l’environnement recommandé pour le projet.",
    ),
    SectionSpec(
        "Description fonctionnelle",
        (
            "project",
            "program",
            "application",
            "tool",
            "software",
            "implement",
            "build",
            "create",
            "fonctionnalité",
            "description",
            "comportement",
            "programme",
            "service",
        ),
        "The document details the main behaviour expected from the project deliverables.",
        "Le document décrit le comportement attendu des livrables du projet.",
    ),
    SectionSpec(
        "Contraintes techniques",
        (
            "constraint",
            "requirement",
            "forbidden",
            "limit",
            "rule",
            "mandatory",
            "performance",
            "norm",
            "contrainte",
            "règle",
            "limite",
            "interdiction",
            "norme",
        ),
        "Specific technical constraints, coding standards or limits are highlighted in the subject.",
        "Le sujet insiste sur les contraintes techniques, normes et limites imposées.",
    ),
    SectionSpec(
        "Concepts clés",
        (
            "algorithm",
            "data structure",
            "logic",
            "parsing",
            "mathematics",
            "network",
            "graphics",
            "concurrency",
            "security",
            "machine learning",
            "ai",
            "database",
            "algorithme",
            "structure",
            "concept",
            "mathématique",
            "logique",
            "réseau",
            "graphique",
            "sécurité",
            "base de données",
        ),
        "Key computer science concepts and skills are emphasised throughout the brief.",
        "Les notions d’informatique à maîtriser sont mises en avant dans le document.",
    ),
    SectionSpec(
        "Méthodologie / approche",
        (
            "approach",
            "method",
            "workflow",
            "step",
            "progress",
            "roadmap",
            "guideline",
            "méthodologie",
            "approche",
            "processus",
            "stratégie",
            "étape",
        ),
        "An incremental or recommended methodology is suggested to tackle the project.",
        "Une démarche conseillée pour mener le projet est généralement proposée.",
    ),
    SectionSpec(
        "Exemple d’exécution ou de résultat attendu",
        (
            "example",
            "output",
            "result",
            "sample",
            "expected",
            "illustration",
            "exemple",
            "résultat",
            "sortie",
            "démonstration",
        ),
        "Example usages or expected outputs are provided to illustrate the solution.",
        "Le sujet fournit des exemples d’exécution ou de résultats attendus.",
    ),
    SectionSpec(
        "Difficultés rencontrées / apprentissages",
        (
            "challenge",
            "difficulty",
            "learn",
            "learning",
            "knowledge",
            "insight",
            "experience",
            "difficulté",
            "apprentissage",
            "compétence",
            "progression",
        ),
        "The subject underlines the learning outcomes and challenges addressed by the project.",
        "Les difficultés prévues et les apprentissages visés sont mis en lumière.",
    ),
    SectionSpec(
        "Bonus ou extensions possibles",
        (
            "bonus",
            "optional",
            "extra",
            "extension",
            "improvement",
            "enhancement",
            "bonus",
            "optionnel",
            "amélioration",
            "supplément",
        ),
        "Possible bonus features or optional improvements are discussed in the subject.",
        "Des pistes de bonus ou d’améliorations optionnelles sont évoquées.",
    ),
    SectionSpec(
        "Conclusion rapide",
        ("conclusion", "summary", "wrap", "final", "validation", "deliverable", "conclusion", "synthèse"),
        "The conclusion summarises what success in the project demonstrates.",
        "La conclusion rappelle ce que la réussite du projet met en valeur.",
    ),
]


LANGUAGE_LABELS = {
    "C": (r"(?<!\w)C(?!\w|\+\+)",),
    "C++": (r"C\+\+",),
    "C#": (r"C#",),
    "Python": (r"python", r"\bpy\b"),
    "Java": (r"java",),
    "JavaScript": (r"javascript", r"node\.js", r"nodejs"),
    "TypeScript": (r"typescript",),
    "Shell": (r"shell", r"\bbash\b"),
    "SQL": (r"\bsql\b",),
    "PHP": (r"\bphp\b",),
    "Swift": (r"\bswift\b",),
    "Kotlin": (r"\bkotlin\b",),
    "Ruby": (r"\bruby\b",),
    "Rust": (r"\brust\b",),
    "Go": (r"\bgo\b",),
    "Scala": (r"\bscala\b",),
    "Haskell": (r"\bhaskell\b",),
    "OCaml": (r"\bocaml\b",),
    "R": (r" R ", r"\bR\b"),
    "Perl": (r"\bperl\b",),
    "Docker": (r"docker",),
    "Kubernetes": (r"kubernetes",),
    "React": (r"react",),
    "Vue.js": (r"vue\.js", r"\bvue\b"),
    "Angular": (r"angular",),
    "Symfony": (r"symfony",),
    "Laravel": (r"laravel",),
    "Unreal": (r"unreal",),
    "Unity": (r"unity",),
}


def extract_text_from_pdf(path: Path, max_pages: int | None = None) -> str:
    pages_to_read = max_pages if max_pages is not None else MAX_PAGES_PER_PDF
    try:
        reader = PdfReader(str(path))
    except Exception as exc:  # pragma: no cover - defensive
        print(f"[warn] Cannot open {path}: {exc}", file=sys.stderr)
        return ""

    text_parts: List[str] = []
    for idx, page in enumerate(reader.pages[:pages_to_read]):
        try:
            chunk = page.extract_text() or ""
        except Exception as exc:  # pragma: no cover - defensive
            print(f"[warn] Cannot extract page {idx} from {path}: {exc}", file=sys.stderr)
            continue
        text_parts.append(chunk)
    return "\n".join(text_parts)


def normalise_text(text: str) -> str:
    text = text.replace("\r\n", "\n")
    text = text.replace("\r", "\n")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{2,}", "\n", text)
    return text


def split_sentences(text: str) -> List[str]:
    raw_candidates = re.split(r"(?<=[.!?])\s+|\n", text)
    paragraphs = text.split("\n")
    seen = set()
    sentences: List[str] = []

    def add_candidate(candidate: str) -> None:
        cleaned = candidate.strip(" \t-•")
        if not cleaned:
            return
        lowered = cleaned.lower()
        if lowered in seen:
            return
        if re.match(r"^(?:[IVXLCDM]+|[0-9]+)(?:\.|-|\s)", cleaned):
            return
        if len(cleaned.split()) < 4 and ":" not in cleaned:
            return
        if len(cleaned) < 20 and ":" not in cleaned:
            return
        seen.add(lowered)
        sentences.append(cleaned)

    for candidate in raw_candidates:
        add_candidate(candidate)
    for paragraph in paragraphs:
        add_candidate(paragraph)

    return sentences


def detect_languages(text: str) -> Sequence[str]:
    found = []
    for label, patterns in LANGUAGE_LABELS.items():
        for pattern in patterns:
            if re.search(pattern, text, flags=re.IGNORECASE):
                found.append(label)
                break
    return found


def pick_sentence(sentences: Sequence[str], keywords: Sequence[str], used: set[int]) -> str:
    lowered_keywords = [kw.lower() for kw in keywords]
    for index, sentence in enumerate(sentences):
        if index in used:
            continue
        lowered = sentence.lower()
        if any(keyword in lowered for keyword in lowered_keywords):
            used.add(index)
            return sentence
    for index, sentence in enumerate(sentences):
        if index in used:
            continue
        if len(sentence.split()) > 6:
            used.add(index)
            return sentence
    return ""


def sanitise_snippet(text: str) -> str:
    snippet = text.strip()
    snippet = re.sub(r"^(résumé|summary)\s*:?\s*", "", snippet, flags=re.IGNORECASE)
    snippet = re.sub(r"^(?:section|chapter)\s+[0-9IVXLCDM]+\s*:?\s*", "", snippet, flags=re.IGNORECASE)
    snippet = re.sub(r"^(?:objectifs?|goals?)\s*:?\s*", "", snippet, flags=re.IGNORECASE)
    snippet = re.sub(r"\s+", " ", snippet)
    if snippet and snippet[-1] not in ".?!":
        snippet += "."
    return snippet


def extract_snippet_by_keyword(text: str, keywords: Sequence[str]) -> str:
    lowered = text.lower()
    for keyword in keywords:
        search_start = 0
        while True:
            idx = lowered.find(keyword, search_start)
            if idx == -1:
                break
            start = text.rfind(".", 0, idx)
            if start == -1:
                start = text.rfind("\n", 0, idx)
            if start == -1:
                start = max(idx - 180, 0)
            else:
                start += 1
            end = text.find(".", idx)
            if end == -1:
                end = text.find("\n", idx)
            if end == -1:
                end = min(idx + 220, len(text))
            snippet = text[start:end].strip()
            snippet = re.sub(r"\s+", " ", snippet)
            if is_valid_snippet(snippet):
                return sanitise_snippet(snippet)
            search_start = idx + len(keyword)
    return ""


def is_valid_snippet(snippet: str) -> bool:
    if not snippet:
        return False
    lowered = snippet.lower()
    if len(snippet.split()) < 4:
        return False
    ignored_markers = (
        "table des matières",
        "table of contents",
        "english version coming soon",
    )
    if any(marker in lowered for marker in ignored_markers):
        return False
    return True


def extract_top_keywords(text: str, limit: int = 6) -> List[str]:
    tokens = re.findall(r"[A-Za-zÀ-ÖØ-öø-ÿ0-9]+", text.lower())
    counts: dict[str, int] = {}
    for token in tokens:
        if len(token) < 4:
            continue
        if token in STOPWORDS:
            continue
        counts[token] = counts.get(token, 0) + 1
    sorted_tokens = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    return [token for token, _ in sorted_tokens[:limit]]


def build_summary_for_pdf(path: Path, translator: Translator) -> List[str]:
    raw_text = extract_text_from_pdf(path)
    normalised = normalise_text(raw_text)
    sentences = split_sentences(normalised)
    used_indices: set[int] = set()
    used_snippets: List[str] = []
    top_keywords = extract_top_keywords(normalised)

    english_lines: List[str] = []
    for section in SECTION_SPECS:
        sentence = pick_sentence(sentences, section.keywords, used_indices)
        if sentence:
            sentence = sanitise_snippet(sentence)
        else:
            sentence = extract_snippet_by_keyword(normalised, section.keywords)
        duplicate = False
        for existing in used_snippets:
            if sentence == existing or sentence in existing or existing in sentence:
                duplicate = True
                break
        if duplicate:
            sentence = ""
        if not sentence:
            sentence = section.fallback_en
        used_snippets.append(sentence)
        english_lines.append(sentence)

    languages = detect_languages(normalised)
    if languages:
        english_lines[1] = f"The recommended environment mentions: {', '.join(sorted(set(languages)))}."
    if top_keywords:
        concepts = ", ".join(top_keywords[:4])
        english_lines[4] = f"Core concepts highlighted include: {concepts}."
        skills = ", ".join(top_keywords[:3])
        english_lines[7] = f"The project strengthens skills around {skills}."

    lines: List[str] = []
    for section, content in zip(SECTION_SPECS, english_lines):
        french = translate_fragment(translator, content, path)
        cleaned = french.strip()
        if not cleaned:
            cleaned = section.fallback_fr
        lines.append(f"- {section.label} : {cleaned}")
    return lines


def format_title(path: Path) -> str:
    parts = list(path.parts)
    if len(parts) >= 2:
        category = parts[-2]
    else:
        category = "Divers"
    raw_name = path.stem
    words = re.split(r"[_\-\s]+", raw_name)
    nice_title = " ".join(w.capitalize() for w in words if w)
    return f"### {category} — {nice_title}"


def translate_fragment(translator: Translator, text: str, context_path: Path, attempts: int = 3) -> str:
    if not text:
        return ""
    cached = TRANSLATION_CACHE.get(text)
    if cached is not None:
        return cached
    delay = 1.0
    for attempt in range(1, attempts + 1):
        try:
            translated = translator.translate(text, src="auto", dest="fr").text
        except Exception as exc:  # pragma: no cover - defensive
            print(f"[warn] Translation attempt {attempt} failed for {context_path}: {exc}", file=sys.stderr)
            time.sleep(delay)
            delay *= 1.5
            continue
        TRANSLATION_CACHE[text] = translated
        return translated
    print(f"[warn] Falling back to original text for {context_path}.", file=sys.stderr)
    TRANSLATION_CACHE[text] = text
    return text


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate French summaries for 42 subjects.")
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Nombre maximum de projets à traiter (pour tests).",
    )
    parser.add_argument(
        "--max-pages",
        type=int,
        default=MAX_PAGES_PER_PDF,
        help="Nombre de pages lues par PDF (défaut: 3).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("projets_details.md"),
        help="Chemin du fichier de sortie.",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=DEFAULT_ROOT,
        help="Répertoire contenant les sujets à analyser.",
    )
    parser.add_argument(
        "--start",
        type=int,
        default=0,
        help="Index de départ (0-based) dans la liste triée des PDF.",
    )
    parser.add_argument(
        "--append",
        action="store_true",
        help="Ajoute les nouveaux résumés à la suite du fichier si celui-ci existe déjà.",
    )
    return parser


def main() -> int:
    parser = build_arg_parser()
    args = parser.parse_args()

    global MAX_PAGES_PER_PDF
    global ROOT
    MAX_PAGES_PER_PDF = args.max_pages
    ROOT = args.root.resolve()

    if not ROOT.exists():
        print(f"[error] {ROOT} not found.", file=sys.stderr)
        return 1

    start_index = max(0, args.start)

    translator = Translator()
    root_label = f"`{ROOT}`" if ROOT.name == "organized_subjects" else f"`{ROOT}`"
    append_mode = args.append and args.output.exists()
    output_lines: List[str] = []
    if not append_mode:
        output_lines.extend(
            [
                "# Résumé des projets 42",
                "",
                f"Ce document présente une synthèse automatisée des sujets disponibles dans {root_label}. Chaque projet est résumé en une dizaine de lignes suivant la structure demandée.",
                "",
            ]
        )

    pdf_paths = sorted(ROOT.rglob("*.pdf"))
    total_available = len(pdf_paths)
    if start_index:
        pdf_paths = pdf_paths[start_index:]
    if args.limit is not None:
        pdf_paths = pdf_paths[: args.limit]

    if not pdf_paths:
        print("[info] Aucun sujet à traiter avec les paramètres fournis.")
        return 0

    total_to_process = len(pdf_paths)

    for index, pdf_path in enumerate(pdf_paths, start=1):
        absolute_index = start_index + index
        print(f"[info] Processing {absolute_index}/{total_available}: {pdf_path}")
        output_lines.append(format_title(pdf_path.relative_to(ROOT)))
        summary_lines = build_summary_for_pdf(pdf_path, translator)
        output_lines.extend(summary_lines)
        output_lines.append("")
        if index % 20 == 0:
            time.sleep(1.5)
        else:
            time.sleep(0.2)

    text_to_write = "\n".join(output_lines)
    if append_mode:
        ensure_newline = True
        if args.output.exists():
            try:
                with args.output.open("rb") as fh:
                    fh.seek(-1, 2)
                    last_char = fh.read(1)
                    if last_char in {b"\n", b"\r"}:
                        ensure_newline = False
            except OSError:
                ensure_newline = True
        with args.output.open("a", encoding="utf-8") as handle:
            if ensure_newline:
                handle.write("\n")
            handle.write(text_to_write)
    else:
        args.output.write_text(text_to_write, encoding="utf-8")

    print(f"[info] Wrote {total_to_process} project summaries to {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
