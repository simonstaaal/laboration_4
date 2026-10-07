module digital_lock(
    input logic clk,
    input logic rst_n,
    input logic [3:0] key,
    input logic valid_key,
    output logic state
);

typedef enum logic [1:0]{
    Unlocked, Locked
}state_ty;

 logic [15:0] input_pw, saved_pw, next_input_pw, next_saved_pw;


state_ty pres_state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        pres_state <=  Unlocked;
        input_pw <= 16'h0;
        saved_pw <= 16'h1234;
    end
    else begin
        pres_state <= next_state;
        input_pw <= next_input_pw;
        saved_pw <= next_saved_pw;
    end
end


always_comb begin 
    next_state = pres_state;
    next_input_pw = input_pw;
    next_saved_pw = saved_pw;
    state = 0;

    case(pres_state)
    Unlocked: begin
        state = 0;
        next_input_pw = 16'h0;
        if(valid_key == 1'b1) begin
            if(key == 4'hB) begin
                next_state = Locked;
            end
            if (key == 4'hE) begin
                
            end    
        end
    end
    /*
    Unlocked: begin
        state = 0;
        next_input_pw = 16'h0 
        if(valid_key == 1'b1 && key == 4'hB) begin
            next_state = Locked;
        end
    end
    */
    Locked: begin
        state = 1;
        if(valid_key == 1'b1)begin
            if(key == 4'hC && input_pw == saved_pw)begin
                next_state = Unlocked;
            end
            else begin
                next_input_pw = {input_pw, key};
            end
       end
    end
    endcase
end

endmodule