interface axi(input bit ACLK);

  //write_address_channel
  logic [3:0] AWID;    
  logic [31:0] AWADDR;
  logic [3:0] AWLEN;
  logic [2:0] AWSIZE;
  logic [1:0] AWBURST;
  logic AWVALID,AWREADY;

  //write_data channel
  logic [3:0] WID;
  logic [31:0]WDATA;
  logic [3:0]WSTRB;
  logic WREADY,WLAST,WVALID;

  //write_response channel
  logic [3:0] BID;
  logic [1:0] BRESP;
  logic BVALID,BREADY;

  //read_address_channel
  logic [3:0] ARID;
  logic [31:0] ARADDR;
  logic [3:0] ARLEN;
  logic [2:0] ARSIZE;
  logic [1:0] ARBURST;
  logic ARVALID,ARREADY;

  //read_data/response channel
  logic [3:0] RID;
  logic [31:0]RDATA;
  logic [1:0] RRESP;
  logic RREADY,RLAST,RVALID;

  /*
  -----------------------------------------------------------------------------------------------------
  ------------------------ ASSERTIONS : AXI Protocol Verification --------------------------------------
  ------------------------ System Verilog Assertions (SVA) ---------------------------------------------
  Noting down few points : 
  |->       :: Overlapping Assertion on same clk edge.
  |=>       :: Non-Overlapping Assertion. The check happens on next clk edge [ |-> #1  ------> |=> ].
  
  Go to Repetition
  [->n]                     :: Event must happen exactly n cycles later. Event match the number of times specified not necessarily on continuous clock cycles.
  a |-> ##1 b[->3] ##1 c;   :: The signal “a” is high on given posedge of the clock, the signal “b” should be high for 3 clock cycles followed by “c” should be high after ”b” is high for the third time.
  
  
  Repetiton Operator
  [*n]              :: signal [*n] or sequence [*n]. "n" is the number of repetitions.
  a |-> ##1 b[*3];  :: The signal “a” is high on given posedge of the clock, the signal “b” should be high for 3 consecutive clock cycles.
  
  Nonconsecutive repetition
  signal [=n]       :: It does not require that the last match on the signal repetition happens in the clock cycle before the end of the entire sequence matching.
  
  AXI Rules Links :
  1. ARM : https://developer.arm.com/documentation/dui0534/b/Protocol-Assertions-Descriptions/AXI4-and-AXI4-Lite-protocol-assertion-descriptions/Write-address-channel-checks?lang=en
  2. AMD : https://docs.amd.com/r/en-US/pg101-axi-protocol-checker/AXI-Protocol-Checks-and-Descriptions
  ------------------------------------------------------------------------------------------------
  */

  // Address Write Channel Assertions.

sequence awid_stable
	$stable(awid_stable)
endsequence
  
property awid_stable_prop;
	@(posedge clk) AWVALID && !AWREADY |=> awid_stable until AWREADY[->1];
endproperty;

AWID_STABLE : assert property(awid_stable_prop) else $error(“ AWID is not in stable state”);

// AWADDR remains stable when AWVALID = 1 and AWREADY = 0
sequence awaddr_stable;
  $stable(AWADDR);
endsequence

property awaddr_stable_prop;
  @(posedge clk) AWVALID && !AWREADY |=> awaddr_stable until AWREADY[->1];
endproperty

AWADDR_STABLE : assert property (awaddr_stable_prop) else $error("AWADDR is not in a stable state when AWVALID = 1 and AWREADY = 0");

// AWLEN remains stable when AWVALID = 1 and AWREADY = 0
sequence awlen_stable;
  $stable(AWLEN);
endsequence

property awlen_stable_prop;
  @(posedge clk) AWVALID && !AWREADY |=> awlen_stable until AWREADY[->1];
endproperty

AWLEN_STABLE : assert property (awlen_stable_prop) else $error("AWLEN is not in a stable state when AWVALID = 1 and AWREADY = 0");

// AWSIZE remains stable when AWVALID = 1 and AWREADY = 0
sequence awsize_stable;
  $stable(AWSIZE);
endsequence

property awsize_stable_prop;
  @(posedge clk) AWVALID && !AWREADY |=> awsize_stable until AWREADY[->1];
endproperty

AWSIZE_STABLE : assert property (awsize_stable_prop) else $error("AWSIZE is not in a stable state when AWVALID = 1 and AWREADY = 0");

// AWBURST remains stable when AWVALID = 1 and AWREADY = 0
sequence awburst_stable;
  $stable(AWBURST);
endsequence

property awburst_stable_prop;
  @(posedge clk) AWVALID && !AWREADY |=> awburst_stable until AWREADY[->1];
endproperty

AWBURST_STABLE : assert property (awburst_stable_prop) else $error("AWBURST is not in a stable state when AWVALID = 1 and AWREADY = 0");

// AWID must be in a known state when AWVALID = 1
property awid_known;
  @(posedge clk) AWVALID |-> !$isunknown(AWID);
endproperty

AWID_IS_KNOWN : assert property (awid_known) else $error("AWID is in an unknown state when AWVALID = 1");

// AWADDR must be in a known state when AWVALID = 1
property awaddr_known;
  @(posedge clk) AWVALID |-> !$isunknown(AWADDR);
endproperty

AWADDR_IS_KNOWN : assert property (awaddr_known) else $error("AWADDR is in an unknown state when AWVALID = 1");

// AWLEN must be in a known state when AWVALID = 1
property awlen_known;
  @(posedge clk) AWVALID |-> !$isunknown(AWLEN);
endproperty

AWLEN_IS_KNOWN : assert property (awlen_known) else $error("AWLEN is in an unknown state when AWVALID = 1");

// AWSIZE must be in a known state when AWVALID = 1
property awsize_known;
  @(posedge clk) AWVALID |-> !$isunknown(AWSIZE);
endproperty

AWSIZE_IS_KNOWN : assert property (awsize_known) else $error("AWSIZE is in an unknown state when AWVALID = 1");

// AWBURST must be in a known state when AWVALID = 1
property awburst_known;
  @(posedge clk) AWVALID |-> !$isunknown(AWBURST);
endproperty

AWBURST_IS_KNOWN : assert property (awburst_known) else $error("AWBURST is in an unknown state when AWVALID = 1");

property write_burst_4kb_boundary;
  @(posedge clk) AWVALID |-> ((AWADDR & 12'hFFF) + (AWLEN * (1 << AWSIZE))) <= 12'hFFF;
endproperty

WRITE_BURST_BOUNDARY : assert property (write_burst_4kb_boundary) else $error("Write burst crosses the 4KB boundary!");

property write_wrap_aligned_address;
  @(posedge clk) AWVALID |-> (AWBURST == 2'b10) |-> (AWADDR % (1 << AWSIZE) == 0);
endproperty

WRITE_WRAP_ALIGNMENT : assert property (write_wrap_aligned_address) else $error("Write transaction with WRAP burst has an unaligned address!");

sequence seq_wrap_burst_len;
  (AWLEN == 2) || (AWLEN == 4) || (AWLEN == 8) || (AWLEN == 16);
endsequence

property wrap_burst_transaction;
  @(posedge clk) AWBURST == 2'b10 |-> seq_wrap_burst_len;
endproperty

WRITE_WRAP_BURST_LENGTH : assert property (wrap_burst_transaction) else $error("Write transaction with WRAP burst does not have a valid length (2, 4, 8, or 16)!");

property awsize_check_property;
  @(posedge clk) AWVALID |-> (AWSIZE < bus_width);
endproperty

AWSIZE_CHECK : assert property (awsize_check_property) else $error("AWSIZE exceeds the bus width of the data interface!");

property awburst_reserved;
	@(posedge clk) AWVALID |-> (AWBURST != 2’b11) 
endproperty
AWBURST_RESERVED_ASSERTED : assert property (awburst_reserved) $else $error(“ AWBURST is in Reserved State”);

property awvalid_first_cycle_low;
  @(posedge clk) (ARESETn == 1) ##0 (ARESETn == 1) |-> (AWVALID == 0);
endproperty

AWVALID_FIRST_CYCLE_LOW : assert property (awvalid_first_cycle_low) else $error("AWVALID is not LOW on the first cycle after ARESETn = 1!");

property awvalid_hold_until_awready;
  @(posedge clk) AWVALID |=> AWVALID until AWREADY;
endproperty

AWVALID_HOLD_UNTIL_AWREADY : assert property (awvalid_hold_until_awready) else $error("AWVALID did not remain HIGH until AWREADY = 1!");

property awvalid_known_when_resetn_high;
  @(posedge clk) (ARESETn == 1) |-> !$isunknown(AWVALID);
endproperty

AWVALID_KNOWN_STATE : assert property (awvalid_known_when_resetn_high) else $error("AWVALID is in an unknown (X) state when ARESETn = 1!");

property awready_within_maxwaits;
  @(posedge clk) AWVALID |=> AWREADY [->16];
endproperty

AWREADY_ASSERTION : assert property (awready_within_maxwaits) else $error("AWREADY was not asserted within MAXWAITS (16 cycles) after AWVALID!");

property fixed_burst_length_check;
  @(posedge clk) (AWBURST == 2'b00) |-> (AWLEN < 16);
endproperty

FIXED_BURST_LENGTH : assert property (fixed_burst_length_check) else $error("AWLEN exceeds 16 beats for a FIXED burst type!");

// Update rest of them similarly next.
  
// W  : Write Data Channel

// B  : Write Response Channel

// AR : Read Address Channel

// R  : Read Data Channel

  
endinterface

module axi_asertion_standalone_check;
  bit ACLK;
  
  axi intf (ACLK);

  initial begin
    ACLK = 0;
  end

  always #5 ACLK = ~ACLK;

  //Normal Verilog Tetscases Generation or Use UVM Method to Verify like APB Infrastructure Way of execution. 
  
endmodule  






