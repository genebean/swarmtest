# Swarm Test

This is a demo of how to use the Puppet module
[puppetlabs/docker](https://forge.puppet.com/puppetlabs/docker)
to setup and manage a 3 node Docker Swarm cluster in Vagrant and deploy a
Docker Compose application to it as a stack. The stack is comprised of an
unmodified Nginx container and a linked Redis container. You can access Nginx
via any of the urls in the table below after running `vagrant up` in the
project's root directory.

In the Vagrantfile I take advantage of the fact that its actually a ruby file
and iterate over a range instead of repeating a bunch of code. For those less
familiar with ruby, here is a quick explination of what's going on. The file
starts out like most Vagrantfiles do and then has this:

```ruby
(1..3).each do |n|
  # regular code for a Vagrantfile here
end
```

What this does is create a loop that will run the code in the middle for each
number in the range (1 through 3 in this case) and represent the number its on
with a variable named `n`. It puts that variable to use in the code below
when naming the vm's, when setting the static ip, and when defining the port to
forward to on the host:

```ruby
docker.vm.hostname = "docker#{n}"
docker.vm.network "private_network", ip: "172.16.0.#{n + 10}"
docker.vm.network "forwarded_port", guest: 80, host: "808#{n}"
```

This will generate the following by appending `n` to the hostname and `n + 10`
to the ip address:

| hostname | static ip   | port | Nginx URL             |
| -------- | ----------- | ---- | --------------------- |
| docker1  | 172.16.0.11 | 8081 | http://localhost:8081 |
| docker2  | 172.16.0.12 | 8082 | http://localhost:8082 |
| docker3  | 172.16.0.13 | 8083 | http://localhost:8083 |

A `puppet apply` run happens on each VM as part of the setup process. The
`docker1` vm has code that initializes the swarm and then creates a file in the
project's root directory called `manager-token`. The line below ensures that
on a freshly cloned setup that there are not errors due to this file not
existing yet:

```ruby
if File.exists?('./manager-token')
  # more Vagrant code
end
```
