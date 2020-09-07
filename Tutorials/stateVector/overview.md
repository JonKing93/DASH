---
layout: simple_layout
title: stateVector Overview
---

# Overview

The stateVector class helps design and build a state vector ensemble from data stored in .grid files. There are two parts to this process. Part 1 is the design phase: in this stage you will add variables to a state vector and design them to follow whatever specifications you require. Part 2 is the build phase: here, the design is finalized and a state vector ensemble is constructed from the design template.

Note that data is not loaded and processed until the very end of these two steps. The stateVector class is written to help you design a template for a state vector; it does not manipulate large loaded data arrays. This way, the final state vector ensemble can be built with a minimum of data loading and processing.

[Previous](welcome)   [Next](concepts)
