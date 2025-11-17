module StoreBuffer(
    input wire CLK,
    input wire RST,
    // Decode Stage
    input wire clear_speculative, // aka branch mispredicted
    input wire reserve_1,
    input wire reserve_2,
    // Execute Stage
    input wire LS_W,
    input wire [4:0] LS_index,
    input wire [15:0] LS_addr,
    input wire [15:0] LS_data,
    // Load/Store Stage for load enquiry
    input wire [15:0] LS_search_addr,
    // Writeback Stage
    input wire pop_head,
    // Retiring Stage from ROB
    input wire [7:0] ROB_W,      // ROB has retired entries
    input wire [39:0] SB_index,  // indices which have been retired in ROB

    // To decoder
    output wire [4:0] free_index_1,
    output wire [4:0] free_index_2,
    output wire stall,

    // To L1-D Cache
    output wire head_valid,
    output wire [15:0] head_addr,
    output wire [15:0] head_data,

    // For loads
    output reg LS_match,
    output reg [15:0] LS_search_data
);

    // Store buffer entries (32 entries)
    reg valid[0:31];
    reg executed[0:31];
    reg retired[0:31];
    reg [15:0] addr[0:31];
    reg [15:0] data[0:31];

    // Front and back pointers for the circular buffer
    reg [4:0] head;
    reg [4:0] tail;
    reg is_full;

    // --- Internal Wires ---
    integer i;
    integer j;
    integer k;
    reg [4:0] max_age_2;
    reg [4:0] current_age_2;
    integer latest_committed_idx;
    integer best_match_idx;
    reg is_active;
    reg [4:0] current_age;
    reg [4:0] max_age;


    // Wires to decode the incoming retired indices from ROB
    wire [4:0] SB_index0 = SB_index[4:0];
    wire [4:0] SB_index1 = SB_index[9:5];
    wire [4:0] SB_index2 = SB_index[14:10];
    wire [4:0] SB_index3 = SB_index[19:15];
    wire [4:0] SB_index4 = SB_index[24:20];
    wire [4:0] SB_index5 = SB_index[29:25];
    wire [4:0] SB_index6 = SB_index[34:30];
    wire [4:0] SB_index7 = SB_index[39:35];

    // Combinational logic for branch misprediction recovery
    reg [4:0] mispredict_new_tail;

    // --- Combinational Logic ---

    // Combinational logic for outputs and control signals
    assign free_index_1 = tail;
    assign free_index_2 = tail + 1;

    // Stall if less than 2 free entries are available.
    // This occurs if the buffer is full, or if only one spot remains.
    assign stall = is_full || (((tail + 1) & 5'h1F) == head);

    // Outputs for the L1-D Cache interface
    assign head_valid = valid[head] && executed[head] && retired[head];
    assign head_addr = addr[head];
    assign head_data = data[head];


    // Logic for Store-to-Load Forwarding
    // Searches for the most recent store to a given address for a load query.
    always @(*) begin
        // Default outputs
        best_match_idx = -1;
        current_age = 0;
        max_age = 5'b0; // Default value prevents a latch for max_age
        LS_match = 1'b0;
        LS_search_data = 16'b0;

        // Iterate through all entries to find the newest matching store
        for (i = 0; i < 32; i = i + 1) begin
            // Check if the current entry is active (between head and tail)
            if (head == tail && !is_full) begin // Empty case
                is_active = 0;
            end else if (head < tail) begin // No wrap-around
                is_active = (i >= head) && (i < tail);
            end else begin // Pointers have wrapped around
                is_active = (i >= head) || (i < tail);
            end

            // A candidate for forwarding must be valid, executed, active, and match the address
            if (valid[i] && executed[i] && is_active && (addr[i] == LS_search_addr)) begin
                if (best_match_idx == -1) begin
                    // This is the first match we've found
                    best_match_idx = i;
                    max_age = (i - head + 32) & 5'h1F; // Calculate its age
                end else begin
                    // If this match is newer than the best one so far, update
                    current_age = (i - head + 32) & 5'h1F;
                    if (current_age > max_age) begin
                        best_match_idx = i;
                        max_age = current_age;
                    end
                end
            end
        end

        // If a valid match was found, output its data
        if (best_match_idx != -1) begin
            LS_match = 1'b1;
            LS_search_data = data[best_match_idx];
        end
    end

    // Combinational logic to calculate the new tail pointer after a branch misprediction.
    // The new tail should be placed after the most recently committed instruction in the buffer.
    always @(*) begin
          
        latest_committed_idx = -1;
        max_age_2 = 0;
        current_age_2 = 0;

        // Find the committed entry with the greatest age (most recent)
        for (j = 0; j < 32; j = j + 1) begin
            if (valid[j] && retired[j]) begin
                if (latest_committed_idx == -1) begin
                    latest_committed_idx = j;
                    max_age_2 = (j - head + 32) & 5'h1F;
                end else begin
                    current_age_2 = (j - head + 32) & 5'h1F;
                    if (current_age_2 > max_age_2) begin
                        latest_committed_idx = j;
                        max_age_2 = current_age_2;
                    end
                end
            end
        end

        // The new tail is the slot after the last committed entry.
        // If no entries were committed, the buffer is effectively empty, so tail equals head.
        if (latest_committed_idx != -1) begin
            mispredict_new_tail = latest_committed_idx + 1;
        end else begin
            mispredict_new_tail = head;
        end
    end


    // --- Sequential Logic ---

    always @(posedge CLK) begin
        if (RST) begin
            // Synchronously reset the entire store buffer
            head <= 0;
            tail <= 0;
            is_full <= 0;
            for (k = 0; k < 32; k = k + 1) begin
                valid[k] <= 0;
                executed[k] <= 0;
                retired[k] <= 0;
                addr[k] <= 0;
                data[k] <= 0;
            end
        end
        else if (clear_speculative) begin
            // On a branch misprediction, clear all non-retired (speculative) entries
            // and rewind the tail pointer to maintain a contiguous buffer state.
            tail <= mispredict_new_tail;
            is_full <= 0; // Buffer cannot be full after clearing entries
            for (k = 0; k < 32; k = k + 1) begin
                if (!retired[k]) begin // Clear if not retired
                    valid[k] <= 0;
                    executed[k] <= 0;
                end
            end
        end
        else begin
            // --- Normal Operation ---

            // 1. Reserve new entries (Allocation at the tail)
            if (reserve_1) begin
                valid[tail] <= 1'b1;
                executed[tail] <= 1'b0;
                retired[tail] <= 1'b0;
            end
            if (reserve_2) begin
                valid[tail + 1] <= 1'b1;
                executed[tail + 1] <= 1'b0;
                retired[tail + 1] <= 1'b0;
            end
            // Update tail pointer based on reservations
            if (reserve_1 || reserve_2) begin
                tail <= tail + reserve_1 + reserve_2;
            end

            // 2. Update an entry when its store instruction executes
            if (LS_W) begin
                addr[LS_index] <= LS_addr;
                data[LS_index] <= LS_data;
                executed[LS_index] <= 1'b1;
            end

            // 3. Mark entries as retired based on signals from the ROB
            if (ROB_W[0]) retired[SB_index0] <= 1'b1;
            if (ROB_W[1]) retired[SB_index1] <= 1'b1;
            if (ROB_W[2]) retired[SB_index2] <= 1'b1;
            if (ROB_W[3]) retired[SB_index3] <= 1'b1;
            if (ROB_W[4]) retired[SB_index4] <= 1'b1;
            if (ROB_W[5]) retired[SB_index5] <= 1'b1;
            if (ROB_W[6]) retired[SB_index6] <= 1'b1;
            if (ROB_W[7]) retired[SB_index7] <= 1'b1; 
            
            // 4. Pop the head entry after it's written to the L1-D cache
            if (pop_head) begin
                valid[head] <= 1'b0;
                executed[head] <= 1'b0;
                retired[head] <= 1'b0;
                head <= head + 1;
            end

            // 5. Update the 'is_full' flag
            if (pop_head) begin
                is_full <= 1'b0;
            end else if ((reserve_1 || reserve_2) && ((tail + reserve_1 + reserve_2) == head)) begin
                is_full <= 1'b1;
            end

        end
    end

endmodule 