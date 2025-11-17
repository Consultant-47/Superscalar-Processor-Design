/*
    Pipeline IF_ID Register
    Inputs :
        clk reset stall
        From FetchStage : I1, I2, I1V, I2V, I1P, I2P, I1PC, I2PC
        From Decoder : loop, I1_loop, I2_loop, I1V_loop, I2V_loop, I1P_loop, I2P_loop, I1PC_loop, I2PC_loop
    Outputs :
        I1, I2, I1V, I2V, I1P, I2P, I1PC, I2PC
*/

module IF_ID_PR (
    input wire clk,             // external clock
    input wire reset,           // external reset
    input wire stall,           // external stall
    input wire flush,           // external flush

    // From FetchStage
    input wire [15:0] I1,
    input wire [15:0] I2,
    input wire I1V,
    input wire I2V,
    input wire I1P,
    input wire I2P,
    input wire [15:0] I1PC,
    input wire [15:0] I2PC,

    // From Decoder
    input wire loop,
    input wire [15:0] I1_loop,
    input wire [15:0] I2_loop,
    input wire I1V_loop,
    input wire I2V_loop,
    input wire I1P_loop,
    input wire I2P_loop,
    input wire [15:0] I1PC_loop,
    input wire [15:0] I2PC_loop,
    input wire [5:0] I1_IMM,
    input wire [5:0] I2_IMM,

    // Outputs to Decoder
    output reg [15:0] I1_out,
    output reg [15:0] I2_out,
    output reg I1V_out,
    output reg I2V_out,
    output reg I1P_out,
    output reg I2P_out,
    output reg [15:0] I1PC_out,
    output reg [15:0] I2PC_out,
    output reg [5:0] I1_prev_IMM,
    output reg [5:0] I2_prev_IMM
);

always @(posedge clk) begin
    if (reset || flush) begin
        // Reset all outputs
        I1_out <= 16'b0;
        I2_out <= 16'b0;
        I1V_out <= 1'b0;
        I2V_out <= 1'b0;
        I1P_out <= 1'b0;
        I2P_out <= 1'b0;
        I1PC_out <= 16'b0;
        I2PC_out <= 16'b0;
        I1_prev_IMM <= 6'b0;
        I2_prev_IMM <= 6'b0;
    end else if (!stall) begin
        // Update outputs based on the `loop` signal
        if (loop) begin
            I1_out <= I1_loop;
            I2_out <= I2_loop;
            I1V_out <= I1V_loop;
            I2V_out <= I2V_loop;
            I1P_out <= I1P_loop;
            I2P_out <= I2P_loop;
            I1PC_out <= I1PC_loop;
            I2PC_out <= I2PC_loop;
        end else begin
            I1_out <= I1;
            I2_out <= I2;
            I1V_out <= I1V;
            I2V_out <= I2V;
            I1P_out <= I1P;
            I2P_out <= I2P;
            I1PC_out <= I1PC;
            I2PC_out <= I2PC;
        end

        // Update immediate values
        I1_prev_IMM <= I1_IMM;
        I2_prev_IMM <= I2_IMM;
    end
end

endmodule