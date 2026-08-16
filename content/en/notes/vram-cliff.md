---
title: "On 8 GB you end up with one model per job"
description: "Fully resident on the GPU is 73–113 tok/s; one layer over and it is 7–21. Which side you land on is decided by how the KV cache grows, not by the size of the weights — and the model that holds a long context could not call tools."
summary: "How to choose a model for an 8 GB GPU, and why a 4B held more context than an 8B."
---

An RTX 3060 Ti, 8 GB of VRAM, running ollama. The first way I picked models
was to work out the VRAM from the parameter count and the quantisation.
That is not enough to predict anything.

## The cliff is four to ten times

The same prompt at ctx 8k:

| Model | tok/s | Resident on GPU |
|---|---|---|
| gemma3:4b | 111 | 100% |
| qwen2.5:7b | 83 | 100% |
| granite3.3:8b | 73 | 100% |
| gemma3:12b | 18 | 74% |
| gpt-oss:20b | 11 | 50% |
| phi4 (14B) | 6.9 | 64% |

Everything that fits lands between 73 and 113 tok/s. Everything that spills
by even a layer lands between 7 and 18. There is no middle: it does not
degrade in proportion to how far over you went.

gpt-oss:20b beats phi4 14B because it is a mixture of experts. Only some of
the weights are used per token, so the chance of hitting a layer that was
pushed to the CPU drops with it.

## The KV cache decides which side

Change only the context length and the order changes with it.

| Model | ctx 8k | ctx 32k |
|---|---|---|
| gemma3:4b | 111 tok/s · 4.43 GB | **113 tok/s · 4.95 GB** |
| qwen2.5:7b | 83 tok/s · 5.34 GB | 21 tok/s · 8.68 GB |
| granite3.3:8b | 73 tok/s · 7.18 GB | 7.8 tok/s · **13.89 GB** |

granite3.3 is an 8B and reaches 13.9 GB at 32k, half of it on the CPU.
gemma3 is a 4B and grows by half a gigabyte.

Gemma 3 makes most of its attention layers sliding-window and places a
global layer only every few layers, so the KV cache is sized by the window
rather than by the context. Quadrupling the context barely moves it. Every
layer in granite3.3 is global, so its cache grows with the length.

**Sizing by the weights alone gets this wrong.** For 32k the 4B is both
faster and safer than the 8B.

## The one that holds context cannot call tools

An agent framework wants the model to return a structured `tool_calls`
field. Given the same function definition:

| Model | Result |
|---|---|
| qwen2.5:7b | returns `tool_calls` |
| granite3.3:8b | returns `tool_calls` |
| gemma3:4b | ollama refuses — does not support tools |
| gemma3-tools:4b | returns a ` ```tool_call ` block as text |
| qwen2.5-coder:7b / 3b | nothing |

The derivative with *tools* in its name does not return the structured
form either; it leaves you parsing text. Neither do the code-specialised
ones, so **an agent that writes code and also calls tools cannot be built
on a coder model.**

So the model that runs 32k at 113 tok/s cannot call tools, and the models
that can call tools fall apart at 32k. 8 GB does not hold both.

## Which leaves four

| Job | Model | Measured at ctx 16k |
|---|---|---|
| Agents, tool calling | qwen2.5:7b | 83 tok/s · 6.30 GB |
| RAG generation | gemma3:4b | 113 tok/s · 4.60 GB |
| Code, long context | qwen2.5-coder:3b | 160 tok/s · 3.11 GB |
| Code, quality first | qwen2.5-coder:7b | 83 tok/s · 6.30 GB |

All four sit fully on the GPU. One model for everything was not available.

The plan before measuring was a single 8B or 12B; in place that is an
18 tok/s wait. Reading `size_vram` back from `/api/ps` at the context you
actually use settles it faster than any estimate.
