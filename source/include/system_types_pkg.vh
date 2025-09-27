/*
    Filename: system_types_pkg.vh
    Author: zlagpacan
    Description: Package Header File for System-Level Types
*/

`ifndef SYSTEM_TYPES_VH
`define SYSTEM_TYPES_VH

package system_types_pkg;

    // ----------------------------------------------------------------
    // General:

    parameter VA_WIDTH = 32;
    parameter VPN_WIDTH = 20;
    parameter VPN1_WIDTH = 10;
    parameter VPN0_WIDTH = 10;

    parameter PA_WIDTH = 34;
    parameter PPN_WIDTH = 22;
    parameter PPN1_WIDTH = 12;
    parameter PPN0_WIDTH = 10;

    parameter PO_WIDTH = 12;

    // ----------------------------------------------------------------
    // Caches:

    // coherence granularity 
    parameter COH_BLOCK_SIZE = 64; // 64B
    parameter COH_BLOCK_SIZE_BITS = COH_BLOCK_SIZE * 8; // 512b
        // AKA data512
    parameter COH_BLOCK_OFFSET = $clog2(COH_BLOCK_SIZE); // 6b
    parameter COH_BLOCK_ADDR_WIDTH = PA_WIDTH - COH_BLOCK_OFFSET; // 34b - 6b = 28b
        // AKA PA28

    // L1 granularity
    parameter L1_BLOCK_SIZE = 32; // 32B
    parameter L1_BLOCK_SIZE_BITS = L1_BLOCK_SIZE * 8; // 256b
        // AKA data256
    parameter L1_BLOCK_OFFSET = $clog2(L1_BLOCK_SIZE); // 5b
    parameter L1_BLOCK_ADDR_WIDTH = PA_WIDTH - L1_BLOCK_OFFSET; // 34b - 5b = 29b
        // AKA PA29

    // icache
        // sizing
    parameter ICACHE_SIZE = 2**13; // 8KB, 4KB page per way
    parameter ICACHE_BLOCK_SIZE = 32; // 32B
    parameter ICACHE_ASSOC = 2; // 2x
        // address bit partitioning
            // 16B*2-way fetch width
            // {tag[21:0], index[6:0], block_offset[0], fetch_offset[3:0]}
    parameter ICACHE_BLOCK_OFFSET_WIDTH = $clog2(ICACHE_BLOCK_SIZE); // 5b
    parameter ICACHE_NUM_SETS = ICACHE_SIZE / ICACHE_ASSOC / ICACHE_BLOCK_SIZE; // 128x
    parameter ICACHE_INDEX_WIDTH = $clog2(ICACHE_NUM_SETS); // 7b
    parameter ICACHE_TAG_WIDTH = PA_WIDTH - ICACHE_INDEX_WIDTH - ICACHE_BLOCK_OFFSET_WIDTH; // 34b - 7b - 5b = 22b
        // fetch side interface
    parameter ICACHE_FETCH_WIDTH = 16; // 16B
    parameter ICACHE_FETCH_BLOCK_OFFSET_WIDTH = $clog2(ICACHE_BLOCK_SIZE / ICACHE_FETCH_WIDTH); // 1b

    // dcache_write_buffer

    // dcache_amo_unit

    // dcache
    parameter DCACHE_SIZE = 2**13; // 8 KB
    parameter DCACHE_BLOCK_SIZE = 32;
    parameter DCACHE_ASSOC = 2;
    // hardcoded 2 banks, partitioned based on lowest index bit
    parameter DCACHE_BLOCK_OFFSET_WIDTH = $clog2(DCACHE_BLOCK_SIZE);
    parameter DCACHE_NUM_SETS = DCACHE_SIZE / DCACHE_ASSOC / DCACHE_BLOCK_SIZE;
    parameter DCACHE_NUM_SETS_PER_BANK = DCACHE_NUM_SETS / 2;
    parameter DCACHE_INDEX_WIDTH = $clog2(DCACHE_NUM_SETS_PER_BANK);
    parameter DCACHE_TAG_WIDTH = PA_WIDTH - DCACHE_INDEX_WIDTH - 1 - DCACHE_BLOCK_OFFSET_WIDTH;
    parameter DCACHE_BANK_BIT = DCACHE_BLOCK_OFFSET_WIDTH;
    parameter DCACHE_WORD_ADDR_BANK_BIT = DCACHE_BLOCK_OFFSET_WIDTH - 2;
    // data array access
        // grab index from index bits + upper block offset bits
    parameter DCACHE_DATA_WORD_WIDTH = 4;
    parameter LOG_DCACHE_DATA_WORD_WIDTH = $clog2(DCACHE_DATA_WORD_WIDTH);
    parameter DCACHE_DATA_WORD_INDEX_WIDTH = DCACHE_INDEX_WIDTH + DCACHE_BLOCK_OFFSET_WIDTH - LOG_DCACHE_DATA_WORD_WIDTH;
    parameter DCACHE_DATA_NUM_ROWS_PER_BANK = 2**DCACHE_DATA_WORD_INDEX_WIDTH;

    typedef struct packed {
        logic [DCACHE_TAG_WIDTH-1:0]            tag;
        logic [DCACHE_INDEX_WIDTH-1:0]          index;
        logic                                   bank;
        logic [DCACHE_BLOCK_OFFSET_WIDTH-1:0]   block_offset;
    } dcache_PA_t;

    // l2_cache

    // conflict_table

    // bus_amo_unit

    // bus

    // l3_cache

    // mem_controller_write_buffer

    // mem_controller

    // ----------------------------------------------------------------
    // TLB's:

    // itlb

    // dtlb

    // pt_walker

endpackage

`endif // SYSTEM_TYPES_VH