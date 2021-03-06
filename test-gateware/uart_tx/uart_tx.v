// -----------------------------------------------------------------------------
// Copyright (c) 2019 All rights reserved
// -----------------------------------------------------------------------------
// Author      : Josh Johnson <josh@joshajohnson.com>
// File        : uart_tx.v
// Description : 9600 Baud UART Transmitter
// Created     : 2019-10-25 16:14:50
// Revised     : 2019-10-25 16:14:50
// Editor      : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`ifndef _uart_tx_v_
`define _uart_tx_v_

`default_nettype none
`include "../src/clkDivHz.v"

module uart_tx(
    input clk,
    input [7:0] data,
    input send,
    output reg uart_tx,
    output reg ready
);

	// UART State Machine
	localparam [3:0] IDLE 	= 4'b0000;
	localparam [3:0] START 	= 4'b0001;
	localparam [3:0] BIT0 	= 4'b0010;
	localparam [3:0] BIT1 	= 4'b0011;
	localparam [3:0] BIT2 	= 4'b0100;
	localparam [3:0] BIT3 	= 4'b0101;
	localparam [3:0] BIT4 	= 4'b0110;
	localparam [3:0] BIT5 	= 4'b0111;
	localparam [3:0] BIT6 	= 4'b1000;
	localparam [3:0] BIT7 	= 4'b1001;
	localparam [3:0] STOP 	= 4'b1010;

	reg [3:0] state = 0;
	reg [3:0] next_state = 0;

	// Drive state machine
	always @(*) begin
		state <= next_state;
	end

	// Mode state machine
	always @(posedge clk) begin
		case (state)
			IDLE : begin
			ready <= 1'b1;
			uart_tx <= 1'b1;
				// Wait until told to transmit
				if (send) begin
					next_state <= START;
					clk_rst <= 1'b0;
				end
				
			end

			START : begin
				// Send start bit
				uart_tx <= 1'b0;
				ready <= 1'b0;
				if (next_bit)
					next_state <= BIT0;
			end

			BIT0 : begin
				// Send bits
				uart_tx <= data[0];
				if (next_bit) begin
					next_state <= BIT1;
				end
			end

			BIT1 : begin
				uart_tx <= data[1];
				if (next_bit) begin
					next_state <= BIT2;
				end
			end

			BIT2 : begin
				uart_tx <= data[2];
				if (next_bit) begin
					next_state <= BIT3;
				end
			end

			BIT3 : begin
				uart_tx <= data[3];
				if (next_bit) begin
					next_state <= BIT4;
				end
			end

			BIT4 : begin
				uart_tx <= data[4];
				if (next_bit) begin
					next_state <= BIT5;
				end
			end

			BIT5 : begin
				uart_tx <= data[5];
				if (next_bit) begin
					next_state <= BIT6;
				end
			end

			BIT6 : begin
				uart_tx <= data[6];
				if (next_bit) begin
					next_state <= BIT7;
				end
			end

			BIT7 : begin
				uart_tx <= data[7];
				if (next_bit) begin
					next_state <= STOP;
				end
			end

			STOP : begin
				uart_tx <= 1'b1;
				if (next_bit) begin
					next_state <= IDLE;
					clk_rst <= 1'b1;
					ready <= 1'b1;
				end
			end

			default: next_state <= IDLE;
		endcase
	end
	
	wire next_bit;
	reg clk_rst = 1;
	clkDivHz #(
			.FREQUENCY(9600)
		) inst_clockDividerHz (
			.clk        	(clk),
			.rst        	(clk_rst),
			.enable     	(1'b1),
			.dividedClk 	(),
			.dividedPulse	(next_bit)
		);


endmodule

`endif