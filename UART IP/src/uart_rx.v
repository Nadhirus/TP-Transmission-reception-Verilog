module uart_rx(
    input wire clk,           // System clock
    input wire rst_n,         // Asynchronous reset
    input wire rx,            // Receive data line
    output reg [7:0] data,    // Received data
    output reg received,      // Flag indicating data has been received
    input wire rts,           // Request to send (from transmitter)
    output reg cts            // Clear to send (flow control)
);

    reg [3:0] state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg [12:0] clock_div;     // Counter for timing

    localparam IDLE   = 4'd0;
    localparam START  = 4'd1;
    localparam DATA   = 4'd2;
    localparam STOP   = 4'd3;
    localparam DONE   = 4'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            received <= 1'b0;
            cts <= 1'b1;      // CTS deasserted by default
            clock_div <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    received <= 1'b0;
                    cts <= 1'b1;  // CTS deasserted, not ready to receive
                    if ((rx == 1'b0) && (rts == 1'b0)) begin // Wait for start bit and RTS from transmitter
                        cts <= 1'b0;   // Assert CTS, ready to receive
                        state <= START;
                    end
                end
                START: begin
                    if (clock_div == 6) begin  // Wait for the middle of the start bit
                        state <= DATA;
                        clock_div <= 0;
                        bit_count <= 0;
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                DATA: begin
                    if (clock_div == 12) begin  // Sample data bit in the middle of each bit time
                        shift_reg <= {rx, shift_reg[7:1]}; // Shift data in
                        bit_count <= bit_count + 1;
                        clock_div <= 0;
                        if (bit_count == 8) begin
                            state <= STOP;  // All 8 bits received
                        end
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                STOP: begin
                    if (clock_div == 12) begin
                        state <= DONE;    // Wait for the stop bit
                        clock_div <= 0;
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                DONE: begin
                    data <= shift_reg;    // Output received data
                    received <= 1'b1;     // Set received flag
                    cts <= 1'b1;          // Deassert CTS
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
