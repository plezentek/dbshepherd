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
	"github.com/plezentek/dbshepherd/common"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
)

type cancelPair struct {
	ctx common.CancelContext
	fn  common.CancelFunction
}

func NewMigrationEnvironments(fs *pflag.FlagSet, appViper *viper.Viper) *MigrationEnvironments {
	return BuildEnvironments(fs, appViper)
}

func NewMigrationApiServer(
	ctx common.CancelContext,
	mes *MigrationEnvironments,
	hs *HealthService) *MigrationApiServer {
	return &MigrationApiServer{Closer: ctx, Health: hs, Environments: mes}
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
	mas *MigrationApiServer) *WebServer {
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
