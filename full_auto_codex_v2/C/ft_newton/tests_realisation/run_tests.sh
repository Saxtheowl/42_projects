#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

# Trajectoire de base
peak=$(./ft_newton | awk 'NR>1 { if ($3>m) m=$3 } END {print m}')
fail=0
if (( $(echo "$peak < 3.0" | bc -l) )); then
  echo "❌ peak height too low ($peak)"
  fail=$((fail+1))
else
  echo "✅ peak height $peak"
fi
# ensure at least one bounce (velocity y changes sign to positive after negative)
vy_signs=$(./ft_newton | awk 'NR>2 {print $6}' | awk 'BEGIN{s=0}{if($1>0) s=1}END{print s}')
if [ "$vy_signs" -eq 0 ]; then
  echo "❌ no bounce detected"
  fail=$((fail+1))
else
  echo "✅ bounce detected"
fi

# Collision sphère-sphère + export CSV/JSON
OUT_JSON=/tmp/ft_newton_final.json
OUT_CSV=/tmp/ft_newton_trace.csv
./ft_newton --speed 8 --angle 8 --sim 2 --csv "$OUT_CSV" --final-json "$OUT_JSON" >/dev/null
min_dist=$(python3 - <<'PY'
import json,math
data=json.load(open('/tmp/ft_newton_final.json'))
b0=data['bodies'][0]
b1=data['bodies'][1]
dx=b0['pos'][0]-b1['pos'][0]; dy=b0['pos'][1]-b1['pos'][1]; dz=b0['pos'][2]-b1['pos'][2]
dist=math.sqrt(dx*dx+dy*dy+dz*dz)
print(dist - (b0['radius']+b1['radius']))
PY
)
if (( $(echo "$min_dist < -0.01" | bc -l) )); then
  echo "❌ bodies overlapping ($min_dist)"
  fail=$((fail+1))
else
  echo "✅ bodies separated (penetration margin $min_dist)"
fi

if [ ! -s "$OUT_CSV" ]; then
  echo "❌ CSV export missing"
  fail=$((fail+1))
else
  echo "✅ CSV export present"
fi
if python3 - <<'PY'
import json
data=json.load(open('/tmp/ft_newton_final.json'))
# ensure json contains at least 2 bodies
assert len(data['bodies']) >= 2
PY
then
  :
else
  echo "❌ final JSON incomplete"
  fail=$((fail+1))
fi

# Trace export
TRACE_JSON=/tmp/ft_newton_trace_full.json
./ft_newton --speed 10 --angle 40 --dt 0.02 --sim 1.0 --trace-json "$TRACE_JSON" >/dev/null
if python3 - <<'PY'
import json,sys
data=json.load(open('/tmp/ft_newton_trace_full.json'))
frames=data.get("frames", [])
dt=data.get("dt")
if not frames or abs(dt-0.02) > 1e-6:
    sys.exit(1)
# y velocity should become negative then positive (bounce) across frames
vy=[f["bodies"][0]["vel"][1] for f in frames]
neg = any(v < 0 for v in vy)
pos_after = any(v > 0 for v in vy[int(len(vy)/2):])
sys.exit(0 if neg and pos_after else 1)
PY
then
  echo "✅ trace JSON export OK (frames recorded, bounce detected)"
else
  echo "❌ trace JSON export invalid"
  fail=$((fail+1))
fi

# Config file + friction effect
CFG=/tmp/ft_newton.cfg
cat > "$CFG" <<'EOF'
speed=6
angle=15
dt=0.01
sim_time=1.2
friction=0.7
EOF
last_vx=$(./ft_newton --config "$CFG" | tail -n 1 | awk '{print $5}')
first_vx=$(./ft_newton --config "$CFG" | head -n 2 | tail -n 1 | awk '{print $5}')
if (( $(echo "${last_vx#-} > ${first_vx#-}" | bc -l) )); then
  echo "❌ friction check failed (vx increased)"
  fail=$((fail+1))
else
  echo "✅ friction damped horizontal speed ($first_vx -> $last_vx)"
fi

# Drag check
drag_speed=$(./ft_newton --speed 10 --angle 20 --sim 0.8 --dt 0.01 | tail -n 1 | awk '{print $5}')
drag_speed_with=$(./ft_newton --speed 10 --angle 20 --sim 0.8 --dt 0.01 --drag 0.3 | tail -n 1 | awk '{print $5}')
if (( $(echo "${drag_speed_with#-} < ${drag_speed#-}" | bc -l) )); then
  echo "✅ drag reduces horizontal speed (${drag_speed} -> ${drag_speed_with})"
else
  echo "❌ drag did not reduce speed (${drag_speed} vs ${drag_speed_with})"
  fail=$((fail+1))
fi

# Stats export (energy decreases with drag)
STATS=/tmp/ft_newton_stats.json
./ft_newton --speed 10 --angle 20 --sim 0.5 --dt 0.01 --drag 0.3 --stats-json "$STATS" >/dev/null
if python3 - <<'PY'
import json,sys
data=json.load(open('/tmp/ft_newton_stats.json'))
init=data["total_energy_initial"]
final=data["total_energy_final"]
max_h=data["max_height"]
max_r=data["max_range"]
sim_t=data.get("simulated_time", 0)
steps=data.get("steps", 0)
sphere_col=data.get("sphere_collisions", 0)
fc_time=data.get("first_contact_time", -1)
fc_range=data.get("first_contact_range", -1)
wall_col=data.get("wall_contacts", 0)
sys.exit(0 if final < init and max_h > 0 and max_r > 0 and sim_t > 0 and steps > 0 and sphere_col >= 0 and wall_col >= 0 and fc_time >= 0 and fc_range >= 0 else 1)
PY
then
  echo "✅ stats JSON export OK (energy drop with drag, max_height tracked)"
else
  echo "❌ stats JSON export invalid"
  fail=$((fail+1))
fi
STATS_MD=/tmp/ft_newton_stats.md
./ft_newton --speed 10 --angle 20 --sim 0.5 --dt 0.01 --drag 0.3 --stats-md "$STATS_MD" >/dev/null
if [ -s "$STATS_MD" ]; then
  echo "✅ stats Markdown export OK"
else
  echo "❌ stats Markdown missing"
  fail=$((fail+1))
fi

# Energy CSV export
ENERGY=/tmp/ft_newton_energy.csv
./ft_newton --speed 10 --angle 30 --sim 0.6 --dt 0.01 --energy-csv "$ENERGY" >/dev/null
if [ -s "$ENERGY" ] && python3 - <<'PY'
import csv,sys
rows=list(csv.DictReader(open('/tmp/ft_newton_energy.csv')))
sys.exit(0 if len(rows)>10 and float(rows[0]['energy'])>0 else 1)
PY
then
  echo "✅ energy CSV export OK"
else
  echo "❌ energy CSV export invalid"
  fail=$((fail+1))
fi

# Collision stats
COL_STATS=/tmp/ft_newton_col.json
./ft_newton --speed 8 --angle 8 --sim 2 --dt 0.02 --stats-json "$COL_STATS" >/dev/null
if python3 - <<'PY'
import json,sys
d=json.load(open('/tmp/ft_newton_col.json'))
sys.exit(0 if d.get("sphere_collisions",0) > 0 else 1)
PY
then
  echo "✅ sphere collision stats recorded"
else
  echo "❌ sphere collision stats missing"
  fail=$((fail+1))
fi

# Wind influence
WIND_SCENE=/tmp/ft_newton_wind.scene
cat > "$WIND_SCENE" <<'EOF'
gravity=0,-9.81,0
ground_friction=0.0
drag=0.0
body=1.0,0.5,0.5,0,1,0,0,0,0
EOF
WIND_JSON=/tmp/ft_newton_wind.json
WIND_JSON2=/tmp/ft_newton_wind2.json
./ft_newton --scene "$WIND_SCENE" --wind 2,0,0 --dt 0.01 --sim 0.8 --final-json "$WIND_JSON" >/dev/null
./ft_newton --scene "$WIND_SCENE" --wind 0,0,0 --dt 0.01 --sim 0.8 --final-json "$WIND_JSON2" >/dev/null
if python3 - <<'PY'
import json,sys
a=json.load(open('/tmp/ft_newton_wind.json'))['bodies'][0]['vel'][0]
b=json.load(open('/tmp/ft_newton_wind2.json'))['bodies'][0]['vel'][0]
sys.exit(0 if a > b else 1)
PY
then
  echo "✅ wind increases horizontal speed"
else
  echo "❌ wind influence not detected"
  fail=$((fail+1))
fi

# Target count/spacing
TARGET_JSON=/tmp/ft_newton_targets.json
./ft_newton --speed 8 --angle 10 --targets 4 --target-spacing 1.5 --sim 0.5 --dt 0.02 --final-json "$TARGET_JSON" >/dev/null
if python3 - <<'PY'
import json,sys
data=json.load(open('/tmp/ft_newton_targets.json'))
if len(data['bodies']) != 5:
    sys.exit(1)
xs=[b['pos'][0] for b in data['bodies'][1:]]
sys.exit(0 if abs(xs[-1] - 5.0 - 3*1.5) < 1e-6 else 1)
PY
then
  echo "✅ target count/spacing applied"
else
  echo "❌ target count/spacing failed"
  fail=$((fail+1))
fi

# Random targets deterministic with seed
RAND1=/tmp/ft_newton_rand1.json
RAND2=/tmp/ft_newton_rand2.json
./ft_newton --speed 8 --angle 10 --random-targets 3 --seed 42 --sim 0.5 --dt 0.02 --final-json "$RAND1" >/dev/null
./ft_newton --speed 8 --angle 10 --random-targets 3 --seed 42 --sim 0.5 --dt 0.02 --final-json "$RAND2" >/dev/null
if python3 - <<'PY'
import json,sys
def extract(path):
    data=json.load(open(path))
    return [(b['pos'][0], b['pos'][1]) for b in data['bodies'][1:]]
a=extract('/tmp/ft_newton_rand1.json')
b=extract('/tmp/ft_newton_rand2.json')
sys.exit(0 if a==b else 1)
PY
then
  echo "✅ random targets deterministic with seed"
else
  echo "❌ random targets not deterministic"
  fail=$((fail+1))
fi

# Bounds keep projectile inside X
BOUNDS_JSON=/tmp/ft_newton_bounds.json
./ft_newton --speed 15 --angle 0 --bounds 3 --sim 1.0 --dt 0.01 --final-json "$BOUNDS_JSON" >/dev/null
if python3 - <<'PY'
import json,sys
b=json.load(open('/tmp/ft_newton_bounds.json'))['bodies'][0]
sys.exit(0 if abs(b['pos'][0]) <= 3.1 else 1)
PY
then
  echo "✅ bounds limit applied"
else
  echo "❌ bounds not enforced"
  fail=$((fail+1))
fi

# Auto-stop should reduce steps for a resting body
# Auto-stop should reduce steps for a resting body (custom scene)
AUTO_SCENE=/tmp/ft_newton_auto.scene
cat > "$AUTO_SCENE" <<'EOF'
gravity=0,0,0
ground_friction=0.0
drag=0.0
body=1.0,0.5,0.2,0,0.5,0,0,0,0
EOF
AUTO_STATS=/tmp/ft_newton_auto.json
./ft_newton --scene "$AUTO_SCENE" --sim 2 --dt 0.01 --auto-stop --stats-json "$AUTO_STATS" >/dev/null
if python3 - <<'PY'
import json,sys,math
d=json.load(open('/tmp/ft_newton_auto.json'))
steps=d["steps"]
sim_t=d["simulated_time"]
sys.exit(0 if steps < 10 and sim_t < 0.1 else 1)
PY
then
  echo "✅ auto-stop stops early on resting scene"
else
  echo "❌ auto-stop did not stop early"
  fail=$((fail+1))
fi

# Scene loader + collision importée
SCENE=/tmp/ft_newton.scene
cat > "$SCENE" <<'EOF'
gravity=0,0,0
ground_friction=0.0
body=1.0,0.5,1.0,0,1,0,2,0,0
body=1.0,0.5,1.0,2,1,0,0,0,0
EOF
SCENE_JSON=/tmp/ft_newton_scene.json
if ./ft_newton --scene "$SCENE" --dt 0.01 --sim 1.2 --final-json "$SCENE_JSON" >/dev/null; then
  if python3 - <<'PY'
import json,math,sys
data=json.load(open('/tmp/ft_newton_scene.json'))
b0,b1=data['bodies'][0],data['bodies'][1]
v0,v1=b0['vel'][0],b1['vel'][0]
sys.exit(0 if v1 > 1.2 and v0 < 1.0 and v1 > v0 else 1)
PY
  then
    echo "✅ scene loader elastic swap OK (v1 dominant après collision)"
  else
    echo "❌ scene loader: unexpected velocities (v0/v1)"
    fail=$((fail+1))
  fi
else
  echo "❌ scene loader execution failed"
  fail=$((fail+1))
fi

if [ "$fail" -eq 0 ]; then
  echo "All tests passed."
else
  echo "$fail test(s) failed."
  exit 1
fi
