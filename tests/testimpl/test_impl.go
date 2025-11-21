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
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/aws/aws-sdk-go-v2/service/ecs/types"
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
	clusterName := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_cluster_name")
	clusterArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "ecs_cluster_arn")
	clusterTags := terraform.OutputMap(t, ctx.TerratestTerraformOptions(), "ecs_cluster_tags_all")

	t.Run("TestECSClusterExists", func(t *testing.T) {
		testECSClusterExists(t, ecsClient, clusterName, clusterArn)
	})

	t.Run("TestECSClusterConfiguration", func(t *testing.T) {
		testECSClusterConfiguration(t, ecsClient, clusterName)
	})

	t.Run("TestECSClusterTags", func(t *testing.T) {
		testECSClusterTags(t, ecsClient, clusterName, clusterTags)
	})
}

func testECSClusterExists(t *testing.T, ecsClient *ecs.Client, clusterName, clusterArn string) {
	// Describe the cluster
	input := &ecs.DescribeClustersInput{
		Clusters: []string{clusterName},
	}

	result, err := ecsClient.DescribeClusters(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS cluster")
	require.Len(t, result.Clusters, 1, "Expected exactly one cluster")

	cluster := result.Clusters[0]
	assert.Equal(t, clusterName, *cluster.ClusterName, "Cluster name should match")
	assert.Equal(t, clusterArn, *cluster.ClusterArn, "Cluster ARN should match")
	assert.NotEmpty(t, cluster.ClusterArn, "Cluster ARN should not be empty")
}

func testECSClusterConfiguration(t *testing.T, ecsClient *ecs.Client, clusterName string) {
	// Describe the cluster
	input := &ecs.DescribeClustersInput{
		Clusters: []string{clusterName},
		Include:  []types.ClusterField{types.ClusterFieldSettings},
	}

	result, err := ecsClient.DescribeClusters(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS cluster")
	require.Len(t, result.Clusters, 1, "Expected exactly one cluster")

	cluster := result.Clusters[0]

	// Check that cluster is active
	assert.Equal(t, "ACTIVE", *cluster.Status, "Cluster should be ACTIVE")

	// Check settings
	expectedSettings := map[string]string{
		"containerInsights": "enabled",
	}

	if cluster.Settings != nil && len(cluster.Settings) > 0 {
		actualSettings := make(map[string]string)
		for _, setting := range cluster.Settings {
			actualSettings[string(setting.Name)] = *setting.Value
		}

		for name, expectedValue := range expectedSettings {
			actualValue, exists := actualSettings[name]
			assert.True(t, exists, "Expected setting %s to exist", name)
			if exists {
				assert.Equal(t, expectedValue, actualValue, "Setting %s should have value %s", name, expectedValue)
			}
		}
	}

	// Additional checks
	assert.NotNil(t, cluster.ClusterArn, "Cluster ARN should be present")
	assert.True(t, cluster.ClusterArn != nil && *cluster.ClusterArn != "", "Cluster ARN should not be empty")
}

func testECSClusterTags(t *testing.T, ecsClient *ecs.Client, clusterName string, expectedTags map[string]string) {
	// Describe the cluster
	input := &ecs.DescribeClustersInput{
		Clusters: []string{clusterName},
		Include:  []types.ClusterField{types.ClusterFieldTags},
	}

	result, err := ecsClient.DescribeClusters(context.TODO(), input)
	require.NoError(t, err, "Failed to describe ECS cluster")
	require.Len(t, result.Clusters, 1, "Expected exactly one cluster")

	cluster := result.Clusters[0]

	// Check tags
	if cluster.Tags != nil && len(cluster.Tags) > 0 {
		actualTags := make(map[string]string)
		for _, tag := range cluster.Tags {
			actualTags[*tag.Key] = *tag.Value
		}

		for key, expectedValue := range expectedTags {
			actualValue, exists := actualTags[key]
			assert.True(t, exists, "Expected tag %s to exist", key)
			if exists {
				assert.Equal(t, expectedValue, actualValue, "Tag %s should have value %s", key, expectedValue)
			}
		}
	}
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
