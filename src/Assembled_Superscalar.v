module Assembled_Superscalar #(
    parameter SB_SIZE           = 5,
    parameter ROB_SIZE          = 7,
    parameter RRF_SIZE          = 7,
    parameter R_CZ_SIZE         = 8,
    parameter RS_AL_ENTRY_SIZE  = 145,
    parameter RS_LS_ENTRY_SIZE  = 75,
    parameter ROB_ENTRY_SIZE    = 55
)(
	input wire clk,				// external clock
	// input wire stall,			// external stall
	// input wire flush,			// external flush
	input wire reset
);

// ----------------------------------------------------------------------------

// FetchStage inputs
wire R0w;
wire [15:0] R0d;

// FetchStage outputs
wire [15:0] fetch_I1, fetch_I2; // to decode stage
wire fetch_I1V, fetch_I2V; // to decode stage
wire fetch_I1P, fetch_I2P; // to decode stage
wire [15:0] fetch_I1PC, fetch_I2PC; // to decode stage

// ----------------------------------------------------------------------------

// Decoder inputs
// wire stall; -- already declared above
wire [SB_SIZE-1:0] SB_idx_1, SB_idx_2; // from store buffer
wire [ROB_SIZE-1:0] ROB_idx_1, ROB_idx_2; // from reorder buffer
wire [RRF_SIZE-1:0] RRF_ptr_1, RRF_ptr_2; // from RRF
wire [R_CZ_SIZE-1:0] R_CZ_ptr_1, R_CZ_ptr_2, R_CZ_ptr_3, R_CZ_ptr_4; // from CZ RRF
wire [7:0] ARF_B; // from ARF
wire [15:0] ARF_D1, ARF_D2, ARF_D3, ARF_D4, ARF_D5, ARF_D6, ARF_D7; // from ARF
wire [RRF_SIZE-1:0] ARF_tag_1, ARF_tag_2, ARF_tag_3, ARF_tag_4, ARF_tag_5, ARF_tag_6, ARF_tag_7; // from ARF
wire [7:0] RRF_V_ARF_tags; // from RRF
wire [15:0] RRF_D_ARF_tag_1, RRF_D_ARF_tag_2, RRF_D_ARF_tag_3, RRF_D_ARF_tag_4, RRF_D_ARF_tag_5, RRF_D_ARF_tag_6, RRF_D_ARF_tag_7; // from RRF
wire arch_C, arch_C_B; // from RRF_CZ
wire [R_CZ_SIZE-1:0] arch_C_tag; // from RRF_CZ
wire arch_Z, arch_Z_B; // from RRF_CZ
wire [R_CZ_SIZE-1:0] arch_Z_tag; // from RRF_CZ
wire R_CZ_V_arch_C_tag, R_CZ_D_arch_C_tag; // from RRF_CZ
wire R_CZ_V_arch_Z_tag, R_CZ_D_arch_Z_tag; // from RRF_CZ

wire [15:0] PR_I1, PR_I2; // from IF_ID_PR
wire PR_I1V, PR_I2V; // from IF_ID_PR
wire PR_I1P, PR_I2P; // from IF_ID_PR
wire [15:0] PR_I1PC, PR_I2PC; // from IF_ID_PR
wire [5:0] PR_I1_prev_IMM, PR_I2_prev_IMM; // from IF_ID_PR

// Decoder outputs
wire loop; // to IF_ID_PR
wire [15:0] I1_loop, I2_loop; // to IF_ID_PR
wire I1V_loop, I2V_loop; // to IF_ID_PR
wire I1P_loop, I2P_loop; // to IF_ID_PR
wire [15:0] I1PC_loop, I2PC_loop; // to IF_ID_PR
wire [5:0] I1IMM_loop, I2IMM_loop; // to IF_ID_PR

wire RS_AL_V1, RS_AL_V2; // to RS_AL
wire [RS_AL_ENTRY_SIZE-1:0] RS_AL_1, RS_AL_2; // to RS_AL
wire RS_LS_V1, RS_LS_V2; // to RS_LS
wire [RS_LS_ENTRY_SIZE-1:0] RS_LS_1, RS_LS_2; // to RS_LS
wire ROB_V1, ROB_V2; // to ROB
wire [ROB_ENTRY_SIZE-1:0] ROB_1, ROB_2; // to ROB

wire using_RRF_ptr_1, using_RRF_ptr_2; // to RRF
wire using_R_CZ_ptr_1, using_R_CZ_ptr_2, using_R_CZ_ptr_3, using_R_CZ_ptr_4; // to RRF

wire ARF_update_tag_1, ARF_update_tag_2; // to ARF
wire [2:0] ARF_new_reg_1, ARF_new_reg_2; // to ARF
wire [RRF_SIZE-1:0] ARF_new_tag_1, ARF_new_tag_2; // to ARF
wire update_arch_C; // to ARF
wire [R_CZ_SIZE-1:0] new_C_tag; // to ARF
wire update_arch_Z; // to ARF
wire [R_CZ_SIZE-1:0] new_Z_tag; // to ARF

wire SB_reserve_1, SB_reserve_2; // to SB

// ----------------------------------------------------------------------------

// RS AL inputs
// From ALU1
wire ALU1_D_W;
wire [15:0] ALU1_D;
wire [6:0] ALU1_D_RR;

// From ALU2
wire ALU2_D_W;
wire [15:0] ALU2_D;
wire [6:0] ALU2_D_RR;

// From LS
wire LS_D_W;
wire [15:0] LS_D;
wire [6:0] LS_D_RR;

// RS AL Outputs
wire rs_al_stall;                // Fetch/decode stall signal

// To ALU1
wire ALU1_V;
wire [3:0] ALU1_opcode;
wire [15:0] ALU1_opr1;
wire [15:0] ALU1_opr2;
wire [15:0] ALU1_imm;
wire ALU1_carry;
wire ALU1_zero;
wire ALU1_neg_opr2;
wire [1:0] ALU1_CZ_cond;
wire [6:0] ALU1_dest;
wire [2:0] ALU1_arch_dest;
wire [15:0] ALU1_prev_dest;
wire [15:0] ALU1_PC;
wire [7:0] ALU1_C_dest;
wire [7:0] ALU1_Z_dest;
wire ALU1_branch_pred;
wire [ROB_SIZE-1:0] ALU1_ROB_index;

// To ALU2
wire ALU2_V;
wire [3:0] ALU2_opcode;
wire [15:0] ALU2_opr1;
wire [15:0] ALU2_opr2;
wire [15:0] ALU2_imm;
wire ALU2_carry;
wire ALU2_zero;
wire ALU2_neg_opr2;
wire [1:0] ALU2_CZ_cond;
wire [6:0] ALU2_dest;
wire [2:0] ALU2_arch_dest;
wire [15:0] ALU2_prev_dest;
wire [15:0] ALU2_PC;
wire [7:0] ALU2_C_dest;
wire [7:0] ALU2_Z_dest;
wire ALU2_branch_pred;
wire [ROB_SIZE-1:0] ALU2_ROB_index;

// General outputs
wire [4:0] rs_al_empty_pos1, rs_al_empty_pos2; 

// ----------------------------------------------------------------------------

// RS LS outputs
wire rs_ls_stall;                // Fetch/decode stall signal

// To LoadStore
wire LS_LS_V1;
wire LS_load_store;
wire [15:0] LS_Base;
wire [15:0] LS_Offset;
wire [15:0] LS_Source_Data;
wire [6:0] LS_dest;
wire [2:0] LS_arch_dest_ls;
wire [7:0] LS_Z_dest;
wire [SB_SIZE-1:0] LS_SB_index;
wire [ROB_SIZE-1:0] LS_ROB_index;
wire LS_is_LMSM;
wire SB_stall;

// General outputs
// wire [4:0] rs_ls_empty_pos1; **Changed**

// ----------------------------------------------------------------------------

// RRF inputs
wire ROB_RRF_W1, ROB_RRF_W2; 
wire [RRF_SIZE-1:0] ROB_RRF_readidx1, ROB_RRF_readidx2;
wire [2:0] ROB_RRF_writeidx1, ROB_RRF_writeidx2;

// RRF outputs
wire [2:0] RRF_ARF_write_idx1, RRF_ARF_write_idx2;
wire [15:0] RRF_ARF_write_data1, RRF_ARF_write_data2;
wire [6:0] RRF_ARF_write_tag1, RRF_ARF_write_tag2;
wire RRF_ARF_write_en1, RRF_ARF_write_en2; 
wire RRF_two_available;
// ----------------------------------------------------------------------------

// ARF inputs

// ARF outputs

// ----------------------------------------------------------------------------

// ALU outputs
wire ALU1_branch_mispred, ALU2_branch_mispred, ALU1_ROB_W, ALU2_ROB_W;
wire [15:0] ALU1_new_PC, ALU2_new_PC;
wire [6:0] ALU_to_ROB_index1, ALU_to_ROB_index2; // to ROB

// LS outputs
wire LS_branch_mispred, LS_ROB_W;
wire [15:0] LS_new_PC;
wire [6:0] LS_to_ROB_index; 
wire [15:0] SB_search_addr;
wire SB_W;
wire [4:0] SB_index_out;
wire [15:0] SB_addr_out;
wire [15:0] SB_data_out;

// ----------------------------------------------------------------------------

// ROB inputs

// ROB outputs
wire ROB_stall;
wire [7:0] ROB_SB_V;
wire [39:0] ROB_SB_Index;
wire [15:0] ROB_SB_PC1, ROB_SB_PC2;

// ----------------------------------------------------------------------------

// LS unit inputs
wire SB_LS_match;
wire [15:0] SB_LS_data;
wire [15:0] L1d_data; // from L1d cache

// LS unit outputs
wire L1d_R;
wire [15:0] L1d_addr;

// ----------------------------------------------------------------------------

// Store Buffer inputs
reg pop_head;

// Store Buffer outputs
wire head_valid;
wire [15:0] head_addr;
wire [15:0] head_data;

// ----------------------------------------------------------------------------

wire IF_ID_PR_flush;
wire RS_flush;

wire ROB_flush;
wire [15:0] new_PC_value_after_misprediction;
// Instantiate FetchStage

wire Fetch_stall; // stall signal for fetch stage
assign Fetch_stall = rs_al_stall || rs_ls_stall || ROB_stall || (!RRF_two_available); // **Changes**
FetchStage fetch_stage_inst (
    .clk(clk),					// external clock
    .stall(Fetch_stall),				// external stall 
    .reset(reset),			   	// external flush //NO FLUSH
    .R0w(ROB_flush),	 				// FOR NOW external R0 update		
    .R0d(new_PC_value_after_misprediction),					// FOR NOW external R0 data

	// To Decoder
    .I1(fetch_I1),
    .I2(fetch_I2),
    .I1V(fetch_I1V),
    .I2V(fetch_I2V),
    .I1P(fetch_I1P),
    .I2P(fetch_I2P),
    .I1PC(fetch_I1PC),
    .I2PC(fetch_I2PC)
);

// Instantiate IF_ID_PR 
IF_ID_PR if_id_pr_inst (
	.clk(clk),					// external clock
	.reset(reset),				// external reset
	.stall(Fetch_stall),				// external stall **Changed**
	.flush(ROB_flush),			   	// external flush

	// From FetchStage
	.I1(fetch_I1),
	.I2(fetch_I2),
	.I1V(fetch_I1V),
	.I2V(fetch_I2V),
	.I1P(fetch_I1P),
	.I2P(fetch_I2P),
	.I1PC(fetch_I1PC),
	.I2PC(fetch_I2PC),

	// From Decoder
	.loop(loop),
	.I1_loop(I1_loop),
	.I2_loop(I2_loop),
	.I1V_loop(I1V_loop),
	.I2V_loop(I2V_loop),
	.I1P_loop(I1P_loop),
	.I2P_loop(I2P_loop),
	.I1PC_loop(I1PC_loop),
	.I2PC_loop(I2PC_loop),
	.I1_IMM(I1IMM_loop),
	.I2_IMM(I2IMM_loop),

	// Outputs to Decoder
	.I1_out(PR_I1),
	.I2_out(PR_I2),
	.I1V_out(PR_I1V),
	.I2V_out(PR_I2V),
	.I1P_out(PR_I1P),
	.I2P_out(PR_I2P),
	.I1PC_out(PR_I1PC),
	.I2PC_out(PR_I2PC),
	.I1_prev_IMM(PR_I1_prev_IMM),
	.I2_prev_IMM(PR_I2_prev_IMM)
);

// Instantiate Decoder
Decoder decoder_inst (
	.stall(Fetch_stall), //**Changed**

	// From SB
	.SB_idx_1(SB_idx_1),
	.SB_idx_2(SB_idx_2),

	// From ROB
	.ROB_idx_1(ROB_idx_1),
	.ROB_idx_2(ROB_idx_2),
	
	// From RRF
	.RRF_ptr_1(RRF_ptr_1),
	.RRF_ptr_2(RRF_ptr_2),
	.R_CZ_ptr_1(R_CZ_ptr_1),
	.R_CZ_ptr_2(R_CZ_ptr_2),
	.R_CZ_ptr_3(R_CZ_ptr_3),
	.R_CZ_ptr_4(R_CZ_ptr_4),
	.RRF_V_ARF_tags(RRF_V_ARF_tags),
	.RRF_D_ARF_tag_1(RRF_D_ARF_tag_1),
	.RRF_D_ARF_tag_2(RRF_D_ARF_tag_2),
	.RRF_D_ARF_tag_3(RRF_D_ARF_tag_3),
	.RRF_D_ARF_tag_4(RRF_D_ARF_tag_4),
	.RRF_D_ARF_tag_5(RRF_D_ARF_tag_5),
	.RRF_D_ARF_tag_6(RRF_D_ARF_tag_6),
	.RRF_D_ARF_tag_7(RRF_D_ARF_tag_7),

	// From ARF
	.ARF_B(ARF_B),
	.ARF_D1(ARF_D1),
	.ARF_D2(ARF_D2),
	.ARF_D3(ARF_D3),
	.ARF_D4(ARF_D4),
	.ARF_D5(ARF_D5),
	.ARF_D6(ARF_D6),
	.ARF_D7(ARF_D7),
	.ARF_tag_1(ARF_tag_1),
	.ARF_tag_2(ARF_tag_2),
	.ARF_tag_3(ARF_tag_3),
	.ARF_tag_4(ARF_tag_4),
	.ARF_tag_5(ARF_tag_5),
	.ARF_tag_6(ARF_tag_6),
	.ARF_tag_7(ARF_tag_7),
	.arch_C(arch_C),
	.arch_C_B(arch_C_B),
	.arch_C_tag(arch_C_tag),
	.arch_Z(arch_Z),
	.arch_Z_B(arch_Z_B),
	.arch_Z_tag(arch_Z_tag),
	.R_CZ_V_arch_C_tag(R_CZ_V_arch_C_tag),
	.R_CZ_D_arch_C_tag(R_CZ_D_arch_C_tag),
	.R_CZ_V_arch_Z_tag(R_CZ_V_arch_Z_tag),
	.R_CZ_D_arch_Z_tag(R_CZ_D_arch_Z_tag),

	// From IF_ID_PR
	.PR_I1(PR_I1),
	.PR_I2(PR_I2),
	.PR_I1V(PR_I1V),
	.PR_I2V(PR_I2V),
	.PR_I1P(PR_I1P),
	.PR_I2P(PR_I2P),
	.PR_I1PC(PR_I1PC),
	.PR_I2PC(PR_I2PC),
	.PR_I1_prev_IMM(PR_I1_prev_IMM),
	.PR_I2_prev_IMM(PR_I2_prev_IMM),

	// To IF_ID_PR
	.loop(loop),
	.I1_loop(I1_loop),
	.I2_loop(I2_loop),
	.I1V_loop(I1V_loop),
	.I2V_loop(I2V_loop),
	.I1P_loop(I1P_loop),
	.I2P_loop(I2P_loop),
	.I1PC_loop(I1PC_loop),
	.I2PC_loop(I2PC_loop),
	.I1IMM_loop(I1IMM_loop),
	.I2IMM_loop(I2IMM_loop),

	// To RS
	.RS_AL_V1(RS_AL_V1),
	.RS_AL_V2(RS_AL_V2),
	.RS_AL_1(RS_AL_1),
	.RS_AL_2(RS_AL_2),
	.RS_LS_V1(RS_LS_V1),
	.RS_LS_V2(RS_LS_V2),
	.RS_LS_1(RS_LS_1),
	.RS_LS_2(RS_LS_2),
	
	// To ROB
	.ROB_V1(ROB_V1),
	.ROB_V2(ROB_V2),
	.ROB_1(ROB_1),
	.ROB_2(ROB_2),

	// To RRF
	.using_RRF_ptr_1(using_RRF_ptr_1),
	.using_RRF_ptr_2(using_RRF_ptr_2),
	.using_R_CZ_ptr_1(using_R_CZ_ptr_1),
	.using_R_CZ_ptr_2(using_R_CZ_ptr_2),
	.using_R_CZ_ptr_3(using_R_CZ_ptr_3),
	.using_R_CZ_ptr_4(using_R_CZ_ptr_4),

	// To ARF
	.ARF_update_tag_1(ARF_update_tag_1),
	.ARF_update_tag_2(ARF_update_tag_2),
	.ARF_new_reg_1(ARF_new_reg_1),
	.ARF_new_reg_2(ARF_new_reg_2),
	.ARF_new_tag_1(ARF_new_tag_1),
	.ARF_new_tag_2(ARF_new_tag_2),
	.update_arch_C(update_arch_C),
	.new_C_tag(new_C_tag),
	.update_arch_Z(update_arch_Z),
	.new_Z_tag(new_Z_tag),

	// To SB
	.SB_reserve_1(SB_reserve_1),
	.SB_reserve_2(SB_reserve_2),



	// Forward from execture to decoder
	.ALU1_D_W(ALU1_D_W),
	.ALU1_D(ALU1_D),
	.ALU1_D_RR(ALU1_D_RR),
	.ALU1_C_W(),
	.ALU1_C(),
	.ALU1_C_RR(),
	.ALU1_Z_W(),
	.ALU1_Z(),
	.ALU1_Z_RR(),

	.ALU2_D_W(ALU2_D_W),
	.ALU2_D(ALU2_D),
	.ALU2_D_RR(ALU2_D_RR),
	.ALU2_C_W(),
	.ALU2_C(),
	.ALU2_C_RR(),
	.ALU2_Z_W(),
	.ALU2_Z(),
	.ALU2_Z_RR(),

	.LS_D_W(LS_D_W),
	.LS_D(LS_D),
	.LS_D_RR(LS_D_RR),
	.LS_Z_W(),
	.LS_Z(),
	.LS_Z_RR()
);

// Instantiate RS
// Instantiate RS_ArithmeticLogical
RS_ArithmeticLogical #(
    .RS_AL_ENTRY_SIZE(RS_AL_ENTRY_SIZE)
) rs_arithmetic_logical_inst (
    .clk(clk),                          // external clock
    .reset(reset),                      // external reset
    // .stall(stall),                      // external stall
    .flush(ROB_flush),                      // external flush THIS DOES NOTHING HERE

    // From Decoder (2 entries)
    .RS_AL_V1(RS_AL_V1),
    .RS_AL_1(RS_AL_1),
    .RS_AL_V2(RS_AL_V2),
    .RS_AL_2(RS_AL_2),

    // From ALU1
    .ALU1_D_W(ALU1_D_W),
    .ALU1_D(ALU1_D),
    .ALU1_D_RR(ALU1_D_RR),

    // From ALU2
    .ALU2_D_W(ALU2_D_W),
    .ALU2_D(ALU2_D),
    .ALU2_D_RR(ALU2_D_RR),

    // From LS
    .LS_D_W(LS_D_W),
    .LS_D(LS_D),
    .LS_D_RR(LS_D_RR),

    // Outputs
    .rs_stall(rs_al_stall),                // Fetch/decode stall signal

    // To ALU1
    .ALU1_V(ALU1_V),
    .ALU1_opcode(ALU1_opcode),
    .ALU1_opr1(ALU1_opr1),
    .ALU1_opr2(ALU1_opr2),
    .ALU1_imm(ALU1_imm),
    .ALU1_carry(ALU1_carry),
    .ALU1_zero(ALU1_zero),
    .ALU1_neg_opr2(ALU1_neg_opr2),
    .ALU1_CZ_cond(ALU1_CZ_cond),
    .ALU1_dest(ALU1_dest),
    .ALU1_arch_dest(ALU1_arch_dest),
    .ALU1_prev_dest(ALU1_prev_dest),
    .ALU1_PC(ALU1_PC),
    .ALU1_C_dest(ALU1_C_dest),
    .ALU1_Z_dest(ALU1_Z_dest),
    .ALU1_branch_pred(ALU1_branch_pred),
    .ALU1_ROB_index(ALU1_ROB_index),

    // To ALU2
    .ALU2_V(ALU2_V),
    .ALU2_opcode(ALU2_opcode),
    .ALU2_opr1(ALU2_opr1),
    .ALU2_opr2(ALU2_opr2),
    .ALU2_imm(ALU2_imm),
    .ALU2_carry(ALU2_carry),
    .ALU2_zero(ALU2_zero),
    .ALU2_neg_opr2(ALU2_neg_opr2),
    .ALU2_CZ_cond(ALU2_CZ_cond),
    .ALU2_dest(ALU2_dest),
    .ALU2_arch_dest(ALU2_arch_dest),
    .ALU2_prev_dest(ALU2_prev_dest),
    .ALU2_PC(ALU2_PC),
    .ALU2_C_dest(ALU2_C_dest),
    .ALU2_Z_dest(ALU2_Z_dest),
    .ALU2_branch_pred(ALU2_branch_pred),
    .ALU2_ROB_index(ALU2_ROB_index),

	// General outputs
	.empty_pos1(rs_al_empty_pos1),
	.empty_pos2(rs_al_empty_pos2)
);

// Instantiate RS_LoadStore
RS_LoadStore #(
    .RS_LS_ENTRY_SIZE(RS_LS_ENTRY_SIZE)
) rs_load_store_inst (
    .clk(clk),                          // external clock
    .reset(reset),                      // external reset
    .stall(SB_stall),                    
    .flush(ROB_flush),                      // external flush THIS DOES NOTHING HERE

    // From Decoder (2 entries)
    .RS_LS_V1(RS_LS_V1),
    .RS_LS_1(RS_LS_1),
    .RS_LS_V2(RS_LS_V2),
    .RS_LS_2(RS_LS_2),

    // From ALU1
    .ALU1_D_W(ALU1_D_W),
    .ALU1_D(ALU1_D),
    .ALU1_D_RR(ALU1_D_RR),

    // From ALU2
    .ALU2_D_W(ALU2_D_W),
    .ALU2_D(ALU2_D),
    .ALU2_D_RR(ALU2_D_RR),

    // From LS
    .LS_D_W(LS_D_W),
    .LS_D(LS_D),
    .LS_D_RR(LS_D_RR),

    // Outputs
    .rs_stall(rs_ls_stall),                // Fetch/decode stall signal

	// To LoadStore
	.LS_V1(LS_LS_V1),
	.Load_Store(LS_load_store),
	.Base(LS_Base),
	.Offset(LS_Offset),
	.Source_Data(LS_Source_Data),
	.dest(LS_dest),
	.arch_dest_ls(LS_arch_dest_ls),
	.Z_dest(LS_Z_dest),
	.SB_index(LS_SB_index),
	.ROB_index(LS_ROB_index),
	.is_LMSM(LS_is_LMSM)//, **Changed**

	// // Check values
	// .empty_pos1(rs_ls_empty_pos1) **Changed**
);

// Instantiate RF
// Instantiate RRF
RRF rrf_inst (
	.clk(clk),
	// .stall(stall),
	.flush(ROB_flush),
	.reset(reset),

	// From Decoder
	.decode_use_slot1(using_RRF_ptr_1),
	.decode_use_slot2(using_RRF_ptr_2),

	// From Execute
	.write1_en(ALU1_D_W),
	.write2_en(ALU2_D_W),
	.write3_en(LS_D_W),
	.write1_idx(ALU1_D_RR),
	.write2_idx(ALU2_D_RR),
	.write3_idx(LS_D_RR),
	.write1_data(ALU1_D),
	.write2_data(ALU2_D),
	.write3_data(LS_D),

	// From ARF
	.ARF_tag_1(ARF_tag_1),
	.ARF_tag_2(ARF_tag_2),
	.ARF_tag_3(ARF_tag_3),
	.ARF_tag_4(ARF_tag_4),
	.ARF_tag_5(ARF_tag_5),
	.ARF_tag_6(ARF_tag_6),
	.ARF_tag_7(ARF_tag_7),

	// From ROB
	.rob_write_valid1(ROB_RRF_W1),
	.rob_write_index1(ROB_RRF_writeidx1),
	.rob_rrf_read_idx1(ROB_RRF_readidx1),
	.rob_write_valid2(ROB_RRF_W2),
	.rob_write_index2(ROB_RRF_writeidx2),
	.rob_rrf_read_idx2(ROB_RRF_readidx2),

	// To Decode
	.two_empty_available(RRF_two_available),		// THESE STALL SOMEWHERE
	.empty_pos1_idx(RRF_ptr_1),
	.empty_pos2_idx(RRF_ptr_2),
	.RRF_data_1(RRF_D_ARF_tag_1),
	.RRF_valid_1(RRF_V_ARF_tags[1]),
	.RRF_data_2(RRF_D_ARF_tag_2),
	.RRF_valid_2(RRF_V_ARF_tags[2]),
	.RRF_data_3(RRF_D_ARF_tag_3),
	.RRF_valid_3(RRF_V_ARF_tags[3]),
	.RRF_data_4(RRF_D_ARF_tag_4),
	.RRF_valid_4(RRF_V_ARF_tags[4]),
	.RRF_data_5(RRF_D_ARF_tag_5),
	.RRF_valid_5(RRF_V_ARF_tags[5]),
	.RRF_data_6(RRF_D_ARF_tag_6),
	.RRF_valid_6(RRF_V_ARF_tags[6]),
	.RRF_data_7(RRF_D_ARF_tag_7),
	.RRF_valid_7(RRF_V_ARF_tags[7]),

	// To ARF
	.ARF_write_valid1(RRF_ARF_write_en1),
	.ARF_write_index1(RRF_ARF_write_idx1),
	.ARF_write_data1(RRF_ARF_write_data1),
	.ARF_write_tag1(RRF_ARF_write_tag1),
	.ARF_write_valid2(RRF_ARF_write_en2),
	.ARF_write_index2(RRF_ARF_write_idx2),
	.ARF_write_data2(RRF_ARF_write_data2),
	.ARF_write_tag2(RRF_ARF_write_tag2)
);

// Instantiate ARF
ARF arf_inst (
	.clk(clk),
	.reset(reset),
	// .stall(stall),
	.flush(ROB_flush),

	// From Decoder
	.decode_reg_idx1(ARF_new_reg_1),
	.decode_reg_idx2(ARF_new_reg_2),
	.decode_new_tag1(ARF_new_tag_1),
	.decode_new_tag2(ARF_new_tag_2),
	.decode_update_tag1(ARF_update_tag_1),
	.decode_update_tag2(ARF_update_tag_2),

	// From RRF
	.rrf_write_idx1(RRF_ARF_write_idx1),
	.rrf_write_idx2(RRF_ARF_write_idx2),
	.rrf_write_data1(RRF_ARF_write_data1),
	.rrf_write_data2(RRF_ARF_write_data2),
	.rrf_write_en1(RRF_ARF_write_en1),
	.rrf_write_en2(RRF_ARF_write_en2),
	.rrf_write_tag1(RRF_ARF_write_tag1),
	.rrf_write_tag2(RRF_ARF_write_tag2),

	// To Decode
	.busy_bits(ARF_B),
	.ARF_data_1(ARF_D1),
	.ARF_data_2(ARF_D2),
	.ARF_data_3(ARF_D3),
	.ARF_data_4(ARF_D4),
	.ARF_data_5(ARF_D5),
	.ARF_data_6(ARF_D6),
	.ARF_data_7(ARF_D7),

	// To Decode and RRF
	.ARF_tag_1(ARF_tag_1),
	.ARF_tag_2(ARF_tag_2),
	.ARF_tag_3(ARF_tag_3),
	.ARF_tag_4(ARF_tag_4),
	.ARF_tag_5(ARF_tag_5),
	.ARF_tag_6(ARF_tag_6),
	.ARF_tag_7(ARF_tag_7)
);

// Instantiate ExecuteStage
// Instantiate ALU1
alu alu1_inst (
	// Inputs
	.valid(ALU1_V),
	.opcode(ALU1_opcode),
	.opr1(ALU1_opr1),
	.opr2(ALU1_opr2),
	.imm(ALU1_imm),
	.carry(ALU1_carry),
	.zero(ALU1_zero),
	.neg_opr2(ALU1_neg_opr2),
	.CZ_cond(ALU1_CZ_cond),
	.dest(ALU1_dest),
	.arch_dest(ALU1_arch_dest),
	.prev_dest(ALU1_prev_dest),
	.PC(ALU1_PC),
	.C_dest(ALU1_C_dest),
	.Z_dest(ALU1_Z_dest),
	.branch_pred(ALU1_branch_pred),
	.ROB_index_in(ALU1_ROB_index),

	// Outputs
	// For RRF
	.ALU_W(ALU1_D_W),
	.ALU_D(ALU1_D),
	.ALU_RR(ALU1_D_RR),

	// For R_CZ
	.ALU_C_W(),
	.ALU_C(),
	.ALU_C_RR(),
	.ALU_Z_W(),
	.ALU_Z(),
	.ALU_Z_RR(),

	// For ROB
	.ALU_branch_mispred(ALU1_branch_mispred),
	.ALU_new_PC(ALU1_new_PC),
	.ROB_update(ALU1_ROB_W),
	.ROB_index_out(ALU_to_ROB_index1)
);

// Instantiate ALU2
alu alu2_inst (
	// Inputs
	.valid(ALU2_V),
	.opcode(ALU2_opcode),
	.opr1(ALU2_opr1),
	.opr2(ALU2_opr2),
	.imm(ALU2_imm),
	.carry(ALU2_carry),
	.zero(ALU2_zero),
	.neg_opr2(ALU2_neg_opr2),
	.CZ_cond(ALU2_CZ_cond),
	.dest(ALU2_dest),
	.arch_dest(ALU2_arch_dest),
	.prev_dest(ALU2_prev_dest),
	.PC(ALU2_PC),
	.C_dest(ALU2_C_dest),
	.Z_dest(ALU2_Z_dest),
	.branch_pred(ALU2_branch_pred),
	.ROB_index_in(ALU2_ROB_index),

	// Outputs
	// For RRF
	.ALU_W(ALU2_D_W),
	.ALU_D(ALU2_D),
	.ALU_RR(ALU2_D_RR),

	// For R_CZ
	.ALU_C_W(),
	.ALU_C(),
	.ALU_C_RR(),
	.ALU_Z_W(),
	.ALU_Z(),
	.ALU_Z_RR(),

	// For ROB
	.ALU_branch_mispred(ALU2_branch_mispred),
	.ALU_new_PC(ALU2_new_PC),
	.ROB_update(ALU2_ROB_W),
	.ROB_index_out(ALU_to_ROB_index2)
);

// Instantiate LoadStore Unit
load_store_unit load_store_unit_inst (
	// Inputs
	.Valid(LS_LS_V1),
	.Load_Store(LS_load_store),
	.Base(LS_Base),
	.Offset(LS_Offset),
	.Source_Data(LS_Source_Data),
	.dest(LS_dest),
	.arch_dest(LS_arch_dest_ls),
	.Z_dest(LS_Z_dest),
	.SB_index(LS_SB_index),
	.ROB_index(LS_ROB_index),
	.is_LMSM(LS_is_LMSM),

	.SB_match(SB_LS_match),
	.SB_data(SB_LS_data),

	.L1d_data(L1d_data),

	// Outputs
	// For RRF
	.LS_W(LS_D_W),
	.LS_RR(LS_D_RR),
	.LS_D(LS_D),

	// For R_CZ
	.LS_Z_W(),
	.LS_Z_dest(),
	.LS_Z(),

	// For Store Buffer
	.SB_search_addr(SB_search_addr),
	.SB_W(SB_W),
	.SB_index_out(SB_index_out),
	.SB_addr_out(SB_addr_out),
	.SB_data_out(SB_data_out),

	// For ROB
	.ROB_W(LS_ROB_W),
	.ROB_index_out(LS_to_ROB_index),
	.LS_branch_mispred(LS_branch_mispred),
	.LS_new_PC(LS_new_PC),

	// For L1d cache
	.L1d_R(L1d_R),
	.L1d_addr(L1d_addr)
);

// Instantiate ROB
ROB #(
	.ROB_ENTRY_SIZE(55),
	.ROB_INDEX_SIZE(7),
	.RRF_SIZE(7),
	.R_CZ_SIZE(8),
	.SB_SIZE(5),
	.ROB_SIZE(128)
) rob_inst (
	// Main Control Signals
	.CLK(clk),
	// .Flush(flush),
	.RST(reset),

	// From Decoder
	.Dispatch1_V(ROB_V1),
	.Dispatch1(ROB_1),
	.Dispatch2_V(ROB_V2),
	.Dispatch2(ROB_2),

	// From ALU1
	.ALU1_mispred(ALU1_branch_mispred),
	.ALU1_new_PC(ALU1_new_PC),
	.ALU1_valid(ALU1_ROB_W),
	.ALU1_index(ALU_to_ROB_index1),

	// From ALU2
	.ALU2_mispred(ALU2_branch_mispred),
	.ALU2_new_PC(ALU2_new_PC),
	.ALU2_valid(ALU2_ROB_W),
	.ALU2_index(ALU_to_ROB_index2),

	// From Load/Store Unit
	.LSU_mispred(LS_branch_mispred),
	.LSU_new_PC(LS_new_PC),
	.LSU_valid(LS_ROB_W),
	.LSU_index(LS_to_ROB_index),

	// To RRF
	.ROB_Retire1_V(ROB_RRF_W1),
	.ROB_Retire1_ARF_Addr(ROB_RRF_writeidx1),
	.ROB_Retire1_RRF_Addr(ROB_RRF_readidx1),
	.ROB_Retire2_V(ROB_RRF_W2),
	.ROB_Retire2_ARF_Addr(ROB_RRF_writeidx2),
	.ROB_Retire2_RRF_Addr(ROB_RRF_readidx2),

	// To R_CZ
	.ROB_Retire1_C_V(),
	.ROB_Retire1_Z_V(),
	.ROB_Retire1_C_Addr(),
	.ROB_Retire1_Z_Addr(),
	.ROB_Retire2_C_V(),
	.ROB_Retire2_Z_V(),
	.ROB_Retire2_C_Addr(),
	.ROB_Retire2_Z_Addr(),

	// To Store Buffer
	.ROB_Retire_SB_Valid(ROB_SB_V),
	.ROB_Retire_SB_Index(ROB_SB_Index),

	// To Decoder
	.ROB_index_1(ROB_idx_1),
	.ROB_index_2(ROB_idx_2),

	// Stall output in case of ROB full
	.ROB_stall(ROB_stall),
	.Global_Flush(ROB_flush),
	.new_PC_value_after_misprediction(new_PC_value_after_misprediction)
);

// Instantiate SB
// Instantiate StoreBuffer
StoreBuffer store_buffer_inst (
	.CLK(clk),
	.RST(reset),

	// Inputs
	// Decode Stage
	.clear_speculative(ROB_flush),          // connect flush to clear speculative
	.reserve_1(SB_reserve_1),
	.reserve_2(SB_reserve_2),

	// Execute Stage
	.LS_W(SB_W),
	.LS_index(SB_index_out),
	.LS_addr(SB_addr_out),
	.LS_data(SB_data_out),

	// Load/Store Stage for load enquiry
	.LS_search_addr(SB_search_addr),

	// Writeback Stage
	.pop_head(pop_head),

	// Retiring Stage
	.ROB_W(ROB_SB_V), // combined ROB_SB_V1 and ROB_SB_V2 with 6 zeros padding
	.SB_index(ROB_SB_Index), // combined ROB_SB_Addr1 and ROB_SB_Addr2 with 30 zeros padding

	// Outputs
	// To decoder
	.free_index_1(SB_idx_1),
	.free_index_2(SB_idx_2),

	// To Reserve Station LS
	.stall(SB_stall),                           // connected to RS for LS

	// To L1-D Cache
	.head_valid(head_valid),                      // not connected
	.head_addr(head_addr),                       // not connected
	.head_data(head_data),                       // not connected

	// For loads store unit
	.LS_match(SB_LS_match),
	.LS_search_data(SB_LS_data)
);


// for now, if L1d_R is high, then read high, write low, and addr is L1d_addr, D_In is 0, D_Out is L1d_data
// else, if head_valid is high, then read low, write high, and addr is head_addr, D_out is 0, D_in is head_data, also remember to pop_head
// else read and write are both 0, addr is 0, data is 0

reg read_signal, write_signal;
reg [15:0] addr_signal, data_in_signal;
wire [15:0] data_out_signal;

always @(*) begin
	if (L1d_R) begin
		read_signal = 1;
		write_signal = 0;
		addr_signal = L1d_addr;
		data_in_signal = 16'b0;
		pop_head = 0;
	end else if (head_valid) begin
		read_signal = 0;
		write_signal = 1;
		addr_signal = head_addr;
		data_in_signal = head_data;
		pop_head = 1;
	end else begin
		read_signal = 0;
		write_signal = 0;
		addr_signal = 16'b0;
		data_in_signal = 16'b0;
		pop_head = 0;
	end
end

assign L1d_data = data_out_signal;

DataMemory data_memory_inst (
	.clk(clk),
	.Read(read_signal), 
	.Write(write_signal), 
	.Addr(addr_signal), 
	.D_In(data_in_signal), 
	.D_Out(data_out_signal) 
);

// // Instantiate Data Memory (L1-D Cache)
// module DataMemory(
//     input         clk,
//     input         Read,
//     input         Write,
//     input  [15:0] Addr,     // full 16-bit address
//     input  [15:0] D_In,     // Data input for write operations
//     output reg [15:0] D_Out // Data output: concatenation of two 8-bit values
// );



endmodule
