# Project Proposal

## Project Title
Generating Unit Proofs from Unit Tests Using Large Language Models: A Factorial Design Study

## Project Description
In AutoUP, the main goal is to automatically generate unit proofs from a given codebase. AutoUP is designed as a pipeline of agents that work together to iteratively generate and improve unit proofs.

As part of that broader research direction, this project explores a side question related to unit tests. Since unit tests are widely adopted in software repositories, an important question is whether they can be used as input to generate unit proofs. In other words, instead of starting from the full codebase, this project studies whether unit tests alone contain enough information for a large language model (LLM) to generate useful unit proofs.

This project is formulated as a designed experiment. Each observation corresponds to one proof generation produced by an LLM under a specific experimental configuration. Because LLM outputs are stochastic, the experiment naturally allows replication by running multiple generations under the same treatment combination.

The purpose of the study is to evaluate how different controllable factors, such as the choice of model, temperature, and prompting strategy, affect the quality of the generated unit proofs.

## Research Questions
1. Can unit tests be used as effective inputs for generating unit proofs with LLMs?
2. How does the choice of LLM affect the quality of the generated unit proofs?
3. How do temperature and prompting strategies influence proof quality?
4. Which experimental factors have the largest impact on verification success and coverage?

## Possible Experimental Factors
The main factors that could be considered in the experiment include:

- **LLM model**: different models such as GPT, Gemini, or open-source alternatives
- **Temperature**: different generation temperatures to study output variability and stability
- **Prompting strategy**: different prompt engineering approaches, such as zero-shot, few-shot, or structured prompts
- **Amount of context provided**: for example, only the unit test versus the unit test plus relevant code context
- **Number of examples in the prompt**: no examples, one example, or multiple examples
- **Proof generation style**: concise instructions versus step-by-step instructions
- **Program or benchmark complexity**: simple versus complex targets
- **Type of unit test**: different categories of tests depending on their structure or intent

Not all of these factors need to be included in the final experiment. A smaller subset should be selected to keep the design manageable.

## Response Variables
The quality of the generated unit proofs will be measured using two automated response variables:

1. **Number of verification errors**, measured with CBMC  
   This response captures how many verification conditions fail for the generated unit proof.

2. **Coverage**, measured as a value between 0 and 1  
   This response captures how much of the relevant code is covered by the generated unit proof.

These two responses provide complementary views of proof quality: verification correctness and proof effectiveness.

## Methodology
A factorial design will be used to estimate the effect of the selected factors on the quality of the generated unit proofs. Since each treatment combination can be replicated multiple times, the experiment will provide degrees of freedom for estimating experimental error and for studying interaction effects among factors.

The analysis will focus on how the selected factors influence both the number of verification errors and the coverage achieved by the generated proof. These response variables will be analyzed separately in order to better understand the strengths and weaknesses of each treatment combination.

If necessary, nuisance sources of variability such as benchmark program, repository, or code complexity may be handled through blocking or controlled sampling.

## Expected Outcomes
This project is expected to provide evidence on whether unit tests can serve as a practical basis for generating unit proofs with LLMs. It should also identify which experimental settings lead to better performance in terms of verification success and coverage.

More broadly, the study aims to provide a rigorous and reproducible framework for evaluating LLM-based proof generation from unit tests.