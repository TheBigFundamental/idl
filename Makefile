.PHONY: all clean go py


PROTO_DIR=proto
TBF=tbf
TBF_DIR=$(PROTO_DIR)/$(TBF)

GO_DIR=go
GO_GITHUB_ROOT=github.com/thebigfundamental/idl/go
GO_SERVICE=$(patsubst $(TBF_DIR)%,$(GO_DIR)%,$(wildcard $(TBF_DIR)/*/))
GO_MODS=$(foreach d,$(GO_SERVICE),$(d)go.mod)

PY_DIR=py
PY_PACKAGE=$(patsubst $(PROTO_DIR)%,$(PY_DIR)%,$(wildcard $(TBF_DIR)/*/))
PY_INIT=$(foreach d,$(PY_PACKAGE),$(d)__init__.py)

all: go py

clean:
	rm -rf go/*
	rm -rf py/*

go: $(GO_MODS)

$(GO_DIR)/%/go.mod: $(TBF_DIR)/%/*.proto
	protoc --proto_path=$(PROTO_DIR) --go_out=./ --go-grpc_out=./ $^
	cd $(GO_DIR)/$(*) && rm go.mod && go mod init $(GO_GITHUB_ROOT)/$* && go mod tidy

py: $(PY_INIT) $(PY_DIR)/$(TBF)/__init__.py

$(PY_DIR)/$(TBF)/__init__.py:
	touch $@

$(PY_DIR)/$(TBF)/%/__init__.py: $(TBF_DIR)/%/*.proto
	python -m grpc_tools.protoc -I$(PROTO_DIR) --python_out=$(PY_DIR) --grpc_python_out=$(PY_DIR) $^
	touch $@
