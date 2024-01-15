package main

import (
	"os"

	"github.com/taylormonacelli/fewbitsy"
)

func main() {
	code := fewbitsy.Execute()
	os.Exit(code)
}
