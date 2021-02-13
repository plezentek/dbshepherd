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

package cmd

import (
	"context"
	"fmt"
	"os"
	"time"

	goflag "flag"

	"github.com/spf13/cobra"

	homedir "github.com/mitchellh/go-homedir"
	"github.com/plezentek/dbshepherd/app/services"
	_ "github.com/plezentek/dbshepherd/common"
	_ "github.com/spf13/pflag"
	"github.com/spf13/viper"
	_ "go.uber.org/automaxprocs/maxprocs"
	_ "google.golang.org/grpc"
	"k8s.io/klog"
)

var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "dbshepherd",
	Short: "Admin server for monitoring and performing database migrations",
	Long: `DB Shepherd is a web-based admin interface for checking on and performing
	database migrations.`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("DB Shepherd")

		// The context from which al activity is managed
		appContext := context.Background()

		// Start Services
		services := services.Build(appContext, cmd.PersistentFlags())
		services.RunWithGracefulShutdown(7 * time.Second)
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		klog.Fatalf("dbshepherd failed to execute, err=%v", err)
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	// Supported flags/config
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.dbshepherd.yaml)")
	rootCmd.PersistentFlags().Int16("port", 8080, "TCP port to listen on")
	rootCmd.PersistentFlags().String("cert", "", "Certificate file to use, must also set --key")
	rootCmd.PersistentFlags().String("key", "", "Key file to use, must also set --cert")
	rootCmd.PersistentFlags().StringArray("env", []string{}, "Migration environment  (e.g. 'prod: [file:///migrations/prod postgres://user:password@host/dbname]'")
	rootCmd.PersistentFlags().StringArray("user", []string{}, "Usernames and passwords required to access site (e.g. 'bob: $2a$10$abcedfgh')")
	rootCmd.PersistentFlags().Bool("dev", false, "Allow CORS request for easy frontend development")

	klog.InitFlags(nil)
	rootCmd.PersistentFlags().AddGoFlagSet(goflag.CommandLine)
	rootCmd.PersistentFlags().SortFlags = false
	rootCmd.Flags().SortFlags = false

	// Bind flags to viper so that we can use flags, env variables, or config file for setup
	viper.BindPFlag("port", rootCmd.PersistentFlags().Lookup("port"))
	viper.BindPFlag("cert", rootCmd.PersistentFlags().Lookup("cert"))
	viper.BindPFlag("key", rootCmd.PersistentFlags().Lookup("key"))
	viper.BindPFlag("dev", rootCmd.PersistentFlags().Lookup("dev"))
}

// initConfig reads in config file and ENV variables if set.
func initConfig() {
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := homedir.Dir()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		// Search config in home directory with name ".dbshepherd" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigName(".dbshepherd")
	}

	viper.SetEnvPrefix("DBS")
	viper.AutomaticEnv() // read in environment variables that match

	// If a config file is found, read it in.
	if err := viper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}
}
