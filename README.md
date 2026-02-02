
# Asynchronous-and-Synchronous-FIFO

**Synchronous and Asynchronous FIFO Design in Verilog HDL**
A Verilog-based implementation of **Synchronous FIFO and Asynchronous FIFO**, focusing on **Clock Domain Crossing (CDC), metastability mitigation, pointer synchronization, and producer–consumer handshaking**, verified using simulation waveforms and structural design analysis.

![FIFO](https://img.shields.io/badge/Design-FIFO-blue?style=flat-square) <img src="https://img.shields.io/badge/HDL-Verilog-blue.svg" /> <img src="https://img.shields.io/badge/Domain-CDC%20Design-orange.svg" /> <img src="https://img.shields.io/badge/EDA-Generic%20Simulator-brightgreen.svg" />

---

## 🧩 Overview

This project presents the **design, implementation, and verification of both Synchronous and Asynchronous FIFO architectures** using Verilog HDL.
The primary focus is on **safe data transfer across clock domains**, understanding **metastability**, **MTBF**, and applying **industry-standard CDC techniques** such as **double-flop synchronizers, gray-code pointers, and handshake-based pulse synchronizers**.

The FIFO design is verified using simulation waveforms, emphasizing **full/empty detection, pointer synchronization, and producer–consumer coordination**.

---


## ✨ Features

* Synchronous FIFO (single clock domain)
* Asynchronous FIFO (independent read and write clock domains)
* Gray-code pointer encoding and decoding
* Double D-FF synchronizers for CDC
* Full, Empty, and Almost-Full flag generation
* Producer–consumer handshake awareness
* Simulation-driven verification using waveform analysis
* FPGA- and ASIC-friendly RTL design practices

---

## 📊 Simulation Waveforms & Schematic

### Asynchronous FIFO waveform:
<img width="1570" height="867" alt="image" src="https://github.com/user-attachments/assets/f3232d87-6c4b-465e-a17b-ce28fda2b110" />

### Synthesis Schematic

<img width="1066" height="538" alt="image" src="https://github.com/user-attachments/assets/4fd5c606-0221-48bd-b6e9-6f3c50004a68" />


## 🛠️ EDA Tools & Technologies

* **HDL:** Verilog
* **Design Style:** RTL + Structural Modeling
* **Verification:** Simulation-based waveform analysis
* **CDC Techniques:**

  * Double-flop synchronizers
  * Gray-code pointer transfer
  * Handshake-based pulse synchronizers
* **Clocking:**

  * Single clock domain (Synchronous FIFO)
  * Multi-clock domain (Asynchronous FIFO)

---

## 📘 Theory Overview

### Basics of Clock Domain Crossing (CDC)

* **Synchronous Design:**
  All modules operate on the **same clock frequency and phase**. Data transfer occurs using the same clock that captures it.

* **Asynchronous Design:**
  Modules operate on **different clocks** (frequency and/or phase). Data transfer between these modules leads to **Clock Domain Crossing (CDC)** issues.

---

### Metastability and MTBF (Mean Time Between Failures)

If a signal generated in one clock domain changes close to the sampling edge of another clock domain, it may violate **setup or hold time**, causing the output to enter a **metastable state** (≈ VDD/2).

* Metastability is **temporary but dangerous**
* MTBF is **inversely proportional** to:

  * Sampling clock frequency
  * Frequency of data transitions

CDC techniques are used to **increase MTBF**, not eliminate metastability.

---

### Two-Stage Synchronizers (Level Signals)

A **two-flop synchronizer** reduces metastability propagation by allowing the first flop to resolve instability before the second captures the signal.
This technique is suitable for **slow-changing level signals**.

---

### Edge Detection Logic

Edge detection is used to convert a **level signal into a pulse**, typically using:

* A delayed version of the signal (D-FF)
* Combinational logic to detect transitions

Supported modes:

1. Positive edge detection
2. Negative edge detection
3. Dual-edge detection

---

### Pulse Synchronizers

#### Slow-to-Fast Clock Transfer

A pulse transferred through synchronizers becomes a **level**, requiring **edge detection** in the destination domain.

#### Fast-to-Slow Clock Transfer

Pulses may be completely missed. Solutions include:

* Toggle-based synchronizers
* Handshake-based pulse synchronizers

---

### Handshake-Based Pulse Synchronizer

This is the **most reliable CDC pulse transfer technique**, especially when clock frequencies are unknown.
A feedback mechanism ensures:

* No pulse is generated before the previous one is fully acknowledged
* Safe transfer without pulse loss

---

### FIFO Design Concepts

* Gray-code pointer synchronization
* Full and empty detection logic
* Depth calculation (non-power-of-2 considerations)
* Write pointer transfer to read domain and vice versa
* Importance of verifying behavior using **your own implementation**, not just reference designs

---

## 📘 Learnings / Challenges

> **(Directly derived from this project’s implementation and debugging experience)**

1. **D-FF is a delay flip-flop (but not always)** due to metastability when data changes near the sampling edge.

2. Latches in Verilog are inferred via **combinational blocks with incomplete assignments**, even though outputs are declared as registers.

3. FIFO reset resets **only pointers**, not memory contents.

4. Synchronous designs typically imply a **single shared clock domain**.

5. Structural Verilog does **not flag missing port connections**, leading to silent bugs.

6. `3'bxxx` is simulation-only and **not synthesizable**.

7. Creating derived clocks internally is discouraged; use **clock enables or FSM delays** instead.

8. Use **named/positional ports and parameterization** to reduce integration bugs.

9. Missing pointer values during synchronization is acceptable and **does not cause false empty detection**.

10. **Major Challenge – Producer–Consumer Handshake:**
    Without feedback, the producer may overwrite FIFO data.

    * `full` and `almost_full` must be exposed to the producer
    * `wr_valid` is required to prevent invalid trailing data from being written
    * FIFO must be allowed to **drain naturally to empty**

---

## 📚 References

* **CMOS Digital Integrated Circuits** — Prof. Janakiraman (Setup/Hold & Metastability)
* **Flop n Adder – FIFO & CDC Video Series**
* **Karthik Vippala – CDC & Asynchronous FIFO**
  [https://youtu.be/oUxa8itti8w](https://youtu.be/oUxa8itti8w)
* **FIFO Depth Calculation**

  * [https://youtu.be/-xLedxOJC3s](https://youtu.be/-xLedxOJC3s)
  * [https://youtu.be/-xxiyB-k2vg](https://youtu.be/-xxiyB-k2vg)






***
# Theory
# Basics of CDC
<img width="1321" height="785" alt="image" src="https://github.com/user-attachments/assets/f99dcbb7-1975-4212-8d2d-35d2a57a4d98" />
## Difference between Synchronous and Asynchronous Designs:
1. **Synchronous:** If all the modules/subsystems of an IP are running on the same clock frequency and same phase then the design is called synchronous. A module transfers data/signal through the same clock as the module which accepts the data.
2.  **Asynchronous:** If the multiple modules work on different clocks within the same IP, or even if there are 2 IPs and the IPs work on different clocks and transfer of data/signal happens, then it is called asynchronous design. Example-: Module A transfers data at CLK i to another module B which accepts data through CLK j. CLK i and j differ either by frequency or phase as they were generated by different PLLs in the chip. This passing of data/signal is called **clock domain crossing.**

## Metastability and MTBF(Mean Time between Failures)
<img width="1405" height="851" alt="image" src="https://github.com/user-attachments/assets/5584954b-639c-4f7c-bd7b-01f26c5b4b1e" />

### Metastability
If the SigA which is the ouput of module(having clkA) changes very close to CLKB's sampling edge then it may not entirely cover up the setup or hold time window of clkB and hence the output would be undeterministic(near Vdd/2 that is neither high nor low) for a period of time as it wasn't sampled correctly/entirely until the next clock edge of B where it is sampled correctly if it remains as it is and does not change. This metastability region is called **Failure**
See CMOS Prof.Janakiraman for setup and hold time intuition.
In short-: Why setup time is needed? Master Latch is on before the sampling edge and it needs to store the new incoming data in the feedback loop as the feedback loop will turn on closing the data input path. The time delay of all the inverters and pass transmission gates it needs to pass through till it reaches the last transmission gate of **Breaking the FB configuration.** is the setup time.
Hold time is required in case of clock skew(on clkbar-: negative skew in +ve edge trigger) in case of 1-1 overlap of clk and clkbar where data can shoot through both the latch's transmission gates if data changes during the thold, this is a race condition.

Also refer to Prof.Jankiraman's Metastability video
### MTBF
Is is inversely proportional to (sampling frequency(of data acceptor clock)* frequency of change of data), obviously as if the input change increases then more likely that it will change within setup or hold window and failure/metastabillity will happen.

CDC Techniques discussed further help in increasing MTBF time.

## Technique to increase MTBF-: 2 Stage/flop synchronizers for a level signal(frequency = 1Hz))
<img width="905" height="562" alt="image" src="https://github.com/user-attachments/assets/5a31a389-bdec-44b0-9c75-74997cbe6d12" />

Here we can see that the capture flop which has the output of **o/p** is initially caught in metastablity but the 2nd cascaded flop right next to it does not capture this unstable data as 2 D-FF cascaded work like shift registers and hence the 2nd flop captures the previous data that was there before the edge. 
On the next edge both o/p and 2nd flop capture the correct value as the o/p actually slowly rises/falls to the correct value during the metastablity state(as the state is temporary) and the 2nd flop that accepts the value has the inverter logic gate initially which produces the correct output as the input lies either in the Vil or Vih range.

### Actual design Implementation:

<img width="863" height="507" alt="image" src="https://github.com/user-attachments/assets/7f93ac62-ff19-4e52-b170-ccaec7113ca2" />
We should pull this from std.cell library as the distance between the 2 flops should be less. If the distance is more, then the o/p signal of 1st flop may diminish its logic value.(This is primarily why buffers are added in a design of clock tree).

# Edge Dectection Logic/Ckt to generate a pulse signal from a level signal
<img width="1180" height="721" alt="image" src="https://github.com/user-attachments/assets/10f03087-09fe-419b-9a0d-cc23a6f94a60" />
3 types of pulse generation-:
1. Positive Edge Detection
2. Negative Edge Dectecton
3. Both Implement together
Note-: **Positive edge detection means that want to generate a pulse on the positive edge of the input signal.**
For this we use an additional D flop to produce the delayed version of Signal A(If Sig A and posedge of clock occurs at the same time then the previous value of SigA is sampled instead of new value). We use the logic equation as shown to generate a small pulse using additional gates.

## Ckt Implementation
<img width="898" height="545" alt="image" src="https://github.com/user-attachments/assets/9b330bac-fc29-4030-b5da-a3926dace672" />

# Pulse Synchronizer: Transferring of Pulse from slower to faster or faster to slower clock domains.
**1) Slow to Fast:**
<img width="835" height="462" alt="image" src="https://github.com/user-attachments/assets/6761ec55-f695-4e54-a7b4-d4e8b13408d9" />

**Defination of Pulse:**
When logic level 1 lasts for a complete 1 time period and then shuts off, it is then called a pulse.
In the Figure when we pass the SignalA pulse(pulse in ClkA) to the clock domain B's flop though double synchronizers we actually get a level in clkB(logic '1' lasts for multiple clocks) hence we use the edge detection technique to produce a pulse in clkB.
Do note that this design fails if clkA and clkB are very near in frequency in case the sampled SigB goes into metastability. Better approach discussed later.

<img width="657" height="412" alt="image" src="https://github.com/user-attachments/assets/0c080a8c-b0c6-49c5-b0e3-b15a367efbb1" />


**2) Fast to Slow clock:** 
<img width="687" height="461" alt="image" src="https://github.com/user-attachments/assets/ca231a72-1574-4b3f-8433-cfad07b33ea5" />

Here you can see that pulse is not detected as it was never sampled. We can either use Toggle based approach/Handshake(standard and usable if we don't know the frequency of both clocks) based approach.

<img width="766" height="536" alt="image" src="https://github.com/user-attachments/assets/e0860ecd-952f-49cb-a9fe-82a2e5389978" />

here we convert the small pulse into level that is easily detectable through slow clockB. Edge detection technique is used to generate pulses in clock B.
Issue arises when multiple pulses are generated in clkA domain as double synchronizer will miss out some of these pulses due to metastability of the previous pulse and also the fact that they are in slower clkB.

# Standard process: Handshake based pulse synchronizer(transfer of pulse from clock domains)

<img width="868" height="520" alt="image" src="https://github.com/user-attachments/assets/b6e7e54f-1779-4712-a429-a069c0f52cc7" />


See the Karthik Vippala's last 3 minute summary or the video for understanding.


<img width="770" height="512" alt="image" src="https://github.com/user-attachments/assets/3369556d-8318-4fcc-90a1-b68c65b1df01" />

In short-: sinput produces pulse and allows a permanent feedback loop that generates 1 level at q which travels through double synchronizers and the delay ff and through edge detection technique sync_out is produced as the resultant pulse in different clock domain. 
To prevent sinput or the user to produce another pulse before the previous pulse is completely utilised we use a feedback loop that travels through 2 flops of clka back to busy or gate which turn it on that tells the user not to generate a pulse anymore. This changes the mux's select line and now one of the input of busy or gate is made zero but the 0 needs to travel through 5 muxes(3 of clka and 2 of clkb) to make the other input of Mux =0 to allow more pulses.

## ICG(Integrated Clock gating technique for decreasing dynamic power dissipation)
https://youtu.be/X5arXnfDTEk

Refer Prof. Jankiraman notes for Dynamic power dissipation
In short-: In half cycle of input of inverter either changin to 1 or 0, one path closes and the other opens up. The closed path for example vdd to capcitor charges the capacitor and half of the energy is lost. Cap only stores 1/2 * C * (Vdd^2) . Energy provided by the source battery is C(vdd^2). E = integration over time of Vi*I w.r.t time where i =cdvo/dt

## Synchronous FIFO/CDC/gray_encode_decode/(not power of 2 depth issue)/Asynchronous FIFO
Refer Flop_n_Adder(2 videos)
Refer Karthik Vippali(3 videos)
**Most Importantly refer your own code as it is much different from Karthik Vippali.**
https://youtu.be/oUxa8itti8w

**Important things to learn only from your code-: Full and empty condition.**

## Depth calculation
https://youtu.be/-xLedxOJC3s

https://youtu.be/-xxiyB-k2vg


# **Learnings:**

1. **D-FF is a delay flip-flop (but not always).**
   This is because if the input **D data changes exactly at the clock’s sampling edge** (edge-triggered), then the output may either:

   * pull the **previous stable value of D**, or
   * go into a **metastable state** (≈ VDD/2).

   We consider the case where it pulls the **previous stable value** and *not* the metastable state, because only then does it behave like a **one-clock-cycle delay element**.

2. **Latch in Verilog** is inferred using a **combinational block with incomplete assignments**, but the output `q` is declared as a **register type**.

3. When **reset (rst) is asserted in a FIFO**, the values stored in memory are **not reset**. Only the **read and write pointers are reset**, and the previously stored values are simply **ignored and later overwritten** with new ones.

4. If a design is said to be **synchronous**, then most probably **all subsystems/modules run on the same synchronous clock domain** as the other modules.

5. **Debugging Issue:**
   In **structural Verilog modeling**, when interconnecting subsystems in the top module, if some **port names are left out**, it is **not shown as an error** by the compiler and those ports simply remain **disconnected**, which can be very hard to debug.

6. `3'bxxx` is **not synthesizable** and works only for **simulation**. Instead, use an **impossible or reserved value** of your choice.

7. Instead of creating a **slower clock internally from a global clock** (i.e., creating multiple clock domains), it is better to:

   * use **clock enables** within a single global clock using `if` conditionals, or
   * use **FSM states as delay mechanisms** to execute instructions after a certain number of states.

   Note that this will **not truly act like different clock domains with different frequencies**—everything still operates in **multiples of the same base clock frequency**.

8. Use **positional or named ports** and **parameterized design** to prevent debugging issues.

9. **Important point to remember:**
   When we transfer `wptr` to the **slower clock domain of `rptr`**, some `wptr` values are **missed by the double D-FF (two-stage) synchronizers**, but this is **acceptable**.
   This is because the **empty condition will never actually be falsely activated**. Data is most likely written faster, the FIFO will rarely be empty, and the read can proceed freely.
   This should be verified using **timing analysis practice**.

10. **Challenges faced – Handshake / Producer–Consumer Protocol:**
    If there is **no way to tell the producer to pause** and stop providing data, the producer will **continuously push data**, unaware of whether the FIFO is **full or almost full**. Hence, **full and almost_full must be outputs of the FIFO** and fed back to the producer.
<img width="842" height="593" alt="image" src="https://github.com/user-attachments/assets/4ac7ca89-e67b-4f41-b63a-a07eb50d77bb" />

    **Need for almost_full:**
    There are multiple reasons—analyze the waveform for better understanding. Key points:

    * `wdata` is a **delayed version of `from_user`**.
    * `wr_en` must write **`wdata`**, not `from_user`.
    * In the testbench, we decide on the **negedge of the clock** whether the FIFO is full or not, but we did **not check almost_full**.
    * Just before the FIFO becomes full on the **rising edge of `w_clk`**, on the previous negedge we see that it is not full and pass a new value to `from_user`.
    * The **full condition only changes** due to `wdata` being written on the incoming posedge.
    * Full prevents `wdata` from being written, but we must **also prevent `from_user` from generating a new value**, which is why **almost_full is required**.



    **Second issue – Valid data handling:**
    After `wen/ren` is asserted (`1'b1`), the data written into or read from the FIFO must be handled in the **same number of clock cycles**.
    In this design, the **read operation takes one extra clock cycle**, so the consumer was made **combinational**.

    However, note that the consumer may take time to evaluate the current `to_the_user` value. A better design improvement would be to introduce a **`read_valid` signal**.
    Only when `read_valid == 1'b1` should the `rptr` increment and the next data be read from the FIFO.

    Without a **valid-input mechanism**, the design does not work correctly. Refer to the testbench code below:

    ```verilog
    repeat(50) begin
    @(negedge w_clk) begin
        if((dut.wen == 1'b1) && (dut.full == 1'b0) && (almost_full == 1'b0)) begin
        
            valid_input = 1'b1;
            from_user = $urandom();
            
        end
        else begin
            valid_input = 1'b0;
        end
    ```

    There will always be some **valid or invalid value** present on `from_user` from the producer.
    `wen` depends on whether the FIFO is full, and we use `full` to determine if it is safe to write into the FIFO.

    If the producer has finished sending all data and only the **last floating value of `from_user` remains** (which is invalid and should not be written), it still gets written because the FIFO only checks the **full condition** and has no knowledge of data validity.

    In real-world scenarios, this cannot be allowed. The FIFO should **stop accepting data** and then **gradually drain to the empty state**.
    Hence, we transfer **`wr_valid`** to the FIFO to tell it to **stop completely** and allow it to drain naturally to the empty state.

