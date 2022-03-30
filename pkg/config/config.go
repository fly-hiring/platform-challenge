package config

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"

	"github.com/fsnotify/fsnotify"
)

func NewConfigStore(path string) *ConfigStore {
	return &ConfigStore{path: path}
}

// ConfigStore manages reading and watching for changes to a config file
type ConfigStore struct {
	path string

	watcher  *fsnotify.Watcher
	updateCh chan Config
}

// StartWatcher begins monitoring the config file for changes.
func (c *ConfigStore) StartWatcher() (<-chan Config, error) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, err
	}

	if err := watcher.Add(c.path); err != nil {
		return nil, err
	}

	c.watcher = watcher

	ch := make(chan Config)
	c.updateCh = ch

	go func() {
		defer close(c.updateCh)
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				if event.Op&fsnotify.Write == fsnotify.Write {
					log.Println("config file modified")

					cfg, err := readConfigFile(event.Name)
					if err != nil {
						log.Printf("error loading config file %s: %s", event.Name, err)
					} else {
						ch <- cfg
					}
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Println("error watching config file:", err)
			}
		}
	}()

	return ch, nil
}

// Close stops monitoring for changes
func (c *ConfigStore) Close() error {
	if c.watcher != nil {
		defer func() {
			c.watcher = nil
		}()
		return c.watcher.Close()
	}
	return nil
}

// Read loads and validates the config file
func (c ConfigStore) Read() (Config, error) {
	return readConfigFile(c.path)
}

func readConfigFile(path string) (Config, error) {
	var cfg Config
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return cfg, fmt.Errorf("error reading config file: %w", err)
	}

	if err := json.Unmarshal(data, &cfg); err != nil {
		return cfg, fmt.Errorf("error loading config: %w", err)
	}

	if err := validateConfig(cfg); err != nil {
		return cfg, err
	}

	return cfg, nil
}

func validateConfig(cfg Config) error {
	ports := map[int]struct{}{}

	for _, app := range cfg.Apps {
		for _, port := range app.Ports {
			if _, ok := ports[port]; ok {
				return errors.New("invalid configuration - duplicate ports")
			}
			ports[port] = struct{}{}
		}
	}
	return nil
}

type Config struct {
	// Apps is the list of configured apps
	Apps []App
}

// App holds configuration for a single "App"
type App struct {
	// Name is a friendly name to assist in debugging
	Name string
	// Ports is the list of ports this app will respond to
	Ports []int
	// Targets is the list of backend targets this app will proxy to
	Targets []string
}
