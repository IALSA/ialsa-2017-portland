# This script executes all manipulation scripts and walks you through data provisioniing chain.

# Phases of the workflow
# 0 - extract parameters from model objects and organize them into a catalog
# 1 - correct the spelling and grouping of model elementes
# 2 - compute additional variables
# 3 - tranform between wide and long format

# ---- physical-physical -----------------------------------------
# Physical-physical stream
base::source("./manipulation/physical-physical/0-parser.R") 
base::source("./manipulation/physical-physical/1-cleaner.R")
base::source("./manipulation/physical-physical/2-augmentor.R")
base::source("./manipulation/physical-physical/3-transformer.R")


# ---- physical-cognitive -----------------------------------------
# Physical-cognitive stream
# base::source("./manipulation/physical-cognitive/0-parser.R") # needs debugging. For now, inherit from IALSA-2015-
base::source("./manipulation/physical-cognitive/1-cleaner.R")
base::source("./manipulation/physical-cognitive/2-augmentor.R")
base::source("./manipulation/physical-cognitive/3-transformer.R")