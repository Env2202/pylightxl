## pylightxl project Makefile
##
## Cross-platform helper for:
## - Creating and using a virtual environment
## - Installing development dependencies
## - Running tests and linting
## - Running a small demo script
##
## Usage (Linux/macOS):
##   make help
##   make venv
##   make install
##   make test
##   make lint
##   make demo
##
## Usage (Windows, with Make available via e.g. Git Bash):
##   make help
##   make venv
##   make install
##   make test
##   make lint
##   make demo
##
## Activating the virtual environment (after `make venv`):
##   - Linux/macOS: `source .venv/bin/activate`
##   - Windows (cmd.exe): `.venv\Scripts\activate`
##   - Windows (PowerShell): `.venv\Scripts\Activate.ps1`

SHELL := /bin/sh

## ---------------------------------------------------------------------------
## Configuration
## ---------------------------------------------------------------------------

# Default virtual environment directory
VENV_DIR ?= .venv

# Base Python executable to create the venv and OS-specific venv Python path
ifeq ($(OS),Windows_NT)
	# On Windows, prefer the Python launcher if available
	PYTHON ?= py -3
	VENV_PYTHON := $(VENV_DIR)\Scripts\python.exe
else
	# On POSIX systems, prefer python3 but fall back to python if overridden
	PYTHON ?= python3
	VENV_PYTHON := $(VENV_DIR)/bin/python
endif

.PHONY: help venv install install-dev lint test demo clean distclean

## ---------------------------------------------------------------------------
## Help
## ---------------------------------------------------------------------------

help:
	@echo ""
	@echo "pylightxl Makefile targets"
	@echo "--------------------------"
	@echo "make venv       - Create a virtual environment in '$(VENV_DIR)'"
	@echo "make install    - Install pylightxl into the venv (editable) and test deps"
	@echo "make install-dev- Same as install (alias), kept for clarity"
	@echo "make test       - Run test suite with pytest"
	@echo "make lint       - Run flake8 linting similar to CI"
	@echo "make demo       - Run a small pylightxl demo script"
	@echo "make clean      - Remove Python cache files"
	@echo "make distclean  - Remove caches and the virtual environment"
	@echo ""
	@echo "Virtual environment activation (after 'make venv'):"
	@echo "  - Linux/macOS:    source $(VENV_DIR)/bin/activate"
	@echo "  - Windows cmd:    $(VENV_DIR)\Scripts\activate"
	@echo "  - Windows PowerShell:  $(VENV_DIR)\Scripts\Activate.ps1"
	@echo ""

## ---------------------------------------------------------------------------
## Virtual environment & installation
## ---------------------------------------------------------------------------

$(VENV_DIR):
	$(PYTHON) -m venv $(VENV_DIR)

venv: $(VENV_DIR)
	@echo "Virtual environment created at '$(VENV_DIR)'."
	@echo ""
	@echo "Activate it with:"
	@echo "  - Linux/macOS:    source $(VENV_DIR)/bin/activate"
	@echo "  - Windows cmd:    $(VENV_DIR)\Scripts\activate"
	@echo "  - Windows PowerShell:  $(VENV_DIR)\Scripts\Activate.ps1"

install: venv
	"$(VENV_PYTHON)" -m pip install --upgrade pip
	"$(VENV_PYTHON)" -m pip install -e .
	"$(VENV_PYTHON)" -m pip install pytest flake8
	@echo "Installation complete. Use 'make test' and 'make lint' to verify."

install-dev: install

## ---------------------------------------------------------------------------
## Quality: tests & lint
## ---------------------------------------------------------------------------

test:
	"$(VENV_PYTHON)" -m pytest

lint:
	@echo "Running flake8 similar to GitHub Actions..."
	"$(VENV_PYTHON)" -m flake8 . --exclude="$(VENV_DIR),.git" --count --select=E9,F63,F7,F82 --show-source --statistics
	"$(VENV_PYTHON)" -m flake8 . --exclude="$(VENV_DIR),.git" --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

## ---------------------------------------------------------------------------
## Demo
## ---------------------------------------------------------------------------

demo:
	@echo "Running pylightxl demo (creates 'demo.xlsx' in the current directory)..."
	"$(VENV_PYTHON)" -c "import pylightxl as xl; \
db = xl.Database(); \
db.add_ws(ws='Sheet1'); \
db.ws('Sheet1').update_index(row=1, col=1, val=10); \
db.ws('Sheet1').update_index(row=1, col=2, val=20); \
db.ws('Sheet1').update_index(row=2, col=1, val='hello'); \
db.ws('Sheet1').update_index(row=2, col=2, val='world'); \
xl.writexl(db=db, fn='demo.xlsx'); \
print('Demo workbook \"demo.xlsx\" written successfully.')"

## ---------------------------------------------------------------------------
## Maintenance
## ---------------------------------------------------------------------------

clean:
	@echo "Removing Python cache files..."
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -type f -delete 2>/dev/null || true

distclean: clean
	@echo "Removing virtual environment '$(VENV_DIR)'..."
	rm -rf "$(VENV_DIR)"

