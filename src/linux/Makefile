include ../common.mak

PROGRAM=$(PUMPKINOS)/pumpkin

OBJS=main.o

$(PROGRAM): $(OBJS)
	@echo Linking pumpkin
	@$(CC) -o $(PROGRAM) $(OBJS) -L$(BIN) -lpit -lpthread $(EXE_LDFLAGS)

clean:
	@rm -f $(PROGRAM) $(OBJS)
