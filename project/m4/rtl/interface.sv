/* -----------------------------------------------------------------------------
 * File:        interface.sv
 * Description: AXI4-Lite Slave Interface for the HDC Accelerator.
 * ----------------------------------------------------------------------------- */

module axi_interface #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    axi_aresetn,

    input  logic [ADDR_WIDTH-1:0]   awaddr,
    input  logic                    awvalid,
    output logic                    awready,

    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic                    wvalid,
    output logic                    wready,

    output logic [1:0]              bresp,
    output logic                    bvalid,
    input  logic                    bready,

    input  logic [ADDR_WIDTH-1:0]   araddr,
    input  logic                    arvalid,
    output logic                    arready,

    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [1:0]              rresp,
    output logic                    rvalid,
    input  logic                    rready,

    // Application-Facing Ports
    output logic [DATA_WIDTH-1:0]   app_ctrl, // NEW: Passes full control register
    output logic [DATA_WIDTH-1:0]   app_data_a,
    output logic [DATA_WIDTH-1:0]   app_data_b,
    output logic                    app_start,
    input  logic [DATA_WIDTH-1:0]   app_data_out,
    input  logic                    app_core_ready
);

    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_base_vec;
    logic [DATA_WIDTH-1:0] reg_feat_vec;

    assign app_ctrl   = reg_control;
    assign app_data_a = reg_base_vec;
    assign app_data_b = reg_feat_vec;
    assign app_start  = reg_control[0];

    assign awready = 1'b1;
    assign wready  = 1'b1;
    
    always_ff @(posedge clk) begin
        if (!axi_aresetn) begin
            bvalid       <= 1'b0;
            reg_control  <= '0;
            reg_base_vec <= '0;
            reg_feat_vec <= '0;
        end else begin
            if (awvalid && wvalid) begin
                bvalid <= 1'b1;
                case (awaddr[7:0])
                    8'h00: reg_control  <= wdata;
                    8'h04: reg_base_vec <= wdata;
                    8'h08: reg_feat_vec <= wdata;
                    default: ;
                endcase
            end else if (bready && bvalid) begin
                bvalid <= 1'b0;
            end
        end
    end
    assign bresp = 2'b00;

    assign arready = 1'b1;
    always_ff @(posedge clk) begin
        if (!axi_aresetn) begin
            rvalid <= 1'b0;
            rdata  <= '0;
        end else begin
            if (arvalid) begin
                rvalid <= 1'b1;
                case (araddr[7:0])
                    8'h00: rdata <= {reg_control[31:2], app_core_ready, reg_control[0]};
                    8'h04: rdata <= reg_base_vec;
                    8'h08: rdata <= reg_feat_vec;
                    8'h0C: rdata <= app_data_out;
                    default: rdata <= '0;
                endcase
            end else if (rready && rvalid) begin
                rvalid <= 1'b0;
            end
        end
    end
    assign rresp = 2'b00;

endmodule