Romulus is a submission to the [NIST lightweight competition](https://csrc.nist.gov/projects/lightweight-cryptography). You can find the v1.2 specifications [here](https://romulusae.github.io/romulus/Romulus.pdf) and the latest v1.3 specifications here.

Romulus is composed of 3 variants, each using the tweakable block cipher Skinny-128/384+ internally: 
- Romulus-N+, a nonce-based AE (NAE)
- Romulus-M+, a nonce misuse-resistant AE (MRAE)
- Romulus-H+, a hash function

# Team

- **[Tetsu Iwata](http://www.nuee.nagoya-u.ac.jp/labs/tiwata/)**, Nagoya University, Japan
- **[Mustafa Khairallah](https://www.mustafa-khairallah.com/)**, Nanyang Technological University, Singapore
- **[Kazuhiko Minematsu](https://www.nec.com/en/global/rd/people/kazuhiko_minematsu.html)**, NEC, Japan
- **[Thomas Peyrin](https://sites.google.com/site/thomaspeyrin/)**, Nanyang Technological University, Singapore

You can contact us on [remus-and-romulus@googlegroups.com](mailto:remus-and-romulus@googlegroups.com)


# Features

COMING SOON


# Rationale

COMING SOON


# Security

## Claims

COMING SOON

## Security Proofs

COMING SOON: N-mode, M-mode, Hash, RUP, 

## Third party analysis

A partial list of third party analysis of the Skinny tweakable block ciphers is present [on the Skinny website](https://sites.google.com/site/skinnycipher/security). 

One can observe that the Skinny tweakable block ciphers went through a lot of third-party analysis efforts since its publication, with more than 30 cryptanalysis papers after only 4 years. At early 2020, the best known attacks against Skinny-128/384 covers 28 rounds ([Zhao et al. 2019](https://eprint.iacr.org/2019/714)) out of 56 rounds. This means that the security margin of this primitive is at least of 50% and actually much more if one considers only single-key attacks and/or attacks with a complexity lower than 2<sup>128</sup>.

Indeed, all these attacks have very high complexity, much more than 2<sup>200</sup> in computational complexity and sometimes up to almost 2<sup>384</sup>, and only work in the related-tweakey model where differences need to also be inserted in the tweak and/or key input. In the single-key model, the best known attacks against Skinny-128/384 covers 22 rounds ([Tolba et al. 2016](https://eprint.iacr.org/2016/1115.pdf), [Shi et al. 2018](https://eprint.iacr.org/2018/813.pdf), [Chen et al. 2019](https://link.springer.com/chapter/10.1007/978-3-030-41579-2_14)), again all these attacks having a very high computational complexity. This represents a much larger security margin when compared to other (tweakable) block ciphers, or to most permutation-based AEAD designs, where non-random behaviour can be usually exhibited for the full-round internal primitive with a complexity lower than the targeted security parameter of the whole scheme. 

For this reason, the Skinny team decided to propose a new variant of Skinny-128/384 (named Skinny-128/384+) by reducing its number of rounds from 56 to 40, to give a security margin of around 30\% (in the worst-case related-tweakey scenario, without even excluding attacks with complexity much higher than 2<sup>128</sup>), which remains a very large security margin. This is the internal primitive we use in Romulus submission v1.3, in contrary to v1.2 which was using Skinny-128/384. More precisely, ROMULUS-N+ and ROMULUS-M+ share the exact same specifications as ROMULUS-N1 and ROMULUS-M1 (from version 1.2), except that the number of Skinny-128/384 rounds is reduced from 56 to 40. The security claims remained exactly the same, while they are expected to be around 1.4x faster than their counterparts for the same area cost. To simplify the submission, we decided to only keep these Skinny-128/384-based variants and remove the ones based on Skinny-128/256 from v1.2.


# Performances and implementations

## Hardware

COMING SOON

## Software
 
You can find reference implementations of Romulus in C and Python in [our Github repo](https://github.com/romulusae/romulus):

You can find optimized implementations of Romulus in the following Github repos: 
- [Alexandre Adomnicai](https://github.com/aadomn/skinny) - Cortex-M optimised implementations
- [Rhys Weatherley](https://github.com/rweather/lightweight-crypto) - Cortex-M and AVR optimised implementations 
