module Costas_TopLevel#(parameter PSK_SIGNAL_RATE_HZ = 125)(
  input logic sys_clk, // 27MHz embedded clock
  input logic pps, // 1Hz pulse
  input logic clk10M_w, // 10MHz clock
  input logic costas_txrq, // Costas array transmission request
  input logic psk_txrq, // PSK transmission request
  output logic mcu_costas_trigger, // Costas array trigger
  output logic mcu_costas_clk, // Costas array clock
  output logic mcu_psk_trigger, // PSK trigger
  output logic mcu_psk_clk, // PSK clock
  output logic fq_ud, // Frequency update request
  output logic unlock, // Unlock signal
  output logic unlock_psk, // PSK Unlock signal
  output logic[3:0] ledr // leds (For monitoring)
);


  logic clk10k;
  logic clock60;
  logic clock600;
  logic interCostasClock;
  logic interPskClock;
  logic Costas_fq_ud_n;
  logic Costas_fq_ud;
  logic Psk_fq_ud;
  logic Psk_fq_ud_n;

    assign Psk_fq_ud = ~Psk_fq_ud_n;
    assign Costas_fq_ud = ~Costas_fq_ud_n;

  counter60   counter60(.clock(pps), .clock60(clock60), .unlock(unlock));
  counter600  counter600(.clock(pps), .clock600(clock600), .unlock(unlock_psk));
//  counter1000 counter1000(.clock(sys_clk), .clock1000(clk10k));

  

  master_Counter #(.CLKDIV(250000), .DUTY( 50 )) interCostasCounter (.clockin(clk10M_w), .clockout(interCostasClock), .sync(unlock));
  master_Counter #(.CLKDIV(12500), .DUTY( 50 )) interPskCounter (.clockin(clk10M_w), .clockout(interPskClock), .sync(unlock_psk));
  master_Counter #(.CLKDIV(4), .DUTY( 25 ) ) CostasCounter (.clockin(interCostasClock), .clockout(mcu_costas_clk), .sync(1'b1));
  master_Counter #(.CLKDIV(4), .DUTY( 75 ) ) fq_udCounterCostas (.clockin(interCostasClock), .clockout(Costas_fq_ud_n), .sync(1'b1));
  master_Counter #(.CLKDIV(4), .DUTY( 75 ) ) fq_udCounterPsk (.clockin(interPskClock), .clockout(Psk_fq_ud_n), .sync(1'b1));
  master_Counter #(.CLKDIV(4), .DUTY( 25 ) ) PskCounter (.clockin(interPskClock), .clockout(mcu_psk_clk), .sync(1'b1));

  assign fq_ud = (Costas_fq_ud&costas_txrq) | (Psk_fq_ud&psk_txrq);
  assign mcu_costas_trigger = clock60 & (~clock600);
  assign mcu_psk_trigger = clock600;
  assign ledr[0] = mcu_costas_trigger;
  assign ledr[1] = mcu_psk_trigger;
  assign ledr[2] = pps;
  assign ledr[3] = mcu_costas_clk;

endmodule