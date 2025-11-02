#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AAB_PATH="${PROJECT_ROOT}/build/ft_hangouts-debug.apk"

if [ ! -f "${AAB_PATH}" ]; then
	printf 'APK not found at %s – build first via Android Studio (./gradlew assembleDebug)\n' "${AAB_PATH}" >&2
	exit 1
fi

EMULATOR_NAME="ft_hangouts_demo"

printf 'Launching emulator %s...\n' "${EMULATOR_NAME}"
emulator -avd "${EMULATOR_NAME}" -netdelay none -netspeed full &
EMULATOR_PID=$!

sleep 10
adb wait-for-device

printf 'Installing APK...\n'
adb install -r "${AAB_PATH}"

printf 'Launching app...\n'
adb shell monkey -p com.ft.hangouts 1

wait ${EMULATOR_PID}
