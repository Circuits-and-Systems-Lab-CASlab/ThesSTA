module mini_top (in, clk, out);
  input in;
  input clk;
  output out;
  wire n1;

  INV1 u1 (.A(in), .Y(n1));
  BUF1 u2 (.A(n1), .Y(out));
endmodule
