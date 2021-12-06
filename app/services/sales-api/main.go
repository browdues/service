package main

import (
	"fmt"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/BrowduesMan85/service/foundation/logger"
	"go.uber.org/automaxprocs/maxprocs"
	"go.uber.org/zap"
)

// build is the git version of this program. It is set using build flags in the makefile.
var build = "develop"

func main() {

	log, err := logger.New("SALES-API")

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	defer log.Sync()

	if err := run(log); err != nil {
		log.Errorw("startup", "ERROR", err)
		log.Sync()
		os.Exit(1)
	}
}

func run(log *zap.SugaredLogger) error {
	// =========================================================================
	// GOMAXPROCS

	// Set the correct number of threads for the service
	// based on what is available either by the machine or quotas.
	//
	// (nbrowdues) Force go to respect the number of threads available in docker.
	if _, err := maxprocs.Set(); err != nil {
		return fmt.Errorf("maxprocs: %w", err)
	}
	log.Infow("startup", "GOMAXPROCS", runtime.GOMAXPROCS(0))

	// Make a channel to listen for an interrupt or terminate signal from the OS.
	// Use a buffered channel because the signal package requires it.
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	return nil
}
