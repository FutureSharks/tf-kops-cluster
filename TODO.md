# To do

- Tighten IAM rules. S3 and Route 53 access should be specific to the cluster bucket and the specific zone ID.
- Do we need an internal ELB?
- Does on destroy `kops delete cluster` work?
- Use ALBs instead of ELBs
- Support more options for `kops create cluster`
- Support extra user-data
