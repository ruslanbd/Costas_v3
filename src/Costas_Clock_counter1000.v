module counter1000(
input clock,
output wire clock1000
);

    reg [9:0]count = 10'd0;
    reg clkstate = 0;
    always @(posedge clock) begin
        case(count)
            10'd1000:  begin
                        count <= 10'd0;
                        clkstate <= 1'b1;
                    end
            10'd0:  begin
                        count <= 10'd1;
                        clkstate <= 1'd0;
                   end
            default: begin 
                        count <= count + 1'd1;
                    end
        endcase
    end
    assign clock1000 = clkstate;
endmodule