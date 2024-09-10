*Design FIFO logic
- AF_LEVEL = 1
-	AE_LEVEL = 1

![image](https://github.com/user-attachments/assets/9914d29e-fa57-427d-9ff2-10905d9ba6c8)

- The following commented code was used for keeping the data after a pop operation until the next data is pushed.
- This can be useful if you want to hold the previous data after a pop until new data is pushed.

- wire [DEPTH_LOG-1:0] rd_ptr_2 = rd_ptr + pop - 1;
- assign dout = mem[rd_ptr_2]; 
![image](https://github.com/user-attachments/assets/d4173538-e7b8-4911-bf71-2597f2b6eed1)
