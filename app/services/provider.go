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
	"context"

	"github.com/google/wire"
	"github.com/plezentek/dbshepherd/app/grpc"
	"github.com/plezentek/dbshepherd/common"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
	yaml "gopkg.in/yaml.v2"
	"k8s.io/klog"
)

type cancelPair struct {
	ctx common.CancelContext
	fn  common.CancelFunction
}

func NewMigrationEnvironments(fs *pflag.FlagSet, appViper *viper.Viper) *common.MigrationEnvironments {
	var out common.MigrationEnvironments
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
					out.Environments = append(out.Environments, common.MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
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
					out.Environments = append(out.Environments, common.MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
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
						out.Environments = append(out.Environments, common.MigrationEnvironment{Name: name, Source: uris[0], Database: uris[1]})
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
func NewMigrationApiServer(
	ctx common.CancelContext,
	mes *common.MigrationEnvironments,
	hs *HealthService) *grpc.MigrationApiServer {
	return &grpc.MigrationApiServer{Environments: mes}
}

func NewHealthService(ctx common.CancelContext) *HealthService {
	reporter := make(chan bool, 1)
	checker := make(chan chan bool, 1)

	return &HealthService{Closer: ctx, Reporter: reporter, Checker: checker}
}

func NewWebServer(
	appViper *viper.Viper,
	ctx common.CancelContext,
	hs *HealthService,
	fs *pflag.FlagSet,
	mas *grpc.MigrationApiServer) *WebServer {
	return &WebServer{
		Closer:             ctx,
		port:               appViper.GetString("port"),
		Health:             hs,
		MigrationApiServer: mas,
		DevMode:            appViper.GetBool("dev"),
		UserDb:             BuildUserDb(fs, appViper),
		cert:               appViper.GetString("cert"),
		key:                appViper.GetString("key")}
}

func NewCancelPair(ctx context.Context) cancelPair {
	cancelCtx, cancelFn := context.WithCancel(ctx)
	return cancelPair{ctx: cancelCtx, fn: common.CancelFunction(cancelFn)}
}

func NewCancelContext(pair cancelPair) common.CancelContext {
	return pair.ctx
}

func NewCancelFunction(pair cancelPair) common.CancelFunction {
	return pair.fn
}

func GetViper() *viper.Viper {
	return viper.GetViper()
}

func NewSignalHandler(ctx common.CancelContext, cancelFn common.CancelFunction) *SignalHandler {
	return &SignalHandler{Closer: ctx, CancelFn: cancelFn}
}

func NewServiceTracker() *ServiceTrackerImpl {
	tracker := ServiceTrackerImpl{}
	tracker.AddService()
	return &tracker
}

func NewServices(
	t common.ServiceTracker,
	c common.CancelContext,
	hs *HealthService,
	ws *WebServer,
	sh *SignalHandler) *servicesImpl {
	return &servicesImpl{Tracker: t, context: c, Health: hs, Web: ws, SigHandler: sh}
}

var ProviderSet = wire.NewSet(
	GetViper,
	NewCancelContext,
	NewCancelFunction,
	NewCancelPair,
	NewMigrationEnvironments,
	NewMigrationApiServer,
	NewHealthService,
	NewServiceTracker,
	NewServices,
	NewSignalHandler,
	NewWebServer,
	wire.Bind(new(common.ServiceTracker), new(*ServiceTrackerImpl)),
	wire.Bind(new(Services), new(*servicesImpl)))
