module api (/*AUTOARG*/
            // Outputs
            pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, do_last, domain,
            con, sen, sdec, schain, smxc, smode, srst, tk1se, tk1ksch,
            tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n, tk2ksch, tk2in, tk2chain,
            tk2correct, tk3ksch, tk3in, tk3chain, tk3correct,
            // Inputs
            counter, pdi_data, pdo, sdi_data, pdi_valid, sdi_valid, pdo_ready,
            clk, rst
            ) ;
   // SKINNY FINAL CONSTANT
   parameter FINCONST = 7'b001010;

   // BLK COUNTER INITIAL CONSTANT
   parameter INITCTR = 56'h00000000000002;
   parameter INITCTR2 = 56'h00000000000001;   

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
   parameter keyheader2  = 3;   
   parameter storekey    = 4;
   parameter nonceheader = 5;
   parameter storen      = 6;
   parameter adheader    = 7;
   parameter adheader2   = 8;
   parameter msgheader   = 9;
   parameter storeadsf   = 10;
   parameter storeadtf   = 11;
   parameter storeadsp   = 12;
   parameter storeadtp   = 13;
   parameter storemf     = 14;
   parameter storemp     = 15;
   parameter encryptad   = 16;
   parameter encryptn    = 17;
   parameter encryptm    = 18;
   parameter outputtag0  = 19;
   parameter outputtag1  = 20;   
   parameter verifytag0  = 21;
   parameter verifytag1  = 22;
   parameter statuse     = 23;  
   parameter statusdf    = 24;  
   parameter statusds    = 25;
   parameter rstsf       = 26;          
   
   output reg [7:0] pdo_data, pdi;
   output reg       pdi_ready, sdi_ready, pdo_valid, do_last;

   output reg [7:0] domain, con;
   output reg [3:0] sen;   
   output reg       sdec, schain, smxc,smode, srst;
   output reg       tk1se, tk1ksch, tk1chain, tk1rst, tk1correct_cnt, tk1s, tk1n;
   output reg       tk2ksch, tk2in, tk2chain, tk2correct;       
   output reg       tk3ksch, tk3in, tk3chain, tk3correct;       
   
   input [55:0]     counter;   
   input [7:0]      pdi_data, pdo, sdi_data;
   input            pdi_valid, sdi_valid, pdo_ready;

   input            clk, rst;

   reg [4:0]        fsm, fsmn;
   reg [15:0]       seglen, seglenn;  
   reg [3:0]        flags, flagsn;
   reg              dec, decn;
   reg [7:0]        nonce_domain, nonce_domainn;
   reg [5:0]        cnt, cntn;
   reg [4:0]        cenc, cencn;   
   reg              tk1correct_cntn, tk1nn;

   always @ (posedge clk) begin
      if (rst) begin
         fsm <= idle;
         seglen <= 0;
         flags <= 0;
         dec <= 0;
         tk1correct_cnt <= 1;
         cnt <= 6'h01;   
         cenc <= 0;      
         nonce_domain <= adpadded;       
         tk1n <= 0;
      end
      else begin
         fsm <= fsmn;
         seglen <= seglenn;
         flags <= flagsn;
         dec <= decn;
         cnt <= cntn;
         cenc <= cencn;  
         nonce_domain <= nonce_domainn;
         tk1correct_cnt <= tk1correct_cntn; 
         tk1n <= tk1nn;                 
      end
   end
   
   always @ ( tk1n or cenc or cnt or counter or dec or flags
              or fsm or nonce_domain or pdi_data or pdi_valid or pdo
              or pdo_ready or sdi_data or sdi_valid or seglen
              or tk1correct_cnt) begin
      pdo_data <= 0;      
      pdi      <= pdi_data;    
      do_last  <= 0;            
      domain   <= 0;         
      sen      <= 0;
      sdec     <= 0;
      schain   <= 0;
      smxc     <= 0;
      smode    <= 0;
      srst     <= 0;
      con      <= 0;      
      tk1se    <= 0;
      tk1ksch  <= 0;      
      tk1chain <= 0;
      tk1rst   <= 0;
      tk1correct_cntn <= tk1correct_cnt;
      tk2ksch  <= 0;
      tk2in    <= 0;
      tk2chain <= 0;
      tk2correct <= 0;
      tk3ksch  <= 0;
      tk3in    <= 0;
      tk3chain <= 0;
      tk3correct <= 0;      
      sdi_ready <= 0;
      pdi_ready <= 0;
      pdo_valid <= 0;
      tk1s <= 0;      
      nonce_domainn <= nonce_domain;      
      fsmn <= fsm;
      seglenn <= seglen; 
      flagsn <= flags;
      decn <= dec;
      cntn <= cnt;
      cencn <= cenc; 
      tk1nn <= tk1n;            
      case (fsm) 
        idle: begin
           cntn <= 'h1;    
           pdi_ready <= 1;
           nonce_domainn <= adpadded; 
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (pdi_data[7:4] == ACTKEY) begin
                 fsmn <= loadkey;              
              end
              else if (pdi_data[7:4] == ENC) begin
                 tk1rst <= 1;        
                 tk1se <= 1;
                 tk1correct_cntn <= 1;           
                 fsmn <= rstsf;
                 decn <= 0;              
              end
              else if (pdi_data[7:4] == DEC) begin
                 tk1rst <= 1;        
                 tk1se <= 1;
                 tk1correct_cntn <= 1;           
                 fsmn <= rstsf;
                 decn <= 1;             
              end
           end     
        end // case: idle
        loadkey: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              if (sdi_data[7:4] == LDKEY) begin
                 fsmn <= keyheader;               
              end             
           end
        end
        keyheader: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              if (sdi_data[7:4] == KEY) begin
                 fsmn <= keyheader2;
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end             
           end
        end     
        keyheader2: begin
           if (sdi_valid) begin
              if (cnt == 'hF) begin
                 cntn <= 'h1;
                 fsmn <= storekey;               
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
              sdi_ready <= 1;
           end
        end
        storekey: begin
           if (sdi_valid) begin
              sdi_ready <= 1;
              tk3in <= 1;
              tk3chain <= 1;
              if (cnt == 5'h0E) begin
                 cntn <= 6'h01;
                 fsmn <= idle;           
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
           end
        end // case: storekey
        rstsf: begin
           if (cnt == 'h0E) begin
              cntn <= 'h01;
              fsmn <= adheader;       
           end
           else begin
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                         
           end
           sen <= 4'hF;
           pdi <= 8'h00;
           schain <= 1;
           srst <= 1;
           smode <= 1;
           tk1se <= 1;
           tk1rst <= 1;    
        end
        nonceheader: begin
           case (cnt) 
             'h01: begin
                if (pdi_valid) begin
                   pdi_ready <= 1;
                   if (pdi_data[7:4] == Npub) begin
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                   end             
                end
             end
             'h03: begin
                if (pdi_valid) begin
                   pdi_ready <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end
             end
             'h07: begin
                if (pdi_valid) begin
                   pdi_ready <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end
             end
             'h0F: begin
                if (pdi_valid) begin
                   pdi_ready <= 1;
                   fsmn <= storen;
                   cntn <= 'h01;                   
                end
             end
           endcase // case (cnt)
        end // case: nonceheader        
        storen: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              tk2in <= 1;
              tk2chain <= 1;
              if (cnt == 5'h0E) begin
                 domain <= nonce_domain;
                 cntn <= 6'h01;
                 fsmn <= encryptn;
                 cencn <= 0;             
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end
           end
        end // case: storen
        adheader: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              case (cnt) 
                'h01: begin
                   if (pdi_data[7:4] == AD) begin
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                      flagsn <= pdi_data[3:0];                              
                   end
                end
                'h03: begin
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
                end
                'h07: begin
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
                   seglenn[15:8] <= pdi_data;              
                end
                'h0F: begin
                   cntn <= 'h01;
                   seglenn[7:0] <= pdi_data;               
                   if ((flags[1] == 1) && ({seglen[15:8],pdi_data} < 16)) begin
                      fsmn <= storeadsp;
                   end
                   else begin
                      fsmn <= storeadsf;
                   end
                end
              endcase // case (cnt)           
           end
        end // case: adheader
        adheader2: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              case (cnt) 
                'h01: begin
                   if (pdi_data[7:4] == AD) begin
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                      flagsn <= pdi_data[3:0];                              
                   end
                end
                'h03: begin
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
                end
                'h07: begin
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
                   seglenn[15:8] <= pdi_data;              
                end
                'h0F: begin
                   cntn <= 'h01;
                   seglenn[7:0] <= pdi_data;               
                   if ((flags[1] == 1) && ({seglen[15:8],pdi_data} < 16)) begin
                      fsmn <= storeadtp;
                   end
                   else begin
                      fsmn <= storeadtf;
                   end
                end
              endcase // case (cnt)           
           end
        end // case: adheader2  
        storeadsf: begin
           if (pdi_valid) begin
              pdi_ready <= 1;                 
              sen <= 'hF;
              schain <= 1;
              smode <= 1;
              pdi <= pdi_data;        
              if (cnt == 5'h01) begin
                 seglenn <= seglen - 16;
              end       
              if (cnt == 5'h0E) begin
                 if (counter != INITCTR2) begin
                    tk3correct <= 1;
                 end 
                 cntn <= 6'h01;
                 tk1se <= 1;
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
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h03: begin
                if (seglen > 1) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h03
             6'h07: begin
                if (seglen > 2) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h07
             6'h0F: begin
                if (seglen > 3) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h0F
             6'h1F: begin
                if (seglen > 4) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h1F
             6'h3E: begin
                if (seglen > 5) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3E
             6'h3D: begin
                if (seglen > 6) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3D
             6'h3B: begin
                if (seglen > 7) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3B
             6'h37: begin
                if (seglen > 8) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h37
             6'h2F: begin
                if (seglen > 9) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h2F
             6'h1E: begin
                if (seglen > 10) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h1E
             6'h3C: begin
                if (seglen > 11) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3C
             6'h39: begin
                if (seglen > 12) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h39
             6'h33: begin
                if (seglen > 13) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h33
             6'h27: begin
                if (seglen > 14) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      sen <= 'hF;
                      schain <= 1;
                      smode <= 1;
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   sen <= 'hF;
                   schain <= 1;
                   smode <= 1;
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end
             6'h0E: begin
                seglenn <= 0;
                if (counter != INITCTR2) begin
                   tk3correct <= 1;
                end 
                pdi <= {4'h0,seglen[3:0]};
                sen <= 'hF;
                schain <= 1;
                smode <= 1;
                tk1se <= 1;             
                domain <= nonce_domain;
                nonce_domainn <= adpadded;                    
                cntn <= 6'h01;
                fsmn <= nonceheader;               
             end // case: 6'h0E      
           endcase // case (cnt)              
        end // case: storeadsp
        storeadtf: begin
           if (pdi_valid) begin
              pdi_ready <= 1;                 
              tk2in <= 1;
              tk2chain <= 1;
              if (cnt == 5'h01) begin
                 seglenn <= seglen - 16;
              end                                 
              if (cnt == 5'h0E) begin
                 cntn <= 6'h01;
                 if (flags[1] == 1) begin
                    nonce_domainn <= adfinal;                 
                 end
                 fsmn <= encryptad;
                 cencn <= 0;             
              end
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                
              end             
           end // if (pdi_valid)           
        end // case: storeadtf
        storeadtp: begin
           case (cnt) 
             6'h01: begin
                if (seglen > 0) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h03: begin
                if (seglen > 1) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h03
             6'h07: begin
                if (seglen > 2) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h07
             6'h0F: begin
                if (seglen > 3) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h0F
             6'h1F: begin
                if (seglen > 4) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h1F
             6'h3E: begin
                if (seglen > 5) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3E
             6'h3D: begin
                if (seglen > 6) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3D
             6'h3B: begin
                if (seglen > 7) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3B
             6'h37: begin
                if (seglen > 8) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h37
             6'h2F: begin
                if (seglen > 9) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h2F
             6'h1E: begin
                if (seglen > 10) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h1E
             6'h3C: begin
                if (seglen > 11) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h3C
             6'h39: begin
                if (seglen > 12) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h39
             6'h33: begin
                if (seglen > 13) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end // case: 6'h33
             6'h27: begin
                if (seglen > 14) begin
                   if (pdi_valid) begin
                      pdi_ready <= 1;
                      tk2in <= 1;
                      tk2chain <= 1;                  
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                   end                     
                end // if (seglen >= 0)
                else begin
                   pdi <= 0;
                   tk2in <= 1;
                   tk2chain <= 1;                     
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end // else: !if(seglen >= 0)
             end
             6'h0E: begin
                seglenn <= 0;
                pdi <= {4'h0,seglen[3:0]};
                tk2in <= 1;
                tk2chain <= 1;                
                domain <= nonce_domain;
                nonce_domainn <= adpadded;                    
                cntn <= 6'h01;
                cencn <= 0;              
                fsmn <= encryptad;               
             end // case: 6'h0E      
           endcase // case (cnt)              
        end // case: storeadtp  
        msgheader: begin
           if (pdi_valid) begin
              case (cnt) 
                'h01: begin
                   if (dec == 1) begin                
                      if (pdi_data[7:4] == CIPHER) begin
                         if (pdo_ready) begin
                            pdi_ready <= 1;
                            pdo_valid <= 1;
                            pdo_data <= {PLAIN,pdi_data[3],1'b0,pdi_data[1],pdi_data[1]};
                            cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                         end            
                         flagsn <= pdi_data[3:0];                        
                      end
                   end // if (dec == 1)
                   else begin
                      if (pdi_data[7:4] == PLAIN) begin
                         if (pdo_ready) begin
                            pdi_ready <= 1;
                            pdo_valid <= 1;
                            pdo_data <= {CIPHER,pdi_data[3],1'b0,pdi_data[1],1'b0};
                            cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                         end
                         flagsn <= pdi_data[3:0];                        
                      end
                   end
                end
                'h03: begin
                   if (pdo_ready) begin
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                      pdi_ready <= 1;
                      pdo_valid <= 1;
                      pdo_data <= pdi_data;                   
                   end             
                end
                'h07: begin
                   if (pdo_ready) begin
                      cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                      pdi_ready <= 1;
                      pdo_valid <= 1;
                      pdo_data <= pdi_data;                   
                   end             
                   seglenn[15:8] <= pdi_data;              
                end
                'h0F: begin
                   if (pdo_ready) begin
                      cntn <= 'h01;
                      pdi_ready <= 1;
                      pdo_valid <= 1;
                      pdo_data <= pdi_data;
                      seglenn[7:0] <= pdi_data;
                      if ((flags[1] == 1) && ({seglen[15:8],pdi_data} < 16)) begin
                         fsmn <= storemp;                        
                      end
                      else begin
                         fsmn <= storemf;                        
                      end
                   end             
                   seglenn[7:0] <= pdi_data;
                end // case: 'h0F               
              endcase // case (cnt)
           end // if (pdi_valid)                                
        end // case: msgheader
        storemf: begin
           if (pdi_valid) begin
              if (pdo_ready) begin
                 sdec <= dec;            
                 pdo_valid <= 1;
                 pdo_data <= pdo;                
                 pdi_ready <= 1;                 
                 sen <= 'hF;
                 schain <= 1;
                 smode <= 1;             
                 if (cnt == 5'h01) begin
                    seglenn <= seglen - 16;
                 end
                 if (cnt == 5'h0E) begin
                    tk1se <= 1;
                    tk2correct <= 1;
                    tk3correct <= 1;
                    tk1correct_cntn <= 1;             
                    if ((seglen == 0) && (flags[1] == 1)) begin
                       domain <= msgfinal;
                       nonce_domainn <= adpadded;                      
                    end
                    else begin
                       domain <= msgnormal;                    
                    end
                    cntn <= 6'h01;
                    fsmn <= encryptm;
                    cencn <= 0;                         
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
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h03: begin               
                if (seglen > 1) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h07: begin               
                if (seglen > 2) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h0F: begin               
                if (seglen > 3) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h1F: begin               
                if (seglen > 4) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h3E: begin               
                if (seglen > 5) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h3D: begin               
                if (seglen > 6) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h3B: begin               
                if (seglen > 7) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h37: begin               
                if (seglen > 8) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h2F: begin               
                if (seglen > 9) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h1E: begin               
                if (seglen > 10) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h3C: begin               
                if (seglen > 11) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h39: begin               
                if (seglen > 12) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h33: begin               
                if (seglen > 13) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h27: begin               
                if (seglen > 14) begin
                   if (pdo_ready) begin
                      if (pdi_valid) begin
                         pdo_valid <= 1;
                         pdo_data <= pdo;               
                         sdec <= dec;                         
                         pdi_ready <= 1;                 
                         sen <= 4'hF;
                         schain <= 1;
                         smode <= 1;                     
                         cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};           
                      end                     
                   end             
                end             
                else begin
                   pdi <= 0;
                   sen <= 4'hF;
                   schain <= 1;
                   smode <= 1;                   
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                end // else: !if(seglen >= 0)
             end // case: 6'h01      
             6'h0E: begin
                seglenn <= 0;
                pdi <= {4'h0, seglen[3:0]};
                domain <= msgpadded;
                tk1se <= 1;
                tk1correct_cntn <= 1;
                tk2correct <= 1;
                tk3correct <= 1;
                sen <= 4'hF;
                schain <= 1;
                smode <= 1;                      
                cntn <= 'h01;
                fsmn <= encryptm;
                cencn <= 0;              
             end // case: 6'h0E      
           endcase // case (cnt)                   
        end // case: storemp
        encryptad: begin
           tk1correct_cntn <= 0;           
           cencn <= cenc + 1;
           if (cenc == 0) begin
              con <= {4'h0,cnt[3:0]};         
           end
           else if (cenc == 4) begin
              con <= {6'h0,cnt[5:4]};         
           end
           else if (cenc == 8) begin
              con <= 8'h02;           
           end
           else begin
              con <= 0;       
           end
           if (cenc <  8) begin
              sen <= 4'hF;
              schain <= 1;
              tk1s <= 1;
              tk1chain <= 1;
              tk1se <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 16) begin
              sen <= 4'hF;
              schain <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 17) begin
              sen <= 4'h7;          
              tk1se <= 1;
              if (tk1n == 0) begin
                 tk1ksch <= 1; 
                 tk1se <= 1;
              end
              else begin
                 tk1ksch <= 0;
                 tk1se <= 0;
              end                               
              tk1nn <= ~tk1n;
              tk2ksch <= 1;
              tk3ksch <= 1;           
           end
           else if (cenc < 18) begin
              sen <= 4'h6;            
           end
           else if (cenc < 19) begin
              sen <= 4'h4;            
           end
           else if (cenc < 22) begin
              sen <= 4'hF;
              smxc <= 1;              
           end
           else begin
              cencn <= 0;             
              sen <= 4'hF;
              smxc <= 1;
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
              if (cnt == FINCONST) begin
                 cntn <= 6'h01;
                 if (seglen == 0) begin
                    if (flags[1] == 1) begin
                       fsmn <= storeadsp;
                    end
                    else begin
                       tk1correct_cntn <= 1;
                       tk1se <= 1;
                       fsmn <= adheader;
                    end
                 end
                 else if (seglen < 16) begin
                    tk1correct_cntn <= 1;
                    tk1se <= 1;
                    fsmn <= storeadsp;
                 end
                 else begin
                    tk1correct_cntn <= 1;
                    tk1se <= 1;
                    fsmn <= storeadsf;
                 end
              end // if (cnt == FINCONST)
           end // else: !if(cenc < 22)
        end // case: encryptad
        encryptn: begin
           tk1correct_cntn <= 0;           
           cencn <= cenc + 1;
           if (cenc == 0) begin
              con <= {4'h0,cnt[3:0]};         
           end
           else if (cenc == 4) begin
              con <= {6'h0,cnt[5:4]};         
           end
           else if (cenc == 8) begin
              con <= 8'h02;           
           end
           else begin
              con <= 0;       
           end
           if (cenc <  8) begin
              sen <= 4'hF;
              schain <= 1;
              tk1s <= 1;
              tk1chain <= 1;
              tk1se <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 16) begin
              sen <= 4'hF;
              schain <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 17) begin
              sen <= 4'h7;          
              if (tk1n == 0) begin
                 tk1ksch <= 1; 
                 tk1se <= 1;
              end
              else begin
                 tk1ksch <= 0;
                 tk1se <= 0;
              end          
              tk1nn <= ~tk1n;                   
              tk2ksch <= 1;
              tk3ksch <= 1;           
           end
           else if (cenc < 18) begin
              sen <= 4'h6;            
           end
           else if (cenc < 19) begin
              sen <= 4'h4;            
           end
           else if (cenc < 22) begin
              sen <= 4'hF;
              smxc <= 1;              
           end
           else begin
              cencn <= 0;             
              sen <= 4'hF;
              smxc <= 1;
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
              if (cnt == FINCONST) begin
                 cntn <= 6'h01;
                 tk1correct_cntn <= 1;
                 tk1se <= 1;
                 tk1rst <= 1;            
                 fsmn <= msgheader;
              end // if (cnt == FINCONST)
           end // else: !if(cenc < 22)
        end // case: encryptn
        encryptm: begin
           tk1correct_cntn <= 0;           
           cencn <= cenc + 1;
           if (cenc == 0) begin
              con <= {4'h0,cnt[3:0]};         
           end
           else if (cenc == 4) begin
              con <= {6'h0,cnt[5:4]};         
           end
           else if (cenc == 8) begin
              con <= 8'h02;           
           end
           else begin
              con <= 0;       
           end
           if (cenc <  8) begin
              sen <= 4'hF;
              schain <= 1;
              tk1s <= 1;
              tk1chain <= 1;
              tk1se <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 16) begin
              sen <= 4'hF;
              schain <= 1;
              tk2chain <= 1;
              tk3chain <= 1;          
           end
           else if (cenc < 17) begin
              sen <= 4'h7;          
              if (tk1n == 0) begin
                 tk1ksch <= 1; 
                 tk1se <= 1;
              end
              else begin
                 tk1ksch <= 0;
                 tk1se <= 0;
              end             
              tk1nn <= ~tk1n;
              tk2ksch <= 1;
              tk3ksch <= 1;           
           end
           else if (cenc < 18) begin
              sen <= 4'h6;            
           end
           else if (cenc < 19) begin
              sen <= 4'h4;            
           end
           else if (cenc < 22) begin
              sen <= 4'hF;
              smxc <= 1;              
           end
           else begin
              cencn <= 0;             
              sen <= 4'hF;
              smxc <= 1;
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
              if (cnt == FINCONST) begin
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
                    end
                    else begin
                       fsmn <= msgheader;
                    end // else: !if(flags[1] == 1)
                 end // if (seglen == 0)
                 else if (seglen < 16) begin
                    fsmn <= storemp;
                 end
                 else begin
                    fsmn <= storemf;
                 end              
              end // if (cnt == FINCONST)             
           end // else: !if(cenc < 22)
        end // case: encryptm
        outputtag0: begin
           if (pdo_ready) begin
              case (cnt) 
                'h01: begin
                   pdi <= 0;    
                   pdo_valid <= 1;      
                   pdo_data <= {TAG,4'h3};             
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                end
                'h03: begin
                   pdi <= 0;    
                   pdo_valid <= 1;      
                   pdo_data <= 8'h0;
                   fsmn <= outputtag0;             
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                 
                end
                'h07: begin
                   pdi <= 0;    
                   pdo_valid <= 1;      
                   pdo_data <= 8'h0;
                   fsmn <= outputtag0;             
                   cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};                 
                end
                'h0F: begin
                   pdi <= 0;    
                   pdo_valid <= 1;      
                   pdo_data <= 8'h10;
                   fsmn <= outputtag1;             
                   cntn <= 'h01;
                end
              endcase // case (cnt)           
           end // if (pdo_ready)           
        end // case: outputtag0 
        outputtag1: begin
           if (pdo_ready) begin
              pdi <= 0;    
              sen <= 4'hF;
              schain <= 1;
              smode <= 1;             
              pdo_valid <= 1;      
              pdo_data <= pdo;
              cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
              if (cnt == 6'h0E) begin
                 fsmn <= statuse;
                 cntn <= 6'h01;
              end
           end // if (pdo_ready)           
        end // case: outputtag1 
        statuse: begin
           if (pdo_ready) begin
              pdo_valid <= 1;
              pdo_data <= {SUCCESS, 4'h0};
              do_last <= 1;
              fsmn <= idle;
              tk3correct <= 1;
           end
        end
        verifytag0: begin
           if (pdi_valid) begin
			     case (cnt)
				  'h01: begin
                 if (pdi_data[7:4] == TAG) begin
                    cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
						  pdi_ready <= 1;
					  end
				  end
				  'h0F: begin
				     fsmn <= verifytag1;
                 cntn <= 'h01;
					  pdi_ready <= 1;
				  end
				  default: begin
                 fsmn <= verifytag0;
					  cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1};
                 pdi_ready <= 1;
              end
              endcase				  
           end     
        end
        verifytag1: begin
           if (pdi_valid) begin
              pdi_ready <= 1;
              if (cnt == 6'h0E) begin
                 cntn <= 6'h01;
                 if ((pdo != 8'h0) || (dec == 0)) begin
                    fsmn <= statusdf;
                 end
                 else begin
                    fsmn <= statusds;
                 end // else: !if((pdo != 32'h0) || (dec == 0))          
              end // if (cnt == 6'h0F)
              else begin
                 cntn <= {cnt[4:0], cnt[5]^cnt[4]^1'b1}; 
                 sen <= 4'hF;
                 smode <= 1;
                 schain <= 1;           
                 if (pdo != 8'h0) begin
                    decn <= 0;           
                 end
              end // else: !if(cnt == 6'h0F)          
           end // if (pdi_valid)           
        end // case: verifytag1    
        statusds: begin
           if (pdo_ready) begin
              pdo_valid <= 1;
              pdo_data <= {SUCCESS, 4'h0};
              do_last <= 1;
              fsmn <= idle;
              tk3correct <= 1; 
           end
        end     
        statusdf: begin
           if (pdo_ready) begin
              pdo_valid <= 1;
              pdo_data <= {FAILURE, 4'h0};
              do_last <= 1;
              fsmn <= idle;
              tk3correct <= 1;        
           end
        end                       
      endcase // case (fsm)      
   end
   
endmodule // api
