module uart_tx(
    input wire clk,         // System clock
    input wire rst_n,       // Asynchronous reset
    input wire transmit,    // Signal to start transmission
    input wire [7:0] data,  // Data to transmit
    input wire cts,         // Clear to send signal (from receiver)
    output reg tx,          // Transmit data line
    output reg rts          // Request to send (flow control)
);

    reg [3:0] state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg [12:0] clock_div;   // Counter for timing

    localparam IDLE   = 4'd0;
    localparam START  = 4'd1;
    localparam DATA   = 4'd2;
    localparam STOP   = 4'd3;
    localparam DONE   = 4'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1'b1;     // TX line idle state is high
            rts <= 1'b1;    // RTS is active low (deasserted)
            bit_count <= 0;
            clock_div <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    rts <= 1'b1;
                    if (transmit && (cts == 1'b0)) begin // CTS must be asserted by receiver
                        state <= START;
                        rts <= 1'b0;    // Assert RTS
                        shift_reg <= data;
                        bit_count <= 4'd0;
                    end
                end
                START: begin
                    tx <= 1'b0;   // Start bit (low)
                    if (clock_div == 12) begin  // Wait for 12 clock cycles (assuming 12 clocks per bit)
                        state <= DATA;
                        clock_div <= 0;
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                DATA: begin
                    if (clock_div == 12) begin
                        tx <= shift_reg[0];    // Transmit LSB first
                        shift_reg <= shift_reg >> 1; // Shift data
                        bit_count <= bit_count + 1;
                        clock_div <= 0;
                        if (bit_count == 8) begin
                            state <= STOP; // All 8 bits transmitted
                        end
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                STOP: begin
                    tx <= 1'b1;  // Stop bit (high)
                    if (clock_div == 12) begin
                        state <= DONE;
                        clock_div <= 0;
                    end else begin
                        clock_div <= clock_div + 1;
                    end
                end
                DONE: begin
                    rts <= 1'b1;  // Deassert RTS
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
