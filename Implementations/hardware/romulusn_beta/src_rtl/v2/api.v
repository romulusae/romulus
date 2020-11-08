module api (/*AUTOARG*/
   // Outputs
   pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, do_last, domain, srst, senc,
   sse, xrst, xenc, xse, yrst, yenc, yse, zrst, zenc, zse, erst,
   decrypt, correct_cnt, constant, constant2, tk1s,
   // Inputs
   counter, pdi_data, pdo, sdi_data, pdi_valid, sdi_valid, pdo_ready, clk, rst
   ) ;
   // SKINNY FINAL CONSTANT
   parameter FINCONST = 7'b011010;

   // BLK COUNTER INITIAL CONSTANT
   parameter INITCTR = 56'h02000000000000;  
parameter INITCTR2 = 56'h01000000000000;    

   // INSTRUCTIONS
   parameter LDKEY = 4;
   parameter ACTKEY = 7;
   parameter ENC = 2;
   parameter DEC = 3;
   parameter SUCCESS = 14;
   parameter FAILURE = 15;

   //SEGMENT HEADERS
   parameter RSRVD1 = 0;
   parameter AD = 1;
   parameter NpubAD = 2; 
   parameter ADNpub = 3; 
   parameter PLAIN = 4; 
   parameter CIPHER = 5; 
   parameter CIPHERTAG = 6; 
   parameter RSRVD = 7; 
   parameter TAG = 8; 
   parameter RSRVD2 = 9; 
   parameter LENGTH = 10;
   parameter RSRVD3 = 11;  
   parameter KEY = 12; 
   parameter Npub = 13; 
   parameter Nsec = 14; 
   parameter ENCNsec = 15;

   // DOMAINS
   parameter adnormal = 8;
   parameter adfinal = 24;
   parameter adpadded = 26;
   parameter msgnormal = 4;
   parameter msgfinal = 20;
   parameter msgpadded = 21;   

   // STATES
   parameter idle        = 0;
   parameter loadkey     = 1;
	parameter keyheader   = 2;   
   parameter storekey    = 3;
   parameter nonceheader = 4;
   parameter storen      = 5;
   parameter adheader    = 6;
   parameter adheader2   = 7;
   parameter msgheader   = 8;
   parameter storeadsf   = 9;
   parameter storeadtf   = 10;
   parameter storeadsp   = 11;
   parameter storeadtp   = 12;
   parameter storemf     = 13;
   parameter storemp     = 14;
   parameter encryptad   = 15;
   parameter encryptn    = 16;
   parameter encryptm    = 17;
   parameter outputtag0  = 18;
   parameter outputtag1  = 19;   
   parameter verifytag0  = 20;
   parameter verifytag1  = 21;
   parameter statuse     = 22;	
	parameter statusdf    = 23;	
	parameter statusds    = 24;	
   
   output reg [31:0] pdo_data, pdi;
   output reg        pdi_ready, sdi_ready, pdo_valid, do_last;

   output reg [7:0]  domain;
   output reg        srst, senc, sse;
   output reg        xrst, xenc, xse;
   output reg        yrst, yenc, yse;
   output reg        zrst, zenc, zse;
   output reg        erst;
   output reg [3:0]  decrypt;
   output reg        correct_cnt;
   output  [5:0]       constant; 
   output  [5:0]       constant2; 	
   output reg        tk1s; 
   
   input [55:0]      counter;   
   input [31:0]      pdi_data, pdo, sdi_data;
   input             pdi_valid, sdi_valid, pdo_ready;

   input             clk, rst;

   reg [4:0]         fsm, fsmn;
   reg [15:0]         seglen, seglenn;  
   reg [3:0]         flags, flagsn;
   reg               dec, decn;
   reg [7:0]         nonce_domain, nonce_domainn;
   reg [5:0]         cnt, cntn;   
   reg               correct_cntn;
   reg               st0, st0n;
   reg               c2, c2n;
   reg               tk1sn;

   assign constant = cnt;
   assign constant2 = {cnt[4:0], cnt[5]^cnt[4]^1'b1};   

   always @ (posedge clk) begin
      if (rst) begin
         fsm <= idle;
         seglen <= 0;
         flags <= 0;
         dec <= 0;
         correct_cnt <= 1;
         cnt <= 6'h01;   
         st0 <= 0;
         c2 <= 0;        
         tk1s <= 1;      
         nonce_domain <= adpadded;       
      end
      else begin
         fsm <= fsmn;
         seglen <= seglenn;
         flags <= flagsn;
         dec <= decn;
         cnt <= cntn;    
         nonce_domain <= nonce_domainn;
         st0 <= st0n;
         c2 <= c2n;
         tk1s <= tk1sn;  
         correct_cnt <= correct_cntn;    
      end
   end
   
   always @ ( counter or constant2 or c2 or cnt or correct_cnt or dec or flags
	     or fsm or nonce_domain or pdi_data or sdi_data or pdi_valid or pdo
	     or pdo_ready or sdi_valid or seglen or st0 or tk1s) begin
      pdo_data <= 0;      
      pdi <= pdi_data;  
      do_last <= 0;    
      domain <= 0;         
      srst   <= 0;
      senc   <= 0;
      sse    <= 0;
      xrst   <= 0;
      xenc   <= 0;
      xse    <= 0;
      yrst   <= 0;
      yenc   <= 0;
      yse    <= 0;
      zrst   <= 0;
      zenc   <= 0;
      zse    <= 0;
      erst   <= 0;
      decrypt <= 0;      
      sdi_ready <= 0;
      pdi_ready <= 0;
      pdo_valid <= 0;
      tk1sn <= tk1s;      
      nonce_domainn <= nonce_domain;      
      fsmn <= fsm;
      seglenn <= seglen; 
      flagsn <= flags;
      decn <= dec;
      correct_cntn <= correct_cnt;
      st0n <= st0;
      c2n <= c2;           
      cntn <= cnt;      
      case (fsm) 
        idle: begin
	   pdi_ready <= 1;
	   srst <= 1;
	   sse <= 1;
	   senc <= 1;	   
           tk1sn <= 1;     
           nonce_domainn <= adpadded;      
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (pdi_data[31:28] == ACTKEY) begin
                 fsmn <= loadkey;              
              end
              else if (pdi_data[31:28] == ENC) begin
                 zenc <= 1;        
                 zrst <= 1;
                 correct_cntn <= 1;           
                 zse <= 1;         
                 fsmn <= adheader;
                 decn <= 0;              
              end
              else if (pdi_data[31:28] == DEC) begin
                 zenc <= 1;        
                 zrst <= 1;
                 correct_cntn <= 1;           
                 zse <= 1;         
                 fsmn <= adheader;
                 decn <= 1;             
              end
           end     
        end // case: idle
	loadkey: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              if (sdi_data[31:28] == LDKEY) begin
                 fsmn <= keyheader;               
              end             
           end
        end
        keyheader: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              if (sdi_data[31:28] == KEY) begin
                 fsmn <= storekey;               
              end             
           end
	   else if (pdi_valid) begin
			     if (pdi_data[31:28] == ENC) begin
                 zenc <= 1;        
                 zrst <= 1;
                 correct_cntn <= 1;           
                 zse <= 1;         
                 fsmn <= adheader;
                 decn <= 0;              
              end
              else if (pdi_data[31:28] == DEC) begin
                 zenc <= 1;        
                 zrst <= 1;
                 correct_cntn <= 1;           
                 zse <= 1;         
                 fsmn <= adheader;
                 decn <= 1;             
              end
			  end
        end
        storekey: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              xrst <= 1;
              xenc <= 1;
              xse <= 1;
              if (cnt == 5'h0F) begin
                 cntn <= 6'h01;
                 fsmn <= idle;           
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
           end
        end // case: storekey
        nonceheader: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (pdi_data[31:28] == Npub) begin
                 fsmn <= storen;             
              end             
           end
        end
        storen: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              yenc <= 1;
              yse <= 1;
              yrst <= 1;              	      
              if (cnt == 5'h0F) begin
		 domain <= nonce_domain;
		 //zenc <= 1;
		 //zse <= 1;
		 //if (counter != INITCTR) begin
		   // xse <= 1;
		   // xenc <= 1;		    
		 //end 		 
                 cntn <= 6'h01;
                 fsmn <= encryptn;               
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
           end
        end // case: storen
        adheader: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (pdi_data[31:28] == AD) begin
                 seglenn <= pdi_data[15:0];
                 flagsn <= pdi_data[27:24];              
                 if ((pdi_data[25] == 1) && (pdi_data[15:0] < 16)) begin
                    fsmn <= storeadsp;
                 end
                 else begin
                    fsmn <= storeadsf;
                 end
              end             
           end
        end // case: adheader
        adheader2: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (pdi_data[31:28] == AD) begin
                 seglenn <= pdi_data[15:0];
                 flagsn <= pdi_data[27:24];              
                 if ((pdi_data[25] == 1) && (pdi_data[15:0] < 16)) begin
                    fsmn <= storeadtp;
                 end
                 else begin
                    fsmn <= storeadtf;
                 end
              end             
           end
        end // case: adheader2  
        storeadsf: begin
           if (pdi_valid) begin
              pdi_ready <= 1;                 
              senc <= 1;
              sse <= 1;
              	if (cnt == 5'h01) begin
				     seglenn <= seglen - 16;
				  end	
              if (cnt == 5'h0F) begin
		 if (counter != INITCTR2) begin
		    xse <= 1;
		    xenc <= 1;		    
		 end 
                 cntn <= 6'h01;
		           zenc <= 1;
		           zse <= 1;
                 if (seglen == 0) begin		 
                 if (flags[1] == 1) begin
                    fsmn <= nonceheader;
		              nonce_domainn <= adfinal;
		              domain <= adfinal;		    
                 end
                 else begin
                    fsmn <= adheader2;
		              domain <= adnormal;		    
                 end
					  end
					  else if (seglen < 16) begin
					    fsmn <= storeadtp;
						 domain <= adnormal;
					  end
					  else begin
					    fsmn <= storeadtf;
						 domain <= adnormal;
					  end
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end



           end     
        end     
        storeadsp: begin
           case (cnt) 
             6'h01: begin
                if (seglen > 0) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      senc <= 1;
                      sse <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   senc <= 1;
                   sse <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h03: begin
                if (seglen > 4) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      senc <= 1;
                      sse <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   senc <= 1;
                   sse <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h07: begin
                if (seglen > 8) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      senc <= 1;
                      sse <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   senc <= 1;
                   sse <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h0F: begin
				    seglenn <= 0;
                if (seglen > 12) begin
                   if (pdi_valid) begin
		      if (counter != INITCTR2) begin
		    xse <= 1;
		    xenc <= 1;		    
		 end 
                      pdi_ready <= 1;
                      pdi <= {pdi_data[31:4],seglen[3:0]};                                 
                      senc <= 1;
                      sse <= 1;
		      zenc <= 1;
		      zse <= 1;	
	 	      domain <= adpadded;
		      nonce_domainn <= adpadded;		      
                      cntn <= 6'h01;
                      fsmn <= nonceheader;                    
                   end                     
                end // if (seglen >= 0)
                else begin
		   if (counter != INITCTR2) begin
		    xse <= 1;
		    xenc <= 1;		    
		 end 
                   pdi <= {28'h0,seglen[3:0]};                  
                   senc <= 1;
                   sse <= 1;
		   zenc <= 1;
		   zse <= 1;		 		   
	 	   domain <= nonce_domain;
		   nonce_domainn <= adpadded;		      
                   cntn <= 6'h01;
                   fsmn <= nonceheader;               
                end                             
             end // case: 6'h0F      
           endcase // case (cnt)              
        end // case: storeadsp
        storeadtf: begin
           if (pdi_valid) begin
              pdi_ready <= 1;                 
              yenc <= 1;
              yse <= 1;
              yrst <= 1;              
              if (cnt == 5'h01) begin
				     seglenn <= seglen - 16;
				  end				  
              if (cnt == 5'h0F) begin
                 cntn <= 6'h01;
		 if (flags[1] == 1) begin
		    nonce_domainn <= adfinal;		      
		 end
                 fsmn <= encryptad;
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
				end
        end     
        storeadtp: begin
           case (cnt) 
             6'h01: begin
                if (seglen > 0) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      yenc <= 1;
                      yse <= 1;
                      yrst <= 1;                      
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   yenc <= 1;
                   yse <= 1;
                   yrst <= 1;                 
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h03: begin
                if (seglen > 4) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      yenc <= 1;
                      yse <= 1;
                      yrst <= 1;                      
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   yenc <= 1;
                   yse <= 1;
                   yrst <= 1;                 
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h07: begin
                if (seglen > 8) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;                 
                      yenc <= 1;
                      yse <= 1;
                      yrst <= 1;                      
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   yenc <= 1;
                   yse <= 1;
                   yrst <= 1;                 
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h0F: begin
				    seglenn <= 0;
                if (seglen > 12) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      pdi <= {pdi_data[31:4],seglen[3:0]};                 
                      yenc <= 1;
                      yse <= 1;
                      yrst <= 1;                      
                      cntn <= 6'h01;
		      nonce_domainn <= adpadded;		      
                      cntn <= 6'h01;                 		      
                      fsmn <= encryptad;                      
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= {28'h0,seglen[3:0]};                  
                   yenc <= 1;
                   yse <= 1;
                   yrst <= 1;    
		   nonce_domainn <= adpadded;		      
                   cntn <= 6'h01;
                   fsmn <= encryptad;                 
                end                             
             end // case: 6'h0F      
           endcase // case (cnt)              
        end // case: storeadsp
        msgheader: begin
           if (pdi_valid) begin
              if (dec == 1) begin
                 if (pdi_data[31:28] == CIPHER) begin            
                    seglenn <= pdi_data[15:0];
                    flagsn <= pdi_data[27:24];           
                    if ((pdi_data[25] == 1) && (pdi_data[15:0] < 16)) begin
		       if (pdo_ready) begin
			  fsmn <= storemp;
			  pdi_ready <= 1;
			  pdo_valid <= 1;
			  pdo_data <= {PLAIN , pdi_data[27], 1'b0, pdi_data[25],pdi_data[25],pdi_data[23:0]};
		       end		       
                    end
                    else begin
		       if (pdo_ready) begin
			  pdi_ready <= 1;
			  fsmn <= storemf;
			  pdo_valid <= 1;
		     	  pdo_data <= {PLAIN , pdi_data[27], 1'b0, pdi_data[25],pdi_data[25],pdi_data[23:0]};
		       end
		    end
                 end          
              end // if (dec == 1)
              else begin
		 seglenn <= pdi_data[15:0];
                 flagsn <= pdi_data[27:24];           
                 if ((pdi_data[25] == 1) && (pdi_data[15:0] < 16)) begin
		    if (pdo_ready) begin
			  fsmn <= storemp;
			  pdi_ready <= 1;
			  pdo_valid <= 1;
			  pdo_data <= {CIPHER , pdi_data[27], 1'b0, pdi_data[25],1'b0,pdi_data[23:0]};
		    end
                 end
                 else begin
		    if (pdo_ready) begin
		       pdi_ready <= 1;
		       fsmn <= storemf;
		       pdo_valid <= 1;
		       pdo_data <= {CIPHER, pdi_data[27], 1'b0, pdi_data[25],1'b0,pdi_data[23:0]};
		       end
		    end // if (pdo_ready)		       
              end // else: !if(dec == 1)	      
           end // if (pdi_valid)           
        end // case: msgheader
                storemf: begin
           if (pdi_valid) begin
	           if (pdo_ready) begin
		           decrypt <= {dec,dec,dec,dec};		 
		           pdo_valid <= 1;
		           pdo_data <= pdo;		 
		           pdi_ready <= 1;                 
		           senc <= 1;
		           sse <= 1;
		           if (cnt == 5'h01) begin
		              seglenn <= seglen - 16;
		           end
		           if (cnt == 5'h0F) begin
		              zenc <= 1;
		              zse <= 1;
		              yenc <= 1;
		              yse <= 1;
		              xenc <= 1;
		              xse <= 1;
		              correct_cntn <= 1;	      
		              if ((seglen == 0) && (flags[1] == 1)) begin
		                 domain <= msgfinal;
		                 nonce_domainn <= adpadded;		       
		              end
		              else begin
		                 domain <= msgnormal;		       
		              end
                    cntn <= 6'h01;
                    fsmn <= encryptm;               
		           end
		           else begin
                    cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
		           end
              end // if (pdo_ready)	      
	        end          
        end
        storemp: begin
           case (cnt) 
             6'h01: begin		
                if (seglen > 0) begin
		   if (pdo_ready) begin
                      if (pdi_valid) begin
			 pdo_valid <= 1;
			 case (seglen) 
			   1: begin
			      pdo_data <= {pdo[31:24],24'h0};
			      decrypt <= {dec,3'b0};		 
			   end
			   2: begin
			      pdo_data <= {pdo[31:16],16'h0};
			      decrypt <= {dec,dec,2'b0};		 
			   end
			   3: begin
			      pdo_data <= {pdo[31:8],8'h0};
			      decrypt <= {dec,dec,dec,1'b0};		 
			   end
			   default: begin
			      pdo_data <= pdo;		
			      decrypt <= {dec,dec,dec,dec};		 	      
			   end
			 endcase // case (seglen)			 
			 pdi_ready <= 1;                 
			 senc <= 1;
			 sse <= 1;
			 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end		   
		end		
                else begin
                   pdi <= 0;
                   senc <= 1;
                   sse <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end // else: !if(seglen >= 0)
	     end // case: 6'h01	     
             6'h03: begin
                if (seglen > 4) begin
		   if (pdo_ready) begin
                      if (pdi_valid) begin
			 pdo_valid <= 1;
			 case (seglen) 
			   5: begin
			      pdo_data <= {pdo[31:24],24'h0};		
			      decrypt <= {dec,3'b0};		 	      
			   end
			   6: begin
			      pdo_data <= {pdo[31:16],16'h0};
			      decrypt <= {dec,dec,2'b0};		 
			   end
			   7: begin
			      pdo_data <= {pdo[31:8],8'h0};
			      decrypt <= {dec,dec,dec,1'b0};		 
			   end
			   default: begin
			      pdo_data <= pdo;		
			      decrypt <= {dec,dec,dec,dec};		 	      
			   end
			 endcase // case (seglen)			 
			 pdi_ready <= 1;                 
			 senc <= 1;
			 sse <= 1;
			 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end               
		   end      
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   senc <= 1;
                   sse <= 1;                  
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h07: begin
                if (seglen > 8) begin
		   if (pdo_ready) begin
                      if (pdi_valid) begin
			 pdo_valid <= 1;
			 case (seglen) 
			   9: begin
			      pdo_data <= {pdo[31:24],24'h0};		
			      decrypt <= {dec,3'b0};		 
			   end
			   10: begin
			      pdo_data <= {pdo[31:16],16'h0};
			      decrypt <= {dec,dec,2'b0};		 
			   end
			   11: begin
			      pdo_data <= {pdo[31:8],8'h0};
			      decrypt <= {dec,dec,dec,1'b0};		 
			   end
			   default: begin
			      pdo_data <= pdo;		
			      decrypt <= {dec,dec,dec,dec};		 	      
			   end
			 endcase // case (seglen)			 			 
			 pdi_ready <= 1;                 
			 senc <= 1;
			 sse <= 1;
			 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end               
		   end      
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;               
                   senc <= 1;
                   sse <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                                 
                end             
             end
             6'h0F: begin
				    seglenn <= 0;
                if (seglen > 12) begin
		   if (pdo_ready) begin		      
                      if (pdi_valid) begin
			 pdo_valid <= 1;
			 case (seglen) 
			   13: begin
			      pdo_data <= {pdo[31:24],24'h0};		
			      decrypt <= {dec,3'b0};		 	      
			   end
			   14: begin
			      pdo_data <= {pdo[31:16],16'h0};
			      decrypt <= {dec,dec,2'b0};		 
			   end
			   15: begin
			      pdo_data <= {pdo[31:8],8'h0};
			      decrypt <= {dec,dec,dec,1'b0};		 
			   end
			   default: begin
			      pdo_data <= pdo;		
			      decrypt <= {dec,dec,dec,dec};		 
			   end
			 endcase // case (seglen)			 			 
			 domain <= msgpadded;
			 zenc <= 1;
			 zse <= 1;
			 correct_cntn <= 1;	      
			 yenc <= 1;
			 yse <= 1;
			 xenc <= 1;
			 xse <= 1;	      	      		      
			 pdi_ready <= 1;
			 pdi <= {pdi_data[31:4],seglen[3:0]};                 
			 senc <= 1;
			 sse <= 1;
			 cntn <= 6'h01;
			 fsmn <= encryptm;               
                      end            
		   end         
                end // if (seglen >= 0)
                else begin
		   domain <= msgpadded;
		   zenc <= 1;
		   zse <= 1;
		   correct_cntn <= 1;	      
		   yenc <= 1;
		   yse <= 1;
		   xenc <= 1;
		   xse <= 1;	      	      		   
                   pdi <= {28'h0,seglen[3:0]};                  
                   senc <= 1;
                   sse <= 1;
                   cntn <= 6'h01;
                   fsmn <= encryptm;                  
                end                             
             end // case: 6'h0F      
           endcase // case (cnt)                   
        end // case: storemp
        encryptad: begin
           correct_cntn <= 0;
           tk1sn <= ~tk1s;         
           senc <= 1;
           xenc <= 1;
           yenc <= 1;
           zenc <= 1;
           cntn <= {constant2[4:0], constant2[5]^constant2[4]^1'b1};                                         
           if (constant2 == FINCONST) begin
              cntn <= 6'h01;
	      if (seglen == 0) begin
              if (flags[1] == 1) begin
                 fsmn <= storeadsp;
                 seglenn <= 0;           
                 st0n <= 1;
                 c2n <= 0;               
              end
              else begin
		 correct_cntn <= 1;
		 zenc <= 1;
		 zse <= 1;		 
                 fsmn <= adheader;
                 c2n <= 1;                  
              end    
              end
				  else if (seglen < 16) begin
				     correct_cntn <= 1;
				     fsmn <= storeadsp;
					  zenc <= 1;
		           zse <= 1;
                 c2n <= 1;
              end
				  else begin
				     correct_cntn <= 1;
				     fsmn <= storeadsf;
					  zenc <= 1;
		           zse <= 1;
                 c2n <= 1;
              end				  
           end // if (cnt == FINCONST)    
        end // case: encryptad
        encryptn: begin
           correct_cntn <= 0;
           tk1sn <= ~tk1s;         
           senc <= 1;
           xenc <= 1;
           yenc <= 1;
           zenc <= 1;
           cntn <= {constant2[4:0], constant2[5]^constant2[4]^1'b1};                                         
           if (constant2 == FINCONST) begin
              cntn <= 6'h01;          
              fsmn <= msgheader;
	      zrst <= 1;
	      zenc <= 1;
	      zse <= 1;
	      correct_cntn <= 1;	      
              c2n <= 1;             
           end // if (cnt == FINCONST)     
        end // case: encryptn
        encryptm: begin
           correct_cntn <= 0;
           tk1sn <= ~tk1s;         
           senc <= 1;
           xenc <= 1;
           yenc <= 1;
           zenc <= 1;
           cntn <= {constant2[4:0], constant2[5]^constant2[4]^1'b1};                                        
           if (constant2 == FINCONST) begin
              cntn <= 6'h01;
              if (seglen == 0) begin				  
              if (flags[1] == 1) begin
                 if (dec == 1) begin
                    fsmn <= verifytag0;
                 end
                 else begin
                    fsmn <= outputtag0;
                 end
                 seglenn <= 0;           
                 st0n <= 1;
                 c2n <= 0;               
              end
              else begin
                 fsmn <= msgheader;
                 c2n <= 1;                  
              end
              end
              else if (seglen < 16) begin
                 fsmn <= storemp;
                 c2n <= 1;
              end
              else begin
                 fsmn <= storemf;
                 c2n <= 1;
              end				  
           end // if (cnt == FINCONST)
        end // case: encryptm
        outputtag0: begin
           if (pdo_ready) begin
              pdi <= 0;    
              pdo_valid <= 1;      
              pdo_data <= {TAG,4'h3,8'h0,16'h010};
              fsmn <= outputtag1;             
           end
        end
        outputtag1: begin
           if (pdo_ready) begin
              pdi <= 0;    
              senc <= 1;
              sse <= 1;              
              pdo_valid <= 1;      
              pdo_data <= pdo;
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
              if (cnt == 6'h0F) begin
                 fsmn <= statuse;
                 cntn <= 6'h01;
              end
           end // if (pdo_ready)           
        end // case: outputtag1 
        verifytag0: begin
           if (pdi_valid) begin
              if (pdi_data[31:28] == TAG) begin
                 fsmn <= verifytag1;
                 pdi_ready <= 1;
              end             
           end     
        end
        verifytag1: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (cnt == 6'h0F) begin
                 cntn <= 6'h01;
		 if ((pdo != 32'h0) || (dec == 0)) begin
                    fsmn <= statusdf;
                 end
                 else begin
                    fsmn <= statusds;
                 end // else: !if((pdo != 32'h0) || (dec == 0))          
              end // if (cnt == 6'h0F)
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};     
		 senc <= 1;
		           sse <= 1;         
                 if (pdo != 32'h0) begin
                    decn <= 0;           
                 end
              end // else: !if(cnt == 6'h0F)          
           end // if (pdi_valid)           
        end // case: verifytag1  
	statusds: begin
		     if (pdo_ready) begin
			     pdo_valid <= 1;
              pdo_data <= {SUCCESS, 28'h0};
				  do_last <= 1;
				  fsmn <= idle;
			xse <= 1;
				  xenc <= 1;
		     end
        end	
        statusdf: begin
		     if (pdo_ready) begin
			     pdo_valid <= 1;
              pdo_data <= {FAILURE, 28'h0};
				  do_last <= 1;
				  fsmn <= idle;
			xse <= 1;
				  xenc <= 1;
		     end
        end	
        statuse: begin
		     if (pdo_ready) begin
			     pdo_valid <= 1;
              pdo_data <= {SUCCESS, 28'h0};
				  do_last <= 1;
				  fsmn <= idle;
			xse <= 1;
				  xenc <= 1;
			  end
		  end		  
      endcase // case (fsm)      
   end
   
endmodule // api
