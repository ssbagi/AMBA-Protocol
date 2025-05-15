# AHB

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








