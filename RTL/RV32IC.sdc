create_clock -name clk -period 10 [get_ports {clk}]
set_input_delay -clock { clk } 0.5 [get_ports {n_rst}]
set_output_delay -clock { clk } -add_delay 1 [get_ports {o_WB_DataOut[0] o_WB_DataOut[1] o_WB_DataOut[2] o_WB_DataOut[3] o_WB_DataOut[4] o_WB_DataOut[5] o_WB_DataOut[6] o_WB_DataOut[7] o_WB_DataOut[8] o_WB_DataOut[9] o_WB_DataOut[10] o_WB_DataOut[11] o_WB_DataOut[12] o_WB_DataOut[13] o_WB_DataOut[14] o_WB_DataOut[15] o_WB_DataOut[16] o_WB_DataOut[17] o_WB_DataOut[18] o_WB_DataOut[19] o_WB_DataOut[20] o_WB_DataOut[21] o_WB_DataOut[22] o_WB_DataOut[23] o_WB_DataOut[24] o_WB_DataOut[25] o_WB_DataOut[26] o_WB_DataOut[27] o_WB_DataOut[28] o_WB_DataOut[29] o_WB_DataOut[30] o_WB_DataOut[31]}]
