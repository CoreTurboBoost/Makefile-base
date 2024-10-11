# Modify the following block for all projects.
BINARY=./bin/program
EXTRA_COPTS=
SRCEXT=.c
CODEDIRS=. src/
INCDIRS=. include/
LINKDIRS=. lib/
LINKFILES=example_link_file1 example_link_file2
LINKOPTS=# General link options that don't begin with -l or -L, such as -shared
DEFINES=EXAMPLE_DEFINE1=0 EXAMPLE_DEFINE2
WORKDIR=.# EMPTY to not prepend a working directory to all file paths

# Modify the following block, only if needed.
CC=gcc
OPT=-O0
SYMBOLS=-g# OR -s   to strip

# Generate files that encode make rules for the .h dependencies.
DEPFLAGS=-MP -MD
# Automatically add the -I onto each include directory
COPTS=-Wall -Wextra $(SYMBOLS) $(EXTRA_COPTS) $(foreach D,$(INCDIRS),-I$(D)) $(OPT) $(DEPFLAGS)

# Init default variable values, if they have no value set already.
P_WORKDIR=$(if $(WORKDIR),$(WORKDIR)/,$(WORKDIR))

# for-style iteration (foreach) and regular expression completions (wildcard)
CFILES=$(foreach D,$(CODEDIRS),$(wildcard $(P_WORKDIR)$(D)/*$(SRCEXT)))
P_LINKDIRS=$(foreach D,$(LINKDIRS),-L$(P_WORKDIR)$(D))
P_LINKFILES=$(foreach F,$(LINKFILES),-l$(F))
P_DEFINES=$(foreach D,$(DEFINES),-D$(D))

# Regular expression replacement
OBJECTS=$(patsubst %.c,%.o,$(CFILES))
DEPFILES=$(patsubst %.c,%.d,$(CFILES))

all: $(P_WORKDIR)$(BINARY)

$(P_WORKDIR)$(BINARY): $(OBJECTS)
	$(CC) -o $@ $^ $(P_LINKDIRS) $(LINKOPTS) $(P_LINKFILES)

# Compilation of .c files.
# Treat %.c as a list instead of a single string, thus $< instead of $^.
%.o:%.c
	$(CC) $(COPTS) $(P_DEFINES) -c -o $@ $<

clean:
	rm -f $(P_WORKDIR)$(BINARY) $(OBJECTS) $(DEPFILES)

# Package current state of project files into a archive file.
pack: clean
	tar zcvf dist.tgz *

# @ silences the printing of the command
# $(info ...) prints output
diff:
	$(info The status of the repository, and the volume of per-file changes:)
	@git status
	@git diff --stat

# Include the Makefile code for C header files.
-include $(DEPFILES)

# add .PHONY, so that the non-targetfile rules work, even if a file with the same name exists.
.PHONY: all clean pack diff

