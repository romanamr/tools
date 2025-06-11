package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/google/go-github/v60/github"
	"golang.org/x/oauth2"
)

func runGitCommand(args ...string) error {
	fmt.Printf("🟢 Ejecutando: git %s\n", strings.Join(args, " "))
	cmd := exec.Command("git", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func getGitConfig(key string) string {
	out, err := exec.Command("git", "config", "--get", key).Output()
	if err != nil {
		fmt.Fprintf(os.Stderr, "⚠️  No se pudo obtener git config %s: %v\n", key, err)
		os.Exit(1)
	}
	return strings.TrimSpace(string(out))
}

func scan() string {
	reader := bufio.NewReader(os.Stdin)
	nombre, _ := reader.ReadString('\n')
	return strings.TrimSpace(nombre)
}

func main() {
	// Flags CLI
	titulo := flag.String("titulo", "", "Título del Pull Request")
	baseBranch := flag.String("base", "develop", "Nombre de la rama base")
	branchName := flag.String("branch", "", "Nombre de la rama a crear")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, `
Uso:
	git-draft-pr --branch nombre-rama --titulo "Título del Pull Request"

Opciones:
`)
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, `

Ejemplos:
	git draft-pr --branch mi-feature-123 --titulo "Agregar validación de emails"
	git draft-pr --branch bugfix-issue-77 --titulo "Fix en login"

Notas:
	- La rama base por defecto es "develop", se puede cambiar con --base.
	- Requiere que esté seteada la variable de entorno GITHUB_TOKEN.
`)
	}

	flag.Parse()

	if *branchName == "" {
		fmt.Print("Introduce el nombre de la rama: ")
		fmt.Scanln(branchName)
	}

	if *titulo == "" {
		fmt.Print("Introduce el título del Pull Request: ")
		tituloInput := scan()
		if tituloInput == "" {
			fmt.Println("❌ Debes proporcionar un título para el Pull Request")
			os.Exit(1)
		}
		*titulo = tituloInput
	}

	// Config personal
	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		fmt.Println("❌ Debes exportar tu token en el enviroment GITHUB_TOKEN=...")
		os.Exit(1)
	}

	repoURL := getGitConfig("remote.origin.url")
	slug := strings.TrimSuffix(strings.TrimPrefix(repoURL, "https://github.com/"), ".git")
	slug = strings.TrimPrefix(slug, "git@github.com:") // por si usa SSH

	parts := strings.Split(slug, "/")
	if len(parts) != 2 {
		fmt.Println("❌ No se pudo interpretar el owner/repo del remoto")
		os.Exit(1)
	}
	repoOwner := parts[0]
	repoName := parts[1]

	// Git commands
	if err := runGitCommand("checkout", *baseBranch); err != nil {
		os.Exit(1)
	}
	if err := runGitCommand("fetch", "origin"); err != nil {
		os.Exit(1)
	}
	if err := runGitCommand("pull"); err != nil {
		os.Exit(1)
	}
	if err := runGitCommand("checkout", "-b", *branchName); err != nil {
		os.Exit(1)
	}
	if err := runGitCommand("commit", "--allow-empty", "-m", *titulo); err != nil {
		os.Exit(1)
	}
	if err := runGitCommand("push", "-u", "origin", *branchName); err != nil {
		os.Exit(1)
	}

	// Crear PR vía API
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	newPR := &github.NewPullRequest{
		Title:               github.String(*titulo),
		Head:                github.String(*branchName),
		Base:                github.String(*baseBranch),
		Body:                github.String(*titulo),
		MaintainerCanModify: github.Bool(true),
		Draft:               github.Bool(true),
	}

	pr, _, err := client.PullRequests.Create(ctx, repoOwner, repoName, newPR)
	if err != nil {
		fmt.Printf("❌ Error al crear el PR: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("✅ Pull Request draft creado: %s\n", pr.GetHTMLURL())
}
