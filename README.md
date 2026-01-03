# aws-ha-secure-webapp-
A diagram of a highly secure and available AWS architecture
# High level overview:
  - app is deployed to a single region
  - 2 different AZs
  - VPC spans both AZs
  - each AZ hosts a public app subnet
    public subnet hosts a NAT gateway and an ALB that spans both AZs
  - 2 private subnets
    1 private subnet for the compute layer - this case is EC2
    1 private subnet for the DB layer - RDS shown here
  - IGW provides inbound and outbound internet connectivity
  - ALB receives HTTPS only traffic from internet
  - NAT gws allow for outbound only internet access from the private subnets
# Traffic flow:
    - user traffic enters via ALB over HTTPS -> 
    - ALB forwards reqs to compute resources in private subnets -> 
    - app tier communicates with database tier internally -> 
    - outbound traffic from private subnets flows through the NAT gw only
# compute layer:
    - resources are deployed in private subnets
    - auto-scaling set to span multi-az
    - instances and tasks use IAM roles with least privilege permissions
    - no SSH access, this would be handled via AWS Systems Manager
# database layer:
   - RDS multi-az for high availability
    - deployed in private subnets
    - encryption at rest is enabled
    - automated backups are enabled
    - (no direct access from the internet or LB to the db layer)
# security considerations:
    - network layer
      no public IPs on application or db resources
      - security groups enforce strict access
        alb -> app tier only
        app tier -> db tier only
      - IAM
        follow least-privilege
        no long-lved credentials stored on compute resources
      - data protection
        encryption at rest for db
        tls termination at the load balancer
# monitoring and observability:
    - cloudwatch monitors
      alb load balancer metrics
      compute resource matrics
    - alarms can notify operators via SNS
    -  health checks ensure failed instances are replaced automaticaly
# cost considerations:
    NAT gw
    security and availabilty over minimal cost
    future optimization considerations
      vpc gw eps to reduce NAT traffic
      right size copmute resources based on load patterns
