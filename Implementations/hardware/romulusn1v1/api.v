module api (/*AUTOARG*/
   // Outputs
   pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, domain, srst, senc,
   sse, xrst, xenc, xse, yrst, yenc, yse, zrst, zenc, zse, erst,
   decrypt, correct_cnt, tk1s,
   // Inputs
   counter, pdi_data, pdo, pdi_valid, sdi_valid, pdo_ready, clk, rst,
   constant
   ) ;
   // SKINNY FINAL CONSTANT
   parameter FINCONST = 7'b001010;

   // BLK COUNTER INITIAL CONSTANT
   parameter INITCTR = 56'h01000000000000;   
   
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
   
   //STATES
   parameter idle = 0;
   parameter storekey1 = 1;
   parameter storekey2 = 2;
   parameter storekey3 = 3;
   parameter storekey4 = 4;
   parameter keyheader = 5;
   parameter nonceheader = 6;
   parameter storenonce1 = 7;
   parameter storenonce2 = 8;
   parameter storenonce3 = 9;
   parameter storenonce4 = 10;
   parameter adheader = 11;
   parameter msgheader = 12; 
   parameter storeadtps0_1 = 13;
   parameter storeadtps0_2 = 14;
   parameter storeadtps0_3 = 15;
   parameter storeadtps0_4 = 16;
   parameter storeadtfsp_1 = 17;
   parameter storeadtfsp_2 = 18;
   parameter storeadtfsp_3 = 19;
   parameter storeadtfsp_4 = 20;
   parameter storeadtfsf_1 = 21;
   parameter storeadtfsf_2 = 22;
   parameter storeadtfsf_3 = 23;
   parameter storeadtfsf_4 = 24;
   parameter storeadsf_1 = 25;
   parameter storeadsf_2 = 26;
   parameter storeadsf_3 = 27;
   parameter storeadsf_4 = 28;
   parameter storeadsp_1 = 29;
   parameter storeadsp_2 = 30;
   parameter storeadsp_3 = 31;
   parameter storeadsp_4 = 32;
   parameter storeads0_1 = 33;
   parameter storeads0_2 = 34;
   parameter storeads0_3 = 35;
   parameter storeads0_4 = 36;
   parameter encryptad = 37;  
   parameter store0_1 = 38;
   parameter store0_2 = 39;
   parameter store0_3 = 40;
   parameter store0_4 = 41;
   parameter encryptnonce = 42;
   parameter storemp_1 = 44;
   parameter storemp_2 = 45;
   parameter storemp_3 = 46;
   parameter storemp_4 = 47;
   parameter storemf_1 = 48;
   parameter storemf_2 = 49;
   parameter storemf_3 = 50;
   parameter storemf_4 = 51;
   parameter encryptmsg = 52;
   parameter outputtag1 = 53;
   parameter outputtag2 = 54;   
   parameter outputtag3 = 55;   
   parameter outputtag4 = 56;
   parameter outputtag0 = 57;   
   parameter verifytag1 = 58;
   parameter verifytag2 = 59;	
   parameter verifytag3 = 60;	
   parameter verifytag4 = 61;
   parameter verifytag0 = 62;	
   
   output reg [31:0] pdo_data, pdi;
   output reg 	     pdi_ready, sdi_ready, pdo_valid;

   output reg [7:0]  domain;
   output reg 	     srst, senc, sse;
   output reg 	     xrst, xenc, xse;
   output reg 	     yrst, yenc, yse;
   output reg 	     zrst, zenc, zse;
   output reg 	     erst;
   output reg [3:0]  decrypt;
   output reg 	     correct_cnt;  
   output reg 	     tk1s; 
   
   input [55:0]      counter;   
   input [31:0]  pdi_data, pdo;
   input 	 pdi_valid, sdi_valid, pdo_ready;

   input 	 clk, rst;

   input [5:0] 	 constant;

   reg [5:0] 	 fsm, fsmn;
   reg [15:0] 	 seglen, seglenn;  
   reg [3:0] 	 flags, flagsn;
   reg 		 dec, decn;
   reg [7:0]	 nonce_domain, nonce_domainn;
   reg 		 correct_cntn;
   reg 		 st0, st0n;
   reg 		 c2, c2n;
   reg 		 tk1sn;		       

   always @ (posedge clk) begin
      if (rst) begin
	 fsm <= idle;
	 seglen <= 0;
	 flags <= 0;
	 dec <= 0;
	 correct_cnt <= 1;
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
	 nonce_domain <= nonce_domainn;
	 st0 <= st0n;
	 c2 <= c2n;
	 tk1s <= tk1sn;	 
	 correct_cnt <= correct_cntn;	 
      end
   end


   always @ ( /*AUTOSENSE*/c2 or constant or correct_cnt or counter
	     or dec or flags or fsm or nonce_domain or pdi_data
	     or pdi_valid or pdo or pdo_ready or sdi_valid or seglen
	     or st0 or tk1s) begin
      pdo_data <= 0;      
      pdi <= pdi_data;      
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
      case (fsm) 
	idle: begin
	   tk1sn <= 1;	   
	   nonce_domainn <= adpadded;	   
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == LDKEY) begin
		 fsmn <= keyheader;		 
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
	end
	keyheader: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == KEY) begin
		 fsmn <= storekey1;		 
	      end	      
	   end
	end
	storekey1: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      
	      fsmn <= storekey2;	      
	   end
	end
	storekey2: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      
	      fsmn <= storekey3;	      
	   end
	end
	storekey3: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      
	      fsmn <= storekey4;	      
	   end
	end
	storekey4: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      	      
	      fsmn <= idle;	      
	   end
	end
	nonceheader: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == Npub) begin
		 fsmn <= storenonce1;		 
	      end	      
	   end
	end
	storenonce1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yrst <= 1;
	      yenc <= 1;
	      yse <= 1;	      
	      fsmn <= storenonce2;	      
	   end
	end
	storenonce2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yrst <= 1;
	      yenc <= 1;
	      yse <= 1;	      	      
	      fsmn <= storenonce3;	      
	   end
	end
	storenonce3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yrst <= 1;
	      yenc <= 1;
	      yse <= 1;	      
	      fsmn <= storenonce4;
	      if (c2 == 1) begin		 
		 domain <= nonce_domain;		      
		 zenc <= 1;
		 zse <= 1;
		 correct_cntn <= 1;
		 c2n <= 0;		 
	      end	      
	   end
	end
	storenonce4: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yrst <= 1;
	      yenc <= 1;
	      yse <= 1;	      
	      domain <= nonce_domain;	
	      zenc <= 1;
	      zse <= 1;
	      correct_cntn <= 1;	      
	      if (counter != INITCTR) begin
		 yenc <= 1;
		 yse <= 1;
		 xenc <= 1;
		 xse <= 1;	   
	      end
	      fsmn <= encryptnonce;
	      erst <= 1;		 
	   end
	end
	adheader: begin
	   senc <= 1;
	   srst <= 1;
	   sse <= 1;	   
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == AD) begin
		 seglenn <= pdi_data[15:0];
		 flagsn <= pdi_data[27:24];		 
		 if (pdi_data[15:0] == 0) begin
		    fsmn <= nonceheader;
		    st0n <= 1;		    
		 end
		 else if (pdi_data[15:0] < 16) begin
		    fsmn <= storeadtps0_1;
		    st0n <= 0;		    
		 end
		 else if (pdi_data[15:0] < 32) begin
		    fsmn <= storeadtfsp_1;
		    if (pdi_data == 16) begin
		       st0n <= 0;
		    end
		    else begin
		       st0n <= 1;
		    end		    
		 end
		 else begin
		    fsmn <= storeadtfsf_1;
		    st0n <= 1;		    
		 end
	      end	      
	   end
	end // case: adheader
	storeadtfsf_1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      seglenn <= seglen - 16;
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtfsf_2;
	   end	   
	end
	storeadtfsf_2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtfsf_3;
	   end	   
	end
	storeadtfsf_3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      if (c2 == 1) begin		 
		 domain <= adnormal;		      
		 zenc <= 1;
		 zse <= 1;
		 correct_cntn <= 1;
		 c2n <= 0;		 
	      end	      
	      fsmn <= storeadtfsf_4;
	   end	   
	end
	storeadtfsf_4: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      zenc <= 1;
	      zse <= 1;
	      domain <= adnormal;	      
	      correct_cntn <= 1;	      
	      fsmn <= storeadsf_1;
	      if (counter != INITCTR) begin	      
		 //yenc <= 1;
		 //yse <= 1;
		 xenc <= 1;
		 xse <= 1;	   
   	      end
	   end	   
	end
	storeadsf_1: begin
	   if (pdi_valid) begin
	      seglenn <= seglen - 16;	      
	      pdi_ready <= 1;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;	      
	      fsmn <= storeadsf_2;
	   end	   	   
	end
	storeadsf_2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;	      
	      fsmn <= storeadsf_3;
	   end	   	   
	end
	storeadsf_3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;	      
	      fsmn <= storeadsf_4;
	   end	   	   
	end
	storeadsf_4: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;	      
	      if (seglen == 0) begin
		 nonce_domainn <= adfinal;		 
		 domain <= adnormal;	
	      end
	      else begin
		 domain <= adnormal;	
	      end	      
	      //zenc <= 1;	      
	      //zse <= 1;
	      correct_cntn <= 1;	      
	      erst <= 1;	      
	      fsmn <= encryptad;
	   end	   	   
	end
	storeadtfsp_1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      seglenn <= seglen - 16;
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtfsp_2;
	   end	   
	end
	storeadtfsp_2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtfsp_3;
	   end	   
	end
	storeadtfsp_3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;	      
	      fsmn <= storeadtfsp_4;
	   end	   
	end
	storeadtfsp_4: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      //zenc <= 1;
	      //zse <= 1;
	      correct_cntn <= 1;	      
	      if (seglen == 0) begin
		 fsmn <= nonceheader;
		 nonce_domainn <= adfinal;
	      end
	      else begin
		 fsmn <= storeadsp_1;
	      end
	   end	   
	end
	storeadsp_1: begin
	   if (pdi_valid) begin	      
	      pdi_ready <= 1;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;		 
	      fsmn <= storeadsp_2;
	   end	   	   
	end
	storeadsp_2: begin
	   if (seglen[3:0] > 4) begin
	      if (pdi_valid) begin	      
		 pdi_ready <= 1;	      
		 yenc <= 1;
		 yrst <= 1;
		 yse <= 1;		 
		 fsmn <= storeadsp_3;
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;		 
	      fsmn <= storeadsp_3;
	   end
	end
	storeadsp_3: begin
	   if (seglen[3:0] > 8) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 yenc <= 1;
		 yrst <= 1;
		 yse <= 1;
		 if (c2 == 1) begin		 
		    domain <= nonce_domain;		      
		    zenc <= 1;
		    zse <= 1;
		    correct_cntn <= 1;
		    c2n <= 0;		    
		 end		 		 
		 fsmn <= storeadsp_4;
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;
	      if (c2 == 1) begin		 
		 domain <= nonce_domain;		      
		 zenc <= 1;
		 zse <= 1;
		 correct_cntn <= 1;
		 c2n <= 0;		    
	      end		 	      
	      fsmn <= storeadsp_4;
	   end
	end
	storeadsp_4: begin
	   seglenn <= 0;
	   if (seglen[3:0] > 12) begin
	      if (pdi_valid) begin
		 pdi <= pdi_data | {28'h0,seglen[3:0]};	      		 
		 pdi_ready <= 1;	      
		 yenc <= 1;
		 yrst <= 1;
		 yse <= 1;		 
		 domain <= adnormal;
		 nonce_domainn <= adpadded;		 
		 zenc <= 1;
		 zse <= 1;
		 correct_cntn <= 1;	      
		 if (counter != INITCTR) begin		 
		    //yenc <= 1;
		    //yse <= 1;
		    xenc <= 1;
		    xse <= 1;
		 end	      		 
		 erst <= 1;	                		 
		 fsmn <= encryptad;
	      end
	   end
	   else begin
	      pdi <= {28'h0,seglen[3:0]};	      
	      yenc <= 1;
	      yrst <= 1;
	      yse <= 1;		 
	      domain <= adnormal;
	      nonce_domainn <= adpadded;	
	      zenc <= 1;
	      zse <= 1;
	      correct_cntn <= 1;	      
	      if (counter != INITCTR) begin
		 //yenc <= 1;
		 //yse <= 1;
		 xenc <= 1;
		 xse <= 1;	   
	      end   	      
	      erst <= 1;	           		 	      
	      fsmn <= encryptad;
	   end
	end
	storeadtps0_1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtps0_2;
	   end	   
	end
	storeadtps0_2: begin
	   if (seglen[3:0] > 4) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 fsmn <= storeadtps0_3;
	      end
	   end
	   else begin
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtps0_3;
	      pdi <= 0;	      
	   end
	end
	storeadtps0_3: begin
	   if (seglen[3:0] > 8) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 fsmn <= storeadtps0_4;
	      end
	   end
	   else begin
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadtps0_4;
	      pdi <= 0;	      
	   end
	end
	storeadtps0_4: begin
	   seglenn <= 0;
	   nonce_domainn <= adpadded;	   	   
	   if (seglen[3:0] > 12) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 //zenc <= 1;
		 //zse <= 1;
		 correct_cntn <= 1;	      
		 fsmn <= nonceheader;
		 pdi <= pdi_data | {28'h0,seglen[3:0]};
		 if (counter != INITCTR) begin
		    //yenc <= 1;
		    //yse <= 1;
		    xenc <= 1;
		    xse <= 1;	
		 end      	   	      		 
	      end	      
	   end // if (seglen[3:0] > 12)
	   else begin
	      senc <= 1;
	      sse <= 1;
	      //zenc <= 1;
	      //zse <= 1;
	      correct_cntn <= 1;	      
	      fsmn <= nonceheader;
	      pdi <= {28'h0,seglen[3:0]};
	      if (counter != INITCTR) begin
		 //yenc <= 1;
		 //yse <= 1;
		 xenc <= 1;
		 xse <= 1;	
	      end      	   	      
	   end // else: !if(pdi_valid)
	end // case: storetps0_4
	encryptad: begin
	   correct_cntn <= 0;
	   tk1sn <= ~tk1s;	   
	   senc <= 1;
	   xenc <= 1;
	   yenc <= 1;
	   zenc <= tk1s;	
	   if (constant == FINCONST) begin
	      //pdi_ready <= 1;	      
	      if (seglen == 0) begin
		 if (flags[1] == 1) begin
		    fsmn <= nonceheader;
		    st0n <= 1;
		    c2n <= 0;
		    
		 end
		 else begin
		    fsmn <= adheader;
		    c2n <= 1;		    
		 end
	      end
	      else if (seglen < 16) begin
		 fsmn <= storeadtps0_1;
		 st0n <= 0;
		 c2n <= 1;		    
	      end	      
	      else if (seglen < 32) begin
		 fsmn <= storeadtfsp_1;
		 c2n <= 1;		    
		 if (seglen == 16) begin
		    st0n <= 0;		
		 end
		 else begin
		    st0n <= 1;		    
		 end    
	      end
	      else begin
		 c2n <= 1;		    
		 fsmn <= storeadtfsf_1;
		 st0n <= 1;		 
	      end
	   end
	end // case: encryptad
	store0_1: begin
	   pdi <= 0;
	   senc <= 1;
	   sse <= 1;
	   fsmn <= store0_2;	   
	end
	store0_2: begin
	   pdi <= 0;
	   senc <= 1;
	   sse <= 1;
	   fsmn <= store0_3;	   
	end
	store0_3: begin
	   pdi <= 0;
	   senc <= 1;
	   sse <= 1;
	   fsmn <= store0_4;	   
	end
	store0_4: begin
	   pdi <= 0;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;
	   domain <= adnormal;
	   nonce_domainn <= adpadded;	
	   //zenc <= 1;
	   //zse <= 1;
	   if (counter != INITCTR) begin
	      yenc <= 1;
	      yse <= 1;
	      xenc <= 1;
	      xse <= 1;	
	   end      	   
	   fsmn <= encryptnonce;	   
	end
	encryptnonce: begin
	   correct_cntn <= 0;
	   tk1sn <= ~tk1s;	   
	   senc <= 1;
	   xenc <= 1;
	   yenc <= 1;
	   zenc <= tk1s;	
	   if (constant == FINCONST) begin
	      zenc <= 1;	   
	      zrst <= 1;
	      correct_cntn <= 1;	      
	      zse <= 1;	   
	      fsmn <= msgheader;
	      pdi_ready <= 1;	      
	   end
	end
	msgheader: begin
	   if (pdi_valid) begin
	      if ((pdi_data[31:28] == PLAIN) || (pdi_data[31:28] == CIPHER)) begin
		 pdo_valid <= 1;
		 if (dec) begin
		    pdo_data <= {PLAIN, pdi_data[27:0]};
		 end
		 else begin
		    pdo_data <= {CIPHER, pdi_data[27:0]};
		 end
		 if (pdo_ready) begin
		    pdi_ready <= 1;
		    seglenn <= pdi_data[15:0];
		    flagsn <= pdi_data[27:24];		 
		    /*if (pdi_data[15:0] == 0) begin
		       if (dec) begin
			  fsmn <= verifytag0;
		       end
		       else begin
			  fsmn <= outputtag0;
		       end
		    end
		    else*/
		    if (pdi_data[15:0] < 16) begin
		       fsmn <= storemp_1;		    
		    end
		    else begin
		       fsmn <= storemf_1;		    
		    end
		 end // if (pdo_ready)		 
	      end // if (pdi_data[31:28] == PLAIN)	      	      
	   end // if (pdi_valid)
	   else begin
	      pdi_ready <= 1;
	   end
	end // case: msgheader
	storemp_1: begin
	   if (pdi_valid) begin	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;	      
	      case (seglen[3:0])
		0: begin
		   pdi <= 32'h0;
		   pdo_valid <= 0;
		end
		1: begin
		   pdo_data <= {pdo[31:24], 24'h0};
		   pdo_valid <= 1;
		   if (dec) begin
		      decrypt <= 4'h8;		      
		   end		   
		end
		2: begin
		   pdo_data <= {pdo[31:16], 16'h0};
		   pdo_valid <= 1;
		   if (dec) begin
		      decrypt <= 4'hC;		      
		   end		   
		end
		3: begin
		   pdo_data <= {pdo[31:8], 8'h0};
		   pdo_valid <= 1;
		   if (dec) begin
		      decrypt <= 4'hE;		      
		   end		   
		end
		default: begin
		   pdo_data <= pdo;
		   pdo_valid <= 1;
		   if (dec) begin
		      decrypt <= 4'hF;		      
		   end		   		   
		end
	      endcase // case (seglen[3:0])	     
	      if (pdo_ready) begin
		 fsmn <= storemp_2;
	      end
	   end	   	   
	end
	storemp_2: begin
	   if (seglen[3:0] > 4) begin
	      if (pdi_valid) begin	      
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 case (seglen[3:0]) 
		   5: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		      if (dec) begin
			 decrypt <= 4'h8;		      
		      end		   		      
		   end
		   6: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		      if (dec) begin
			 decrypt <= 4'hC;		      
		      end		   
		   end
		   7: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		      if (dec) begin
			 decrypt <= 4'hE;		      
		      end		   
		   end
		   default: begin
		      pdo_data <= pdo;
		      if (dec) begin
			 decrypt <= 4'hF;		      
		      end		   
		   end
		 endcase // case (seglen[3:0])	     		 
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= storemp_3;
		 end
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemp_3;
	   end
	end
	storemp_3: begin
	   if (seglen[3:0] > 8) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 case (seglen[3:0]) 
		   9: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		      if (dec) begin
			 decrypt <= 4'h8;		      
		      end		   
		   end
		   10: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		      if (dec) begin
			 decrypt <= 4'hC;		      
		      end		   
		   end
		   11: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		      if (dec) begin
			 decrypt <= 4'hE;		      
		      end		   
		   end
		   default: begin
		      pdo_data <= pdo;
		      if (dec) begin
			 decrypt <= 4'hF;		      
		      end		   
		   end
		 endcase // case (seglen[3:0])	     		 
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= storemp_4;
		 end
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemp_4;
	   end
	end
	storemp_4: begin
	   seglenn <= 0;	   
	   if (seglen[3:0] > 12) begin
	      if (pdi_valid) begin
		 pdi <= pdi_data | {28'h0,seglen[3:0]};	      		 
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 domain <= msgpadded;	
		 zenc <= 1;
		 zse <= 1;
		 correct_cntn <= 1;	      
		 yenc <= 1;
		 yse <= 1;
		 xenc <= 1;
		 xse <= 1;	      		 
		 erst <= 1;
		 case (seglen[3:0]) 
		   13: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		      if (dec) begin
			 decrypt <= 4'h8;		      
		      end		   
		   end
		   14: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		      if (dec) begin
			 decrypt <= 4'hC;		      
		      end		   
		   end
		   15: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		      if (dec) begin
			 decrypt <= 4'hE;		      
		      end		   
		   end
		   default: begin
		      pdo_data <= pdo;
		      if (dec) begin
			 decrypt <= 4'hF;		      
		      end		   
		   end
		 endcase // case (seglen[3:0])	     		 		 
		 pdo_data <= pdo;
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= encryptmsg;
		 end	      	      		 
	      end
	   end
	   else begin
	      pdi <= {28'h0,seglen[3:0]};	      
	      senc <= 1;
	      sse <= 1;
	      domain <= msgpadded;	
	      zenc <= 1;
	      zse <= 1;
	      correct_cntn <= 1;	      
	      yenc <= 1;
	      yse <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      
	      erst <= 1;
	      fsmn <= encryptmsg;	      
	   end // else: !if(seglen[3:0] > 12)
	end // case: storemp_4	
	storemf_1: begin
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end	   
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      
	      seglenn <= seglen - 16;	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_2;
	   end	   	   
	end
	storemf_2: begin
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end	   
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_3;
	   end	   	   
	end
	storemf_3: begin
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end	   
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_4;
	   end	   	   
	end
	storemf_4: begin
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end	   
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	     	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      if (seglen == 0) begin
		 domain <= msgfinal;	
	      end
	      else begin
		 domain <= msgnormal;	
	      end	      
	      zenc <= 1;
	      zse <= 1;
	      correct_cntn <= 1;	      
	      yenc <= 1;
	      yse <= 1;
	      xenc <= 1;
	      xse <= 1;	      
	      erst <= 1;	      
	      fsmn <= encryptmsg;
	   end	   	   
	end
	encryptmsg: begin
	   correct_cntn <= 0;
	   tk1sn <= ~tk1s;	   
	   senc <= 1;
	   xenc <= 1;
	   yenc <= 1;
	   zenc <= tk1s;	
	   if (constant == FINCONST) begin	      
	      if (seglen == 0) begin
		 if (flags[1] == 1) begin
		    if (dec) begin
		       fsmn <= verifytag0;
		    end
		    else begin
		       fsmn <= outputtag0;
		    end
		 end
		 else
		 end
		 else begin
		    fsmn <= msgheader;		    
		 end
	      end
	      else if (seglen < 16) begin
		 fsmn <= storemp_1;		 
	      end
	      else begin
		 fsmn <= storemf_1;		 
	      end
	   end
	end // case: encryptmsg
	outputtag0: begin
	   pdi <= 0;	   
	   pdo_valid <= 1;	   
	   pdo_data <= {TAG,4'h3,8'h0,16'h010};
	   if (pdo_ready) begin
	      fsmn <= outputtag1;	      
	   end
	end
	outputtag1: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   yenc <= 1;
	   yse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag2;	      
	   end	   
	end
	outputtag2: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   yenc <= 1;
	   yse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag3;	      
	   end	   
	end
	outputtag3: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   yenc <= 1;
	   yse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag4;	      
	   end	   
	end
	outputtag4: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   yenc <= 1;
	   yse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= idle;	      
	   end	   	   
	end // case: outputtag4
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
	      fsmn <= verifytag2;
	      if (pdo != 32'h0) begin
		 decn <= 0;		 
	      end
	   end
	end
	verifytag2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      fsmn <= verifytag3;
	      if (pdo != 32'h0) begin
		 decn <= 0;		 
	      end
	   end
	end
	verifytag3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      fsmn <= verifytag4;
	      if (pdo != 32'h0) begin
		 decn <= 0;		 
	      end
	   end
	end
	verifytag4: begin
	   if (pdi_valid) begin
	      if ((pdo != 32'h0) || (dec == 0)) begin
		 pdo_valid <= 1;
		 pdo_data <= {FAILURE, 28'h0};
		 if (pdo_ready) begin
		    pdi_ready <= 1;
		    fsmn <= idle;		  
		 end
	      end
	      else begin
		 pdo_valid <= 1;
		 pdo_data <= {SUCCESS, 28'h0};
		 if (pdo_ready) begin
		    pdi_ready <= 1;
		    fsmn <= idle;		  
		 end
	      end
	   end
	end
      endcase // case (fsm)      
	  


      
   end
   

   
endmodule // api
