# My FIFO project
In this document, I will explore all problems and doubts I had while building my asynchronous FIFO in systemverilog. 
   	When I started constructing my FIFO memory I didn’t have any knowledge about this topic, so I had to learn the main concepts online, learn them and then translate them to systemverilog. While I was learning, I was struck with some doubts about the functionality of the model, so the dynamic of this report will be simple: I will answer the questions I had while I was assembling my project.	

    1. Why is this FIFO asynchronous?

	It is asynchronous because we have 2 clocks: the write clock and the read clock, and these two don’t have the same clock time. For example, the write clock can be 20 ns and the read clock can be 30 ns. However, the read half is synchronous with the read clock and the write half is synchronous with the write clock.


    2. Why is there an empty flag and full flag?

	Well, these flags exist as a security measure to avoid errors. Our FIFO works with pointers, one for writing and another for reading, and imagine that we have an empty FIFO and we try to read while it is empty, we will point to something that doesn’t exist, creating problems and undefined behavior. The “same” logic occurs to the full flag, if we try to write while our FIFO is full, it might overwrite important info that hasn't been read yet, creating another problem. Hence, we have flags to check if FIFO is empty and then we don’t read, and check if FIFO is full and then we don’t write.

    3. How do we know if the FIFO is full or empty, what is the logic?

	This is very important because it is the core of FIFO memory. The logic is: If the write pointer is pointing to the same address that read pointer is pointing on the same lap, then our FIFO is empty, and if the write pointer is pointing to the same address but on a different lap, then our FIFO is full.
If we are using 6 bits width to write and read data then our rbin and wbin need an extra bit, to define the lap. 
Example: 
	rbin = 0_000000;
	wbin = 0_000000; —> this means that our FIFO is empty


	rbin = 0_000110;
	wbin = 0_001010; —> this means that our FIFO is neither empty nor     full


	rbin = 0_000000;
	wbin = 1_000000; —> here FIFO is full, because we have written in every position until it gives a complete lap. The writing is one lap after than reading.

     4. Why do we use 2 flip-flops?

	To overtake the metastability, which is when the system is almost stable. The values cannot enter in write or read logic while being in the metastability state because the system is not stable yet and any small thing can completely change the circuit and create bugs, basically if the d value changes between the gap time of metastability, it violates the system and it can be bad. Then the first flip-flop gets the value and stabilizes it and gives it to the second flip-flop and finally the value is ready to be processed correctly and far from errors.
	
	5. Why do we need to convert the binary values to gray?

	The gray code is needed to synchronize each bit individually. If we don’t have our wtpr or the rptr in gray code, we don’t know if the bits are being processed within the metastability state or not. For example, wptr has various bits changing at the same time (0111 -> 1000), we can capture wrong combinations (ex. 0000 or 1111), so to bypass these problems we convert the binary numbers to gray, which is the xor operation between the numbers and the MSB is equal to the MSB of binary value.
 	Example:
	gray = (binary >> 1) ^ binary
	binary			gray
	0000			0000
	0001			0001
	0010			0011
	0111			0100
	1111			1000
	And this works because now each bit changes one by one between transitions of consecutive counts and avoids the reading, to capture invalid intermediate states.  

              
	6. Why do we need to invert the 2 MSB of rptr to compare with wptr to check if it is full?
	The MSB is the lap’s indicator, so when we convert rbin to gray, the MSB of gray value is equal to the MSB of binary value, and the second MSB is a xor operation between the MSB and the second MSB, so if the lap bit changes, the two MSB also changes. Exemple:
	gray = (binary >> 1) ^ binary
	rptr = binary(0000) = gray(0000)
	wptr = binary(1000) =  gray(1100) —> full
So if we want to compare wptr with rptr we have to invert the two MSB of rptr and then we check if it is full.
	Another example:
	rptr = binary(0100) = gray(0110)
	wptr = binary(1100) = gray(1010) —> full
See? it always happens.


	7. If I want to check the data that exists in address 4, how do I do it?

	This memory is first in first out, so we have to increment rbin until it gives us the address 4, then we read that value and check. We can’t just give an order to read the exact address 4.
