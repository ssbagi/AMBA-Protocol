# AXI Assertions
This document outlines the AXI Channels and their associated assertions or rules to avoid deadlocks or errors, using Formal Verification techniques such as SVA (SystemVerilog Assertions) and property-based checks.

## Write Channel
Note: The first two assertions in almost all AW Channel signals are the same. These can be combined into a single assertion.

### Write Address Channel (AW Channel)

#### AWID
- AWID remains stable when AWVALID = 1 and AWREADY = 0.
- AWID must be in a known state when AWVALID = 1.
#### AWADDR
- AWADDR remains stable when AWVALID = 1 and AWREADY = 0.
- AWADDR must be in a known state when AWVALID = 1.
- A write burst cannot cross a 4KB boundary.
- A write transaction with wrap must have an aligned address.
#### AWLEN
- AWLEN remains stable when AWVALID = 1 and AWREADY = 0.
- AWLEN must be in a known state when AWVALID = 1.
- A write transaction with burst type WRAP must have a length of 2, 4, 8, or 16.
#### AWSIZE
- AWSIZE remains stable when AWVALID = 1 and AWREADY = 0.
- AWSIZE must be in a known state when AWVALID = 1.
- AWSIZE must not exceed the bus width of the data interface.
#### AWBURST
- AWBURST remains stable when AWVALID = 1 and AWREADY = 0.
- AWBURST must be in a known state when AWVALID = 1.
- AWBURST should not have 2’b11 when AWVALID = 1.
#### AWLOCK
- AWLOCK remains stable when AWVALID = 1 and AWREADY = 0.
- AWLOCK must be in a known state when AWVALID = 1.
#### AWCACHE
- AWCACHE remains stable when AWVALID = 1 and AWREADY = 0.
- If AWVALID = 1 → AWCACHE[1] = 0 (Cacheable or Modifiable bit), then AWCACHE[3:2] must be 0.
- AWCACHE must be in a known state when AWVALID = 1.
#### AWVALID
- AXI4 supports asynchronous reset assertion and synchronous deassertion.
- AWVALID = 0 for the first cycle when ARESETn = 1.
- AWVALID = 1 must remain HIGH until AWREADY = 1.
- AWVALID cannot be in X state when ARESETn = 1, except in Reset mode.
#### AWREADY
- AWREADY must be asserted within MAXWAITS cycles of AWVALID being asserted.
#### AWUSER
- AWUSER remains stable when AWVALID = 1 and AWREADY = 0.
- AWUSER must be in a known state when AWVALID = 1.
#### AWQOS
- AWQOS remains stable when AWVALID = 1 and AWREADY = 0.
- AWQOS must be in a known state when AWVALID = 1.
#### AWREGION
- AWREGION remains stable when AWVALID = 1 and AWREADY = 0.
- AWREGION must be in a known state when AWVALID = 1.
#### AWLEN
- If BURST = 2’b00 (FIXED), cannot exceed 16 beats.
- Exclusive transactions cannot have a length greater than 16 beats.
#### AWUSER
- Stable when AWUSER_WIDTH = 0.
#### AWID
- Stable when ID_WIDTH = 0.

### Write Data Channel (W Channel)

#### WDATA
- WDATA remains stable when WVALID = 1 and WREADY = 0.
- WDATA must be in a known state when WVALID = 1.
#### WSTRB
- WSTRB remains stable when WVALID = 1 and WREADY = 0.
- WSTRB must be in a known state when WVALID = 1.
#### WLAST
- WLAST remains stable when WVALID = 1 and WREADY = 0.
- WLAST must be in a known state when WVALID = 1.
#### WVALID
- WVALID = 0 for the first cycle after ARESETn goes HIGH.
- If WVALID = 1, it must remain asserted until WREADY = 1.
- WVALID must be in a known state when not in reset condition.
#### WREADY
- WREADY must be asserted within MAXWAITS cycles of WVALID being asserted.
- WREADY must be in a known state when not in reset condition.
#### WUSER
- Not implemented in the VIP being used.

### Response Channel (B Channel)

#### BID
- BID remains stable when BVALID = 1 and BREADY = 0.
- BID must be in a known state when BVALID = 1.
#### BRESP
- An EXOKAY write response can only be given to an exclusive write access.
- BRESP remains stable when BVALID = 1 and BREADY = 0.
- BRESP must be in a known state when BVALID = 1.
- A slave must not take BVALID HIGH until after the write address is handshaken.
- A slave must not take BVALID HIGH until after the last write data is handshaken.
#### BVALID
- BVALID = LOW for the first cycle after ARESETn goes HIGH.
- When BVALID is asserted, it must remain asserted until BREADY = HIGH.
- BVALID must be in a known state when not in ARESETn.
#### BREADY
- BREADY must be asserted within MAXWAITS cycles of BVALID being asserted.
- A value of X on BREADY is not permitted when not in reset.

## Read Channel

### Read Address Channel (AR Channel)
#### ARID
- ARID remains stable when ARVALID = 1 and ARREADY = 0.
- ARID must be in a known state when ARVALID = 1.
#### ARADDR
- ARADDR remains stable when ARVALID = 1 and ARREADY = 0.
- ARADDR must be in a known state when ARVALID = 1.
- Read bursts cannot cross a 4KB boundary.
- A read transaction with burst type WRAP must have an aligned address.
#### ARLEN
- ARLEN remains stable when ARVALID = 1 and ARREADY = 0.
- A read transaction with burst type WRAP must have a length of 2, 4, 8, or 16.
- A value of X on ARLEN is not permitted when ARVALID = 1.
- Transactions of burst type FIXED cannot have a length greater than 16 beats.
#### ARSIZE
- The size of a read transfer must not exceed the width of the data interface.
- ARSIZE remains stable when ARVALID = 1 and ARREADY = 0.
- A value of X on ARSIZE is not permitted when ARVALID = 1.
#### ARBURST
- A value of 2’b11 on ARBURST is not permitted when ARVALID = 1.
- ARBURST remains stable when ARVALID = 1 and ARREADY = 0.
- A value of X on ARBURST is not permitted when ARVALID = 1.
#### ARLOCK, ARCACHE, ARPROT
- Not implemented in the VIP being used.
#### ARVALID
- ARVALID = LOW for the first cycle after ARESETn goes HIGH.
- When ARVALID is asserted, it must remain asserted until ARREADY = HIGH.
#### ARREADY
- A value of X on ARREADY is not permitted when not in reset.
- Recommended that ARREADY is asserted within MAXWAITS cycles of ARVALID being asserted.
- ARUSER remains stable when ARVALID = 1 and ARREADY = 0.
#### ARUSER, ARQOS, ARREGION
- Not implemented in the VIP being used.

### Read Data Channel (R Channel)
#### RID
- Read data must always follow the address it relates to.
- RID remains stable when RVALID = 1 and RREADY = 0.
- A value of X on RID is not permitted when RVALID = 1.
#### RDATA
- RDATA remains stable when RVALID = 1 and RREADY = 0.
- A value of X on valid byte lanes of RDATA is not permitted when RVALID = 1.
#### RRESP
- RRESP remains stable when RVALID = 1 and RREADY = 0.
- A value of X on RRESP is not permitted when RVALID = 1.
#### RLAST
- RLAST remains stable when RVALID = 1 and RREADY = 0.
- A value of X on RLAST is not permitted when RVALID = 1.
#### RVALID
- RVALID = LOW for the first cycle after ARESETn goes HIGH.
- When RVALID is asserted, it must remain asserted until RREADY = HIGH.
- A value of X on RVALID is not permitted when not in reset.
#### RREADY
- A value of X on RREADY is not permitted when not in reset.
- A value of X on RUSER is not permitted when RVALID = 1.
#### RUSER
- Not implemented in the VIP being used.


## Conclusion
This document provides AXI verification guidelines based on assertions and formal verification checks using SVA and property-based methods. 
It ensures deadlock avoidance and error prevention across various AXI write and read channels.


## Assertions Generation
The Assertions generated for above rules is as follows : 










