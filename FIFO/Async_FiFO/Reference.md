*Design Async FIFO and TB
- DEPTH = 8, WIDTH = 8
- wclk = 125MHz, rclk = 100MHz
- not necessary for a_full, a_empty
- protect overflow & underflow
- gray_cnt = (bingray_cnt>>1) ^ binary_cnt;

![image](https://github.com/user-attachments/assets/bb093105-bae8-4e23-bfab-351f7ddc558b)
