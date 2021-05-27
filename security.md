[<font size="+2.5">Home</font>](https://romulusae.github.io/romulus/) &nbsp; - - &nbsp; [<font size="+2.5">Specs/Features</font>](https://romulusae.github.io/romulus/specs) &nbsp; - - &nbsp; [<font size="+2.5">Security</font>](https://romulusae.github.io/romulus/security) &nbsp; - - &nbsp; [<font size="+2.5">Implementations</font>](https://romulusae.github.io/romulus/impl)  &nbsp; - - &nbsp; [<font size="+2.5">Contact</font>](https://romulusae.github.io/romulus/contact)   

                             [<font size="-1.0" color="green">Security Claims</font>](https://romulusae.github.io/romulus/security#security-claims) &nbsp; - - &nbsp; [<font size="-1.0" color="green">Security Proofs</font>](https://romulusae.github.io/romulus/security#security-proofs) &nbsp; - - &nbsp; [<font size="-1.0" color="green">Third party analysis</font>](https://romulusae.github.io/romulus/security#third-party-analysis) 

---

&nbsp;   

# Security Claims

Security claims of Romulus-N, Romulus-M and Romulus-T. NR denotes Nonce-Respecting adversary and NM denotes Nonce-Misusing adversary. In the table, n = 128 and small constant
factors are neglected. See submission document for the interpretations of these numbers.

| Member        | NR-Priv           | NR-Auth   | NM-Priv | NM-Auth |   
| ------------- |:-------------:|:-------------:|:-------------:|:-------------:|  
| Romulus-N      | n | n | - | - |   
| Romulus-M      | n | n | n/2 ∼ n | n/2 ∼ n |   
| Romulus-T     | n − log2(n) | n − log2(n) | - |  n − log2(n) |   

Security claims of Romulus-H. In the table, n = 128 and small constant factors are neglected.

| Member        | Collision           | Preimage   | 2nd Preimage |   
| ------------- |:-------------:|:-------------:|:-------------:|   
| Romulus-H      | n − log2(n) | n − log2(n) | n − log2(n) |   


# Security Proofs

- Romulus-N. Suppose the adversary makes queries to both encryption and decryption oracles, with v verification queries, and t-bit tag (where t is in [1,n]), and S total queried blocks for both enc/dec queries. Then the so-called AE advantage is at most 3v/2^n + 2v/2^t plus computational security of the internal TBC accepting S queries. 

- Romulus-M. TODO

- Romulus-T. Security proofs of the TEDT mode are given in the [TEDT article](https://eprint.iacr.org/2019/137). TODO

- Romulus-H. Security proofs of the hashing mode are given in the [MDPH article](https://link.springer.com/chapter/10.1007/978-3-030-30530-7_4). TODO


# Third party analysis

A partial list of third party analysis of the Skinny tweakable block ciphers is present [on the Skinny website](https://sites.google.com/site/skinnycipher/security). 

One can observe that the Skinny tweakable block ciphers went through a lot of third-party analysis efforts since its publication, with more than 30 cryptanalysis papers after only 4 years. At early 2020, the best known attacks against Skinny-128/384 covers 28 rounds ([Zhao et al. 2019](https://eprint.iacr.org/2019/714)) out of 56 rounds. This means that the security margin of this primitive is at least of 50% and actually much more if one considers only single-key attacks and/or attacks with a complexity lower than 2<sup>128</sup>.

Indeed, all these attacks have very high complexity, much more than 2<sup>200</sup> in computational complexity and sometimes up to almost 2<sup>384</sup>, and only work in the related-tweakey model where differences need to also be inserted in the tweak and/or key input. In the single-key model, the best known attacks against Skinny-128/384 covers 22 rounds ([Tolba et al. 2016](https://eprint.iacr.org/2016/1115.pdf), [Shi et al. 2018](https://eprint.iacr.org/2018/813.pdf), [Chen et al. 2019](https://link.springer.com/chapter/10.1007/978-3-030-41579-2_14)), again all these attacks having a very high computational complexity. This represents a much larger security margin when compared to other (tweakable) block ciphers, or to most permutation-based AEAD designs, where non-random behaviour can be usually exhibited for the full-round internal primitive with a complexity lower than the targeted security parameter of the whole scheme. 

For this reason, the Skinny team decided to propose a new variant of Skinny-128/384 (named Skinny-128/384+) by reducing its number of rounds from 56 to 40, to give a security margin of around 30% (in the worst-case related-tweakey scenario, without even excluding attacks with complexity much higher than 2<sup>128</sup>), which remains a very large security margin. This is the internal primitive we use in Romulus submission v1.3, in contrary to v1.2 which was using Skinny-128/384. More precisely, Romulus-N and Romulus-M share the exact same specifications as Romulus-N1 and Romulus-M1 (from version 1.2), except that the number of Skinny-128/384 rounds is reduced from 56 to 40. The security claims remained exactly the same, while they are expected to be around 1.4x faster than their counterparts for the same area cost. To simplify the submission, we decided to only keep these Skinny-128/384-based variants and remove the ones based on Skinny-128/256 from v1.2.
