
module sync_fifotb;
parameter DEPTH=16, WIDTH=8, PTR_WIDTH=4;
reg clk_i,rst_i,wr_en_i,rd_en_i;
reg [WIDTH-1 : 0] wdata_i;
wire [WIDTH-1 : 0] rdata_o;
wire full_o, empty_o, wr_error_o, rd_error_o;
integer i;

sync_fifo dut (
      clk_i, rst_i, wdata_i, full_o, wr_en_i, wr_error_o,
      rdata_o, empty_o, rd_en_i, rd_error_o
);

//clock generation
initial begin
clk_i = 0;
$dumpfile ("fifoh.vcd");
$dumpvars (0,sync_fifotb); 
$monitor ($time,"rst_i = %b , wr_en_i= %b , rd_en_i = %b,wdata_i = %b,rdata_o = %b ,full_o = %b, empty_o = %b, wr_error_o = %b, rd_error_o = %b ",rst_i,wr_en_i,rd_en_i,wdata_i,rdata_o,full_o, empty_o, wr_error_o, rd_error_o) ;
forever #5 clk_i = ~clk_i;
//don't code anything after forever in any language
end

//reset apply, release
initial begin
rst_i = 1;   //apply
@(posedge clk_i);  //holding
rst_i = 0;  //releasing
//now design in a state where we can apply the inputs 
//apply stimulus write to the FIFO and read from the FIFO
for (i=0; i< DEPTH; i=i+1) begin
@(posedge clk_i);
wr_en_i = 1;
wdata_i = $random;
end
@(posedge clk_i);
wr_en_i = 0;
wdata_i = 0;
//read from FIFO
for (i=0; i< DEPTH; i=i+1) begin
@(posedge clk_i);
rd_en_i = 1;
end
@(posedge clk_i);
rd_en_i = 0;
$finish;
end
endmodule