module test();
  reg clk, n_rst;
  wire [31:0] o_WB_DataOut;
  RV32ICM rv32ic1 (.clk(clk),
                  .n_rst(n_rst),
                  .o_WB_DataOut(o_WB_DataOut)
                  );

  integer PC;
  integer data_file, output_file_reg, output_file_mem, i, test_case_num, num_lines;
  reg [31:0] instruction;
  reg [15:0] inst_msb, inst_lsb;
  string file_name;
  string input_file_name;

  // Clock generation
  initial begin
    clk = 0;
    forever #1 clk = ~clk; // 1ps clock period
  end

  initial begin
    #2
    n_rst = 0;
    #4 
    n_rst = 1;

    for (test_case_num = 0; test_case_num < 4000; test_case_num = test_case_num + 1) begin
		
		#2
		n_rst = 0;
		#4 
		n_rst = 1;
		
		PC = 0;

      // Tạo file_name cho file input và lưu vào biến input_file_name
      $sformat(file_name, "D:/rtgtest/Bincode/output1/out_%0d.S.bin", test_case_num);
      input_file_name = file_name; // Lưu lại tên file đầu vào
      data_file = $fopen(input_file_name, "r");

      if (data_file == 0) begin
        $display("File not found: %s. Skipping to next test case.", input_file_name);
        continue; 
      end

      $display("Successfully opened file: %s", input_file_name);
		
      $sformat(file_name, "D:/rtgtest/result/output1/out_%0d.S_Register.txt", test_case_num);
      output_file_reg = $fopen(file_name, "w");
      if (output_file_reg == 0) begin
        $display("Failed to open output file for testcase %0d.", test_case_num);
        $finish;
      end
		
      $sformat(file_name, "D:/rtgtest/result/output1/out_%0d.S_Datamem.txt", test_case_num);
      output_file_mem = $fopen(file_name, "w");
      if (output_file_mem == 0) begin
        $display("Failed to open output file for testcase %0d.", test_case_num);
        $finish;
      end
		
      // Đếm số dòng trong file input
      num_lines = 0;
      while ($fscanf(data_file, "%b\n", instruction) == 1) begin
          num_lines = num_lines + 1;
      end
      $fclose(data_file); // Đóng file sau khi đếm xong số dòng
      
      // Mở lại file input để đọc dữ liệu
      data_file = $fopen(input_file_name, "r");

      i = 0;
		
      while (i < 200) begin  //PC < (num_lines * 4)
          if ($fscanf(data_file, "%b\n", instruction) == 1) begin
              inst_msb = instruction[31:16];
              inst_lsb = instruction[15:0];

              rv32ic1.IF1.memory[2*i + 1] = inst_msb;
              rv32ic1.IF1.memory[2*i] = inst_lsb;

              #2;
          end else begin
              inst_msb = 16'b0000000000000000;
              inst_lsb = 16'b0000000000000000;

              rv32ic1.IF1.memory[2*i + 1] = inst_msb;
              rv32ic1.IF1.memory[2*i] = inst_lsb;
              #2;
          end

          i = i + 1;
          PC = rv32ic1.IF1.o_PC;
      end
      
      $fclose(data_file); 

      #200; 
		
      // Ghi Register File contents
      for (i = 0; i < 32; i = i + 1) begin
          $fwrite(output_file_reg, "%b\n", rv32ic1.ID1.RegFile1.memory[i]);
      end
		
      // Ghi DMEM contents
      for (i = 0; i < 2**17; i = i + 1) begin
          $fwrite(output_file_mem, "%b\n", rv32ic1.MEM1.DMEM.memory[i]);
      end

      $fclose(output_file_reg);
      $fclose(output_file_mem);
      #50;  
		
    end

    $stop;
end
endmodule
