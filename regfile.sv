// Typedef to make things easier
typedef logic [31:0] word_t;
typedef logic [4:0] addr_t;

// 32-bit RISC-V register file
module regfile
  (	// Logic is an SV 4-state type that can be a reg or wire
    input  logic  clk,
    input  addr_t rs1_addr,
    input  addr_t rs2_addr,
    output word_t rs1_data,
    output word_t rs2_data,
    input  logic  w_en,
    input  addr_t w_addr,
    input  word_t w_data
);
  
  // Define a 2-d array of size 32x31
  word_t regs [1:2**$bits(addr_t)-1];

  // Registers update synchronous to posedge of clock 
  always @(posedge clk) begin
    
    // Note: writes to (non-existent) R0 are not possible
    if (w_en && w_addr != '0)
      regs[w_addr] <= w_data;
    
    // Update output read ports
    rs1_data <= rs1_addr == '0 ? '0 : regs[rs1_addr];
    rs2_data <= rs2_addr == '0 ? '0 : regs[rs2_addr];
    
  end
endmodule