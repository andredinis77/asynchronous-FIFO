
## My FIFO Project 

In this section, I explore all the problems and doubts I had while building my asynchronous FIFO in SystemVerilog. 

When I started constructing my FIFO memory, I didn’t have any knowledge about this topic, so I had to learn the main concepts online, understand them, and translate them to SystemVerilog. While I was learning, I was struck with some doubts about the functionality of the model, so the dynamic of this report will be simple: **I will answer the questions I had while I was assembling my project.**

---

### 1. Why is this FIFO asynchronous?
It is asynchronous because we have 2 clocks: the **write clock** and the **read clock**, and these two don’t have the same clock time. For example, the write clock can be 20 ns and the read clock can be 30 ns. However, the read half is synchronous with the read clock and the write half is synchronous with the write clock.

---

### 2. Why is there an empty flag and full flag?
Well, these flags exist as a security measure to avoid errors. Our FIFO works with pointers—one for writing and another for reading.

* **Empty Flag:** Imagine that we have an empty FIFO and we try to read while it is empty: we will point to something that doesn’t exist, creating problems and undefined behavior. 
* **Full Flag:** The same logic applies to the full flag. If we try to write while our FIFO is full, it might overwrite important info that hasn't been read yet, creating another problem. 

Hence, we have flags to check if the FIFO is empty (so we don’t read) and if the FIFO is full (so we don’t write).

---

### 3. How do we know if the FIFO is full or empty, what is the logic?
This is very important because it is the core of FIFO memory. The logic is: 
* If the write pointer is pointing to the same address that the read pointer is pointing to **on the same lap**, then our FIFO is **empty**.
* If the write pointer is pointing to the same address **but on a different lap**, then our FIFO is **full**.

If we are using a 6-bit width to write and read data, then our `rbin` and `wbin` need an extra bit to define the lap.

**Example:**
```text
rbin = 0_000000;
wbin = 0_000000;  —> FIFO is EMPTY (same address, same lap)

rbin = 0_000110;
wbin = 0_001010;  —> FIFO is NEITHER empty nor full

rbin = 0_000000;
wbin = 1_000000;  —> FIFO is FULL (same address, different lap)
```
---

### 4. Why do we use 2 flip-flops?
To overcome metastability, which occurs when the system is almost stable. The values cannot enter write or read logic while being in a metastable state because the system isn't stable yet—any small fluctuation during the metastability gap can violate timing and create bugs.

The first flip-flop captures the signal and stabilizes it, passing it to the second flip-flop so the final value is ready to be processed correctly and safely without timing errors.

---

### 5. Why do we need to convert the binary values to Gray code?
Gray code is needed to synchronize each bit individually. If we don’t have our wptr or rptr in Gray code, multiple bits could change simultaneously (e.g., 0111 -> 1000). If sampled happen during a clock transition, we could capture invalid intermediate states (e.g., 0000 or 1111).

To bypass these problems, we convert binary numbers to Gray code using an XOR operation where the MSB remains identical to the binary MSB:

```txt
gray = (binary >> 1) ^ binary;
binary  gray
0000	  0000
0001	  0001
0010	  0011
0111	  0100
1111	  1000
```
And this works because now each bit changes one by one between transitions of consecutive counts, preventing the logic from capturing invalid intermediate states.

---

### 6. Why do we need to invert the 2 MSB of rptr to compare with wptr to check if it is full?
The MSB is the lap indicator. When we convert rbin to Gray code, the MSB of the Gray value is equal to the MSB of the binary value, and the second MSB is an XOR operation between the MSB and the second MSB. Therefore, when the lap bit changes, both of the top two MSBs change.

```text
gray = (binary >> 1) ^ binary

rptr = binary(0000) = gray(0000)
wptr = binary(1000) = gray(1100) —> FULL
```
So if we want to compare wptr with rptr, we have to invert the two MSBs of rptr and then we check if it is full.

```text
rptr = binary(0100) = gray(0110)
wptr = binary(1100) = gray(1010) —> FULL
```
See? It always happens.

---

### 7. If I want to check the data that exists in address 4, how do I do it?
This memory is First-In, First-Out (FIFO). We cannot directly request to read address 4. We must increment rbin sequentially until it reaches address 4, at which point we can read and inspect that value.

