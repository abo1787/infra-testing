I was having fun with this project, and probably did a bit more than was required, but I wanted to provide some thoughts around the process. 
This readme is probably not required, and I know you can easily parse what all I have in here, but I figured since I don't know if I'll get to chat with you about this I would provide some of my thoughts.  I tried to be as thorough as possible with a few caveats to allow for speed and keep from blowing up my personal AWS account.  Where I made provisions, I have tried to document them all below.

Reasons I did what I did where I did:
I built the terraform repo in order to allow there to be multiple environment deploys out of one terraform directory. (Currently dev/stage/prod)
To run the different env specific files you would simply navigate to the root terraform dir, and input 'terraform <plan/apply/etc> -var-file="/<env>/<region>/<variable file name>"'
I named the dev file as the default auto.tfvars file, but it of course will not run by default as it's not within the root directory.  

I split my .tf files into the resources that grouped together, as I believe it's cleaner this way. I have been told in the past it clutters the repo and is overkill for something this size. 
I made sure to utilize variables anywhere possible in my terraform so you need to check one place for variables, and as long as the TF itself doesn't need to change you can simply update one file.
I took some liberty in defining my own VPC, and subnets, and cidrs.  I over provisioned by a ton, and depending on the autoscaling of the ec2 instance under provisioned the ec2 subnet, I would not do this in an actual environment, and would normally have a cidr map provisioned beforehand and input the proper cidr ranges.  If I did all this in k8s this would be much more trivial to handle, but as there was an ask for an ec2 instance to handle the docker container I went instance instead of k8s as my focus.

From past experiences, and issues, I'm a big believer in your cidr ranges not overlapping in your environments if at all possible, I do this so that when you use a vpn to tunnel into an environment, you can have multiple vpn tunnels up without overlapping and breaking each other.  You could hook to both dev and stage and work within both if the cidr ranges don't overlap.

I have not implemented autoscaling of the application in question.  I figured that may be super overkill for simply providing my understanding of the requested tasks to you via this exercise. 

You will see that for my ingress and egress, I left egress open.  This was done for ease of deployment, and I would heavily recommend that both ingress and egress be locked down if at all possible

I have not deployed a bastion or any other ssh front layer to protect the infrastructure, I believe that is likely out of the scope of the needs here, and again would be overkill. 
In a full proper environment, I would propose the following:
    Non prod environments have ingress locked down, and allow app chatter across the load balancer for external ingress.  For SSH I would propose that we have our infrastructure cordoned off into a vpc where the only way through is via vpn. The vpn is allowed to connect to a bastion, the bastion is allowed to connect to the rest of the environment. Servers are locked down so that they do not allow ssh traffic from any other source but the bastion so people have to follow proper protocol.
    Prod environments should have much the same, but IFF there is an ephemeral access solution the company deems acceptable, use that to gate the access to the VPN tool so that while the keys can be static, the access to those keys is gated via approval