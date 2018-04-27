#
#  Makefile for Go
#
SHELL=/usr/bin/env bash
VERSION=$(shell git describe --tags --always)
PACKAGES = $(shell find ./ -type d | grep -v 'vendor' | grep -v '.git' | grep -v 'bin')

.PHONY: list
.PHONY: test-cover-html

default: build

build:
	go build ./cmd/speedtest -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-${VERSION}

clean:
	rm -f bin/speedtest*
	rm -f coverage-all.out
	rm -f coverage.out

vet:
	go vet ./cmd/...
	go vet ./internal/...

lint:
	golint ./cmd/...
	golint ./internal/...

fmt:
	gofmt -w ./cmd/speedtest
	gofmt -w ./internal/coords
	gofmt -w ./internal/misc
	gofmt -w ./internal/print
	gofmt -w ./internal/sthttp
	gofmt -w ./internal/stxml
	gofmt -w ./internal/tests

test:
	go test $(shell glide nv)

cover:
	go test -cover $(shell glide nv)

coverage:
	echo "mode: count" > coverage-all.out
	$(foreach pkg,$(PACKAGES),\
		go test -coverprofile=coverage.out -covermode=count $(pkg);\
		tail -n +2 coverage.out >> coverage-all.out;)
	go tool cover -html=coverage-all.out

cross:
	echo "Building darwin-amd64..."
	GOOS="darwin" GOARCH="amd64" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-mac-amd64-${VERSION}

	echo "Building windows-386..."
	GOOS="windows" GOARCH="386" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-32-${VERSION}.exe

	echo "Building windows-amd64..."
	GOOS="windows" GOARCH="amd64" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-64-${VERSION}.exe

	echo "Building freebsd-386..."
	GOOS="freebsd" GOARCH="386" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-freebsd-386-${VERSION}

	echo "Building linux-arm..."
	GOOS="linux" GOARCH="arm" go  build -o bin/speedtest-linux-arm-${VERSION}

	echo "Building linux-386..."
	GOOS="linux" GOARCH="386" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-linux-386-${VERSION}

	echo "Building linux-amd64..."
	GOOS="linux" GOARCH="amd64" go build -ldflags="-X main.Version=${VERSION}" -o bin/speedtest-linux-amd64-${VERSION}
