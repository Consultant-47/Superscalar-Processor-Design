module alu (
    // Inputs
    input           valid,
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

    // Outputs
    // for RRF
    output reg          ALU_W,
    output reg  [15:0]  ALU_D,
    output reg  [6:0]   ALU_RR,

    // for R_CZ
    output reg          ALU_C_W,
    output reg          ALU_C,
    output reg  [7:0]   ALU_C_RR,
    output reg          ALU_Z_W,
    output reg          ALU_Z,
    output reg  [7:0]   ALU_Z_RR,

    // for ROB
    output reg          ALU_branch_mispred,
    output reg  [15:0]  ALU_new_PC,
    output reg          ROB_update,
    output reg  [6:0]   ROB_index_out
);

    // Internal logic based on opcode and inputs
    always @(*) begin
        // Default values
        ALU_W = 1'b0;
        ALU_C_W = 1'b0;
        ALU_Z_W = 1'b0;
        ALU_branch_mispred = 1'b0;
        ROB_update = 1'b0;
        ALU_new_PC = 16'b0;
        ALU_RR = 7'b0;
        ALU_C_RR = 8'b0;
        ALU_Z_RR = 8'b0;
        ALU_D = 16'b0;
        ALU_C = 1'b0;
        ALU_Z = 1'b0;
        ROB_index_out = ROB_index_in;

        // Check for valid operation
        if (valid) begin
            if (opcode == 4'b0001) begin // ADD
                ALU_C_W = 1'b1;
                ALU_Z_W = 1'b1;

                {ALU_C, ALU_D} = opr1 + (neg_opr2 ? ~opr2 : opr2) + (&CZ_cond);

                // Set ALU_Z if the 16-bit result ALU_D is zero
                ALU_Z = (ALU_D == 16'b0) ? 1'b1 : 1'b0;

                // Assign destination register tags
                ALU_RR = dest;
                ALU_C_RR = C_dest;
                ALU_Z_RR = Z_dest;

                if (arch_dest == 3'b000) begin
                    if(CZ_cond == 2'b00 || CZ_cond == 2'b11 || (CZ_cond == 2'b10 && carry == 1'b1) || (CZ_cond == 2'b01 && zero == 1'b1)) begin 
                        ALU_branch_mispred = 1'b1;
                    end
                    ALU_new_PC = opr1 + (neg_opr2 ? ~opr2 : opr2) + (&CZ_cond);
                    ALU_W = 1'b0;
                end else begin
                    ALU_W = 1'b1;
                end

                ROB_update = 1'b1;
                ROB_index_out = ROB_index_in;
                
                //if flag mismatches, set ALU_D to previous destination value
                if(!(CZ_cond == 2'b00 || CZ_cond == 2'b11 || (CZ_cond == 2'b10 && carry == 1'b1) || (CZ_cond == 2'b01 && zero == 1'b1)) && arch_dest != 3'b000) begin
                    ALU_D = prev_dest;
                    ALU_C = carry;
                    ALU_Z = zero;
                end
            end

            if (opcode == 4'b0010) begin // NAND
                ALU_Z_W = 1'b1;

                ALU_D = ~(opr1 & (neg_opr2 ? ~opr2 : opr2));

                // Set ALU_Z if the 16-bit result ALU_D is zero
                ALU_Z = (ALU_D == 16'b0) ? 1'b1 : 1'b0;

                // Assign destination register tags
                ALU_RR = dest;
                ALU_Z_RR = Z_dest;

                if (arch_dest == 3'b000) begin
                    if(CZ_cond == 2'b00 || (CZ_cond == 2'b10 && carry == 1'b1) || (CZ_cond == 2'b01 && zero == 1'b1)) begin 
                        ALU_branch_mispred = 1'b1;
                    end
                    ALU_new_PC = ~(opr1 & (neg_opr2 ? ~opr2 : opr2));
                    ALU_W = 1'b0;
                end else begin
                    ALU_W = 1'b1;
                end

                ROB_update = 1'b1;
                ROB_index_out = ROB_index_in;
                
                //if flag mismatches, set ALU_D to previous destination value
                if(!(CZ_cond == 2'b00 || (CZ_cond == 2'b10 && carry == 1'b1) || (CZ_cond == 2'b01 && zero == 1'b1)) && arch_dest != 3'b000) begin
                    ALU_D = prev_dest;
                    ALU_Z = zero;
                end
            end

            if (opcode == 4'b0000) begin // ADI
                ALU_C_W = 1'b1;
                ALU_Z_W = 1'b1;

                {ALU_C, ALU_D} = opr1 + imm;

                // Set ALU_Z if the 16-bit result ALU_D is zero
                ALU_Z = (ALU_D == 16'b0) ? 1'b1 : 1'b0;

                // Assign destination register tags
                ALU_RR = dest;
                ALU_C_RR = C_dest;
                ALU_Z_RR = Z_dest;

                if (arch_dest == 3'b000) begin
                    ALU_branch_mispred = 1'b1;
                    ALU_new_PC = opr1 + imm;
                    ALU_W = 1'b0;
                end else begin
                    ALU_W = 1'b1;
                end

                ROB_update = 1'b1;
                ROB_index_out = ROB_index_in;
            end

            if (opcode == 4'b0011) begin // LLI
                ALU_D = imm;

                // Assign destination register tags
                ALU_RR = dest;

                if (arch_dest == 3'b000) begin
                    ALU_branch_mispred = 1'b1;
                    ALU_new_PC = imm;
                    ALU_W = 1'b0;
                end else begin
                    ALU_W = 1'b1;
                end

                ROB_update = 1'b1;
                ROB_index_out = ROB_index_in;
            end

            if (opcode[3:2] == 2'b10) begin // BEQ/BLE/BLT
                // Perform comparison for branch instructions (BEQ/BLE/BLT)
                {ALU_C, ALU_D} = opr1 + (~opr2) + 1'b1;
                
                // Set ALU_Z if the 16-bit result ALU_D is zero
                ALU_Z = (ALU_D == 16'b0) ? 1'b1 : 1'b0;
                
                if (!((opcode == 4'b1000 && ( (branch_pred == 1'b1 && ALU_Z == 1'b1) || (branch_pred == 1'b0 && ALU_Z == 1'b0) ) ) ||       // BEQ
                      (opcode == 4'b1001 && ( (branch_pred == 1'b1 && ALU_Z == 1'b0 && ALU_C == 1'b0) || (branch_pred == 1'b0 && ALU_C == 1'b1) ) ) || // BLT
                      (opcode == 4'b1010 && ( (branch_pred == 1'b1 && (ALU_Z == 1'b1 || ALU_C == 1'b0)) || (branch_pred == 1'b0 && ALU_C == 1'b1 && ALU_Z == 1'b0) ) ))) begin // BLE
                    ALU_branch_mispred = 1'b1;
                    ALU_new_PC = PC + {imm[15:1], 1'b0};
                end

                ROB_update = 1'b1;
                ROB_index_out = ROB_index_in;
            end

            if (opcode == 4'b1100) begin //JAL
                ALU_D = PC + 16'd2; // Store the next instruction address in ALU_D

                // Assign destination register tags
                ALU_RR = dest;

                ALU_W = 1'b1; // Write to the destination register

                if (branch_pred == 1'b0) begin
                    ALU_branch_mispred = 1'b1; // Misprediction occurred
                    ALU_new_PC = PC + {imm[15:1], 1'b0}; // Update the new PC with the immediate value
                end

                ROB_update = 1'b1; // Update the ROB
                ROB_index_out = ROB_index_in;
            end

            if (opcode == 4'b1101) begin // JALR
                ALU_D = PC + 16'd2; // Store the next instruction address in ALU_D

                // Assign destination register tags
                ALU_RR = dest;

                ALU_W = 1'b1; // Write to the destination register

                ALU_branch_mispred = 1'b1; // Misprediction occurred
                ALU_new_PC = opr2; // Update the new PC with the immediate value

                ROB_update = 1'b1; // Update the ROB
                ROB_index_out = ROB_index_in;
            end

            if (opcode == 4'b1111) begin // JRI
                ALU_branch_mispred = 1'b1; // Misprediction occurred
                ALU_new_PC = opr1 + {imm[15:1], 1'b0}; // Update the new PC with the immediate value

                ROB_update = 1'b1; // Update the ROB
                ROB_index_out = ROB_index_in;
            end

        end
    end

endmodule