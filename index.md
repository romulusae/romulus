[<font size="+2.5">Team</font>](https://romulusae.github.io/romulus/#team) &nbsp; - - &nbsp; [<font size="+2.5">Features</font>](https://romulusae.github.io/romulus/#features) &nbsp; - - &nbsp; [<font size="+2.5">Rationale</font>](https://romulusae.github.io/romulus/#rationale) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/#security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/#performances-and-implementations) 

---

&nbsp;   

Romulus is a submission to the [NIST lightweight competition](https://csrc.nist.gov/projects/lightweight-cryptography). You can find the v1.2 specifications [here](https://romulusae.github.io/romulus/Romulus.pdf) and the latest v1.3 specifications here.

Romulus is composed of 3 variants, each using the tweakable block cipher Skinny-128/384+ internally:  
- Romulus-N, a nonce-based AEAD (NAE)  
- Romulus-M, a nonce misuse-resistant AEAD (MRAE)  
- Romulus-H, a hash function  

In addition, we propose two leakage-resilient AEAD variants: Romulus-LR and Romulus-TEDT.  

