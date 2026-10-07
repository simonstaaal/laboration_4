module fpga_digital_lock(
    input logic clk,
    input logic rst_n,
    input logic [3:0] key,
    input logic valid_key_btn,
    output logic state
);

logic [7:0] debounce_register;
logic debounced_valid_key;
logic valid_key;
logic divided_clk;


//Clock divider 1 sek?
clock_divider #(
        .DIVISOR(100000000)
        ) clock_divider_inst (
        .rst_n(rst_n),
        .clk_in(clk),
        .clk_out(divided_clk)
    );


//Register
always_ff @(posedge divided_clk or negedge rst_n) begin
    if(rst_n == 0) begin
        debounce_register <= 8'h00;
        debounced_valid_key <= 1'b0;
    end
    else begin
        debounce_register <= {debounce_register[6:0], valid_key_btn};

        if(debounce_register == 8'hFF) begin
            debounced_valid_key <= 1'b1;
        end
        else begin
            debounced_valid_key <= 1'b0;
        end
    end
end

key_press_detector key_press(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(debounced_valid_key),
    .key_out(valid_key)
);

digital_lock dig_lock (
    .clk(clk)
    .rst_n(rst_n)
    .key(key)
    .valid_key_btn(valid_key)
    .state(state)
);


// to keypressdetector
//clk in
//rst_n in
//debounced_valid_key in
// valid_key out

endmodule