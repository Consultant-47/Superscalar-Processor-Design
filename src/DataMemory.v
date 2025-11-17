module DataMemory(
    input         clk,
    input         Read,
    input         Write,
    input  [15:0] Addr,     // full 16-bit address
    input  [15:0] D_In,     // Data input for write operations
    output reg [15:0] D_Out // Data output: concatenation of two 8-bit values
);

  // 256 entries of 8-bit wide memory (addresses 0 to 255)
  reg [7:0] mem [0:255];
  integer i;
  // Initialize memory with data words at specific addresses.
  // DATA:
  //   .word 40000   ; Address 100  (40000 = 0x9C40)
  //   .word 30000   ; Address 102  (30000 = 0x7530)
  //   .word 43690   ; Address 120  (43690 = 0xAAAA)
  //   .word 21845   ; Address 122  (21845 = 0x5555)
  initial begin
    for (i = 0; i < 256; i = i + 2) begin
      mem[i]     = i[15:8]; // Upper 8 bits of the 16-bit number
      mem[i + 1] = i[7:0];  // Lower 8 bits of the 16-bit number
    end
    // Word at address 100: 30016 (0x9C40)
    mem[100] = 8'h9C;  // Upper 8 bits of 0x9C40
    mem[101] = 8'h40;  // Lower 8 bits

    // Word at address 102: 30000 (0x7530)
    mem[102] = 8'h75;  // Upper 8 bits of 0x7530
    mem[103] = 8'h30;  // Lower 8 bits

    // Word at address 120: 43690 (0xAAAA)
    mem[120] = 8'hAA;  // Upper 8 bits of 0xAAAA
    mem[121] = 8'hAA;  // Lower 8 bits

    // Word at address 122: 21845 (0x5555)
    mem[122] = 8'h55;  // Upper 8 bits of 0x5555
    mem[123] = 8'h55;  // Lower 8 bits
  end

  // On the negative edge of the clock, perform read or write.
  always @(negedge clk) begin
    // Write: store D_In into two consecutive memory locations.
    if (Write) begin
      mem[Addr]     <= D_In[15:8]; // Store upper 8 bits
      mem[Addr + 1] <= D_In[7:0];  // Store lower 8 bits
    end
    // Read: output two bytes as a 16-bit word.
    if (Read) begin
      D_Out <= {mem[Addr], mem[Addr + 1]}; // Concatenate bytes: MSB from mem[Addr]
    end else begin
      D_Out <= 16'b0;
    end
  end

endmodule

