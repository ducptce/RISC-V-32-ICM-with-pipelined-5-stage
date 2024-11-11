module tb_RV32IC();
  reg clk, n_rst;
  
  RV32IC rv32ic1 (.clk(clk),
                  .n_rst(n_rst)
                  );
  
  task automatic test_load_byte(
  // Task ?? th?c hi?n các b??c kh?i t?o và ki?m tra các tr??ng h?p lb x1, offset(x2)
  input int offset,        // Offset ?? load byte
  input int mem_value,     // Giá tr? trong b? nh?
  input int expected_value // Giá tr? mong ??i t? thanh ghi ?ích
  );
  begin
    // Reset logic
    #2;
    n_rst <= 1'b0;
    #2;
    n_rst <= 1'b1;

    // Setup initial register and memory values
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;  // rs2 = 4
    rv32ic1.MEM1.DMEM.memory[1] <= mem_value;        // Memory content

    // Set instruction: lb x1, offset(x2)
    rv32ic1.IF1.memory[0] <= 16'b0000000010000011;   // lb opcode
    rv32ic1.IF1.memory[1] <= {7'b0000000, offset[4:0], 4'b0001}; // offset và 4 bit cao c?a rs1 (x2)

    #10;
    
    $display("Testcase %0d: sll x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);

    // Check result
    if (rv32ic1.ID1.RegFile1.memory[1] == expected_value) begin
      $display("Pass");
    end else begin
      $display("Fail: Expected %h, got %h", expected_value, rv32ic1.ID1.RegFile1.memory[1]);
    end
  end
endtask
  
  task automatic test_slt(
  input int rs1_value,
  input int rs2_value,
  input int expected_value
  );
  begin
    // Reset logic
    #2
    n_rst <= 1'b0;
    #2;
    n_rst <= 1'b1;

   // Setup initial register and memory values
    rv32ic1.ID1.RegFile1.memory[2] <= rs1_value;  // rs1 = x2
    rv32ic1.ID1.RegFile1.memory[3] <= rs2_value;  // rs2 = x3

    // Set SLT instruction: slt x10, x2, x3 (x10 = rd, x2 = rs1, x3 = rs2)
    rv32ic1.IF1.memory[0] <= {1'b0, 3'b010, 5'b01010, 7'b0110011};   // 1bit rs1, f3, rd, op
    rv32ic1.IF1.memory[1] <= {7'b0000000, 5'b00011, 4'b0001}; // f7, rs2, 4 bit rs1,
    
    #10;
    
    $display("Testcase %0d: slt x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);

    // Check result
    if (rv32ic1.ID1.RegFile1.memory[10] == expected_value) begin
      $display("Pass");
    end else begin
      $display("Fail: Expected %h, got %h", expected_value, rv32ic1.ID1.RegFile1.memory[10]);
    end
  end
endtask

 task automatic test_sltu(
  input int rs1_value,
  input int rs2_value,
  input int expected_value
  );
  begin
    // Reset logic
    #2
    n_rst <= 1'b0;
    #2;
    n_rst <= 1'b1;

   // Setup initial register and memory values
    rv32ic1.ID1.RegFile1.memory[2] <= rs1_value;  // rs1 = x2
    rv32ic1.ID1.RegFile1.memory[3] <= rs2_value;  // rs2 = x3

    // Set SLT instruction: slt x10, x2, x3 (x10 = rd, x2 = rs1, x3 = rs2)
    rv32ic1.IF1.memory[0] <= {1'b0, 3'b011, 5'b01010, 7'b0110011};   // 1bit rs1, f3, rd, op
    rv32ic1.IF1.memory[1] <= {7'b0000000, 5'b00011, 4'b0001}; // f7, rs2, 4 bit rs1,
    
    #10;
    
    $display("Testcase %0d: sltu x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);

    // Check result
    if (rv32ic1.ID1.RegFile1.memory[10] == expected_value) begin
      $display("Pass");
    end else begin
      $display("Fail: Expected %h, got %h", expected_value, rv32ic1.ID1.RegFile1.memory[10]);
    end
  end
endtask
  
  task automatic test_sb(
  input int offset,    // Offset ?? store byte
  input int  reg_value,  // Giá tr? thanh ghi
  input int expected_value // Giá tr? mong ??i trong mem
  );
  begin
    // Reset logic
    #2;
    n_rst <= 1'b0;
    #2;
    n_rst <= 1'b1;

    // Setup initial register and memory values
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;  // rs2 = 4
    rv32ic1.ID1.RegFile1.memory[1] <= reg_value;

    // Set instruction: lb x1, offset(x2)
    rv32ic1.IF1.memory[0] <= {1'b0, 3'b000, offset[4:0], 7'b0100011};   // 1 bit rs1, f3, offset, sb opcode
    rv32ic1.IF1.memory[1] <= {7'b0000000, 5'b00001, 4'b0010}; // [11:5] imme, rs2(x1) và 4 bit cao c?a rs1 (x2)

    #10;
    
    $display("Testcase %0d: sll x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("DMEM[%0d] = %d", 1, rv32ic1.MEM1.DMEM.memory[1]);

    // Check result
    if (rv32ic1.MEM1.DMEM.memory[1] == expected_value) begin
      $display("Pass");
    end else begin
      $display("Fail: Expected %h, got %h", expected_value, rv32ic1.MEM1.DMEM.memory[1]);
    end
  end
endtask
    
  always#1 clk <= ~clk;
  initial begin
    clk <= 1'b0;
    
    /*
  // Argument LB Test: offset, Datamem_init, Expect Value

	 //lb x1, 0(x2)
	  test_load_byte(0, 32'hFAB56C87, 32'hFFFFFF87);
    
    //lb x1, 1(x2)
	  test_load_byte(1, 32'hFAB56C87, 32'h0000006C);
	  
	  //lb x1, 2(x2)
	  test_load_byte(2, 32'hFAB56C87, 32'hFFFFFFB5);

    // Testcase 4: lb x1, 3(x2)
    test_load_byte(3, 32'hFAB56C87, 32'hFFFFFFFA);
     
    // Testcase 5: lb x1, 0(x2) MSB = 0
    test_load_byte(0, 32'hFAB56C57, 32'h00000057);
    //take a byte of M[rs1+imme] with MSB = 0

// Testcase 6: lb x1, 0(x2) MSB = 0
    //take a byte of M[rs1+imme] with MSB = 1
    test_load_byte(0, 32'hFAB56C87, 32'hFFFFFF87);
    */
    
    // check xong
    /*
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lh x1, 0(x2)
    rv32ic1.IF1.memory[0] <= 16'b0001000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00006C87) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lh x1, 2(x2)
    rv32ic1.IF1.memory[0] <= 16'b0001000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'hFFFFFAB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'h1AB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lh x1, 2(x2) take a half word of M[rs1+imme] with MSB = 0
    rv32ic1.IF1.memory[0] <= 16'b0001000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00001AB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lh x1, 2(x2) take a half word of M[rs1+imme] with MSB = 1
    rv32ic1.IF1.memory[0] <= 16'b0001000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'hFFFFFAB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lw x1, 2(x2)
    rv32ic1.IF1.memory[0] <= 16'b0010000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'hFAB56C87) begin
      $display("Pass");
    end
    
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 0(x2)
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00000087) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 1(x2)
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h0000006C) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 2(x2)
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h000000B5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 3(x2)
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10$display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h000000FA) begin
      $display("Pass");
    end
    */
    /*
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C17;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 0(x2) take a byte of M[rs1+imme] with MSB = 0
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00000017) begin
      $display("Pass");
    end#2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C17;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 0(x2) take a byte of M[rs1+imme] with MSB = 0
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00000017) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lbu x1, 0(x2) take a byte of M[rs1+imme] with MSB = 0
    rv32ic1.IF1.memory[0] <= 16'b0100000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'hFFFFFF87) begin
      $display("Pass");
    end
    */
    /*
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lhu x1, 0(x2)
    rv32ic1.IF1.memory[0] <= 16'b0101000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00006C87) begin
      $display("Pass");
    end
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lhu x1, 2(x2)
    rv32ic1.IF1.memory[0] <= 16'b0101000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h0000FAB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'h1AB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lhu x1, 2(x2)  take a half word of M[rs1+imme] with MSB = 0
    rv32ic1.IF1.memory[0] <= 16'b0101000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'h00001AB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //lhu x1, 2(x2)  take a half word of M[rs1+imme] with MSB = 1
    rv32ic1.IF1.memory[0] <= 16'b0101000010000011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[1]);
    if (rv32ic1.ID1.RegFile1.memory[1] == 32'hFFFFFAB5) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //addi x10, x2, 8
    rv32ic1.IF1.memory[0] <= 16'b0000010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000010000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd13) begin
      $display("Pass");
    end
    
    // check xong
    */
    
    
    /// JALR ins chua test
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'd40;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //jalr x10, 8(x2)
    rv32ic1.IF1.memory[0] <= 16'b0000010101100111;
    rv32ic1.IF1.memory[1] <= 16'b0000000010000001;
    
    #10
    $display("Testcase %0d: jalr x10, 8(x2) .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    $display("PC = %d", rv32ic1.IF1.w_nPC);
    $display("PC = %d", rv32ic1.IF1.o_PC);
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd4 & rv32ic1.IF1.w_nPC == 32'd48) begin
      $display("Pass");
    end
    
    /// JALR chua test dung
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //andi x10, x2, 2
    rv32ic1.IF1.memory[0] <= 16'b0111010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //ori x10, x2, 16
    rv32ic1.IF1.memory[0] <= 16'b0110010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000100000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd21) begin
      $display("Pass");
    end
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slli x10, x2, 2
    rv32ic1.IF1.memory[0] <= 16'b0001010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d: slli x10, x2, 2 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    $display("PC = %d", rv32ic1.IF1.w_nPC);
    $display("PC = %d", rv32ic1.IF1.o_PC);
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd20) begin
      $display("Pass");
    end
    
    /*
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, 24
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000110000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, 2
    rv32ic1.IF1.memory[0] <= 16'b0001010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, 5
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, -2
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111111100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, -20
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111011000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, -7     (-) rs1 = (-) imme
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111110010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000002;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, -7     rs1 > 0   imme < 0
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111110010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF0;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //slti x10, x2, 7
    rv32ic1.IF1.memory[0] <= 16'b0010010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    */
    /*
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'd5;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, 24
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000110000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'd5;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, 2
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'd5;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, 5
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, -2
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111111100001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, -20
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111011000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF9;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, -7     (-) rs1 = (-) imme
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111110010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
     #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000002;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, -7     rs1 > 0   imme < 0
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b1111111110010001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    */
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF0;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //sltiu x10, x2, 7
    rv32ic1.IF1.memory[0] <= 16'b0011010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd0) begin
      $display("Pass");
    end
    
    
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'd8;
    
    //srai x10, x2, 3
    rv32ic1.IF1.memory[0] <= 16'b0101010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd1) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF8;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //srai x10, x2, 3    rs1 < 0
    rv32ic1.IF1.memory[0] <= 16'b0101010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'hFFFFFFFF) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000010;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //srli x10, x2, 4  >0
    rv32ic1.IF1.memory[0] <= 16'b0101010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'h00000001) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF0;
    rv32ic1.MEM1.DMEM.memory[1] <= 32'hFAB56C87;
    rv32ic1.MEM1.DMEM.memory[3] <= 32'h50DDDD08;
    
    //srli x10, x2, 4  rs1 < 0
    rv32ic1.IF1.memory[0] <= 16'b0101010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000001000001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'h0FFFFFFF) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000003;

    
    //xori x10, x2, 3
    rv32ic1.IF1.memory[0] <= 16'b0100010100010011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000006) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000003;
    
    //add x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0000010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000008) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000003;
    
    //and x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0111010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d: and x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000001) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000003;
    
    //or x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0110010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d: or x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000007) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000005;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000003;
    
    //sll x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0001010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d: sll x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000040) begin
      $display("Pass");
    end
    
    
    
    //Argument slt test: value x2, value x3, expect value
    //slt x10, x2, x3
    
    //(+) rs1 < (+) rs2
    test_slt(5,10,1);
    //(+) rs1 > (+) rs2
    test_slt(10,5,0);
    //(+) rs1 = (+) rs2
    test_slt(5,5,0);
    //(-) rs1 < (-) rs2
    test_slt(-10,-5,1);
    //(-) rs1 > (-) rs2
    test_slt(-5,-10,0);
    //(-) rs1 = (-) rs2
    test_slt(-5,-5,0);
    //"rs1 > 0    rs2 < 0    rs1 < rs2 unsigned"
    test_slt(10,-5,0);
    //"rs1 < 0    rs2 > 0    rs1 > rs2 unsigned"
    test_slt(-10,5,1);
    
    
    //Argument sltu test: value x2, value x3, expect value
    //slt x10, x2, x3
    
    //(+) rs1 < (+) rs2
    test_sltu(5,10,1);
    //(+) rs1 > (+) rs2
    test_sltu(10,5,0);
    //(+) rs1 = (+) rs2
    test_sltu(5,5,0);
    //(-) rs1 < (-) rs2
    test_sltu(-10,-5,1);
    //(-) rs1 > (-) rs2
    test_sltu(-5,-10,0);
    //(-) rs1 = (-) rs2
    test_sltu(-5,-5,0);
    //"rs1 > 0    rs2 < 0   
    test_sltu(10,-5,1);
    //"rs1 < 0    rs2 > 0    
    test_sltu(-10,5,0);
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000004;
    
    //sra x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0101010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d: sra x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000000) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF4;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000004;
    
    //sra x10, x2, x3   rs1 < 0   random rs2
    rv32ic1.IF1.memory[0] <= 16'b0101010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d: sra x10, x2, x3 rs1 < 0.........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'hFFFFFFFF) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h00000004;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000004;
    
    //srl x10, x2, x3 rs1 > 0
    rv32ic1.IF1.memory[0] <= 16'b0101010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d: srl x10, x2, x3 rs1 > 0 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000000) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h0000000A;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000005;
    
    //sub x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0000010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d: sub x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000005) begin
      $display("Pass");
    end#2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h0000000A;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000005;
    
    //sub x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0000010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d: sub x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd00000005) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'h0000000A;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000005;
    
    //xor x10, x2, x3
    rv32ic1.IF1.memory[0] <= 16'b0000010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0100000000110001;
    
    #10
    $display("Testcase %0d: xor x10, x2, x3 .........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'd15) begin
      $display("Pass");
    end
    
    #2
    n_rst <= 1'b0;
    #2
    n_rst <= 1'b1;
    
    
    rv32ic1.ID1.RegFile1.memory[2] <= 32'hFFFFFFF4;
    rv32ic1.ID1.RegFile1.memory[3] <= 32'h00000004;
    
    //srl x10, x2, x3   rs1 < 0   random rs2
    rv32ic1.IF1.memory[0] <= 16'b0101010100110011;
    rv32ic1.IF1.memory[1] <= 16'b0000000000110001;
    
    #10
    $display("Testcase %0d: srl x10, x2, x3 rs1 < 0.........", $time/14);
    $display("Time = %0t ns: Testbench running...", $time); 
    $display("rd = %d", rv32ic1.ID1.RegFile1.memory[10]);
    
    if (rv32ic1.ID1.RegFile1.memory[10] == 32'h0FFFFFFF) begin
      $display("Pass");
    end
    
    //Argument sltu test: value x1, offset, expect value
    //sb x1, 0(x2) 
    test_sb(0,32'hFAB56C87,32'h00000087);
    //sb x1, 1(x2) 
    test_sb(1,32'hFAB56C87,32'h0000006C);
    //sb x1, 2(x2) 
    test_sb(2,32'hFAB56C87,32'h000000B5);
    //sb x1, 3(x2) 
    test_sb(3,32'hFAB56C87,32'h000000FA);
    
    
  end
endmodule
