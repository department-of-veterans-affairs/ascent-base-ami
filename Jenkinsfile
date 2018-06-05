@Library('ascent') _

packerPipeline {
    packerFile = 'base.json'
    vars = [aws_region: 'us-gov-west-1', vpc_id: "${env.VPC_ID}", subnet_id: "${env.SUBNET_ID}"]
}