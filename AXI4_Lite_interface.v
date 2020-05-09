
//////////////////////////////////////////////////////////////////////////////////

 
// NameOF MAIN BLOCK: AXI4_LITE INTERFACE 
// INSTRUCTION MODULE 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 10ps
module AXI4_Lite_interface 
  #(parameter data_width = 32,
              //**STATES OF FSM** //
    parameter IDLE = 4'd0,    
             // **READ** //
	parameter instr_Rd_Addr_channel = 4'd1,
	parameter instr_Rd_Data_channel = 4'd2,
	parameter Data_Rd_Addr_channel = 4'd3,
	parameter Data_Rd_Data_channel = 4'd4,
			 // **WRITE** //
	parameter Wr_Addr_channel = 4'd5,      
	parameter Wr_Data_channel =4'd6,
	parameter Wr_response_channel = 4'd7)
  
  
  
(  	    input clk,input reset,
//***************INSTRUCTION REQ***************//
		input instr_req_o,            //INSTRUCTION REQUEST >>STILL 1 UNTIL 'data_gnt_i' IS HIGH 
//************************DATA REQ************//
		input  data_req_o,    //DATA REQUEST
		input  data_we_o,    //WRRITE ENABLE 
//**********************************************//
                    //****IP SIDE*****//
		input [31:0] Addr,                           //ADD FROM IP   
		input  [data_width-1 : 0] Write_Data,        // IP 2 AXI


//************INSTRUCTION REQ***************//
		output reg instr_rvalid_i,   //CHECK IF INSTRUCTION VALID ?        
		output reg instr_gnt_i,  // CHECK IF REQUEST IS ACCEPTED OR NOT?

//*************DATA REQ*****************//
		
		output reg data_rvalid_i, //CHECK IF DATA VALID?
		output reg data_gnt_i,    // CHECK IF REQUEST IS ACCEPTED OR NOT?

//**********************************************//
                    //****IP SIDE*****//
		output  reg [data_width-1 : 0] Read_Data ,    //AXI 2 IP


//*********************** AXI_lite INTERFACE******************************** //
//*********************(Master Block)************************//
		//- ******************WRITE ADDRESS ********************
          input AWready,                            //FROM SLAVE 2 INTERFACE 
		  output   reg AWvalid,                     //CHECK IF ADDRESS VALID?
		  output   reg [31:0] AWaddr,			    //  WRITE ADDRESS
	
 
             
        //- ******************WRITE DATA  ********************
  
		  input Wready,                              //FROM SLAVE 2 INTERFACE 
		  output  reg Wvalid,                        //CHECK IF DATA VALID TO WRITE?
		  output  reg [data_width-1 : 0] Wdata,      //WRITE DATA 
		  output   reg [data_width/8 -1 : 0] Wstrb,  //DATA STROB SIGNAL (Default = 1)
 
       //- ****************** RESPONSE  ********************

			input Bvalid,                           //BYTE RESPONSE VALID? (HandShake)
			input [1:0] Bresp,                      //BYTE WRITE READY
			output   reg Bready,                    // BYTE SLAVE 2 INTERFACE
 
		//- ******************READ ADDRS  ********************
			input    ARready,                      //FROM SLAVE 2 INTERFACE 
			output   reg ARvalid,                  // CHECK IF VALID ADDRESS?(Handshake)
			output   reg [31:0] ARaddr,

		//- ******************READ DATA TASK ********************
			input    Rvalid,                          //CHECK IF VALID DATA? (Handshake)
			input    [data_width-1 : 0]Rdata,         //READ DATA 
			input    [1:0] Rresp,                     //RESPONSE 
			output   reg Rready                       //FROM SLAVE 2 INTERFACE 
    );
	
	
	
	
	reg [3:0] STATE;
	reg [3:0] NextState; 
 //********************************FSM**************************************// 
    always@ (posedge clk)
     begin 
       if (~reset)  
	     begin 
	     STATE <= IDLE; 
	   
	     end   
       else 
	     STATE <= NextState;    
     end
 
    always@ (STATE,AWready,Wready,Bvalid,Bresp,ARready,Rvalid,Rdata,Rresp,Addr,Write_Data,instr_req_o,data_req_o,data_we_o) 
       begin
           case (STATE)
		      //-***** IDLE STATE*******//
          IDLE:  
		   begin               
				  ARaddr = 0;
    			  ARvalid = 0;
     			  Rready = 0;
     			  Read_Data = 0;   
      			  instr_gnt_i = 1'b0;
       			  instr_rvalid_i = 1'b0;     
                  Wstrb <= 4'h0;
       			data_gnt_i = 1'b0;
       			data_rvalid_i = 1'b0;
       			Wvalid = 0;
       			AWaddr = 0;             
       			Wdata = 0;
       			AWvalid = 0;
       			Bready = 0;
      
      			if (instr_req_o)  //READ REQUEST
	  			 begin 
	 			  NextState = instr_Rd_Addr_channel;  
				  ARaddr = Addr; 
				  end  
     			else if (data_req_o) //WRITE REQUEST
				 begin
                  if(data_we_o) //DATA WRITE ENABLE >>1
				    begin
					 NextState = Wr_Addr_channel; 
					 Wdata = Write_Data;
					 AWaddr = Addr; 
					end 
                  else     // ENABLE >>0 
				    begin 
				        NextState = Data_Rd_Addr_channel;  
						ARaddr = Addr;
					end
                 end         
      		    else      NextState = IDLE;          // NO REQUEST          
          end
		  
		  
		  
		  
//*********************WRITE ADDRESS *******//	  
		  
     Wr_Addr_channel :
	    begin              
			ARaddr = 0;
			ARvalid = 0;
			Rready = 1'b0;             
			Read_Data = 0; 
			instr_gnt_i = 1'b0;
			instr_rvalid_i = 1'b0;     
     
		 data_rvalid_i = 1'b0;
         data_gnt_i = 1'b1;  // instr_req_o >>IS 0   
         Wvalid = 1;
         AWvalid = 1;
         AWaddr = Addr;
         Wdata = Write_Data;
         Bready = 1;                            
         if ( AWready)  //SLAVE IS READY 
		    NextState =  Wr_Data_channel;  
         else 
			NextState  = Wr_Addr_channel;                                         
       end 
//*************************WRITE DATA *******//	  	   
     Wr_Data_channel : 
	   begin         
         ARaddr = 0;
         ARvalid = 0;
         Rready = 1'b0;
         Read_Data = 0; 
         instr_gnt_i = 1'b0;
         instr_rvalid_i = 1'b0;   //NO NEED FOR INSTRUCTION  
       
         data_rvalid_i = 1'b0;
         data_gnt_i = 1'b0;
         AWaddr = Addr;
         AWvalid = 1'b0;
         Wvalid = 1'b1;    // WRITE FROM SLAVE 
         Bready = 1;      //BYTE READY TO WRITE 
         if (Wready)   //FINISH SENDING 
		   begin              
            Wdata = Write_Data;
            NextState =  Wr_response_channel;
            end
         else   
            begin 
               Wdata = 0;
              NextState  = Wr_Data_channel;   // STILL SENDING 
            end   
       end
//*************************WRITE RESPONSE *******//	  	                
   Wr_response_channel  :
	 begin   
            AWaddr = Addr;
            AWvalid = 1'b0;
            Wvalid = 1'b0;            
            Wdata = 0;
            Bready = 1;
            instr_gnt_i = 1'b0;
            instr_rvalid_i = 1'b0;     
            
            data_rvalid_i = 1'b0;       
            data_gnt_i = 1'b0;
            ARaddr = 0;
            ARvalid = 0;
            Rready = 1'b1; 
            Read_Data = 0; 
          
         if (Bvalid && (Bresp == 2'b00)) //TRANSECTION DONE *.*?
			 begin      
                Rready = 1'b0;
                NextState =  IDLE;
             end
         else  
			NextState  = Wr_Addr_channel;
                                       
     end 
//****************** INSTRUCTION READ ADDRESS***************//
    instr_Rd_Addr_channel:
	  begin        
        Wvalid = 0;
        AWvalid = 0;              
        AWaddr = 0;             
        Wdata = 0;
        Bready = 0;
        data_gnt_i = 1'b0; 
        data_rvalid_i = 1'b0;
        //REQUEST NOT NEEDED 
        instr_gnt_i = 1'b1;
        instr_rvalid_i = 1'b0;
        ARaddr = Addr;
        ARvalid = 1'b1;  
        Rready = 1'b1; 
        Read_Data = 0;     
                         
        if (ARready) // SLAVE IS READY WITH ADDRESS
		    NextState =  instr_Rd_Data_channel;   
		
        else   
		   NextState  = instr_Rd_Addr_channel;       
      end 
//****************** INSTRUCTION READ DATA ***************//
                         
    instr_Rd_Data_channel: 
	  begin    
        Wvalid = 0;
        AWvalid = 0;
        AWaddr = 0;             
        Wdata = 0;
        Bready = 0;
        data_gnt_i = 1'b0;
        data_rvalid_i = 1'b0;
        
        instr_gnt_i = 1'b0;
        ARaddr = Addr;
        ARvalid = 1'b0;
        Rready = 1'b1;
                 
        if (Rvalid  && (Rresp == 2'b00))   //TRANSECTION DONE *.*?
		 begin    
			Read_Data = Rdata;
			NextState =  IDLE;
			instr_rvalid_i = 1'b1;
         end
        else   
           begin                         
			Read_Data = 0; 
			instr_rvalid_i = 1'b0;
			NextState  = instr_Rd_Data_channel;   
           end        
      end 
	  
//****************** DATA READ ADDRESS ***************//
	  
     Data_Rd_Addr_channel:
	 begin        
			Wvalid = 0;
			AWvalid = 0;              
			AWaddr = 0;             
			Wdata = 0;
			Bready = 0;
			data_gnt_i = 1'b1;   // instr_req_o >>IS 0   
			data_rvalid_i = 1'b0;
       
			ARaddr = Addr;  
			ARvalid = 1'b1;  //HandShake
			Rready = 1'b1;   //OUTPUT 
			Read_Data = 0;     
                         
			if (ARready)   // SLAVE IS READY WITH ADDRESS
				NextState=  Data_Rd_Data_channel;   
			else   NextState= Data_Rd_Addr_channel;  //STAY     
       end 
 //****************** DATA READ DATA ***************//
    Data_Rd_Data_channel: 
		begin    
			Wvalid = 0;
			AWvalid = 0;
			AWaddr = 0;             
			Wdata = 0;
			Bready = 0;
			data_gnt_i = 1'b0; 
      
			ARaddr = Addr;
			ARvalid = 1'b0;
			Rready = 1'b1; //OUTPUT
                       
			if (Rvalid && (Rresp == 2'b00)) //TRANSECTION DONE *.*?
				begin     
					Read_Data= Rdata;
					NextState=  IDLE;
					data_rvalid_i= 1'b1;
				end
			else   
				begin                         
					Read_Data= 0; 
					data_rvalid_i= 1'b0;
					NextState= Data_Rd_Data_channel;   
				end        
       end 
    
  endcase
 end
   
endmodule
/* NEW VERISION SARA MAGDI */