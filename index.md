[<font size="+2.5">Team</font>](https://romulusae.github.io/romulus/#team) &nbsp; - - &nbsp; [<font size="+2.5">Features</font>](https://romulusae.github.io/romulus/#features) &nbsp; - - &nbsp; [<font size="+2.5">Rationale</font>](https://romulusae.github.io/romulus/#rationale) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/#security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/#performances-and-implementations) 

---

&nbsp;   

Romulus is a submission to the [NIST lightweight competition](https://csrc.nist.gov/projects/lightweight-cryptography), currently in the final round. You can find the latest v1.3 specifications [here](https://github.com/romulusae/romulus/blob/master/Romulusv1.3.pdf) (and the previous v1.2 specifications [here](https://github.com/romulusae/romulus/blob/master/Romulusv1.2.pdf)).

Romulus is composed of 4 variants, each using the tweakable block cipher Skinny-128/384+ internally:  
- Romulus-N, a nonce-based AEAD (NAE)  
- Romulus-M, a nonce misuse-resistant AEAD (MRAE)  
- Romulus-T, a leakage-resilient AEAD 
- Romulus-H, a hash function  

# Team

- **[Chun Guo](https://faculty.sdu.edu.cn/chun_guo_sk/en/index.htm)**, Shandong University, China
- **[Tetsu Iwata](http://www.nuee.nagoya-u.ac.jp/labs/tiwata/)**, Nagoya University, Japan
- **[Mustafa Khairallah](https://www.mustafa-khairallah.com/)**, Nanyang Technological University, Singapore
- **[Kazuhiko Minematsu](https://www.nec.com/en/global/rd/people/kazuhiko_minematsu.html)**, NEC, Japan
- **[Thomas Peyrin](https://sites.google.com/site/thomaspeyrin/)**, Nanyang Technological University, Singapore

You can contact us on [remus-and-romulus@googlegroups.com](mailto:remus-and-romulus@googlegroups.com)


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

- **Mode.** The Romulus-N mode is designed to simultaneously achieve rate 1 and a small state size. It is based on (a TBC variant of) [COFB](https://eprint.iacr.org/2017/649.pdf) by Chakraborty et al., although the team conducted a thorough revising/simplification to optimize its performance. In particular the algorithm is streamlined so that any redundant logic (e.g. multiplexers) is removed in hardware. The Romulus-M mode is a variant of [SIV](https://web.cs.ucdavis.edu/~rogaway/papers/siv.pdf) by Shrimpton and Rogaway, with certain performance boosts due to the use of TBC. It reuses Romulus-N mode, which enables a combined N/M implementation with a small overhead. Romulus-T is an update of the [TEDT construction](https://eprint.iacr.org/2019/137) from Berti et al., adapted to use Romulus-H as internal hash function. The Romulus-H is the [MDPH construction](https://link.springer.com/chapter/10.1007/978-3-030-30530-7_4) from Naito, which consists of Hirose’s well known [Double-Block-Length (DBL) compression function](https://www.iacr.org/archive/fse2006/40470213/40470213.pdf) plugged into the Merkle-Damgard with Permutation ([MDP](https://www.iacr.org/archive/asiacrypt2007/48330111/48330111.pdf)) domain extender.

- **Primitive.** We adopted Skinny for TBC, which has been published at CRYPTO 2016 and received extensive third-party security analysis (see below). More precicely, we use Skinny-128/384+ as only internal primitive, which consist of Skinny-128/384 with the number of rounds reduced from 56 to 40 (Skinny-128/384 having an extremly large security margin).


# Security

## Claims

Security claims of Romulus-N, Romulus-M and Romulus-T. NR denotes Nonce-Respecting adversary and NM denotes Nonce-Misusing adversary. In the table, n = 128 and small constant
factors are neglected. See submission document for the interpretations of these numbers.

| Member        | NR-Priv           | NR-Auth   | NM-Priv | NM-Auth |   
| ------------- |:-------------:|:-------------:|:-------------:|:-------------:|  
| Romulus-N      | n | n | - | - |   
| Romulus-M      | n | n | n/2 ∼ n | n/2 ∼ n |   
| Romulus-T     | n − log2(n) | n − log2(n) | - |  n − log2(n) |   


## Security Proofs

- Romulus-N. Suppose the adversary makes queries to both encryption and decryption oracles, with v verification queries, and t-bit tag (where t is in [1,n]), and S total queried blocks for both enc/dec queries. Then the so-called AE advantage is at most 3v/2^n + 2v/2^t plus computational security of the internal TBC accepting S queries. 

- Romulus-M. TODO

- Romulus-T. Security proofs of the TEDT mode are given in the [TEDT article](https://eprint.iacr.org/2019/137). TODO

- Romulus-H. Security proofs of the hashing mode are given in the [MDPH article](https://link.springer.com/chapter/10.1007/978-3-030-30530-7_4). TODO

For more details, see [our Transactions on Symmetric-key Cryptology 2020 paper](https://tosc.iacr.org/index.php/ToSC/article/view/8560/8131) or [our slides at the NIST LWC Worksop 2019](https://csrc.nist.gov/CSRC/media/Presentations/updates-on-romulus-remus-and-tgif/images-media/session9-minematsu-updates-romulus-remus-tgif.pdf).

## Third party analysis

A partial list of third party analysis of the Skinny tweakable block ciphers is present [on the Skinny website](https://sites.google.com/site/skinnycipher/security). 

One can observe that the Skinny tweakable block ciphers went through a lot of third-party analysis efforts since its publication, with more than 30 cryptanalysis papers after only 4 years. At early 2020, the best known attacks against Skinny-128/384 covers 28 rounds ([Zhao et al. 2019](https://eprint.iacr.org/2019/714)) out of 56 rounds. This means that the security margin of this primitive is at least of 50% and actually much more if one considers only single-key attacks and/or attacks with a complexity lower than 2<sup>128</sup>.

Indeed, all these attacks have very high complexity, much more than 2<sup>200</sup> in computational complexity and sometimes up to almost 2<sup>384</sup>, and only work in the related-tweakey model where differences need to also be inserted in the tweak and/or key input. In the single-key model, the best known attacks against Skinny-128/384 covers 22 rounds ([Tolba et al. 2016](https://eprint.iacr.org/2016/1115.pdf), [Shi et al. 2018](https://eprint.iacr.org/2018/813.pdf), [Chen et al. 2019](https://link.springer.com/chapter/10.1007/978-3-030-41579-2_14)), again all these attacks having a very high computational complexity. This represents a much larger security margin when compared to other (tweakable) block ciphers, or to most permutation-based AEAD designs, where non-random behaviour can be usually exhibited for the full-round internal primitive with a complexity lower than the targeted security parameter of the whole scheme. 

For this reason, the Skinny team decided to propose a new variant of Skinny-128/384 (named Skinny-128/384+) by reducing its number of rounds from 56 to 40, to give a security margin of around 30% (in the worst-case related-tweakey scenario, without even excluding attacks with complexity much higher than 2<sup>128</sup>), which remains a very large security margin. This is the internal primitive we use in Romulus submission v1.3, in contrary to v1.2 which was using Skinny-128/384. More precisely, Romulus-N and Romulus-M share the exact same specifications as Romulus-N1 and Romulus-M1 (from version 1.2), except that the number of Skinny-128/384 rounds is reduced from 56 to 40. The security claims remained exactly the same, while they are expected to be around 1.4x faster than their counterparts for the same area cost. To simplify the submission, we decided to only keep these Skinny-128/384-based variants and remove the ones based on Skinny-128/256 from v1.2.


# Performances and implementations

## Hardware

You can find VHDL implementation of Romulus in the hardware implementations section of [our Github repo](https://github.com/romulusae/romulus). 

## Software
 
You can find reference implementations of Romulus in C and Python, together with test vectors, in [our Github repo](https://github.com/romulusae/romulus).

You can find optimized implementations of Romulus in the following Github repos: 
- [Alexandre Adomnicai](https://github.com/aadomn/skinny) - Cortex-M and 32-bit optimised implementations
- [Rhys Weatherley](https://github.com/rweather/lightweight-crypto) - Cortex-M and AVR optimised implementations 


