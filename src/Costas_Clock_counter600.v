module counter600(
input clock,
output wire clock600,
output reg unlock
);

    reg [9:0]count = 10'd0;
    reg clkstate = 0;
    always @(posedge clock) begin
        case(count)
            10'd29:  begin
                        count <= 10'd0;
                        clkstate <= 1'b1;
                    end
            10'd28: begin
                        count <= 10'd29;
                        unlock <= 1'd0;
                    end
            10'd1:   begin
                        count <= 10'd2;
                        unlock <= 1'd1;
                    end
            10'd0:  begin
                        count <= 10'd1;
                        clkstate <= 1'b0;
                   end
            default: begin 
                        count <= count + 1'd1;
                    end
        endcase
    end
    assign clock600 = clkstate;
endmodule