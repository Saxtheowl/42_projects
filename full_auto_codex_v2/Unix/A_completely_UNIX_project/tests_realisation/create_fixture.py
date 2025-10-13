from __future__ import annotations

import struct
from pathlib import Path

MH_MAGIC_64 = 0xfeedfacf
CPU_TYPE_X86_64 = 0x01000007
CPU_SUBTYPE_X86_64_ALL = 0x00000003
MH_EXECUTE = 0x2
LC_SEGMENT_64 = 0x19
LC_SYMTAB = 0x2

SEGNAME_TEXT = b"__TEXT" + b"\x00" * 10
SECTNAME_TEXT = b"__text" + b"\x00" * 10

HEADER_SIZE = 32
SEGMENT_SIZE = 72
SECTION_SIZE = 80
SYMTAB_SIZE = 24
LOAD_COMMANDS_SIZE = SEGMENT_SIZE + SECTION_SIZE + SYMTAB_SIZE

SYMBOL_SIZE = 16
TEXT_OFFSET = 0x200
TEXT_SIZE = 16

SYMTAB_OFFSET = HEADER_SIZE + LOAD_COMMANDS_SIZE
STRING_TABLE_OFFSET = SYMTAB_OFFSET + 2 * SYMBOL_SIZE

STRING_TABLE = b"\x00_main\x00_helper\x00"


def build_binary() -> bytes:
    buffer_size = TEXT_OFFSET + TEXT_SIZE
    buf = bytearray(buffer_size)

    header = struct.pack(
        "<IiiIIIII",
        MH_MAGIC_64,
        CPU_TYPE_X86_64,
        CPU_SUBTYPE_X86_64_ALL,
        MH_EXECUTE,
        2,  # ncmds
        LOAD_COMMANDS_SIZE,
        0,  # flags
        0,  # reserved
    )
    buf[0:HEADER_SIZE] = header

    segment = struct.pack(
        "<II16sQQQQIIII",
        LC_SEGMENT_64,
        SEGMENT_SIZE + SECTION_SIZE,
        SEGNAME_TEXT,
        0x0000000000001000,
        0x0000000000001000,
        0,
        TEXT_SIZE,
        7,
        5,
        1,
        0,
    )
    buf[HEADER_SIZE:HEADER_SIZE + SEGMENT_SIZE] = segment

    section = struct.pack(
        "<16s16sQQIIIIIIII",
        SECTNAME_TEXT,
        SEGNAME_TEXT,
        0x0000000000001000,
        TEXT_SIZE,
        TEXT_OFFSET,
        4,
        0,
        0,
        0,
        0,
        0,
        0,
    )
    buf[HEADER_SIZE + SEGMENT_SIZE:HEADER_SIZE + SEGMENT_SIZE + SECTION_SIZE] = section

    symtab = struct.pack(
        "<IIIIII",
        LC_SYMTAB,
        SYMTAB_SIZE,
        SYMTAB_OFFSET,
        2,
        STRING_TABLE_OFFSET,
        len(STRING_TABLE),
    )
    buf[HEADER_SIZE + SEGMENT_SIZE + SECTION_SIZE:
        HEADER_SIZE + SEGMENT_SIZE + SECTION_SIZE + SYMTAB_SIZE] = symtab

    # Symbols
    nlist_main = struct.pack(
        "<IBBHQ",
        1,
        0x0F,
        1,
        0,
        0x0000000000001000,
    )
    nlist_helper = struct.pack(
        "<IBBHQ",
        7,
        0x01,
        0,
        0,
        0,
    )
    buf[SYMTAB_OFFSET:SYMTAB_OFFSET + SYMBOL_SIZE] = nlist_main
    buf[SYMTAB_OFFSET + SYMBOL_SIZE:SYMTAB_OFFSET + 2 * SYMBOL_SIZE] = nlist_helper

    buf[STRING_TABLE_OFFSET:STRING_TABLE_OFFSET + len(STRING_TABLE)] = STRING_TABLE

    text_bytes = bytes.fromhex("554889e54883ec10488d3d12000000c3")
    if len(text_bytes) != TEXT_SIZE:
        raise ValueError("Unexpected text size")
    buf[TEXT_OFFSET:TEXT_OFFSET + TEXT_SIZE] = text_bytes

    return bytes(buf)


def create_fixture(path: Path) -> None:
    path.write_bytes(build_binary())


if __name__ == "__main__":
    target = Path(__file__).resolve().parent / "fixtures" / "sample64.macho"
    target.parent.mkdir(parents=True, exist_ok=True)
    create_fixture(target)
