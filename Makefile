CC := gcc
BIN := ul8_asm
FILE := ul8_asm.c

all: $(BIN)

$(BIN): $(FILE)
	$(CC) $^ -o $@ -D DEBUG

release: $(FILE) 
	$(CC) $^ -o $(BIN)

clean:
	rm -rf $(BIN)