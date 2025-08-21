#!/usr/bin/bash
set -euo pipefail

log() {
  echo "[amd-oc] $*" | systemd-cat -t amd-oc -p info || echo "[amd-oc] $*"
}

warn() {
  echo "[amd-oc][warn] $*" | systemd-cat -t amd-oc -p warning || echo "[amd-oc][warn] $*"
}

err() {
  echo "[amd-oc][error] $*" | systemd-cat -t amd-oc -p err || echo "[amd-oc][error] $*" >&2
}

# Desired settings for RX 7900 XTX
POWER_W=370
BOOST_MHZ=2550

find_amd_card() {
  local card
  for card in /sys/class/drm/card*[0-9]; do
    [ -d "$card" ] || continue
    if [ -f "$card/device/vendor" ] && grep -qi "0x1002" "$card/device/vendor"; then
      echo "$card"
      return 0
    fi
  done
  return 1
}

apply_power_limit() {
  local card_path="$1"
  local hwmon_root="$card_path/device/hwmon"
  if [ ! -d "$hwmon_root" ]; then
    warn "No hwmon directory for $(basename "$card_path")"
    return 0
  fi
  local hw
  for hw in "$hwmon_root"/hwmon*; do
    [ -d "$hw" ] || continue
    if [ -f "$hw/power1_cap" ]; then
      local desired=$(( POWER_W * 1000000 ))
      local maxcap
      maxcap=$(cat "$hw/power1_cap_max" 2>/dev/null || echo "$desired")
      if [ "$desired" -gt "$maxcap" ]; then
        warn "Requested power cap ${desired} > max ${maxcap}. Clamping to max."
        desired="$maxcap"
      fi
      echo "$desired" > "$hw/power1_cap" || warn "Failed to set power1_cap at $hw"
      log "Set power limit to $((desired/1000000)) W on $(basename "$card_path")"
      return 0
    fi
  done
  warn "No power1_cap found for $(basename "$card_path")"
}

apply_boost_clock() {
  local card_path="$1"
  local dev="$card_path/device"
  local pp="$dev/pp_od_clk_voltage"
  local perf="$dev/power_dpm_force_performance_level"

  if [ ! -w "$pp" ]; then
    warn "OD interface not available ($pp). Ensure amdgpu.ppfeaturemask enables OC."
    return 0
  fi

  # Switch to manual perf so OD writes are accepted
  if [ -w "$perf" ]; then
    echo manual > "$perf" 2>/dev/null || true
  fi

  # Try several known syntaxes across gens
  local ok=0
  if echo "s 2 ${BOOST_MHZ}" > "$pp" 2>/dev/null; then
    ok=1
  elif echo "sclk 2 ${BOOST_MHZ}" > "$pp" 2>/dev/null; then
    ok=1
  elif echo "od sclk 2 ${BOOST_MHZ}" > "$pp" 2>/dev/null; then
    ok=1
  fi

  if [ "$ok" -eq 1 ]; then
    # Commit the changes
    echo c > "$pp" 2>/dev/null || true
    log "Applied max boost clock ${BOOST_MHZ} MHz on $(basename "$card_path")"
  else
    warn "Failed to set boost clock using known syntaxes on $(basename "$card_path")"
  fi

  # Return to auto so regular power management works
  if [ -w "$perf" ]; then
    echo auto > "$perf" 2>/dev/null || true
  fi
}

main() {
  local card
  if ! card=$(find_amd_card); then
    err "No AMD GPU found. Exiting."
    exit 0
  fi

  log "Using $(basename "$card") for OC application"
  apply_power_limit "$card"
  apply_boost_clock "$card"
  log "Completed AMD OC application"
}

main "$@"
