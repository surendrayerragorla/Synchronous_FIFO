module sync_fifo (
     // write  interface
     clk_i, rst_i, wdata_i, full_o, wr_en_i, wr_error_o,
     // read interface
     rdata_o, empty_o, rd_en_i, rd_error_o
);
parameter DEPTH=16, WIDTH=8, PTR_WIDTH=4;
//wr_ptr is internal to the design
//declare all inputs and output
input clk_i,rst_i,wr_en_i,rd_en_i;
input [WIDTH-1 : 0] wdata_i;
output reg [WIDTH-1 : 0] rdata_o;
output reg full_o, empty_o, wr_error_o, rd_error_o;

//wr_ptr, rd_ptr, toggle flags(scalar)
reg [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
reg wr_toggle_f, rd_toggle_f; 
//declare the memory
reg [WIDTH-1 : 0] mem [DEPTH-1:0];
integer i;

 /*processes in fifo
  write,read => do they happen on same clock or different clock -> Same clock
 both can be coded in to same always block*/
always @(posedge clk_i) begin
if (rst_i==1) begin
  // all reg variables assign to reset values
   rdata_o = 0;
   full_o = 0;
   empty_o = 1;
   wr_error_o = 0;
   rd_error_o = 0;
   wr_ptr = 0;
   rd_ptr = 0;
   wr_toggle_f = 0;
   rd_toggle_f = 0;
   //mem = 0; //wrong
   for (i=0; i< DEPTH; i=i+1) begin
      mem[i] = 1;
  end
end
else begin //rst_i not applied
//write can happen
if (wr_en_i == 1) begin
if (full_o == 1 ) begin
  wr_error_o = 1;
end
else begin
//store data into memeory
  mem [wr_ptr] = wdata_i;
  wr_error_o = 0;
//increment the wr_ptr
if (wr_ptr == DEPTH-1) wr_toggle_f = ~wr_toggle_f;
  wr_ptr = wr_ptr + 1;  //DEPTH-1 -> DEPTH(16)=>0
        end
    end
//read can happen 
if (rd_en_i == 1 ) begin
   if (empty_o ==1) begin
       rd_error_o = i;
end
else begin
  rdata_o = mem [rd_ptr];
  rd_error_o = 0;
if (rd_ptr == DEPTH-1) rd_toggle_f = ~rd_toggle_f;
//increment the rd_ptr
rd_ptr = rd_ptr+1;
         end
      end
  end
end

//logic for full and empty generation
//sequential logic or combinational logic => Combinational logic
always @(*) begin
  //wr_ptr, rd_ptr, wr_toggle_f, rd_toggle_f
empty_o = 0;
full_o = 0;
if (wr_ptr == rd_ptr) begin
   if (wr_toggle_f == rd_toggle_f) empty_o = 1;
   if (wr_toggle_f != rd_toggle_f) full_o = 1;
   end
end
endmodule