module key_press_detector(
    input logic clk,
    input logic rst_n,
    input logic key_in,
    output logic key_out
);

typedef enum logic { Released, Pressed } state_ty;

state_ty pres_state, next_state;
logic outp_intern;

always_ff @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        pres_state <= Released;
        key_out <= 0;
    end
    else begin
        pres_state <= next_state;
        key_out <= outp_intern;

    end
end


always_comb begin
    next_state = pres_state;
    outp_intern = 0;


    case(pres_state)
    Released: begin
        if(key_in == 1) begin
            next_state = Pressed;
            outp_intern = 1;
        end
        else begin
            next_state = Released;
            outp_intern = 0;
        end
    end

    Pressed: begin
        if(key_in == 0) begin
            next_state = Released;
            outp_intern = 0;
        end
        else begin
            next_state = Pressed;
            outp_intern = 0;
        end
    end
    endcase
end
endmodule