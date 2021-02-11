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
	"math/rand"
	"time"

	"github.com/spf13/pflag"
	"github.com/spf13/viper"
	"golang.org/x/crypto/bcrypt"
	yaml "gopkg.in/yaml.v2"
	"k8s.io/klog"
)

type UserDb struct {
	Users []User `mapstructure:"users"`
}

type User struct {
	Username string `mapstructure:"user" yaml:"user"`
	Password string `mapstructure:"pass" yaml:"pass"`
}

func init() {
	rand.Seed(time.Now().UnixNano())
}

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func randStringBytes(n int) string {
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}

func RandUser() User {
	return User{Username: randStringBytes(10), Password: randStringBytes(30)}
}

func (udb *UserDb) AuthEnabled() bool {
	return len(udb.Users) > 0
}

func (udb *UserDb) IsAuthenticated(user string, password string) bool {
	for _, entry := range udb.Users {
		if user != entry.Username {
			continue
		}
		if err := bcrypt.CompareHashAndPassword([]byte(entry.Password), []byte(password)); err != nil {
			klog.Warningf("Unable to authenicate user %s: %s", user, err)
			return false
		}
		return true
	}
	return false
}

func BuildUserDb(fs *pflag.FlagSet, viper *viper.Viper) *UserDb {
	// If we have some sort of problem building a user database, we fail safe
	// and lock access to the interface by generating an unguessable username
	// and password
	lockout := UserDb{Users: []User{RandUser()}}

	var out UserDb
	if fs.Changed("user") {
		// User flag can be repeated to add multiple users.  It is effectively
		// an inline YAML dictionary with one key only.  The key is the
		// username and the value is the bcrypt password hash
		// Example: --user 'username: passwordhash' --user 'username2: passwordhash2'
		raw, err := fs.GetStringArray("user")
		if err != nil {
			klog.Errorf("Internal error parsing user flag: %s", err)
			return &lockout
		}
		for _, v := range raw {
			var user map[string]string
			if err := yaml.Unmarshal([]byte(v), &user); err == nil && len(user) == 1 {
				for username, password := range user {
					if cost, err := bcrypt.Cost([]byte(password)); err != nil {
						klog.Errorf("Internal error parsing bcrypt password hash: %s", err)
						return &lockout
					} else if cost < 10 {
						klog.Errorf("Internal error parsing bcrypt password hash: Cost too low (<10)")
						return &lockout
					}
					out.Users = append(out.Users, User{Username: username, Password: password})
				}
			} else if err != nil {
				klog.Errorf("Internal error parsing user flag: %s", err)
				return &lockout
			} else {
				klog.Errorf("Internal error parsing user flag, found %d entries instead of 1", len(user))
				return &lockout
			}
		}
	} else {
		if viper.InConfig("users") {
			// Users config entry expects a dictionary where each key is a
			// username and each value is a bcrypt password hash
			// Example:
			// users:
			//   username: passwordhash
			//   username2: passwordhash2
			var users map[string]string
			if err := viper.UnmarshalKey("users", &users); err == nil {
				for username, password := range users {
					if cost, err := bcrypt.Cost([]byte(password)); err != nil {
						klog.Errorf("Internal error parsing bcrypt password hash: %s", err)
						return &lockout
					} else if cost < 10 {
						klog.Errorf("Internal error parsing bcrypt password hash: Cost too low (<10)")
						return &lockout
					}
					out.Users = append(out.Users, User{Username: username, Password: password})
				}
			} else {
				klog.Errorf("Internal error parsing config file: %s", err)
				return &lockout
			}
		} else {
			// DBS_USERS environment variable expects a YAML list of
			// dictionaries. Each dictionary has one key only where the key is
			// the username and the value is the bcrypt password hash.
			// Example: DBS_USERS='[username: passwordhash, username2: passwordhash2]'
			raw := viper.GetString("users")
			var users []map[string]string
			if err := yaml.Unmarshal([]byte(raw), &users); err == nil {
				for _, user := range users {
					if len(user) != 1 {
						klog.Errorf("Internal error parsing environment variable, found %d keys in user dict instead of 1", len(user))
						return &lockout
					}
					for username, password := range user {
						if cost, err := bcrypt.Cost([]byte(password)); err != nil {
							klog.Errorf("Internal error parsing bcrypt password hash: %s", err)
							return &lockout
						} else if cost < 10 {
							klog.Errorf("Internal error parsing bcrypt password hash: Cost too low (<10)")
							return &lockout
						}
						out.Users = append(out.Users, User{Username: username, Password: password})
					}
				}
			} else {
				klog.Errorf("Internal error parsing environment variable: %s", err)
				return &lockout
			}
		}
	}
	return &out
}
