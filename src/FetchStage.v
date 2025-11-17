/*
FetchStage :
    Inputs :  clk, stall, reset, R0w, R0d
    Contains : R0, Instruction memory
    Outputs : 2 instructions, whether they're predicted or actual, whether they're valid or not 
    Logic :
        Compute addr1, addr2; output corresponding instructions, update r0 
*/

module FetchStage (
    input wire clk,
    input wire stall, 
    input wire reset,
    input wire R0w, // R0 updated externally
    input wire [15:0] R0d, // R0 updated externally
    output reg [15:0] I1, // First instruction
    output reg [15:0] I2, // Second instruction
    output reg I1V, // First instruction valid
    output reg I2V, // Second instruction valid
    output reg I1P, // If I1 was a branch, predicted or not (taken/not taken)
    output reg I2P, // If I2 was a branch, predicted or not (taken/not taken)
    output reg [15:0] I1PC,
    output reg [15:0] I2PC
);

    // Internal signals for predicted address from R0_update
    wire [15:0] predicted_addr;
    wire I1V_predict, I2V_predict;
    wire I1P_predict, I2P_predict;

    // Internal register for R0
    reg [15:0] R0;

    // Instruction memory output wires
    wire [15:0] instruction1;
    wire [15:0] instruction2;

    // Instantiate the R0_update module for instruction prediction
    R0_update r0_updater (
        .clk(clk),
        .reset(reset),
        .R0_in(R0),
        .R0w(R0w),
        .R0d(R0d),
        .I1V(I1V_predict),  // branch predictor hit
        .I2V(I2V_predict),
        .I1P(I1P_predict),  // if hit, was it predicted taken or not taken
        .I2P(I2P_predict),
        .R0_out(predicted_addr) // Predicted address for instruction fetch
    );

    // Instantiate the InstructionMemory module to fetch instructions using R0
    InstructionMemory instruction_memory (
        .clk(clk),
        .addr(R0),  // Use R0 as the address
        .I1(instruction1),
        .I2(instruction2)
    );

    // R0 update logic based on R0w and R0d
    always @(posedge clk) begin
        if (!stall && !reset && !R0w) begin
            // If stall is not active, update R0 with the output from R0_update
            R0 <= predicted_addr;
            // Fetch instructions from instruction memory using R0
            I1 <= instruction1;  // First instruction
            I2 <= instruction2;  // Second instruction
            I1V <= 1'b1;              // First instruction always valid
            I2V <= 1'b1; // **Changed** Revert back to this after BP is finalized  I2V <= ~I1P_predict;  // Second instruction invalid if 1st was a taken branch
            I1P <= I1P_predict;    // First instruction branch prediction
            I2P <= I2P_predict;    // Second instruction branch prediction
            I1PC <= R0;           // Program counter for first instruction
            I2PC <= R0 + 16'd2;       // Program counter for second instruction // **Changed**
        end else if (reset) begin
            R0 <= 16'd0;
            I1 <= 16'd0;
            I2 <= 16'd0;
            I1V <= 1'b0;
            I2V <= 1'b0;
            I1P <= 1'b0;
            I2P <= 1'b0;
            I1PC <= 16'd0;
            I2PC <= 16'd0;
        end else if (R0w) begin
            R0 <= R0d;
            I1 <= 16'd0;
            I2 <= 16'd0;
            I1V <= 1'b0;
            I2V <= 1'b0;
            I1P <= 1'b0;
            I2P <= 1'b0;
            I1PC <= 16'd0;
            I2PC <= 16'd0;
        end else begin
            // If stalled, maintain current state
            R0 <= R0;
            I1 <= I1;
            I2 <= I2;
            I1V <= 1'b0;
            I2V <= 1'b0;
            I1P <= I1P;
            I2P <= I2P;
            I1PC <= I1PC;
            I2PC <= I2PC;
        end
    end
endmodule


module InstructionMemory (
    input wire clk,
    input wire [15:0] addr,
    output reg [15:0] I1,
    output reg [15:0] I2
);

    // Define memory with 64K x 8-bit storage (for 16-bit address space)
    reg [7:0] mem [0:127];
    
    initial begin
        // Load instructions (example values, replace with actual)
        $readmemh("instructions.hex", mem);
    end

    always @(negedge clk) begin
        // Fetch 4 bytes corresponding to the given address
        I1 <= {mem[addr], mem[addr + 1]};   // Fetch first instruction (16 bits)
        I2 <= {mem[addr + 2], mem[addr + 3]}; // Fetch second instruction (16 bits)
    end
endmodule

// R0_out = R0_d if R0w is high
// else R0_out = prediction(R0_in) if R0_in has a match in the predictor table
// else R0_out = prediction(R0_in + 2) if R0_in + 2 has a match in the predictor table
// else R0_out = R0 + 4

module R0_update(
    input wire clk,
    input wire reset,

    input wire [15:0] R0_in,
    input wire R0w,
    input wire [15:0] R0d,
    
    output wire I1V,
    output wire I2V,
    output wire I1P,
    output wire I2P,
    output reg [15:0] R0_out
);

    // Internal signals to hold the predicted addresses for R0_in and R0_in + 2
    wire [15:0] predicted_addr_1;  // For R0_in
    wire [15:0] predicted_addr_2;  // For R0_in + 2
    
    // Instantiate the branch predictor module
    assign I1V = 1'b0;
    assign I2V = 1'b0;
    assign I1P = 1'b0;
    assign I2P = 1'b0;

    // Disconnected the branch predictor for now, static not taken predictions
    // branch_predictor predictor (
    //     .clk(clk),
    //     .rst(reset),  // Reset the predictor on reset
    //     .addr1(R0_in),
    //     .addr2(R0_in + 2),
    //     .I1Addr(predicted_addr_1),  // Predicted address for R0_in
    //     .I2Addr(predicted_addr_2),  // Predicted address for R0_in + 2
    //     .I1V(I1V),
    //     .I2V(I2V),
    //     .I1P(I1P),
    //     .I2P(I2P),
    //     .update_valid(1'b0),  // No updates for now
    //     .update_addr(16'd0),
    //     .update_taken(1'b0),
    //     .update_target(16'd0)
    // );
    
    always @(*) begin
        if (R0w) begin
            // If R0w is high, directly use R0d
            R0_out = R0d;
        end else begin
            // If I1V is high, use predicted address for R0_in
            if (I1V) begin
                R0_out = R0_in;
            // If I2V is high, use predicted address for R0_in + 2
            end else if (I2V) begin
                R0_out = R0_in + 16'd2;// **Changed**
            // Otherwise, default to R0_in + 4
            end else begin
                R0_out = R0_in + 16'd4; // **Changed**
            end
        end
    end

endmodule



module branch_predictor (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,

    input  wire [15:0] addr1,
    input  wire [15:0] addr2,

    output reg  [15:0] I1Addr,
    output reg  [15:0] I2Addr,
    output reg         I1V,     // Found an entry for addr1
    output reg         I2V,
    output reg         I1P,     // Prediction for addr1 (taken or not taken)
    output reg         I2P,

    // Update interface
    input  wire        update_valid,    // supposed to update the table
    input  wire [15:0] update_addr,
    input  wire        update_taken,
    input  wire [15:0] update_target
);

    // Predictor tables with 4 entries (0:3)
    reg         valid_table [0:3];
    reg         predict_table [0:3];
    reg [15:0]  target_table [0:3];
    reg [15:0]  addr_table [0:3];  // Store full address for comparison
    reg [7:0]   lru_counter [0:3];  // LRU counter for each entry

    integer i;
    integer empty_idx;
    integer min_idx;

    // Search for the address in the table
    function [1:0] search_table;
        input [15:0] addr;
        integer j;
        begin
            search_table = 2'b11; // Default: no match (invalid index)
            for (j = 0; j < 4; j = j + 1) begin
                if (addr_table[j] == addr) begin
                    search_table = j;  // Found match, set index
                end
            end
        end
    endfunction

    // Update the LRU counters
    task update_lru;
        input [1:0] index;
        integer j;
        begin
            // Reset the LRU counters (decrement others, increment the accessed entry)
            for (j = 0; j < 4; j = j + 1) begin
                if (j != index && valid_table[j] == 1'b1)
                    lru_counter[j] <= lru_counter[j] - 1;
            end
            // Mark the accessed entry as the most recently used
            lru_counter[index] <= 8'hFF;  // Max value to mark as most recent
        end
    endtask

    // Prediction logic based on search
    always @(*) begin
        if (!stall) begin //                                                                                          //  IF STATEMENT IS CAUSING LATCHES
            // Search for addr1 and addr2 in the table
            I1V    = (search_table(addr1) != 2'b11);  // Check for match (valid entry)
            I1P    = (I1V) ? predict_table[search_table(addr1)] : 1'b0;
            I1Addr = (I1V) ? target_table[search_table(addr1)] : 16'd0;

            I2V    = (search_table(addr2) != 2'b11);  // Check for match (valid entry)
            I2P    = (I2V) ? predict_table[search_table(addr2)] : 1'b0;
            I2Addr = (I2V) ? target_table[search_table(addr2)] : 16'd0;
        end
    end

    // Update + Reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                valid_table[i]   <= 1'b0;
                predict_table[i] <= 1'b0;
                target_table[i]  <= 16'd0;
                addr_table[i]    <= 16'd0;  // Clear stored addresses
                lru_counter[i]   <= 8'd0;   // Reset LRU counters
            end
        end else begin
            if (update_valid) begin
                // Check for an empty slot in the table (0 indicates empty)
                empty_idx = 2'b11;  // Default: no empty slot
                for (i = 0; i < 4; i = i + 1) begin
                    if (valid_table[i] == 1'b0) begin
                        empty_idx = i;
                    end
                end

                // If there's space, insert the new entry
                if (empty_idx != 2'b11) begin
                    addr_table[empty_idx]    <= update_addr;
                    valid_table[empty_idx]   <= 1'b1;
                    predict_table[empty_idx] <= update_taken;
                    target_table[empty_idx]  <= update_target;

                    // Update LRU counters after insertion
                    update_lru(empty_idx);
                end else begin
                    // If the table is full, replace the LRU entry
                    min_idx = 2'b00;
                    for (i = 1; i < 4; i = i + 1) begin
                        if (lru_counter[i] < lru_counter[min_idx]) begin
                            min_idx = i;
                        end
                    end

                    // Replace the least recently used entry
                    addr_table[min_idx]    <= update_addr;
                    valid_table[min_idx]   <= 1'b1;
                    predict_table[min_idx] <= update_taken;
                    target_table[min_idx]  <= update_target;

                    // Update LRU counters
                    update_lru(min_idx);
                end
            end
        end
    end

endmodule
