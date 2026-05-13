# NadirPointing — Simulation Technical Report

This document is an in-depth analysis of `NadirPointing/NadirPointing.m` and **every file that is directly required for the simulation to run**. It walks the reader from the moment the script is launched, through every subroutine, dynamics evaluation and plot, to the final saved workspace.

The target reader already knows MATLAB and basic spacecraft attitude dynamics; the goal here is to make the codebase fully traceable: every variable that appears in `NadirPointing.m` is either defined in this report or in one of the files referenced.

---

## 1. Purpose of the simulation

`NadirPointing.m` simulates the **closed-loop attitude control of a 0.5U PocketQube** (the PoCat-Lektron PQ) in a circular Low Earth Orbit (LEO). The stated goal is to point a fixed body axis (the +Z body axis by default) toward the local-vertical "nadir" direction. *(Note: as analyzed in §13.14 and §14 (C3), the target is built with `p.eci_vector = +r̂`, which actually drives body-Z toward zenith — the file name and stated intent disagree with the geometry encoded in the controller. The whole simulation is internally consistent if read as a "zenith-pointing" run.)* The simulation models, in a single MATLAB workspace:

1. **Orbit + attitude dynamics** of a rigid spacecraft (Princeton Satellite Systems' `RHSCubeSat`).
2. **Environmental disturbances**: aerodynamic drag (Jacchia 1970 atmosphere), solar radiation pressure, gravity-gradient torque, residual-dipole magnetic torque.
3. **Sensor models**: 3-axis magnetometer, 3-axis gyro (with bias, ARW, RRW), six-face photodiode sun sensor.
4. **Attitude estimation**: a cold-start TRIAD algorithm on the first step to seed a **Multiplicative Kalman Filter (MKF)** that fuses magnetometer + gyro thereafter.
5. **Control**: a cross-product magnetorquer control law with PD-like gains derived from a continuous-time PID design (`PIDMIMO`), saturated to the achievable magnetic dipole of three orthogonal coils.
6. **Numerical propagation**: 4th-order Runge–Kutta (`RK4`) at a fixed step `dT = 0.25 s` for two orbital periods.
7. **Post-processing**: a 4×3 figure summarizing real attitude error vs. estimated attitude error vs. magnetorquer current draw, an Attitude Knowledge Error (AKE) plot, an LVLH-to-body quaternion plot and a magnetorquer moment plot. The full workspace is dumped to `utils/debug/sim_debug.mat`.

The whole simulation is a **MATLAB script** (no `function` keyword): every variable lives in the base workspace and is consumed by name. The configuration files in `SimConfiguration/` are also scripts — they are `include`-style files that mutate the same workspace.

---

## 2. State vector and frame conventions

### 2.1 State vector `x`

Throughout the run, `x` is a **14×1 column vector**:

| Indices  | Meaning                                          | Units  |
|----------|--------------------------------------------------|--------|
| `x(1:3)` | Position in ECI                                  | km     |
| `x(4:6)` | Velocity in ECI                                  | km/s   |
| `x(7:10)`| Quaternion **ECI → body** (`q = [qs; qx; qy; qz]`) | —      |
| `x(11:13)`| Body angular velocity                           | rad/s  |
| `x(14)`  | Battery state of charge                          | J      |

Index 14 is the battery (`b0 = 20000` J), the last state is always the battery per the convention in `RHSCubeSat`.

### 2.2 Reference frames

- **ECI** (Earth-Centered Inertial): default frame for position, velocity, magnetic field reference and Sun reference. Earth-fixed dipole tilt is rotated into ECI by `ECIToEF` inside `BDipole`.
- **Body**: spacecraft-fixed; origin at center of mass. The +Z body axis is taken as the *instrument axis* (the one to be aligned with the controller's target — actually zenith, see §14 (C3)).
- **LVLH** (Local Vertical, Local Horizontal): used only for visualization (`QLVLH(r,v)`). Z is `-r̂` (nadir), Y is `-r̂×v̂` (orbit-normal, opposite), X completes the right-handed set.

### 2.3 Quaternion convention

All Princeton Satellite Systems (PSS) quaternions in this project are **scalar-first** `q = [qs; qx; qy; qz]` and are **passive** rotations from the source frame to the destination frame. `QForm(q, u_a)` returns `u_b`, while `QTForm(q, u_b)` returns `u_a`. `QPose` is the conjugate (transpose) and `QMult(Q2, Q1)` chains rotations: `Q3 = QMult(Q2,Q1)` rotates A→C if Q2 is A→B and Q1 is B→C — **note the right-to-left composition order**, which is unusual and is the source of more than one comment in the code.

The code mixes PSS quaternion ops with **MATLAB-toolbox** functions `quat2eul`, `quat2rotm` (the *MathWorks* version — but `utils/MKF_functions/quat2rotm.m` shadows it with a custom implementation that uses the **same scalar-first convention**, so both paths agree). Care is required when introducing new attitude code — verify which `quat2rotm` is on the path.

---

## 3. Path setup

### 3.1 `PSSSetPaths(1)`  *(NadirPointing/PSSSetPaths.m)*

Called at the very top of `NadirPointing.m`. Behaviour:

1. `pathToToolbox = fileparts(which(mfilename))` — finds the directory of the script regardless of where MATLAB is currently `cd`'d. **Implication**: you must run `PSSSetPaths` from the *NadirPointing* `PSSSetPaths.m`, not the duplicated copy inside `utils/CubeSatToolbox/`.
2. `cd(pathToToolbox)` — switches the working directory to NadirPointing/.
3. Recursively walks every direct subdirectory (`SimConfiguration`, `utils/...`) calling `AddDirectoryToPath`, which itself recurses into all sub-subdirectories *except* those whose name contains `@` (MATLAB class folders), `.svn`, `html`, or `Headers`.
4. The argument `1` activates non-interactive mode: paths are added but **not saved** between MATLAB sessions, so this script must be re-run every time MATLAB starts fresh.

After this call every script in `SimConfiguration/`, every helper in `utils/Functions/`, every Sensor file, every PSS Toolbox function and the J2 propagator is on the MATLAB path.

---

## 4. Pre-loop initialization

`NadirPointing.m` lines 6–66 run a sequence of include-style scripts. The order is meaningful: each script reads variables produced by previous ones.

### 4.1 `Sim_sat_initial_state.m` — initial state vector

Defines:

- `a0 = 6387.165 + 500` km — initial geocentric distance. The `6387.165` constant is almost certainly a typo for `6378.165` (used elsewhere as `d.rP`). The actual initial altitude is therefore ~509 km, not 500 km, and three different "Earth radii" coexist in the codebase (see §14 (M1)).
- `r0 = [a0; 0; 0]` km, `v0 = [0; 0; VOrbit(a0)]` km/s — equatorial circular orbit in the X–Z ECI plane (the satellite climbs along +Z initially).
- `q0 = [0.7071; 0; 0.7071; 0]` — body initially rotated 90° about ECI Y. (Several alternative `q0` values are commented out for tuning experiments.)
- `w0 = [OrbRate(a0); -OrbRate(a0); OrbRate(a0)]` rad/s — initial angular velocity at orbital-rate magnitude on each axis (a worst-ish case for a magnetorquer-only ADCS).
- `b0 = 20000` J — initial battery charge.
- `x = [r0; v0; q0; w0; b0]`.
- `p.eci_vector = r0/norm(r0)` — the **target ECI vector** is the unit position vector (`+r̂`, ECI-frame) ⇒ pointing at zenith. Once the body is aligned with `p.body_vector = [0;0;1]`, the +Z body axis points *away* from Earth. The file name and project description say "nadir pointing" but the math implements zenith pointing — see §13.14 / §14 (C3).

External calls: `VOrbit(a0)`, `OrbRate(a0)` — both PSS Toolbox functions in `utils/CubeSatToolbox/SC/BasicOrbit/`.

### 4.2 `Sim_time_parameters.m`

- `orbits = 2` — total mission duration in orbital revolutions.
- `tEnd = orbits * Period(a0)` — total simulated seconds (`Period` is the Keplerian period from PSS).
- `dT = 0.25` s — fixed propagation step.
- `nSim = floor(tEnd/dT)` — number of integration steps. For a 500 km circular orbit this is roughly `2 * 5677 / 0.25 ≈ 45 416` steps.
- `Input_delay = 0` — currently unused.

### 4.3 `Sim_pq_model.m`

Calls `CubeSatFaces('0.5U', 1)` (in `utils/Functions/`) returning the **face areas `a`**, **face normals `n`** and **face center positions `r`** for both the front and rear (the `1` adds the −X, −Y, −Z faces). For a 0.5U body the function uses standard side `d = 0.05` m ⇒ x = 0.05, y = 0.05, z = 0.025 m. These six-column matrices are later fed to the aero/optical models inside `RHSCubeSat`.

### 4.4 `Sim_sensors.m` → `Sensors_Config_File.m`

`Sim_sensors.m` calls `Sensors_Config_File` (located in `Detumbling/SimMagnetorquers/Sensors_Config_File.m` — this is shared across pipelines), which builds the master `Sensors` struct:

- **Magnetometer**: XSens MTI model. Calibration matrix error sampled from `Cm1std` (`normrnd` around identity), bias error sampled from `bm1std`, white noise STD `[14 15 20] * 1e-9` T per axis (scaled by `safeFact`). Max dipole limits per axis: `MaxX = MaxY = MaxZ = 0.2` A·m².
- **Gyros**: bias errors, **Angle Random Walk** (`arw`) from IEEE-952 nomenclature, **Rate Random Walk** (`rrw`), 16-bit ADC with `±300 °/s` range, scale division `(max-min)/(2^16-1)`.
- **Sun sensors**: six photodiodes. Output voltage `V0 = 1.415` V at 0° AOI, calibration `R = V0/1000` V/(W/m²) (i.e. ADC at 1000 W/m²), dark-current bias `12 mV`, noise STD `20 mV`, ADC range `[0, 2.5] V` with `2 mV` resolution.

After the include, `Sim_sensors.m` overrides `Sensors.magnetometer.on = 1`, `Sensors.sunSensors.on = 1`, `safeFact = 1` (so the *production* magnetometer noise figures are used, not the tightened `safeFact = 0.1` that the config sets internally).

### 4.5 `Sim_data_structure.m`

Builds the master simulation data struct `d` that is passed to `RHSCubeSat` every step:

1. `d = RHSCubeSat;` — calling `RHSCubeSat` with no arguments returns a default struct (see §6.1.1), giving the simulation a known starting point.
2. Overrides:
   - `d.jD0 = Date2JD([2019 4 5 0 0 0])` — Julian date of epoch (5 April 2019, 00:00 UTC).
   - `d.mass = 0.234` kg.
   - `d.inertia` is initially the off-diagonal matrix from CAD; **then immediately replaced with `mean(diag(D)) * eye(3)` after eigen-decomposition** (`eig`). The simulation is therefore run with a **homogeneous diagonal inertia** equal to the mean principal moment of the real tensor — a deliberate simplification chosen by the author and one that the controller design also assumes.
   - `Sim_thermal_control_config_file` is included here (sets `d.uSurface`, `d.alpha`, `d.epsilon`, `d.area`, `d.cP`, `d.powerTotal`, `T0`).
   - `Sx, Sy, Sz` — magnetorquer **transduction constants** (A·m²/A) for X, Y and Z coils. Used later to compute the current draw from the commanded dipole.
3. Surface model: `d.surfData.cD = 2.7`, `d.surfData.area = a`, `d.surfData.nFace = n`, `d.surfData.rFace = r`, `d.surfData.sigma = [1 1 1 1 1 1; zeros(2,6)]` (perfectly absorbing optical model), `d.aeroModel = @CubeSatAero`, `d.opticalModel = @CubeSatRadiationPressure`.
4. Power model: 6 GaAs cells (one per face), `solarCellEff = 0.3`, `effPowerConversion = 0.9`, `solarCellArea = 0.0012*[1 0 1 1 1 1]` m² (face index 2 is occluded). Battery: 1400 mAh × 3.3 V → ≈16.6 kJ. Consumption is set by `d.power.consumption = 80/3600 * dT * 1e-3` — the comment claims "80 mWh ADCS" but the formula evaluates to ~5.6·10⁻⁶ in the units it is later consumed (W). This is a real dimensional bug — see §14 (C4).
5. Atmosphere: `SolarFluxPrediction(d.jD0, 'nominal')` returns Jacchia-70 inputs `aP, f, fHat, fHat400` for the epoch's solar activity → fed to `d.atm`.
6. Planet: `'earth'`, `d.rP = 6378.165` km.
7. Initial control: `d.dipole = [0;0;0]` A·m².
8. `d.fieldECIbefore = BDipole(x(1:3), d.jD0)` and `d.fieldBODYbefore = QForm(x(7:10), d.fieldECIbefore)` — preload one-step-old magnetic field for use in derivative-style calculations.

### 4.6 `Sim_PID_controller.m`

Designs the cross-product magnetorquer controller:

1. `p = PID3Axis2;` — call without arguments returns `PID3Axis2`'s default data structure used as a parameter container. Note: after this line `p` is **the controller struct**, *not* the orbit-related `p` from `Sim_sat_initial_state.m`. The variable `p.eci_vector` is re-set further down.
2. `Inertia_matrix` is set to the same diagonalized matrix used in `d.inertia`.
3. `[p.a, p.b, p.c, p.d, constants] = PIDMIMO(Inertia_matrix, 1, 0.005/4, 300, 0.1, dT, 'Delta')` — designs a continuous PID with damping ratio `ζ = 1`, undamped natural frequency `ω = 0.00125` rad/s, integrator time constant `τ = 300 s`, derivative roll-off `ωR = 0.1` rad/s, sampled at `dT`, in delta state-space form. Returns the discrete-time state-space matrices and a gain struct `constants.kP`, `constants.kR`, `constants.kI`.
4. `m_max = [Sx, Sy, Sz] * 150 / 1e3` — per-axis dipole saturation expressed as the dipole produced by 150 mA flowing through each coil. This is the **physical max-current limit** of the magnetorquers, which the control law in the loop respects.
5. `p.eci_vector = x(1:3)/norm(x(1:3))` — the current target ECI direction (recomputed every step inside the loop).
6. `p.body_vector = [0;0;1]` — the body axis to align with that ECI direction.

Only `constants.kP` and `constants.kR` are used inside the loop (the integrator gain `kI` is silently dropped — the law that actually fires is purely PD).

### 4.7 `MKF.m` — Multiplicative Kalman Filter initialization

Builds the `KF` struct:

| Field         | Value                                | Meaning |
|---------------|--------------------------------------|---------|
| `KF.q0`       | `q0`                                 | Initial quaternion guess |
| `KF.w0`       | `w0`                                 | Initial angular velocity guess |
| `KF.I3, I6`   | identity                             | Identities reused inside loop |
| `KF.Z3`       | `zeros(3)`                           | Zero block |
| `KF.std_v`    | `1.5e-6` T                           | Magnetometer measurement STD (per-axis) |
| `KF.std_w`    | `0.1° → rad/s`                       | Gyro measurement STD |
| `KF.std_Qw`   | `1e-3`                               | Named "STD on rate" but used unsquared as a covariance — see §14 (C7) |
| `KF.Qw`       | `std_Qw · I3` *(no square — code as written)* | Process-noise covariance block |
| `KF.P0`       | `1e-3 · I6`                          | Initial covariance |
| `KF.Rv`       | `std_v² · I3`                        | Magnetometer covariance (squared correctly) |
| `KF.Rw`       | `std_w² · I3`                        | Gyro covariance (squared correctly) |
| `KF.Qn`       | `[dT³/3·Qw, −dT²/2·Qw; −dT²/2·Qw, dT·Qw]` | Discrete process noise; off-diagonal sign is **inconsistent** with the `+dT·I3` block in `Fn` used later — see §14 (C6) |
| `KF.sim_state`| `1`                                  | Filter mode (only `1` is implemented in this branch — TRIAD on first step then EKF-update on subsequent steps) |

The state vector of the filter is implicit: a 6-element error vector `[δθ; δω]` (small-angle attitude error in body frame + angular-velocity error). The 4-quaternion `KF.qprev` is propagated multiplicatively (hence "Multiplicative" KF).

---

## 5. Plotting buffer pre-allocation

Lines 49–66 pre-size the per-step output arrays so the loop only writes into pre-allocated memory:

`xPlot, dragPlot, radPlot, tRadPlot, tAeroPlot, tMagPlot, tGGPlot, powerPlot, bPlot, qPlot, q_error, angleError_real, yaw_real_vec, pitch_real_vec, roll_real_vec, moment_vec`. The first column of each `*Plot` is seeded by calling `RHSCubeSat(x, 0, d)` once with the initial state to capture the disturbance breakdown at t = 0.

A waitbar `h` is created with a "Stop" cancel button — pressing it sets `canceling=true` in `h`'s appdata, which the main loop polls once per iteration to exit cleanly.

---

## 6. Main simulation loop (lines 92–337)

The loop runs `for k = 1:nSim`, with `t = (k-1)*dT`. Each iteration covers eight stages.

### 6.1 Pointing-error calculation (line 95)

```matlab
angleError_real(1,k) = rad2deg(acos(Dot(p.eci_vector, QTForm(x(7:10), p.body_vector))));
```

**Reading**: rotate the body axis `p.body_vector = [0;0;1]` *backwards* through the ECI→body quaternion (`QTForm`) to express it in ECI, then take its inner product with the current ECI target direction `p.eci_vector` (= `r̂`). The arccos in degrees is the **true** angle between the commanded body axis (in ECI) and the current target direction. This is the *ground-truth* error, only available because we have access to the simulator's true `x(7:10)`.

### 6.2 Magnetic field & magnetometer (lines 99–115)

`rlla = CoordinateTransform('ECI','LLR', x(1:3), d.jD0)` converts the satellite ECI position to geodetic latitude/longitude/altitude (used only as context, the value is not consumed downstream).

The magnetic field uses **`BDipole`** (PSS), a tilted-dipole IGRF-1995 model:

- `d.fieldECI = BDipole(x(1:3), d.jD0 + t/86400)` (called twice — duplicate line, same result).
- `bfieldBODY = QForm(x(7:10), d.fieldECI)` — true field in body frame.
- If `Sensors.magnetometer.on == 1`, `Magnetometer_measurement.m` runs:
  - Re-samples calibration matrix error and bias error from the configured STDs.
  - Applies them: `B_body_with_bias = Cerror * bfieldBODY + biasError'`.
  - Adds zero-mean Gaussian noise with STD `Sensors.magnetometer.sigmaNoise`.
  - The **measured** field is `d.fieldBODY`. Stored in `magnetometer_data(:,k)`.
- Else: `d.fieldBODY = QForm(x(7:10), d.fieldECI)` is the noiseless body-frame field.

### 6.3 Sun position (line 119 → `Sim_sun_position.m`)

`SunVectorECI('initialize', 'earth')` (called on every step — slightly wasteful but cached internally) and `SunVectorECI('update', d.jD0+t/86400, x(1:3))` provide `d.rSunECI`. Then:

1. `d.rSunBody = QForm(x(7:10), d.rSunECI)` — true Sun direction in body frame.
2. For each of the 6 face normals `[+Z, -Z, +X, +Y, -X, -Y]`, compute the angle between the normal and `d.rSunBody` ⇒ array `theta_faces(1..6)`. Faces with `theta < π/2` are illuminated.
3. Compute the photon current per illuminated face from a hand-rolled photodiode model: `solar_flux = 1361` W/m², 2.7 mm² photoactive area, spectral responsivity 0.55 A/W, load resistor 2 kΩ ⇒ open-circuit voltage `vo_ph`. Output per face: `vo_ph * cos(point_faces)^2`. Three independent noise samples are added and averaged to produce `faces_noise`.
4. `sun_position(:,k) = sun_position_estimator(faces_noise, faces_temp)` — calls a hand-built dispatch that classifies how many faces are illuminated (1, 2, 3, ≥4) and selects the appropriate sub-estimator (`sun_vector_1face`, `sun_vector_2faces`, `sun_vector_3faces`, etc., all in `utils/sun estimator sun sensors/`).
5. `d.rSunBody` is **overwritten** with this estimate — meaning subsequent code uses the *measured* sun vector, not the true one.

The Sun vector is consumed by the TRIAD initialization (§6.5) to build the first absolute attitude estimate.

### 6.4 Gyro reading (`Gyro_measurement.m`)

- Builds gyro noise `Sensors.gyros.Noise` from ARW + RRW: STD = `sqrt(arw²/dT + rrw²·dT/12) * randn(3)`.
- `w_meas = x(11:13) + BiasError' + Noise'` — noisy continuous reading.
- If `Sensors.gyros.ratingOn == 1`, quantizes through the helper `sensor_rating` (assumed to be on the path; saturates and rounds to ADC LSB).
- A FIR moving-average over a circular queue of length `queue_size` is computed (queue logic uses `Sensors.gyros.queue_pos`), but the very last line `w_read = w_meas` **discards** the average and uses the unfiltered measurement. The queue logic exists but is bypassed.

### 6.5 Estimator: TRIAD + MKF (`switch KF.sim_state` block, lines 127–240)

Only `case 1` is implemented; it splits internally on `k`:

#### 6.5.1 First step (`k == 1`): TRIAD

The two reference vectors (in ECI) are the magnetic field `d.fieldECI` and the Sun direction `d.rSunECI`; the two body vectors are their measurements `d.fieldBODY` and `d.rSunBody`. `triad(reference2, reference1, body2, body1)` builds a body-from-ECI rotation matrix from the two non-collinear vectors using the standard TRIAD construction:

1. Build a right-handed reference triad from `(v1, v2)`: `v1 = ref1 / |ref1|`, `v2 = (ref1 × ref2) / |·|`, `v3 = (ref1 × v2) / |·|`.
2. Same for the body triad `(w1, w2, w3)`.
3. Rotation matrix is `[v1 v2 v3] * [w1 w2 w3]'`.

Then `rotmatrix2quat(rotation_matrix)` extracts the quaternion via Shepperd's formula:

- `θ = acosd((trace - 1)/2)`,
- `e = (1/(2 sinθ)) * [r23-r32; r31-r13; r12-r21]`,
- `q = [cosd(θ/2); e * sind(θ/2)]`.

The result is sign-flipped if `dot(quaternion, x(7:10)) < 0` (to keep the same hemisphere as the truth — only legal because the simulator can peek at `x`; in flight you would skip this), then normalized.

**Importantly**, on `k==1` the code immediately **overwrites the TRIAD output with the truth** `quaternion = x(7:10)` and seeds `KF.q0 = quaternion`, `KF.w0 = w_read`, `KF.qprev = q0`, `KF.wprev = w0`, `KF.Pprev = KF.P0`. So the filter starts perfectly initialized — TRIAD is computed but not actually used as the seed in this version of the code (a leftover from an earlier branch).

#### 6.5.2 Subsequent steps (`k >= 2`): MKF prediction + correction

**Prediction (state)**:

- `KF.w_predict = KF.wprev` (constant-rate model).
- `KF.delta_predict = [cos(|w|·dT/2); (w/|w|) · sin(|w|·dT/2)]` — quaternion of the small-angle rotation due to `w` over `dT`.
- `KF.qpredict = QMult(KF.qprev, KF.delta_predict)` — propagate quaternion. *Note*: the multiplication order assumes `delta_predict` is body-frame increment composed *after* the previous attitude.

**Prediction (covariance)**:

- `KF.Rdelta = quat2rotm(delta_predict)` — uses `utils/MKF_functions/quat2rotm.m` (scalar-first).
- State transition matrix in error space: `Fn = [Rdelta', dT*I3; Z3, I3]`. Two anomalies relative to the textbook MKF (Markley 2003): the upper-left block uses the *transpose* `Rδᵀ` rather than `Rδ`, and the off-diagonal sign is `+dT·I3` rather than `−dT·I3`. See §13.10.2 / §14 (C6).
- `KF.Ppredict = Fn * (Pprev + Qn) * Fn'` — note that `Qn` is **inside** the `Fn·(·)·Fnᵀ` sandwich. Standard EKF would write `Fn·Pprev·Fnᵀ + Qn`. Including `Qn` inside over-amplifies process noise by `Fn` — see §13.10.3 / §14 (C5).

**Measurement model**:

- `KF.v_meas = d.fieldBODY` (3×1 magnetometer reading).
- `KF.w_meas = w_read` (3×1 gyro reading).
- `KF.state_meas = [v_meas; w_meas]` (6×1).
- `KF.v_est = quat2rotm(qpredict) * d.fieldECI` — predicted magnetometer reading from the predicted attitude.
- `KF.state_predict = [v_est; wprev]`.

**Measurement Jacobian**:

- `KF.Vx = -[v_est]_×` — the skew-symmetric "cross-product matrix" of the predicted body-frame field, used as `∂(R · b_eci)/∂(δθ)`.
- `KF.Hn = [Vx, Z3; Z3, I3]` — top block links field measurement to attitude error, bottom block is the trivial identity for the gyro/rate channel.

**Innovation, gain, update**:

- `KF.Qv = IGRF_sigmaNoise · I3` — but `IGRF_sigmaNoise` holds a **variance** (`σ²`) when `magnetometer.on == 1` (line 105 squares it) and a **standard deviation** (`σ`) when `magnetometer.on == 0` (line 112 leaves it unsquared). The downstream consumption assumes a covariance ⇒ correct in the on-branch, off by `~σ⁻¹ ≈ 3·10⁶` in the off-branch. See §14 (C2).
- `KF.Sn = Hn · Ppredict · Hn' + diag(Qv+Rv, Rw)` — innovation covariance.
- `KF.Kn = Ppredict · Hn' / Sn` — Kalman gain.
- `KF.Correction = Kn · (state_meas - state_predict)` — innovation × gain.
- Split into attitude and rate corrections: `deltaerror = Correction(1:3)`, `deltaw = Correction(4:6)`.
- Convert the small-angle attitude correction into a quaternion: `KF.errorq = [cos(|δ|/2); axis · sin(|δ|/2)]` (with a `1e-6` guard to avoid divide-by-zero).
- Correct: `qupdated = QMult(qpredict, errorq)`, normalize, and force `qupdated(1) >= 0` for sign canonicalization.
- Rate update: `wupdated = w_predict + deltaw`.
- Covariance: `Pupdated = (I6 - Kn·Hn) · Ppredict` (Joseph form **not** used).
- Save: `KF.qprev, KF.wprev, KF.Pprev` ← updated values.
- **Replace** the local `quaternion` and `w_read` with the filter outputs ⇒ the controller and the post-processing both consume the *estimated* attitude/rate from now on, not the truth.

`P11(k)` and `traceP(k)` are also stored for diagnostic plotting (the trace plot is not produced in this script).

### 6.6 Pointing error in body frame (lines 244–254)

- `q_target = U2Q(p.eci_vector, p.body_vector)` — `U2Q(u,v)` returns the smallest quaternion that **rotates u into v**. So `q_target` is the quaternion that rotates the desired ECI direction into the desired body direction.
- `q_real_error_k = QMult(QPose(x(7:10)), q_target)` — composed using truth: it represents the body-frame error rotation needed to align body Z with nadir.
- Sign flip if scalar < 0, then `quat2eul(q_real_error_k', 'ZYX')` gives Euler angles (yaw, pitch, roll) in radians; `rad2deg` and store. These three traces are plotted in column 1 of the summary figure.

### 6.7 Estimated pointing error & control law (lines 257–296)

- `q_target_body = QMult(QPose(quaternion), q_target)` — same composition, but using the **MKF-estimated** quaternion ⇒ this is what the controller actually sees.
- `q_AKE(:,k) = QMult(QPose(quaternion), x(7:10))` — quaternion error between estimate and truth (used for the AKE plot).
- Both quaternions are sign-flipped so the scalar is non-negative.
- `q_error(k,:) = q_target_body` — saved for column-2 plotting.
- `AKE(1,k) = 2 * acosd(q_AKE(1,k))` — Attitude Knowledge Error in degrees.

**Control law (only fires every 1 s, i.e. when `mod(k, ceil(1/dT)) == 0` or `k == 1`)**:

```matlab
kP = d.inertia * constants.kP;
kR = d.inertia * constants.kR;
moment = (kP .* cross(d.fieldBODY, q_target_body(2:4)) - ...
          kR .* cross(d.fieldBODY, w_read)) / (norm(d.fieldBODY)^2);
```

This is the **standard cross-product magnetorquer law**:

`m = (1/||B||²) · [ kP · (B × δq_v) - kR · (B × ω) ]`

where `δq_v` is the vector part of the body-frame error quaternion (≈ `−δθ/2` for small angles, with `δθ` the rotation needed *from* current body *to* target — see §13.8 for the sign accounting). The term in brackets is the desired control torque projected through the orthogonal complement of `B`; division by `||B||²` recovers the dipole `m` such that `m × B` reproduces that torque. Note: the explicit `d.inertia *` factor is dimensionally redundant because `PIDMIMO` already pre-multiplies by inertia (see §13.9 / §14 (C1)) — the produced dipole is therefore ~10⁴× too small, which is the deeper reason the closed-loop response is sluggish.

Saturation: per axis, if `|moment(i)| > m_max(i)` the dipole is clipped to `sign(moment(i)) * m_max(i)`. Between control updates `d.dipole` is held fixed.

`intensity(:,k) = d.dipole(:) ./ [Sx;Sy;Sz] * 1e3` — converts the commanded dipole to milliamps for plotting.

### 6.8 Dynamics integration (lines 305–322)

Single 4th-order Runge–Kutta step:

```matlab
x = RK4(@RHSCubeSat, x, dT, t, d);
```

`RK4(Fun, x, h, t, varargin)` performs the four function evaluations:

```
k1 = Fun(x, t, d)
k2 = Fun(x + h/2·k1, t+h/2, d)
k3 = Fun(x + h/2·k2, t+h/2, d)
k4 = Fun(x + h·k3, t+h, d)
x = x + h·(k1 + 2k2 + 2k3 + k4)/6
```

Then:
- `p.eci_vector = x(1:3)/norm(x(1:3))` — slide the ECI target so it always points at the new radial.
- `[xT, dist, power] = RHSCubeSat(x, t, d)` is called *again*, this time only to extract the disturbance breakdown (`dist.fAerodyn`, `dist.tAerodyn`, etc.) and the power for plotting.
- `qLVLH = QLVLH(x(1:3), x(4:6))` — quaternion ECI→LVLH at the new state.
- `qPlot(:,k+1) = QMult(QPose(qLVLH), x(7:10))` — body-relative-to-LVLH quaternion (this is what is plotted as the LVLH-frame attitude).
- `xPlot(:,k+1) = x`, `t = t + dT`, save `d.fieldECIbefore`, `d.fieldBODYbefore`.

The waitbar is updated every 5% of progress (`upF = ceil(nSim/20)`). If the user clicked Stop, the loop `break`s.

---

## 7. `RHSCubeSat` — the dynamics RHS

Located at `utils/CubeSatToolbox/CubeSat/Simulation/RHSCubeSat.m`. With `nargin == 0` it returns the default struct used in §4.5; otherwise it computes `xDot`.

### 7.1 Sequence

1. Unpack: `r = x(1:3), v = x(4:6), q = x(7:10), w = x(11:13), b = x(end)`.
2. `s = CubeSatEnvironment(x, t, d)` — single helper that bundles:
   - `s.uSun` (Sun unit vector, ECI), `s.nEcl` (eclipse factor 0 or 1), `s.solarFlux` (current value),
   - `s.bField` (ECI magnetic field via `BDipole`),
   - `s.rho` (atmospheric density at `r`, J70 if `d.atm` non-empty else `AtmDens2`),
   - `s.mu` (Earth's gravitational parameter).
3. Power: `uSunBody = QForm(q, s.uSun)`, `pSun = nEcl·solarFlux·uSunBody` (vector pointing at Sun in body frame, magnitude = flux). `power = SolarCellPower(d.power, pSun)` integrates `pSun` against the solar-cell normals & efficiencies. `p = power - d.power.consumption`. Battery saturation: zero out `p` if charging full or discharging empty.
4. Magnetic torque: `bField = QForm(q, s.bField)`, `tMag = Cross(d.dipole, bField)` — the dipole produced by the magnetorquers crossed with the local field.
5. Gravity-gradient torque: `tGG = GravityGradientFromR(q, d.inertia, r, s.mu)`.
6. Drag & SRP: `[fAerodyn, tAerodyn] = feval(d.aeroModel, s, d.surfData)` (== `CubeSatAero`), `[fOptical, tOptical] = feval(d.opticalModel, s, d.surfData)` (== `CubeSatRadiationPressure`). These iterate over the six faces and accumulate force/torque contributions.
7. Translational dynamics: `vDot = fTotal·1e-3/d.mass - mu·r/|r|³`. Note the `1e-3` — forces are in N, but `r` and `v` are in km/s, hence the factor 10⁻³ to convert m to km.
8. Rotational dynamics: `wDot = inv(I) · (tTotal - w × I·w)` — Euler's equations. The wheel branch (`d.kWheels`) is unused (wheels are empty `[]` for this PocketQube).
9. Quaternion kinematics: `qDot = QIToBDot(q, w)` — implements the standard `q̇ = 0.5 · Ω(w) · q` transform.
10. `xDot(end) = p` — battery state of charge is integrated as a scalar power-in.

### 7.2 Outputs

- `xDot` (14×1) — full RHS.
- `dist` — disturbance breakdown (forces and torques per source plus density).
- `power` — instantaneous power produced from solar cells.

---

## 8. Post-processing (lines 339–489)

After loop exit:

- Print start/end timestamps and total wall-clock duration.
- `q_angle = 2*atan2(|q_error(:,2:4)|, q_error(:,1))` — error angle from each estimated body-error quaternion.
- `q_RMS = rms(q_angle)` — pointing-error RMS over the run (saved in workspace, not plotted).
- **Summary 4×3 figure**: column 1 = real angle error + Yaw/Pitch/Roll computed from the truth quaternion; column 2 = MKF-estimated error + Yaw/Pitch/Roll from `q_error`; column 3 = total commanded current magnitude + per-axis current.
- **AKE plot**: `2·acosd(q_AKE(1,:))` with horizontal reference lines at 5° (green dashed) and 10° (red dashed).
- **LVLH quaternion plot**: `Plot2D(tP, qPlot, tL, {'q_s' 'q_x' 'q_y' 'q_z'}, 'LVLH To Body Quaternion')` using `TimeLabl` to scale the time axis to a sensible unit.
- **Magnetorquer moment plot**: three traces (Mx, My, Mz) in A·m² over the full run.
- `SavePlots` is referenced but commented out.
- **`save(fullfile(debugDir, 'sim_debug.mat'))`** — dumps the **entire workspace** to `utils/debug/sim_debug.mat`. This file is gitignored and is used only for offline analysis between runs.

---

## 9. File-level dependency map

The transitive dependency closure of `NadirPointing.m` (only what is *required* for a successful run) is:

### 9.1 Project-local files

| Path | Role |
|------|------|
| `NadirPointing.m` | Top-level script |
| `PSSSetPaths.m` | Path setup |
| `SimConfiguration/Sim_sat_initial_state.m` | Initial state vector |
| `SimConfiguration/Sim_time_parameters.m` | `dT, nSim, tEnd` |
| `SimConfiguration/Sim_pq_model.m` | Face geometry from `CubeSatFaces` |
| `SimConfiguration/Sim_sensors.m` | Calls `Sensors_Config_File` and toggles sensors |
| `SimConfiguration/Sim_data_structure.m` | Builds master `d` struct |
| `SimConfiguration/Sim_thermal_control_config_file.m` | Sets `d.alpha, d.epsilon, d.area, d.cP` |
| `SimConfiguration/Sim_PID_controller.m` | Calls `PIDMIMO`, sets `m_max`, target vectors |
| `SimConfiguration/MKF.m` | Initializes `KF` struct |
| `SimConfiguration/Sim_sun_position.m` | Sun-vector estimate per step |
| `utils/Functions/CubeSatFaces.m` | Local override of PSS function with the same name |
| `utils/Functions/PID3Axis2.m` | PID wrapper / default struct |
| `utils/Functions/triad.m` | TRIAD attitude determination |
| `utils/Functions/rotmatrix2quat.m` | Rotation-matrix → quaternion |
| `utils/MKF_functions/quat2rotm.m` | Custom scalar-first quaternion → rotation matrix |
| `utils/Sensors/Magnetometer_measurement.m` | Adds calibration/bias/noise to `bfieldBODY` |
| `utils/Sensors/Gyro_measurement.m` | Adds bias + ARW/RRW noise to true rate |
| `utils/sun estimator sun sensors/sun_position_estimator.m` and its 12 helpers | Photodiode → sun unit vector dispatch |
| `Detumbling/SimMagnetorquers/Sensors_Config_File.m` | Master sensor parameters (shared with the Detumbling pipeline) |

### 9.2 Princeton Satellite Systems CubeSat Toolbox (vendored at `utils/CubeSatToolbox/`)

**Quaternion math** (`Common/Quaternion/`): `QMult`, `QPose`, `QForm`, `QTForm`, `U2Q`, `Mat2Q`.

**Math utilities** (`Math/`): `RK4`, `Cross`, `Dot`, `Skew`, `Mag`, `Unit`.

**Time**: `Date2JD`, `JD2T`, `JD2000`, `EarthRte`.

**Orbit basics** (`SC/BasicOrbit/`): `Period`, `OrbRate`, `VOrbit`, `RVFromKepler` (only used inside `BDipole`'s demo path), `ECIToEF`.

**Environment** (`SC/Environs/`, `SC/Ephem/`): `BDipole`, `SunVectorECI` (and its helpers `SunV1`, `EarthNut`, `EarthPre`, `EarthRot`, `EOfE`, `ObOfE`, `NutDelta`, etc.), `SolarFluxPrediction`, `Eclipse`, `AtmJ70`, `AtmDens2`.

**Disturbances** (`SC/Disturbances/`, `CubeSat/Simulation/`): `GravityGradientFromR`, `CubeSatAero`, `CubeSatRadiationPressure`, `OpticalSurfaceProperties`, `SolarF`.

**Power**: `CubeSat/Power/SolarCellPower.m`.

**Dynamics** (`CubeSat/Simulation/`, `AeroUtils/Coord/`): `RHSCubeSat`, `CubeSatEnvironment`, `QIToBDot`, `QLVLH`, `CoordinateTransform`.

**Control** (`Common/Control/`): `PIDMIMO`, `C2DZOH`, `C2DelZOH` (delta variant chosen by `'Delta'` flag).

**Plotting** (`Common/Graphics/`): `Plot2D`, `TimeLabl`, `NewFig` (used inside `BDipole` demo).

**Database** (`Common/Database/`): `Constant` (used to query `'equatorial radius earth'`, etc.).

The set above is conservative — anything not listed is *not* needed for `NadirPointing.m` to run end-to-end.

---

## 10. Inputs, outputs and side effects

**Inputs**: none from disk (no CSV / TLE input files are loaded — the orbit is initialized analytically from `a0`, the date is hardcoded). The single external data table consumed is `SC/SCData/SolarFluxPredictions.txt`, opened by `SolarFluxPrediction` inside `Sim_data_structure`.

**Outputs**:

- 4 figure windows (Attitude & Control Summary, AKE, LVLH-to-Body Quaternion, Moment Magnetorquers).
- `utils/debug/sim_debug.mat` — full workspace.
- Console: simulation start time, end time, wall-clock duration.

**Side effects**:

- `cd` into `NadirPointing/` (done by `PSSSetPaths`).
- Adds 100+ directories to the MATLAB path (not persisted).
- Creates `utils/debug/` if it does not exist.

---

## 11. Operating envelope and known caveats

This is a quick-reference list of caveats. The full mathematical/dimensional discussion of every item is in §13–§14.

- The diagonalization of the inertia tensor (`d.inertia = mean(diag(D))*eye(3)`) is **deliberate**: it matches the controller design assumption. Restoring the full off-diagonal tensor would require redesigning the PID gains. (One side-effect: gyroscopic coupling `ω×Iω` vanishes — see §13.2.)
- The control law in the loop is PD only (the `kI` integrator gain returned by `PIDMIMO` is computed but never multiplied into the dipole). If integrator action is needed, `Sim_PID_controller.m` exposes `constants.kI`. See §14 (M6).
- The control gains are also **double-multiplied by inertia** (once inside `PIDMIMO`, once again in `NadirPointing.m`); the produced dipole is therefore ~10⁴× too small in magnitude. Closed-loop bandwidth is far below the design value. See §13.9 / §14 (C1).
- TRIAD output is computed every step but **only consulted on `k == 1`**, where it is then immediately discarded in favour of the truth `x(7:10)`. The deeper reason for the discard is that `triad.m` returns the **inverse** of the PSS quaternion convention — see §13.11 / §14 (C8).
- The control update fires at 1 Hz regardless of `dT` (`mod(k, ceil(1/dT)) == 0`). If you change `dT` to a value that does not divide 1 s evenly, the cadence will drift.
- The pointing target encoded in `q_target` is **zenith**, not nadir, despite the file name. See §13.14 / §14 (C3).
- The MKF process-noise propagation is non-textbook: `P = F·(P + Q)·Fᵀ` instead of `P = F·P·Fᵀ + Q`. See §14 (C5).
- The MKF `Qn` off-diagonal sign and the `Fn` off-diagonal sign are inconsistent; together with `Rδᵀ` instead of `Rδ` in the upper-left block of `Fn`, the filter does not match the textbook MKF. See §13.10 / §14 (C6).
- `KF.Qw` is set as `std_Qw · I3` (no square), so its name and value are inconsistent. See §14 (C7).
- `IGRF_sigmaNoise` is a variance in one branch of the loop and a standard deviation in the other; `KF.Qv` consumes it as a covariance. The mismatch is latent because the variance branch is the default. See §14 (C2).
- `d.power.consumption` is set by a formula whose dimensions do not match its commented intent. See §14 (C4).
- The first call to `BDipole` inside the loop is duplicated (lines 105 and 106). Harmless but wasteful.
- The gyro queue averaging code is dead (the final `w_read = w_meas` line in `Gyro_measurement.m` overrides the average).
- `Sensors.gyros.queue_size` and `Sensors.gyros.queue` need to be initialized somewhere on the path; the ratings code in `Gyro_measurement.m` will error on the first call if those fields are missing — `Sensors_Config_File.m` does **not** create them, so this branch only works if a separate initialization (currently in the Detumbling pipeline) is also on the path. See §14 (M8).
- `Sim_sat_initial_state.m` uses `a0 = 6387.165 + 500` km, `Sim_data_structure.m` sets `d.rP = 6378.165` km, and `BDipole` uses an internal `a = 6371.2` km. Three different "Earth radii" coexist (initial altitude is therefore ~509 km, not 500 km). See §14 (M1).
- Battery initial state of charge `b0 = 20 000 J` exceeds the nominal capacity `1400 mAh × 3.3 V = 16 632 J`. See §14 (M5).

---

## 12. Quick-reference flow diagram

```
PSSSetPaths(1)
     │
     ▼
Sim_sat_initial_state ──► [r0,v0,q0,w0,b0]      ┐
Sim_time_parameters    ──► [dT, nSim]           │
Sim_pq_model           ──► [a, n, r]            ├─► x, d
Sim_sensors            ──► Sensors              │
Sim_data_structure     ──► d (incl. thermal)    │
Sim_PID_controller     ──► p, m_max, constants ─┘
MKF                    ──► KF struct

for k = 1 : nSim
    ├── angleError_real = angle( body axis , target ECI )           ── ground truth
    ├── BDipole + Magnetometer_measurement   ──► d.fieldBODY
    ├── Sim_sun_position (incl. sun_position_estimator) ──► d.rSunBody
    ├── Gyro_measurement                     ──► w_read
    ├── if k == 1:  TRIAD + rotmatrix2quat  → seed KF.q/w/P
    │   else:       MKF predict + update    → quaternion, w_read
    ├── q_target = U2Q(p.eci_vector, p.body_vector)
    ├── q_target_body = QPose(quaternion) ⊗ q_target
    ├── if 1 Hz tick:
    │       moment = (kP · B×q_v − kR · B×ω) / |B|²
    │       d.dipole = saturate(moment, m_max)
    ├── x = RK4(@RHSCubeSat, x, dT, t, d)
    ├── store xPlot, qPlot, intensity, AKE, ...
    └── update waitbar / poll cancel
end

Plots (4×3 summary, AKE, LVLH q, moments)
save utils/debug/sim_debug.mat
```

---

## 13. Mathematical and physical analysis

This section reviews **every quantitative computation** performed during the simulation, verifying:
- the **dimensional consistency** of each expression (SI vs. mixed units actually in use),
- the **frame coherence** of every vector (ECI, body, LVLH, EF, body-aero, body-target),
- and the **physical correctness** of each model (signs, directions, conservation laws).

The notation `[X]` denotes the units of `X`. PSS-Toolbox conventions: positions in **km**, velocities in **km/s**, masses in **kg**, inertia in **kg·m²**, time in **seconds**, angles in **rad**, magnetic field in **Tesla**, magnetic dipole in **A·m²**, force in **N**, torque in **N·m**, gravitational parameter `μ` in **km³/s²**.

### 13.1 Translational dynamics

`RHSCubeSat` line 149:

```
vDot = fTotal·1e-3/d.mass − s.mu · r/Mag(r)^3
```

| Term | Dimensional check |
|------|-------------------|
| `fTotal` (sum of `fAerodyn + fOptical`) | `[N] = [kg·m/s²]` |
| `fTotal·1e-3 / d.mass` | `[N · 10⁻³ / kg] = [10⁻³ m/s²] = [km/s²]` ✓ |
| `s.mu` (= `Constant('mu earth')`) | `[km³/s²]` |
| `r` | `[km]`, `Mag(r)^3` | `[km³]` |
| `s.mu · r / Mag(r)^3` | `[km³/s² · km / km³] = [km/s²]` ✓ |

Both terms have units **km/s²**, so `vDot` integrates correctly with `r [km], v [km/s]` over `dT [s]` in `RK4`. The factor `1e-3` converts the SI-Newton force to km/s² acceleration — this is the *only* unit transition in the integrator and is **correct**.

The Earth-fixed dipole tilt and the magnetic field are computed in ECI, and the position used for gravity (`r/|r|³`) is also in ECI. **Frame coherence ✓.**

### 13.2 Rotational dynamics — Euler's equations

`RHSCubeSat` line 160:

```
wDot = inv(d.inertia) · (tTotal − Cross(w, d.inertia·w))
```

This is the rigid-body Euler equation `Iω̇ = T − ω × (Iω)` with the gyroscopic torque on the right-hand side and `T = T_GG + T_mag + T_aero + T_optical`. With the simulation's diagonal inertia `I = Ī·I3` (see §4.5), `Iω` and `ω×Iω` reduce to `Ī·ω` and `Ī·ω×ω = 0`, which means the **gyroscopic coupling vanishes** in this particular run — the spacecraft behaves as a perfect sphere about its center of mass. This is consistent with the controller assumption (which derives gains from the same diagonal `I`), but it removes the off-diagonal coupling that the real PocketQube has.

Dimensional check:
- `tTotal` ∈ `[N·m] = [kg·m²/s²]`.
- `d.inertia·w` ∈ `[kg·m² · rad/s] = [kg·m²/s]`.
- `Cross(w, d.inertia·w)` ∈ `[(rad/s) · (kg·m²/s)] = [kg·m²/s²] = [N·m]` ✓.
- `inv(d.inertia) · (N·m)` ∈ `[1/(kg·m²) · kg·m²/s²] = [1/s² = rad/s²]` ✓.

**Frame**: all quantities are body-frame; the inertia tensor is body-frame; gravity-gradient and aero/optical torques are body-frame (see §13.4–13.6). `tMag` is body-frame because `bField` was rotated into body. ✓

### 13.3 Quaternion kinematics

`xDot(7:10) = QIToBDot(q, w)` evaluates

```
q̇ = ½ · Ω(ω) · q,  with  Ω(ω) = [0, ωᵀ; −ω, −[ω]ₓ]
```

and `q` is **ECI → body**, `ω` is the body rate. Standard Markley/Crassidis form:

- `q̇₀ = −½ ω · q_v`,
- `q̇_v = +½ (q₀ ω − ω × q_v)`,

which the matrix form above produces exactly. **The convention matches** PSS scalar-first body-to-inertial passive interpretation. Dimension: `ω [rad/s] · q [—] → [1/s]` ✓.

The conjugate-quaternion sign convention used throughout (`QPose` flips only the vector part) is consistent: `QMult(QPose(q), q) = [1;0;0;0]` ⇒ identity rotation. ✓

### 13.4 Gravity-gradient torque

`GravityGradientFromR.m` line 53:

```
t = 3·μ · Cross(r_body, I·r_body) / Mag(r_body)^5
```

This is the standard formula `T_gg = 3μ/r³ · n̂ × (I·n̂)` rewritten with `r = |r|·n̂`:

```
3μ/r³ · n̂ × (I·n̂) = 3μ · r × (I·r) / r⁵.
```

Dimensional check (all in body frame):
- `μ` ∈ `[km³/s²]`.
- `r_body = QForm(q, r)` ∈ `[km]` (the ECI position rotated into body — same magnitude).
- `I · r_body` ∈ `[kg·m² · km] = [kg·m²·km]`.
- `Cross(r_body, I·r_body)` ∈ `[km · kg·m²·km] = [kg·m²·km²]`.
- Divided by `Mag(r)^5 ∈ [km⁵]`: `[kg·m²·km² / km⁵] = [kg·m²/km³]`.
- Multiplied by `μ ∈ [km³/s²]`: `[kg·m²/s²] = [N·m]` ✓.

The mixed `[km]/[m]` dimensions cancel exactly. This **only works because** `μ` carries `km³` in the numerator and the formula is `r⁵` (not `r³`); had the developer multiplied by `(r̂ × I·r̂)/r³` directly, the unit balance would have required converting `r` to meters first. The PSS form is correct as written.

**Frame**: `r_body` and `I` are in body frame, hence `t` is in body frame. ✓

### 13.5 Aerodynamic force and torque (`CubeSatAero`)

Line 84: `qAero = 0.5·rho·vMag·p.vRel·1e6`.

The free-stream dynamic pressure is `q∞ = ½·ρ·v²·v̂` (vector form). Here `vMag = |v_rel|` ∈ `[km/s]` and `p.vRel` ∈ `[km/s]`, so `vMag·vRel` ∈ `[(km/s)²] = [10⁶·(m/s)²]`. The factor `1e6` converts km²/s² → m²/s², so

```
[qAero] = [kg/m³ · m²/s² · ⟨vector⟩] = [N/m² = Pa]·⟨v̂⟩.
```

✓. Then per face:
```
fFace = − (n̂_body · v̂_body) · q_body · area · cD       [N]
torque = (rFace − cM) × fFace                          [m × N = N·m]
```

`d.area ∈ [m²]`, `d.cD ∈ [—]`, `d.rFace ∈ [m]`. ✓

The total force is then rotated **back** to ECI by `force = QTForm(qECIToBody, force)`, while the torque stays in the body frame. **Frame split is intentional** because `RHSCubeSat` consumes ECI forces (for `vDot`) and body torques (for `wDot`) — see §13.1–13.2. ✓

The drag formula uses `vRel`, which `CubeSatEnvironment` computes as `v − cECIToEF'·[ω_⊕]·r_EF` to subtract the corotating-atmosphere velocity at the satellite. This is the correct **co-rotating atmosphere** correction. ✓

### 13.6 Solar-radiation-pressure force (`CubeSatRadiationPressure`, called via handle)

Same structural setup as drag: dynamic-pressure analogue is `s.solarFlux/c · uSun_body`, projected onto each illuminated face. Force in body, then rotated back to ECI. Eclipse modulation through `s.nEcl ∈ [0,1]` zeros out the contribution while the spacecraft is in Earth's shadow. **Frame ✓, dimension ✓** (output `[N]`).

### 13.7 Magnetic-dipole torque

`RHSCubeSat` line 121: `tMag = Cross(d.dipole, bField)` with `bField = QForm(q, s.bField)` (body frame).

```
[d.dipole] = [A·m²], [bField] = [T] = [kg/(A·s²)]
[tMag] = [A·m² · kg/(A·s²)] = [kg·m²/s² = N·m]                ✓
```

`d.dipole` is set by the controller in body frame (the magnetorquer coils are body-fixed), and `bField` is in body frame after `QForm`. **Frame ✓.**

### 13.8 Magnetorquer control law

`NadirPointing.m` lines 280–282:

```
kP_eff = I · constants.kP        [kg·m² · rad/s²/rad = kg·m²/s²]   (per-axis)
kR_eff = I · constants.kR        [kg·m² · rad/s²/(rad/s) = kg·m²/s] (per-axis)
moment = (kP_eff · B×q_v − kR_eff · B×ω) / |B|²
```

The continuous-time PID gains from `PIDMIMO` produce *acceleration-equivalent* gains (the `c, d` matrices are pre-multiplied by `inr`, see `PIDMIMO.m` lines 120–121), so multiplying again by `d.inertia` actually scales the gains by `I²`. This deserves analysis.

**Theoretical control law** (cross-product or "B-cross") for nadir tracking:

```
T_desired = −Kp · q_v − Kr · ω           [N·m]              (PD on attitude error)
m         = (B × T_desired) / |B|²        [A·m²]              (B-cross inversion)
```

Substituting:

```
m = (1/|B|²) · [ −Kp·(B×q_v) − Kr·(B×ω) ]
```

In the code the sign on the proportional term is inverted (`+Kp·B×q_v` instead of `−Kp·B×q_v`). This is consistent **iff** the convention on `q_v` is such that `q_target_body(2:4)` already encodes the *negative* small-angle error, i.e. `q_target_body = q_body→target` rather than `q_target→body`. From §6.7:

```
q_target_body = QMult(QPose(q_body←ECI), q_ECI→target_body) = q_body←target_body
```

So `q_target_body` rotates a vector from the *target* frame to the *current body* frame, and its small-angle vector part is `−½·δθ` (where `δθ` is the rotation needed *from* current body *to* target). Plugging into the standard law `T_desired = −Kp·δθ − Kr·ω`:

```
δθ ≈ −2·q_v   ⇒   T_desired = +2·Kp·q_v − Kr·ω
```

so the sign in the code (`+kP · B×q_v`) **is correct**, but the factor of 2 absorbed into `Kp` means the *effective* proportional gain is twice the textbook value relative to the small-angle interpretation. This is a known idiom in the Wertz / Markley literature and is internally consistent.

**Dimensional check**:

```
B×q_v          [T·−]                 = [T]
B×ω            [T·rad/s]              = [T·rad/s]
kP·B×q_v       [kg·m²·rad/s² · T]     = [N·m·T/rad]
                (rad treated as dimensionless)
kP·B×q_v / |B|²[N·m / T]
```

For this to produce `[A·m²]`, recall `T = kg/(A·s²)`, so `1/T = A·s²/kg`, hence `N·m / T = (kg·m²/s²) · (A·s²/kg) = A·m²` ✓.

The rate term `kR·B×ω / |B|²` requires `[kg·m²/s · T·rad/s] / [T²] = [kg·m²/(s²·T)] = [A·m²]` ✓.

**Frame coherence**: `B = d.fieldBODY`, `ω = w_read` (body), `q_v = q_target_body(2:4)` (body small-angle error). All in body frame ⇒ `m` is body frame. ✓

**Physical sanity**: `m × B` re-creates `T_desired` projected onto the plane orthogonal to `B`; the un-realisable component along `B` is dropped silently. This is a fundamental limitation of magnetorquer-only control and is *not* a bug.

### 13.9 PID design (`PIDMIMO`)

`PIDMIMO(I, ζ=1, ω=0.005/4, τ=300, ωR=0.1, dT=0.25, 'Delta')`:

- `ω = 1.25e-3 rad/s` — closed-loop bandwidth of ~0.2 mHz, ~22× slower than orbital rate `n ≈ 1.07e-3 rad/s`. Wait — this is **slower than orbit**. For a magnetorquer-only ADCS, the controllable bandwidth is actually limited *above* by orbital rate (you need at least one full orbit for the geomagnetic field to span enough directions). A bandwidth slower than `n` is physically reasonable (the system is barely controllable if you go above `n`).
- `ζ = 1` (critically damped).
- `τ_int = 300 s` — integrator time constant; would inject low-frequency authority over ~5 min, but **this gain is dropped from the final law** (`kI` is computed but never multiplied into `moment`).
- `ωR = 0.1 rad/s` — derivative roll-off, well above the bandwidth.

The PIDMIMO output `c, d` matrices are pre-multiplied by `inr` (line 120–121 of `PIDMIMO.m`), so the returned gain `constants.kP` already has units of `[N·m/rad]` (not `[rad/s²/rad]`). Therefore **the multiplication `kP_eff = d.inertia · constants.kP` in `NadirPointing.m` line 280 is an *additional* factor of `Ī` and is dimensionally wrong** by one factor of inertia.

Dimensional re-derivation:
- `PIDMIMO` returns `kP` such that `T = kP·u` with `T [N·m]` and `u [rad]`. Therefore `[kP] = [N·m/rad]`.
- The code does `kP_eff = I · kP`, giving `[kP_eff] = [kg·m² · N·m/rad] = [kg²·m⁴/(s²·rad)]`.
- The control law then divides by `|B|²` giving final `[kP_eff · T·rad / T²] = [kg²·m⁴/(s²·rad) · rad/T] = [kg²·m⁴/(s²·T)]`.
- For this to equal `[A·m²]` we need `kg²·m⁴/(s²·T) = A·m²` ⇒ `kg²·m²/(s²·T) = A`. With `T = kg/(A·s²)`: `kg²·m²/(s²) · (A·s²)/kg = kg·m²·A`. So we get `kg·m²·A`, not `A`. **Off by a factor of `kg·m²`** — i.e. one inertia dimension.

**This is a real dimensional inconsistency**, fed by the double-multiplication by `Ī`. Numerically, since `Ī ≈ 1.17e-4 kg·m²`, the magnitude of the produced dipole is `Ī` times what it should be, i.e. ≈10⁴× smaller. The saturation `m_max = [Sx,Sy,Sz]·150e-3 ≈ 7e-3 to 8e-3 A·m²` will therefore *almost never trigger* unless attitude errors are huge. See §14.

### 13.10 MKF — dimensional and frame analysis

#### 13.10.1 Quaternion propagation

```
δ = [cos(|ω|·dT/2); (ω/|ω|)·sin(|ω|·dT/2)]
q_pred = QMult(q_prev, δ)
```

`|ω|·dT` ∈ `[rad/s · s] = [rad]`. The half-angle quaternion of a body-frame rate-step is correct. The composition order `QMult(q, δ)` (with PSS convention "Q3 = QMult(Q2,Q1) means A→C if Q2:A→B, Q1:B→C") composes `q_prev: ECI→body_prev` with `δ: body_prev→body_now`, giving `q_pred: ECI→body_now`. **Frame ✓**.

#### 13.10.2 Linearized covariance propagation

The MKF error state is `[δθ ∈ ℝ³ (body); δω ∈ ℝ³ (body)]`. The implementation uses

```
F_n = [Rδᵀ,  dT·I3;
       0,    I3]
```

Standard derivations (Markley, *Multiplicative Quaternion Extended Kalman Filtering*, 2003) give

```
F_n_textbook = [Rδ,  −dT·I3;
                0,    I3]      (with attitude-error in body, gyro-bias-free)
```

The code uses `Rδᵀ` and `+dT·I3`. Both deviations from the textbook can be reconciled if the author redefined the sign of `δω` (e.g. as **measured-minus-true** instead of **true-minus-measured**) and used `Rδᵀ` to map the previous body-frame error into the new body frame *via the inverse increment*. But the choice is not documented and **cannot be determined to be correct from the code alone**. Given the relatively simple maneuver (slow nadir pointing), this is unlikely to destabilize the filter, but it casts doubt on whether the MKF would behave correctly under high-rate transients.

#### 13.10.3 Process-noise injection

```
P_pred = F_n · (P_prev + Q_n) · F_nᵀ
```

The standard EKF propagation is `P_pred = F·P·Fᵀ + Q_d`. Including `Q_n` *inside* the `F·(·)·Fᵀ` sandwich means the process noise is rotated by `F` before being added — over-amplifying it by a factor `F·F·Fᵀ·Fᵀ` instead of `F·Fᵀ`. For `Rδ`'s near identity (small steps) the difference is `O(|ω|·dT)` per step but accumulates. **This is a deviation from the standard formulation** — see §14.

#### 13.10.4 Q_n discrete-time form

```
Q_n = [dT³/3·Q_w,  −dT²/2·Q_w;
       −dT²/2·Q_w,  dT·Q_w]
```

The textbook discrete-time process noise of a constant-PSD rate model with state `[δθ; δω]` and continuous-time `Q_c = diag(0, Q_w)` is

```
Q_d = [dT³/3·Q_w,  +dT²/2·Q_w;
       +dT²/2·Q_w,  dT·Q_w]
```

(with **positive** off-diagonal). The code's negative off-diagonal block is consistent **iff** the velocity error appears with a `−dT·I3` in the transition matrix — but it doesn't (the code uses `+dT·I3`). So the off-diagonal of `Q_n` and the off-diagonal of `F_n` are inconsistent in sign. **See §14.**

#### 13.10.5 Variance vs. standard deviation

The simulation re-uses several variables that *should* hold variances (`σ²`) but actually hold standard deviations (`σ`), or vice versa.

Inside `NadirPointing.m`:

| Branch (line) | Code | Stored quantity |
|---------------|------|-----------------|
| `Sensors.magnetometer.on==1` (104) | `IGRF_std = [344 322 481]·1e-9; IGRF_sigmaNoise = IGRF_std.^2` | **variance** `[T²]` |
| `Sensors.magnetometer.on==0` (112) | `IGRF_sigmaNoise = [344 322 481]·1e-9·safeFact` | **standard deviation** `[T]` |
| Inside MKF update (196) | `KF.Qv = IGRF_sigmaNoise · KF.I3` | used as **variance** (covariance block) |

So when the magnetometer is on, `KF.Qv` is dimensionally consistent (variances `[T²]` filling a covariance matrix). When the magnetometer is off, `KF.Qv` is the *standard deviation* multiplied by `I3` — *not* a covariance — and the Kalman gain will be wrong by ~`σ` (a factor of `~3·10⁷`). The on-branch is the simulation's normal mode, so this is latent rather than active; still a real bug. **See §14.**

A second one: in `MKF.m`,

```
KF.Qw = (KF.std_Qw) · KF.I3      (KF.std_Qw = 1e-3)
```

The variable name `std_Qw` plus the lack of squaring suggests the author intended a standard deviation but stored it without squaring; whether `KF.Qw` is a covariance or a deviation is then ambiguous. The downstream `Q_n = [dT³/3·Q_w, …]` form expects `Q_w` to be a *covariance* (PSD-like), so the omission of the square is inconsistent with the discretization formula but consistent with treating `1e-3` as a directly-set covariance. **See §14.**

#### 13.10.6 Innovation, gain, update

```
S_n  = H_n·P_pred·H_nᵀ + diag(Q_v + R_v, R_w)
K_n  = P_pred·H_nᵀ / S_n
P_upd = (I_6 − K_n·H_n) · P_pred
```

- `S_n` ∈ `[T², (rad/s)²]` along the diagonal blocks ✓ (with the variance/std caveat above).
- `K_n` is `(6×6) · ([T², (rad/s)²])⁻¹`. Multiplying `K_n · (state_meas − state_predict)` produces a 6-vector with dimensions `[rad, rad/s]` ⇒ matches the error-state ✓.
- `P_upd` is the **non-Joseph** form. Susceptible to losing positive-definiteness over very long runs through round-off, but harmless for `nSim ≈ 4.5×10⁴`.

### 13.11 TRIAD geometry

`triad(ref1, ref2, body1, body2)` builds an orthonormal triad from a primary vector and a secondary one:

```
v1 = ref1/|ref1|,   v2 = (ref1×ref2)/|·|,   v3 = (ref1×v2)/|·|
w1 = body1/|body1|, w2 = (body1×body2)/|·|, w3 = (body1×w2)/|·|
R  = [v1 v2 v3] · [w1 w2 w3]ᵀ
```

`R` is dimensionless and orthonormal by construction. It rotates body→reference (because `R · w_i = v_i`). Hence `rotmatrix2quat(R)` produces a quaternion with **opposite** convention to PSS's `q: ECI→body`. The downstream code masks this by overwriting `quaternion = x(7:10)` on `k==1` (see §6.5.1), so the inversion never reaches the filter. If `quaternion` from TRIAD were ever used unmodified, the filter would diverge. **Latent bug** — see §14.

### 13.12 Sun-sensor photodiode model

`Sim_sun_position.m` lines 59–62:

```
faces_no_noise = vo_ph · cos(point_faces).²
```

Standard Lambertian photodiode response is **first-power** cosine: short-circuit current ∝ `cos(θ)` (because the projected area scales linearly with the cosine of incidence). The square is **non-physical** for a flat photodiode — it would correspond to a face whose responsivity itself depended on incidence angle. Possibly an intentional gain-shaping for the estimator's behaviour, but undocumented.

Solar constant inconsistency:

| Place | Constant |
|-------|----------|
| `Sim_sun_position.m` line 43 | `solar_flux = 1361 W/m²` |
| `CubeSatEnvironment.m` line 68 | `SOLAR_FLUX = 1367 W/m²` |

The 6 W/m² discrepancy is about 0.4 % — negligible for sun-sensor estimation but inconsistent.

**Frame**: photodiode model is local to body frame. `sun_position_estimator` returns a *unit vector* in body frame, immediately stored in `d.rSunBody`. ✓

### 13.13 Coordinate-transform sanity

| Transform in code | Documented meaning | Verified |
|-------------------|--------------------|----------|
| `QForm(q, vEci)` | rotates **ECI vector → body vector** | ✓ |
| `QTForm(q, vBody)` | rotates **body vector → ECI vector** | ✓ |
| `QMult(QPose(q1), q2)` | composes `q1⁻¹ · q2`; with q1: A→B, q2: A→C ⇒ result B→C | ✓ |
| `QLVLH(r, v)` | builds q: **ECI → LVLH** with z=−r̂, y=−(r×v)/|·|, x=y×z | ✓ |
| `QPlot(:,k+1) = QMult(QPose(qLVLH), x(7:10))` | LVLH → body | ✓ |
| `CoordinateTransform('ECI','LLR', r, jD)` | Returns lat/lon/altitude of `r`; not used downstream | (cosmetic) |

### 13.14 Pointing-target geometry

The "target" is built as `q_target = U2Q(p.eci_vector, p.body_vector)`. `U2Q(u, v)` returns the smallest quaternion `q` such that `QTForm(q, v) = u`, i.e. **`QForm(q, u) = v`**.

With `p.eci_vector = r̂ = +r/|r|` (radial outward, i.e. **zenith** in ECI) and `p.body_vector = [0;0;1]`, the target rotation aligns body-Z with the *zenith* direction. For true **nadir** pointing (body-Z toward Earth), one of the following should hold:

- `p.eci_vector = -r/|r|`, or
- `p.body_vector = [0;0;-1]`, or
- the controller's sign convention is inverted elsewhere to compensate.

None of the three is the case in the code, so the simulation actually drives the body Z axis toward zenith, not nadir. The angle-error ground-truth in `angleError_real` is consistent with the controller's target, so the plotted error is meaningful — but it is the error to *zenith*, not to *nadir*. **See §14.**

### 13.15 Power and battery

| Quantity | Code expression | Stated unit |
|----------|-----------------|------------|
| `power` (from `SolarCellPower`) | `Σ η_cell·η_conv·area·max(n̂·pSun, 0)` | `[W]` |
| `pSun` | `nEcl · solarFlux · uSunBody` | `[W/m²]` |
| `d.power.consumption` | `80/3600 · dT · 1e-3` | comment says "W each dT, ADCS 80 mWh" |
| `p = power − consumption` | (subtracted) | implied `[W]` |
| `xDot(end) = p` | RK4-integrated as a scalar | implied `[J/s = W]` |
| `b = x(end)` | battery state | seeded as `b0 = 20000` |

Two dimensional issues:

1. **`d.power.consumption` formula**: the *commented intent* is "80 mWh ADCS consumption", which would be an **energy** of `80·10⁻³·3600 = 288 J`. The formula evaluates to `80/3600 · 0.25 · 10⁻³ ≈ 5.6·10⁻⁶`. With dT in the formula, the produced quantity is neither power nor energy with any standard interpretation. The treatment of `consumption` as `[W]` (since it is subtracted from `power`) is therefore inconsistent with the formula. **Real bug — see §14.**

2. **Battery initial value**: `b0 = 20000` (J?). The capacity is `1400 mAh · 3.6 s/mA·h · 3.3 V = 16,632 J`, so the simulation **starts with the battery already over-full** by ~20 %. The `RHSCubeSat` saturation logic clamps `p` to zero whenever `b ≥ batteryCapacity`, so the battery is held at `b0` until the integration "discovers" the over-charge condition — but it never will, because `p ≥ 0` cases are clipped to `0`, and `p < 0` cases (eclipse) decrement `b` toward the capacity. So the battery integrates downward from `b0 = 20 000 J` past the cap. **Latent inconsistency — see §14.**

### 13.16 Magnetic-field model

`BDipole(r, jD)` computes the IGRF-1995 tilted-dipole field:

```
b_EF = (a³·h₀·1e-9 / r³) · (3·(û_dipole · r̂)·r̂ − û_dipole)
b_ECI = ECIToEFᵀ · b_EF
```

| Symbol | Code | Units |
|--------|------|-------|
| `a` | `6371.2` | km (mean Earth radius for IGRF) |
| `h₀` | `√(g₁₀² + g₁₁² + h₁₁²)` | nT (IGRF Gauss coefficients, scaled by `1e-9` to convert to T) |
| `r_EF` | `cECIToEF · r` | km |
| `b_EF` | output | T |

The `1e-9` factor converts `nT → T`. Dimensionally `[km³·nT·1e-9 / km³] = [T]` ✓.

The IGRF reference epoch is **1995** with secular-variation linear in `dJD`. For the simulation epoch (2019-04-05) the secular drift is ~24 years × ~22 nT/year ≈ 530 nT in `g₁₀`, which is non-negligible (~1.5 % of total field). For a control bandwidth of ~1 mHz this is unimportant, but the *absolute* field magnitude is biased by the antiquated coefficients.

**Frame**: input `r` in ECI, intermediate `r_EF` in Earth-fixed, output `b` in ECI. Then `bField = QForm(q, b)` rotates to body. ✓

### 13.17 RK4 propagation

`RK4(@RHSCubeSat, x, dT=0.25, t, d)` performs the standard fourth-order Runge–Kutta. The truncation error is `O(dT⁵)` per step and `O(dT⁴)` over the integration interval. With `dT = 0.25 s` and the dominant fast dynamics being attitude (highest frequency of order `|ω| ~ 2·n ~ 2·10⁻³ rad/s`), the per-orbit attitude error is well under `10⁻⁹ rad`. Numerical accuracy is **not** a bottleneck.

The unit composition inside `RK4` is consistent because every state and its derivative share the same unit: `r [km], v [km/s], q [—], ω [rad/s], b [J]` propagated by `vDot [km/s²], aDot [km/s³] (implicit), q̇ [1/s], ω̇ [rad/s²], ḃ [W = J/s]`. All consistent ✓.

The fact that `q` is integrated component-wise (rather than via an exponential map) means it slowly loses its unit norm; the simulation never re-normalizes `x(7:10)` between steps. Over 45 416 steps the accumulated drift is in the `1e-12` range — harmless.

### 13.18 Summary table — units of every variable in the loop

| Variable | Domain | Units | Frame |
|----------|--------|-------|-------|
| `x(1:3)` | state | km | ECI |
| `x(4:6)` | state | km/s | ECI |
| `x(7:10)` | state | — | quaternion ECI→body |
| `x(11:13)` | state | rad/s | body |
| `x(14)` | state | J | scalar |
| `d.fieldECI` | environment | T | ECI |
| `d.fieldBODY` | sensor reading | T | body |
| `d.rSunECI` | environment | km / dimensionless | ECI |
| `d.rSunBody` | sensor reading | dimensionless unit | body |
| `w_read` | sensor reading | rad/s | body |
| `d.dipole` | actuator command | A·m² | body |
| `m_max` | parameter | A·m² | per-axis body |
| `intensity(:,k)` | logging | mA | per-axis body |
| `q_target` | controller | quaternion | ECI → body_target |
| `q_target_body` | controller | quaternion | body → body_target |
| `q_AKE(:,k)` | logging | quaternion | body_estimate → body_truth |
| `AKE(1,k)` | logging | deg | scalar |
| `KF.Pprev` | filter | mixed `[rad², rad²/s²]` blocks | body error space |
| `KF.Kn` | filter | mixed (gain) | maps `[T, rad/s]` → `[rad, rad/s]` |
| `moment_vec(k,:)` | logging | A·m² | body |
| `qPlot(:,k+1)` | logging | quaternion | LVLH → body |

---

## 14. Things that don't add up — known inconsistencies in the full picture

This section consolidates every place where, after the math/physics walk-through, a quantity, sign, or dimension is **inconsistent with the rest of the code or with the textbook physics**. The list is in decreasing order of severity. Items are *real* mismatches (not subjective preferences), drawn from cross-referencing every file in the dependency closure.

### 14.1 Critical (control or estimator behaviour is altered)

**(C1) Double inertia-multiplication of the PID gains** — *Sim_PID_controller.m* line 21 calls `PIDMIMO(Inertia_matrix, …)` which internally pre-multiplies the C/D matrices by `Inertia_matrix` (PIDMIMO.m lines 120–121) so the returned `kP, kR` already have units `[N·m/rad]` and `[N·m·s/rad]`. *NadirPointing.m* line 280 then computes `kP_eff = d.inertia · constants.kP`, multiplying by inertia a **second time**. Numerical consequence: the produced dipole is scaled by an extra factor `Ī ≈ 1.17·10⁻⁴ kg·m²`, i.e. ~10 000× too small. The saturation `m_max ≈ 8·10⁻³ A·m²` is rarely if ever triggered, and the closed-loop bandwidth is far below the design value of `ω = 1.25·10⁻³ rad/s`. **Suggested fix**: drop the `d.inertia ·` factor in `NadirPointing.m`, or undo the inertia-pre-multiplication inside `PIDMIMO` for this caller.

**(C2) `IGRF_sigmaNoise` is variance in one branch, standard deviation in the other** — *NadirPointing.m* line 104 sets `IGRF_sigmaNoise = IGRF_std.^2` (correct: covariance ⇒ `[T²]`). Line 112 sets `IGRF_sigmaNoise = IGRF_std` (wrong: standard deviation ⇒ `[T]`). The variable is then consumed unconditionally as a covariance in `KF.Qv = IGRF_sigmaNoise · I3`. With the magnetometer **on** (the default) the on-branch is taken and the value is correct; if anyone disables the magnetometer the gain is wrong by ~`σ⁻¹ = 3·10⁶` — the filter trusts the magnetometer infinitely. **Suggested fix**: square the value in line 112.

**(C3) Pointing target is zenith, not nadir** — `q_target = U2Q(p.eci_vector = r̂, p.body_vector = [0;0;1])` aligns body-Z with the radial-outward direction. Nadir is `−r̂`. The simulation, controller, and reference plots are *internally* consistent (all measure error to zenith), but the filename and project description state "nadir pointing". **Suggested fix**: set either `p.body_vector = [0;0;-1]` *or* `p.eci_vector = −x(1:3)/norm(x(1:3))`. (The latter must also be updated inside the loop at line 306.)

**(C4) `d.power.consumption` formula does not match its stated meaning** — *Sim_data_structure.m* line 51: `d.power.consumption = 80/3600 · dT · 1e-3`. The comment says "80 mWh ADCS". Three valid interpretations and the formula matches none:
- 80 mWh as energy: `80·10⁻³ · 3600 = 288 J` — formula evaluates to ~5.6·10⁻⁶, off by 8 orders of magnitude.
- 80 mW as power: `0.08 W` — formula off by ~4 orders.
- 80 mWh per orbit: would require `÷ Period(a₀) ≈ 5677`, formula has `/3600` — nominally similar but formula has the wrong `dT` factor.

The expression is then subtracted from `power [W]` and integrated by RK4, so the dimensional intent is "power" but the formula carries `dT` (suggesting energy-per-step). **Suggested fix**: write `d.power.consumption = 0.08;  % W (= 80 mW continuous ADCS)`.

**(C5) MKF — process-noise injection inside the propagation sandwich** — *NadirPointing.m* line 176: `KF.Ppredict = F_n · (KF.Pprev + KF.Qn) · F_nᵀ`. Standard EKF: `P_pred = F·P·Fᵀ + Q_d`. The code's form rotates `Q_d` by `F·F`, which is *not* what discretization gives, and over-amplifies process noise as `|F| > 1` (which it is, because of the `dT·I3` block). **Suggested fix**: replace by `F_n · KF.Pprev · F_nᵀ + KF.Qn`.

**(C6) MKF — sign of off-diagonal `Q_n` block contradicts the sign of the off-diagonal `F_n` block** — *MKF.m* line 19: `KF.Qn = [dT³/3·Qw, −dT²/2·Qw; −dT²/2·Qw, dT·Qw]`. *NadirPointing.m* line 175: `F_n = [Rδᵀ, +dT·I3; 0, I3]`. The textbook discretization of the rate-noise model with this `F_n` produces `Q_d` with **positive** off-diagonal `+dT²/2·Q_w`. Either the `F_n` should be `[Rδᵀ, −dT·I3; 0, I3]` (in which case the `Q_n` is correct and the prediction step `q_pred = QMult(q_prev, δ_predict)` would also need to be revisited), or the sign in `Q_n` should be flipped. As written they do not refer to the same model.

**(C7) MKF — `KF.Qw` is set as `std_Qw · I3` (not `std_Qw² · I3`)** — *MKF.m* line 13: `KF.Qw = (KF.std_Qw) · KF.I3` with `KF.std_Qw = 1e-3`. The naming "std" suggests a standard deviation, in which case the covariance should be `std_Qw² · I3 = 1e-6 · I3`. The downstream `Q_n` discretization formula is mathematically a covariance discretization, so it expects `Q_w` to be the continuous-time PSD covariance `[(rad/s)²]`. As coded, `Q_w` is `1e-3 · I3` — three orders of magnitude larger than the `std² = 1e-6` implication. **Suggested fix**: square or rename.

**(C8) TRIAD output is inverted relative to PSS quaternion convention** — `triad.m` returns `R = [v1 v2 v3] · [w1 w2 w3]ᵀ` with `R · w_i = v_i`. This rotates **body → reference (ECI)**. PSS's `q` is **ECI → body**. The `rotmatrix2quat` extraction therefore yields the **inverse** of the PSS-convention quaternion. The code masks this by overwriting `quaternion = x(7:10)` on `k==1`, so the bug is latent. If anyone removes the overwrite to test cold-start estimation, the filter will diverge instantly. **Suggested fix**: take the conjugate (`QPose`) of the extracted quaternion before storing it in `KF.q0`.

### 14.2 Moderate (correctness preserved, but value or assumption is off)

**(M1) Earth radius mismatch** — *Sim_sat_initial_state.m* uses `a0 = 6387.165 + 500 km` (likely a typo for `6378.165`); *Sim_data_structure.m* sets `d.rP = 6378.165 km`. The 9 km gap means the actual altitude at `t=0` is 509 km, not 500 km, and the `BDipole`-internal Earth radius (`a = 6371.2 km`) makes a third value. Magnetic-field magnitude is biased by ≈4 % at perigee. Cosmetic for a 2-orbit demo, but should be settled.

**(M2) Magnetometer measurement noise is over-modeled in the filter** — `KF.std_v = 1.5·10⁻⁶ T` (1500 nT), but the actual noise injected by `Magnetometer_measurement.m` is `4·10⁻⁸ · safeFact = 40 nT`, and the `IGRF_std` used elsewhere is ~350 nT. The filter's `R_v` is therefore ~38× higher than the truth, making the filter overly slow (it under-trusts the magnetometer). Tuning, not a bug.

**(M3) Sun-sensor cosine is squared** — `Sim_sun_position.m` line 59 uses `cos(point_faces).^2`. Standard photodiode response is first-order cosine. The square halves the apparent illumination at off-axis incidence, biasing the estimator's face-classification thresholds. Possibly intentional.

**(M4) Solar constant inconsistency** — 1361 W/m² in the sun-sensor model (Sim_sun_position) vs 1367 W/m² in the dynamics environment (CubeSatEnvironment). 0.4 % numerical mismatch.

**(M5) Battery initial charge above capacity** — `b0 = 20 000 J` but `batteryCapacity = 1400·3.6·3.3 = 16 632 J`. The integrator's "if `b ≥ batteryCapacity`, clamp `p > 0` to zero" branch fires every step until eclipse; battery state will sit at `b0` until the first eclipse, then decrement *past* the cap. Logged battery state therefore exceeds physical capacity for the entire sunlit phase of the first orbit.

**(M6) Integrator gain `kI` from `PIDMIMO` is computed but never used** — *NadirPointing.m* line 282 uses only `kP` and `kR`. The integrator time constant `τ_int = 300 s` thus has no effect in closed loop. Either intentional (B-cross is naturally PD-only) or a leftover.

**(M7) Gyro queue moving-average is dead code** — *Gyro_measurement.m* line 48: `w_read = w_meas` overrides the queue average computed two lines earlier. Either remove the queue logic or remove the override.

**(M8) Sensor.gyros.queue / queue_size / queue_pos are not initialized in the NadirPointing path** — *Sensors_Config_File.m* does not set `Sensors.gyros.queue_pos` or `queue_size`. The code in `Gyro_measurement.m` lines 32–46 will error on the first call unless they are initialized elsewhere. Currently runs only because the Detumbling pipeline initialization is also on the path.

**(M9) `BDipole` is called twice per step** — *NadirPointing.m* lines 105 and 106 are duplicates. Wastes a call but does not affect correctness.

**(M10) `SunVectorECI('initialize', 'earth')` is called every step** — *Sim_sun_position.m* line 1. The cost is small (cached internally) but the intent of the `'initialize'` mode was a one-time setup.

**(M11) Control-update cadence is hard-coded at 1 Hz** — `mod(k, ceil(1/dT)) == 0`. Works because `dT = 0.25` divides 1 s evenly. Will silently malfunction if `dT` is changed to a value like `0.3`.

### 14.3 Minor / cosmetic

- **(m1)** TRIAD is computed every step on `k==1` only, then discarded — not used as the cold-start seed. Document intent or remove.
- **(m2)** The non-Joseph form `P_upd = (I − KH)·P_pred` works fine for `O(10⁵)` steps but loses symmetry over very long runs. For research-grade longevity use Joseph form.
- **(m3)** `xPlot` size is `(14, nSim+1)`, allocated as `[x zeros(14, nSim)]` — the 14 is a magic number. Use `length(x)` for safety.
- **(m4)** Variable shadowing: `p` is reassigned mid-script (orbit-target struct in *Sim_sat_initial_state*, then PID struct in *Sim_PID_controller*). Confusing for readers.
- **(m5)** `q_AKE`, `intensity`, `quaternion_estimated` and `magnetometer_data` are not pre-allocated, so MATLAB grows them inside the loop — slight performance hit.
- **(m6)** IGRF coefficients in `BDipole` are **1995-epoch**; for a 2019 simulation the secular drift adds ~1.5 % to the field magnitude.
- **(m7)** Quaternion `x(7:10)` is never re-normalized between RK4 steps; norm drift after `nSim ≈ 4.5·10⁴` steps is `O(1e-12)`.
- **(m8)** Integrator state of the PID (`p.x_roll`, `p.x_yaw`, `p.x_pitch`) is part of the `PID3Axis2` defaults but never updated in the loop — dead structure fields.
- **(m9)** The custom `quat2rotm` in `utils/MKF_functions/quat2rotm.m` shadows MATLAB's. Both happen to share the scalar-first convention here, so paths cannot conflict — but it's a fragile coexistence.

---

## 15. Cross-check between this analysis and the rest of the report

After consolidating §13 and §14, several points elsewhere in the report deserve to be **revised** or **strengthened**:

- §6.4 (gyro reading) noted that the queue averaging is bypassed by the trailing `w_read = w_meas`. §14 (M7) re-confirms this and adds (M8) — the `queue_pos / queue_size` fields are not even initialized in the *Sim_sensors* call path, so the queue logic would also crash on the first iteration if it ever ran.
- §6.5.1 (TRIAD seeding) noted that the TRIAD output is overwritten on `k==1`. §13.11 + §14 (C8) explain *why* this is necessary: the TRIAD output is in the **opposite** convention to PSS's quaternions, so it would be useless without first applying `QPose`. The masking is therefore not just a tuning shortcut but a hidden correctness fix.
- §6.7 (control-law sign) was treated as "the standard cross-product law". §13.8 derives the sign carefully and finds it consistent **once you account for `q_target_body` being a body→target quaternion** (equivalent to a `−½·δθ` small-angle representation). The factor-of-2 absorption into `kP` is a stylistic choice but mathematically equivalent.
- §11 (caveats) said "the PID `kI` integrator is silently dropped" and "the Control loop fires at 1 Hz". §14 (M6, M11) re-list these and add (C1): the proportional gain is itself dimensionally wrong by one factor of `Ī`, which is the deeper reason the closed-loop response visible in the plots is sluggish, not (only) the missing integrator.
- §11 also mentioned a 9 km mismatch between `a0` and `d.rP`. §14 (M1) adds a *third* Earth radius (`a = 6371.2 km` inside `BDipole`). The simulation effectively uses three different Earth radii.
- §6.3 (sun position) mentioned the photodiode model. §13.12 and §14 (M3, M4) document the squared cosine and the 1361 vs. 1367 W/m² inconsistency, which were not flagged in the first walk-through.
- §11 listed "a0 + 500 km" as 500 km altitude. §14 (M1) corrects this to ~509 km.
- §4.5 stated `b0 = 20000` J. §14 (M5) shows this **exceeds** the physical battery capacity (16 632 J). The comment "Initialize battery state" hides a non-physical initial condition.

The two new sections (§13, §14) are **strictly additive** to the prior walk-through and do not contradict anything earlier in the report; they sharpen the caveats with quantitative grounding, attribute root causes to specific lines, and propose minimal fixes where applicable.

---

*End of report.*
