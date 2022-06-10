`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		parameter X = 1
	)(
	input logic clk, reset,

	input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  creq,
    input  cbus_resp_t cresp
);

`ifndef REFERENCE_CACHE

    localparam WORDS_PER_LINE = 16;
    localparam ASSOCIATIVITY = 2;
    localparam SET_NUM = 4;
    localparam OFFSET_BITS = $clog2(WORDS_PER_LINE);//4
    localparam INDEX_BITS = $clog2(SET_NUM);//3
    localparam TAG_BITS = 64 - INDEX_BITS - OFFSET_BITS - 3; /* Maybe 32, or
    smaller */
    localparam type offset_t = logic [OFFSET_BITS-1:0];
    localparam type index_t = logic [INDEX_BITS-1:0];
    localparam type tag_t = logic [TAG_BITS-1:0];
    function offset_t get_offset(addr_t addr);
        return addr[3+OFFSET_BITS-1:3];
    endfunction
    function index_t get_index(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS-1:OFFSET_BITS+3];
    endfunction
    function tag_t get_tag(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS+TAG_BITS-
    1:3+INDEX_BITS+OFFSET_BITS];
    endfunction
    // localparam type state_t = enum logic[2:0] {
    // INIT, FETCH, WRITEBACK 
    // };
    
    
    typedef enum logic[2:0] { 
        INIT, FETCH, WRITEBACK,
        EXCHANGE_1, EXCHANGE_2,
        IDLE, BURST
    } state_t;
    typedef struct packed {
        u1 valid;
        u1 dirty;
        tag_t tag;
    } meta_t;
    typedef u1 LRU_t[SET_NUM-1:0][ASSOCIATIVITY-1:0];
    typedef u7 index_counter_t;

	/* TODO: Lab3 Cache */

    // u64 data_array [SET_NUM-1:0][ASSOCIATIVITY-1:0][WORDS_PER_LINE-1:0];//数据内存
    // meta_t index_array [SET_NUM-1:0][ASSOCIATIVITY-1:0];//索引内存
    u1 LRU [SET_NUM-1:0][ASSOCIATIVITY-1:0];
    state_t state;
    index_counter_t counter;
    u2 age;
    meta_t meta_read, meta_write;
    u1 meta_strobe; 
    u8 data_strobe;
    word_t data_read, data_write;
    u5 block_counter;
    u1 LRU_result,row_num;
    offset_t offset_counter, data_offset;

    always_ff @ (posedge clk)
    begin
         counter <= counter + 1;
    end

//data_write
    always_comb begin
        data_write = '0;
        if(reset == 1)begin
            data_write = '0; 
        end
        else begin
            unique case(state)
                EXCHANGE_2:begin
                    data_write = cresp.data;
                end
                WRITEBACK:begin
                    data_write = dreq.data;
                end
                default:begin
                    
                end
            endcase 
        end
        
    end

//state状态
    always_ff @ (posedge clk)
    begin
        if(reset) begin
            state <= IDLE;
        end
        else begin
            unique case(state)
                INIT:begin
                    state <= FETCH;
                end
                FETCH:begin
                    if(age > ASSOCIATIVITY - 1)begin
                        if(meta_read.dirty == 1)begin
                            state <= EXCHANGE_1; 
                        end
                        else begin
                            state <= EXCHANGE_2; 
                        end
                    end
                    else if(meta_read.valid == 1 && 
                            meta_read.tag == dreq.addr[63:9])begin//命中
                        state <= WRITEBACK;
                    end
                    else begin
                        state <= FETCH;
                    end
                end
                WRITEBACK:begin
                    state <= IDLE; 
                end
                EXCHANGE_1: begin
                    if(block_counter == 15)begin//写完了
                        state <= EXCHANGE_2;
                    end
                    else begin
                        state <= EXCHANGE_1; 
                    end
                end
                EXCHANGE_2:begin
                    if(cresp.last == 1)begin//写完了
                        state <= WRITEBACK;
                    end
                    else begin
                        state <= EXCHANGE_2; 
                    end
                end
                IDLE: begin
                    if(dreq.valid == 1 && dreq.addr[31] == 0)begin
                        state <= BURST ;
                    end
                    else if(dreq.valid == 1)begin
                        state <= INIT; 
                    end
                    else begin
                        state <= IDLE; 
                    end
                end
                BURST:begin
                    if(cresp.last == 1)begin//单独访存完成
                        state <= IDLE; 
                    end
                    else begin
                        state <= BURST; 
                    end
                end
                default:begin
                    state <= IDLE;
                end
            endcase
        end
     end

//age行号计数
    always_ff @ (posedge clk)
    begin
        if(reset) begin
            age <= 0;
        end
        else begin
            unique case(state)
                INIT:begin
                    age <= '0; 
                end
                FETCH:begin
                    age <= age + 1;
                end
                default:begin
                    age <= age;
                end
            endcase
        end
    end
//block_counter行号计数器
    always_ff @ (posedge clk)
    begin
        if(reset) begin
            block_counter <= 0;
        end
        else begin
            unique case(state)
                EXCHANGE_1:begin
                    if(block_counter == 15)begin
                        block_counter <= '0; 
                    end
                    else if(cresp.ready == 1)begin
                        block_counter <= block_counter + 1;
                    end
                    else begin
                        block_counter <= block_counter;
                    end
                end
                EXCHANGE_2:begin
                    if(cresp.ready == 1)begin
                        block_counter <= block_counter + 1;
                    end
                    else begin
                        block_counter <= block_counter;
                    end
                end
                default:begin
                    block_counter <= '0;
                end
            endcase
        end
    end
//LRU————1代表上次用过
    always_ff @ (posedge clk)
    begin
        if(reset) begin
            for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                for (u2 j = 0; j != 2'b10 ; j++) begin : LRU_ASSOCIATIVITY
                   LRU[i[1:0]][j[0]] <= j[0]; 
                end : LRU_ASSOCIATIVITY   
            end : LRU_SET
        end
        else begin
            unique case(state)
            IDLE:begin
                for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                    if(LRU[i[1:0]][0] == '0 && LRU[i[1:0]][1] == '0)begin
                        LRU[i[1:0]][0] <= '0;
                        LRU[i[1:0]][1] <= '1;
                    end
                end : LRU_SET
            end
            FETCH:begin
                if(meta_read.valid == 1 && 
                meta_read.tag == dreq.addr[63:9])begin
                    for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                        for (u2 j = 0; j != 2'b10 ; j++) begin : LRU_ASSOCIATIVITY
                            if(i[1:0] != get_index(dreq.addr) )begin
                               LRU[i[1:0]][j[0]] <=LRU[i[1:0]][j[0]]; 
                            end
                            else begin
                                if(j[0]== age[0] )begin
                                   LRU[i[1:0]][j[0]] <= '1; 
                                end
                                else begin
                                   LRU[i[1:0]][j[0]] <= '0; 
                                end
                            end
                        end : LRU_ASSOCIATIVITY   
                    end : LRU_SET
                end
            end
                EXCHANGE_2:begin
                    if (cresp.last == 1) begin
                        for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                            for (u2 j = 0; j != 2'b10 ; j++) begin : LRU_ASSOCIATIVITY
                                if(i[1:0] != get_index(dreq.addr) )begin
                                   LRU[i[1:0]][j[0]] <=LRU[i[1:0]][j[0]]; 
                                end
                                else begin
                                   LRU[i[1:0]][j[0]] <= ~LRU[i[1:0]][j[0]]; 
                                end
                            end : LRU_ASSOCIATIVITY   
                        end : LRU_SET
                    end
                    else begin
                        for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                            for (u2 j = 0; j != 2'b10 ; j++) begin : LRU_ASSOCIATIVITY
                               LRU[i[1:0]][j[0]] <=LRU[i[1:0]][j[0]]; 
                            end : LRU_ASSOCIATIVITY   
                        end : LRU_SET
                    end
                end
                default:begin
                    for (u4 i = 0; i != 4'b0100; i++) begin : LRU_SET
                        for (u2 j = 0; j != 2'b10 ; j++) begin : LRU_ASSOCIATIVITY
                           LRU[i[1:0]][j[0]] <=LRU[i[1:0]][j[0]]; 
                        end : LRU_ASSOCIATIVITY   
                    end : LRU_SET
                end
            endcase
        end
    end
//选择替换的行号 输出上次没被用的
    always_comb begin
        LRU_result = '0;
        if(LRU[get_index(dreq.addr)][0] == 0)begin
            LRU_result = '0;
        end
        else begin
            LRU_result = '1; 
        end
    end

    always_comb begin
        row_num = '0;
        unique case (state)
            FETCH:begin
                if(age > ASSOCIATIVITY - 1) begin
                    row_num = LRU_result;
                end
                else begin
                    row_num = age[0];
                end
            end
            EXCHANGE_1:begin
                row_num = LRU_result;
            end
            EXCHANGE_2: begin
                row_num = LRU_result;
            end
            WRITEBACK:begin
                row_num = ~LRU_result; //输出上次用过的
            end
            default: begin
                row_num = age[0];
            end
        endcase 
    end

//状态机 creq dresp
    always_comb begin
        creq = '0;
        dresp = '0;
        unique case(state)
            WRITEBACK:begin
                creq = '0;

                dresp.addr_ok = '1;
                dresp.data_ok = '1;
                dresp.data = data_read;
            end
            EXCHANGE_1:begin
                creq.valid = '1;
                creq.is_write = '1;
                creq.addr = {meta_read.tag, get_index(dreq.addr), 4'b0, 3'b0};
                creq.size = MSIZE8;
                creq.data = data_read;
                creq.len = MLEN16;
                creq.burst = AXI_BURST_INCR;
                creq.strobe = '1;

                dresp.addr_ok = '0;
                dresp.data_ok = '0;
                dresp.data = '0;
            end
            EXCHANGE_2:begin
                creq.valid = '1;
                creq.is_write = '0;
                creq.addr = {dreq.addr[63:7], 4'b0,3'b0};
                creq.size = MSIZE8;
                creq.data = data_read;
                creq.len = MLEN16;
                creq.burst = AXI_BURST_INCR;
                creq.strobe = '0;

                dresp.addr_ok = '0;
                dresp.data_ok = '0;
                dresp.data = '0;
            end
            BURST:begin
                if(dreq.strobe == '0) begin//is read
                    creq.valid = '1;
                    creq.is_write = '0;
                    creq.addr = dreq.addr;
                    creq.size = dreq.size;
                    creq.data = dreq.data;
                    creq.len = MLEN1;
                    creq.burst = AXI_BURST_FIXED;
                    creq.strobe = dreq.strobe;

                    dresp.addr_ok = '1;
                    dresp.data_ok = cresp.last;
                    dresp.data = cresp.data;
                end
                else begin
                    creq.valid = '1;
                    creq.is_write = '1;
                    creq.addr = dreq.addr;
                    creq.size = dreq.size;
                    creq.data = dreq.data;
                    creq.len = MLEN1;
                    creq.burst = AXI_BURST_FIXED;
                    creq.strobe = dreq.strobe;

                    dresp.addr_ok = '1;
                    dresp.data_ok = cresp.last;
                    dresp.data = cresp.data;
                end
            end
            default:begin
                creq = '0;

                dresp.addr_ok = '0;
                dresp.data_ok = '0;
                dresp.data = '0;
            end
        endcase
    end
//data_strobe
    always_comb begin
        data_strobe = '0;
        if(reset == 1)begin
            data_strobe = '1;
        end
        else begin
            unique case (state)
                EXCHANGE_2: begin
                    if(cresp.ready == 1)begin
                        data_strobe = '1;
                    end
                    else begin
                        data_strobe = '0;
                    end
                end
                WRITEBACK:begin
                    data_strobe = dreq.strobe; 
                end
                default: begin
                    data_strobe = '0;
                end
            endcase 
        end
    end
//offset_counter 偏移计数器
    always_ff @ (posedge clk)begin
        if(reset)begin
            offset_counter <= '0;
        end
        else begin
            unique case (state)
                EXCHANGE_1: begin
                    if(cresp.ready == 1)begin
                        offset_counter <= offset_counter + 1; 
                    end
                    else if(cresp.last)begin
                        offset_counter <= '0;
                    end
                    else begin
                        offset_counter <= offset_counter;
                    end
                end
                EXCHANGE_2: begin
                    if(cresp.ready == 1)begin
                        offset_counter <= offset_counter + 1; 
                    end
                    else if(cresp.last)begin
                        offset_counter <= '0;
                    end
                    else begin
                        offset_counter <= offset_counter;
                    end
                end
                default: begin
                    offset_counter <= '0;
                end
            endcase 
        end
    end
    //确认data_offset
    always_comb begin
        data_offset = '0;
        unique case(state)
            EXCHANGE_1:begin
                data_offset = offset_counter; 
            end
            EXCHANGE_2:begin
                data_offset = offset_counter; 
            end
            default:begin
                data_offset = get_offset(dreq.addr);
            end
        endcase 
    end

//meta管理
    u3 meta_addr;
    always_comb begin
        meta_strobe = '0;
        meta_write = '0;
        meta_addr =  '0;
        if(reset)begin
            meta_strobe = '1;
            meta_write = '0;
            meta_addr =  counter[6:4];
        end
        else begin
            unique case(state)
                EXCHANGE_2:begin
                    if(cresp.last == 1)begin
                        meta_strobe = '1;
                        meta_write.valid = '1;
                        meta_write.dirty = '0;
                        meta_write.tag = dreq.addr[63:9];
                        meta_addr =  {get_index(dreq.addr), row_num};
                    end
                end
                WRITEBACK:begin
                    if(dreq.strobe != '0)begin
                        meta_strobe = '1;
                        meta_write.valid = '1;
                        meta_write.dirty = '1;
                        meta_write.tag = dreq.addr[63:9];
                        meta_addr =  {get_index(dreq.addr), row_num};
                    end
                    else begin
                        meta_strobe = '0;
                        meta_write.valid = '0;
                        meta_write.dirty = '0;
                        meta_write.tag = '0;
                        meta_addr =  {get_index(dreq.addr), row_num};
                    end
                end
                default:begin
                    meta_strobe = '0;
                    meta_write = '0;
                    meta_addr =  {get_index(dreq.addr), row_num};
                end
            endcase
        end
    end

    u7 data_addr;
    always_comb begin
        data_addr = '0;
        if(reset == 1 )begin
            data_addr = counter;
        end
        else begin
            data_addr =  {get_index(dreq.addr), row_num, data_offset};
        end 
    end
    RAM_SinglePort #(
        .ADDR_WIDTH($clog2(SET_NUM * ASSOCIATIVITY * WORDS_PER_LINE)),//8
        .DATA_WIDTH(64),
        .BYTE_WIDTH(8),
        .MEM_TYPE(0),
        .READ_LATENCY(0)
    ) data_array (
        .clk,  .en(1'b1),
        .addr(data_addr),
        .strobe(data_strobe),
        .wdata(data_write),
        .rdata(data_read)
    );
    // u4 meta_addr;
    // assign meta_addr =  {get_index(dreq.addr), row_num};
    RAM_SinglePort #(
        .ADDR_WIDTH($clog2(SET_NUM * ASSOCIATIVITY)),//4
        .DATA_WIDTH($bits(meta_t)),//44
        .BYTE_WIDTH($bits(meta_t)),//54
        .MEM_TYPE(0),
        .READ_LATENCY(0)
    ) meta (
        .clk,  .en(1'b1),
        .addr(meta_addr),
        .strobe(meta_strobe),
        .wdata(meta_write),
        .rdata(meta_read)
    );




`else

	typedef enum u2 {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

	// typedefs
    typedef union packed {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef u4 offset_t;

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];

    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram;
    word_t ram_rdata;

    always_comb
    unique case (state)
    FETCH: begin
        ram.en     = 1;
        ram.strobe = 8'b11111111;
        ram.wdata  = cresp.data;
    end

    READY: begin
        ram.en     = 1;
        ram.strobe = req.strobe;
        ram.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_inst (
        .clk(clk), .en(ram.en),
        .addr(offset),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) begin
        unique case (state)
        IDLE: if (dreq.valid) begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end else begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`endif

endmodule

`endif
