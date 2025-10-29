package testimpl

import (
	"context"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testTypes "github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	failedToGetSecurityGroupMsg = "Failed to get security group"
	failedToFindIngressRuleMsg  = "Failed to find ingress rule"
)

func TestComposableComplete(t *testing.T, ctx testTypes.TestContext) {
	ec2Client := GetAWSEC2Client(t)

	ingressRuleId := terraform.Output(t, ctx.TerratestTerraformOptions(), "ingress_rule_id")
	securityGroupId := terraform.Output(t, ctx.TerratestTerraformOptions(), "security_group_id")
	effectiveSource := terraform.Output(t, ctx.TerratestTerraformOptions(), "effective_source")

	t.Run("TestSecurityGroupIngressRuleExists", func(t *testing.T) {
		testSecurityGroupIngressRuleExists(t, ec2Client, securityGroupId, ingressRuleId)
	})

	t.Run("TestSecurityGroupIngressRuleProperties", func(t *testing.T) {
		testSecurityGroupIngressRuleProperties(t, ec2Client, securityGroupId, ingressRuleId)
	})

	t.Run("TestEffectiveSource", func(t *testing.T) {
		testEffectiveSource(t, effectiveSource)
	})
}

func testSecurityGroupIngressRuleExists(t *testing.T, ec2Client *ec2.Client, securityGroupId, ingressRuleId string) {
	// Get security group
	sg, err := ec2Client.DescribeSecurityGroups(context.TODO(), &ec2.DescribeSecurityGroupsInput{
		GroupIds: []string{securityGroupId},
	})
	require.NoError(t, err, failedToGetSecurityGroupMsg)
	require.NotEmpty(t, sg.SecurityGroups, "Security group should exist")

	// Verify security group has at least one ingress rule
	assert.NotEmpty(t, sg.SecurityGroups[0].IpPermissions, "Security group should have at least one ingress rule")
}

func testSecurityGroupIngressRuleProperties(t *testing.T, ec2Client *ec2.Client, securityGroupId, ingressRuleId string) {
	// Get security group rules
	rules, err := ec2Client.DescribeSecurityGroupRules(context.TODO(), &ec2.DescribeSecurityGroupRulesInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("group-id"),
				Values: []string{securityGroupId},
			},
		},
	})
	require.NoError(t, err, "Failed to describe security group rules")

	// Find the specific ingress rule by ID
	var ingressRule *types.SecurityGroupRule
	for i := range rules.SecurityGroupRules {
		rule := &rules.SecurityGroupRules[i]
		if rule.SecurityGroupRuleId != nil && *rule.SecurityGroupRuleId == ingressRuleId {
			ingressRule = rule
			break
		}
	}

	require.NotNil(t, ingressRule, "Ingress rule should be found")

	// Verify basic rule properties (protocol-agnostic)
	assert.False(t, *ingressRule.IsEgress, "Rule should be an ingress rule")
	assert.NotNil(t, ingressRule.IpProtocol, "Rule should have a protocol specified")

	// Verify at least one source is set
	hasSource := ingressRule.CidrIpv4 != nil ||
		ingressRule.CidrIpv6 != nil ||
		ingressRule.PrefixListId != nil ||
		ingressRule.ReferencedGroupInfo != nil
	assert.True(t, hasSource, "Rule should have at least one source (CIDR, prefix list, or SG)")
}

func testEffectiveSource(t *testing.T, effectiveSource string) {
	assert.NotEmpty(t, effectiveSource, "Effective source should not be empty")
	// Verify it has one of the expected prefixes
	hasValidPrefix := strings.Contains(effectiveSource, "cidr_ipv4:") ||
		strings.Contains(effectiveSource, "cidr_ipv6:") ||
		strings.Contains(effectiveSource, "prefix_list:") ||
		strings.Contains(effectiveSource, "security_group:")
	assert.True(t, hasValidPrefix, "Effective source should have a valid prefix (cidr_ipv4, cidr_ipv6, prefix_list, or security_group)")
}

func GetAWSEC2Client(t *testing.T) *ec2.Client {
	awsEC2Client := ec2.NewFromConfig(GetAWSConfig(t))
	return awsEC2Client
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
