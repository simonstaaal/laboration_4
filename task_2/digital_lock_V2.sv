module digital_lock(
    input logic clk,
    input logic rst_n,
    input logic [3:0] key,
    input logic valid_key_btn,
    output logic state
);

typedef enum logic [1:0]{
    Unlocked, Locked, Change_PW, Pressed, Released
}state_ty;

logic [15:0] input_pw, saved_pw, next_input_pw;
logic [1:0] pw_change_count, next_pw_change_count;
logic update_pw;

logic [7:0] debounce_register;
logic debounced_valid_key;
logic valid_key;
logic divided_clk;

state_ty pres_state, next_state, btn_state, next_btn_state;

clock_divider #(
        .DIVISOR(100000000)
        ) clock_divider_inst (
        .rst_n(rst_n),
        .clk_in(CLK_100MHZ),
        .clk_out(divided_clk)
    );

always_ff @(posedge divided_clk or negedge rst_n) begin
    if(rst_n == 0) begin
        debounce_register <= 8'h00;
        debounced_valid_key <= 1'b0;
        btn_state <= Released;
        valid_key <= 1'b0;
    end
    else begin
        debounce_register <= {debounce_register[6:0], valid_key_btn};
        btn_state <= next_btn_state;
    end

    if(debounce_register == 8'hFF) begin
        debounced_valid_key <= 1'b1;
    end
    else begin
        debounced_valid_key <= 1'b0;
    end
end

always_ff @(posedge CLK_100MHZ or negedge rst_n) begin
    if(rst_n == 0) begin
        pres_state <=  Unlocked;
        input_pw <= 16'h0;
        saved_pw <= 16'h1234;
        pw_change_count <= 2'b00;
        debounced_valid_key <= 1'b0;
    end
    else begin
        pres_state <= next_state;
        input_pw <= next_input_pw;
        pw_change_count <= next_pw_change_count;
        if (update_pw) begin
            saved_pw <= input_pw;
        end
    end
end


always_comb begin
    next_state = pres_state;
    next_input_pw = input_pw;
    next_pw_change_count = pw_change_count;
    update_pw = 1'b0;
    state = 0;

    case(pres_state)
    Unlocked: begin
        state = 0;
        next_pw_change_count = 2'b00;

        if(valid_key == 1'b1 && key == 4'hB) begin
            next_state = Locked;
        end
        if(valid_key == 1'b1 && key == 4'hE) begin
            next_state = Change_PW;
        end
    end

    Locked: begin
        state = 1;
        if(valid_key == 1'b1) begin
            if(key == 4'hC && input_pw == saved_pw) begin
                next_state = Unlocked;
            end
            next_input_pw = {input_pw[11:0], key};
        end
    end

    Change_PW: begin
        state = 0;
        if(valid_key == 1'b1) begin
            next_input_pw = {input_pw[11:0], key};
            next_pw_change_count = pw_change_count + 1;
            if(pw_change_count == 2'b11) begin
                update_pw = 1'b1;
                next_state = Unlocked;
            end
        end
    end

    endcase

end

endmodule