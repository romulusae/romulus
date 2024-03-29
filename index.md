[<font size="+2.5">Home</font>](https://romulusae.github.io/romulus/) &nbsp; - - &nbsp; [<font size="+2.5">Specs/Features</font>](https://romulusae.github.io/romulus/specs) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/impl)  &nbsp; - - &nbsp; [<font size="+2.5">Contact</font>](https://romulusae.github.io/romulus/contact) 

&nbsp; &nbsp;    

---

&nbsp;   

Romulus is a submission to the [NIST lightweight competition](https://csrc.nist.gov/projects/lightweight-cryptography), currently in the final round. You can find the latest v1.3 specifications [here](https://romulusae.github.io/romulus/docs/Romulusv1.3.pdf) (and the previous v1.2 specifications [here](https://romulusae.github.io/romulus/docs/Romulusv1.2.pdf)). You can also check: 
* our NIST LWC Worksop 2022 [slides](https://github.com/romulusae/romulus/raw/master/docs/NIST_LWC_2022.pdf)
* our Transactions on Symmetric-key Cryptology 2020 [paper](https://tosc.iacr.org/index.php/ToSC/article/view/8560/8131) and corresponding [talk](https://www.youtube.com/watch?v=3ML5g8tnP6A&ab_channel=TheIACR) at FSE 2020
* our NIST LWC Worksop 2020 [paper](https://csrc.nist.gov/CSRC/media/Events/lightweight-cryptography-workshop-2020/documents/papers/new-results-romulus-lwc2020.pdf) and [slides](https://csrc.nist.gov/CSRC/media/Presentations/new-results-on-romulus/images-media/session-2-peyrin-new-results-rolmulus.pdf)
* our NIST LWC Worksop 2019 [paper](https://csrc.nist.gov/CSRC/media/Events/lightweight-cryptography-workshop-2019/documents/papers/updates-on-romulus-remus-tgif-lwc2019.pdf) and [slides](https://csrc.nist.gov/CSRC/media/Presentations/updates-on-romulus-remus-and-tgif/images-media/session9-minematsu-updates-romulus-remus-tgif.pdf)
* **(NEW)** The third-party security analysis of the Romulus-N and Romulus-M operating modes by [Jooyoung Lee](https://cs.kaist.ac.kr/people/view?idx=536&kind=faculty&menu=167) (see document [here](https://romulusae.github.io/romulus/docs/Security_evaluation_Romulus_Jooyoung_Lee.pdf))
* **(NEW)** A new security proof for the MDPH mode used in Romulus-H ([ePrint](https://eprint.iacr.org/2021/1469) and [IET Info Sec](https://ietresearch.onlinelibrary.wiley.com/doi/full/10.1049/ise2.12058))
* **(NEW)** A security proof for the Romulus-T mode (see document [here](https://romulusae.github.io/romulus/docs/Romulus_T_proof.pdf))

Romulus is composed of 4 variants, each using the tweakable block cipher Skinny-128/384+ internally:  
- Romulus-N, a nonce-based AEAD (NAE)  
- Romulus-M, a nonce misuse-resistant AEAD (MRAE)  
- Romulus-T, a leakage-resilient AEAD 
- Romulus-H, a hash function  

