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
	"time"

	"github.com/plezentek/dbshepherd/common"
	"k8s.io/klog"
)

type HealthService struct {
	Closer   common.CancelContext
	Reporter chan bool
	Checker  chan chan bool
}

func (hs *HealthService) Start(st common.ServiceTracker) {
	st.AddService()
	defer st.ShutdownService()
	defer func() {
		close(hs.Reporter)
		close(hs.Checker)
	}()

	currentHealthy := true
	klog.Infoln("Health Service starting")
	for {
		select {
		case responder := <-hs.Checker:
			klog.Infof("Health Service: Check() returning %v", currentHealthy)
			responder <- currentHealthy
		case newHealthy := <-hs.Reporter:
			klog.Infof("Health Service: Report() received %v", newHealthy)
			currentHealthy = newHealthy
		case <-hs.Closer.Done():
			klog.Infoln("Health Service: Shutting down")
			return
		}
	}
}

func (hs *HealthService) ReportHealthy(healthy bool) {
	// Don't block
	klog.Infof("Health Service API: ReportHealth() reporting %v", healthy)
	go func() {
		hs.Reporter <- healthy
	}()
}

func (hs *HealthService) CheckHealthy() bool {
	responder := make(chan bool, 1)
	defer close(responder)
	klog.Infoln("Health Service API: CheckHealthy()")
	hs.Checker <- responder
	select {
	case result := <-responder:
		klog.Infof("Health Service API: returning %v", result)
		return result
	case <-time.After(5 * time.Second):
		// A hung healthservice is by definition unhealthy
		klog.Infoln("Health Service API: CheckHealthy() hung")
		return false
	}
}
