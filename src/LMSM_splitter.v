module LMSM_splitter (
    input  [15:0] I,
    input         V,
    input         order, // 0 for 1st, 1 for 2nd
    input  [5:0] prev_IMM,
    output reg       is_LMSM,
    output reg [15:0] uop_1_I,
    output reg       uop_1_V,
    output reg [15:0] uop_2_I,
    output reg       uop_2_V,
    output reg [15:0] new_I,
    output reg       new_V,
    output reg [5:0] new_IMM
);

    // Internal signals
    reg [15:0] I_after_uop_1, I_after_uop_2;

    // Your logic here
    always @(*) begin
        // Default values
        is_LMSM = 1'b0;
        uop_1_I = 16'b0;
        uop_1_V = 1'b0;
        uop_2_I = 16'b0;
        uop_2_V = 1'b0;
        new_I = 16'b0;
        new_V = 1'b0;
		  new_IMM = 5'b0;

        I_after_uop_1 = 16'b0;
        I_after_uop_2 = 16'b0;

        // Check if the input is LMSM
        if (I[15:13] == 4'b011 && V == 1'b1) begin
            is_LMSM = 1'b1;
            
            // Decode into uop_1 & update new_I
            if (I[7:0] != 8'b0) begin
                uop_1_V = 1'b1;
                if (I[0] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b111, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:1], 1'b0};
                    I_after_uop_1 = {I[15:8], I[7:1], 1'b0};
                end else if (I[1] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b110, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:2], 1'b0, I[0]};
                    I_after_uop_1 = {I[15:8], I[7:2], 1'b0, I[0]};
                end else if (I[2] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b101, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:3], 1'b0, I[1:0]};
                    I_after_uop_1 = {I[15:8], I[7:3], 1'b0, I[1:0]};
                end else if (I[3] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b100, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:4], 1'b0, I[2:0]};
                    I_after_uop_1 = {I[15:8], I[7:4], 1'b0, I[2:0]};
                end else if (I[4] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b011, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:5], 1'b0, I[3:0]};
                    I_after_uop_1 = {I[15:8], I[7:5], 1'b0, I[3:0]};
                end else if (I[5] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b010, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7:6], 1'b0, I[4:0]};
                    I_after_uop_1 = {I[15:8], I[7:6], 1'b0, I[4:0]};
                end else if (I[6] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b001, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], I[7], 1'b0, I[5:0]};
                    I_after_uop_1 = {I[15:8], I[7], 1'b0, I[5:0]};
                end else if (I[7] == 1'b1) begin
                    uop_1_I = {I[15:14], 1'b0, I[12], 3'b000, I[11:9], (prev_IMM + 6'd2)};
                    new_I   = {I[15:8], 1'b0, I[6:0]};
                    I_after_uop_1 = {I[15:8], 1'b0, I[6:0]};
                end
                new_IMM = prev_IMM + 6'd2;
                new_V = |I_after_uop_1[7:0];
            end

            // Decode into uop_2 & update new_I
            if (order == 1'b0 && I_after_uop_1[7:0] != 8'b0) begin
                uop_2_V = 1'b1;
                if (I_after_uop_1[0] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b111, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:1], 1'b0};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:1], 1'b0};
                end else if (I_after_uop_1[1] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b110, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:2], 1'b0, I_after_uop_1[0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:2], 1'b0, I_after_uop_1[0]};
                end else if (I_after_uop_1[2] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b101, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:3], 1'b0, I_after_uop_1[1:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:3], 1'b0, I_after_uop_1[1:0]};
                end else if (I_after_uop_1[3] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b100, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:4], 1'b0, I_after_uop_1[2:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:4], 1'b0, I_after_uop_1[2:0]};
                end else if (I_after_uop_1[4] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b011, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:5], 1'b0, I_after_uop_1[3:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:5], 1'b0, I_after_uop_1[3:0]};
                end else if (I_after_uop_1[5] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b010, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7:6], 1'b0, I_after_uop_1[4:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7:6], 1'b0, I_after_uop_1[4:0]};
                end else if (I_after_uop_1[6] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b001, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], I_after_uop_1[7], 1'b0, I_after_uop_1[5:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], I_after_uop_1[7], 1'b0, I_after_uop_1[5:0]};
                end else if (I_after_uop_1[7] == 1'b1) begin
                    uop_2_I = {I_after_uop_1[15:14], 1'b0, I_after_uop_1[12], 3'b000, I_after_uop_1[11:9], (prev_IMM + 6'd4)};
                    new_I   = {I_after_uop_1[15:8], 1'b0, I_after_uop_1[6:0]};
                    I_after_uop_2 = {I_after_uop_1[15:8], 1'b0, I_after_uop_1[6:0]};
                end
                new_IMM = prev_IMM + 6'd4;
                new_V = |I_after_uop_2[7:0];
            end
        end
    end
endmodule 