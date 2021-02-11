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
	"sync"
	"time"

	"k8s.io/klog"
)

type ServiceTrackerImpl struct {
	wg         sync.WaitGroup
	addservice chan<- bool
}

func (c *ServiceTrackerImpl) AddService() {
	c.wg.Add(1)
}

func (c *ServiceTrackerImpl) ShutdownService() {
	c.wg.Done()
}

func (c *ServiceTrackerImpl) GracefulShutdown(t time.Duration) {
	klog.Infoln("Shutting down gracefully")
	c.wg.Done() // Remove implicit service
	timer := make(chan struct{})
	go func() {
		defer close(timer)
		c.wg.Wait()
	}()
	select {
	case <-timer:
		// no op
		klog.Infoln("Graceful shutdown finished waiting")
	case <-time.After(t):
		klog.Infoln("Graceful shutdown timed out")
		// no op
	}
}
