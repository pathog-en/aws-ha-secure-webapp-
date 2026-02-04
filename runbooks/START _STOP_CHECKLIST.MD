--- Commands for checking online:

1 - aws eks list-clusters --region us-east-2

(if online - cluster name will be listed / if not - nothing listed)

Check K8s connectivity:

2 - kubectl get nodes

(nodes returned = up and running)

3 - kubectl get ingress aws-ha-webapp-ingress

(address present = publically reachable)

4 - curl -I https://game.pathog-en.dev/health

(status 200 = online)

--- Commands to bring project online from offline:

5- cd terraform/eks
 - terraform apply auto-approve

(start on repo root - runn above, wait until complete)

6 - kubectl get nodes 

(show workers in ready status)

7 - kubectl apply -f k8s/deployment.yaml
  - kubectl apply -f k8s/service.yaml
  - kubectl apply -f k8s/ingress.yaml

(deploy app resources)

8 - kubectl get ingress aws-ha-webapp-ingress

(wait until 'address' shows aws alb url)

9 - if ALB hostname changes, update SS DNS
	- host = game
	- type = CNAME
	- alias/data = (alb url from step 8)

10 - curl -I https://game.pathog-en.dev/health
   - curl -I https://game.pathogn-en.dev/game

--- Commands to take fully offline

11 - cd terraform/eks
   - terraform destroy -auto-approve

(run from repo root)

12 - aws eks list-clusters --region us-east-2
   - kubectl get nodes 

(nothing listed = offline)

13 - curl -I https://game.pathogn-en.dev/health

(should fail = offline)

--- Command if need to bring offline w/o destroying 

14 - kubectl delete ingress aws-ha-webapp-ingress
   - kubectl scale deployment aws-ha-webapp --replicas=0

(delete ingress and scale in deployment, replicas to zero)

--- Command to being online fast

15 - kubectl scale deployment aws-ha-webapp --replicas=2
   - kubectl apply -f k8s/ingress.yaml