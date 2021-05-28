[<font size="+2.5">Home</font>](https://romulusae.github.io/romulus/) &nbsp; - - &nbsp; [<font size="+2.5">Specs/Features</font>](https://romulusae.github.io/romulus/specs) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/impl)  &nbsp; - - &nbsp; [<font size="+2.5">Contact</font>](https://romulusae.github.io/romulus/contact) 

&nbsp; &nbsp;    

---

&nbsp;   

Romulus is a submission to the [NIST lightweight competition](https://csrc.nist.gov/projects/lightweight-cryptography), currently in the final round. You can find the latest v1.3 specifications [here](https://romulusae.github.io/romulus/docs/Romulusv1.3.pdf) (and the previous v1.2 specifications [here](https://romulusae.github.io/romulus/docs/Romulusv1.2.pdf)). You can also check: 
* our Transactions on Symmetric-key Cryptology 2020 [paper](https://tosc.iacr.org/index.php/ToSC/article/view/8560/8131) and corresponding [talk](https://www.youtube.com/watch?v=3ML5g8tnP6A&ab_channel=TheIACR) at FSE 2020
* our NIST LWC Worksop 2020 [paper](https://csrc.nist.gov/CSRC/media/Events/lightweight-cryptography-workshop-2020/documents/papers/new-results-romulus-lwc2020.pdf) and [slides](https://csrc.nist.gov/CSRC/media/Presentations/new-results-on-romulus/images-media/session-2-peyrin-new-results-rolmulus.pdf)
* our NIST LWC Worksop 2019 [paper](https://csrc.nist.gov/CSRC/media/Events/lightweight-cryptography-workshop-2019/documents/papers/updates-on-romulus-remus-tgif-lwc2019.pdf) and [slides](https://csrc.nist.gov/CSRC/media/Presentations/updates-on-romulus-remus-and-tgif/images-media/session9-minematsu-updates-romulus-remus-tgif.pdf)

Romulus is composed of 4 variants, each using the tweakable block cipher Skinny-128/384+ internally:  
- Romulus-N, a nonce-based AEAD (NAE)  
- Romulus-M, a nonce misuse-resistant AEAD (MRAE)  
- Romulus-T, a leakage-resilient AEAD 
- Romulus-H, a hash function  

