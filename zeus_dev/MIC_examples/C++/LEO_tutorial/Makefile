##******************************************************************************
##
##  Copyright (C) 2012 Intel Corporation. All Rights Reserved.
##
##  The source code contained or described herein and all
##  documents related to the source code ("Material") are owned by
##  Intel Corporation or its suppliers or licensors. Title to the
##  Material remains with Intel Corporation or its suppliers and
##  licensors. The Material is protected by worldwide copyright
##  laws and treaty provisions.  No part of the Material may be
##  used, copied, reproduced, modified, published, uploaded,
##  posted, transmitted, distributed,  or disclosed in any way
##  except as expressly provided in the license provided with the
##  Materials.  No license under any patent, copyright, trade
##  secret or other intellectual property right is granted to or
##  conferred upon you by disclosure or delivery of the Materials,
##  either expressly, by implication, inducement, estoppel or
##  otherwise, except as expressly provided in the license
##  provided with the Materials.
##
##******************************************************************************
## Content:
##      Intel(R) C++ Composer XE 2013 
##      Build for Sample LEO_tutorial
##******************************************************************************

NAME		=	tbo_sort
CC		=	icc
CXX		=	icpc
LD		=	icc
DEBUG		=
CFLAGS		+=	-openmp $(DEBUG)
CXXFLAGS	=	$(CFLAGS)
LDFLAGS		=	

EXE		=	$(NAME).out
CFILES		=	$(wildcard *.c)
CXXFILES	=	$(wildcard *.cpp)
OBJECTS		=	$(CFILES:.c=.o) $(CXXFILES:.cpp=.o)

help:
	@echo "Usage:"
	@echo "    Build with offload		: make mic"
	@echo "    Build without offload	: make no_mic"
	@echo "    Run   : "$(EXE)

mic : $(EXE)
	@echo "...."
	@echo "Build complete"
	@echo "Run : "$(EXE)

no_mic: CFLAGS	+= -no-offload
no_mic: mic

mic_debug : DEBUG	+= -g -traceback -O0
mic_debug : mic

$(EXE) : $(OBJECTS)
	$(LD) $^ $(CFLAGS) $(LDFLAGS) -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o : %.cpp
	$(CXX) $(CFLAGS) -c $< -o $@

clean :	
	rm -fr $(EXE) $(EXE:.out=MIC.out) \
	$(OBJECTS) $(OBJECTS:.o=MIC.o) \
	$(EXE:.out=.out.xnlog)
