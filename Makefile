CC := gcc
BIN := asm/ul8_asm
FILE := asm/ul8_asm.c

all: $(BIN)

$(BIN): $(FILE)
	$(CC) $^ -o $@ -D DEBUG

release: $(FILE) 
	$(CC) $^ -o $(BIN)

clean:
	rm -rf $(BIN)