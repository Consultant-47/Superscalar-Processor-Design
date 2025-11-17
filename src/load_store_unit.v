module load_store_unit (
    // Inputs
    input wire        Valid,
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

    input wire        SB_match,
    input wire [15:0] SB_data,

    input wire [15:0] L1d_data,

    // Outputs
    //for RRF
    output reg       LS_W,
    output reg [6:0] LS_RR,
    output reg [15:0]LS_D,

    //for R_CZ
    output reg       LS_Z_W,
    output reg [7:0] LS_Z_dest,
    output reg       LS_Z,

    //for Store Buffer
    output reg [15:0]SB_search_addr,
    output reg       SB_W,
    output reg [4:0] SB_index_out,
    output reg [15:0] SB_addr_out,
    output reg [15:0] SB_data_out,

    //for ROB
    output reg       ROB_W,
    output reg [6:0] ROB_index_out,
    output reg       LS_branch_mispred,
    output reg [15:0] LS_new_PC,

    //for L1d cache
    output reg       L1d_R,
    output reg [15:0]L1d_addr
);

    // Internal logic will go here

    always @(*) begin
        // Default values
        LS_W = 1'b0;
        LS_RR = 7'b0;
        LS_D = 16'b0;
        LS_Z_W = 1'b0;
        LS_Z_dest = 8'b0;
        LS_Z = 1'b0;
        SB_search_addr = 16'b0;
        SB_W = 1'b0;
        SB_index_out = 5'b0;
        SB_addr_out = 16'b0;
        SB_data_out = 16'b0;
        ROB_W = 1'b0;
        ROB_index_out = 7'b0;
        LS_branch_mispred = 1'b0;
        LS_new_PC = 16'b0;
        L1d_R = 1'b0;
        L1d_addr = 16'b0;

        if (Valid) begin
            if (Load_Store) begin // Store operation
                SB_W = 1'b1; // Indicate a write operation to store buffer
                SB_addr_out = Base + Offset; // Calculate store address
                SB_data_out = Source_Data; // Data to be stored
                SB_index_out = SB_index; // Store buffer index

                ROB_W = 1'b1; // Indicate a write operation to ROB
                ROB_index_out = ROB_index; // ROB index for the operation

                L1d_R = 1'b0; // No read operation from L1d cache
            end else begin // Load operation
                L1d_R = 1; // Indicate a read operation from L1d cache
                L1d_addr = Base + Offset; // Calculate load address
                SB_search_addr = Base + Offset; // Address to search in store buffer



                ROB_W = 1'b1; // Indicate a write operation to ROB
                ROB_index_out = ROB_index; // ROB index for the operation



                if (SB_match) begin
                    LS_D = SB_data; // Load data from store buffer if matched
                end else begin
                    LS_D = L1d_data; // Load data from L1d cache otherwise
                end

                if (arch_dest == 3'b000) begin 
                    LS_branch_mispred = 1'b1; // Indicate a branch misprediction
                    if (SB_match) begin
                        LS_new_PC = SB_data; // Load data from store buffer if matched
                    end else begin
                        LS_new_PC = L1d_data; // Load data from L1d cache otherwise
                    end
                end else begin
                    LS_W = 1'b1; // Indicate a write operation to RRF
                    LS_RR = dest; // Destination register for the load operation
                end

                if (is_LMSM == 1'b0) begin
                    LS_Z_W = 1'b1; // Indicate a write operation to Z register
                    LS_Z_dest = Z_dest; // Z destination register for the load operation
                    LS_Z = (LS_D == 16'b0) ? 1'b1 : 1'b0; // Set Z if loaded data is zero
                end
            end
        end
    end
    

endmodule