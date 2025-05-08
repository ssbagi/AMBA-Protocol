![image](https://github.com/user-attachments/assets/41f28aba-8b04-40ba-929b-59adc2292e57)![image](https://github.com/user-attachments/assets/6ea187c3-63cb-4429-b956-145dc79f2f51)## AXI4

The Widely accepted AMBA AXI Protocol. 
Link : 
- https://www.arm.com/architecture/system-architectures/amba/amba-specifications
- https://www.arm.com/resources/education/books/fundamentals-soc
- https://www.arm.com/resources/education/books/modern-soc
  
The content is taken from the ARM Documentation. 

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
- If an error is indicated for any of the transfers in the transaction, the full indicated length of the transaction must still be completed. There is **no such thing as early burst termination.** 

### Early Burst Termination
There is no concept of Early burst termination. 


