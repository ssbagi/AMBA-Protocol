# AXI Interconnect Protocol

The following content is taken from "Fundamentals of System-on-Chip Design". 
There are different version of AXI Protocol :
- AXI            : High Performance protocol designed for high-throughput device.
- AXI4 - Stream  : The master initiates data transfers, and the slave receives them. High-speed, point-to-point data streaming without handshaking overhead like in AXI memory-mapped protocols.
- AXI4 - Lite    : A lighter version used for Low-throughput device. It's equivalent to APB Protocol. 

## AHB-Lite Performance Bottlenecks
The following bottlenecks have been taken care by AXI Protocol. 
- Transfer Reordering
- Transparent Interconnect Pipelining
- Unaligned Transfers
- Simultaneous Read and Write Transfers



