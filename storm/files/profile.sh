#!/bin/bash

[[ ":$PATH:" == *":{{ storm_bin }}:"* ]] || export PATH=$PATH:{{ storm_bin }}
