APP_NAME := Scap

.PHONY: build debug run package clean

build:
	./scripts/build.sh release

debug:
	./scripts/build.sh debug

run:
	./scripts/run.sh debug

package:
	./scripts/package.sh

clean:
	rm -rf build
