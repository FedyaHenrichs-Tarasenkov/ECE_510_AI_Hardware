/* -----------------------------------------------------------------------------
 * File:        interface.sv
 * Description: AXI4-Lite Slave Interface for the HDC Accelerator.
 *
 * Protocol:    AXI4-Lite (32-bit Data, 32-bit Address)
 * Clocking:    Single clock domain (clk).
 * Reset:       Synchronous, active-low reset (axi_aresetn).
 *
 * Register Map:
 * Address 0x00 : Control/Status Register (Read/Write)
 * [0]   - Start HDC Operation (Write 1 to trigger)
 * [1]   - HDC Core Ready (Read Only)
 * Address 0x04 : Base Vector Input Data (Write Only)
 * Address 0x08 : Feature Vector Input Data (Write Only)
 * Address 0x0C : Bound Vector Output Data (Read Only)
 * ----------------------------------------------------------------------------- */

module axi_interface #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    axi_aresetn, // Standard AXI reset is active-low

    // AXI4-Lite Write Address Channel
    input  logic [ADDR_WIDTH-1:0]   awaddr,
    input  logic                    awvalid,
    output logic                    awready,

    // AXI4-Lite Write Data Channel
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic                    wvalid,
    output logic                    wready,

    // AXI4-Lite Write Response Channel
    output logic [1:0]              bresp,
    output logic                    bvalid,
    input  logic                    bready,

    // AXI4-Lite Read Address Channel
    input  logic [ADDR_WIDTH-1:0]   araddr,
    input  logic                    arvalid,
    output logic                    arready,

    // AXI4-Lite Read Data Channel
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [1:0]              rresp,
    output logic                    rvalid,
    input  logic                    rready
);

    // Internal Registers
    logic [DATA_WIDTH-1:0] reg_control;
    logic [DATA_WIDTH-1:0] reg_base_vec;
    logic [DATA_WIDTH-1:0] reg_feat_vec;
    logic [DATA_WIDTH-1:0] reg_bound_vec;

    // Simplified AXI4-Lite Write Logic
    assign awready = 1'b1;
    assign wready  = 1'b1;
    
    always_ff @(posedge clk) begin
        if (!axi_aresetn) begin
            bvalid      <= 1'b0;
            reg_control <= '0;
            reg_base_vec<= '0;
            reg_feat_vec<= '0;
        end else begin
            if (awvalid && wvalid) begin
                bvalid <= 1'b1; // Send write response
                case (awaddr[7:0])
                    8'h00: reg_control  <= wdata;
                    8'h04: reg_base_vec <= wdata;
                    8'h08: reg_feat_vec <= wdata;
                    default: ; // Do nothing
                endcase
            end else if (bready && bvalid) begin
                bvalid <= 1'b0;
            end
        end
    end
    assign bresp = 2'b00; // OKAY response

    // Simplified AXI4-Lite Read Logic
    assign arready = 1'b1;

    always_ff @(posedge clk) begin
        if (!axi_aresetn) begin
            rvalid <= 1'b0;
            rdata  <= '0;
        end else begin
            if (arvalid) begin
                rvalid <= 1'b1;
                case (araddr[7:0])
                    8'h00: rdata <= reg_control;
                    8'h04: rdata <= reg_base_vec;
                    8'h08: rdata <= reg_feat_vec;
                    8'h0C: rdata <= reg_bound_vec;
                    default: rdata <= '0;
                endcase
            end else if (rready && rvalid) begin
                rvalid <= 1'b0;
            end
        end
    end
    assign rresp = 2'b00; // OKAY response

endmodule