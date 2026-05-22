/* -----------------------------------------------------------------------------
 * File:        top.sv
 * Description: Integrated Top-Level Module for the HDC Edge AI Accelerator.
 * Instantiates the AXI4-Lite interface and the HDC compute core,
 * connecting the host memory map to the 32-bit parallel XOR datapath.
 *
 * Glue Logic:  - Reset Inversion: Converts active-low AXI reset to active-high core reset.
 * - Handshake routing: Connects interface triggers/registers to core.
 *
 * Ports:
 * Global:
 * - clk          : input  : 1-bit  : System clock (100 MHz target).
 * - axi_aresetn  : input  : 1-bit  : AXI4-Lite synchronous active-low reset.
 *
 * AXI4-Lite Write Address Channel:
 * - awaddr       : input  : 32-bit : Write address.
 * - awvalid      : input  : 1-bit  : Write address valid.
 * - awready      : output : 1-bit  : Write address ready.
 *
 * AXI4-Lite Write Data Channel:
 * - wdata        : input  : 32-bit : Write data.
 * - wvalid       : input  : 1-bit  : Write valid.
 * - wready       : output : 1-bit  : Write ready.
 *
 * AXI4-Lite Write Response Channel:
 * - bresp        : output : 2-bit  : Write response.
 * - bvalid       : output : 1-bit  : Write response valid.
 * - bready       : input  : 1-bit  : Response ready.
 *
 * AXI4-Lite Read Address Channel:
 * - araddr       : input  : 32-bit : Read address.
 * - arvalid      : input  : 1-bit  : Read address valid.
 * - arready      : output : 1-bit  : Read address ready.
 *
 * AXI4-Lite Read Data Channel:
 * - rdata        : output : 32-bit : Read data.
 * - rresp        : output : 2-bit  : Read response.
 * - rvalid       : output : 1-bit  : Read valid.
 * - rready       : input  : 1-bit  : Read ready.
 * ----------------------------------------------------------------------------- */

module top (
    input  logic        clk,
    input  logic        axi_aresetn,

    input  logic [31:0] awaddr,
    input  logic        awvalid,
    output logic        awready,

    input  logic [31:0] wdata,
    input  logic        wvalid,
    output logic        wready,

    output logic [1:0]  bresp,
    output logic        bvalid,
    input  logic        bready,

    input  logic [31:0] araddr,
    input  logic        arvalid,
    output logic        arready,

    output logic [31:0] rdata,
    output logic [1:0]  rresp,
    output logic        rvalid,
    input  logic        rready
);

    // =========================================================================
    // GLUE LOGIC & INTERNAL NETS
    // =========================================================================
    
    // 1. Reset Conversion (Glue Logic)
    logic core_rst;
    assign core_rst = ~axi_aresetn;

    // 2. Data & Control Routing (Glue Logic)
    logic        intf_to_core_valid;
    logic [31:0] intf_to_core_data_a;
    logic [31:0] intf_to_core_data_b;
    logic        core_to_intf_ready;
    logic        core_to_intf_valid;
    logic [31:0] core_to_intf_data;
    logic        intf_to_core_ready;

    // Tie the core's downstream ready signal high, as the interface 
    // dynamically routes the output directly to the read register.
    assign intf_to_core_ready = 1'b1;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // AXI4-Lite Interface
    axi_interface intf_inst (
        .clk(clk),
        .axi_aresetn(axi_aresetn),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wvalid(wvalid),
        .wready(wready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),

        // Application Side Ports
        .app_start(intf_to_core_valid),       
        .app_core_ready(core_to_intf_ready),  
        .app_data_a(intf_to_core_data_a),     
        .app_data_b(intf_to_core_data_b),     
        .app_data_out(core_to_intf_data)      
    );

    // HDC Compute Core (Binding Unit)
    compute_core core_inst (
        .clk(clk),
        .rst(core_rst), // Driven by Glue Logic
        
        .s_axi_valid(intf_to_core_valid),
        .s_axi_data_a(intf_to_core_data_a),
        .s_axi_data_b(intf_to_core_data_b),
        .s_axi_ready(core_to_intf_ready),
        
        .m_axi_valid(core_to_intf_valid),
        .m_axi_data(core_to_intf_data),
        .m_axi_ready(intf_to_core_ready) // Driven by Glue Logic
    );

endmodule