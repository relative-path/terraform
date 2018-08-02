# Terraform for RelativePath.io

## Setting up AWS

```
> aws configure --profile relativepath
* paste in access key
* paste secret key
* default region us-west-2
* format/output/whatever as json
```

## Running Terraform

```
> terraform init
> env AWS_PROFILE=relativepath terraform apply
```

## Resources

* [Setting up a Cloudfront Distribution](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)
* [Heroku + DNSimple](https://github.com/hashicorp/terraform/blob/2487af19453a0d55a428fb17150f87b24170ccc1/examples/cross-provider/main.tf)
