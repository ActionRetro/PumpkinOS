#!/usr/bin/env python3
"""List the Palm OS system calls made by an installed app's ARM code and
which of them PumpkinOS's ARM emulator does not handle yet.

usage: util/armcalls.py vfs/app_storage/<App_Name_...>

The app must be installed (run PumpkinOS once with its .prc in
vfs/app_install). ARM code reaches Palm OS through tables found at
[r9 - 12] (DAL), [r9 - 8] (BOOT) and [r9 - 4] (UI); each call is a load of
one of those tables followed by a load from it at the function's offset.
Calls made through computed addresses are not found.
"""
import os
import re
import struct
import sys

GROUPS = {12: (1, 'DAL'), 8: (2, 'BOOT'), 4: (3, 'UI')}
TABLE_NAMES = {1: 'HALTable', 2: 'SystemTable', 3: 'UITable'}
WINDOW = 8  # instructions between loading the table and indexing it


def is_ldr_imm(ins):
    # cond 010 P U 0 W 1 Rn Rd imm12 (word load, immediate offset)
    return (ins & 0x0E500000) == 0x04100000


def scan(code):
    calls = {}
    pending = {}  # register -> (group, instructions left)
    n = len(code) // 4
    for i in range(n):
        ins = struct.unpack_from('<I', code, i * 4)[0]
        for reg in list(pending):
            g, left = pending[reg]
            if left <= 1:
                del pending[reg]
            else:
                pending[reg] = (g, left - 1)
        if not is_ldr_imm(ins):
            continue
        pre = (ins >> 24) & 1
        up = (ins >> 23) & 1
        rn = (ins >> 16) & 0xF
        rd = (ins >> 12) & 0xF
        imm = ins & 0xFFF
        if not pre:
            continue
        if rn == 9 and not up and imm in GROUPS:
            pending[rd] = (GROUPS[imm][0], WINDOW)
        elif rn in pending and up and imm % 4 == 0:
            g = pending.pop(rn)[0]
            calls.setdefault((g, imm), 0)
            calls[(g, imm)] += 1
    return calls


def mapped_calls(path):
    # group cases are at 4 spaces, function cases at 8 spaces
    mapped = set()
    group = None
    for line in open(path, encoding='latin-1'):
        m = re.match(r'^    case ([123]):', line)
        if m:
            group = int(m.group(1))
            continue
        m = re.match(r'^        case 0x([0-9A-Fa-f]+):', line)
        if m and group:
            mapped.add((group, int(m.group(1), 16)))
    return mapped


def names(path):
    table = {}
    for line in open(path, encoding='latin-1'):
        parts = line.split()
        if len(parts) >= 3 and parts[0] in TABLE_NAMES.values():
            g = [k for k, v in TABLE_NAMES.items() if v == parts[0]][0]
            table[(g, int(parts[1], 16))] = parts[2]
    return table


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    db = sys.argv[1]
    emulation = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'src', 'libpumpkin', 'emulation')
    armsyscall = os.path.join(emulation, 'armsyscall.c')
    systables = os.path.join(emulation, 'SysTables.txt')
    calls = {}
    for f in sorted(os.listdir(db)):
        if f.startswith('ARMC.'):
            for k, v in scan(open(os.path.join(db, f), 'rb').read()).items():
                calls[k] = calls.get(k, 0) + v
    mapped = mapped_calls(armsyscall)
    table = names(systables)
    group_name = {v[0]: v[1] for v in GROUPS.values()}
    missing = [k for k in sorted(calls) if k not in mapped]
    print('%d distinct calls, %d already handled, %d missing\n' % (len(calls), len(calls) - len(missing), len(missing)))
    for k in sorted(calls):
        print('%-7s %-4s 0x%03X %-36s x%d' % ('ok' if k in mapped else 'MISSING', group_name[k[0]], k[1], table.get(k, '?'), calls[k]))


main()
