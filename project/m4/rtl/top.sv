/* -----------------------------------------------------------------------------
 * File:        top.sv
 * Description: Integrated Top-Level Module for the HDC Edge AI Accelerator.
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

    logic core_rst;
    assign core_rst = ~axi_aresetn;

    logic        intf_to_core_valid;
    logic [31:0] intf_to_core_ctrl; // NEW
    logic [31:0] intf_to_core_data_a;
    logic [31:0] intf_to_core_data_b;
    logic        core_to_intf_ready;
    logic        core_to_intf_valid;
    logic [31:0] core_to_intf_data;
    logic        intf_to_core_ready;

    assign intf_to_core_ready = 1'b1;

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

        .app_ctrl(intf_to_core_ctrl), // NEW
        .app_start(intf_to_core_valid),       
        .app_core_ready(core_to_intf_ready),  
        .app_data_a(intf_to_core_data_a),     
        .app_data_b(intf_to_core_data_b),     
        .app_data_out(core_to_intf_data)      
    );

    compute_core core_inst (
        .clk(clk),
        .rst(core_rst),
        
        .s_axi_ctrl(intf_to_core_ctrl), // NEW
        .s_axi_valid(intf_to_core_valid),
        .s_axi_data_a(intf_to_core_data_a),
        .s_axi_data_b(intf_to_core_data_b),
        .s_axi_ready(core_to_intf_ready),
        
        .m_axi_valid(core_to_intf_valid),
        .m_axi_data(core_to_intf_data),
        .m_axi_ready(intf_to_core_ready)
    );

endmodule