# Primitives & Components

## unknown

### contTap
- kind: `primitive`
- file: `base\contTap.v`
- ports:
  - `trig` (input, 1)
  - `req` (output, 1)
  - `rstn` (input, 1)
- deps_primitives:
- tech_cells:
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### delay1U
- kind: `primitive`
- file: `base\delay1U.v`
- ports:
  - `inR` (input, 1)
  - `outR` (output, 1)
  - `rstn` (input, 1)
- deps_primitives:
- tech_cells:
  - `CLKAND2V3_140P9T35R`
  - `DEL1V4_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### eventSink
- kind: `primitive`
- file: `base\eventSink.v`
- ports:
  - `i_drive` (input, 1)
  - `o_free` (output, 1)
  - `rstn` (input, 1)
- deps_primitives:
  - `delay1U`
- tech_cells:
- reset: present=True, signal=rstn, active_low=True

### eventSource
- kind: `primitive`
- file: `base\eventSource.v`
- ports:
  - `switch` (input, 1)
  - `fire` (output, 1)
  - `rstn` (input, 1)
- deps_primitives:
  - `delay1U`
- tech_cells:
  - `CLKAND2V1_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### freeSetDelay
- kind: `primitive`
- file: `base\freeSetDelay.v`
- ports:
  - `DELAY_UNIT_NUM` (unknown, 1)
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

### pmtRelay
- kind: `primitive`
- file: `base\pmtRelay.v`
- ports:
  - `inR` (input, 1)
  - `inA` (output, 1)
  - `outR` (output, 1)
  - `outA` (input, 1)
  - `pmt` (input, 1)
  - `fire` (output, 1)
  - `rstn` (input, 1)
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

### receiver
- kind: `primitive`
- file: `base\receiver.v`
- ports:
  - `inR` (input, 1)
  - `inA` (output, 1)
  - `i_free` (input, 1)
  - `rstn` (input, 1)
- deps_primitives:
- tech_cells:
  - `DRNQV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True

### relay
- kind: `primitive`
- file: `base\relay.v`
- ports:
  - `inR` (input, 1)
  - `inA` (output, 1)
  - `outR` (output, 1)
  - `outA` (input, 1)
  - `fire` (output, 1)
  - `rstn` (input, 1)
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
- file: `base\sender.v`
- ports:
  - `i_drive` (input, 1)
  - `o_free` (output, 1)
  - `outR` (output, 1)
  - `i_free` (input, 1)
  - `rstn` (input, 1)
- deps_primitives:
- tech_cells:
  - `DEL1V4_140P9T35R`
  - `DRNQV2_140P9T35R`
  - `INV2_140P9T35R`
- reset: present=True, signal=rstn, active_low=True
