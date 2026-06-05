`timescale 1ns / 1ps

interface axis_if #(parameter DATA_WIDTH = 96);
    logic                    tvalid;
    logic                    tready;
    logic [DATA_WIDTH-1:0]   tdata;
    logic                    tlast;

    modport slave (
        input  tvalid, tdata, tlast,
        output tready
    );

    modport master (
        output tvalid, tdata, tlast,
        input  tready
    );
endinterface