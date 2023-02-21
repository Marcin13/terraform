# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES - S3 - STATIC WEBSITE
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "Bucket Name"
  type = string
  default = "teststrona123"
}





## ---------------------------------------------------------------------------------------------------------------------
## VARIABLES - GLOBAL
## ---------------------------------------------------------------------------------------------------------------------
#variable "custom_tags" {
#  type = object({
#    Client      = string
#    Project     = string
#    Environment = string
#    AWS_Account = string
#  })
#}
#
#variable "project_name" {
#  description = "Project Name"
#  type        = string
#  default     = ""
#}
#
#variable "account_id" {
#  description = "Account Id"
#  type = string
#  default = ""
#}
#
#variable "region" {
#  description = "Region"
#  type = string
#  default = ""
#}
#
## ---------------------------------------------------------------------------------------------------------------------
## VARIABLES - S3 - STATIC WEBSITE
## ---------------------------------------------------------------------------------------------------------------------
#variable "name" {
#  description = "Bucket Name"
#  type = string
#  default = ""
#}
#
#variable "index_document" {
#  description = "Document Index"
#  type = string
#  default = ""
#}
#
#variable "error_document" {
#  description = "Document error"
#  type = string
#  default = ""
#}
#
#
## ---------------------------------------------------------------------------------------------------------------------
## VARIABLES - CDN
## ---------------------------------------------------------------------------------------------------------------------
#variable "default_root_object" {
#  description = "Default Root Object"
#  type = string
#  default = ""
#}
#
#variable "cloudfront_aliases" {
#  description = "CloudFront Aliases"
#  type = list(string)
#  default = []
#}
#
#variable "web_acl_id" {
#  description = "Web ACL Id"
#  type = string
#  default = ""
#}
#
#variable "hosted_zone_acm_arn" {
#  description = "Hosted Zone ACM Arn"
#  type = string
#  default = ""
#}
#
#
## ---------------------------------------------------------------------------------------------------------------------
## VARIABLES - DNS
## ---------------------------------------------------------------------------------------------------------------------
#variable "hosted_zone_id" {
#  description = "Hosted Zone Id"
#  type = string
#  default = ""
#}
#
#variable "subdomain_record" {
#  description = "Subdomain Record"
#  type = string
#  default = ""
#}