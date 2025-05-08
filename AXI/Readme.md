# AXI4

The Widely accepted AMBA AXI Protocol. The content is taken from the ARM Documentation.

Reference Link : 
- https://www.arm.com/architecture/system-architectures/amba/amba-specifications
- https://www.arm.com/resources/education/books/fundamentals-soc
- https://www.arm.com/resources/education/books/modern-soc
  
The AXI protocol features are:
- Suitable for high-bandwidth and low-latency designs.
- High-frequency operation is provided without using complex bridges.
- The protocol meets the interface requirements of a wide range of components.
- Suitable for memory controllers with high initial access latency.
- Flexibility in the implementation of interconnect architectures is provided.
- Backward-compatible with AHB and APB interfaces.

The key features of the AXI protocol are:
- Separate address/control and data phases.
- Support for unaligned data transfers using byte strobes.
- Uses burst-based transactions with only the start address issued.
- Separate write and read data channels that can provide low-cost Direct Memory Access (DMA)
- Support for issuing multiple outstanding addresses.
- Support for out-of-order transaction completion.
- Permits easy addition of register stages to provide timing closure.

## Channel Handshake :
- The Channel Handshake mechanism is based on the VALID and READY signals. The VALID signal goes from the source to the destination, and READY goes from the destination to the source.
- The source uses the VALID signal to indicate when valid information is available. The VALID signal must remain asserted, meaning set to high, until the destination accepts the information. Signals that remain asserted in this way are called sticky signals.
- The destination indicates when it can accept information using the READY signal. The READY signal goes from the channel destination to the channel source.
- This mechanism **is not an asynchronous handshake**, and **requires the rising edge of the clock** for the handshake to complete. 

![image](https://github.com/user-attachments/assets/e64337e7-68f2-4115-9df5-b6d8a5806689)

**NOTE **
- Valid : The signal is generated from Source.
- Ready : The signal is generated from Destination.

## Why do we have VALID and READY ? 
The Backpressure concept 

### Completer-to-requestor Backpressure :
- The mechanism through which a completer communicates its unavailability to a requestor is referred to as backpressure and a requestor waiting on a completer’s acknowledgement in this context is said to be stalled.
- Backpressure is generally implemented by a completer-to-requestor “READY” signal and a transaction starts only when WR/RD and READY are both asserted in the same clock cycle. 

![image](https://github.com/user-attachments/assets/65d5b414-8e65-48fd-86e9-37505cbbfd28)

In this scenario, the only signals of interest between the requestor and completer are, therefore, WR, WRDATA, and READY. Furthermore, suppose the completer needs two cycles end-to-end to perform a write operation, but that the requestor does not know this1. Figure 4.16 shows a timeline for our example.

![image](https://github.com/user-attachments/assets/65afdaf3-dde3-4a14-b69d-5a401b247819)

The back-and-forth between the requestor and the completer shown above can continue indefinitely and the net result is that no transfer ever completes in its entirety. 

In fact, all transfers started by the requestor are seen by the completer, but because each entity only reacts to signals it sees at the rising edge of the clock and, at those specific times, we never have an instance in which both WR and READY are asserted simultaneously, we end up without any transactions being accepted by the completer.

**Resolution :** 
If a requestor wants to start a transaction, then it should assert its control signals and **keep them asserted until the completer’s READY signal is asserted**, at which point the requestor and completer are both aware of each other’s state and the requestor can safely deassert its control signals.

The design choice to keep signals asserted until they are acknowledged by the other entity has two implications: 
(1) The Requestor must not check the READY signal before deciding to assert its control signals because otherwise the completer may never know of the requestor’s intention to start a transaction; 
(2) The Transactions cannot be interrupted once started because a requestor cannot deassert its control signals early, and all data words must be transmitted for both entities to acknowledge the transaction has finished.

![image](https://github.com/user-attachments/assets/17b05b48-1027-4e33-9e12-2dda1e8730a8)
From the above image following conclusion can be drawn : 
- Source is trying to write one word transaction with Address to register 0 and WRDATA = 0xA. The Source/Requestor doesn't involve the decision to start a transaction.
- At next rising edge of the clock T2, T3 the source sees the Ready is still not asserted so it keeps its control signal asserted. (WR is control signal).
- At the next rising edge of the clock **(T4)**, the requestor sees that READY is finally asserted. This means the completer is ready and has **accepted the transaction because WR and READY are both asserted at the same rising clock edge**. This concludes the single-word write transaction.
- At time T4 Handshake Happened.
- At time T5 start a burst-write transaction to registers 1 to 3 by driving required values on ADDR, LENGTH, WR(Control signal) and WRDATA.
- At time T6. The completer is busy and the READY signal is seen as deasserted by the requestor at the rising edge of the clock. The completer is therefore exerting backpressure on the requestor, which then decides to keep its WR control signal asserted and maintains the existing write payload on the WRDATA bus
- At time T8 and T9. The completer asserts the READY signal. Because READY and WR are both asserted the handshake is happening and data transfer happens.

In summary, a transaction must first be accepted by a completer before it can be executed. In a write transaction, this acceptance phase is conducted at the first rising edge of the clock where both WR and READY are asserted, with any additional control signals needed to characterize the transaction (ADDR, LENGTH) also being asserted at this time
The management of backpressure in accepting the transaction and on all following write cycles is therefore handled by the READY signal.

**Write Transaction :** In a write transaction, data flows from the requestor to the completer and the WR signal conveys the validity of the WRDATA bus.

**Read Transaction :** The RD signal does not convey the validity of the RDDATA bus, but rather the validity of the control signals relevant to starting a transaction (ADDR, LENGTH). We need an additional completer-to-requestor signal to convey the validity of the RDDATA bus, so we add a “RDDATAVALID” signal to our protocol.

In the below image the need of RDDATAVALID signal existence coems into picture.
![image](https://github.com/user-attachments/assets/424c413a-1bd4-4121-9259-b50dfef510e9)

Simple/burst read transactions with completer-to-requestor backpressure
![image](https://github.com/user-attachments/assets/980b147d-ff43-4af7-a321-767d6c219313)

Summary : The incorporation of the READY and RDDATAVALID signals, can now enable completer-to-requestor backpressure for both write and read transactions.

### Requestor-to-completer Backpressure : 
For example, consider the setup shown in below figure in which a requestor uses a 16-entry internal FIFO buffer to store data that is to be sent to a completer, but where the requestor needs to perform a 64-word burst-write transaction.
![image](https://github.com/user-attachments/assets/4026300d-52f2-46ac-a359-aa18d24cbe16)

When starting the write transaction, the requestor does not know all 64 words that it will transmit to the completer; at most, it knows 16 of these words. However, the requestor also knows that the internal FIFO buffer it is using is going to be incrementally drained and refilled while data is being pulled from it onto the WRDATA bus and pushed to it from some downstream source inside the requestor.
**In such cases, the requestor needs to exert backpressure on the completer until a new word is available to be written.**

The requestor exerts backpressure on the completer at time T3 because the WR signal is deasserted while READY is asserted, thereby stalling the completer. 
However, at time T5 it is the completer that is exerting backpressure on the requestor because WR is asserted while READY is deasserted. 
![image](https://github.com/user-attachments/assets/0edc27e3-766e-4b26-97a4-9e70d4089ac9)

Therefore, we must reserve the RD signal solely for the acceptance phase of a transaction and must add to our protocol a further signal, RDDATAREADY, to convey a requestor’s availability during a read transaction.
Just as for completer-to-requestor backpressure, a data word is considered successfully transferred from the completer to the requestor when both RDDATAVALID and RDDATAREADY are asserted at the rising edge of the clock.

The final set of signals between the Requester and Completer is as shown below
![image](https://github.com/user-attachments/assets/75421116-f9be-4f41-9e07-9614bd55ee3a)

Now mapping the same concept to AXI4 Protocol as shown below : 
![image](https://github.com/user-attachments/assets/ccfffca6-4064-4298-83e4-d298a5d70f4c)

## Clock Signal
- All input signals are sampled on the rising edge of ACLK.
- All output signal changes can only occur after the rising edge of ACLK.

## Reset Signal
- The AXI protocol uses a single active-LOW reset signal, ARESETn.
- The reset signal can be asserted asynchronously, but deassertion can only be synchronous with a rising edge of ACLK.
- In Reset Phase : All the Valid signal to be driven Low.
  - The Source has to drive AWVALID = 0, WVALID = 0 and ARVALID = 0.
  - The Destination has to drive BVALID = 0 and RVALID = 0.
- Since reset assertion is asynchronous now all the valid signal must drive to 0 on next rising ACLK edge after ARESETn is HIGH.
  
## AXI Protocol : Write 
![image](https://github.com/user-attachments/assets/4fde7c71-3248-4c5b-bd80-377b4aa66755)

## AXI Protocol : Read
![image](https://github.com/user-attachments/assets/9d17887a-c83b-4fcc-8726-9ce03353e090)

## Transfer v/s Transaction 

Transfer    : A transfer is a single exchange of information, with one VALID and READY handshake. 
![image](https://github.com/user-attachments/assets/0abce112-3ab2-449c-b015-50618e89cfe8)

Transaction : A transaction is an entire burst of transfers, containing an address transfer, one or more data transfers, and, for write sequences, a response transfer.
![image](https://github.com/user-attachments/assets/fcc62ea0-df03-4567-97b3-59f423d1fc8e)

## Channel Handshake
There are scenarios like this : 

### ** Scenario 1 :** Valid issued early than Ready
The handshake completes on the rising edge of clock cycle 4, because both READY and VALID signals are asserted.  
![image](https://github.com/user-attachments/assets/c955224e-fd90-4cf0-af8f-052c6631c931)

### ** Scenario 2 :** Ready issued early than Valid
The handshake completes on the rising edge of clock cycle 4, when both VALID and READY are asserted.
![image](https://github.com/user-attachments/assets/d7d37939-3898-4f4d-a46f-bc211eb9a701)

### ** Scenario 3 :** Ready and Valid asserted on the same Clock edge.
The handshake completes on the rising edge of clock cycle 4, when both VALID and READY are asserted.
![image](https://github.com/user-attachments/assets/cc59dd5f-f63a-4954-adca-4d983d398d3f)

**NOTE :** In all three examples, information is passed down the channel when READY and VALID are asserted on the rising edge of the clock signal.  

### Deadlock 
In general the deadlock means Producer A is waiting for resource used by Producer B until it frees it cannot proceed and vice-versa w.r.t to Producer B to Producer A. This is Deadlock. 

In order to avoid Deadlock we use following Resolution : 
![image](https://github.com/user-attachments/assets/bdcbe817-e646-460c-86ce-1efb31bdfa64)

**Conclusion : ** These rules mean that **READY can be asserted before or after VALID**, or even at the same time. 

## Write transaction: Single data item
![image](https://github.com/user-attachments/assets/f5361e1a-f26a-4e9c-af2f-9da8ab6d73e6)

## Write transaction: Multiple data items
![image](https://github.com/user-attachments/assets/7dd6fe06-9608-4a67-9501-4d6cbe0b16ff)

- The master drives **the WLAST high to indicate the final WDATA**. This means that the slave can either count the data transfers or just monitor WLAST.
- Once all WDATA transfers are received, the slave gives a single BRESP value on the B channel. **One single BRESP covers the entire burst**.
- If the slave decides that any of the **transfers contain an error**, **it must wait until the entire burst has completed** before it informs the master that an error occurred.   

## Read Tranaction : Single data item
![image](https://github.com/user-attachments/assets/346693bd-cea3-42b2-9778-3c99ba39b422)

## Read Transaction : Multiple data item
![image](https://github.com/user-attachments/assets/a6ab4867-6427-4a7e-bf04-9f3d207e3202)

- In this example, the master is waiting for data as shown by RREADY set to high. The slave drives valid RDATA and asserts RVALID for each transfer.

## BRESP v/s WRESP
- For a read transaction there is an **RRESP response for every transfer in the transaction**. In the read transaction, the slave uses the same channel to send the data back to the master and to indicate the status of the read operation.  
- In the write transaction, the slave has to send the response as a separate transfer on the B channel. **One single BRESP covers the entire transaction**.
- If we send BRESP for every write beat this will **involve more clock cycles and unecessary traffic** beaucse of the two-way flow between master and slave. 
- If an error is indicated for any of the transfers in the transaction, the full indicated length of the transaction must still be completed. There is **no such thing as early burst termination.** 

### Early Burst Termination
There is no concept of Early burst termination due to error in any of the transfers.

## Active Transaction 

The Active Transaction is known as Outstanding Transactions (OT). 

### Active Read Transaction
- An active read transaction is a transaction for which the read address has been transferred, but the last read data has not yet been transferred at the current point in time.
- The Data must come after the Address becuase the slave has to send the data so, **without knowing address it cannot send leading data.** 
![image](https://github.com/user-attachments/assets/5ad3b3c6-43a7-4015-9574-9ada166f8a97)

### Active Write Transaction
- For write transactions, the data can come after the address, but leading write data is also allowed.
- The start of a write transaction can therefore be either of the following: 
• The transfer of the write address 
• The transfer of leading write information

**Scenario 1 :** 
- Active write transaction where the write address has been transferred, but the write response has not yet been transferred.
![image](https://github.com/user-attachments/assets/9283f61f-c42f-4569-8440-d50c33ec65b7)

**Scenario 2 : **
- Active write transaction where the leading write data has been transferred.
![image](https://github.com/user-attachments/assets/614c051c-2220-4620-8982-ceaab916dedf)


## Write Channel Signals

### AW : Write Address Channel
- The default state of AWREADY is always HIGH. 
- It is not recommended to default AWREADY LOW because it forces the transfer to take at least two cycles, one to assert AWVALID and another to assert AWREADY.
  
![image](https://github.com/user-attachments/assets/7a7693b0-da70-4b16-ad23-8be2c66cc2ef)

### W : Write Data Channel
- The Manager can assert the WVALID signal only when it drives valid write data. Once the WVALID is asserted it must remain in asserted state until next rising clk edge after the subordinate asserts WREADY.
- The default state of WREADY can be HIGH, but only if the Subordinate can always accept write data in a single cycle.
- It is recommended that WDATA is driven to zero for inactive byte lanes.
- The Manager must assert the WLAST signal while it is driving the final write transfer in the transaction.
  
![image](https://github.com/user-attachments/assets/a8fac7f3-7dd4-43bf-9f24-4688c63d436b)
  
### B : Write Response Chaneel
- The Subordinate can assert the BVALID signal only when it drives a valid write response. When asserted, BVALID must remain asserted until the rising clock edge after the Manager asserts BREADY.
- AXI4 removes the WID signal from the W channel. This is because write data reordering is no longer allowed.
- AXI4 adds user-defined signals to each channel.
- AXI4 adds the AWREGION signal to the AW channel. This signal supports slave regions which allow for multiple logical interfaces from a single physical slave interface.  
![image](https://github.com/user-attachments/assets/ad0f24ed-1dd6-4597-ac95-a41f4ac6bc5a)

## Read Channel Signals

### AR : Read Address Channel
- The Manager can assert the ARVALID signal only when it drives a valid request. When asserted, ARVALID must remain asserted until the rising clock edge after the Subordinate asserts the ARREADY signal.
- The Manager can assert the ARVALID signal only when it drives a valid request. When asserted, ARVALID must remain asserted until the rising clock edge after the Subordinate asserts the ARREADY signal.
![image](https://github.com/user-attachments/assets/0af58c51-6d10-4167-96a1-0d823f128313)

### R  : Read Data Channel
- The Subordinate must assert the RLAST signal when it is driving the final read transfer in the transaction.
- It is recommended that RDATA is driven to zero for inactive byte lanes.
![image](https://github.com/user-attachments/assets/4ce8dfb1-a411-4a3d-a43e-f9be3d5143a4)

## AXI Channel Dependencies
- WLAST transfer must complete before BVALID is asserted.
- RVALID cannot be asserted until ARADDR has been transferred.
  - The slave cannot transfer any read data without it seeing the address first. This is because the slave cannot send data back to the master if it does not know the address that the data will be read from.
- WVALID can assert before AWVALID.
  - A master could use the Write Data channel to send data to the slave, before communicating the address where the slave should write these data.  

## Write Transaction Dependencies
![image](https://github.com/user-attachments/assets/7f582be6-d616-449d-b9d1-bf12c7c5829b)

## Read Transaction Dependencies
![image](https://github.com/user-attachments/assets/bf8f41f9-22e5-4810-870e-3f066f2ab6c9)

## Response Signal
![image](https://github.com/user-attachments/assets/9f247e64-e6a0-49ab-8f5f-ac92757ed97e)

### Data Size, Length and Burst Type
![image](https://github.com/user-attachments/assets/476dcd68-10f1-4df2-9e9c-dfe2a38fd6f6)

**Beat  :** Each data transfer. Atomic unit of Total data transfer
**Burst :** Required payload data to be transferred. 

**AxLen  :** This provides the total number of beats in the transaction.
**AxSize :** This specifies the total number of bytes for each beat.

$$
\text{Transaction size} = (A_xlen + 1) * (2^{(A_xSize)}) \text{ Bytes}
$$

The AxSIZE Encodings mentioned below : 
![image](https://github.com/user-attachments/assets/6b58d6df-b657-4ba2-9a16-f79aa43840db)

The AxLEN Encodings mentioned below :   
![image](https://github.com/user-attachments/assets/435deb4b-88ae-46c7-b98b-c15f0ce5454a)

Few Rules on the transaction length : 
![image](https://github.com/user-attachments/assets/a4f6a20d-f8e8-46c8-a195-0bdac1be0cdf)

### Maximum number of bytes in a transaction
- The highest possible value for AxLen = 255 (8bit) and AxSIZE = 7 (3bit) = 128 Bytes.
- The maximum number of bytes in a transaction is 4KB and transactions are not permitted to cross a 4KB boundary.
- An interconnect striping at a granule smaller than 4KB might be able to avoid burst splitting if it knows that transactions will not cross the stripe boundary.

![image](https://github.com/user-attachments/assets/1ae748f2-8513-42e0-8a44-a1e923ad86da)

## Protection level support
- If a transaction does not have the correct level of protection, a memory controller could refuse read or write access by using these signals.
- AWPROT and ARPROT, that can protect against illegal transactions downstream in the system.
- AxPROT bit 0 : Privileged access and Unprivileged access.
- AxPROT bit 1 : Secure and Non-Secure.
- AxPROT bit 2 : Instruction access or Data access

## Cache Support
- Modern SoC systems often contain caches that are placed in several points of the system. For example, the level 2 cache might be external to the processor, or the level 3 caches might be in front of the memory controller.
- AxCACHE bit 0 : Bufferable bit
  - When this bit is set to 1, the interconnect or any component can delay the transaction reaching its final destination for any number of cycles.
  - The bufferable bit indicates whether the response can come from an intermediate point, or whether the response must come from the destination slave.
- AxCACHE bit 1 : Cacheable bit
  - The bufferable bit indicates whether the response can come from an intermediate point, or whether the response must come from the destination slave.
  - For reads, setting the modifiable bit means that the contents of a location can be prefetched, or the values from a single fetch can be used for multiple read transactions. 
- AxCACHE bit 2 : RA bit
  - The transaction must be looked up in a cache as it could have been allocated in this cache by another master.
  - The RA bit indicates that on a read, the allocation of the transaction is recommended, but not mandatory.
- AxCACHE bit 3 : WA bit
  - The transaction must be looked up in a cache as it could have been allocated in this cache by another master.
  - The WA bit indicates that on a write, the allocation of the transaction is recommended, but not mandatory.

**Why ?**
- The reason for including read and write allocation on both read and write address buses is that it **allows a system-level cache to optimize its performance.**
- Read Access
  - Write-allocate and no Read allocate    : The address might be stored in the cache because it could have been allocated on a previous write, and therefore it must do a cache lookup.
  - No write-allocate and no read allocate : The cache knows that the address has not been allocated in the cache. Go fetch from the downstram.

## Write Data Strobes
- The write data strobe signal is used by a master to tell a slave which bytes of the data bus are required.
- Write data strobes are useful for cache accesses for efficient movement of sparse data arrays.
- In addition to using write data strobes, you can optimize data transfers using unaligned start addresses.
- The write channel has one strobe bit per byte on the data bus. These bits make the WSTRB signal.

![image](https://github.com/user-attachments/assets/9f8eb7a0-a511-49e2-beaf-144d257f6d89)

- Valid data only in bytes from 7 to 2.
- Valid data only in bytes 2, 3, 4, and 5.
- Valid data only in bytes 0 and 7 of the data bus.
- Valid data only in bytes 3, 5, 6, and 7 of the data bus.

### Why Data strobe? Why WSTRB only ?
- Byte lane strobes offer efficient movement of sparse data arrays. 
- Write Transactions can be early terminated by setting the remaining transfer byte lane strobes to 0, although the remaining transfers must still be completed. The WSTRB signal can also change between transfers in a transaction.
- Read Transactions we don't need the RSTRB : This is because the master indicates the transfer required and can mask out any unwanted bytes received from the slave.


## Atomic Access with the lock signal 
- In general when multiple threads or cores accessing the same memory region or same variable we come across the concept of Write Serialization and Write Propagation. In ARM Architecture the programmer has to take care of synchronization stuff. Programmer-managed via barriers/atomics.
- The AxLOCK signal in the AXI protocol and ARM's weak memory ordering are related in their roles for avoiding data races, but they operate at different abstraction levels.
- Atomic Operations : Used to implement critical sections (e.g., spinlocks, compare-and-swap) by locking the bus during a transaction sequence.
- Exclusive Access  : The AxLOCK signal supports exclusive transactions (AxLOCK=0b01 for exclusive, 0b10 for locked), which are essential for hardware-level atomicity.
- When a master initiates a locked transaction (AxLOCK asserted), the interconnect ensures no other master accesses the same memory region until the lock is released.
- This prevents data races during critical sections by enforcing atomicity at the hardware level.
- AxLOCK (Hardware): Ensures atomicity for critical sections via bus locking.
- ARM Weak Ordering (Software): Requires explicit synchronization to avoid data races, leveraging atomic instructions that may use AxLOCK under the hood.

AxLOCK
- 0b00 - Normal
- 0b01 - Exclusive
- 0b10 - Locked
- 0b11 - Reserved

### Locked Access 
- When a master uses the AxLOCK signals for a transaction to show that it is a locked transaction, then the interconnect must ensure that only that master can access the targeted slave region, until an unlocked transaction from the same master completes.
-  An arbiter within the interconnect must enforce this restriction. Because locked accesses require the interconnect to prevent any other transactions occurring while the locked sequence is in progress, they can have an important impact on the interconnect performance.
  
### Exclusive Access
- Exclusive accesses are more efficient than locked transactions, and they allow multiple masters to access a slave at the same time.
- The exclusive access mechanism enables the implementation of semaphore-type operations, without requiring the bus to remain locked to a particular master during the operation.
- In an exclusive access sequence, other masters can access the slave at the same time, but only one master will be granted access to the same memory range.  

### Example of Workflow
- STEP 1 : A thread uses an atomic instruction (e.g., LDREX/STREX) to modify shared data.
- STEP 2 : The processor generates exclusive AXI transactions (AxLOCK=0b01) to ensure atomic access.
- STEP 3 : The interconnect locks the bus during this sequence, preventing other cores from accessing the same memory.

![image](https://github.com/user-attachments/assets/da940ef5-03df-4d27-ba4f-d9394fc80081)


## QoS : Quality of Service
- Quality of service allows you to prioritize transactions allowing you to improve system performance, by ensuring that more important transactions are dealt with higher priority.
- AWQOS : 4 bit wide. 0 - Low and F - High.
- ARQOS : 4 bit wide. 0 - Low and F - High.

![image](https://github.com/user-attachments/assets/bfdc2527-94be-492c-9d57-9706f73e483b)


## Transfer Behavior

### Simple Transactions
![image](https://github.com/user-attachments/assets/6f5377f0-db44-4b3a-baef-0feeaa347614)

### Simple Transactions 
- The master starts transaction B before it has finished transaction A.
- The master uses the Read Address channel to transfer in sequence the read addresses C and D for the slave.
- This shows the flexibility of the AXI protocol and the possibility to optimize the interconnect performance. 
![image](https://github.com/user-attachments/assets/1ed704d1-7590-4908-80e5-380ef60d9a4f)

## Transfer IDs
- Marking each transaction with an ID gives the possibility to complete transactions out of order.
- The transactions to faster memory regions can complete without waiting for earlier transactions to slower memory regions.
- The use of transfer IDs enables **the implementation of a high-performance interconnect, maximizing data throughput and system efficiency**.
- According to the AXI protocol specifications, **all transactions with a given ID must be ordered.**
- However, there is **no restriction on the ordering of transactions with different IDs**.

### Write Transaction Ordering Rule
- **RULE 1 :** Write data on the W channel must follow the same order as the address transfers on the AW channel.
- ![image](https://github.com/user-attachments/assets/b09e1dc6-e6c9-4b46-86d1-20451efdf859)

- **RULE 2 :** Transactions with different IDs can complete in any order. In below example the Response for Transaction B comes first and then for Transaction A. The completion can be in different order then issued.
- ![image](https://github.com/user-attachments/assets/53ff2ce0-afb0-4e90-b62b-645e8ffda797)

- **RULE 3 :** A master can have multiple outstanding transactions with the same ID, but they must be performed in order and complete in order.
-  In this example, transaction B has a different ID from the other transactions, so it can complete at any point. However, transactions A and C have the same ID, so they must complete in the same order as they were issued: A first, then C. 
- ![image](https://github.com/user-attachments/assets/e4df4391-9c7d-4572-a24b-36dc4672793f)
 
### Read Transactions Ordering Rule
- **RULE 1 :** Read data for different IDs on the R channel has no ordering restrictions. This means that the slave can send it in any order.
- ![image](https://github.com/user-attachments/assets/8fe798e7-c92d-4fbc-8eb5-565c64a2fddf)

- **RULE 2 :** The read data for the different IDs on the R channel can be interleaved, with the RID value differentiating which transaction the data relates to.
- ![image](https://github.com/user-attachments/assets/f9ebbbf7-fe6e-4f9b-8c8b-6b701a2c6139)

- **RULE 3 :** For transactions with the same ID, read data on the R channel must be returned in the order that they were requested.
- ![image](https://github.com/user-attachments/assets/f8dded90-309c-469d-86f0-b1aff2cb827f)
 
### Read and Write Channel Ordering
- Read and write channels have no ordering rules in relation to each other. This means that they can complete in any order.
- If a master requires ordering for a specific sequence of reads and writes, the master must ensure that the transaction order is respected by explicitly waiting for transactions to complete before issuing new ones. 
- In the below image there is sync or memory barrier operation kind of thing or dependency like RAW defined stuff.
- ![image](https://github.com/user-attachments/assets/e8fe2feb-fb19-468f-bef0-9f6dc60e7674)


### Unaligned Transfer 
- An unaligned transfer is where the AxADDR values do not have to be aligned to the width of the transaction.
- The AXI supports unaligned transfers using the strobe signals.
- This only affects the first transfer in a transaction. After the first transfer in a transaction, all other transfers are aligned.
- The first transfer starts at address 0x01 and contains three bytes. All the following transfers in the burst are aligned with the bus width and are composed of four bytes each.

- Example 1 :
![image](https://github.com/user-attachments/assets/641ec045-6247-4ba9-b6de-24863274f0f9)

- Example 2 : 
![image](https://github.com/user-attachments/assets/6a2fcf64-6bec-474c-a349-e278cca2afae)

### Endianness Support
![image](https://github.com/user-attachments/assets/59698ceb-3c30-4752-aaf0-15c0d1d50f04)
























