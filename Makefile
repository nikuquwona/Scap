APP_NAME := Scap

.PHONY: build debug run clean

build:
	./scripts/build.sh release

debug:
	./scripts/build.sh debug

run:
	./scripts/run.sh debug

clean:
	rm -rf build
