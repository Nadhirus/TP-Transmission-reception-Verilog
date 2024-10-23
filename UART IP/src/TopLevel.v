module TopLevel(
    input wire rst_n,            // Asynchronous reset
    input wire transmit,         // Signal to start transmission
    input wire [7:0] tx_data,    // Data to transmit
    output wire [7:0] rx_data,   // Received data
    output wire tx_done,         // Transmit done flag
    output wire rx_done          // Receive done flag
);

    InternalCLK your_instance_name(
        .oscout(oscout_o) //output oscout
    );

    // UART TX Instance
    uart_top uart_top_inst (
        .clk(oscout_o),
        .rst_n(rst_n),
        .transmit(transmit),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .tx_done(tx_done),
        .rx_done(rx_done)
    );


endmodule
