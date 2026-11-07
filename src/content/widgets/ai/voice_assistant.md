---
title: Voice Assistant
description: A Flutter voice assistant UI with an animated waveform, a listening state, and a transcript.
app: core
path: /ai/voice_assistant
code_files: ["ai/voice_assistant.dart"]
---

## How it works

There's no microphone or speech code. `_listening` toggles from the mic `GestureDetector`, and the 24 bars are a fixed `sin` curve scaled by a repeating `AnimationController`, so the waveform has no connection to sound. The quoted transcript is a hardcoded string. `_c` also keeps running after the bars flatten to 8 px.

## Adapting it

- Start and stop a recogniser such as speech_to_text where `_listening` flips, and show partial results in place of the literal quote.
- Drive the bar height `h` from the recogniser's sound level instead of `_c.value`.
- Stop `_c` while `_listening` is false to avoid rebuilding the bars for nothing.
