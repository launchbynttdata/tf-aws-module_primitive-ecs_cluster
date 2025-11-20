// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testimpl

import (
	"context"
	"strconv"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testTypes "github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx testTypes.TestContext) {
	// Get AWS ECS client
	ecsClient := GetAWSECSClient(t)

	// Get outputs from Terraform
	serviceName := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_service_name")
	clusterName := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_service_cluster")
	desiredCountStr := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_service_desired_count")
	taskDefinition := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_service_task_definition")
	launchType := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_service_launch_type")

	// Convert desired_count to int
	desiredCount := 0
	if desiredCountStr != "" {
		var err error
		desiredCount, err = strconv.Atoi(desiredCountStr)
		if err != nil {
			t.Fatalf("Invalid desired count: %s", desiredCountStr)
		}
	}

	t.Run("TestECSServiceExists", func(t *testing.T) {
		testECSServiceExists(t, ecsClient, serviceName, clusterName)
	})

	t.Run("TestECSServiceConfiguration", func(t *testing.T) {
		testECSServiceConfiguration(t, ecsClient, serviceName, clusterName, desiredCount, taskDefinition, launchType)
	})
}

func testECSServiceExists(t *testing.T, ecsClient *ecs.Client, serviceName, clusterName string) {
	// Describe the service
	input := &ecs.DescribeServicesInput{
		Services: []string{serviceName},
		Cluster:  aws.String(clusterName),
	}

	result, err := ecsClient.DescribeServices(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS service")
	require.Len(t, result.Services, 1, "Expected exactly one service")

	service := result.Services[0]
	assert.Equal(t, serviceName, *service.ServiceName, "Service name should match")
	// Note: ClusterArn is the full ARN, clusterName might be name or ARN
	assert.Contains(t, *service.ClusterArn, clusterName, "Cluster ARN should contain the cluster name")
	assert.NotEmpty(t, service.ServiceArn, "Service ARN should not be empty")
}

func testECSServiceConfiguration(t *testing.T, ecsClient *ecs.Client, serviceName, clusterName string, expectedDesiredCount int, expectedTaskDefinition, expectedLaunchType string) {
	// Describe the service
	input := &ecs.DescribeServicesInput{
		Services: []string{serviceName},
		Cluster:  aws.String(clusterName),
	}

	result, err := ecsClient.DescribeServices(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS service")
	require.Len(t, result.Services, 1, "Expected exactly one service")

	service := result.Services[0]

	// Check desired count
	assert.Equal(t, int32(expectedDesiredCount), service.DesiredCount, "Desired count should match")

	// Check task definition
	assert.Equal(t, expectedTaskDefinition, *service.TaskDefinition, "Task definition should match")

	// Check launch type
	if expectedLaunchType != "" {
		assert.Equal(t, expectedLaunchType, string(service.LaunchType), "Launch type should match")
	}

	// Additional checks
	assert.NotNil(t, service.ServiceArn, "Service ARN should be present")
	assert.NotNil(t, service.ClusterArn, "Cluster ARN should be present")
	assert.True(t, service.ServiceArn != nil && *service.ServiceArn != "", "Service ARN should not be empty")
}

func GetAWSECSClient(t *testing.T) *ecs.Client {
	awsECSClient := ecs.NewFromConfig(GetAWSConfig(t))
	return awsECSClient
}

func GetAWSSTSClient(t *testing.T) *sts.Client {
	awsSTSClient := sts.NewFromConfig(GetAWSConfig(t))
	return awsSTSClient
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
