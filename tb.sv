module tb();
  // Registers to drive stimulus
  reg  [31:0] 	w_data_tb;
  reg  [ 4:0] 	w_addr_tb,
  				rs1_addr_tb, 
  				rs2_addr_tb;
  reg 			clk_tb, 
  				w_en_tb;
  // Wires to capture response
  wire [31:0]	rs1_data_tb,
   			    rs2_data_tb;
  
  int error_count;
  
  // Generator and driver in a single task -lacks reusability
  task gen_drive_tv();
    
    // Randomize write data - missing constraints
    begin
      
      // random 32-bit write data
      w_data_tb = $random();
      
      // randomize 5-bit write address
      w_addr_tb = $urandom_range((2**5)-1, 0);
      
      // randomize read addresses
      rs1_addr_tb = $urandom_range((2**5)-1, 0);
      rs2_addr_tb = $urandom_range((2**5)-1, 0);
      
      // randomize write enable
      w_en_tb = $urandom_range(1, 0);
      
      // After this statement the DUT should have updated the output/rf
      @(posedge clk_tb);
      
    end
  endtask
  
  // Scoreboard and checker in a single task - lacks reusability
  task check_tv();
    begin
      
      // Wait some time for the outputs to settle (negedge is often used)
      @(negedge clk_tb);
      
      // Check write
      if(w_en_tb == 1'b1 ) begin
        // Check write to register
        if(w_addr_tb != '0)
          if(rf_inst.regs[w_addr_tb] === w_data_tb)
            $display("@%10t: Write success!", $time());
          else begin
            $display("@%10t: Write error!", $time());
            error_count = error_count + 1;
          end
      end
      
      // Check read output port 1 for registers 1-31
      if(rs1_addr_tb != '0) begin
        if(rs1_data_tb === rf_inst.regs[rs1_addr_tb])
          $display("@%10t: Read success!", $time());
        else begin
          $display("@%10t: Read error!", $time());
          error_count = error_count + 1;
        end
        
      // Check read output port 1 register 0
      end else begin
        if(rs1_data_tb == '0)
          $display("@%10t: Read success!", $time());
        else begin
          $display("@%10t: Read error!", $time());
          error_count = error_count + 1;
        end
      
      // Check read output port 1 for registers 1-31 
      end if(rs2_addr_tb != '0) begin
        if(rs2_data_tb === rf_inst.regs[rs2_addr_tb])
          $display("@%10t: Read success!", $time());
        else begin
          $display("@%10t: Read error!", $time());
          error_count = error_count + 1;
        end
        
      // Check read output port 1 register 0
      end else begin
        if(rs2_data_tb == '0)
          $display("@%10t: Read success!", $time());
        else begin
          $display("@%10t: Read error!", $time());
          error_count = error_count + 1;
        end
      end 
      
      // Things you can add
      //
      //	- Check longer sequences
      //	Ex. add a var to indicate that
      //	there was a write attempted at R0
      //	try to read R0 and verify that it
      //	does not return a non-zero metric
      //
      //	- Add another var to show that the above
      //	test was run and do not check again
      //	to save simulation time
      //
      //	- As you read Ch. 2 try and figure out what the
      //	best var type for the above cover point is
      
    end
  endtask
  
  // make a clock
  always #10 clk_tb = ~clk_tb;
 
  initial begin
    
    // Populate waveforms for EPWave
    //	- Check EPWave box
    //	- in the "Compile Options" add -debug_access+all
    $vcdpluson;
    $vcdplusmemon;
    $dumpfile("dump.vcd"); 
    $dumpvars;
    
  	// Initialize clock
    clk_tb = 1'b1;
    @(posedge clk_tb);
    
    // Generate, drive, score, and check 100 random test vectors
    repeat(100) begin
      gen_drive_tv();
      check_tv();
    end
    
    // End simulation
    $display("Total errors: %d", error_count);
    $finish();
    
  end
  
  // Instance of regfile
  regfile
  	rf_inst(
      .clk(clk_tb), 
      .rs1_addr(rs1_addr_tb),
      .rs2_addr(rs2_addr_tb),
      .rs1_data(rs1_data_tb),
      .rs2_data(rs2_data_tb),
      .w_en(w_en_tb),
      .w_addr(w_addr_tb),
      .w_data(w_data_tb)
    );
endmodule
