package structextractor
package main

import (
	"flag"
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
)

func main() {
	inputFile := flag.String("input", "", "Input Go file to process")
	outputFile := flag.String("output", "", "Output file (defaults to stdout)")
	flag.Parse()

	if *inputFile == "" {
		fmt.Fprintln(os.Stderr, "Error: -input flag is required")
		flag.Usage()
		os.Exit(1)
	}

	if err := processFile(*inputFile, *outputFile); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func processFile(inputPath, outputPath string) error {
	// Parse the input file
	fset := token.NewFileSet()
	node, err := parser.ParseFile(fset, inputPath, nil, parser.ParseComments)
	if err != nil {
		return fmt.Errorf("failed to parse file: %w", err)
	}

	// Filter declarations to keep only structs and remove functions
	filteredDecls := make([]ast.Decl, 0)
	
	for _, decl := range node.Decls {
		switch d := decl.(type) {
		case *ast.GenDecl:
			// Keep type declarations (which include structs), imports, and constants
			// Filter out individual specs if needed
			if d.Tok == token.TYPE || d.Tok == token.IMPORT || d.Tok == token.CONST || d.Tok == token.VAR {
				filteredDecls = append(filteredDecls, decl)
			}
		case *ast.FuncDecl:
			// Skip all function declarations
			continue
		}
	}

	// Update the AST with filtered declarations
	node.Decls = filteredDecls

	// Determine output destination
	var output *os.File
	if outputPath == "" {
		output = os.Stdout
	} else {
		// Create output directory if it doesn't exist
		if dir := filepath.Dir(outputPath); dir != "." {
			if err := os.MkdirAll(dir, 0755); err != nil {
				return fmt.Errorf("failed to create output directory: %w", err)
			}
		}
		
		output, err = os.Create(outputPath)
		if err != nil {
			return fmt.Errorf("failed to create output file: %w", err)
		}
		defer output.Close()
	}

	// Format and write the modified AST
	if err := format.Node(output, fset, node); err != nil {
		return fmt.Errorf("failed to format output: %w", err)
	}

	if outputPath != "" {
		fmt.Printf("Successfully extracted structs to: %s\n", outputPath)
	}

	return nil
}
