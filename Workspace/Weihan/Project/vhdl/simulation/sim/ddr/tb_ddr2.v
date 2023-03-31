`timescale 1ns/1ns

module tb_ddr2;

   reg clock;
   reg reset;
   wire	led;

   wire [12:0] ddr2_addr;
   wire [2:0]  ddr2_ba;
   wire	       ddr2_cas_n;
   wire [0:0]  ddr2_ck_n;
   wire [0:0]  ddr2_ck_p;
   wire [0:0]  ddr2_cke;
   wire	       ddr2_ras_n;
   wire	       ddr2_we_n;
   wire [15:0] ddr2_dq;
   wire [1:0]  ddr2_dqs_n;
   wire [1:0]  ddr2_dqs_p;
   wire [0:0]  ddr2_cs_n;
   wire [1:0]  ddr2_dm;
   wire [0:0]  ddr2_odt;

   initial begin
      clock = 1'b0;
      reset = 1'b0;
      // Reset for 1us
      #100 
	reset = 1'b1;
      #1000
	reset = 1'b0;
   end

   // Generate 100MHz clock signal
   always #5 clock <= ~clock;


   ddr2 ddr2_top(
		 // Reference Clock Ports
		 .clk                              (clock),
		 .rst                              (reset),
		 .init_calib_complete              (led),
      
		 // Memory interface ports
		 .ddr2_addr                        (ddr2_addr ),
		 .ddr2_ba                          (ddr2_ba   ),
		 .ddr2_cas_n                       (ddr2_cas_n),
		 .ddr2_ck_n                        (ddr2_ck_n ),
		 .ddr2_ck_p                        (ddr2_ck_p ),
		 .ddr2_cke                         (ddr2_cke  ),
		 .ddr2_ras_n                       (ddr2_ras_n),
		 .ddr2_we_n                        (ddr2_we_n ),
		 .ddr2_dq                          (ddr2_dq   ),
		 .ddr2_dqs_n                       (ddr2_dqs_n),
		 .ddr2_dqs_p                       (ddr2_dqs_p),
		 .ddr2_cs_n                        (ddr2_cs_n ),
		 .ddr2_dm                          (ddr2_dm   ),
		 .ddr2_odt                         (ddr2_odt  )
		 );



   ddr2_model  ddr2_model(
			  .ck          (ddr2_ck_p),
			  .ck_n        (ddr2_ck_n),
			  .cke         (ddr2_cke),
			  .cs_n        (ddr2_cs_n),
			  .ras_n       (ddr2_ras_n),
			  .cas_n       (ddr2_cas_n),
			  .we_n        (ddr2_we_n),
			  .dm_rdqs     (ddr2_dm),
			  .ba          (ddr2_ba),
			  .addr        (ddr2_addr),
			  .dq          (ddr2_dq),
			  .dqs         (ddr2_dqs_p),
			  .dqs_n       (ddr2_dqs_n),
			  .rdqs_n      (),
			  .odt         (ddr2_odt)
			  );

endmodule

