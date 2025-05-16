![image](https://github.com/user-attachments/assets/4b270bda-28ec-4f5f-a86c-e23faf8ae188)# AHB

The Widely accepted AMBA AHB Protocol. The content is taken from the ARM Documentation.

Reference Link :
- https://developer.arm.com/documentation/ihi0033/c
- https://www.arm.com/resources/education/books/fundamentals-soc

## AHB Protocol Introduction 
AMBA AHB is a bus interface suitable for high-performance synthesizable designs. It defines the interface between components, such as Managers, interconnects, and Subordinates.
The most common AHB Subordinates are internal memory devices, external memory interfaces, and high-bandwidth peripherals. 

The AMBA AHB is avialbale with two versions :
- AHB Full  : Supports multiple masters and includes arbitration, bus request, and stall features. It allows for more complex system designs where multiple masters need to communicate efficiently.
- AHB Lite  : Designed for simpler systems with a single master. It removes arbitration and bus request signals, making it more streamlined and efficient for straightforward designs.

The most common AHB-Lite completers are high-bandwidth peripherals such as DMA engines and internal or external memory, whereas typical APB completers are peripherals such as timers, GPIO controllers, and I2C controllers.

The AHB protocol features are :
- Burst transfers
- Single clock-edge operation
- Non-tristate implementation
- Configurable data bus widths
- Configurable address bus widths


The low-bandwidth peripherals use AMBA Advanced Peripheral Bus (APB). Bridging between the higher performance AHB and APB is done using an AHB Subordinate, known as an APB bridge.
An overview of how such a combined AHB-Lite/APB system might appear, with interfaces depicted in pink being high-bandwidth components that use the AHB-Lite protocol, and interfaces colored green being low-bandwidth components that use the APB protocol. 
![image](https://github.com/user-attachments/assets/245bb2cb-8c96-4ba6-aa0a-973607a87e38)

## AHB-Lite Interconnect Protocol
- The AHB-Lite provides an alternative solution to the bus utilization by allowing managers to issue bus operations in a **pipelined** fashion. The address phase and data phase are able to be overlapped and back-to-back reads are possible.
-  The use of wide data buses to increase bandwidth beyond what is achievable through increased bus utilization alone.

## AHB-Lite Signals

![image](https://github.com/user-attachments/assets/2b6e3315-4395-42a1-9d71-82ae1a9fef59)

## High Level overview

![image](https://github.com/user-attachments/assets/46e10533-3126-406f-8e11-26e6f845c030)

![image](https://github.com/user-attachments/assets/c27c39bf-a831-463d-8bcc-2fda88780247)

The following conculsions can be made :
- The AHB-Lite is single requestor (One Master) design. It consits of one address decoder and one multiplexer in the system.
- The AHB-Lite has dedicated wiring channels between Manager and subordinates.
- The AHB-Lite manager broadcasts its outgoing signals to all subordinates, every subordinate effectively sees all operations on the bus. The subordinates are designed to only sample the manager’s control signals when their own decoder-generated subordinate-select signal, HSELx, is active.
- The only control-related subordinate-to-manager signals are HREADYOUT and HRESP. HREADYOUT is used to apply subordinate-side backpressure in AHB-Lite and is provided to the manager by the multiplexer through the HREADY signal.
- The HREADY is broadcast to both the manager and the subordinates. Because this backpressure signal is shared by all subordinates and the manager only sees a single HREADY signal, it means that a new bus operation cannot begin until the previous operation (to any other subordinate) has finished.


## Basic Operations
- In the below Figure we observe the bus communication is pipelined and the address phase of the current transfer therefore overlaps with the data phase of the previous transfer. The descriptions of the address and data phases given above imply that only the data phase can be stalled. 
- The address phase of the current transfer overlaps the data phase of the previous one, the net result is that the current transfer’s address phase stalls if the previous transfer’s data phase stalls.
- The pipelined nature of the communication protocol, the data phases are always one clock cycle behind their corresponding address phases, and the five-word transfer of our example therefore takes a total of six clock cycles from start to finish.

![image](https://github.com/user-attachments/assets/1cedb3f2-365b-440e-866b-1574439048d2)

- HWRITE = 0 ----> READ and HWRITE = 1 ----> WRITE

![image](https://github.com/user-attachments/assets/cd4875e7-4b2c-4b54-90ac-d1a20ba44039)

## HTRANS
HTRANS is a 2-bit signal sent from the manager to the subordinate to indicate the type of transfer being requested.

![image](https://github.com/user-attachments/assets/f7d357ba-5426-4538-af01-ddcb8b3ed28f)

- AHB-Lite idle transfers through HTRANS signal. The HTRANS = 2'b00.
- The manager no longer wishes to write or read to the subordinate at this point and therefore starts the address phase of the next transfer by sending IDLE on the HTRANS bus.
- The subordinate then effectively ignores the HADDR and HWRITE signals upon seeing this IDLE signal. This concludes the address phase of the third transfer, a transfer during which no data will be exchanged.
- At this point the manager wishes to perform another read transfer and therefore starts the address phase of a new transfer (to address 0x0) by deasserting HWRITE and driving HTRANS to NONSEQ.
![image](https://github.com/user-attachments/assets/0f86cf63-d285-4e7d-86a0-08da2da4d8d3)

## Transfer-specific Data Widths
- HSIZE = 3bit. The size of a single transfer in bytes.
- The HSIZE is driven by manager/master/requestor during the address phase of a transfer to indicate how many bits transmitted on the data buses must be sampled or returned by slave/subordinate/completer.

![image](https://github.com/user-attachments/assets/07eb2d76-f2de-4bd5-a2ca-703feac84492)
  
- A manager can only stipulate a transfer size that is less than or equal to the native width of its data bus, because larger transfers (obviously) wouldn’t physically fit on the bus.
- 2^(HSIZE) <= Physical Bus Width.
- If the Physical Bus Width = 64bit (8B). The HSIZE value allowed is 0,1,2,3. The allowed transfer size is 1B, 2B, 4B and 8B. 

In below example waveform of a how a manager with a 64-bit data bus can use the HSIZE bus to write a total of 21 bytes of data to a subordinate. 
![image](https://github.com/user-attachments/assets/2146f1d1-0d3b-4417-b2a6-44997431f465)

## Bursts
- HBURST = 3bit.
- The mechanism for a series of bus transfers with consecutive addresses that is used to reduce the overhead of transmitting an individual address on the bus for every one of these back-to-back transfers.
- This reduces the address transmission overhead and increase the bus utilization.
- Beat : Individual bus transfer.

![image](https://github.com/user-attachments/assets/9d16d431-3eb4-4b66-873c-d4ac4f839445)

- In general there are two types of burst transfer Incrementing and Wrapping type.
![image](https://github.com/user-attachments/assets/516bfbfe-6fbc-48b6-a3c1-adf2564e52f8)


## Data Transfer
- The total amount of data transferred in a burst defined by multiplying the HSIZE(data size of each transfer) * HBURST(No. of beats).

## Incrementing Burst
- The first transfer is NONSEQ and follwed SEQ and then IDLE at end.
- The next address calculation happens inside the slave/completer side. Next Address = Address(Previous) + HSIZE. The succesive beats use this address.

![image](https://github.com/user-attachments/assets/7ef29907-e23e-444a-b7ab-5ca0bf7ee71a)

From above Figure the following conclusion can be made : 
- Time T1 to T5. The address generated from T1 to T4 are 0x8, 0xC, 0x10 and 0x14. The read response comes from T2 to T5.

## Wrapping Burst
- As we all know that CPU interfaces with a highspeed internal cache (local copy of frequently accessed memory) and only “interacts” with memory (also mediated via the cache) when this cache does not contain the requested data.
- The CPU generates the target address (LD/STR opcode) and a cache(L1 Data cache) miss ocurrs then cache (L1 Data cache) then fetches from L2 if not present goes to System Level (L3 or LLCC) or at the end from Main Memory. At the end returns specific word within the line that was requested by the CPU.
- **Why is it advatageous ?**
  - Assume the cache line = 16-words wide and its uses Incrementing burst to fetch the data from memory in order from word 0 to 15.
  - The CPU want to read the last word i.e., Word 15 so, now the CPU has to wait till the transfer from Word 0 to Word 15 is done. Then the Word 15 is transferred. A long wait time is present.
  - The wrapping burst first transfers the "critical-word-first" cache-fill scheme. The remaining transfers in the wrapping burst then take care of filling up the rest of the cache line.

![image](https://github.com/user-attachments/assets/aa141385-3849-4a80-8f79-fdd7d5066ac7)

## Streaming Workload
- The incrementing bursts of undefined length. The workload where the manager does not know the amount of data that is to be read or written in advance.
- The Master/Manager must drive HBURST to INCR type (HBURST = 3'b001).
- The Manager can stop undefined length bursts by sending IDLE or NONSEQ. 

In below figure we have two patterns for the undefined length burst type to transfer the single beat bursts :
- The issue of SINGLE on HBURST and NONSEQ on HTRANS.
- The issue INCR on HBURST, NONSEQ on HTRANS, and terminating the undefined-length burst after one transfer.
![image](https://github.com/user-attachments/assets/4238527b-7885-471c-939c-13aa79da49b1)


## Backpressure
- The backpressure mechanism allows either endpoint to handle occasional throughput mismatches by stalling the other.
- The support of bidirectional backpresurre
  - HREADY : From Slave to Master.
  - HTRANS : From Master to Slave. (The 2'b01 : BUSY state signals the slave to stop). Insertion of Idle cycles.

### Subordinate side Backpressure
- The Subordiante/Slave has the control over the data phase stalling.  
- During a data phase, subordinates can deassert HREADY to insert wait states if they require more time to respond to a transfer, with the address phase of the next transfer only accepted when HREADY is high again.

### Manger side Backpressure
- Which kind of transfer needs to be stalled ?
  - IDLE
  - NONSEQ
  - SEQ
- IDLE Transfer needs not be stalled by Manager. The IDLE state itself says that the data transfer is not needed. 
- NONSEQ Transfer this also needs not be stalled by Manager becuse it is single beat transfer. Its a very small request.
- BUSRT Transfer : Only for this kind of transfer. A Manager may **run out of internal buffering** space due to **unexpected downstream stalls** due to large data transfer are performed.

The back-to-back single-beat transfers are unstallable on the manager side and high bus utilization can be achieved.

![image](https://github.com/user-attachments/assets/b6def7c4-a85e-4baf-bf8e-e9a4fb64d46e)

From the above figure following conclusion can be made : 





