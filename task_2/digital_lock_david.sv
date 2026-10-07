module digital_lock(
    input logic clk,
    input logic rst_n,
    input logic [3:0] key,
    input logic valid_key,
    output logic state
);

typedef enum logic [1:0]{
    Unlocked, Locked, Change_PW
}state_ty;

logic [15:0] input_pw, saved_pw, next_input_pw;
logic [1:0] pw_change_count, next_pw_change_count;
logic update_pw;

state_ty pres_state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        pres_state <=  Unlocked;
        input_pw <= 16'h0;
        saved_pw <= 16'h1234;
        pw_change_count <= 2'b00;
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