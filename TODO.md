# To do

- Support extra user-data
- Tighten IAM policy: restrict access to just kops bucket, just relevant ASGs, single Route53 zone
- Have option to choose master count as one US region has 6x AZs. If AZ count is even, do AZ count -1.
- Put hashes for each k8s version into a map
