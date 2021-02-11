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
	"time"

	"github.com/plezentek/dbshepherd/common"
)

type Services interface {
	StartAll()
	GracefulShutdown(time.Duration)
	Wait()
	RunWithGracefulShutdown(time.Duration)
}

type servicesImpl struct {
	Tracker    common.ServiceTracker
	Health     *HealthService
	Web        *WebServer
	SigHandler *SignalHandler
	context    context.Context
}

func (s *servicesImpl) StartAll() {
	// Do Nothing
	go s.SigHandler.Start(s.Tracker)
	go s.Web.Start(s.Tracker)
	go s.Health.Start(s.Tracker)
}

func (s *servicesImpl) Wait() {
	<-s.context.Done()
}

func (s *servicesImpl) GracefulShutdown(t time.Duration) {
	s.Tracker.GracefulShutdown(t)
}

func (s *servicesImpl) RunWithGracefulShutdown(t time.Duration) {
	s.StartAll()
	s.Wait()
	s.GracefulShutdown(t)
}
