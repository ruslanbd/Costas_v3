//-----------------------------------------------------------------------------
//
// Author: Ruslan Gindullin (W2HAT)
// Date: 2025-02-17
// Version: 3.0
// Revision: 1.0
// License: MIT
// Module name: Costas_TopLevel
// Filename:    TopLevel.v
//
// For HamSCI 2025 Workshop
//
//-----------------------------------------------------------------------------
// Description: 
//
// Costas_TopLevel is the top-level module for an amateur radio beacon. 
// It provides the necessary clock signals and triggers for the operation of
// an MCU loading an ad9850 DDS chip for precisely timed Costas array 
// transmissions and station ID using PSK. 
//
//-----------------------------------------------------------------------------
//
// Parameters:
// - PSK_SIGNAL_RATE_HZ: The signal rate for PSK transmission in Hz.
// (TODO: actually implement this)
//
//-----------------------------------------------------------------------------
// Ports
//-----------------------------------------------------------------------------
//
// Inputs:
// - sys_clk: 27MHz embedded clock (used for testing)
// - pps: 1Hz pulse
// - clk10M_w: 10MHz clock
// - costas_txrq: Costas array transmission request from MCU
// - psk_txrq: PSK transmission request from MCU
//
//-----------------------------------------------------------------------------
//
// Outputs:
// - mcu_costas_trigger: Costas array trigger
// - mcu_costas_clk: Costas array clock
// - mcu_psk_trigger: PSK trigger
// - mcu_psk_clk: PSK clock
// - fq_ud: Frequency update request
// - unlock: Unlock signal
// - unlock_psk: PSK Unlock signal
// - ledr: LEDs for monitoring
//
//-----------------------------------------------------------------------------

module Costas_TopLevel#(parameter PSK_SIGNAL_RATE_HZ = 125)(
  input logic sys_clk, // 27 MHz embedded clock
  input logic pps, // 1Hz pulse
  input logic clk10M_w, // 10MHz clock (MHz)
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