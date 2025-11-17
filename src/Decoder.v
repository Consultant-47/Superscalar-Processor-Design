/*
  Template Verilog module for Decoder
  - To be filled with case logic for PR_I1[15:12] and PR_I2[15:12]
  - Define SB_SIZE, ROB_SIZE, RRF_SIZE, R_CZ_SIZE, RS_AL_ENTRY_SIZE, RS_LS_ENTRY_SIZE, ROB_ENTRY_SIZE
*/

module Decoder #(
    parameter SB_SIZE           = 5,
    parameter ROB_SIZE          = 7,
    parameter RRF_SIZE          = 7,
    parameter R_CZ_SIZE         = 8,
    parameter RS_AL_ENTRY_SIZE  = 145,
    parameter RS_LS_ENTRY_SIZE  = 75,
    parameter ROB_ENTRY_SIZE    = 55
)(
    input  wire                     stall,
    input  wire [SB_SIZE-1:0]       SB_idx_1,
    input  wire [SB_SIZE-1:0]       SB_idx_2,
    input  wire [ROB_SIZE-1:0]      ROB_idx_1,
    input  wire [ROB_SIZE-1:0]      ROB_idx_2,
    input  wire [RRF_SIZE-1:0]      RRF_ptr_1,
    input  wire [RRF_SIZE-1:0]      RRF_ptr_2,
    input  wire [R_CZ_SIZE-1:0]     R_CZ_ptr_1,
    input  wire [R_CZ_SIZE-1:0]     R_CZ_ptr_2,
    input  wire [R_CZ_SIZE-1:0]     R_CZ_ptr_3,
    input  wire [R_CZ_SIZE-1:0]     R_CZ_ptr_4,
    input  wire [7:0]               ARF_B,
    input  wire [15:0]              ARF_D1,
    input  wire [15:0]              ARF_D2,
    input  wire [15:0]              ARF_D3,
    input  wire [15:0]              ARF_D4,
    input  wire [15:0]              ARF_D5,
    input  wire [15:0]              ARF_D6,
    input  wire [15:0]              ARF_D7,
    input  wire [RRF_SIZE-1:0]      ARF_tag_1,
    input  wire [RRF_SIZE-1:0]      ARF_tag_2,
    input  wire [RRF_SIZE-1:0]      ARF_tag_3,
    input  wire [RRF_SIZE-1:0]      ARF_tag_4,
    input  wire [RRF_SIZE-1:0]      ARF_tag_5,
    input  wire [RRF_SIZE-1:0]      ARF_tag_6,
    input  wire [RRF_SIZE-1:0]      ARF_tag_7,
    input  wire [7:0]               RRF_V_ARF_tags,
    input  wire [15:0]              RRF_D_ARF_tag_1,
    input  wire [15:0]              RRF_D_ARF_tag_2,
    input  wire [15:0]              RRF_D_ARF_tag_3,
    input  wire [15:0]              RRF_D_ARF_tag_4,
    input  wire [15:0]              RRF_D_ARF_tag_5,
    input  wire [15:0]              RRF_D_ARF_tag_6,
    input  wire [15:0]              RRF_D_ARF_tag_7,
    input  wire                     arch_C,
    input  wire                     arch_C_B,
    input  wire [R_CZ_SIZE-1:0]     arch_C_tag,
    input  wire                     arch_Z,
    input  wire                     arch_Z_B,
    input  wire [R_CZ_SIZE-1:0]     arch_Z_tag,
    input  wire                     R_CZ_V_arch_C_tag,
    input  wire                     R_CZ_D_arch_C_tag,
    input  wire                     R_CZ_V_arch_Z_tag,
    input  wire                     R_CZ_D_arch_Z_tag,
    input  wire [15:0]              PR_I1,
    input  wire                     PR_I1V,
    input  wire                     PR_I1P,
    input  wire [15:0]              PR_I1PC,
    input  wire [5:0]              PR_I1_prev_IMM,
    input  wire [15:0]              PR_I2,
    input  wire                     PR_I2V,
    input  wire                     PR_I2P,
    input  wire [15:0]              PR_I2PC,
    input  wire [5:0]              PR_I2_prev_IMM,

    output reg                      loop,
    output reg  [15:0]              I1_loop,
    output reg                      I1V_loop,
    output reg                      I1P_loop,
    output reg  [15:0]              I1PC_loop,
    output reg  [5:0]               I1IMM_loop,
    output reg  [15:0]              I2_loop,
    output reg                      I2V_loop,
    output reg                      I2P_loop,
    output reg  [15:0]              I2PC_loop,
    output reg  [5:0]               I2IMM_loop,

    output reg                      RS_AL_V1,
    output reg  [RS_AL_ENTRY_SIZE-1:0] RS_AL_1,
    output reg                      RS_AL_V2,
    output reg  [RS_AL_ENTRY_SIZE-1:0] RS_AL_2,
    output reg                      RS_LS_V1,
    output reg  [RS_LS_ENTRY_SIZE-1:0] RS_LS_1,
    output reg                      RS_LS_V2,
    output reg  [RS_LS_ENTRY_SIZE-1:0] RS_LS_2,
    output reg                      ROB_V1,
    output reg  [ROB_ENTRY_SIZE-1:0] ROB_1,
    output reg                      ROB_V2,
    output reg  [ROB_ENTRY_SIZE-1:0] ROB_2,

    output reg                      using_RRF_ptr_1,
    output reg                      using_RRF_ptr_2,
    output reg                      using_R_CZ_ptr_1,
    output reg                      using_R_CZ_ptr_2,
    output reg                      using_R_CZ_ptr_3,
    output reg                      using_R_CZ_ptr_4,

    output reg                      ARF_update_tag_1,
    output reg  [2:0]               ARF_new_reg_1,
    output reg  [RRF_SIZE-1:0]      ARF_new_tag_1,
    output reg                      ARF_update_tag_2,
    output reg  [2:0]               ARF_new_reg_2,
    output reg  [RRF_SIZE-1:0]      ARF_new_tag_2,
    output reg                      update_arch_C,
    output reg  [R_CZ_SIZE-1:0]     new_C_tag,
    output reg                      update_arch_Z,
    output reg  [R_CZ_SIZE-1:0]     new_Z_tag,

    output reg                      SB_reserve_1,
    output reg                      SB_reserve_2,




    input wire ALU1_D_W,
    input wire [15:0] ALU1_D,
    input wire [6:0] ALU1_D_RR,
    input wire ALU1_C_W,
    input wire ALU1_C,
    input wire [7:0] ALU1_C_RR,
    input wire ALU1_Z_W,
    input wire ALU1_Z,
    input wire [7:0] ALU1_Z_RR,

    input wire ALU2_D_W,
    input wire [15:0] ALU2_D,
    input wire [6:0] ALU2_D_RR,
    input wire ALU2_C_W,
    input wire ALU2_C,
    input wire [7:0] ALU2_C_RR,
    input wire ALU2_Z_W,
    input wire ALU2_Z,
    input wire [7:0] ALU2_Z_RR,

    input wire LS_D_W,
    input wire [15:0] LS_D,
    input wire [6:0] LS_D_RR,
    input wire LS_Z_W,
    input wire LS_Z,
    input wire [7:0] LS_Z_RR
);

reg [2:0] I1_arch_dest, I2_arch_dest;
reg [RRF_SIZE-1:0] I1_dest_tag_1, I2_dest_tag_1;
reg I1_W, I2_W;
reg I1_C_W, I2_C_W;
reg I1_Z_W, I2_Z_W;
reg [7:0] I1_C_tag, I2_C_tag;
reg [7:0] I1_Z_tag, I2_Z_tag;

// Wires and regs for LMSM splitter logic
wire is_LMSM_I1_out, is_LMSM_I2_out;
wire [15:0] uop_1_I_I1_out, uop_2_I_I1_out;
wire uop_1_V_I1_out, uop_2_V_I1_out;
wire [15:0] new_I1_out;
wire [5:0]  new_I1_IMM_out;
wire new_V1_out;

wire [15:0] uop_1_I_I2_out, uop_2_I_I2_out;
wire uop_1_V_I2_out, uop_2_V_I2_out;
wire [15:0] new_I2_out;
wire [5:0]  new_I2_IMM_out;
wire new_V2_out;

LMSM_splitter lmsm_splitter_1 (
    .I(PR_I1),
    .V(PR_I1V),
    .order(1'b0),
    .prev_IMM(PR_I1_prev_IMM),
    .is_LMSM(is_LMSM_I1_out),
    .uop_1_I(uop_1_I_I1_out),
    .uop_1_V(uop_1_V_I1_out),
    .uop_2_I(uop_2_I_I1_out),
    .uop_2_V(uop_2_V_I1_out),
    .new_I(new_I1_out),
    .new_V(new_V1_out),
    .new_IMM(new_I1_IMM_out)
);

LMSM_splitter lmsm_splitter_2 (
    .I(PR_I2),
    .V(PR_I2V),
    .order(1'b1),
    .prev_IMM(PR_I2_prev_IMM),
    .is_LMSM(is_LMSM_I2_out),
    .uop_1_I(uop_1_I_I2_out),
    .uop_1_V(uop_1_V_I2_out),
    .uop_2_I(uop_2_I_I2_out),
    .uop_2_V(uop_2_V_I2_out),
    .new_I(new_I2_out),
    .new_V(new_V2_out),
    .new_IMM(new_I2_IMM_out)
);

// Intermediate signals representing the instructions to be decoded by the main logic
reg [15:0] current_PR_I1;
reg        current_PR_I1V;
reg [15:0] current_PR_I1PC;
reg        current_PR_I1P;

reg [15:0] current_PR_I2;
reg        current_PR_I2V;
reg [15:0] current_PR_I2PC;
reg        current_PR_I2P;

// This block determines the actual instructions to feed into the decoder
// and handles loopback if an instruction is split.
always @(*) begin
    // Default assignments for loop signals (will be overridden if an instruction is split)
    loop           = 1'b0;
    I1_loop        = 16'b0;
    I1V_loop       = 1'b0;
    I1P_loop       = 1'b0;
    I1PC_loop      = 16'b0;
    I1IMM_loop     = 5'b0;
    I2_loop        = 16'b0;
    I2V_loop       = 1'b0;
    I2P_loop       = 1'b0;
    I2PC_loop      = 16'b0;
    I2IMM_loop     = 5'b0;

    if (is_LMSM_I1_out) begin
        // PR_I1 was LMSM. Split it into two uops.
        current_PR_I1 = uop_1_I_I1_out;
        current_PR_I1V = uop_1_V_I1_out;
        current_PR_I1PC = PR_I1PC;
        current_PR_I1P = PR_I1P;

        current_PR_I2 = uop_2_I_I1_out;
        current_PR_I2V = uop_2_V_I1_out;
        current_PR_I2PC = PR_I1PC;
        current_PR_I2P = PR_I1P;         

        // Original PR_I2 is looped back to be processed in the next cycle.
        loop = 1'b1;
        I1_loop = new_I1_out;
        I1V_loop = new_V1_out; // is 0 if LM/SM is done
        I1P_loop = PR_I1P;
        I1PC_loop = PR_I1PC;
        I1IMM_loop = new_I1_IMM_out;

        I2_loop = PR_I2;
        I2V_loop = PR_I2V;
        I2P_loop = PR_I2P;
        I2PC_loop = PR_I2PC;
    end else if (is_LMSM_I2_out) begin
        // PR_I1 was NOT LMSM, but PR_I2 IS LMSM.
        current_PR_I1 = PR_I1;       // Original PR_I1 (passed through splitter)
        current_PR_I1V = PR_I1V;
        current_PR_I1PC = PR_I1PC;
        current_PR_I1P = PR_I1P;

        current_PR_I2 = uop_1_I_I2_out;
        current_PR_I2V = uop_1_V_I2_out;
        current_PR_I2PC = PR_I2PC;
        current_PR_I2P = PR_I2P;

        loop = new_V2_out;
        I1_loop = new_I2_out;
        I1V_loop = new_V2_out; // is 0 if LM/SM is done
        I1P_loop = PR_I2P;
        I1PC_loop = PR_I2PC;
        I1IMM_loop = new_I2_IMM_out;
    end else begin
        // Neither PR_I1 nor PR_I2 are LMSM instructions that need splitting by the splitters.
        // Use the (pass-through) outputs.
        current_PR_I1 = PR_I1;
        current_PR_I1V = PR_I1V;
        current_PR_I1PC = PR_I1PC;
        current_PR_I1P = PR_I1P;

        current_PR_I2 = PR_I2;
        current_PR_I2V = PR_I2V;
        current_PR_I2PC = PR_I2PC;
        current_PR_I2P = PR_I2P;
        // loop signals remain at their default (0)
    end
end

// The main combinational decode logic (already in the user's code)
// will now use current_PR_I1, current_PR_I1V, current_PR_I1PC, current_PR_I1P
// and current_PR_I2, current_PR_I2V, current_PR_I2PC, current_PR_I2P
// instead of the direct PR_I* inputs.
// Also, the main combinational block should NOT assign to loop, I1_loop etc. anymore.

// -----------------------------------------------------------------------------
// Combinational decode logic
// -----------------------------------------------------------------------------
always @(*) begin
    RS_AL_V1       = 1'b0;
    RS_AL_1        = {RS_AL_ENTRY_SIZE{1'b0}};
    RS_AL_V2       = 1'b0;
    RS_AL_2        = {RS_AL_ENTRY_SIZE{1'b0}};
    RS_LS_V1       = 1'b0;
    RS_LS_1        = {RS_LS_ENTRY_SIZE{1'b0}};
    RS_LS_V2       = 1'b0;
    RS_LS_2        = {RS_LS_ENTRY_SIZE{1'b0}};
    ROB_V1         = 1'b0;
    ROB_1          = {ROB_ENTRY_SIZE{1'b0}};
    ROB_V2         = 1'b0;
    ROB_2          = {ROB_ENTRY_SIZE{1'b0}};
    using_RRF_ptr_1= 1'b0;
    using_RRF_ptr_2= 1'b0;
    using_R_CZ_ptr_1=1'b0;
    using_R_CZ_ptr_2=1'b0;
    using_R_CZ_ptr_3=1'b0;
    using_R_CZ_ptr_4=1'b0;
    ARF_update_tag_1=1'b0;
    ARF_new_reg_1  = 3'b0;
    ARF_new_tag_1  = {RRF_SIZE{1'b0}};
    ARF_update_tag_2=1'b0;
    ARF_new_reg_2  = 3'b0;
    ARF_new_tag_2  = {RRF_SIZE{1'b0}};
    update_arch_C  = 1'b0;
    new_C_tag      = {R_CZ_SIZE{1'b0}};
    update_arch_Z  = 1'b0;
    new_Z_tag      = {R_CZ_SIZE{1'b0}};
    SB_reserve_1   = 1'b0;
    SB_reserve_2   = 1'b0;

    I1_arch_dest   = 3'b0;
    I2_arch_dest   = 3'b0;
    I1_W           = 1'b0;
    I2_W           = 1'b0;
    I1_dest_tag_1  = {RRF_SIZE{1'b0}};
    I2_dest_tag_1  = {RRF_SIZE{1'b0}};
    I1_C_W         = 1'b0;
    I2_C_W         = 1'b0;
    I1_Z_W         = 1'b0;
    I2_Z_W         = 1'b0;
    I1_C_tag       = {R_CZ_SIZE{1'b0}};
    I2_C_tag       = {R_CZ_SIZE{1'b0}};
    I1_Z_tag       = {R_CZ_SIZE{1'b0}};
    I2_Z_tag       = {R_CZ_SIZE{1'b0}};

    if (stall == 1'b0) begin
        //Decoding I1
        if (current_PR_I1V == 1'b1) begin
            if (current_PR_I1[14] == 1'b0 || current_PR_I1[15:14] == 2'b11) begin // If I1 is an A/L instruction
                // Dispatch to RS_AL_1
                RS_AL_V1 = 1'b1;
                RS_AL_1[RS_AL_ENTRY_SIZE-1] = 1'b1; // Set valid bit
                RS_AL_1[RS_AL_ENTRY_SIZE-2:RS_AL_ENTRY_SIZE-5] = current_PR_I1[15:12]; // Set opcode

                //C/Z Write Conditions
                if(current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0000) begin // ADD instruction                        
                    RS_AL_1[RS_AL_ENTRY_SIZE-6:RS_AL_ENTRY_SIZE-7] = 2'b11; // Set C/Z write 
                    I1_C_W = 1'b1; // Set C write
                    I1_Z_W = 1'b1; // Set Z write
                end else if (current_PR_I1[15:12] == 4'b0010) begin // NAND instruction
                    RS_AL_1[RS_AL_ENTRY_SIZE-6:RS_AL_ENTRY_SIZE-7] = 2'b01; // Set Z write
                    I1_Z_W = 1'b1; // Set Z write
                end

                //OPR1 
                if (current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010 || current_PR_I1[15:14] == 2'b10 || current_PR_I1[15:12] == 4'b1111 || current_PR_I1[15:12] == 4'b0000) begin // If ADD or NAND or Branch or JRI or ADI instruction aka read OPR1 (A)
                    // Check if operand 1 is available
                    if (current_PR_I1[11:9] == 3'b000) begin // If operand 1 is R0
                        RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = current_PR_I1PC; // Use PC as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                    end else if (current_PR_I1[11:9] == 3'b001) begin // If operand 1 is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D1; // Use ARF_D1 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_1; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b010) begin // If operand 1 is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D2; // Use ARF_D2 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_2; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b011) begin // If operand 1 is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D3; // Use ARF_D3 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_3; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b100) begin // If operand 1 is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D4; // Use ARF_D4 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_4; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b101) begin // If operand 1 is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D5; // Use ARF_D5 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_5; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b110) begin // If operand 1 is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D6; // Use ARF_D6 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_6; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else begin // If operand 1 is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D7; // Use ARF_D7 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_7; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end
                end else begin // If operand 1 is not required
                    RS_AL_1[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = 16'b0; // Set operand 1 to 0
                    RS_AL_1[RS_AL_ENTRY_SIZE-24] = 1'b1; // Operand available
                end

                //OPR2
                if (current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010 || current_PR_I1[15:14] == 2'b10 || current_PR_I1[15:12] == 4'b1101) begin // If ADD or NAND or Branch or JLR instruction aka read OPR2
                    // Check if operand 2 is available
                    if (current_PR_I1[8:6] == 3'b000) begin // If operand 1 is R0
                        RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = current_PR_I1PC; // Use PC as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                    end else if (current_PR_I1[8:6] == 3'b001) begin // If operand 1 is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D1; // Use ARF_D1 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_1; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[8:6] == 3'b010) begin // If operand 1 is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D2; // Use ARF_D2 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_2; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[8:6] == 3'b011) begin // If operand 1 is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D3; // Use ARF_D3 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_3; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[8:6] == 3'b100) begin // If operand 1 is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D4; // Use ARF_D4 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_4; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[8:6] == 3'b101) begin // If operand 1 is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D5; // Use ARF_D5 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_5; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I1[8:6] == 3'b110) begin // If operand 1 is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D6; // Use ARF_D6 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_6; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else begin // If operand 1 is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D7; // Use ARF_D7 as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_7; // Operand available @ RRF
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end
                end else begin // If operand 1 is not required
                    RS_AL_1[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = 16'b0; // Set operand 1 to 0
                    RS_AL_1[RS_AL_ENTRY_SIZE-41] = 1'b1; // Operand available
                end

                //IMM
                if(current_PR_I1[15:12] == 4'b0000 || current_PR_I1[15:14] == 2'b10) begin // If ADI or JRI instruction aka IMM6, signed
                    RS_AL_1[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(10){current_PR_I1[5]}}, current_PR_I1[5:0] }; // Set immediate value
                end else if (current_PR_I1[15:12] == 4'b1100 || current_PR_I1[15:12] == 4'b1111) begin // If JAL or JRI instruction aka IMM9, signed
                    RS_AL_1[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(7){current_PR_I1[8]}}, current_PR_I1[8:0] }; // Set immediate value
                end else if (current_PR_I1[15:12] == 4'b0011) begin // If LLI instruction aka IMM9, unsigned
                    RS_AL_1[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(7){1'b0}}, current_PR_I1[8:0] }; // Set immediate value
                end

                // Neg 2, C, Z conditions
                if(current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010) begin // If ADD or NAND instruction
                    RS_AL_1[RS_AL_ENTRY_SIZE-58:RS_AL_ENTRY_SIZE-60] = current_PR_I1[2:0]; // Set neg2, C, Z conditions
                end

                // Carry Flag
                if ( ( current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010 ) && current_PR_I1[1:0] == 2'b10) begin // If ADD or NAND instruction and C is required to check
                    if (arch_C_B == 1'b0) begin // Check if Arch C is not busy
                        RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){arch_C}}; // Use arch_C
                        RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                    end else if (R_CZ_V_arch_C_tag == 1'b1) begin // Check if R_C is valid
                        RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){R_CZ_D_arch_C_tag}}; // C available @ R_C
                        RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                    end else if (ALU1_C_W == 1'b1 && ALU1_C_RR == arch_C_tag) begin // Check if ALU1 is writing to R1
                        RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){ALU1_C}}; // Use ALU1_D as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_C_W == 1'b1 && ALU2_C_RR == arch_C_tag) begin // Check if ALU2 is writing to R1
                        RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] =  {(8){ALU2_C}}; // Use ALU2_D as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set operand 1 valid
                    end else begin // C not available
                        RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = arch_C_tag;
                        RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b0; // C not available
                    end
                end else begin
                    RS_AL_1[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = 8'b0;
                    RS_AL_1[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                end

                // Zero Flag
                if ( ( current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010 ) && current_PR_I1[1:0] == 2'b01) begin // If ADD or NAND instruction and Z is required to check
                    if (arch_Z_B == 1'b0) begin // Check if Arch Z is not busy
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){arch_Z}}; // Use arch_Z
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                    end else if (R_CZ_V_arch_Z_tag == 1'b1) begin // Check if R_Z is valid
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){R_CZ_D_arch_Z_tag}}; // X available @ R_Z
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                    end else if (ALU1_Z_W == 1'b1 && ALU1_Z_RR == arch_Z_tag) begin // Check if ALU1 is writing to R1
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){ALU1_Z}}; // Use ALU1_D as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_Z_W == 1'b1 && ALU2_Z_RR == arch_Z_tag) begin // Check if ALU2 is writing to R1
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){ALU2_Z}}; // Use ALU2_D as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else if (LS_Z_W == 1'b1 && LS_Z_RR == arch_Z_tag) begin // Check if LS is writing to R1
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = LS_Z; // Use LS_D as operand 1
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else begin // Z not available
                        RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = arch_Z_tag;
                        RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b0; // Z not available
                    end
                end else begin
                    RS_AL_1[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = 8'b0;
                    RS_AL_1[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                end

                // Set destination register & prev dest
                if (current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010) begin // If ADD or NAND instruction aka Dest is C
                    I1_arch_dest = current_PR_I1[5:3]; // Set destination register
                    if (current_PR_I1[5:3] != 3'b000) begin
                        I1_W = 1'b1; // Set write flag

                        I1_dest_tag_1 = RRF_ptr_1; // Set destination tag
                        RS_AL_1[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_1; // Set destination tag
                        using_RRF_ptr_1 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_1 = 1'b1; // Set ARF update tag
                        ARF_new_reg_1 = current_PR_I1[5:3]; // Set new register
                        ARF_new_tag_1 = RRF_ptr_1; // Set new tag

                        if (ARF_B[current_PR_I1[5:3]] == 1'b0) begin // Check if Arch C is not busy
                            // Assign ARF_D value (indexed by current_PR_I1[5:3]) to prev_dest field (truncated)
                            case (current_PR_I1[5:3])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D1;
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D2;
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D3;
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D4;
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D5;
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D6;
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D7;
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[5:3] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[current_PR_I1[5:3]] == 1'b1) begin // Check if RRF is valid
                            case (current_PR_I1[5:3])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_1;
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_2;
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_3;
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_4;
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_5;
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_6;
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_7;
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[5:3] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            case (current_PR_I1[5:3])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[5:3] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end
                    end
                end else if (current_PR_I1[15:12] == 4'b0000) begin // If ADI instruction aka Dest is B
                    I1_arch_dest = current_PR_I1[8:6]; // Set destination register
                    if (current_PR_I1[8:6] != 3'b000) begin
                        I1_W = 1'b1; // Set write flag
                        I1_dest_tag_1 = RRF_ptr_1; // Set destination tag
                        RS_AL_1[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_1; // Set destination tag
                        using_RRF_ptr_1 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_1 = 1'b1; // Set ARF update tag
                        ARF_new_reg_1 = current_PR_I1[8:6]; // Set new register
                        ARF_new_tag_1 = RRF_ptr_1; // Set new tag

                        if (ARF_B[current_PR_I1[8:6]] == 1'b0) begin // Check if Arch C is not busy
                            // Assign ARF_D value (indexed by current_PR_I1[8:6]) to prev_dest field (truncated)
                            case (current_PR_I1[8:6])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D1;
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D2;
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D3;
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D4;
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D5;
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D6;
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D7;
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[8:6] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[current_PR_I1[8:6]] == 1'b1) begin // Check if RRF is valid
                            case (current_PR_I1[8:6])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_1;
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_2;
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_3;
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_4;
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_5;
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_6;
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_7;
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[8:6] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            case (current_PR_I1[8:6])
                                3'b001: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                                3'b010: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                                3'b011: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                                3'b100: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                                3'b101: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                                3'b110: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                                3'b111: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                                default: RS_AL_1[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I1[8:6] is 1-7
                            endcase
                            RS_AL_1[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end
                    end
                end else if (current_PR_I1[15:12] == 4'b1101 || current_PR_I1[15:12] == 4'b1100 || current_PR_I1[15:12] == 4'b0011) begin // If JLR or JAL or LLI instruction aka Dest is A
                    I1_arch_dest = current_PR_I1[11:9]; // Set destination register
                    if (current_PR_I1[11:9] != 3'b000) begin
                        I1_W = 1'b1; // Set write flag
                        I1_dest_tag_1 = RRF_ptr_1; // Set destination tag
                        RS_AL_1[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_1; // Set destination tag
                        using_RRF_ptr_1 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_1 = 1'b1; // Set ARF update tag
                        ARF_new_reg_1 = current_PR_I1[11:9]; // Set new register
                        ARF_new_tag_1 = RRF_ptr_1; // Set new tag
                    end
                end

                //Set Carry Destination register
                if(current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0000) begin // If ADD or ADI instruction 
                    I1_C_tag = R_CZ_ptr_1; // Set Carry destination tag
                    RS_AL_1[RS_AL_ENTRY_SIZE-103:RS_AL_ENTRY_SIZE-110] = R_CZ_ptr_1; // Set Carry destination tag
                    using_R_CZ_ptr_1 = 1'b1; // Set R_CZ pointer usage
                    update_arch_C = 1'b1; // Set update arch C
                    new_C_tag = R_CZ_ptr_1; // Set new Carry tag
                end

                //Set Zero Destination register
                if(current_PR_I1[15:12] == 4'b0001 || current_PR_I1[15:12] == 4'b0010 || current_PR_I1[15:12] == 4'b0000) begin // If ADD or ADI or NAND instruction 
                    I1_Z_tag = R_CZ_ptr_2; // Set Zero destination tag
                    RS_AL_1[RS_AL_ENTRY_SIZE-111:RS_AL_ENTRY_SIZE-118] = R_CZ_ptr_2; // Set Zero destination tag
                    using_R_CZ_ptr_2 = 1'b1; // Set R_CZ pointer usage
                    update_arch_Z = 1'b1; // Set update arch Z
                    new_Z_tag = R_CZ_ptr_2; // Set new Zero tag
                end

                //Set prediction
                RS_AL_1[RS_AL_ENTRY_SIZE-119] = current_PR_I1P; // Set prediction

                //Set PC 
                RS_AL_1[RS_AL_ENTRY_SIZE-120:RS_AL_ENTRY_SIZE-135] = current_PR_I1PC; // Set PC

                //Set ROB Index
                RS_AL_1[RS_AL_ENTRY_SIZE-136:RS_AL_ENTRY_SIZE-142] = ROB_idx_1; // Set ROB index

                RS_AL_1[RS_AL_ENTRY_SIZE-143:RS_AL_ENTRY_SIZE-145] = I1_arch_dest; // Set destination register

                ROB_V1 = 1'b1; // Set ROB valid
                ROB_1 = {current_PR_I1[15:12], I1_arch_dest, I1_dest_tag_1, current_PR_I1PC, I1_C_W, I1_C_tag, I1_Z_W, I1_Z_tag, 5'b0, I1_W, 1'b0};
            end else begin // If instruction is L/S instruction [LW/SW ONLY]
                RS_LS_V1 = 1'b1; // Set RS_LS valid
                RS_LS_1[RS_LS_ENTRY_SIZE-1] = 1'b1; // Set RS_LS valid

                //Load(0) or Store(1)
                RS_LS_1[RS_LS_ENTRY_SIZE-2] = current_PR_I1[12]; // Set Load/Store flag

                //Base address (B)
                if (current_PR_I1[8:6] == 3'b000) begin // If Base is R0
                    RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = current_PR_I1PC; // Use PC as Base
                    RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                end else if (current_PR_I1[8:6] == 3'b001) begin // If Base is R1
                    if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D1; // Use ARF_D1 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_1; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I1[8:6] == 3'b010) begin // If Base is R2
                    if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D2; // Use ARF_D2 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_2; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I1[8:6] == 3'b011) begin // If Base is R3
                    if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D3; // Use ARF_D3 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_3; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I1[8:6] == 3'b100) begin // If Base is R4
                    if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D4; // Use ARF_D4 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_4; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I1[8:6] == 3'b101) begin // If Base is R5
                    if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D5; // Use ARF_D5 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_5; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I1[8:6] == 3'b110) begin // If Base is R6
                    if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D6; // Use ARF_D6 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_6; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else begin // If Base is R7
                    if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D7; // Use ARF_D7 as Base
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_7; // Base available @ RRF
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_1[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                        RS_LS_1[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end

                //Offset, IMM6, Sign Ext
                RS_LS_1[RS_LS_ENTRY_SIZE-20:RS_LS_ENTRY_SIZE-35] = {{(10){current_PR_I1[5]}}, current_PR_I1[5:0]}; // Set Offset

                //Source register (A) for Store
                if (current_PR_I1[12] == 1'b1) begin // If Store instruction
                    if (current_PR_I1[11:9] == 3'b000) begin // If Source is R0
                        RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = current_PR_I1PC; // Use PC as Source
                        RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                    end else if (current_PR_I1[11:9] == 3'b001) begin // If Source is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D1; // Use ARF_D1 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_1; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b010) begin // If Source is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D2; // Use ARF_D2 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_2; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b011) begin // If Source is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D3; // Use ARF_D3 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_3; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b100) begin // If Source is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D4; // Use ARF_D4 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_4; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b101) begin // If Source is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D5; // Use ARF_D5 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_5; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I1[11:9] == 3'b110) begin // If Source is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D6; // Use ARF_D6 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_6; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else begin // If Source is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D7; // Use ARF_D7 as Source
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_7; // Source available @ RRF
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_1[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_LS_1[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end

                    // Store Buffer
                    RS_LS_1[RS_LS_ENTRY_SIZE-53:RS_LS_ENTRY_SIZE-57] = SB_idx_1; // Set Store Buffer index
                    SB_reserve_1 = 1'b1; // Set Store Buffer reserve
                end else begin // If Load
                    I1_arch_dest = current_PR_I1[11:9]; // Set destination register
                    if (current_PR_I1[11:9] != 3'b000) begin
                        I1_W = 1'b1; // Set write flag
                        I1_dest_tag_1 = RRF_ptr_1; // Set destination tag
                        RS_LS_1[RS_LS_ENTRY_SIZE-58:RS_LS_ENTRY_SIZE-64] = RRF_ptr_1; // Set destination tag
                        using_RRF_ptr_1 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_1 = 1'b1; // Set ARF update tag
                        ARF_new_reg_1 = current_PR_I1[11:9]; // Set new register
                        ARF_new_tag_1 = RRF_ptr_1; // Set new tag
                    end
                end

                RS_LS_1[RS_LS_ENTRY_SIZE-65:RS_LS_ENTRY_SIZE-71] = ROB_idx_1; // Set ROB index

                RS_LS_1[RS_LS_ENTRY_SIZE-72:RS_LS_ENTRY_SIZE-74] = I1_arch_dest; // Set destination register

                RS_LS_1[RS_LS_ENTRY_SIZE-75] = is_LMSM_I1_out; // Set LMSM flag [for ZERO Flag]

                ROB_V1 = 1'b1; // Set ROB valid
                ROB_1 = {current_PR_I1[15:12], I1_arch_dest, I1_dest_tag_1, current_PR_I1PC, 18'b0, SB_idx_1, I1_W, is_LMSM_I1_out}; // Set ROB entry
            end
        end

        // Decode I2
        if (current_PR_I2V == 1'b1) begin
            if (current_PR_I2[14] == 1'b0 || current_PR_I2[15:14] == 2'b11) begin // If I1 is an A/L instruction
                // Dispatch to RS_AL_2
                RS_AL_V2 = 1'b1;
                RS_AL_2[RS_AL_ENTRY_SIZE-1] = 1'b1; // Set valid bit
                RS_AL_2[RS_AL_ENTRY_SIZE-2:RS_AL_ENTRY_SIZE-5] = current_PR_I2[15:12]; // Set opcode

                //C/Z Write Conditions
                if(current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0000) begin // ADD instruction                        
                    RS_AL_2[RS_AL_ENTRY_SIZE-6:RS_AL_ENTRY_SIZE-7] = 2'b11; // Set C/Z write 
                    I2_C_W = 1'b1; // Set C write
                    I2_Z_W = 1'b1; // Set Z write
                end else if (current_PR_I2[15:12] == 4'b0010) begin // NAND instruction
                    RS_AL_2[RS_AL_ENTRY_SIZE-6:RS_AL_ENTRY_SIZE-7] = 2'b01; // Set Z write
                    I2_Z_W = 1'b1; // Set Z write
                end

                //OPR1  RS_AL_2
                if (current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010 || current_PR_I2[15:14] == 2'b10 || current_PR_I2[15:12] == 4'b1111 || current_PR_I2[15:12] == 4'b0000) begin // If ADD or NAND or Branch or JRI or ADI instruction aka read OPR1 (A)
                    // Check if operand 1 is available
                    if (current_PR_I2[11:9] == 3'b000) begin // If operand 1 is R0
                        RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = current_PR_I2PC; // Use PC as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                    end else if (I1_W == 1'b1 && I1_arch_dest == current_PR_I2[11:9]) begin// If operand 1 is the same as destination register
                        RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                    end else if (current_PR_I2[11:9] == 3'b001) begin // If operand 1 is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D1; // Use ARF_D1 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_1; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b010) begin // If operand 1 is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D2; // Use ARF_D2 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_2; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b011) begin // If operand 1 is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D3; // Use ARF_D3 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_3; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b100) begin // If operand 1 is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D4; // Use ARF_D4 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_4; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid

                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b101) begin // If operand 1 is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D5; // Use ARF_D5 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_5; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b110) begin // If operand 1 is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D6; // Use ARF_D6 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_6; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end else begin // If operand 1 is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ARF_D7; // Use ARF_D7 as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = RRF_D_ARF_tag_7; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b0; // Operand not available
                        end
                    end
                end else begin // If operand 1 is not required
                    RS_AL_2[RS_AL_ENTRY_SIZE-8:RS_AL_ENTRY_SIZE-23] = 16'b0; // Set operand 1 to 0
                    RS_AL_2[RS_AL_ENTRY_SIZE-24] = 1'b1; // Operand available
                end

                //OPR2
                if (current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010 || current_PR_I2[15:14] == 2'b10 || current_PR_I2[15:12] == 4'b1101) begin // If ADD or NAND or Branch or JLR instruction aka read OPR2
                    // Check if operand 2 is available
                    if (current_PR_I2[8:6] == 3'b000) begin // If operand 2 is R0
                        RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = current_PR_I2PC; // Use PC as operand 2
                        RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                    end else if (I1_W == 1'b1 && I1_arch_dest == current_PR_I2[8:6]) begin// If operand 2 is the same as destination register
                        RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as operand 2
                        RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                    end else if (current_PR_I2[8:6] == 3'b001) begin // If operand 2 is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D1; // Use ARF_D1 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_1; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[8:6] == 3'b010) begin // If operand 2 is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D2; // Use ARF_D2 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_2; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[8:6] == 3'b011) begin // If operand 2 is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D3; // Use ARF_D3 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_3; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[8:6] == 3'b100) begin // If operand 2 is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D4; // Use ARF_D4 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_4; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[8:6] == 3'b101) begin // If operand 2 is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D5; // Use ARF_D5 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_5; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else if (current_PR_I2[8:6] == 3'b110) begin // If operand 2 is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D6; // Use ARF_D6 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_6; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end else begin // If operand 2 is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ARF_D7; // Use ARF_D7 as operand 2
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = RRF_D_ARF_tag_7; // Operand available @ RRF
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 2 valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU1_D; // Use ALU1_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = ALU2_D; // Use ALU2_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = LS_D; // Use LS_D as operand 1
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b0; // Operand not available
                        end
                    end
                end else begin // If operand 2 is not required
                    RS_AL_2[RS_AL_ENTRY_SIZE-25:RS_AL_ENTRY_SIZE-40] = 16'b0; // Set operand 2 to 0
                    RS_AL_2[RS_AL_ENTRY_SIZE-41] = 1'b1; // Operand available
                end

                //IMM
                if(current_PR_I2[15:12] == 4'b0000 || current_PR_I2[15:14] == 2'b10) begin // If ADI or JRI instruction aka IMM6, signed
                    RS_AL_2[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(10){current_PR_I2[5]}}, current_PR_I2[5:0] }; // Set immediate value
                end else if (current_PR_I2[15:12] == 4'b1100 || current_PR_I2[15:12] == 4'b1111) begin // If JAL or JRI instruction aka IMM9, signed
                    RS_AL_2[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(7){current_PR_I2[8]}}, current_PR_I2[8:0] }; // Set immediate value
                end else if (current_PR_I2[15:12] == 4'b0011) begin // If LLI instruction aka IMM9, unsigned
                    RS_AL_2[RS_AL_ENTRY_SIZE-42:RS_AL_ENTRY_SIZE-57] = { {(7){1'b0}}, current_PR_I2[8:0] }; // Set immediate value
                end

                // Neg 2, C, Z conditions
                if(current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010) begin // If ADD or NAND instruction
                    RS_AL_2[RS_AL_ENTRY_SIZE-58:RS_AL_ENTRY_SIZE-60] = current_PR_I2[2:0]; // Set neg2, C, Z conditions
                end

                // Carry Flag
                if ( ( current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010 ) && current_PR_I2[1:0] == 2'b10) begin // If ADD or NAND instruction and C is required to check
                    if (I1_C_W == 1'b1) begin // Check if I1 is writing to C
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = I1_C_tag; // Use I1 C tag as C
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b0; // C not available
                    end else if (arch_C_B == 1'b0) begin // Check if Arch C is not busy
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){arch_C}}; // Use arch_C
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                    end else if (R_CZ_V_arch_C_tag == 1'b1) begin // Check if R_C is valid
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){R_CZ_D_arch_C_tag}}; // C available @ R_C
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                    end else if (ALU1_C_W == 1'b1 && ALU1_C_RR == arch_C_tag) begin // Check if ALU1 is writing to R1
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = {(8){ALU1_C}}; // Use ALU1_D as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_C_W == 1'b1 && ALU2_C_RR == arch_C_tag) begin // Check if ALU2 is writing to R1
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] =  {(8){ALU2_C}}; // Use ALU2_D as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set operand 1 valid
                    end else begin // C not available
                        RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = arch_C_tag;
                        RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b0; // C not available
                    end
                end else begin
                    RS_AL_2[RS_AL_ENTRY_SIZE-61:RS_AL_ENTRY_SIZE-68] = 8'b0;
                    RS_AL_2[RS_AL_ENTRY_SIZE-69] = 1'b1; // Set C valid
                end

                // Zero Flag
                if ( ( current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010 ) && current_PR_I2[1:0] == 2'b01) begin // If ADD or NAND instruction and Z is required to check
                    if (I1_Z_W == 1'b1) begin // Check if I1 is writing to Z
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = I1_Z_tag; // Use I1 Z tag as Z
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b0; // Z not available
                    end else if (arch_Z_B == 1'b0) begin // Check if Arch Z is not busy
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){arch_Z}}; // Use arch_Z
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                    end else if (R_CZ_V_arch_Z_tag == 1'b1) begin // Check if R_Z is valid
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){R_CZ_D_arch_Z_tag}}; // X available @ R_Z
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                    end else if (ALU1_Z_W == 1'b1 && ALU1_Z_RR == arch_Z_tag) begin // Check if ALU1 is writing to R1
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){ALU1_Z}}; // Use ALU1_D as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_Z_W == 1'b1 && ALU2_Z_RR == arch_Z_tag) begin // Check if ALU2 is writing to R1
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = {(8){ALU2_Z}}; // Use ALU2_D as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else if (LS_Z_W == 1'b1 && LS_Z_RR == arch_Z_tag) begin // Check if LS is writing to R1
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = LS_Z; // Use LS_D as operand 1
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set operand 1 valid
                    end else begin // Z not available
                        RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = arch_Z_tag;
                        RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b0; // Z not available
                    end
                end else begin
                    RS_AL_2[RS_AL_ENTRY_SIZE-70:RS_AL_ENTRY_SIZE-77] = 8'b0;
                    RS_AL_2[RS_AL_ENTRY_SIZE-78] = 1'b1; // Set Z valid
                end

                // Set destination register & prev dest
                if (current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010) begin // If ADD or NAND instruction aka Dest is C
                    I2_arch_dest = current_PR_I2[5:3]; // Set destination register
                    if (current_PR_I2[5:3] != 3'b000) begin
                        I2_W = 1'b1; // Set write flag

                        I2_dest_tag_1 = RRF_ptr_2; // Set destination tag
                        RS_AL_2[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_2; // Set destination tag
                        using_RRF_ptr_2 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_2 = 1'b1; // Set ARF update tag
                        ARF_new_reg_2 = current_PR_I2[5:3]; // Set new register
                        ARF_new_tag_2 = RRF_ptr_2; // Set new tag


                        if (I1_W == 1'b1 && current_PR_I2[5:3] == I1_arch_dest) begin // Check if destination register is the same as I1 destination register
                            RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as prev dest
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end else if (ARF_B[current_PR_I2[5:3]] == 1'b0) begin // Check if Arch Reg is not busy
                            // Assign ARF_D value (indexed by current_PR_I2[5:3]) to prev_dest field (truncated)
                            case (current_PR_I2[5:3])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D1;
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D2;
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D3;
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D4;
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D5;
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D6;
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D7;
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[5:3] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[current_PR_I2[5:3]] == 1'b1) begin // Check if RRF is valid
                            case (current_PR_I2[5:3])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_1;
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_2;
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_3;
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_4;
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_5;
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_6;
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_7;
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[5:3] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            case (current_PR_I2[5:3])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[5:3] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end
                    end
                end else if (current_PR_I2[15:12] == 4'b0000) begin // If ADI instruction aka Dest is B
                    I2_arch_dest = current_PR_I2[8:6]; // Set destination register
                    if (current_PR_I2[8:6] != 3'b000) begin
                        I2_W = 1'b1; // Set write flag
                        I2_dest_tag_1 = RRF_ptr_2; // Set destination tag
                        RS_AL_2[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_2; // Set destination tag
                        using_RRF_ptr_2 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_2 = 1'b1; // Set ARF update tag
                        ARF_new_reg_2 = current_PR_I2[8:6]; // Set new register
                        ARF_new_tag_2 = RRF_ptr_2; // Set new tag

                        if (I1_W == 1'b1 && current_PR_I2[8:6] == I1_arch_dest) begin // Check if destination register is the same as I1 destination register
                            RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as prev dest
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end else if (ARF_B[current_PR_I2[8:6]] == 1'b0) begin // Check if Arch C is not busy
                            // Assign ARF_D value (indexed by current_PR_I2[8:6]) to prev_dest field (truncated)
                            case (current_PR_I2[8:6])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D1;
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D2;
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D3;
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D4;
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D5;
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D6;
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = ARF_D7;
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[8:6] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else if (RRF_V_ARF_tags[current_PR_I2[8:6]] == 1'b1) begin // Check if RRF is valid
                            case (current_PR_I2[8:6])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_1;
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_2;
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_3;
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_4;
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_5;
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_6;
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = RRF_D_ARF_tag_7;
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[8:6] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b1; // Set operand 1 valid
                        end else begin // Operand not available
                            case (current_PR_I2[8:6])
                                3'b001: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                                3'b010: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                                3'b011: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                                3'b100: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                                3'b101: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                                3'b110: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                                3'b111: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                                default: RS_AL_2[RS_AL_ENTRY_SIZE-86:RS_AL_ENTRY_SIZE-101] = 16'dx; // Should not be reached if current_PR_I2[8:6] is 1-7
                            endcase
                            RS_AL_2[RS_AL_ENTRY_SIZE-102] = 1'b0; // Operand not available
                        end
                    end
                end else if (current_PR_I2[15:12] == 4'b1101 || current_PR_I2[15:12] == 4'b1100 || current_PR_I2[15:12] == 4'b0011) begin // If JLR or JAL or LLI instruction aka Dest is A
                    I2_arch_dest = current_PR_I2[11:9]; // Set destination register
                    if (current_PR_I2[11:9] != 3'b000) begin
                        I2_W = 1'b1; // Set write flag
                        I2_dest_tag_1 = RRF_ptr_2; // Set destination tag
                        RS_AL_2[RS_AL_ENTRY_SIZE-79:RS_AL_ENTRY_SIZE-85] = RRF_ptr_2; // Set destination tag
                        using_RRF_ptr_2 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_2 = 1'b1; // Set ARF update tag
                        ARF_new_reg_2 = current_PR_I2[11:9]; // Set new register
                        ARF_new_tag_2 = RRF_ptr_2; // Set new tag
                    end
                end

                //Set Carry Destination register
                if(current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0000) begin // If ADD or ADI instruction 
                    I2_C_tag = R_CZ_ptr_3; // Set Carry destination tag
                    RS_AL_2[RS_AL_ENTRY_SIZE-103:RS_AL_ENTRY_SIZE-110] = R_CZ_ptr_3; // Set Carry destination tag
                    using_R_CZ_ptr_3 = 1'b1; // Set R_CZ pointer usage
                    update_arch_C = 1'b1; // Set update arch C
                    new_C_tag = R_CZ_ptr_3; // Set new Carry tag
                end

                //Set Zero Destination register
                if(current_PR_I2[15:12] == 4'b0001 || current_PR_I2[15:12] == 4'b0010 || current_PR_I2[15:12] == 4'b0000) begin // If ADD or ADI or NAND instruction 
                    I2_Z_tag = R_CZ_ptr_4; // Set Zero destination tag
                    RS_AL_2[RS_AL_ENTRY_SIZE-111:RS_AL_ENTRY_SIZE-118] = R_CZ_ptr_4; // Set Zero destination tag
                    using_R_CZ_ptr_4 = 1'b1; // Set R_CZ pointer usage
                    update_arch_Z = 1'b1; // Set update arch Z
                    new_Z_tag = R_CZ_ptr_4; // Set new Zero tag
                end

                //Set prediction
                RS_AL_2[RS_AL_ENTRY_SIZE-119] = current_PR_I2P; // Set prediction

                //Set PC 
                RS_AL_2[RS_AL_ENTRY_SIZE-120:RS_AL_ENTRY_SIZE-135] = current_PR_I2PC; // Set PC

                //Set ROB Index
                if (ROB_V1 == 1'b0) begin
                    RS_AL_2[RS_AL_ENTRY_SIZE-136:RS_AL_ENTRY_SIZE-142] = ROB_idx_1; // Set ROB index
                    RS_AL_2[RS_AL_ENTRY_SIZE-143:RS_AL_ENTRY_SIZE-145] = I2_arch_dest; // Set destination register
                    ROB_V1 = 1'b1; // Set ROB valid
                    ROB_1 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, I2_C_W, I2_C_tag, I2_Z_W, I2_Z_tag, 5'b0, I2_W, 1'b0};
                end else begin
                    RS_AL_2[RS_AL_ENTRY_SIZE-136:RS_AL_ENTRY_SIZE-142] = ROB_idx_2; // Set ROB index
                    RS_AL_2[RS_AL_ENTRY_SIZE-143:RS_AL_ENTRY_SIZE-145] = I2_arch_dest; // Set destination register
                    ROB_V2 = 1'b1; // Set ROB valid
                    ROB_2 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, I2_C_W, I2_C_tag, I2_Z_W, I2_Z_tag, 5'b0, I2_W, 1'b0};
                end
                
            end else begin // If instruction is L/S instruction [LW/SW ONLY]
                RS_LS_V2 = 1'b1; // Set RS_LS valid
                RS_LS_2[RS_LS_ENTRY_SIZE-1] = 1'b1; // Set RS_LS valid

                //Load(0) or Store(1)
                RS_LS_2[RS_LS_ENTRY_SIZE-2] = current_PR_I2[12]; // Set Load/Store flag

                //Base address (B)
                if (current_PR_I2[8:6] == 3'b000) begin // If Base is R0
                    RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = current_PR_I2PC; // Use PC as Base
                    RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                end else if (I1_W == 1'b1 && I1_arch_dest == current_PR_I2[8:6]) begin// If base is the same as destination register
                    RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as base
                    RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                end else if (current_PR_I2[8:6] == 3'b001) begin // If Base is R1
                    if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D1; // Use ARF_D1 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_1; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I2[8:6] == 3'b010) begin // If Base is R2
                    if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D2; // Use ARF_D2 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_2; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I2[8:6] == 3'b011) begin // If Base is R3
                    if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D3; // Use ARF_D3 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_3; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I2[8:6] == 3'b100) begin // If Base is R4
                    if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D4; // Use ARF_D4 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_4; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I2[8:6] == 3'b101) begin // If Base is R5
                    if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D5; // Use ARF_D5 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_5; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else if (current_PR_I2[8:6] == 3'b110) begin // If Base is R6
                    if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D6; // Use ARF_D6 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_6; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end else begin // If Base is R7
                    if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ARF_D7; // Use ARF_D7 as Base
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = RRF_D_ARF_tag_7; // Base available @ RRF
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set Base valid
                    end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU1_D; // Use ALU1_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = ALU2_D; // Use ALU2_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = LS_D; // Use LS_D as operand 1
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b1; // Set operand 1 valid
                    end else begin // Base not available
                        RS_LS_2[RS_LS_ENTRY_SIZE-3:RS_LS_ENTRY_SIZE-18] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                        RS_LS_2[RS_LS_ENTRY_SIZE-19] = 1'b0; // Base not available
                    end
                end

                //Offset, IMM6, Sign Ext
                RS_LS_2[RS_LS_ENTRY_SIZE-20:RS_LS_ENTRY_SIZE-35] = {{(10){current_PR_I2[5]}}, current_PR_I2[5:0]}; // Set Offset

                //Source register (A) for Store
                if (current_PR_I2[12] == 1'b1) begin // If Store instruction
                    if (current_PR_I2[11:9] == 3'b000) begin // If Source is R0
                        RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = current_PR_I2PC; // Use PC as Source
                        RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                    end else if (I1_W == 1'b1 && I1_arch_dest == current_PR_I2[11:9]) begin// If base is the same as destination register
                        RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, I1_dest_tag_1 }; // Use I1 destination tag as base
                        RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Base not available
                    end else if (current_PR_I2[11:9] == 3'b001) begin // If Source is R1
                        if (ARF_B[1] == 1'b0) begin // Check if Arch R1 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D1; // Use ARF_D1 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[1] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_1; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_1) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_1) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_1) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_1 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b010) begin // If Source is R2
                        if (ARF_B[2] == 1'b0) begin // Check if Arch R2 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D2; // Use ARF_D2 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[2] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_2; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_2) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_2) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_2) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_2 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b011) begin // If Source is R3
                        if (ARF_B[3] == 1'b0) begin // Check if Arch R3 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D3; // Use ARF_D3 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[3] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_3; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_3) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_3) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_3) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_3 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b100) begin // If Source is R4
                        if (ARF_B[4] == 1'b0) begin // Check if Arch R4 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D4; // Use ARF_D4 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[4] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_4; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_4) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_4) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_4) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_4 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b101) begin // If Source is R5
                        if (ARF_B[5] == 1'b0) begin // Check if Arch R5 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D5; // Use ARF_D5 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[5] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_5; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_5) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_5) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_5) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_5 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else if (current_PR_I2[11:9] == 3'b110) begin // If Source is R6
                        if (ARF_B[6] == 1'b0) begin // Check if Arch R6 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D6; // Use ARF_D6 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[6] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_6; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_6) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_6) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_6) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_6 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end else begin // If Source is R7
                        if (ARF_B[7] == 1'b0) begin // Check if Arch R7 is not busy
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ARF_D7; // Use ARF_D7 as Source
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (RRF_V_ARF_tags[7] == 1'b1) begin // Check if RRF is valid
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = RRF_D_ARF_tag_7; // Source available @ RRF
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set Source valid
                        end else if (ALU1_D_W == 1'b1 && ALU1_D_RR == ARF_tag_7) begin // Check if ALU1 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU1_D; // Use ALU1_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (ALU2_D_W == 1'b1 && ALU2_D_RR == ARF_tag_7) begin // Check if ALU2 is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = ALU2_D; // Use ALU2_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else if (LS_D_W == 1'b1 && LS_D_RR == ARF_tag_7) begin // Check if LS is writing to R1
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = LS_D; // Use LS_D as operand 1
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b1; // Set operand 1 valid
                        end else begin // Source not available
                            RS_LS_2[RS_LS_ENTRY_SIZE-36:RS_LS_ENTRY_SIZE-51] = { {(16-RRF_SIZE){1'b0}}, ARF_tag_7 };
                            RS_LS_2[RS_LS_ENTRY_SIZE-52] = 1'b0; // Source not available
                        end
                    end

                    // Store Buffer
                    if (SB_reserve_1 == 1'b0) begin
                        RS_LS_2[RS_LS_ENTRY_SIZE-53:RS_LS_ENTRY_SIZE-57] = SB_idx_1; // Set Store Buffer index
                        SB_reserve_1 = 1'b1; // Set Store Buffer reserve
                    end else begin
                        RS_LS_2[RS_LS_ENTRY_SIZE-53:RS_LS_ENTRY_SIZE-57] = SB_idx_2; // Set Store Buffer index
                        SB_reserve_2 = 1'b1; // Set Store Buffer reserve
                    end
                end else begin // If Load
                    I2_arch_dest = current_PR_I2[11:9]; // Set destination register
                    if (current_PR_I2[11:9] != 3'b000) begin
                        I2_W = 1'b1; // Set write flag
                        I2_dest_tag_1 = RRF_ptr_2; // Set destination tag
                        RS_LS_2[RS_LS_ENTRY_SIZE-58:RS_LS_ENTRY_SIZE-64] = RRF_ptr_2; // Set destination tag
                        using_RRF_ptr_2 = 1'b1; // Set RRF pointer usage
                        ARF_update_tag_2 = 1'b1; // Set ARF update tag
                        ARF_new_reg_2 = current_PR_I2[11:9]; // Set new register
                        ARF_new_tag_2 = RRF_ptr_2; // Set new tag
                    end
                end

                if (ROB_V1 == 1'b0) begin
                    RS_LS_2[RS_LS_ENTRY_SIZE-65:RS_LS_ENTRY_SIZE-71] = ROB_idx_1; // Set ROB index
                    RS_LS_2[RS_LS_ENTRY_SIZE-72:RS_LS_ENTRY_SIZE-74] = I2_arch_dest; // Set destination register
                    RS_LS_2[RS_LS_ENTRY_SIZE-75] = is_LMSM_I1_out | is_LMSM_I2_out; // Set LMSM flag [for ZERO Flag]
                    ROB_V1 = 1'b1; // Set ROB valid
                    if (SB_reserve_2 == 1'b1) begin
                        ROB_1 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, 18'b0, SB_idx_2, I2_W, is_LMSM_I2_out | is_LMSM_I1_out};
                    end else begin
                        ROB_1 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, 18'b0, SB_idx_1, I2_W, is_LMSM_I2_out | is_LMSM_I1_out};
                    end
                end else begin
                    RS_LS_2[RS_LS_ENTRY_SIZE-65:RS_LS_ENTRY_SIZE-71] = ROB_idx_2; // Set ROB index
                    RS_LS_2[RS_LS_ENTRY_SIZE-72:RS_LS_ENTRY_SIZE-74] = I2_arch_dest; // Set destination register
                    RS_LS_2[RS_LS_ENTRY_SIZE-75] = is_LMSM_I1_out | is_LMSM_I2_out; // Set LMSM flag [for ZERO Flag]
                    ROB_V2 = 1'b1; // Set ROB valid
                    if (SB_reserve_2 == 1'b1) begin
                        ROB_2 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, 18'b0, SB_idx_2, I2_W, is_LMSM_I2_out | is_LMSM_I1_out};
                    end else begin
                        ROB_2 = {current_PR_I2[15:12], I2_arch_dest, I2_dest_tag_1, current_PR_I2PC, 18'b0, SB_idx_1, I2_W, is_LMSM_I2_out | is_LMSM_I1_out};
                    end
                end
            end
        end
    end
end

endmodule
