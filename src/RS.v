/*
RS Arithmetic Logical :
    Table of 32 RS entries : 
        1. Valid (144)
        2. Opcode (143-140)
        3. CW (139)
        4. ZW (138)
        5. OPR_1 (137-122) (Tag is LSB 7 bits)
        6. OPR1 valid (121)
        7. OPR_2 (120-105) (Tag is LSB 7 bits)
        8. OPR2 valid (104)
        9. Imm (103-88) (Sign extended)
        10. neg2 (87)
        11. Carry condition (86)
        12. Zero condition (85)
        13. Carry flag value or tag (84-77) 
        14. Carry valid (76)
        15. Zero flag value or tag (75-68)
        16. Zero valid (67)
        17. RRF dest (66-60)
        18. Prev dest (59-44)
        19. Prev dest valid (43)
        20. R_CZ carry dest (42-35)
        21. R_CZ zero dest (34-27)
        22. Branch pred (26)
        23. PC (25-10)
        24. ROB index (9-3)
        25. ARF dest (2-0)
    Inputs :
        clk reset stall
        From decoder : valid bit + all data (x2)
        From ALU1/2 : ALU1/2_D_W, ALU1/2_D, ALU1/2_D_RR - update all ALU1/2_D_RR with ALU1/2_D and update valid bits
        From LS : LS_D_W, LS_D, LS_D_RR - update all LS_D_RR with LS_D and update valid bits
    Outputs :
        stall - Do I have >=2 empty slots? if not stall Fetch & Decode
        ALU1_V - issuing to ALU1?
        ALU1_... {
            input   [3:0]   opcode,
            input   [15:0]  opr1,
            input   [15:0]  opr2,
            input   [15:0]  imm,
            input           carry,
            input           zero,
            input           neg_opr2,
            input   [1:0]   CZ_cond,
            input   [6:0]   dest,
            input   [2:0]   arch_dest,
            input   [15:0]  prev_dest,
            input   [15:0]  PC,
            input   [7:0]   C_dest,
            input   [7:0]   Z_dest,
            input           branch_pred,
            input   [6:0]   ROB_index_in,
        } /refer decoder for exact places of each/
        similarly for ALU2
        Careful: Dynamically decide which entries are eligible for execution, depends on opcode as each requires different operands/CZ Flags
*/

module RS_ArithmeticLogical #(
    parameter RS_AL_ENTRY_SIZE = 145
    ) (
    input  wire         clk,
    input  wire         reset,
    input  wire         flush,          // THIS DOES NOTHING FOR NOW

    // From Decoder (2 entries)
    input  wire         RS_AL_V1,
    input  wire [RS_AL_ENTRY_SIZE-1:0] RS_AL_1,
    input  wire         RS_AL_V2,
    input  wire [RS_AL_ENTRY_SIZE-1:0] RS_AL_2,

    // From ALU1
    input  wire         ALU1_D_W,
    input  wire [15:0]  ALU1_D,
    input  wire [6:0]   ALU1_D_RR,

    // From ALU2
    input  wire         ALU2_D_W,
    input  wire [15:0]  ALU2_D,
    input  wire [6:0]   ALU2_D_RR,

    // From LS
    input  wire         LS_D_W,
    input  wire [15:0]  LS_D,
    input  wire [6:0]   LS_D_RR,

    // Outputs
    output wire         rs_stall, // Fetch/decode stall signal

    // To ALU1
    output reg         ALU1_V,
    output reg [3:0]   ALU1_opcode,
    output reg [15:0]  ALU1_opr1,
    output reg [15:0]  ALU1_opr2,
    output reg [15:0]  ALU1_imm,
    output reg         ALU1_carry,
    output reg         ALU1_zero,
    output reg         ALU1_neg_opr2,
    output reg [1:0]   ALU1_CZ_cond,
    output reg [6:0]   ALU1_dest,
    output reg [2:0]   ALU1_arch_dest,
    output reg [15:0]  ALU1_prev_dest,
    output reg [15:0]  ALU1_PC,
    output reg [7:0]   ALU1_C_dest,
    output reg [7:0]   ALU1_Z_dest,
    output reg         ALU1_branch_pred,
    output reg [6:0]   ALU1_ROB_index,

    // To ALU2 (same format as ALU1)
    output reg         ALU2_V,
    output reg [3:0]   ALU2_opcode,
    output reg [15:0]  ALU2_opr1,
    output reg [15:0]  ALU2_opr2,
    output reg [15:0]  ALU2_imm,
    output reg         ALU2_carry,
    output reg         ALU2_zero,
    output reg         ALU2_neg_opr2,
    output reg [1:0]   ALU2_CZ_cond,
    output reg [6:0]   ALU2_dest,
    output reg [2:0]   ALU2_arch_dest,
    output reg [15:0]  ALU2_prev_dest,
    output reg [15:0]  ALU2_PC,
    output reg [7:0]   ALU2_C_dest,
    output reg [7:0]   ALU2_Z_dest,
    output reg         ALU2_branch_pred,
    output reg [6:0]   ALU2_ROB_index,

    // Check values
    output reg [4:0]   empty_pos1,
    output reg [4:0]   empty_pos2
);

// Internal storage
// Registers for all RS entries
reg         valid       [31:0];
reg [3:0]   opcode      [31:0];
reg         cw          [31:0];
reg         zw          [31:0];
reg [15:0]  opr1        [31:0];
reg         opr1_valid  [31:0];
reg [15:0]  opr2        [31:0];
reg         opr2_valid  [31:0];
reg [15:0]  imm         [31:0];
reg         neg2        [31:0];
reg         carry_cond  [31:0];
reg         zero_cond   [31:0];
reg [7:0]   carry_flag  [31:0];
reg         carry_valid [31:0];
reg [7:0]   zero_flag   [31:0];
reg         zero_valid  [31:0];
reg [6:0]   rrf_dest    [31:0];
reg [15:0]  prev_dest   [31:0];
reg         prev_dest_valid [31:0];
reg [7:0]   r_cz_carry_dest [31:0];
reg [7:0]   r_cz_zero_dest  [31:0];
reg         branch_pred [31:0];
reg [15:0]  pc          [31:0];
reg [6:0]   rob_index   [31:0];
reg [2:0]   arf_dest    [31:0];

// To-Do
// Check if 2 entries are free
// if 2 entries are free, accept input for RS_AL_1 and RS_AL_2
// else stall the fetch/decode stage
// Check if 2 entries are ready
// if 2 entries are ready, issue to ALU1 and ALU2 and mark corresponding valid to 0
// Check if ALU1/2 or LS have written back, if yes, update the corresponding opr with the new value and set opr_valid bit to 1, if all valid bits are 1, set valid bit to 1

integer i;
integer issued = 0;

// Count free entries
integer free_count;
always @(*) begin
    free_count = 0;
    for (i = 0; i < 32; i = i + 1) begin
        if (!valid[i]) free_count = free_count + 1;
    end
end

assign rs_stall = (free_count < 2);

// Helper function: check for free slot
integer idx1, idx2;
integer readyx1, readyx2;

task automatic find_two_free_entries(output integer out1, output integer out2);
    integer j;
    begin
        out1 = -1;
        out2 = -1;
        for (j = 0; j < 32; j = j + 1) begin
            if (!valid[j]) begin
                if (out1 == -1) out1 = j;
                else if (out2 == -1) begin
                    out2 = j;
                    disable find_two_free_entries; // ✅ legal inside task
                end
            end
        end
    end
endtask

task automatic find_two_ready_entries(output integer out1, output integer out2);
    integer j;
    begin
        out1 = -1;
        out2 = -1;
        for (j = 0; j < 32; j = j + 1) begin
            if (valid[j] && opr1_valid[j] && opr2_valid[j]) begin
                if (out1 == -1) out1 = j;
                else if (out2 == -1) begin
                    out2 = j;
                    disable find_two_ready_entries; // ✅ legal inside task
                end
            end
        end
    end
endtask

// Combined insertion and write-back logic
always @(posedge clk) begin
    if (reset || flush) begin
        for (i = 0; i < 32; i = i + 1) begin
            valid[i] <= 0;
            opcode[i] <= 0;
            cw[i] <= 0;
            zw[i] <= 0;
            opr1[i] <= 0;
            opr1_valid[i] <= 0;
            opr2[i] <= 0;
            opr2_valid[i] <= 0;
            imm[i] <= 0;
            neg2[i] <= 0;
            carry_cond[i] <= 0;
            zero_cond[i] <= 0;
            carry_flag[i] <= 0;
            carry_valid[i] <= 0;
            zero_flag[i] <= 0;
            zero_valid[i] <= 0;
            rrf_dest[i] <= 0;
            prev_dest[i] <= 0;
            prev_dest_valid[i] <= 0;
            r_cz_carry_dest[i] <= 0;
            r_cz_zero_dest[i] <= 0;
            branch_pred[i] <= 0;
            pc[i] <= 0;
            rob_index[i] <= 0;
            arf_dest[i] <= 0;
        end
        issued = 0;
    end else begin
        // Write-back forwarding
        for (i = 0; i < 32; i = i + 1) begin
            if (valid[i]) begin
                if (!opr1_valid[i]) begin
                    if (ALU1_D_W && ALU1_D_RR == opr1[i][6:0]) begin
                        opr1[i] <= ALU1_D;
                        opr1_valid[i] <= 1;
                    end else if (ALU2_D_W && ALU2_D_RR == opr1[i][6:0]) begin
                        opr1[i] <= ALU2_D;
                        opr1_valid[i] <= 1;
                    end else if (LS_D_W && LS_D_RR == opr1[i][6:0]) begin
                        opr1[i] <= LS_D;
                        opr1_valid[i] <= 1;
                    end
                end
                if (!opr2_valid[i]) begin
                    if (ALU1_D_W && ALU1_D_RR == opr2[i][6:0]) begin
                        opr2[i] <= ALU1_D;
                        opr2_valid[i] <= 1;
                    end else if (ALU2_D_W && ALU2_D_RR == opr2[i][6:0]) begin
                        opr2[i] <= ALU2_D;
                        opr2_valid[i] <= 1;
                    end else if (LS_D_W && LS_D_RR == opr2[i][6:0]) begin
                        opr2[i] <= LS_D;
                        opr2_valid[i] <= 1;
                    end
                end
            end
        end

        // Issue to ALU1/2
        issued = 0;
        readyx1 = -1;
        readyx2 = -1;
        find_two_ready_entries(readyx1, readyx2);
        
        if (readyx1 != -1) begin
            valid[readyx1] <= 0;
            issued = issued + 1;
        end
        if (readyx2 != -1) begin
            valid[readyx2] <= 0;
            issued = issued + 1;
        end

        // for (i = 0; i < 32 && issued < 2; i = i + 1) begin
        //     if (valid[i] && opr1_valid[i] && opr2_valid[i]) begin
        //         if (!ALU1_V) begin
        //             ALU1_V <= 1;
        //             ALU1_opcode <= opcode[i];
        //             ALU1_opr1 <= opr1[i];
        //             ALU1_opr2 <= opr2[i];
        //             ALU1_imm <= imm[i];
        //             ALU1_carry <= carry_valid[i];
        //             ALU1_zero <= zero_valid[i];
        //             ALU1_neg_opr2 <= neg2[i];
        //             ALU1_CZ_cond <= {carry_cond[i], zero_cond[i]};
        //             ALU1_dest <= rrf_dest[i];
        //             ALU1_arch_dest <= arf_dest[i];
        //             ALU1_prev_dest <= prev_dest[i];
        //             ALU1_PC <= pc[i];
        //             ALU1_C_dest <= r_cz_carry_dest[i];
        //             ALU1_Z_dest <= r_cz_zero_dest[i];
        //             ALU1_branch_pred <= branch_pred[i];
        //             ALU1_ROB_index <= rob_index[i];
        //             valid[i] <= 0;
        //             issued = issued + 1;
        //         end else if (!ALU2_V) begin
        //             ALU2_V <= 1;
        //             ALU2_opcode <= opcode[i];
        //             ALU2_opr1 <= opr1[i];
        //             ALU2_opr2 <= opr2[i];
        //             ALU2_imm <= imm[i];
        //             ALU2_carry <= carry_valid[i];
        //             ALU2_zero <= zero_valid[i];
        //             ALU2_neg_opr2 <= neg2[i];
        //             ALU2_CZ_cond <= {carry_cond[i], zero_cond[i]};
        //             ALU2_dest <= rrf_dest[i];
        //             ALU2_arch_dest <= arf_dest[i];
        //             ALU2_prev_dest <= prev_dest[i];
        //             ALU2_PC <= pc[i];
        //             ALU2_C_dest <= r_cz_carry_dest[i];
        //             ALU2_Z_dest <= r_cz_zero_dest[i];
        //             ALU2_branch_pred <= branch_pred[i];
        //             ALU2_ROB_index <= rob_index[i];
        //             valid[i] <= 0;
        //             issued = issued + 1;
        //         end
        //     end
        // end

        // Insertion
        if (free_count >= 2) begin
            idx1 = -1;
            idx2 = -1;
            find_two_free_entries(idx1, idx2);
            if (RS_AL_V1) begin
                if (idx1 != -1) begin
                    valid[idx1]          <= RS_AL_1[144];
                    opcode[idx1]         <= RS_AL_1[143:140];
                    cw[idx1]             <= RS_AL_1[139];
                    zw[idx1]             <= RS_AL_1[138];
                    opr1[idx1]           <= RS_AL_1[137:122];
                    opr1_valid[idx1]     <= RS_AL_1[121];
                    opr2[idx1]           <= RS_AL_1[120:105];
                    opr2_valid[idx1]     <= RS_AL_1[104];
                    imm[idx1]            <= RS_AL_1[103:88];
                    neg2[idx1]           <= RS_AL_1[87];
                    carry_cond[idx1]     <= RS_AL_1[86];
                    zero_cond[idx1]      <= RS_AL_1[85];
                    carry_flag[idx1]     <= RS_AL_1[84:77];
                    carry_valid[idx1]    <= RS_AL_1[76];
                    zero_flag[idx1]      <= RS_AL_1[75:68];
                    zero_valid[idx1]     <= RS_AL_1[67];
                    rrf_dest[idx1]       <= RS_AL_1[66:60];
                    prev_dest[idx1]      <= RS_AL_1[59:44];
                    prev_dest_valid[idx1]<= RS_AL_1[43];
                    r_cz_carry_dest[idx1]<= RS_AL_1[42:35];
                    r_cz_zero_dest[idx1] <= RS_AL_1[34:27];
                    branch_pred[idx1]    <= RS_AL_1[26];
                    pc[idx1]             <= RS_AL_1[25:10];
                    rob_index[idx1]      <= RS_AL_1[9:3];
                    arf_dest[idx1]       <= RS_AL_1[2:0];
                end
            end
            if (RS_AL_V2) begin
                if (idx2 != -1) begin
                    valid[idx2]          <= RS_AL_2[144];
                    opcode[idx2]         <= RS_AL_2[143:140];
                    cw[idx2]             <= RS_AL_2[139];
                    zw[idx2]             <= RS_AL_2[138];
                    opr1[idx2]           <= RS_AL_2[137:122];
                    opr1_valid[idx2]     <= RS_AL_2[121];
                    opr2[idx2]           <= RS_AL_2[120:105];
                    opr2_valid[idx2]     <= RS_AL_2[104];
                    imm[idx2]            <= RS_AL_2[103:88];
                    neg2[idx2]           <= RS_AL_2[87];
                    carry_cond[idx2]     <= RS_AL_2[86];
                    zero_cond[idx2]      <= RS_AL_2[85];
                    carry_flag[idx2]     <= RS_AL_2[84:77];
                    carry_valid[idx2]    <= RS_AL_2[76];
                    zero_flag[idx2]      <= RS_AL_2[75:68];
                    zero_valid[idx2]     <= RS_AL_2[67];
                    rrf_dest[idx2]       <= RS_AL_2[66:60];
                    prev_dest[idx2]      <= RS_AL_2[59:44];
                    prev_dest_valid[idx2]<= RS_AL_2[43];
                    r_cz_carry_dest[idx2]<= RS_AL_2[42:35];
                    r_cz_zero_dest[idx2] <= RS_AL_2[34:27];
                    branch_pred[idx2]    <= RS_AL_2[26];
                    pc[idx2]             <= RS_AL_2[25:10];
                    rob_index[idx2]      <= RS_AL_2[9:3];
                    arf_dest[idx2]       <= RS_AL_2[2:0];
                end
            end
        end
    end
end


always @(*) begin
    ALU1_V = 1'b0;
    ALU1_opcode = 4'b0;
    ALU1_opr1 = 16'b0;
    ALU1_opr2 = 16'b0;
    ALU1_imm = 16'b0;
    ALU1_carry = 1'b0;
    ALU1_zero = 1'b0;
    ALU1_neg_opr2 = 1'b0;
    ALU1_CZ_cond = 2'b0;
    ALU1_dest = 7'b0;
    ALU1_arch_dest = 3'b0;
    ALU1_prev_dest = 16'b0;
    ALU1_PC = 16'b0;
    ALU1_C_dest = 8'b0;
    ALU1_Z_dest = 8'b0;
    ALU1_branch_pred = 1'b0;
    ALU1_ROB_index = 7'b0;
    ALU2_V = 1'b0;
    ALU2_opcode = 4'b0;
    ALU2_opr1 = 16'b0;
    ALU2_opr2 = 16'b0;
    ALU2_imm = 16'b0;
    ALU2_carry = 1'b0;
    ALU2_zero = 1'b0;
    ALU2_neg_opr2 = 1'b0;
    ALU2_CZ_cond = 2'b0;
    ALU2_dest = 7'b0;
    ALU2_arch_dest = 3'b0;
    ALU2_prev_dest = 16'b0;
    ALU2_PC = 16'b0;
    ALU2_C_dest = 8'b0;
    ALU2_Z_dest = 8'b0;
    ALU2_branch_pred = 1'b0;
    ALU2_ROB_index = 7'b0;
    empty_pos1 = 5'b0;
    empty_pos2 = 5'b0;

    if (readyx1 != -1) begin
        ALU1_V = 1;
        ALU1_opcode = opcode[readyx1];
        ALU1_opr1 = opr1[readyx1];
        ALU1_opr2 = opr2[readyx1];
        ALU1_imm = imm[readyx1];
        ALU1_carry = carry_valid[readyx1];
        ALU1_zero = zero_valid[readyx1];
        ALU1_neg_opr2 = neg2[readyx1];
        ALU1_CZ_cond = {carry_cond[readyx1], zero_cond[readyx1]};
        ALU1_dest = rrf_dest[readyx1];
        ALU1_arch_dest = arf_dest[readyx1];
        ALU1_prev_dest = prev_dest[readyx1];
        ALU1_PC = pc[readyx1];
        ALU1_C_dest = r_cz_carry_dest[readyx1];
        ALU1_Z_dest = r_cz_zero_dest[readyx1];
        ALU1_branch_pred = branch_pred[readyx1];
        ALU1_ROB_index = rob_index[readyx1];
    end
    if (readyx2 != -1) begin
        ALU2_V = 1;
        ALU2_opcode = opcode[readyx2];
        ALU2_opr1 = opr1[readyx2];
        ALU2_opr2 = opr2[readyx2];
        ALU2_imm = imm[readyx2];
        ALU2_carry = carry_valid[readyx2];
        ALU2_zero = zero_valid[readyx2];
        ALU2_neg_opr2 = neg2[readyx2];
        ALU2_CZ_cond = {carry_cond[readyx2], zero_cond[readyx2]};
        ALU2_dest = rrf_dest[readyx2];
        ALU2_arch_dest = arf_dest[readyx2];
        ALU2_prev_dest = prev_dest[readyx2];
        ALU2_PC = pc[readyx2];
        ALU2_C_dest = r_cz_carry_dest[readyx2];
        ALU2_Z_dest = r_cz_zero_dest[readyx2];
        ALU2_branch_pred = branch_pred[readyx2];
        ALU2_ROB_index = rob_index[readyx2];
    end
    if (free_count >= 2) begin
        empty_pos1 <= (idx1 == -1) ? 5'b11111 : idx1[4:0];
        empty_pos2 <= (idx2 == -1) ? 5'b11111 : idx2[4:0];
    end
end


endmodule


/*
RS Load Store :
    Table of 32 RS entries : 
        1. Valid bit
        2. Load/Store bit
        3. Base
        4. Base valid bit
        5. Offset
        6. Source (Data or Tag)
        7. Source valid bit
        8. Store Buffer index
        9. RR address
        10. ROB index
        11. ARF destination
        12. is LMSM
    Inputs :
        clk reset stall
        From decoder : valid bit + all data (x2)
        From ALU1/2 : ALU1/2_D_W, ALU1/2_D, ALU1/2_D_RR - update all ALU1/2_D_RR with ALU1/2_D and update valid bits
        From LS : LS_D_W, LS_D, LS_D_RR - update all LS_D_RR with LS_D and update valid bits
    Outputs :
        stall - do I have >=2 empty slots?
        LS_V1 - issuing to LS_Unit?
        LS - {
            input wire        Load_Store, // 0 for Load, 1 for Store
            input wire [15:0] Base,
            input wire [15:0] Offset,
            input wire [15:0] Source_Data,
            input wire [6:0]  dest,
            input wire [2:0]  arch_dest,
            input wire [7:0]  Z_dest,
            input wire [4:0]  SB_index,
            input wire [6:0]  ROB_index,
            input wire        is_LMSM,
        } /refer to decoder/

        /will be a Queue, FIFO/
*/

module RS_LoadStore #(
    parameter RS_LS_ENTRY_SIZE = 75
    ) (
    input  wire         clk,
    input  wire         reset,
    input  wire         stall,      // From Store buffer - if full, stall
    input  wire         flush, 

    // From Decoder (2 entries)
    input  wire         RS_LS_V1,
    input  wire [RS_LS_ENTRY_SIZE-1:0] RS_LS_1,
    input  wire         RS_LS_V2,
    input  wire [RS_LS_ENTRY_SIZE-1:0] RS_LS_2,

    // From ALU1
    input  wire         ALU1_D_W,
    input  wire [15:0]  ALU1_D,
    input  wire [6:0]   ALU1_D_RR,

    // From ALU2
    input  wire         ALU2_D_W,
    input  wire [15:0]  ALU2_D,
    input  wire [6:0]   ALU2_D_RR,

    // From LS
    input  wire         LS_D_W,
    input  wire [15:0]  LS_D,
    input  wire [6:0]   LS_D_RR,

    // Outputs
    output wire         rs_stall,  // If < 2 slots available

    // To Load/Store Unit
    output reg         LS_V1,
    output reg         Load_Store,
    output reg [15:0]  Base,
    output reg [15:0]  Offset,
    output reg [15:0]  Source_Data,
    output reg [6:0]   dest,
    output reg [2:0]   arch_dest_ls,
    output reg [7:0]   Z_dest,
    output reg [4:0]   SB_index,
    output reg [6:0]   ROB_index,
    output reg         is_LMSM //, **Changed**

    // Check values
    // output reg [4:0]   empty_pos1 **Changed**
    );

    // Internal storage
    reg         valid        [31:0];
    reg         load_store   [31:0];
    reg [15:0]  base         [31:0];
    reg         base_valid   [31:0];
    reg [15:0]  offset       [31:0];
    reg [15:0]  source_data  [31:0];
    reg         source_valid [31:0];
    reg [4:0]   sb_index     [31:0];
    reg [6:0]   rr_addr      [31:0];
    reg [6:0]   rob_index_r  [31:0];
    reg [2:0]   arch_dest    [31:0];
    reg [7:0]   z_dest       [31:0];
    reg         is_lmsm      [31:0];

    // Additional logic to be implemented
    // - Entry insertion (from decoder)
    // - Operand/tag broadcast update (from ALU/LS)
    // - Issue logic (determine ready entries to issue to LS)
    // - rs_stall output based on # of free entries

    integer i, issued = 0;

    integer free_count;
    always @(*) begin
        free_count = 0;
        for (i = 0; i < 32; i = i + 1) begin
            if (!valid[i])
                free_count = free_count + 1;
        end
    end

    assign rs_stall = (free_count < 2);

    integer start_ptr = 0, end_ptr = 0;


    integer idx1, idx2, start_idx = 0;
    integer idx;
    integer readyx1;

    //Note: this is ugly but works
    integer found_1, found_2;

    task automatic find_two_free_entries(output integer out1, output integer out2, input integer start_idx);
        integer j;
        begin
            out1 = -1;
            out2 = -1;
            for (j = 0; j < 32; j = j + 1) begin
                idx = (start_idx + j) % 32; // Circular queue logic
                if (!valid[idx]) begin
                    if (out1 == -1) out1 = idx;
                    else if (out2 == -1) begin
                        out2 = idx;
                        disable find_two_free_entries; // ✅ legal inside task
                    end
                end
            end
        end
    endtask

    // Combined insertion and write-back logic
    always @(posedge clk) begin
        if (reset || flush) begin
            for (i = 0; i < 32; i = i + 1) begin
                valid[i]       <= 0;
                load_store[i]  <= 0;
                base[i]        <= 0;
                base_valid[i]  <= 0;
                offset[i]      <= 0;
                source_data[i] <= 0;
                source_valid[i]<= 0;
                sb_index[i]    <= 0;
                rr_addr[i]     <= 0;
                rob_index_r[i] <= 0;
                arch_dest[i]   <= 0;
                z_dest[i]      <= 0;
                is_lmsm[i]     <= 0;
            end
            start_idx = 0;
            start_ptr = 0;
            end_ptr = 0;
        end 
        else begin
            // Write-back forwarding
            for (i = 0; i < 32; i = i + 1) begin
                if (valid[i]) begin
                    if (!base_valid[i]) begin
                        if (ALU1_D_W && ALU1_D_RR == base[i][6:0]) begin
                            base[i] <= ALU1_D;
                            base_valid[i] <= 1;
                        end else if (ALU2_D_W && ALU2_D_RR == base[i][6:0]) begin
                            base[i] <= ALU2_D;
                            base_valid[i] <= 1;
                        end else if (LS_D_W && LS_D_RR == base[i][6:0]) begin
                            base[i] <= LS_D;
                            base_valid[i] <= 1;
                        end
                    end
                    if (!source_valid[i]) begin
                        if (ALU1_D_W && ALU1_D_RR == source_data[i][6:0]) begin
                            source_data[i] <= ALU1_D;
                            source_valid[i] <= 1;
                        end else if (ALU2_D_W && ALU2_D_RR == source_data[i][6:0]) begin
                            source_data[i] <= ALU2_D;
                            source_valid[i] <= 1;
                        end else if (LS_D_W && LS_D_RR == source_data[i][6:0]) begin
                            source_data[i] <= LS_D;
                            source_valid[i] <= 1;
                        end
                    end
                end
            end

            // Issue to LS
            found_1 = 0;
            for (i = 0; i < 32; i = i + 1) begin
                // if (valid[i] && base_valid[i] && source_valid[i]) begin
                if (found_1 == 0 && valid[i] && ( (!load_store[i] && base_valid[i]) || (load_store[i] && base_valid[i] && source_valid[i]))) begin
                    valid[i] <= 0;
                    found_1 = 1;
                    end_ptr = end_ptr + 1;
                end
            end

            // Insertion
            if (free_count >= 2) begin
                // idx1 = -1;
                // idx2 = -1;
                // find_two_free_entries(idx1, idx2, start_idx);
                // start_idx = (idx2 != -1) ? idx2 : ((idx1 != -1) ? idx1 : start_idx);
                // empty_pos1 <= (idx1 == -1) ? 5'b11111 : idx1[4:0];
                // empty_pos2 <= (idx2 == -1) ? 5'b11111 : idx2[4:0];
                if (RS_LS_V1 && RS_LS_V2) begin
                    // if (idx1 != -1) begin
                    if (start_ptr - end_ptr < 32) begin
                        valid[start_ptr[4:0]]       <= RS_LS_1[74];
                        load_store[start_ptr[4:0]]  <= RS_LS_1[73];
                        base[start_ptr[4:0]]        <= RS_LS_1[72:57];
                        base_valid[start_ptr[4:0]]  <= RS_LS_1[56];
                        offset[start_ptr[4:0]]      <= RS_LS_1[55:40];
                        source_data[start_ptr[4:0]] <= RS_LS_1[39:24];
                        source_valid[start_ptr[4:0]]<= RS_LS_1[23];
                        sb_index[start_ptr[4:0]]    <= RS_LS_1[22:18];
                        rr_addr[start_ptr[4:0]]     <= RS_LS_1[17:11];
                        rob_index_r[start_ptr[4:0]] <= RS_LS_1[10:4];
                        arch_dest[start_ptr[4:0]]   <= RS_LS_1[3:1];
                        is_lmsm[start_ptr[4:0]]     <= RS_LS_1[0];
                        start_ptr = start_ptr + 1;
                    end
                    if (start_ptr - end_ptr < 32) begin
                        valid[start_ptr[4:0]]       <= RS_LS_2[74];
                        load_store[start_ptr[4:0]]  <= RS_LS_2[73];
                        base[start_ptr[4:0]]        <= RS_LS_2[72:57];
                        base_valid[start_ptr[4:0]]  <= RS_LS_2[56];
                        offset[start_ptr[4:0]]      <= RS_LS_2[55:40];
                        source_data[start_ptr[4:0]] <= RS_LS_2[39:24];
                        source_valid[start_ptr[4:0]]<= RS_LS_2[23];
                        sb_index[start_ptr[4:0]]    <= RS_LS_2[22:18];
                        rr_addr[start_ptr[4:0]]     <= RS_LS_2[17:11];
                        rob_index_r[start_ptr[4:0]] <= RS_LS_2[10:4];
                        arch_dest[start_ptr[4:0]]   <= RS_LS_2[3:1];
                        is_lmsm[start_ptr[4:0]]     <= RS_LS_2[0];
                        start_ptr = start_ptr + 1;
                    end
                end else if (RS_LS_V1 ^ RS_LS_V2) begin
                    if (RS_LS_V1 && start_ptr - end_ptr < 32) begin
                        valid[start_ptr[4:0]]       <= RS_LS_1[74];
                        load_store[start_ptr[4:0]]  <= RS_LS_1[73];
                        base[start_ptr[4:0]]        <= RS_LS_1[72:57];
                        base_valid[start_ptr[4:0]]  <= RS_LS_1[56];
                        offset[start_ptr[4:0]]      <= RS_LS_1[55:40];
                        source_data[start_ptr[4:0]] <= RS_LS_1[39:24];
                        source_valid[start_ptr[4:0]]<= RS_LS_1[23];
                        sb_index[start_ptr[4:0]]    <= RS_LS_1[22:18];
                        rr_addr[start_ptr[4:0]]     <= RS_LS_1[17:11];
                        rob_index_r[start_ptr[4:0]] <= RS_LS_1[10:4];
                        arch_dest[start_ptr[4:0]]   <= RS_LS_1[3:1];
                        is_lmsm[start_ptr[4:0]]     <= RS_LS_1[0];
                        start_ptr = start_ptr + 1;
                    end else if (RS_LS_V2 && start_ptr - end_ptr < 32) begin
                        valid[start_ptr[4:0]]       <= RS_LS_2[74];
                        load_store[start_ptr[4:0]]  <= RS_LS_2[73];
                        base[start_ptr[4:0]]        <= RS_LS_2[72:57];
                        base_valid[start_ptr[4:0]]  <= RS_LS_2[56];
                        offset[start_ptr[4:0]]      <= RS_LS_2[55:40];
                        source_data[start_ptr[4:0]] <= RS_LS_2[39:24];
                        source_valid[start_ptr[4:0]]<= RS_LS_2[23];
                        sb_index[start_ptr[4:0]]    <= RS_LS_2[22:18];
                        rr_addr[start_ptr[4:0]]     <= RS_LS_2[17:11];
                        rob_index_r[start_ptr[4:0]] <= RS_LS_2[10:4];
                        arch_dest[start_ptr[4:0]]   <= RS_LS_2[3:1];
                        is_lmsm[start_ptr[4:0]]     <= RS_LS_2[0];
                        start_ptr = start_ptr + 1;
                    end
                end
            end
        end
    end

    always @(*) begin
        LS_V1 = 1'b0;
        Load_Store = 1'b0;
        Base = 16'b0;
        Offset = 16'b0;
        Source_Data = 16'b0;
        dest = 7'b0;
        arch_dest_ls = 3'b0;
        Z_dest = 8'b0;
        SB_index = 5'b0;
        ROB_index = 7'b0;
        is_LMSM = 1'b0;
        // empty_pos1 = 5'b0;

        if (stall) begin
            LS_V1 = 0;
            Load_Store = 0;
            Base = 0;
            Offset = 0;
            Source_Data = 0;
            dest = 0;
            arch_dest_ls = 0;
            Z_dest = 0;
            SB_index = 0;
            ROB_index = 0;
            is_LMSM = 0;
        end

        found_2 = 0;
        for (i = 0; i < 32; i = i + 1) begin
            // if (valid[i] && base_valid[i] && source_valid[i]) begin
            if (found_2 == 0 && valid[i] && ( (!load_store[i] && base_valid[i]) || (load_store[i] && base_valid[i] && source_valid[i]))) begin
                found_2 = 1;
                LS_V1 = 1;
                Load_Store = load_store[i];
                Base = base[i];
                Offset = offset[i];
                Source_Data = source_data[i];
                dest = rr_addr[i];
                arch_dest_ls = arch_dest[i];
                Z_dest = z_dest[i];
                SB_index = sb_index[i];
                ROB_index = rob_index_r[i];
                is_LMSM = is_lmsm[i];
            end
        end
    end

endmodule
