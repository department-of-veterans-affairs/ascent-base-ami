@Library('ascent') _

packerPipeline {
    packerFile = 'base.json'
    vars = [aws_region: 'us-gov-west-1', vpc_id: "${this.env.VPC_ID}", subnet_id: "${this.env.SUBNET_ID}"]
}