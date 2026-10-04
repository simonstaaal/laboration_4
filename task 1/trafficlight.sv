module trafficlight #(parameter RED_DELAY = 5 ,parameter  RED_ORANGE_DELAY = 2, parameter GREEN_DELAY =7, parameter ORANGE_DELAY= 2, parameter COUNTER_WIDTH= 3)(
    input logic clk,
    input logic rst_n,
    output logic red,
    output logic orange,
    output logic green
);

//Define states
typedef enum logic [1:0] { 
    Red, RedOrange, Orange, Green
} state_ty;

state_ty pres_state, next_state;
logic [COUNTER_WIDTH - 1:0] counter, next_counter;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin //rst_n aktiv låg när den är 0 är vi i reset state
        pres_state <= Red;
        counter <= 0;
    end
    else begin
        pres_state <= next_state;
        counter <= next_counter;
    end
   
end

always_comb begin
    next_state = pres_state;
    next_counter = counter + 1;
    red = 0;
    orange = 0;
    green = 0;

    case(pres_state)
    Red: begin
        red = 1;
        if(counter == RED_DELAY -1) begin
            next_state = RedOrange;
            next_counter = 0;
        end
    end

    RedOrange: begin
        red = 1;
        orange = 1;
        if(counter == RED_ORANGE_DELAY -1) begin
            next_state = Green;
            next_counter = 0;
        end
    end

    Green: begin
        green = 1;
        if(counter == GREEN_DELAY - 1) begin
            next_state = Orange;
            next_counter = 0;
        end
    end

    Orange: begin
        orange = 1;
        if(counter == ORANGE_DELAY -1) begin
            next_state = Red;
            next_counter = 0;
        end
    end
    endcase


    
end

endmodule