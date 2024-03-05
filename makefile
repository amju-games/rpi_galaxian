# rpi_galaxian - Raspberry Pi Galaxian
# Copyright (C) 2024 Juliet Colman 

# Flags for compiling
CXXFLAGS := -std=c++20 -Wall

# Target executable name
TARGET := rpigal
TEST_TARGET := tests_rpigal

# Source files directory
SRCDIR := source
TESTDIR := source/test
BUILDDIR := build
OBJDIR := $(BUILDDIR)/obj
DEPDIR := $(BUILDDIR)/dep

# Source files
SRCS := $(wildcard $(SRCDIR)/*.cpp)
TEST_SRCS := $(wildcard $(TESTDIR)/*.cpp)

# Object files
OBJS := $(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.o,$(SRCS))
TEST_OBJS := $(patsubst $(TESTDIR)/%.cpp,$(OBJDIR)/%.o,$(TEST_SRCS))

# Dependencies
DEPS := $(OBJS:.o=.d) $(TEST_OBJS:.o=.d)


# Platform detection
UNAME := $(shell uname)

ifeq ($(UNAME), Darwin) # macOS
    # Add Mac-specific flags or configurations if needed
    CXXFLAGS += -DMACOSX
    CXX := clang++
else ifeq ($(OS), Windows_NT) # Windows
    # Add Windows-specific flags or configurations if needed
else ifneq ("$(wildcard /proc/device-tree/model)","") # Raspberry Pi
    # Add Raspberry Pi-specific flags or configurations if needed
    CXXFLAGS += -DRASPBERRY_PI
    CXX := g++
endif

# Default rule
all: $(TARGET) $(TEST_TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(TEST_TARGET): $(TEST_OBJS) $(filter-out $(OBJDIR)/main.o,$(OBJS))
	$(CXX) $(CXXFLAGS) -o $@ $^

# Rule to compile source files into object files
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR) $(DEPDIR)
	$(CXX) $(CXXFLAGS) -MMD -MP -c -o $@ $<

$(OBJDIR)/%.o: $(TESTDIR)/%.cpp | $(OBJDIR) $(DEPDIR)
	$(CXX) $(CXXFLAGS) -MMD -MP -c -o $@ $<

$(OBJDIR) $(DEPDIR):
	mkdir -p $@

clean:
	@rm -rf $(TARGET) $(TEST_TARGET) $(BUILDDIR)

-include $(DEPS)

.PHONY: all clean

