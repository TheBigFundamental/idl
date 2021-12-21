.PHONY: all clean go py

GITHUB_ROOT=github.com/TheBigFundamental/idl/go

PROTO_DIR=proto
TBF_DIR=$(PROTO_DIR)/tbf

GO_DIR=go
PY_DIR=py

SERVICE=$(patsubst $(TBF_DIR)%,$(GO_DIR)%,$(wildcard $(TBF_DIR)/*/))
GO_MODS=$(foreach d,$(SERVICE),$(d)go.mod)

all: go py

clean:
	rm -rf go/*
	rm -rf py/*

go: $(GO_MODS)

$(GO_DIR)/%/go.mod: $(TBF_DIR)/%/*.proto
	protoc --proto_path=$(PROTO_DIR) --go_out=./ --go-grpc_out=./ $^
	cd $(GO_DIR)/$(*) && go mod init $(GITHUB_ROOT)/$* && go mod tidy

py: $(SERVICE)
	python -m grpc_tools.protoc -I$(PROTO_DIR) --python_out=$(PY_DIR) --grpc_python_out=$(PY_DIR) $(PROTO_FILES)
