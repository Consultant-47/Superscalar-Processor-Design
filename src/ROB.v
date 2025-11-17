/* Description: Reorder Buffer (ROB) module
    Table of 128 entries:
    Each entry is 68 bits wide.
    1. Valid bit / Busy Bit                 : 1 bit
    2. PC                                   : 16 bits
    3. Destination Architectural Register   : 3 bits
    4. Destination Renamed Register         : 7 bits
    5. Carry Writeback                      : 1 bit
    6. Carry Writeback Address              : 8 bits
    7. Zero Writeback                       : 1 bit
    8. Zero Writeback Address               : 8 bits
    9. Valid / Execute                      : 1 bit
    10. Mispredicted Branch                 : 1 bit
    11. Correct Branch Address              : 16 bits
    12. Store Buffer Index                  : 5 bits
    13. RRF Write Enable                    : 1 bit
    14. Is Instruction LM or SM?            : 1 bit

*/
module ROB #(parameter ROB_ENTRY_SIZE = 55, 
             parameter ROB_INDEX_SIZE = 7,
             parameter RRF_SIZE = 7,
             parameter R_CZ_SIZE = 8,
             parameter SB_SIZE = 5,
             parameter ROB_SIZE = 128
             ) (
    // Main Control Signals
    input wire CLK,
    // input wire Flush,
    input wire RST,
    // From Decoder
    input wire Dispatch1_V,
    input wire [ROB_ENTRY_SIZE-1:0] Dispatch1,
    input wire Dispatch2_V,
    input wire [ROB_ENTRY_SIZE-1:0] Dispatch2,

    // From ALU1
    input wire ALU1_mispred,
    input wire [15:0] ALU1_new_PC,
    input wire ALU1_valid,
    input wire [ROB_INDEX_SIZE-1:0] ALU1_index,

    // From ALU2
    input wire ALU2_mispred,
    input wire [15:0] ALU2_new_PC,
    input wire ALU2_valid,
    input wire [ROB_INDEX_SIZE-1:0] ALU2_index,

    // From Load/Store Unit
    input wire LSU_mispred,
    input wire [15:0] LSU_new_PC,
    input wire LSU_valid,
    input wire [ROB_INDEX_SIZE-1:0] LSU_index,

    // To RRF
    output reg ROB_Retire1_V,
    output reg [2:0] ROB_Retire1_ARF_Addr,
    output reg [RRF_SIZE-1:0] ROB_Retire1_RRF_Addr,
    output reg ROB_Retire2_V,
    output reg [2:0] ROB_Retire2_ARF_Addr,
    output reg [RRF_SIZE-1:0] ROB_Retire2_RRF_Addr,

    // To R_CZ
    output reg ROB_Retire1_C_V,
    output reg ROB_Retire1_Z_V,
    output reg [R_CZ_SIZE-1:0] ROB_Retire1_C_Addr,
    output reg [R_CZ_SIZE-1:0] ROB_Retire1_Z_Addr,

    output reg ROB_Retire2_C_V,
    output reg ROB_Retire2_Z_V,
    output reg [R_CZ_SIZE-1:0] ROB_Retire2_C_Addr,
    output reg [R_CZ_SIZE-1:0] ROB_Retire2_Z_Addr,
    // Unclear about the Carry and Zero flag which is supposed to be an output because aren't they stored in CZ_RR.

    // To Store Buffer
    output reg [7:0] ROB_Retire_SB_Valid,
    output reg [39:0] ROB_Retire_SB_Index,

    // To Decoder
    output wire [ROB_INDEX_SIZE-1:0] ROB_index_1,
    output wire [ROB_INDEX_SIZE-1:0] ROB_index_2,

    // Stall output in case of ROB full
    output wire ROB_stall,
    // Flush signal to the rest of the pipeline
    output reg Global_Flush,
    output reg [15:0] new_PC_value_after_misprediction
);

// Internal registers
reg                 valid       [ROB_SIZE - 1:0]; // Valid bits for each entry
reg [3:0]           opcode      [ROB_SIZE - 1:0]; // Opcode for each entry
reg [15:0]          PC          [ROB_SIZE - 1:0]; // Program Counter for each entry
reg [2:0]           ARF_Addr    [ROB_SIZE - 1:0]; // Destination ARF address
reg [RRF_SIZE-1:0]  RRF_Addr    [ROB_SIZE - 1:0]; // Destination RRF address
reg                 C_W         [ROB_SIZE - 1:0]; // Carry Writeback
reg [R_CZ_SIZE-1:0] C_Addr      [ROB_SIZE - 1:0]; // Carry Writeback Address
reg                 Z_W         [ROB_SIZE - 1:0]; // Zero Writeback
reg [R_CZ_SIZE-1:0] Z_Addr      [ROB_SIZE - 1:0]; // Zero Writeback Address
reg                 Instr_Valid [ROB_SIZE - 1:0]; // Instruction Valid bit
reg                 Mispredicted_Branch [ROB_SIZE - 1:0]; // Mispredicted Branch
reg [15:0]          Correct_Branch_Addr [ROB_SIZE - 1:0]; // Correct Branch Address
reg [SB_SIZE-1:0]   SB_Addr     [ROB_SIZE - 1:0]; // Store Buffer Address
reg                 RRF_W       [ROB_SIZE - 1:0]; // RRF Write Enable
reg                 Is_LM_SM    [ROB_SIZE - 1:0]; // Is Instruction Load/Store Memory or Store Memory

reg internal_retire_1, internal_retire_2;

integer i;

// Count free entries in ROB
integer free_entries;
always @(*) begin
    free_entries = 0;
    for (i = 0; i < ROB_SIZE; i = i + 1) begin
        if (!valid[i]) begin
            free_entries = free_entries + 1;
        end
    end
end
// Check if ROB is full
assign ROB_stall = (free_entries < 2);

reg [6:0] ROB_Head_Pointer;
reg [6:0] ROB_Retire_Pointer;

assign ROB_index_1 = ROB_Head_Pointer;
assign ROB_index_2 = ROB_Head_Pointer + 6'd1;

always @(*) begin
    internal_retire_1 = 1'b0;
    internal_retire_2 = 1'b0;
	
    ROB_Retire1_V = 1'b0;
    ROB_Retire1_ARF_Addr = 3'b0;
    ROB_Retire1_RRF_Addr = {RRF_SIZE{1'b0}};
    ROB_Retire1_C_V = 1'b0;
    ROB_Retire1_C_Addr = {R_CZ_SIZE{1'b0}};
    ROB_Retire1_Z_V = 1'b0;
    ROB_Retire1_Z_Addr = {R_CZ_SIZE{1'b0}};
    // ROB_Retire1_HeadPC = 16'b0;

    ROB_Retire2_V = 1'b0;
    ROB_Retire2_ARF_Addr = 3'b0;
    ROB_Retire2_RRF_Addr = {RRF_SIZE{1'b0}};
    ROB_Retire2_C_V = 1'b0;
    ROB_Retire2_C_Addr = {R_CZ_SIZE{1'b0}};
    ROB_Retire2_Z_V = 1'b0;
    ROB_Retire2_Z_Addr = {R_CZ_SIZE{1'b0}};
    // ROB_Retire2_HeadPC = 16'b0;

    ROB_Retire_SB_Valid = 8'b0;
    ROB_Retire_SB_Index = 40'b0;

    Global_Flush = 1'b0;
    new_PC_value_after_misprediction = 16'b0;

    // Retiring instructions
    if(Instr_Valid[ROB_Retire_Pointer]) begin
        //to retire, entry should be valid and instruction should be executed
        internal_retire_1 = 1'b1;
        ROB_Retire1_V = RRF_W[ROB_Retire_Pointer];
        ROB_Retire1_ARF_Addr = ARF_Addr[ROB_Retire_Pointer];
        ROB_Retire1_RRF_Addr = RRF_Addr[ROB_Retire_Pointer];
        ROB_Retire1_C_V = C_W[ROB_Retire_Pointer];
        ROB_Retire1_C_Addr = C_Addr[ROB_Retire_Pointer];
        ROB_Retire1_Z_V = Z_W[ROB_Retire_Pointer];
        ROB_Retire1_Z_Addr = Z_Addr[ROB_Retire_Pointer];
        if (opcode[ROB_Retire_Pointer] == 4'b0101) begin
            ROB_Retire_SB_Valid[0] = 1'b1;
            ROB_Retire_SB_Index[4:0] = SB_Addr[ROB_Retire_Pointer];
        end else begin
            if (Mispredicted_Branch[ROB_Retire_Pointer]) begin
                Global_Flush = 1'b1;
                new_PC_value_after_misprediction = Correct_Branch_Addr[ROB_Retire_Pointer];
            end else begin // **Changed**
                Global_Flush = 1'b0;  // **Changed**
                new_PC_value_after_misprediction = 16'b0; // **Changed**
            end // **Changed**
        end
        // ROB_Retire1_HeadPC = PC[ROB_Head_Pointer + 6'd1];
        if(Instr_Valid[ROB_Retire_Pointer + 6'd1] && !Mispredicted_Branch[ROB_Retire_Pointer]) begin
            internal_retire_2 = 1'b1;
            ROB_Retire2_V = RRF_W[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_ARF_Addr = ARF_Addr[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_RRF_Addr = RRF_Addr[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_C_V = C_W[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_C_Addr = C_Addr[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_Z_V = Z_W[ROB_Retire_Pointer + 6'd1];
            ROB_Retire2_Z_Addr = Z_Addr[ROB_Retire_Pointer + 6'd1];
            if (opcode[ROB_Retire_Pointer + 6'd1] == 4'b0101) begin
                ROB_Retire_SB_Valid[1] = 1'b1;
                ROB_Retire_SB_Index[9:5] = SB_Addr[ROB_Retire_Pointer + 6'd1];
            end else begin
                if (Mispredicted_Branch[ROB_Retire_Pointer + 6'd1]) begin
                    Global_Flush = 1'b1;
                    new_PC_value_after_misprediction = Correct_Branch_Addr[ROB_Retire_Pointer + 6'd1];
                end else begin // **Changed**
                    Global_Flush = 1'b0;  // **Changed**
                    new_PC_value_after_misprediction = 16'b0; // **Changed**
                end // **Changed**
            end 
            // ROB_Retire2_HeadPC = PC[ROB_Head_Pointer + 6'd1];
        end
    end
end

always @(posedge CLK) begin // Removed posedge RST // **Changed**
    if(RST) begin
        for (i = 0; i < ROB_SIZE; i = i + 1) begin
            valid[i] <= 1'b0;
            opcode[i] <= 4'b0;
            PC[i] <= 16'b0;
            ARF_Addr[i] <= 3'b0;
            RRF_Addr[i] <= 7'b0;
            C_W[i] <= 1'b0;
            C_Addr[i] <= 8'b0;
            Z_W[i] <= 1'b0;
            Z_Addr[i] <= 8'b0;
            Instr_Valid[i] <= 1'b0;
            Mispredicted_Branch[i] <= 1'b0;
            Correct_Branch_Addr[i] <= 16'b0;
            SB_Addr[i] <= 5'b0;
            RRF_W[i] <= 1'b0;
            Is_LM_SM[i] <= 1'b0;
        end
        ROB_Head_Pointer <= 7'b0;
        ROB_Retire_Pointer <= 7'b0;
    end
    else begin
        if((Mispredicted_Branch[ROB_Retire_Pointer] && valid[ROB_Retire_Pointer] && Instr_Valid[ROB_Retire_Pointer]) || (Mispredicted_Branch[ROB_Retire_Pointer + 6'd1] && valid[ROB_Retire_Pointer + 6'd1] && Instr_Valid[ROB_Retire_Pointer + 6'd1])) begin
            // Flush the ROB on mispredicted branch
            ROB_Head_Pointer <= 7'b0;
            ROB_Retire_Pointer <= 7'b0;
            for (i = 0; i < ROB_SIZE; i = i + 1) begin
                valid[i] <= 1'b0;
                opcode[i] <= 4'b0;
                PC[i] <= 16'b0;
                ARF_Addr[i] <= 3'b0;
                RRF_Addr[i] <= 7'b0;
                C_W[i] <= 1'b0;
                C_Addr[i] <= 8'b0;
                Z_W[i] <= 1'b0;
                Z_Addr[i] <= 8'b0;
                Instr_Valid[i] <= 1'b0;
                Mispredicted_Branch[i] <= 1'b0;
                Correct_Branch_Addr[i] <= 16'b0;
                SB_Addr[i] <= 5'b0;
                RRF_W[i] <= 1'b0;
                Is_LM_SM[i] <= 1'b0;
            end
        end else begin
            // Updating validity and branch information
            if(ALU1_valid) begin
                Instr_Valid[ALU1_index] <= 1'b1;
                Mispredicted_Branch[ALU1_index] <= ALU1_mispred;
                Correct_Branch_Addr[ALU1_index] <= ALU1_new_PC;
            end
            if(ALU2_valid) begin
                Instr_Valid[ALU2_index] <= 1'b1;
                Mispredicted_Branch[ALU2_index] <= ALU2_mispred;
                Correct_Branch_Addr[ALU2_index] <= ALU2_new_PC;
            end
            if(LSU_valid) begin
                Instr_Valid[LSU_index] <= 1'b1;
                Mispredicted_Branch[LSU_index] <= LSU_mispred;
                Correct_Branch_Addr[LSU_index] <= LSU_new_PC;
            end
        
            if(Dispatch1_V && ~valid[ROB_Head_Pointer]) begin
                // Global_Flush <= 1'b0; // **Changed**
                valid[ROB_Head_Pointer] <= 1'b1;
                opcode[ROB_Head_Pointer] <= Dispatch1[54:51];
                PC[ROB_Head_Pointer] <= Dispatch1[40:25];
                ARF_Addr[ROB_Head_Pointer] <= Dispatch1[50:48];
                RRF_Addr[ROB_Head_Pointer] <= Dispatch1[47:41];
                C_W[ROB_Head_Pointer] <= Dispatch1[24];
                C_Addr[ROB_Head_Pointer] <= Dispatch1[23:16];
                Z_W[ROB_Head_Pointer] <= Dispatch1[15];
                Z_Addr[ROB_Head_Pointer] <= Dispatch1[14:7];
                Instr_Valid[ROB_Head_Pointer] <= 1'b0;
                Mispredicted_Branch[ROB_Head_Pointer] <= 1'b0;
                Correct_Branch_Addr[ROB_Head_Pointer] <= 16'b0;
                SB_Addr[ROB_Head_Pointer] <= Dispatch1[6:2];
                RRF_W[ROB_Head_Pointer] <= Dispatch1[1];
                Is_LM_SM[ROB_Head_Pointer] <= Dispatch1[0];
                // new_PC_value_after_misprediction <= 16'b0; // **Changed**
            end
            if(Dispatch2_V && ~valid[ROB_Head_Pointer + 6'd1]) begin  
                // Adding dispatched instructions to the ROB
                // Global_Flush <= 1'b0; // **Changed**
                valid[ROB_Head_Pointer + 6'd1] <= 1'b1;
                opcode[ROB_Head_Pointer + 6'd1] <= Dispatch2[54:51];
                PC[ROB_Head_Pointer + 6'd1] <= Dispatch2[40:25];
                ARF_Addr[ROB_Head_Pointer + 6'd1] <= Dispatch2[50:48];
                RRF_Addr[ROB_Head_Pointer + 6'd1] <= Dispatch2[47:41];
                C_W[ROB_Head_Pointer + 6'd1] <= Dispatch2[24];
                C_Addr[ROB_Head_Pointer + 6'd1] <= Dispatch2[23:16];
                Z_W[ROB_Head_Pointer + 6'd1] <= Dispatch2[15];
                Z_Addr[ROB_Head_Pointer + 6'd1] <= Dispatch2[14:7];
                Instr_Valid[ROB_Head_Pointer + 6'd1] <= 1'b0;
                Mispredicted_Branch[ROB_Head_Pointer + 6'd1] <= 1'b0;
                Correct_Branch_Addr[ROB_Head_Pointer + 6'd1] <= 16'b0;
                SB_Addr[ROB_Head_Pointer + 6'd1] <= Dispatch2[6:2];
                RRF_W[ROB_Head_Pointer + 6'd1] <= Dispatch2[1];
                Is_LM_SM[ROB_Head_Pointer + 6'd1] <= Dispatch2[0];
                // new_PC_value_after_misprediction <= 16'b0; // **Changed**
            end

            // Retiring instructions
            if(Instr_Valid[ROB_Retire_Pointer]) begin
                valid[ROB_Retire_Pointer] <= 1'b0;
                if(Instr_Valid[ROB_Retire_Pointer + 6'd1]) begin
                    valid[ROB_Retire_Pointer + 6'd1] <= 1'b0;
                end
            end

            // Update the retire pointer
            if(internal_retire_1 && internal_retire_2) begin
                ROB_Retire_Pointer <= ROB_Retire_Pointer + 6'd2;
            end
            else if(internal_retire_1) begin
                ROB_Retire_Pointer <= ROB_Retire_Pointer + 6'd1;
            end
            // Update the head pointer
            if(Dispatch1_V && Dispatch2_V) begin
                ROB_Head_Pointer <= ROB_Head_Pointer + 6'd2;
            end
            else if(Dispatch1_V) begin
                ROB_Head_Pointer <= ROB_Head_Pointer + 6'd1;
            end
        end
        // Why was this brought out ? Question
        // Mispredicted_Branch[ALU1_index] <= ALU1_mispred;
        // Correct_Branch_Addr[ALU1_index] <= ALU1_new_PC;
        // Mispredicted_Branch[ALU2_index] <= ALU2_mispred;
        // Correct_Branch_Addr[ALU2_index] <= ALU2_new_PC;
        // Mispredicted_Branch[LSU_index] <= LSU_mispred;
        // Correct_Branch_Addr[LSU_index] <= LSU_new_PC;
    end
end

endmodule