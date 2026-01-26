# Primitives & Components

## base_pipeline

### cFifo1
- kind: `component`
- file: `cFifo1.v`
- ports:
  - `i_drive` (unknown, null)
  - `i_freeNext` (unknown, null)
  - `o_free` (unknown, null)
  - `o_driveNext` (unknown, null)
  - `o_fire_1` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
  - `receiver`
  - `relay`
  - `sender`
- tech_cells:
- reset: present=True, signal=rstn, active_low=True

### cPmtFifo1
- kind: `component`
- file: `cPmtFifo1.v`
- ports:
  - `i_drive` (unknown, null)
  - `i_freeNext` (unknown, null)
  - `o_free` (unknown, null)
  - `o_driveNext` (unknown, null)
  - `o_fire_1` (unknown, null)
  - `rstn` (unknown, null)
  - `pmt` (unknown, null)
- deps_primitives:
  - `pmtRelay`
  - `receiver`
  - `relay`
  - `sender`
- tech_cells:
- reset: present=True, signal=rstn, active_low=True

## delay

### delay1U
- kind: `primitive`
- file: `delay1U.v`
- ports:
  - `inR` (unknown, null)
  - `outR` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `CLKAND2V3_140P9T35R`
  - `DEL1V4_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### freeSetDelay
- kind: `primitive`
- file: `freeSetDelay.v`
- ports:
  - `DELAY_UNIT_NUM` (unknown, null)
- deps_primitives:
  - `delay1U`
- tech_cells:
  - `BUFV2_140P9T35R`
  - `CLKAND2V3_140P9T35R`
  - `DEL1V4_140P9T35R`
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
  - `XOR2V2_140P9T35R`
  - `generate`
- reset: present=False, signal=None, active_low=None

## event

### eventSink
- kind: `primitive`
- file: `eventSink.v`
- ports:
  - `i_drive` (unknown, null)
  - `o_free` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
  - `delay1U`
- tech_cells:
- reset: present=True, signal=rstn, active_low=True

### eventSource
- kind: `primitive`
- file: `eventSource.v`
- ports:
  - `switch` (unknown, null)
  - `fire` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
  - `delay1U`
- tech_cells:
  - `CLKAND2V1_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

## handshake_relay

### pmtRelay
- kind: `primitive`
- file: `pmtRelay.v`
- ports:
  - `inR` (unknown, null)
  - `inA` (unknown, null)
  - `outR` (unknown, null)
  - `outA` (unknown, null)
  - `pmt` (unknown, null)
  - `fire` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `BUFV2_140P9T35R`
  - `CLKAND2V3_140P9T35R`
  - `DEL1V4_140P9T35R`
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
  - `XNOR2V2_140P9T35R`
  - `XOR2V2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

## toggle

### contTap
- kind: `primitive`
- file: `contTap.v`
- ports:
  - `trig` (unknown, null)
  - `req` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

## unknown

### receiver
- kind: `primitive`
- file: `receiver.v`
- ports:
  - `inR` (unknown, null)
  - `inA` (unknown, null)
  - `i_free` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `DRNQV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### relay
- kind: `primitive`
- file: `relay.v`
- ports:
  - `inR` (unknown, null)
  - `inA` (unknown, null)
  - `outR` (unknown, null)
  - `outA` (unknown, null)
  - `fire` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `BUFV2_140P9T35R`
  - `CLKAND2V3_140P9T35R`
  - `DEL1V4_140P9T35R`
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
  - `XNOR2V2_140P9T35R`
  - `XOR2V2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### sender
- kind: `primitive`
- file: `sender.v`
- ports:
  - `i_drive` (unknown, null)
  - `o_free` (unknown, null)
  - `outR` (unknown, null)
  - `i_free` (unknown, null)
  - `rstn` (unknown, null)
- deps_primitives:
- tech_cells:
  - `DEL1V4_140P9T35R`
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True
