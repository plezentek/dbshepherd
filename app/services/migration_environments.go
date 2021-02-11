// Copyright 2021 Plezentek, Inc. All rights reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package services

import (
	"strings"

	"github.com/spf13/pflag"
	"github.com/spf13/viper"
	yaml "gopkg.in/yaml.v2"
	"k8s.io/klog"
)

type MigrationEnvironment struct {
	Name     string
	Source   string
	Database string
}

type MigrationEnvironments struct {
	Environments []MigrationEnvironment
}

func BuildEnvironments(fs *pflag.FlagSet, viper *viper.Viper) *MigrationEnvironments {
	var out MigrationEnvironments
	if fs.Changed("env") {
		// Env flag can be repeated to add multiple environments.  Each flag
		// instance is an inline YAML dictionary mapping a single key, the
		// environment name, to a list of two uris, first the source uri, then
		// the database uri
		// Example: --env 'prod: [uri1, uri2]' --env 'dev: [uri3, uri4]'
		raw, err := fs.GetStringArray("env")
		if err != nil {
			klog.Errorf("Internal error parsing env flag: %s", err)
			return nil
		}
		for _, v := range raw {
			var env map[string][]string
			if err := yaml.Unmarshal([]byte(v), &env); err == nil && len(env) == 1 {
				for name, uris := range env {
					if len(uris) != 2 {
						klog.Errorf("Internal error parsing env flag, found %d uris instead of 2", len(uris))
						return nil
					}
					out.Environments = append(out.Environments, MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
				}
			} else if err != nil {
				klog.Errorf("Internal error parsing env flag: %s", err)
				return nil
			} else {
				klog.Errorf("Internal error parsing env flag, found %d entries instead of 1", len(env))
				return nil
			}
		}
	} else {
		if viper.InConfig("environments") {
			// Environments config entry expects a dictionary where each key is
			// an environment name and each value is a list of two uris, the
			// source uri followed by the database uri.
			// Example:
			// environments:
			//   prod:
			//   - uri1
			//   - uri2
			//   dev:
			//   - uri3
			//   - uri4
			var environments map[string][]string
			if err := viper.UnmarshalKey("environments", &environments); err == nil {
				for name, uris := range environments {
					if len(uris) != 2 {
						klog.Errorf("Internal error parsing environments in config file, found %d uris instead of 2", len(uris))
						return nil
					}
					out.Environments = append(out.Environments, MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
				}
			} else {
				klog.Errorf("Internal error parsing config file: %s", err)
				return nil
			}
		} else {
			// DBS_ENVIRONMENTS environment variable expects a YAML list of
			// dictionaries. Each dictionary has one key only where the key is
			// the name of the environment and the value is a list of two uris,
			// the source uri followed by the database uri.
			// Example: DBS_ENVIRONMENTS='[prod: [uri1, uri2], dev: [uri3, uri4]]'
			raw := viper.GetString("environments")
			var environments []map[string][]string
			if err := yaml.Unmarshal([]byte(raw), &environments); err == nil {
				for _, env := range environments {
					if len(env) != 1 {
						klog.Errorf("Internal error parsing environment variable, found %d keys in env dict instead of 1", len(env))
						return nil
					}
					for name, uris := range env {
						if len(uris) != 2 {
							klog.Errorf("Internal error parsing environments in config file, found %d uris instead of 2", len(uris))
							return nil
						}
						out.Environments = append(out.Environments, MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
					}
				}
			} else {
				klog.Errorf("Internal error parsing environment variable: %s", err)
				return nil
			}
		}
	}
	return &out
}

func EnvironmentsFromMaps(sources map[string]string, databases map[string]string) *MigrationEnvironments {
	environments := make([]MigrationEnvironment, len(sources))
	index := 0
	for env, source := range sources {
		environments[index] = MigrationEnvironment{Name: strings.ToLower(env), Source: source, Database: databases[env]}
		index++
	}
	return &MigrationEnvironments{environments}
}
