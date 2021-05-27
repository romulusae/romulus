[<font size="+2.5">Home</font>](https://romulusae.github.io/romulus/) &nbsp; - - &nbsp; [<font size="+2.5">Specs/Features</font>](https://romulusae.github.io/romulus/specs) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/impl)  &nbsp; - - &nbsp; [<font size="+2.5">Contact</font>](https://romulusae.github.io/romulus/contact) 

&nbsp; &emsp; &emsp; [<font size="-1.0" color="green">Specifications</font>](https://romulusae.github.io/romulus/specs#specifications) &nbsp; - - &nbsp; [<font size="-1.0" color="green">Features</font>](https://romulusae.github.io/romulus/specs#features) &nbsp; - - &nbsp; [<font size="-1.0" color="green">Rationale</font>](https://romulusae.github.io/romulus/specs#rationale) 


---

&nbsp;   

# Specifications

Romulus is composed of 4 variants, each using the tweakable block cipher Skinny-128/384+ internally:  
- Romulus-N, a nonce-based AEAD (NAE)  
- Romulus-M, a nonce misuse-resistant AEAD (MRAE)  
- Romulus-T, a leakage-resilient AEAD 
- Romulus-H, a hash function  


![alt text](https://romulusae.github.io/romulus/docs/modeN_simplified.png "Romulus-N")
![alt text](https://romulusae.github.io/romulus/docs/modeM_simplified.png "Romulus-M")
![alt text](https://romulusae.github.io/romulus/docs/modeT.png "Romulus-T")
![alt text](https://romulusae.github.io/romulus/docs/modeH.png "Romulus-H")

# Features

Romulus is built on a **tweakable block cipher** (TBC), which is an extension of classical block cipher introduced by Liskov, Rivest and Wagner at Crypto 2003. Romulus adopts a mode of operation which was designed particularly with lightweight applications in mind. The underlying TBC is [Skinny](https://eprint.iacr.org/2016/660.pdf) proposed at CRYPTO 2016, a high security primitive specifically designed to be very efficient in constrained environments, and which received an important amount of third-party analysis since its publication. 

Romulus presents several interesting features: 

- **Small operating state size.**  The state size refers to the amount of working memory needed to implement the scheme. Romulus's state size is the same as what is needed to implement the TBC alone. It is essentially the minimum as a TBC-based mode. 

- **Rate-1 operation.** The speed of an operating mode can be measured by the rate, which is the number of input blocks processed per internal primitive call. Romulus-N has rate 1, thus it needs an n-bit block TBC call to process an n-bit message block, which is optimal. We also remark that, for associated data (AD) blocks it is even more efficient (i.e. it can process (n+t) bits by one TBC call of n-bit block and t-bit tweak). For Romulus-M it has rate below 1 (note: rate of 1 is impossible for MRAE secrutiy notion) but is superior to other known TBC modes. 

- **Small overhead for short messages.** There is no pre-processing TBC call that adds computation overhead. For example, when Romulus-N receives 1-block AD and 1-block message, the encryption takes only three TBC calls.  

- **Highly Reliable Security.** The security of Romulus (for N and M variants) is provably reduced to the computational security (TPRP security) of the TBC in the single-key model. This is called Standard Model Security. Unlike those based on (e.g.) random permutation model or ideal-cipher model, there is no gap between the security model and the instantiation. The security for Romulus-N/H is n bits for n=128, and for Romulus-M it has n-bit nonce-respecting security and n/2-bit nonce-misuse security. 

- **Misuse-resistant security.** Romulus-M is an MRAE and has a strong resistance against potential nonce repeat by adopting a variant of SIV/SCT structure. Moreover its security only gracefully degrades depending on the maximum repetition of nonce, from n bits to n/2-bit as mentioned above, which is a desirable feature for MRAE. 

- **leakage resiliance.** Romulus-T is an AEAD which offers full leakage-resistance: it limits the exploitability of physical leakages via side-channel attacks, even if these leakages happen during every message encryption and decryption operation. It is based on the provably secure TBC-based [TEDT construction](https://eprint.iacr.org/2019/137), which offers what is currently considered as the highest possible security notions in the presence of leakage, namely beyond birthday bound CIML2 and security against Chosen Ciphertext Attacks with nonce-misuse-resilience and Leakage using levelled implementations (CCAmL2). In addition, it provides beyond birthday bound black-box and leakage-resilient security guarantees. TEDT leads to an energy-efficient leakage-resilient solution as two TBCs are implemented: the first one needs strong and energy demanding protections against side-channel attacks but is used in a limited way, while the other only requires weak and energy-efficient protections and performs the bulk of the computation.

# Rationale

- **Operating modes.** The Romulus-N mode is designed to simultaneously achieve rate 1 and a small state size. It is based on (a TBC variant of) [COFB](https://eprint.iacr.org/2017/649.pdf) by Chakraborty et al., although the team conducted a thorough revising/simplification to optimize its performance. In particular the algorithm is streamlined so that any redundant logic (e.g. multiplexers) is removed in hardware. The Romulus-M mode is a variant of [SIV](https://web.cs.ucdavis.edu/~rogaway/papers/siv.pdf) by Shrimpton and Rogaway, with certain performance boosts due to the use of TBC. It reuses Romulus-N mode, which enables a combined N/M implementation with a small overhead. Romulus-T is an update of the [TEDT construction](https://eprint.iacr.org/2019/137) from Berti et al., adapted to use Romulus-H as internal hash function. The Romulus-H is the [MDPH construction](https://link.springer.com/chapter/10.1007/978-3-030-30530-7_4) from Naito, which consists of Hirose’s well known [Double-Block-Length (DBL) compression function](https://www.iacr.org/archive/fse2006/40470213/40470213.pdf) plugged into the Merkle-Damgard with Permutation ([MDP](https://www.iacr.org/archive/asiacrypt2007/48330111/48330111.pdf)) domain extender.

- **Internal primitive.** We adopted Skinny for TBC, which has been published at CRYPTO 2016 and received extensive third-party security analysis (see below). More precicely, we use Skinny-128/384+ as only internal primitive, which consist of Skinny-128/384 with the number of rounds reduced from 56 to 40 (Skinny-128/384 having an extremly large security margin).

