module master_Counter#(
    parameter CLKDIV = 1000,
    parameter DUTY = 500
    )(
input sync,
input clockin,
output wire clockout
);

    reg [31:0] count = 32'd0;
    reg clkstate = 0;
    reg syncd = 0;

    always @(posedge clockin) begin
            case(count)
                CLKDIV:  begin
                        count <= 10'd0;
                        clkstate <= 1'b1;
                    end
                duty_cycle(CLKDIV, DUTY):  begin
                        if(!sync && !syncd) begin 
                            count <= 0;
                            syncd <= 1;
                        end else begin 
                            count <= duty_next(CLKDIV, DUTY);
                            if(sync && syncd) syncd <= 0;
                            clkstate <= 1'd0;
                        end
                   end
                default: begin 
                        if(!sync && !syncd) begin 
                            count <= 0;
                            syncd <= 1;
                        end else begin 
                            count <= count + 1'd1;
                            if(sync && syncd)
                                syncd <= 0;
                            end
                    end
            endcase
    end
    assign clockout = clkstate;

    function automatic integer duty_cycle;
        input integer clkdiv;
        input integer duty;
        begin
            duty_cycle = (clkdiv * duty)/100;
        end
    endfunction

    function automatic integer duty_next;
        input integer clkdiv;
        input integer duty;
        begin
            duty_next = (clkdiv * duty)/100+1;
        end
    endfunction

endmodule