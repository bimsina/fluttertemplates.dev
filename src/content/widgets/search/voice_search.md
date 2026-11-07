---
title: Voice Search
description: Mic button that pulses while listening, with a simulated transcript
app: core
path: /search/voice_search
code_files: ["search/voice_search.dart"]
---

## How it works

Simulated: there's no microphone access or speech recognition, and the page says so. `_startListening` repeats `_pulseController` and runs a `Timer.periodic` that reveals `_simulatedWords` one at a time into `_transcript`. When the phrase completes, or the mic is tapped again, `_stopListening` cancels the timer and stops the pulse, so nothing animates while idle. `AnimatedBuilder` only rescales its cached `child`. The transcript doesn't run a search.

## Adapting it

- Start and stop `speech_to_text` in those two methods, requesting microphone permission first.
- Update `_transcript` from its results instead of the timer.
- Submit the final transcript to your search.
