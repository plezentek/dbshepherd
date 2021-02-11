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
	"os"
	"os/signal"
	"syscall"

	"github.com/plezentek/dbshepherd/common"
	"k8s.io/klog"
)

type SignalHandler struct {
	Closer   common.CancelContext
	CancelFn common.CancelFunction
}

func (w *SignalHandler) Start(st common.ServiceTracker) {
	st.AddService()
	defer st.ShutdownService()
	// Create signal handler
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGTERM, syscall.SIGINT)
	defer func() {
		signal.Stop(c)
		w.CancelFn()
	}()

	select {
	case sig := <-c:
		klog.Infof("Received `%v` signal\n", sig.String())
		w.CancelFn()
	case <-w.Closer.Done():
		// Exit gracefully
	}
}
