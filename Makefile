TARGET ?= main
BUILD_DIR = build
PACKAGE_DIR = pkg

P_DIR = ${BUILD_DIR}/lib
T_DIR = ${BUILD_DIR}/${TARGET}
BIN = ${T_DIR}/${TARGET}

# colors
CLR_AS    = \033[1;34m
CLR_CC    = \033[1;32m
CLR_LINK  = \033[1;36m
CLR_CLEAN = \033[1;31m
CLR_RESET = \033[0m


.PHONY: all clean
.SILENT:

all: ${BIN}

# build/
${T_DIR}:
	mkdir -p $@

${P_DIR}:
	mkdir -p $@

# main
${BIN}: ${P_DIR}/macro.o ${BIN}.o | ${T_DIR} ${P_DIR}
	@echo "  ${CLR_LINK}LINK${CLR_RESET}    $@"
	gcc -static -g $^ -o $@ -m32 -no-pie -Wl,--no-warn-execstack,--no-warn-rwx-segments

# main.o
${BIN}.o: ${TARGET}.asm | ${T_DIR} ${P_DIR}
	@echo "  ${CLR_AS}AS${CLR_RESET}      $<"
	nasm -f elf32 -o $@ $<

# macro.o
${P_DIR}/macro.o: ${PACKAGE_DIR}/macro.c | ${T_DIR} ${P_DIR}
	@echo "  ${CLR_CC}CC${CLR_RESET}      $<"
	gcc -g -c $< -o $@ -m32 -no-pie -Wl,--no-warn-execstack

clean:
	@echo "  ${CLR_CLEAN}CLEAN${CLR_RESET}   ${BUILD_DIR}"
	rm -rf ${T_DIR}