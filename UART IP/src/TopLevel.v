module uart_top(
    input wire clk,              // System clock
    input wire rst_n,            // Asynchronous reset
    input wire transmit,         // Signal to start transmission
    input wire [7:0] tx_data,    // Data to transmit
    output wire [7:0] rx_data,   // Received data
    output wire tx_done,         // Transmit done flag
    output wire rx_done          // Receive done flag
);

    // Internal signals
    wire tx;
    wire rx;
    wire rts;
    wire cts;

    // UART TX Instance
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .transmit(transmit),
        .data(tx_data),
        .cts(cts),
        .tx(tx),
        .rts(rts)
    );

    // UART RX Instance
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(tx),         // Connect TX to RX (loopback for testing)
        .data(rx_data),
        .received(rx_done),
        .rts(rts),
        .cts(cts)
    );

    assign tx_done = !uart_tx_inst.rts;  // Transmit done when RTS is deasserted

endmodule
