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

package grpc

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"strings"

	migrate "github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/source"
	pb "github.com/plezentek/dbshepherd/api"
	"github.com/plezentek/dbshepherd/common"
)

type MigrationApiServer struct {
	pb.UnimplementedMigrateServer
	Environments *common.MigrationEnvironments
}

func (mas *MigrationApiServer) ListEnvironments(ctx context.Context, request *pb.Empty) (*pb.ListEnvironmentsResponse, error) {
	environments := make([]*pb.Environment, len(mas.Environments.Environments))
	for index, value := range mas.Environments.Environments {
		environments[index] = &pb.Environment{Name: value.Name}
	}
	response := &pb.ListEnvironmentsResponse{Environments: environments}
	return response, nil
}

func (mas *MigrationApiServer) getEnvironment(environment string) (int, error) {
	if environment == "" {
		return 0, nil
	}
	for index, value := range mas.Environments.Environments {
		if value.Name == strings.ToLower(environment) {
			return index, nil
		}
	}
	return -1, fmt.Errorf("Migration Environment %s Not Found", environment)
}

func (mas *MigrationApiServer) GetDatabaseVersion(ctx context.Context, request *pb.Environment) (*pb.GetDatabaseVersionResponse, error) {
	response := &pb.GetDatabaseVersionResponse{}
	index, err := mas.getEnvironment(request.Name)
	if err != nil {
		return response, err
	}
	migration, err := migrate.New(mas.Environments.Environments[index].Source, mas.Environments.Environments[index].Database)
	if err != nil {
		return response, err
	}
	version, dirty, err := migration.Version()
	if err != nil {
		response.Error = err.Error()
	}
	response.Version, response.IsDirty = uint64(version), dirty
	return response, nil
}

func (mas *MigrationApiServer) ListMigrations(ctx context.Context, request *pb.Environment) (*pb.ListMigrationsResponse, error) {
	response := &pb.ListMigrationsResponse{}
	index, err := mas.getEnvironment(request.Name)
	if err != nil {
		return response, err
	}
	migrationSource, err := source.Open(mas.Environments.Environments[index].Source)
	if err != nil {
		return response, err
	}
	version, err := migrationSource.First()
	if oserr, ok := err.(*os.PathError); ok && oserr.Err == os.ErrNotExist {
		// Valid source, but no migrations
		return response, nil
	}
	if err != nil {
		// Problem with the sources
		return response, err
	}

	migration := &pb.Migration{Version: uint64(version)}
	if _, identifierUp, err := migrationSource.ReadUp(version); err == nil {
		migration.IdentifierUp = identifierUp
	}
	if _, identifierDown, err := migrationSource.ReadDown(version); err == nil {
		migration.IdentifierDown = identifierDown
	}

	migrations := []*pb.Migration{migration}
	for {
		version, err = migrationSource.Next(version)
		if err != nil {
			break
		}
		migration = &pb.Migration{Version: uint64(version)}
		if _, identifierUp, err := migrationSource.ReadUp(version); err == nil {
			migration.IdentifierUp = identifierUp
		}
		if _, identifierDown, err := migrationSource.ReadDown(version); err == nil {
			migration.IdentifierDown = identifierDown
		}
		migrations = append(migrations, migration)
	}
	if oserr, ok := err.(*os.PathError); ok && oserr.Err == os.ErrNotExist {
		// ErrNotExist means we've hit the last of the migrations, this is normal
		response.Migrations = migrations
		return response, nil
	}
	return response, err
}

func (mas *MigrationApiServer) GetMigration(ctx context.Context, request *pb.GetMigrationRequest) (*pb.GetMigrationResponse, error) {
	response := &pb.GetMigrationResponse{}
	index, err := mas.getEnvironment(request.Environment)
	if err != nil {
		return response, err
	}
	migrationSource, err := source.Open(mas.Environments.Environments[index].Source)
	version, err := migrationSource.First()
	for uint64(version) != request.Version && err == nil {
		version, err = migrationSource.Next(version)
	}
	if err != nil {
		return response, err
	}
	if uint64(version) == request.Version {
		migration := &pb.Migration{Version: uint64(version)}
		if sourceUp, identifierUp, err := migrationSource.ReadUp(version); err != nil {
			return response, err
		} else {
			migration.IdentifierUp = identifierUp
			buf := new(bytes.Buffer)
			buf.ReadFrom(sourceUp)
			migration.SourceUp = buf.String()
		}
		if sourceDown, identifierDown, err := migrationSource.ReadDown(version); err != nil {
			return response, err
		} else {
			migration.IdentifierDown = identifierDown
			buf := new(bytes.Buffer)
			buf.ReadFrom(sourceDown)
			migration.SourceDown = buf.String()
		}
		response.Migration = migration
	}
	return response, nil
}

func (mas *MigrationApiServer) SetVersion(ctx context.Context, request *pb.SetVersionRequest) (*pb.PerformMigrationResponse, error) {
	response := &pb.PerformMigrationResponse{}
	index, err := mas.getEnvironment(request.Environment)
	if err != nil {
		response.Successful = false
		return response, err
	}
	migration, err := migrate.New(mas.Environments.Environments[index].Source, mas.Environments.Environments[index].Database)
	if err != nil {
		response.Successful = false
		return response, err
	}
	err = migration.Migrate(uint(request.Version))
	if err != nil {
		response.Successful = false
		response.Error = err.Error()
	} else {
		response.Successful = true
	}
	return response, nil
}

func (mas *MigrationApiServer) ForceMarkVersion(ctx context.Context, request *pb.ForceMarkVersionRequest) (*pb.PerformMigrationResponse, error) {
	response := &pb.PerformMigrationResponse{}
	index, err := mas.getEnvironment(request.Environment)
	if err != nil {
		response.Successful = false
		return response, err
	}
	migration, err := migrate.New(mas.Environments.Environments[index].Source, mas.Environments.Environments[index].Database)
	if err != nil {
		response.Successful = false
		return response, err
	}
	err = migration.Force(int(request.Version))
	if err != nil {
		response.Successful = false
		response.Error = err.Error()
	} else {

		response.Successful = true
	}
	return response, nil
}
